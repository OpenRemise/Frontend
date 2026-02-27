cmake_minimum_required(VERSION 3.25 FATAL_ERROR)
include(FetchContent)

FetchContent_Declare(
  CMakeModules
  GIT_REPOSITORY "https://github.com/ZIMO-Elektronik/CMakeModules"
  GIT_TAG v0.12.2)
FetchContent_MakeAvailable(CMakeModules)

set(OPENREMISE_FRONTEND_BASE_HREF
    "/./"
    CACHE STRING "href attribute of the <base> tag in web/index.html")
set(OPENREMISE_FRONTEND_DOMAIN
    remise.local
    CACHE STRING "Default domain for non-kIsWeb builds")
set(OPENREMISE_FRONTEND_SMALL_SCREEN_WIDTH
    800
    CACHE STRING "Width under which a small screen is assumed")
set(OPENREMISE_FRONTEND_FAKE_SERVICES
    false
    CACHE STRING "Fake services (for e.g. demo)")

version_from_git()
project(Frontend VERSION ${VERSION_FROM_GIT})

find_program(FVM_EXECUTABLE fvm)
if(FVM_EXECUTABLE)
  set(DART_EXECUTABLE fvm dart)
  set(FLUTTER_EXECUTABLE fvm flutter)
else()
  find_program(DART_EXECUTABLE dart REQUIRED)
  find_program(FLUTTER_EXECUTABLE flutter REQUIRED)
endif()

# Get flutter version
execute_process(COMMAND ${FLUTTER_EXECUTABLE} --version
                OUTPUT_VARIABLE FLUTTER_VERSION_RAW)
string(REGEX MATCH "[0-9]+\\.[0-9]+\\.[0-9]+" FLUTTER_VERSION
             ${FLUTTER_VERSION_RAW})

# Get all source files
file(GLOB_RECURSE LIB lib/*.dart)

if(FLUTTER_VERSION VERSION_LESS_EQUAL "3.27.4")
  # For some reason only dart can run the build_runner
  add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/web
    COMMAND ${FLUTTER_EXECUTABLE} pub get
    COMMAND ${DART_EXECUTABLE} run build_runner build
            --delete-conflicting-outputs
    COMMAND
      ${FLUTTER_EXECUTABLE} build web #
      --output=${CMAKE_CURRENT_BINARY_DIR}/web #
      --base-href=${OPENREMISE_FRONTEND_BASE_HREF} #
      --web-renderer=html #
      --no-web-resources-cdn #
      --optimization-level=4 #
      --dart-define=OPENREMISE_FRONTEND_DOMAIN=${OPENREMISE_FRONTEND_DOMAIN} #
      --dart-define=OPENREMISE_FRONTEND_SMALL_SCREEN_WIDTH=${OPENREMISE_FRONTEND_SMALL_SCREEN_WIDTH} #
      --dart-define=OPENREMISE_FRONTEND_FAKE_SERVICES=${OPENREMISE_FRONTEND_FAKE_SERVICES} #
    # https://github.com/flutter/flutter/issues/126738
    COMMAND
      ${CMAKE_COMMAND} -E rm -rf #
      ${CMAKE_CURRENT_BINARY_DIR}/web/assets/NOTICES #
      ${CMAKE_CURRENT_BINARY_DIR}/web/canvaskit #
    DEPENDS ${LIB} #
    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR})
else()
  # For some reason only dart can run the build_runner
  add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/web
    COMMAND ${FLUTTER_EXECUTABLE} pub upgrade --major-versions
    COMMAND ${DART_EXECUTABLE} run build_runner build
            --delete-conflicting-outputs
    COMMAND
      ${FLUTTER_EXECUTABLE} build web #
      --output=${CMAKE_CURRENT_BINARY_DIR}/web #
      --base-href=${OPENREMISE_FRONTEND_BASE_HREF} #
      --no-web-resources-cdn #
      --dart-define=OPENREMISE_FRONTEND_DOMAIN=${OPENREMISE_FRONTEND_DOMAIN} #
      --dart-define=OPENREMISE_FRONTEND_SMALL_SCREEN_WIDTH=${OPENREMISE_FRONTEND_SMALL_SCREEN_WIDTH} #
      --dart-define=OPENREMISE_FRONTEND_FAKE_SERVICES=${OPENREMISE_FRONTEND_FAKE_SERVICES} #
    # https://github.com/flutter/flutter/issues/126738
    COMMAND
      ${CMAKE_COMMAND} -E rm -rf #
      ${CMAKE_CURRENT_BINARY_DIR}/web/assets/NOTICES #
      ${CMAKE_CURRENT_BINARY_DIR}/web/canvaskit/chromium #
      ${CMAKE_CURRENT_BINARY_DIR}/web/canvaskit/skwasm.js #
      ${CMAKE_CURRENT_BINARY_DIR}/web/canvaskit/skwasm.js.symbols #
      ${CMAKE_CURRENT_BINARY_DIR}/web/canvaskit/skwasm.wasm #
      ${CMAKE_CURRENT_BINARY_DIR}/web/canvaskit/skwasm_heavy.js #
      ${CMAKE_CURRENT_BINARY_DIR}/web/canvaskit/skwasm_heavy.js.symbols #
      ${CMAKE_CURRENT_BINARY_DIR}/web/canvaskit/skwasm_heavy.wasm #
    DEPENDS ${LIB} #
    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR})
endif()

# Build web
add_custom_target(Frontend ALL DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/web)

# Create Frontend-${PROJECT_VERSION}.zip
if(CMAKE_BUILD_TYPE STREQUAL Release)
  add_custom_target(
    FrontendRelease
    COMMAND ${CMAKE_COMMAND} -E tar "cf" ${PROJECT_NAME}-${PROJECT_VERSION}.zip
            --format=zip *
    COMMAND
      ${CMAKE_COMMAND} -E rename
      ${CMAKE_CURRENT_BINARY_DIR}/web/${PROJECT_NAME}-${PROJECT_VERSION}.zip
      ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}-${PROJECT_VERSION}.zip
    DEPENDS Frontend
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/web)
endif()

if(PROJECT_IS_TOP_LEVEL)
  include(CTest)
endif()

if(BUILD_TESTING
   AND PROJECT_IS_TOP_LEVEL
   AND CMAKE_SYSTEM_NAME STREQUAL CMAKE_HOST_SYSTEM_NAME)
  add_subdirectory(docs)
endif()
