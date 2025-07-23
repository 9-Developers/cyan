include(cmake/SystemLink.cmake)
include(cmake/LibFuzzer.cmake)
include(CMakeDependentOption)
include(CheckCXXCompilerFlag)


include(CheckCXXSourceCompiles)


macro(cyan_supports_sanitizers)
  if((CMAKE_CXX_COMPILER_ID MATCHES ".*Clang.*" OR CMAKE_CXX_COMPILER_ID MATCHES ".*GNU.*") AND NOT WIN32)

    message(STATUS "Sanity checking UndefinedBehaviorSanitizer, it should be supported on this platform")
    set(TEST_PROGRAM "int main() { return 0; }")

    # Check if UndefinedBehaviorSanitizer works at link time
    set(CMAKE_REQUIRED_FLAGS "-fsanitize=undefined")
    set(CMAKE_REQUIRED_LINK_OPTIONS "-fsanitize=undefined")
    check_cxx_source_compiles("${TEST_PROGRAM}" HAS_UBSAN_LINK_SUPPORT)

    if(HAS_UBSAN_LINK_SUPPORT)
      message(STATUS "UndefinedBehaviorSanitizer is supported at both compile and link time.")
      set(SUPPORTS_UBSAN ON)
    else()
      message(WARNING "UndefinedBehaviorSanitizer is NOT supported at link time.")
      set(SUPPORTS_UBSAN OFF)
    endif()
  else()
    set(SUPPORTS_UBSAN OFF)
  endif()

  if((CMAKE_CXX_COMPILER_ID MATCHES ".*Clang.*" OR CMAKE_CXX_COMPILER_ID MATCHES ".*GNU.*") AND WIN32)
    set(SUPPORTS_ASAN OFF)
  else()
    if (NOT WIN32)
      message(STATUS "Sanity checking AddressSanitizer, it should be supported on this platform")
      set(TEST_PROGRAM "int main() { return 0; }")

      # Check if AddressSanitizer works at link time
      set(CMAKE_REQUIRED_FLAGS "-fsanitize=address")
      set(CMAKE_REQUIRED_LINK_OPTIONS "-fsanitize=address")
      check_cxx_source_compiles("${TEST_PROGRAM}" HAS_ASAN_LINK_SUPPORT)

      if(HAS_ASAN_LINK_SUPPORT)
        message(STATUS "AddressSanitizer is supported at both compile and link time.")
        set(SUPPORTS_ASAN ON)
      else()
        message(WARNING "AddressSanitizer is NOT supported at link time.")
        set(SUPPORTS_ASAN OFF)
      endif()
    else()
      set(SUPPORTS_ASAN ON)
    endif()
  endif()
endmacro()

macro(cyan_setup_options)
  option(cyan_ENABLE_HARDENING "Enable hardening" ON)
  option(cyan_ENABLE_COVERAGE "Enable coverage reporting" OFF)
  cmake_dependent_option(
    cyan_ENABLE_GLOBAL_HARDENING
    "Attempt to push hardening options to built dependencies"
    ON
    cyan_ENABLE_HARDENING
    OFF)

  cyan_supports_sanitizers()

  if(NOT PROJECT_IS_TOP_LEVEL OR cyan_PACKAGING_MAINTAINER_MODE)
    option(cyan_ENABLE_IPO "Enable IPO/LTO" OFF)
    option(cyan_WARNINGS_AS_ERRORS "Treat Warnings As Errors" OFF)
    option(cyan_ENABLE_USER_LINKER "Enable user-selected linker" OFF)
    option(cyan_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" OFF)
    option(cyan_ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)
    option(cyan_ENABLE_SANITIZER_UNDEFINED "Enable undefined sanitizer" OFF)
    option(cyan_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
    option(cyan_ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
    option(cyan_ENABLE_UNITY_BUILD "Enable unity builds" OFF)
    option(cyan_ENABLE_CLANG_TIDY "Enable clang-tidy" OFF)
    option(cyan_ENABLE_CPPCHECK "Enable cpp-check analysis" OFF)
    option(cyan_ENABLE_PCH "Enable precompiled headers" OFF)
    option(cyan_ENABLE_CACHE "Enable ccache" OFF)
  else()
    option(cyan_ENABLE_IPO "Enable IPO/LTO" ON)
    option(cyan_WARNINGS_AS_ERRORS "Treat Warnings As Errors" ON)
    option(cyan_ENABLE_USER_LINKER "Enable user-selected linker" OFF)
    option(cyan_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" ${SUPPORTS_ASAN})
    option(cyan_ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)
    option(cyan_ENABLE_SANITIZER_UNDEFINED "Enable undefined sanitizer" ${SUPPORTS_UBSAN})
    option(cyan_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
    option(cyan_ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
    option(cyan_ENABLE_UNITY_BUILD "Enable unity builds" OFF)
    option(cyan_ENABLE_CLANG_TIDY "Enable clang-tidy" ON)
    option(cyan_ENABLE_CPPCHECK "Enable cpp-check analysis" ON)
    option(cyan_ENABLE_PCH "Enable precompiled headers" OFF)
    option(cyan_ENABLE_CACHE "Enable ccache" ON)
  endif()

  if(NOT PROJECT_IS_TOP_LEVEL)
    mark_as_advanced(
      cyan_ENABLE_IPO
      cyan_WARNINGS_AS_ERRORS
      cyan_ENABLE_USER_LINKER
      cyan_ENABLE_SANITIZER_ADDRESS
      cyan_ENABLE_SANITIZER_LEAK
      cyan_ENABLE_SANITIZER_UNDEFINED
      cyan_ENABLE_SANITIZER_THREAD
      cyan_ENABLE_SANITIZER_MEMORY
      cyan_ENABLE_UNITY_BUILD
      cyan_ENABLE_CLANG_TIDY
      cyan_ENABLE_CPPCHECK
      cyan_ENABLE_COVERAGE
      cyan_ENABLE_PCH
      cyan_ENABLE_CACHE)
  endif()

  cyan_check_libfuzzer_support(LIBFUZZER_SUPPORTED)
  if(LIBFUZZER_SUPPORTED AND (cyan_ENABLE_SANITIZER_ADDRESS OR cyan_ENABLE_SANITIZER_THREAD OR cyan_ENABLE_SANITIZER_UNDEFINED))
    set(DEFAULT_FUZZER ON)
  else()
    set(DEFAULT_FUZZER OFF)
  endif()

  option(cyan_BUILD_FUZZ_TESTS "Enable fuzz testing executable" ${DEFAULT_FUZZER})

endmacro()

macro(cyan_global_options)
  if(cyan_ENABLE_IPO)
    include(cmake/InterproceduralOptimization.cmake)
    cyan_enable_ipo()
  endif()

  cyan_supports_sanitizers()

  if(cyan_ENABLE_HARDENING AND cyan_ENABLE_GLOBAL_HARDENING)
    include(cmake/Hardening.cmake)
    if(NOT SUPPORTS_UBSAN 
       OR cyan_ENABLE_SANITIZER_UNDEFINED
       OR cyan_ENABLE_SANITIZER_ADDRESS
       OR cyan_ENABLE_SANITIZER_THREAD
       OR cyan_ENABLE_SANITIZER_LEAK)
      set(ENABLE_UBSAN_MINIMAL_RUNTIME FALSE)
    else()
      set(ENABLE_UBSAN_MINIMAL_RUNTIME TRUE)
    endif()
    message("${cyan_ENABLE_HARDENING} ${ENABLE_UBSAN_MINIMAL_RUNTIME} ${cyan_ENABLE_SANITIZER_UNDEFINED}")
    cyan_enable_hardening(cyan_options ON ${ENABLE_UBSAN_MINIMAL_RUNTIME})
  endif()
endmacro()

macro(cyan_local_options)
  if(PROJECT_IS_TOP_LEVEL)
    include(cmake/StandardProjectSettings.cmake)
  endif()

  add_library(cyan_warnings INTERFACE)
  add_library(cyan_options INTERFACE)

  include(cmake/CompilerWarnings.cmake)
  cyan_set_project_warnings(
    cyan_warnings
    ${cyan_WARNINGS_AS_ERRORS}
    ""
    ""
    ""
    "")

  if(cyan_ENABLE_USER_LINKER)
    include(cmake/Linker.cmake)
    cyan_configure_linker(cyan_options)
  endif()

  include(cmake/Sanitizers.cmake)
  cyan_enable_sanitizers(
    cyan_options
    ${cyan_ENABLE_SANITIZER_ADDRESS}
    ${cyan_ENABLE_SANITIZER_LEAK}
    ${cyan_ENABLE_SANITIZER_UNDEFINED}
    ${cyan_ENABLE_SANITIZER_THREAD}
    ${cyan_ENABLE_SANITIZER_MEMORY})

  set_target_properties(cyan_options PROPERTIES UNITY_BUILD ${cyan_ENABLE_UNITY_BUILD})

  if(cyan_ENABLE_PCH)
    target_precompile_headers(
      cyan_options
      INTERFACE
      <vector>
      <string>
      <utility>)
  endif()

  if(cyan_ENABLE_CACHE)
    include(cmake/Cache.cmake)
    cyan_enable_cache()
  endif()

  include(cmake/StaticAnalyzers.cmake)
  if(cyan_ENABLE_CLANG_TIDY)
    cyan_enable_clang_tidy(cyan_options ${cyan_WARNINGS_AS_ERRORS})
  endif()

  if(cyan_ENABLE_CPPCHECK)
    cyan_enable_cppcheck(${cyan_WARNINGS_AS_ERRORS} "" # override cppcheck options
    )
  endif()

  if(cyan_ENABLE_COVERAGE)
    include(cmake/Tests.cmake)
    cyan_enable_coverage(cyan_options)
  endif()

  if(cyan_WARNINGS_AS_ERRORS)
    check_cxx_compiler_flag("-Wl,--fatal-warnings" LINKER_FATAL_WARNINGS)
    if(LINKER_FATAL_WARNINGS)
      # This is not working consistently, so disabling for now
      # target_link_options(cyan_options INTERFACE -Wl,--fatal-warnings)
    endif()
  endif()

  if(cyan_ENABLE_HARDENING AND NOT cyan_ENABLE_GLOBAL_HARDENING)
    include(cmake/Hardening.cmake)
    if(NOT SUPPORTS_UBSAN 
       OR cyan_ENABLE_SANITIZER_UNDEFINED
       OR cyan_ENABLE_SANITIZER_ADDRESS
       OR cyan_ENABLE_SANITIZER_THREAD
       OR cyan_ENABLE_SANITIZER_LEAK)
      set(ENABLE_UBSAN_MINIMAL_RUNTIME FALSE)
    else()
      set(ENABLE_UBSAN_MINIMAL_RUNTIME TRUE)
    endif()
    cyan_enable_hardening(cyan_options OFF ${ENABLE_UBSAN_MINIMAL_RUNTIME})
  endif()

endmacro()
