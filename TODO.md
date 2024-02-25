# TODO

## Slow mDNS resolution
For some reason mDNS resolution is super slow on desktop...  
https://askubuntu.com/questions/1279792/local-hostname-resolution-is-slow-on-20-04

This can be solved though by editing /etc/nsswitch.conf  
https://wiki.archlinux.org/title/avahi

Replacing mdns_minimal with mdns4_minimal did the trick so far

## Packages
- [sliver_tools](https://pub.dev/packages/sliver_tools)
- [flutter_slidable](https://pub.dev/packages/flutter_slidable)
- [radial_button](https://pub.dev/packages/radial_button)
- [fl_chart](https://pub.dev/packages/fl_chart)
- [pie_menu](https://pub.dev/packages/pie_menu)
- [flutter_xslider](https://pub.dev/packages/flutter_xlider)
- [sleek_circular_slider](https://pub.dev/packages/sleek_circular_slider)
- [flutter_locales](https://pub.dev/packages/flutter_locales)
- [flutter_staggered_grid_view](https://pub.dev/packages/flutter_staggered_grid_view)

## Theme
Flutter can create a theme from an image, although that doesn't seem to work on the web...?  
https://www.youtube.com/watch?v=CfOlY36GWYU

## Android
Gradle version clusterfuck  
https://docs.gradle.org/current/userguide/compatibility.html

Emulator needs to be launched from within /opt/android-sdk/tools/emulator and with -feature -Vulkan

## Material design
https://m3.material.io/

## Z21 app
Maybe we should take a look at how the Z21 app imports/exports locos? It seems to be some sq3lite thing?

## Partitions
Currently I use the following partitions.csv
ota_0 4M  
ota_1 4M  
nvs 8M  
storage rest  

Maybe 4M OTA ain't enough for future app stuff? Also there is no room for images. Maybe create an 8MB "data" partition and an 8MB "frontend" one?

## Update screen
Update screen needs
- MDU update
- Frontend update

## Service screen
- re-read and re-write button?

## Setting base-href from the command line
flutter build web --base-href "/path/"

## Better constant names
WIDTH -> MAX_NAV_RAIL_WIDTH (or MIN_NAV_BAR_WIDTH)

## Cab
Option for left-handers to have slider left?
LinearGradiant for Sliders CustomCurve would be great... (would be a PR)
There is currently a data race when switching locos while the cab is still open, no clue how we can prevent that?