cmake_minimum_required(VERSION 3.25 FATAL_ERROR)
include(FetchContent)

if(ESP_PLATFORM)
  idf_component_register(REQUIRES spiffs)
endif()

FetchContent_Declare(
  CMakeModules
  GIT_REPOSITORY https://github.com/ZIMO-Elektronik/CMakeModules
  GIT_TAG v0.8.0)
FetchContent_MakeAvailable(CMakeModules)

version_from_git()
project(
  Frontend
  VERSION ${VERSION_FROM_GIT}
  LANGUAGES CXX)

set(PARTITION
    storage
    CACHE STRING "")

# For some reason only dart can run the build_runner
find_program(DART_EXECUTABLE dart REQUIRED)
find_program(FLUTTER_EXECUTABLE flutter PATHS /usr/bin/flutter REQUIRED)
add_custom_command(
  OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/build/web
  COMMAND ${FLUTTER_EXECUTABLE} pub get
  COMMAND ${DART_EXECUTABLE} run build_runner build --delete-conflicting-outputs
  COMMAND
    ${FLUTTER_EXECUTABLE} build web --web-renderer=html
    --dart-define=VERSION=${VERSION_FROM_GIT} --dart-define=WIDTH=640
    --output-dir=${CMAKE_CURRENT_BINARY_DIR}/build/web
  # https://github.com/flutter/flutter/issues/126738
  COMMAND
    ${CMAKE_COMMAND} -E rm -rf
    ${CMAKE_CURRENT_BINARY_DIR}/build/web/assets/NOTICES
    ${CMAKE_CURRENT_BINARY_DIR}/build/web/canvaskit
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  COMMENT "Building Frontend for web")

add_custom_target(Frontend DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/build/web)

if(ESP_PLATFORM)
  spiffs_create_partition_image(
    ${PARTITION} ${CMAKE_CURRENT_BINARY_DIR}/build/web FLASH_IN_PROJECT DEPENDS
    Frontend)
endif()
