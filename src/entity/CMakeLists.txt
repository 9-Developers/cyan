include(GenerateExportHeader)

set(ENTITY_SOURCES
    entity.cc
)

add_library(cyan_entity STATIC ${ENTITY_SOURCES})
add_library(cyan::cyan_entity ALIAS cyan_entity)

target_link_libraries(cyan_entity PRIVATE cyan_options cyan_warnings)

target_include_directories(
  cyan_entity
  ${WARNING_GUARD}
  PUBLIC
  $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
  $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/include>
)

target_compile_features(cyan_entity PUBLIC cxx_std_23)

set_target_properties(
  cyan_entity
  PROPERTIES VERSION ${PROJECT_VERSION}
             CXX_VISIBILITY_PRESET hidden
             VISIBILITY_INLINES_HIDDEN YES)

generate_export_header(
  cyan_entity
  EXPORT_FILE_NAME
  ${PROJECT_BINARY_DIR}/include/cyan/entity.h
)

if(NOT BUILD_SHARED_LIBS)
  target_compile_definitions(cyan_entity PUBLIC CYAN_ENTITY_STATIC_DEFINE)
endif()
