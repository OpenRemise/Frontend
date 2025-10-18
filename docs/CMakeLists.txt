# Get Doxygen
cpmaddpackage(
  NAME
  Doxygen
  URL
  "https://github.com/doxygen/doxygen/releases/download/Release_1_14_0/doxygen-1.14.0.linux.bin.tar.gz"
  VERSION
  1.14.0
  DOWNLOAD_ONLY
  ON)
set(DOXYGEN_EXECUTABLE ${Doxygen_SOURCE_DIR}/bin/doxygen)
find_package(Doxygen QUIET COMPONENTS dot)

if(TARGET Doxygen::dot)
  # Get PlantUML
  cpmaddpackage(
    NAME
    PlantUML
    URL
    "https://github.com/plantuml/plantuml/releases/download/v1.2025.1/plantuml-1.2025.1.jar"
    VERSION
    1.2025.1
    DOWNLOAD_ONLY
    ON
    DOWNLOAD_NO_EXTRACT
    ON)
  set(PLANTUML_JAR_PATH ${PlantUML_SOURCE_DIR}/plantuml-1.2025.1.jar)

  # Get Doxygen Awesome
  cpmaddpackage("gh:jothepro/doxygen-awesome-css@2.4.1")

  # Get logo and fonts
  file(DOWNLOAD
       "https://github.com/OpenRemise/.github/raw/master/data/icons/favicon.ico"
       ${CMAKE_CURRENT_BINARY_DIR}/html/favicon.ico)
  file(DOWNLOAD
       "https://github.com/OpenRemise/.github/raw/master/data/images/logo.svg"
       ${CMAKE_CURRENT_BINARY_DIR}/html/logo.svg)
  file(
    DOWNLOAD
    "https://github.com/OpenRemise/.github/raw/master/data/fonts/GlacialIndifference-Bold.otf"
    ${CMAKE_CURRENT_BINARY_DIR}/html/GlacialIndifference-Bold.otf)
  file(
    DOWNLOAD
    "https://github.com/OpenRemise/.github/raw/master/data/fonts/GlacialIndifference-Regular.otf"
    ${CMAKE_CURRENT_BINARY_DIR}/html/GlacialIndifference-Regular.otf)

  set(DOXYGEN_PROJECT_LOGO ${CMAKE_CURRENT_BINARY_DIR}/html/logo.svg)
  set(DOXYGEN_PROJECT_ICON ${CMAKE_CURRENT_BINARY_DIR}/html/favicon.ico)
  set(DOXYGEN_REPEAT_BRIEF NO)
  set(DOXYGEN_MULTILINE_CPP_IS_BRIEF YES)
  set(DOXYGEN_EXTENSION_MAPPING dart=JavaScript)
  set(DOXYGEN_BUILTIN_STL_SUPPORT YES)
  set(DOXYGEN_NUM_PROC_THREADS 0)
  set(DOXYGEN_EXTRACT_ALL YES)
  set(DOXYGEN_EXTRACT_PRIVATE YES)
  set(DOXYGEN_EXTRACT_STATIC YES)
  set(DOXYGEN_EXTRACT_LOCAL_CLASSES YES)
  set(DOXYGEN_EXTRACT_LOCAL_METHODS YES)
  set(DOXYGEN_EXTRACT_ANON_NSPACES YES)
  set(DOXYGEN_LAYOUT_FILE ${CMAKE_CURRENT_LIST_DIR}/DoxygenLayout.xml)
  set(DOXYGEN_FILE_PATTERNS *.dart)
  set(DOXYGEN_EXCLUDE_PATTERNS */*.freezed.dart */*.g.dart)
  set(DOXYGEN_EXCLUDE_SYMBOLS _$*)
  set(DOXYGEN_IMAGE_PATH ${CMAKE_CURRENT_LIST_DIR})
  set(DOXYGEN_FILTER_PATTERNS
      *.dart=${CMAKE_CURRENT_LIST_DIR}/strip_dart_metadata_and_generics_filter.sh
  )
  set(DOXYGEN_HTML_HEADER ${CMAKE_CURRENT_LIST_DIR}/header.html)
  set(DOXYGEN_HTML_FOOTER ${CMAKE_CURRENT_LIST_DIR}/footer.html)
  set(DOXYGEN_HTML_EXTRA_STYLESHEET
      ${doxygen-awesome-css_SOURCE_DIR}/doxygen-awesome.css
      ${doxygen-awesome-css_SOURCE_DIR}/doxygen-awesome-sidebar-only.css
      ${CMAKE_CURRENT_LIST_DIR}/custom.css)
  set(DOXYGEN_HTML_EXTRA_FILES
      ${doxygen-awesome-css_SOURCE_DIR}/doxygen-awesome-fragment-copy-button.js
      ${doxygen-awesome-css_SOURCE_DIR}/doxygen-awesome-interactive-toc.js
      ${doxygen-awesome-css_SOURCE_DIR}/doxygen-awesome-paragraph-link.js
      ${doxygen-awesome-css_SOURCE_DIR}/doxygen-awesome-tabs.js)
  set(DOXYGEN_HTML_COLORSTYLE LIGHT)
  set(DOXYGEN_HTML_COLORSTYLE_HUE 209)
  set(DOXYGEN_HTML_COLORSTYLE_SAT 255)
  set(DOXYGEN_HTML_COLORSTYLE_GAMMA 113)
  set(DOXYGEN_HTML_COPY_CLIPBOARD NO)
  set(DOXYGEN_GENERATE_TREEVIEW YES)
  set(DOXYGEN_PAGE_OUTLINE_PANEL NO)
  set(DOXYGEN_MACRO_EXPANSION YES)
  set(DOXYGEN_EXPAND_ONLY_PREDEF YES)
  set(DOXYGEN_UML_LOOK YES)
  set(DOXYGEN_DOT_IMAGE_FORMAT svg)
  set(DOXYGEN_PLANTUML_JAR_PATH ${PLANTUML_JAR_PATH})

  doxygen_add_docs(${PROJECT_NAME}Docs ${CMAKE_SOURCE_DIR}/lib
                   ${CMAKE_SOURCE_DIR}/CHANGELOG.md)

  # Only build demo for Release
  if(CMAKE_BUILD_TYPE STREQUAL Release)
    add_dependencies(FrontendDocs Frontend)
    add_custom_command(
      TARGET ${PROJECT_NAME}Docs
      POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_BINARY_DIR}/web
              ${CMAKE_CURRENT_BINARY_DIR}/html/demo)
  endif()
endif()
