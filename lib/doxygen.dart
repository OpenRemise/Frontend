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
/// | Chapter                    | Content                         |
/// | -------------------------- | ------------------------------- |
/// | \subpage page_development  | Setup a development environment |
/// | \subpage page_architecture | System architecture             |
///
/// <div class="section_buttons">
/// | Previous   | Next                   |
/// | :--------- | ---------------------: |
/// | \ref index | \ref page_development |
/// </div>

/// \page page_development Development
/// In this chapter, we set up a development environment that allows us to
/// create the frontend, its unit tests, and the documentation.
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
/// important ones are Flutter, a cross-platform app framework, Clang, a host
/// compiler, CMake, a build system, Ninja, a build tool, Doxygen, a
/// documentation generator, and Graphviz, a graph visualization software.
///
/// - [Flutter](https://flutter.dev) ( == 3.27.4 )
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
///   sudo pacman -S --noconfirm clang cmake doxygen git graphviz jdk-openjdk make ninja
///   ```
/// - <b class="tab-title">Ubuntu 24.04</b>
///   ```sh
///   sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa
///   sudo apt-get install -y clang cmake git ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev
///   ```
/// </div>
///
/// \subsection subsection_development_flutter Flutter
///
/// https://docs.flutter.dev/release/archive
///
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
///   bla
/// </div>
///
/// <div class="section_buttons">
/// | Previous                  | Next                   |
/// | :------------------------ | ---------------------: |
/// | \ref page_getting_started | \ref page_architecture |
/// </div>

/// \page page_architecture Architecture
/// HO
///
/// <div class="section_buttons">
/// | Previous              | Next                    |
/// | :-------------------- | ----------------------: |
/// | \ref page_development | \ref page_api_reference |
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
