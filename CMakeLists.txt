cmake_minimum_required(VERSION 3.25 FATAL_ERROR)
include(FetchContent)

FetchContent_Declare(
  CMakeModules
  GIT_REPOSITORY "https://github.com/ZIMO-Elektronik/CMakeModules"
  GIT_TAG v0.9.3)
FetchContent_MakeAvailable(CMakeModules)

option(OPENREMISE_FRONTEND_BUILD_DOCS "Build documentation" ON)
set(OPENREMISE_FRONTEND_BASE_HREF
    "/./"
    CACHE STRING
          "Overrides the href attribute of the <base> tag in web/index.html")
set(OPENREMISE_FRONTEND_DOMAIN
    remise.local
    CACHE STRING "Default domain for non-kIsWeb builds")
set(OPENREMISE_FRONTEND_FAKE_SERVICES
    false
    CACHE STRING "Fake services (for e.g. demo)")
set(OPENREMISE_FRONTEND_SMALL_SCREEN_WIDTH
    800
    CACHE STRING "Width from which a small device is assumed")
set(OPENREMISE_FRONTEND_WEB_RENDERER
    html
    CACHE STRING "The renderer implementation to use when building for the web")

version_from_git()
project(Frontend VERSION ${VERSION_FROM_GIT})

# For some reason only dart can run the build_runner
find_program(DART_EXECUTABLE dart PATHS /usr/bin/ REQUIRED)
find_program(FLUTTER_EXECUTABLE flutter PATHS /usr/bin/ REQUIRED)
add_custom_command(
  OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/web
  COMMAND ${FLUTTER_EXECUTABLE} pub get
  COMMAND ${DART_EXECUTABLE} run build_runner build --delete-conflicting-outputs
  COMMAND
    ${FLUTTER_EXECUTABLE} build web #
    --output=${CMAKE_CURRENT_BINARY_DIR}/web #
    --base-href=${OPENREMISE_FRONTEND_BASE_HREF} #
    --web-renderer=${OPENREMISE_FRONTEND_WEB_RENDERER} #
    --dart-define=OPENREMISE_FRONTEND_DOMAIN=${OPENREMISE_FRONTEND_DOMAIN} #
    --dart-define=OPENREMISE_FRONTEND_FAKE_SERVICES=${OPENREMISE_FRONTEND_FAKE_SERVICES} #
    --dart-define=OPENREMISE_FRONTEND_SMALL_SCREEN_WIDTH=${OPENREMISE_FRONTEND_SMALL_SCREEN_WIDTH} #
    --dart-define=OPENREMISE_FRONTEND_VERSION=${PROJECT_VERSION} #
  # https://github.com/flutter/flutter/issues/126738
  COMMAND
    ${CMAKE_COMMAND} -E rm -rf #
    ${CMAKE_CURRENT_BINARY_DIR}/web/assets/NOTICES #
    ${CMAKE_CURRENT_BINARY_DIR}/web/canvaskit #
  WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR})

add_custom_target(Frontend ALL DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/web)

if(OPENREMISE_FRONTEND_BUILD_DOCS)
  add_subdirectory(docs)
endif()
