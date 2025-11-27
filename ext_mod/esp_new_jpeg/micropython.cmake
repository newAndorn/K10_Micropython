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

target_compile_definitions(usermod_esp_new_jpeg INTERFACE)

# Link our INTERFACE library to the usermod target.
target_link_libraries(usermod INTERFACE usermod_esp_new_jpeg)

# The esp_new_jpeg component will be automatically included via idf_component.yml

