// Copyright (C) 2025 Vincent Hamp
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

/// Documentation
///
/// \file   doxygen.dart
/// \author Vincent Hamp
/// \date   03/11/2024

/// \details
/// Welcome to the OpenRemise [Frontend](https://github.com/OpenRemise/Frontend)
/// documentation, the software powering the OpenRemise web interface.
///
/// \note
/// This documentation is intended for developers. General information on usage
/// can be found on the main page at [openremise.at](https://openremise.at).
///
/// \mainpage Introduction
/// | Getting Started                                                                                                                                                                                            | API Reference                                                                                                                                                                                              | Demo                                                                                                                                                                                                                         |
/// | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
/// | [![](stopwatch.svg)](page_getting_started.html)                                                                                                                                                            | [![](api.svg)](page_api_reference.html)                                                                                                                                                                    | [![](demo.svg)](/Frontend/demo)                                                                                                                                                                                              |
/// | <div style="max-width:200px">New to the codebase? Check out the \ref page_getting_started guides. Set up a development environment and learn about the frontends architecture and it's key concepts.</div> | <div style="max-width:200px">The \ref page_api_reference contains a detailed description of the inner workings of the frontends individual modules. It assumes an understanding of the key concepts.</div> | <div style="max-width:200px">For those who want to see what they're getting into first. Of course, the [Demo](/Frontend/demo) doesn't let you control a real OpenRemise board, but at least you get a feel for the UI.</div> |
///
/// <div class="section_buttons">
/// | Next                      |
/// | ------------------------: |
/// | \ref page_getting_started |
/// </div>

/// \page page_getting_started Getting Started
/// \details
/// The aim of this section is to help you set up a development environment and
/// provide you with a 30.000ft overview of the frontend and some of it's key
/// concepts.
///
/// After we have successfully set up a development environment and compiled the
/// frontend we will look at the system architecture.
///
/// | Chapter                     | Content                         |
/// | --------------------------- | ------------------------------- |
/// | \subpage page_development   | Setup a development environment |
/// | \subpage page_configuration | Environmental variables         |
/// | \subpage page_architecture  | System architecture             |
///
/// <div class="section_buttons">
/// | Previous   | Next                  |
/// | :--------- | --------------------: |
/// | \ref index | \ref page_development |
/// </div>

/// \page page_development Development
/// \details \tableofcontents
/// In this chapter, we set up a development environment that allows us to
/// create the frontend, its unit tests, and the documentation. This means that
/// we will primarily install the [Flutter](https://flutter.dev) framework via
/// [FVM](https://fvm.app), as well as a few tools around it.
///
/// We recommend either an [Arch](https://archlinux.org) (e.g.
/// [Garuda](https://garudalinux.org) or [Manjaro](https://manjaro.org)) or
/// [Ubuntu](https://ubuntu.com) based distribution, so all of the following
/// steps refer to those.
///
/// \section section_development_prerequisites Prerequisites
/// In order to start developing the frontend, we need to meet quite a few
/// prerequisites. Fortunately, most of them can be obtained directly from the
/// package manager. But before we do that, let's bring our system up to date.
/// <div class="tabbed">
/// - <b class="tab-title">Arch</b>
///   ```sh
///   sudo pacman -Syu --noconfirm
///   ```
/// - <b class="tab-title">Ubuntu 24.04</b>
///   ```sh
///   sudo apt update -y
///   sudo apt upgrade -y
///   ```
/// </div>
///
/// Without going into detail about each individual dependency, the most
/// important ones are FVM, a [Flutter](https://flutter.dev) version management
/// tool, Chromium, a web browser, Clang, a host compiler, CMake, a build
/// system, Ninja, a build tool, Doxygen, a documentation generator, and
/// Graphviz, a graph visualization software.
///
/// - [FVM](https://fvm.app) ( >= 4.0.5 )
/// - [Chromium](https://www.chromium.org) ( >= 134.0.6998.35 )
/// - [Clang](https://clang.llvm.org) ( >= 16.0.6 )
/// - [CMake](https://cmake.org) ( >= 3.25 )
/// - [Ninja](https://ninja-build.org) ( >= 1.10.2 )
/// - Optional
///   - for building documentation
///     - [Doxygen](https://www.doxygen.nl/index.html) ( >= 1.14.0 )
///     - [Graphviz](https://graphviz.org) ( >= 12.1.1 )
///
/// <div class="tabbed">
/// - <b class="tab-title">Arch</b>
///   ```sh
///   sudo pacman -S --noconfirm chromium clang cmake doxygen git graphviz jdk-openjdk make ninja
///   ```
/// - <b class="tab-title">Ubuntu 24.04</b>
///   ```sh
///   sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa
///   sudo apt-get install -y chromium-browser clang cmake git ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev
///   ```
/// </div>
///
/// \subsection subsection_development_fvm FVM (Flutter)
/// Instead of installing Flutter directly, we use FVM, a Flutter version
/// management tool. On Arch it is included in the official package manager, on
/// Ubuntu we have to run the install script from the FVM homepage. The problem
/// is that we need a very specific Flutter version, namely **3.27.4**. This is
/// the last version that supports the HTML renderer, which as of now simply
/// produces a much smaller app than the newer canvaskit.
///
/// At the time of writing (06.03.2025), the **gzipped app size** is
/// - 3.8MB with canvaskit
/// - 1.1MB with HTML
///
/// Unless this changes drastically, the Flutter version **must not be
/// updated**. However, Google promises improvement, the progress is tracked in
/// an open issue on [GitHub](https://github.com/OpenRemise/Frontend/issues/23).
///
/// \warning
/// Packages from the package manager or AUR are **not** intended to be locked
/// to a specific version. In case the installation from AUR no longer works,
/// please fall back on the manual installation.
///
/// <div class="tabbed">
/// - <b class="tab-title">Arch</b>
///   ```sh
///   sudo pacman -S --noconfirm fvm
///   ```
/// - <b class="tab-title">Ubuntu 24.04</b>
///   ```sh
///   curl -fsSL https://fvm.app/install.sh | bash
///   ```
/// </div>
///
/// \subsection subsection_development_vscode VSCode (optional)
///
/// We generally recommend [VSCode](https://code.visualstudio.com) for
/// development. It has a great Dart/Flutter extension called
/// [dartcode](https://dartcode.org) which also provides excellent debug and
/// testing support. Of course you are welcome to use any other IDE.
/// <div class="tabbed">
/// - <b class="tab-title">Arch</b>
///   ```sh
///   sudo pamac install visual-studio-code-bin
///   ```
/// - <b class="tab-title">Ubuntu 24.04</b>
///   ```sh
///   snap install code --classic
///   ```
/// </div>
///
/// \section section_development_clone Clone
/// The frontend source code is hosted on GitHub. We can use either SSH or HTTP
/// to  clone the [repository](https://github.com/OpenRemise/Frontend). Using
/// `git clone` without any additional arguments will clone the latest version
/// of the master branch to the current working directory. After that, we can
/// change into the `Frontend` directory we've just created.
/// <div class="tabbed">
/// - <b class="tab-title">SSH</b>
///   ```sh
///   git clone git@github.com:OpenRemise/Frontend.git
///   cd Frontend
///   ```
/// - <b class="tab-title">HTTPS</b>
///   ```sh
///   git clone https://github.com/OpenRemise/Frontend.git
///   cd Frontend
///   ```
/// </div>
///
/// \section section_development_build Build
/// Normally, Flutter apps can be built directly from the command line, e.g.
/// ```sh
/// flutter build linux
/// ```
///
/// However, since we want to integrate the build into the
/// [Firmware](https://github.com/OpenRemise/Firmware), it will be wrapped in
/// CMake. This allows us to use a `Frontend` target directly on the one hand,
/// and on the other hand to have a `FrontendRelease` target that generates
/// ready-made .zip archives for releases.
/// ```sh
/// cmake --preset "Release"
/// cmake --build build --target FrontendRelease
/// ```
///
/// \note
/// What CMake also does is deleting a bunch of unnecessary files, since the
/// Flutter team unfortunately [hasn't managed to clean up the builder folder](https://github.com/flutter/flutter/issues/96509)
/// properly yet...
///
/// \section section_development_debug Debug
/// With Flutter, we have to differentiate on which platform we want to debug.
///
/// \subsection subsection_develop_debug_native Native
/// The easiest to debug are definitely native builds, as they provide us with a
/// debugger with a start and stop function. The VSCode integration via
/// [dartcode](https://dartcode.org) is phenomenal and a simple click on debug
/// configuration is (usually) enough to start a session.
///
/// These configurations can be found under `.vscode/launch.json` and look
/// something like this.
/// ```json
/// {
///   "name": "Frontend (debug mode) OPENREMISE_FRONTEND_DOMAIN=remise.local OPENREMISE_FRONTEND_SMALL_SCREEN_WIDTH=800",
///   "request": "launch",
///   "type": "dart",
///   "flutterMode": "debug",
///   "args": [
///     "--dart-define",
///     "OPENREMISE_FRONTEND_DOMAIN=remise.local",
///     "--dart-define",
///     "OPENREMISE_FRONTEND_SMALL_SCREEN_WIDTH=800"
///   ]
/// }
/// ```
///
/// \warning
/// If Flutter is complaining about `Target of URI hasn't been generated` you'll
/// probably need to run the build runner with
/// ```sh
/// dart run build_runner build --delete-conflicting-outputs
/// ```
///
/// \subsection subsection_develop_debug_web Web
/// No matter how good the native debuggers are, from time to time you need to
/// debug directly in the browser. Flutter allows us to start directly in
/// Chromium with the following call. There is no start or stop function, but
/// the browser developer tools prove useful.
/// <div class="tabbed">
/// - <b class="tab-title">Fish</b>
///    ```sh
///    . chromium.fish
///    flutter run -d chrome --dart-define=OPENREMISE_FRONTEND_DOMAIN=remise.local --dart-define=OPENREMISE_FRONTEND_SMALL_SCREEN_WIDTH=800
///    ```
/// - <b class="tab-title">Bash</b>
///    ```sh
///    . chromium.sh
///    flutter run -d chrome --dart-define=OPENREMISE_FRONTEND_DOMAIN=remise.local --dart-define=OPENREMISE_FRONTEND_SMALL_SCREEN_WIDTH=800
///    ```
/// </div>
///
/// \section section_development_test Test
/// Flutter as a modern framework integrates unit tests very tightly. All that
/// is necessary to run the tests is a one-liner.
/// ```sh
/// flutter test
/// ```
///
/// \section section_development_doc Doc
/// If the optional prerequisites for building the docs were found during
/// CMake's configuration phase, the `FrontendDocs` target can be built to
/// create the documentation.
/// ```sh
/// cmake --build build --target FrontendDocs
/// ```
///
/// If the build was successful, the website can be viewed simply with a browser
/// by opening "build/docs/html/index.html" or by creating a small web server.
/// ```sh
/// python -m http.server --directory build/docs/html --bind 127.0.0.1
/// ```
///
/// \note
/// Doxygen isn't actually designed for documenting Dart code. When parsing
/// [metadata](https://dart.dev/language/metadata) or [generics](https://dart.dev/language/generics),
/// strange compound names are generated, making it impossible to link classes
/// later. For this reason, the [FILTER_PATTERNS](https://www.doxygen.nl/manual/config.html#cfg_filter_patterns)
/// option is used to remove generics before parsing using a [bash script](https://github.com/OpenRemise/Frontend/raw/master/docs/strip_dart_annotations_and_generics_filter.sh.sh).
///
/// <div class="section_buttons">
/// | Previous                  | Next                    |
/// | :------------------------ | ----------------------: |
/// | \ref page_getting_started | \ref page_configuration |
/// </div>

/// \page page_configuration Configuration
/// As already seen in \ref page_development, compilation is done with CMake for
/// easier integration into the [Firmware](https://openremise.at/Firmware). The
/// CMake file contains some options that define constant environment variables
/// in the build via `--dart-define`. These options can, for example, specify
/// the root path of the app or replace the real services with fake ones.
///
/// | Option                                 | Description                                            | Default      |
/// | -------------------------------------- | ------------------------------------------------------ | ------------ |
/// | OPENREMISE_FRONTEND_BASE_HREF          | href attribute of the `<base>` tag in `web/index.html` | /./          |
/// | OPENREMISE_FRONTEND_DOMAIN             | Default domain for non-kIsWeb builds                   | remise.local |
/// | OPENREMISE_FRONTEND_SMALL_SCREEN_WIDTH | Width under which a small screen is assumed            | 800          |
/// | OPENREMISE_FRONTEND_FAKE_SERVICES      | Fake services (for e.g. demo)                          | false        |
///
/// <div class="section_buttons">
/// | Previous              | Next                   |
/// | :-------------------- | ---------------------: |
/// | \ref page_development | \ref page_architecture |
/// </div>

/// \page page_architecture Architecture
/// \details \tableofcontents
/// The entire software stack revolves around services. All communication
/// happens over [HTTP](https://en.wikipedia.org/wiki/HTTP) or
/// [WebSockets](https://en.wikipedia.org/wiki/WebSocket) because it is the only
/// thing that browsers support. All services are packaged into
/// developer-friendly objects via providers, which take care of asynchronous
/// requests, possible caching and error handling. The display and manipulation
/// of the data is then the responsibility of the screens, which in turn use
/// recurring widgets.
///
/// \startuml "Architecture overview"
/// !theme mono
/// skinparam defaultFontName "Glacial Indifference"
///
/// frame "Services" {
/// }
///
/// database "Providers" {
/// }
///
/// frame "Screens" {
/// }
///
/// frame "Widgets" {
/// }
///
/// Services -r-> Providers
/// Providers -d-> Screens
/// Providers -d-> Widgets
/// Screens -r-> Widgets
///
/// 'Links
/// url of Services is [[page_architecture.html#section_architecture_services]]
/// url of Providers is [[page_architecture.html#section_architecture_providers]]
/// url of Screens is [[page_architecture.html#section_architecture_screens]]
/// url of Widgets is [[page_architecture.html#section_architecture_widgets]]
/// \enduml
///
/// \section section_architecture_services Services
/// Services come in the two categories HTTP or WebSockets.
///
/// \subsection subsection_architecture_http HTTP
/// HTTP is used where classic requests make sense and no bidirectional
/// communication is necessary. This applies, for example, to the API for adding
/// or deleting locomotives, changing device settings or querying the current
/// system status. The following endpoints are defined for HTTP.
/// - /dcc/locos/
///   - GET
///   - PUT
///   - DELETE
/// - /dcc/turnouts/
///   - GET
///   - PUT
///   - DELETE
/// - /dcc/
///   - GET
///   - POST
/// - /settings/
///   - GET
///   - POST
/// - /sys/
///   - GET
/// - /*
///   - GET
///
/// \subsection subsection_architecture_ws WebSockets
/// WebSockets are used where fast bidirectional data communication is
/// necessary. This primarily affects all the different APIs for firmware and
/// sound updates, e.g. [DECUP](https://github.com/ZIMO-Elektronik/DECUP) or
/// [ZUSI](https://github.com/ZIMO-Elektronik/ZUSI), but also the
/// [Z21](https://github.com/ZIMO-Elektronik/Z21) endpoint. The following
/// endpoints are defined for WebSockets.
/// - /ota/
/// - /roco/z21/
/// - /zimo/decup/zpp/
/// - /zimo/decup/zsu/
/// - /zimo/mdu/zpp/
/// - /zimo/mdu/zsu/
/// - /zimo/zusi/
///
/// \section section_architecture_providers Providers
/// The frontend uses [Riverpod](https://riverpod.dev) providers as a state
/// management solution. Different types of providers (e.g. `NotifierProvider`
/// or `FutureProvider`) encapsulate the services and allow reacting to state
/// changes through their reactive API. The created providers are injected into
/// the user code by inheriting from special so-called `ConsumerWidgets`.
///
/// For a detailed description of each provider see \ref page_provider.
///
/// \section section_architecture_screens Screens
/// Screens are... well, screens. A screen is essentially a display-filling
/// widget. The only difference to a "smaller" widget is that there is only ever
/// one instance of a screen and when you switch from one screen to another, the
/// entire display usually changes. It is also helpful to distinguish screens
/// from widgets in order to find a clear vocabulary. It is much easier to
/// explain a list of tiles on the decoder screen to someone than a list of
/// widgets on a widget (although that is essentially what it is).
///
/// For a detailed description of each screen see \ref page_screen.
///
/// \section section_architecture_widgets Widgets
/// Widgets are user-defined GUI elements that combine Flutter’s own classes. A
/// classic example of such a widget are the dialogs shown during firmware and
/// sound updates or the locomotive controller.
///
/// For a detailed description of each widget see \ref page_widget.
///
/// <div class="section_buttons">
/// | Previous                | Next                    |
/// | :---------------------- | ----------------------: |
/// | \ref page_configuration | \ref page_api_reference |
/// </div>

/// \page page_api_reference API Reference
/// The project layout follows a typical type-first structure.
///
/// | Chapter                | Content                                                                                            |
/// | ---------------------- | -------------------------------------------------------------------------------------------------- |
/// | \subpage page_screen   | Responsive layout with selectable screens                                                          |
/// | \subpage page_widget   | More complex widgets such as controllers or dialogs                                                |
/// | \subpage page_service  | HTTP, WebSocket and fake services                                                                  |
/// | \subpage page_provider | State management through [Riverpod](https://riverpod.dev/) providers                               |
/// | \subpage page_model    | [freezed](https://pub.dev/packages/freezed) models for settings, file formats, HTTP requests, etc. |
/// | \subpage page_constant | Constants used throughout the app                                                                  |
/// | \subpage page_utility  | Checksums, validators, etc.                                                                        |
///
/// <div class="section_buttons">
/// | Previous               | Next             |
/// | :--------------------- | ---------------: |
/// | \ref page_architecture | \ref page_screen |
/// </div>

/// \page page_utility Utilities
/// \tableofcontents
/// \todo document utilities
///
/// <div class="section_buttons">
/// | Previous           |
/// | :----------------- |
/// | \ref page_constant |
/// </div>

/// \page page_model Models
/// \tableofcontents
/// \todo document models
///
/// <div class="section_buttons">
/// | Previous           | Next               |
/// | :----------------- | -----------------: |
/// | \ref page_provider | \ref page_constant |
/// </div>

/// \page page_widget Widgets
/// \tableofcontents
/// Widgets are currently divided into three categories depending on their
/// intended use.
/// - General widgets are used wherever
/// - Dialog widgets are displayed by the [showDialog](https://api.flutter.dev/flutter/material/showDialog.html)
///   function
/// - Controller widgets make up the complex locomotive and accessory
///   controllers
///
/// \section section_widgets_general General Widgets
/// General widgets can be used generally and have no predefined use cases. They
/// are often just small wrappers over existing classes or helper widgets that,
/// in turn, accept a child.
///
/// \subsection subsection_widgets_default_animated_size Default Animated Size
/// \copydetails DefaultAnimateSize
///
/// \subsection subsection_widgets_error_gif Error GIF
/// \copydetails ErrorGif
///
/// \subsection subsection_widgets_loading_gif Loading GIF
/// \copydetails LoadingGif
///
/// \subsection subsection_widgets_persistent_expansion_tile Persistent Expansion Tile
/// \copydetails PersistentExpansionTile
///
/// \subsection subsection_widgets_png_picture PNG Picture
/// \copydetails PngPicture
///
/// \subsection subsection_widgets_positioned_draggable Positioned Draggable
/// \copydetails PositionedDraggable
///
/// \subsection subsection_widgets_power_icon_button PowerIcon Button
/// \copydetails PowerIconButton
///
/// \section section_widgets_dialog Dialog Widgets
/// Dialog widgets are, as the name suggests, either [SimpleDialog](https://api.flutter.dev/flutter/material/SimpleDialog-class.html)
/// or [AlertDialog](https://api.flutter.dev/flutter/material/AlertDialog-class.html)
/// widgets. All dialogs must be launched using the [showDialog](https://api.flutter.dev/flutter/material/showDialog.html)
/// function. A common use case for dialogs are various updates, such as
/// \ref OtaDialog "OTA updates".
///
/// \subsection subsection_widgets_add_edit AddEdit
/// \copydetails AddEditDialog
///
/// \subsection subsection_widgets_confirmation Confirmation
/// \copydetails ConfirmationDialog
///
/// \subsection subsection_widgets_delete Delete
/// \copydetails DeleteDialog
///
/// \subsection subsection_widgets_download Download
/// \copydetails DownloadDialog
///
/// \subsection subsection_widgets_ota Ota
/// \copydetails OtaDialog
///
/// \subsection subsection_widgets_short_circuit ShortCircuit
/// \copydetails ShortCircuitDialog
///
/// \subsection subsection_widgets_zimo ZIMO
///
/// \subsubsection subsubsection_widgets_zimo_decup Decup
/// \copydetails DecupDialog
///
/// \subsubsection subsubsection_widgets_zimo_mdu Mdu
/// \copydetails MduDialog
///
/// \subsubsection subsubsection_widgets_zimo_sound Sound
/// \copydetails SoundDialog
///
/// \subsubsection subsubsection_widgets_zimo_zusi Zusi
/// \copydetails ZusiDialog
///
/// \section section_widgets_controller %Controller Widgets
/// Controller widgets are a collection of widgets that make up the complex
/// throttle or signal box.
///
/// \subsection subsection_widgets_controller Controller
/// \copydetails Controller
///
/// \subsubsection subsubsection_widgets_cv_editing_controller CV Editing Controller
/// \copydetails CvEditingController
///
/// \subsubsection subsubsection_widgets_cv_terminal CV Terminal
/// \copydetails CvTerminal
///
/// \subsubsection subsubsection_widgets_key_press_notifier Key Press Notifier
/// \copydetails KeyPressNotifier
///
/// \subsubsection subsubsection_widgets_keypad Keypad
/// \copydetails Keypad
///
/// \subsubsection subsubsection_widgets_railcom RailCom
/// \copydetails RailCom
///
/// <div class="section_buttons">
/// | Previous         | Next              |
/// | :--------------- | ----------------: |
/// | \ref page_screen | \ref page_service |
/// </div>

/// \page page_provider Providers
/// \tableofcontents
/// \todo document providers
///
/// <div class="section_buttons">
/// | Previous          | Next            |
/// | :---------------- | --------------: |
/// | \ref page_service | \ref page_model |
/// </div>

/// \page page_screen Screens
/// \tableofcontents
/// The entire app is divided into 5 screens, created in a responsive layout.
/// Depending on the screen width, all screens can be accessed either via a
/// [NavigationBar](https://api.flutter.dev/flutter/material/NavigationBar-class.html)
/// or -[rail](https://api.flutter.dev/flutter/material/NavigationRail-class.html).
/// The screen width at which switching between the two widgets takes place is
/// set in the variable \ref smallScreenWidth, which in turn is set by the
/// environment variable `OPENREMISE_FRONTEND_SMALL_SCREEN_WIDTH` during build.
///
/// \section section_screen_info Info
/// \copydetails InfoScreen
///
/// \section section_screen_decoders Decoders
/// \copydetails DecodersScreen
///
/// \section section_screen_program Program
/// \copydetails ProgramScreen
///
/// \section section_screen_update Update
/// \copydetails UpdateScreen
///
/// \section section_screen_settings Settings
/// \copydetails SettingsScreen
///
/// <div class="section_buttons">
/// | Previous                | Next             |
/// | :---------------------- | ---------------: |
/// | \ref page_api_reference | \ref page_widget |
/// </div>

/// \page page_constant Constants
/// \tableofcontents
/// The app uses a lot of constants which are listed here in no particular
/// order.
///
/// \section section_constant_controller_size Controller Size
/// \copydetails controllerSize
///
/// \section section_constant_fake_cvs Fake CVs
/// \subsection subsection_constant_fake_service_cvs Fake Service CVs
/// \copydetails fakeServiceCvs
///
/// \subsection subsection_constant_fake_loco_cvs Fake Loco CVs
/// \copydetails fakeLocoCvs
///
/// \subsection subsection_constant_fake_accessory_cvs Fake Accessory CVs
/// \copydetails fakeAccessoryCvs
///
/// \section section_constant_fake_services_provider_container Fake Services Provider Container
/// \copydetails fakeServicesProviderContainer
///
/// \section section_constant_icon_size Icon Size
/// \copydetails iconSize
///
/// \section section_constant_key_codes Key Codes
/// \copydetails KeyCodes
///
/// \section section_constant_open_remise_icons OpenRemise Icons
/// \copydetails OpenRemiseIcons
///
/// \section section_constant_small_screen_width Small Screen Width
/// \copydetails smallScreenWidth
///
/// \section section_constant_turnout_map Turnout Map
/// \copydetails turnoutMap
///
/// \section section_constant_ws_batch_size WebSocket Batch Size
/// \copydetails wsBatchSize
///
/// <div class="section_buttons">
/// | Previous        | Next              |
/// | :-------------- | ----------------: |
/// | \ref page_model | \ref page_utility |
/// </div>

/// \page page_service Services
/// \tableofcontents
/// \todo document services
///
/// <div class="section_buttons">
/// | Previous         | Next               |
/// | :--------------- | -----------------: |
/// | \ref page_widget | \ref page_provider |
/// </div>
