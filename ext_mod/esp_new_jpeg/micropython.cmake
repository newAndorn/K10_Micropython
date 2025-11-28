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
# Try multiple possible locations for the managed component
set(ESP_NEW_JPEG_INCLUDE_DIRS "")
if(EXISTS "${CMAKE_BINARY_DIR}/managed_components/espressif__esp_new_jpeg/include")
    list(APPEND ESP_NEW_JPEG_INCLUDE_DIRS "${CMAKE_BINARY_DIR}/managed_components/espressif__esp_new_jpeg/include")
elseif(EXISTS "${CMAKE_SOURCE_DIR}/managed_components/espressif__esp_new_jpeg/include")
    list(APPEND ESP_NEW_JPEG_INCLUDE_DIRS "${CMAKE_SOURCE_DIR}/managed_components/espressif__esp_new_jpeg/include")
elseif(EXISTS "${CMAKE_BINARY_DIR}/managed_components/esp_new_jpeg/include")
    list(APPEND ESP_NEW_JPEG_INCLUDE_DIRS "${CMAKE_BINARY_DIR}/managed_components/esp_new_jpeg/include")
elseif(EXISTS "${CMAKE_SOURCE_DIR}/managed_components/esp_new_jpeg/include")
    list(APPEND ESP_NEW_JPEG_INCLUDE_DIRS "${CMAKE_SOURCE_DIR}/managed_components/esp_new_jpeg/include")
endif()

if(ESP_NEW_JPEG_INCLUDE_DIRS)
    target_include_directories(usermod_esp_new_jpeg INTERFACE ${ESP_NEW_JPEG_INCLUDE_DIRS})
endif()

# Try to link to the component target if it exists (for transitive dependencies)
if(TARGET esp_new_jpeg)
    target_link_libraries(usermod_esp_new_jpeg INTERFACE esp_new_jpeg)
elseif(TARGET __idf_esp_new_jpeg)
    target_link_libraries(usermod_esp_new_jpeg INTERFACE __idf_esp_new_jpeg)
endif()

target_compile_definitions(usermod_esp_new_jpeg INTERFACE)

# Link our INTERFACE library to the usermod target.
target_link_libraries(usermod INTERFACE usermod_esp_new_jpeg)

