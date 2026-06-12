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
/// The entire software stack is divided into three layers. At the top sits the
/// UI layer, which takes care of the graphical representation of the data for
/// the user. In the middle is a domain layer that prepares the data for the UI
/// and converts user input back into data. And underneath that the data layer
/// handles IO, e.g. get or set data over services.
///
/// This architecture is also referred to as [Model-View-ViewModel architectural pattern](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93viewmodel)
/// (MVVM) and recommended by the official [Flutter guide to app architecture](https://docs.flutter.dev/app-architecture/guide).
///
/// A more detailed version of the upcoming diagram can be found at the
/// [bottom of the page](#section_architecture_diagram)(\emoji :warning: not mobile friendly).
///
/// \startuml "Architecture overview"
/// !theme mono
/// skinparam defaultFontName "Glacial Indifference"
///
/// frame "UI" as ui {
/// }
///
/// frame "Domain" as domain {
/// }
///
/// frame "Data" as data {
/// }
///
/// ui <-d-> domain
/// domain <-d-> data
/// \enduml
///
/// \section section_architecture_ui UI
/// The UI layer is responsible for representing data from the domain (or data)
/// layer and interacting with the user. In MVVM language it's made up of two
/// architectural components, views and view models. Views describe how to
/// present data to the user, view models contain logic that converts data into
/// UI state. Depending on the complexity of the state, simpler views might skip
/// the additional indirection and display data directly.
///
/// \section section_architecture_domain Domain
/// The optional domain layer is intended for models that need to mediate
/// between the UI and data layers. In these cases, the logic for converting
/// between external data and UI state is too complex to be handled by the view
/// model.
///
/// \section section_architecture_data Data
/// The data layer handles data from external sources. Services are responsible
/// for acquiring the data, repositories then manage it. Managing means handling
/// things like caching, error handling, or retry logic. Examples of services
/// include [HTTP](https://en.wikipedia.org/wiki/HTTP) requests or [WebSockets](https://en.wikipedia.org/wiki/WebSocket).
///
/// \section section_architecture_project_structure Project structure
/// There are two popular means of organizing code:
/// - By feature - classes needed for each feature are grouped together
/// - By type - types of classes are grouped together
///
/// The structure used here is a combination of the two. Domain and data layer
/// objects (repositories and services) aren't tied to a single feature, while
/// UI layer objects (views and view models) are.
///
/// \htmlonly
/// <details>
///   <summary>lib/</summary>
///   <ul>
///     <details>
///       <summary>config/</summary>
///     </details>
///     <details>
///       <summary>data/</summary>
///       <ul>
///         <details>
///           <summary>models/</summary>
///         </details>
///         <details>
///           <summary>repositories/</summary>
///         </details>
///         <details>
///           <summary>services/</summary>
///         </details>
///       </ul>
///     </details>
///     <details>
///       <summary>domain/</summary>
///       <ul>
///         <details>
///           <summary>models/</summary>
///         </details>
///       </ul>
///     </details>
///     <details>
///       <summary>ui/</summary>
///       <ul>
///         <details>
///           <summary>core/</summary>
///         </details>
///         <details>
///           <summary>&lt;feature&gt;/</summary>
///         </details>
///       </ul>
///     </details>
///     <details>
///       <summary>utils/</summary>
///     </details>
///   </ul>
/// </details>
/// \endhtmlonly
///
/// \section section_architecture_diagram Diagram
/// \startuml "Architecture diagram"
/// !theme mono
/// skinparam defaultFontName "Glacial Indifference"
///
/// frame "UI layer" as ui {
///   package "View" as ui_view {
///   }
///   package "View model" as ui_view_model {
///   }
///   ui_view -[hidden]right-> ui_view_model
/// }
///
/// frame "Domain layer" as domain {
///   package "Models" as domain_models {
///   }
/// }
///
/// frame "Data layer" as data {
///   package "Repositories" as data_repositories {
///   }
///   package "Services" as data_services {
///   }
///   package "Models" as data_models {
///   }
/// }
///
/// ui <-d-> domain
/// domain <-d-> data
/// \enduml
///
/// <div class="section_buttons">
/// | Previous                | Next                    |
/// | :---------------------- | ----------------------: |
/// | \ref page_configuration | \ref page_api_reference |
/// </div>

/// \page page_api_reference API Reference
/// The project layout follows a typical type-first structure.
///
/// | Chapter              | Content                                     |
/// | -------------------- | ------------------------------------------- |
/// | \subpage page_ui     | Responsive layout with selectable screens   |
/// | \subpage page_domain | Models to convert between data and UI state |
/// | \subpage page_data   | HTTP and WebSocket services                 |
/// | \subpage page_utils  | Checksums, validators, etc.                 |
///
/// <div class="section_buttons">
/// | Previous               | Next         |
/// | :--------------------- | -----------: |
/// | \ref page_architecture | \ref page_ui |
/// </div>
