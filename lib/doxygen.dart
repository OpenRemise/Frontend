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

///
///
/// \file   main.dart
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
/// | Getting Started                                                                                                                                                                                            | API Reference                                                                                                                                                                                              |
/// | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
/// | [![](stopwatch.svg)](page_getting_started.html)                                                                                                                                                            | [![](api.svg)](page_api_reference.html)                                                                                                                                                                    |
/// | <div style="max-width:200px">New to the codebase? Check out the \ref page_getting_started guides. Set up a development environment and learn about the frontends architecture and it's key concepts.</div> | <div style="max-width:200px">The \ref page_api_reference contains a detailed description of the inner workings of the frontends individual modules. It assumes an understanding of the key concepts.</div> |
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
/// we will primarily install the [Flutter](https://flutter.dev) framework, as
/// well as a few tools around it.
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
/// important ones are Flutter, a cross-platform app framework, Chromium, a web
/// browser, Clang, a host compiler, CMake, a build system, Ninja, a build tool,
/// Doxygen, a documentation generator, and Graphviz, a graph visualization
/// software.
///
/// - [Flutter](https://flutter.dev) ( == 3.27.4 )
/// - [Chromium](https://www.chromium.org) ( >= 134.0.6998.35 )
/// - [Clang](https://clang.llvm.org) ( >= 16.0.6 )
/// - [CMake](https://cmake.org) ( >= 3.25 )
/// - [Ninja](https://ninja-build.org) ( >= 1.10.2 )
/// - Optional
///   - for building documentation
///     - [Doxygen](https://www.doxygen.nl/index.html) ( >= 1.12.0 )
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
/// \subsection subsection_development_flutter Flutter
/// The Flutter framework is the only dependency that we cannot get directly
/// from the (official) package manager. It's either available from
/// [AUR](https://aur.archlinux.org) or from the
/// [flutter releases archive](https://docs.flutter.dev/release/archive). The
/// problem is that we need a very specific version, namely **3.27.4**. This is
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
///   git clone https://aur.archlinux.org/flutter-bin.git
///   cd flutter-bin
///   git checkout 9dd83f3012fb6b14f7a9453cdfbf2dd097053f79
///   makepkg -si
///   ```
/// - <b class="tab-title">Ubuntu 24.04</b>
///   - Manually download [Flutter 3.27.4](https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.27.4-stable.tar.xz)
///   - Follow the installation instructions at [docs.flutter.dev](https://docs.flutter.dev/get-started/install/linux/web#install-the-flutter-sdk)
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
///
/// ```sh
/// cmake --preset "Release"
/// cmake --build build --target FrontendRelease
/// ```
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
///   "name": "Frontend (debug mode) OPENREMISE_FRONTEND_SMALL_SCREEN_WIDTH=800",
///   "request": "launch",
///   "type": "dart",
///   "flutterMode": "debug",
///   "args": [
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
/// If Doxygen was found during CMake's configuration phase, the `FrontendDocs`
/// target can be built to create the documentation.
/// ```sh
/// cmake --build build --target FrontendDocs
/// ```
///
/// <div class="section_buttons">
/// | Previous                  | Next                    |
/// | :------------------------ | ----------------------: |
/// | \ref page_getting_started | \ref page_configuration |
/// </div>

/// \page page_configuration Configuration
/// \todo
/// Environmental variable stuff... invocations, fakes?
///
/// <div class="section_buttons">
/// | Previous              | Next                   |
/// | :-------------------- | ---------------------: |
/// | \ref page_development | \ref page_architecture |
/// </div>

/// \page page_architecture Architecture
/// \todo
/// Services, Providers, Riverpod, Widgets, Dialogs?
///
/// <div class="section_buttons">
/// | Previous                | Next                    |
/// | :---------------------- | ----------------------: |
/// | \ref page_configuration | \ref page_api_reference |
/// </div>

/// \page page_api_reference API Reference
/// \todo
/// Write API Reference page
///
/// | Chapter                 | Content                                        |
/// | ----------------------- | ---------------------------------------------- |
/// | \subpage page_constants | Analog                                         |
/// | \subpage page_models    | DCC                                            |
/// | \subpage page_providers | DECUP                                          |
/// | \subpage page_screens   | HTTP                                           |
/// | \subpage page_services  | MDU                                            |
/// | \subpage page_utilities | SPIFFS and NVS memory                          |
/// | \subpage page_widgets   | OTA                                            |
///
/// <div class="section_buttons">
/// | Previous               | Next                |
/// | :--------------------- | ------------------: |
/// | \ref page_architecture | \ref page_constants |
/// </div>
