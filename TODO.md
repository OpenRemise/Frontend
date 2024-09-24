# TODO

## Slow mDNS resolution
For some reason mDNS resolution is super slow on desktop...  
https://askubuntu.com/questions/1279792/local-hostname-resolution-is-slow-on-20-04

This can be solved though by editing /etc/nsswitch.conf  
https://wiki.archlinux.org/title/avahi

Replacing mdns_minimal with mdns4_minimal did the trick so far

## Packages
- [dartdoc](https://pub.dev/packages/dartdoc)
- [animated_toggle_switch](https://pub.dev/packages/animated_toggle_switch)
- [easy_localization](https://pub.dev/packages/easy_localization)
- [sliver_tools](https://pub.dev/packages/sliver_tools)
- [flutter_slidable](https://pub.dev/packages/flutter_slidable)
- [radial_button](https://pub.dev/packages/radial_button)
- [fl_chart](https://pub.dev/packages/fl_chart)
- [pie_menu](https://pub.dev/packages/pie_menu)
- [flutter_xslider](https://pub.dev/packages/flutter_xlider)
- [sleek_circular_slider](https://pub.dev/packages/sleek_circular_slider)
- [flutter_staggered_grid_view](https://pub.dev/packages/flutter_staggered_grid_view)
- [websocket_universal](https://pub.dev/packages/websocket_universal)

## Android
Gradle version clusterfuck  
https://docs.gradle.org/current/userguide/compatibility.html
Emulator needs to be launched from within /opt/android-sdk/tools/emulator and with -feature -Vulkan

## Z21 app
Maybe we should take a look at how the Z21 app imports/exports locos? It seems to be some sq3lite thing?

## Service screen
Look how Z21 does it, probably a good idea to split between some large display screen and small display screen
Have just a single CV read/write button on small screen
And an entire table on larger ones?
Also, how about JMRI import?
- re-read and re-write button?

## Cab
Option for left-handers to have slider left?
LinearGradient for Sliders CustomCurve would be great... (would be a PR)
There is currently a data race when switching locos while the cab is still open, no clue how we can prevent that?

## Make use of collections
Instead of manually creating chunks of X bytes do this

```dart
import 'package:collection/collection.dart';

void main() {
  List<dynamic> numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  Iterable<List<dynamic>> chunksCollection = numbers.slices(3);
  print(chunksCollection);
}
```

## svgcleaner
Use this tool to clean up fucked up .svg files  
https://github.com/RazrFalcon/svgcleaner