# ESP_NEW_JPEG MicroPython Module

This module provides JPEG encoding functionality using the Espressif `esp_new_jpeg` component.

## Setup

The component is automatically included via `idf_component.yml`. After building the firmware, the `jpeg` module will be available in MicroPython.

## Usage

```python
import jpeg

# Encode RGB565 buffer to JPEG
rgb565_buffer = bytearray(240 * 320 * 2)  # Your RGB565 image data
jpeg_data = jpeg.encode_rgb565(rgb565_buffer, 240, 320, 60)  # width, height, quality (1-100)

# Save to file
with open("/capture.jpg", "wb") as f:
    f.write(jpeg_data)
```

## API Notes

The C module (`modjpeg.c`) uses the esp_new_jpeg API. If you encounter compilation errors, you may need to adjust the function names or structures to match the actual `esp_new_jpeg` component API. Check the component's header files for the exact API:

- `esp_jpeg_enc.h` - Encoder functions
- `esp_jpeg_common.h` - Common definitions

Common adjustments might include:
- Function names (e.g., `esp_jpeg_enc_open` vs `jpeg_enc_open`)
- Structure names (e.g., `esp_jpeg_image_cfg_t` vs `jpeg_image_cfg_t`)
- Pixel format constants (e.g., `JPEG_PIXEL_FORMAT_RGB565_BE` vs `JPEG_PIXEL_RGB565_BE`)

## Example in Screen Class

See `_k10_base.py` for the `capture_and_encode_jpeg()` method in the Screen class.

