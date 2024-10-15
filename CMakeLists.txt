cmake_minimum_required(VERSION 3.25 FATAL_ERROR)
include(FetchContent)

FetchContent_Declare(
  CMakeModules
  GIT_REPOSITORY "https://github.com/ZIMO-Elektronik/CMakeModules"
  GIT_TAG v0.9.2)
FetchContent_MakeAvailable(CMakeModules)

version_from_git()
project(
  Frontend
  VERSION ${VERSION_FROM_GIT}
  LANGUAGES CXX)

# For some reason only dart can run the build_runner
find_program(DART_EXECUTABLE dart PATHS /usr/bin/ REQUIRED)
find_program(FLUTTER_EXECUTABLE flutter PATHS /usr/bin/ REQUIRED)
add_custom_command(
  OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/build/web
  COMMAND ${FLUTTER_EXECUTABLE} pub get
  COMMAND ${DART_EXECUTABLE} run build_runner build --delete-conflicting-outputs
  COMMAND
    ${FLUTTER_EXECUTABLE} build web --web-renderer=html
    --dart-define=VERSION=${VERSION_FROM_GIT}
    --dart-define=SMALL_SCREEN_WIDTH=800
    --output-dir=${CMAKE_CURRENT_BINARY_DIR}/build/web
  # https://github.com/flutter/flutter/issues/126738
  COMMAND
    ${CMAKE_COMMAND} -E rm -rf
    ${CMAKE_CURRENT_BINARY_DIR}/build/web/assets/NOTICES
    ${CMAKE_CURRENT_BINARY_DIR}/build/web/canvaskit
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  COMMENT "Building Frontend for web")

add_custom_target(Frontend DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/build/web)
