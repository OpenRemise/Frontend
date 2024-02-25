import 'dart:math';

import 'package:html/dom.dart';
import 'package:html/dom_parsing.dart';
import 'package:version/version.dart';

class MsDatabaseInfo {
  String date = '';
  List<String> changelog = [];

  @override
  String toString() {
    return 'Date $date, changelog entries: ${changelog.length}';
  }
}

typedef MsDatabase = Map<String, MsDatabaseInfo>;

class MsDatabaseVisitor extends TreeVisitor {
  final String _lang;
  final MsDatabase _msDatabase = {};

  MsDatabase get msDatabase => _msDatabase;

  MsDatabaseVisitor(this._lang);

  @override
  void visitElement(Element node) {
    // Table with first row id 'flashinfo' contains all we need
    if (node.children.length > 1 && node.children[0].id.contains('flashinfo')) {
      final List<Element> trs = node.children.sublist(1);

      for (final Element tr in trs) {
        // Version (don't use any below 4.202.0)
        if (double.tryParse(tr.children[0].text) == null) continue;
        Version version = Version.parse(tr.children[0].text);
        if (version < Version.parse('4.202')) continue;
        final String key = '${version.major}.${version.minor}';
        _msDatabase[key] = MsDatabaseInfo();

        // Date
        final String dateStr = tr.children[1].text
            .replaceAll(RegExp(r'\s'), '')
            .substring(0, min(10, tr.children[1].text.length));
        final String? date = RegExp(
                r'^(?:(?:31(\/|-|\.)(?:0?[13578]|1[02]|(?:Jan|Mar|May|Jul|Aug|Oct|Dec)))\1|(?:(?:29|30)(\/|-|\.)(?:0?[1,3-9]|1[0-2]|(?:Jan|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec))\2))(?:(?:1[6-9]|[2-9]\d)?\d{2})$|^(?:29(\/|-|\.)(?:0?2|(?:Feb))\3(?:(?:(?:1[6-9]|[2-9]\d)?(?:0[48]|[2468][048]|[13579][26])|(?:(?:16|[2468][048]|[3579][26])00))))$|^(?:0?[1-9]|1\d|2[0-8])(\/|-|\.)(?:(?:0?[1-9]|(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep))|(?:1[0-2]|(?:Oct|Nov|Dec)))\4(?:(?:1[6-9]|[2-9]\d)?\d{2})$')
            .stringMatch(dateStr);
        if (date != null) _msDatabase[key]?.date = date;

        // Changelog (either german or english)
        final List<Element> uls = tr
            .children[_lang.toLowerCase() == 'de' ? 2 : 3]
            .getElementsByTagName('ul');
        for (final ul in uls) {
          for (final li in ul.children) {
            _msDatabase[key]?.changelog.add(li.text.trim());
          }
        }
      }
    }

    visitNodeFallback(node);
  }
}
