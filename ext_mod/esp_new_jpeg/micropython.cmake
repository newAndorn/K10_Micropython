# Create an INTERFACE library for our C module.
add_library(usermod_esp_new_jpeg INTERFACE)

# Add our source files to the lib
target_sources(usermod_esp_new_jpeg INTERFACE
    ${CMAKE_CURRENT_LIST_DIR}/modjpeg.c
)

# Add the current directory as an include directory.
target_include_directories(usermod_esp_new_jpeg INTERFACE
    ${CMAKE_CURRENT_LIST_DIR}
)

# Add include directories for the esp_new_jpeg managed component
# The component is managed via idf_component.yml and installed in managed_components
# Managed components use double underscores in directory names (espressif/esp_new_jpeg -> espressif__esp_new_jpeg)
# The component manager downloads components to the build directory's managed_components folder
set(ESP_NEW_JPEG_INCLUDE_DIRS "")

# Search for the managed component in common locations
# Note: The component manager downloads to ${CMAKE_BINARY_DIR}/managed_components during CMake configure
set(SEARCH_PATHS
    "${CMAKE_BINARY_DIR}/managed_components/espressif__esp_new_jpeg/include"
    "${CMAKE_SOURCE_DIR}/managed_components/espressif__esp_new_jpeg/include"
    "${CMAKE_BINARY_DIR}/managed_components/esp_new_jpeg/include"
    "${CMAKE_SOURCE_DIR}/managed_components/esp_new_jpeg/include"
)

foreach(SEARCH_PATH ${SEARCH_PATHS})
    if(EXISTS "${SEARCH_PATH}")
        list(APPEND ESP_NEW_JPEG_INCLUDE_DIRS "${SEARCH_PATH}")
        message(STATUS "Found esp_new_jpeg include directory: ${SEARCH_PATH}")
        break()
    endif()
endforeach()

if(ESP_NEW_JPEG_INCLUDE_DIRS)
    target_include_directories(usermod_esp_new_jpeg INTERFACE ${ESP_NEW_JPEG_INCLUDE_DIRS})
else()
    message(WARNING "Could not find esp_new_jpeg include directory. The component may not be downloaded yet. Run 'idf.py reconfigure' to download managed components.")
endif()

# Try to link to the component target if it exists (for transitive dependencies)
# This will be available after the component manager processes the dependencies
if(TARGET esp_new_jpeg)
    target_link_libraries(usermod_esp_new_jpeg INTERFACE esp_new_jpeg)
elseif(TARGET __idf_esp_new_jpeg)
    target_link_libraries(usermod_esp_new_jpeg INTERFACE __idf_esp_new_jpeg)
endif()

target_compile_definitions(usermod_esp_new_jpeg INTERFACE)

# Link our INTERFACE library to the usermod target.
target_link_libraries(usermod INTERFACE usermod_esp_new_jpeg)

