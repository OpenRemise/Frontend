import 'dart:convert';

import 'package:html/dom.dart';
import 'package:html/dom_parsing.dart';

// Each project can contain multiple downloads
// b and f are query parameters to www.zimo.at/web2010/scripts/download_zpp.php
class SoundDatabaseProjectDownload {
  String b = '';
  String f = '';
  String decoder = '';
  String? pdf;
}

// Those are the actual projects inside each AnchorPr
// The elements have IDs like "myvar322348"
class SoundDatabaseProject {
  String author = '';
  String type = '';
  String added = '';
  String updated = '';
  List<SoundDatabaseProjectDownload> downloads = [];
}

// This is the expandable tile which contains the overview
// The elements have IDs like "anchorPr322348"
class SoundDatabaseInfo {
  String flag = '';
  String gauge = '';
  String traction = '';
  String company = '';
  String series = '';
  String? image;
  String heading = '';
  String description = '';
  List<SoundDatabaseProject> projects = [];
}

typedef SoundDatabase = Map<String, List<SoundDatabaseInfo>>;

class SoundDatabaseVisitor extends TreeVisitor {
  String _alpha2 = '';
  final SoundDatabase _soundDatabase = {};
  final Map<String, String> _flags = {};

  SoundDatabase get soundDatabase {
    // Set source of flag image in every project
    _soundDatabase.forEach((alpha2, infos) {
      for (final SoundDatabaseInfo info in infos) {
        if (_flags.containsKey(alpha2)) info.flag = _flags[alpha2]!;
      }
    });
    return _soundDatabase;
  }

  @override
  void visitElement(Element node) {
    // Those are the country codes
    if (node.id.isNotEmpty && node.id.length <= 2) _alpha2 = node.id;

    // Use onclick attribute to find flags images
    final String? onclick = node.attributes['onclick'];
    if (onclick != null && onclick.contains('switchCountry')) {
      final String? alpha2 =
          RegExp(r"'\w{2}'").stringMatch(onclick)?.replaceAll("'", '');
      if (alpha2 != null && !_flags.containsKey(alpha2)) {
        final Element img = node.getElementsByTagName('img')[0];
        final String? src = img.attributes['src'];
        _flags[alpha2] = 'http://www.zimo.at/web2010/images/$src';
      }
    }

    // Row with classification (e.g. gauge, traction, ....)
    if (node.id.contains('anchorPr')) {
      assert(node.children.length == 7);
      var info = SoundDatabaseInfo();
      info.gauge = node.children[1].text;
      info.traction = node.children[2].text;
      info.company = node.children[3].text;
      info.series = node.children[4].text;
      _soundDatabase.update(
        _alpha2,
        (infos) => infos + [info],
        ifAbsent: () => [info],
      );
    }

    // Expanded table with image, heading and description
    if (node.id.contains('TableDetail')) {
      assert(node.children.length == 2);

      // Body of the table we're interessted in
      final Element tbody = node.getElementsByTagName('tbody')[0];

      // The first row contains everything
      final Element firstTr = tbody.children[0];
      assert(firstTr.children.length == 2);

      // First column is the image
      final Element firstTd = firstTr.children[0];
      final String? image = firstTd.children[0].attributes['href'];
      _soundDatabase[_alpha2]?.last.image = image;

      // Second column contains heading, description and maybe a wiki link
      final Element secondTd = firstTr.children[1];
      final String heading = secondTd.children[0].text;
      _soundDatabase[_alpha2]?.last.heading = heading;

      // Description format is anarchy. It can be anything from multiple paragraphs to plain text
      // Remove all the crap we don't need:
      // - Arbitrary newlines
      // - Language hints
      // - Wiki links
      // And finally trim...
      final String description = secondTd.text
          .replaceAll(heading, '')
          .replaceAll('\n', '')
          .replaceAll(
            RegExp(r'(Sorry, only in German\s*)'),
            'Sorry, only in German\n',
          )
          .replaceAll(
            RegExp(r'(Leider, nur in Englisch\s*)'),
            'Leider, nur in Englisch\n',
          )
          .replaceAll(
            RegExp(r'((Mehr aus Wikipedia)|(More from Wikipedia))'),
            '',
          )
          .replaceAll('(only in German)', '')
          .trim();
      _soundDatabase[_alpha2]?.last.description = description;
    }

    // Each database entry might contain multiple projects associated with it
    if (node.id.contains('TableProject')) {
      SoundDatabaseProject project = SoundDatabaseProject();

      // Body might contain multiple expandable tables...
      final Element tbody = node.getElementsByTagName('tbody')[0];

      // Each row inside the body contains a new project
      for (final Element tr in tbody.children) {
        // If the row does not contain an ID, it contains information about the author, type and date
        if (!tr.id.contains('myvar')) {
          final Element secondTd = tr.children[1];
          String? str = RegExp(r'Auth*or:\s.*').stringMatch(secondTd.text);
          str = str?.replaceAll(RegExp(r'Auth*or:\s'), '').trim();
          if (str != null) project.author = str;
          str = RegExp(r'Type*:\s.*').stringMatch(secondTd.text);
          str = str?.replaceAll(RegExp(r'Type*:\s'), '').trim();
          if (str != null) project.type = str;
          str = RegExp(r'((Added)|(Erstellt)):\s.*').stringMatch(secondTd.text);
          str = str?.replaceAll(RegExp(r'((Added)|(Erstellt)):\s'), '').trim();
          if (str != null) project.added = str;
          str =
              RegExp(r'((Updated)|(Geändert)):\s.*').stringMatch(secondTd.text);
          str =
              str?.replaceAll(RegExp(r'((Updated)|(Geändert)):\s'), '').trim();
          if (str != null) project.updated = str;
        }
        // If the row contains an ID it contains the actual downloadable stuff...
        else {
          // Body with at least 1 tr child
          final Element tbody = tr.getElementsByTagName('tbody')[0];

          // Each row contains different stuff, look for links
          for (final Element tr in tbody.children) {
            final List<Element> as = tr.getElementsByTagName('a');
            if (as.isEmpty) continue;

            // Only interessted in rows containing .zpp file links
            final String? zpp = as[0].attributes['href'];
            if (zpp != null && zpp.endsWith('zpp')) {
              SoundDatabaseProjectDownload download =
                  SoundDatabaseProjectDownload();

              // Project might contain mutated vowel, force UTF-8
              final Uri uri = Uri.dataFromString(
                zpp,
                encoding: Encoding.getByName('UTF-8'),
              );
              if (uri.queryParameters['b'] != null) {
                download.b = Uri.decodeFull(uri.queryParameters['b']!);
              }
              if (uri.queryParameters['f'] != null) {
                download.f = uri.queryParameters['f']!;
              }

              // Additonal link might be documentation
              if (as.length > 1) {
                final pdf = as[1].attributes['href'];
                if (pdf != null && pdf.endsWith('pdf')) {
                  download.pdf = pdf;
                }
              }

              // That particular project fits the following decoders
              for (final Element td in tr.children) {
                if (td.text.contains(RegExp(r'Decoder:\s'))) {
                  download.decoder =
                      td.text.replaceAll(RegExp(r'Decoder:\s'), '');
                }
              }

              project.downloads.add(download);
            }
          }
        }
      }

      _soundDatabase[_alpha2]?.last.projects.add(project);
    }

    visitNodeFallback(node);
  }
}
