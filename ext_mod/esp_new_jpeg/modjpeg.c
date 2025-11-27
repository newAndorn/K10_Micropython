/*
 * MicroPython JPEG encoder module using esp_new_jpeg
 * Wraps esp_new_jpeg library for use in MicroPython
 */

#include <string.h>
#include "py/obj.h"
#include "py/runtime.h"
#include "py/binary.h"
#include "py/mperrno.h"
#include "modjpeg.h"

#include "esp_log.h"
#include "esp_heap_caps.h"
#include "esp_jpeg_enc.h"
#include "esp_jpeg_common.h"

#define STATIC static

STATIC mp_obj_t jpeg_encode_rgb565(mp_obj_t rgb565_buf, mp_obj_t width_obj, mp_obj_t height_obj, mp_obj_t quality_obj) {
    // Get buffer
    mp_buffer_info_t buf_info;
    mp_get_buffer_raise(rgb565_buf, &buf_info, MP_BUFFER_READ);
    
    // Get dimensions and quality
    int width = mp_obj_get_int(width_obj);
    int height = mp_obj_get_int(height_obj);
    int quality = mp_obj_get_int(quality_obj);
    
    if (quality < 1 || quality > 100) {
        mp_raise_ValueError(MP_ERROR_TEXT("quality must be between 1 and 100"));
    }
    
    // Validate buffer size
    size_t expected_size = width * height * 2; // RGB565 is 2 bytes per pixel
    if (buf_info.len < expected_size) {
        mp_raise_ValueError(MP_ERROR_TEXT("buffer too small"));
    }
    
    // Allocate aligned output buffer (recommended for ESP32-S3)
    // Estimate max JPEG size: typically 1/10 to 1/20 of original for good quality
    size_t out_size = (width * height * 2) / 5; // Conservative estimate
    if (out_size < 1024) {
        out_size = 1024; // Minimum buffer size
    }
    uint8_t *out_buf = (uint8_t *)heap_caps_aligned_alloc(16, out_size, MALLOC_CAP_SPIRAM | MALLOC_CAP_8BIT);
    if (out_buf == NULL) {
        out_buf = (uint8_t *)heap_caps_aligned_alloc(16, out_size, MALLOC_CAP_8BIT);
    }
    if (out_buf == NULL) {
        mp_raise_OSError(MP_ENOMEM);
    }
    
    // Configure encoder
    esp_jpeg_image_cfg_t img_cfg = {
        .width = width,
        .height = height,
        .format = JPEG_PIXEL_FORMAT_RGB565_BE, // Big endian RGB565
        .quality = quality,
        .sub_sample = JPEG_SUBSAMPLE_420,
    };
    
    esp_jpeg_enc_handle_t jpeg_enc = NULL;
    esp_err_t ret = esp_jpeg_enc_open(&img_cfg, &jpeg_enc);
    if (ret != ESP_OK) {
        heap_caps_free(out_buf);
        mp_raise_OSError(MP_EIO);
    }
    
    // Encode
    esp_jpeg_enc_header_t header;
    size_t out_len = out_size;
    
    ret = esp_jpeg_enc_process(jpeg_enc, (uint8_t *)buf_info.buf, out_buf, &out_len, &header);
    if (ret != ESP_OK) {
        esp_jpeg_enc_close(jpeg_enc);
        heap_caps_free(out_buf);
        mp_raise_OSError(MP_EIO);
    }
    
    // Close encoder
    esp_jpeg_enc_close(jpeg_enc);
    
    // Create bytes object with encoded JPEG data
    mp_obj_t result = mp_obj_new_bytes(out_buf, out_len);
    
    // Free output buffer
    heap_caps_free(out_buf);
    
    return result;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_4(jpeg_encode_rgb565_obj, jpeg_encode_rgb565);

STATIC const mp_rom_map_elem_t jpeg_module_globals_table[] = {
    { MP_ROM_QSTR(MP_QSTR___name__), MP_ROM_QSTR(MP_QSTR_jpeg) },
    { MP_ROM_QSTR(MP_QSTR_encode_rgb565), MP_ROM_PTR(&jpeg_encode_rgb565_obj) },
};

STATIC MP_DEFINE_CONST_DICT(jpeg_module_globals, jpeg_module_globals_table);

const mp_obj_module_t mp_module_jpeg = {
    .base = { &mp_type_module },
    .globals = (mp_obj_dict_t *)&jpeg_module_globals,
};

MP_REGISTER_MODULE(MP_QSTR_jpeg, mp_module_jpeg);

