#ifndef DVI_IN_H
#define DVI_IN_H

#include <stddef.h>
#include <stdint.h>

typedef struct pipeline_debug {
  unsigned int valid;
  unsigned int delay;
  unsigned int quality;
  unsigned int last_valid;
  unsigned int last_invalid;
} pipeline_debug_t;

typedef struct pipeline_debug_ctrl {
  unsigned int ovr;
  unsigned int delay;
  unsigned int bitslip;
  unsigned int delay_increment;
} pipeline_debug_ctrl_t;

typedef struct debug_pixel {
  uint32_t red;
  uint32_t green;
  uint32_t blue;
} pixel_t;

typedef struct channel_deskew_debug {
  unsigned int valid;
  unsigned int offset_r;
  unsigned int offset_g;
  unsigned int offset_b;
  unsigned int de;
  unsigned int error_count;
} channel_deskew_debug_t;

typedef struct channel_deskew_debug_ctrl {
  unsigned int ovr;
  unsigned int offset_r;
  unsigned int offset_g;
  unsigned int offset_b;
} channel_deskew_debug_ctrl_t;

typedef struct pixel_counter_debug {
  unsigned int cx;
  unsigned int cy;
  unsigned int is_video_data;
  unsigned int is_hdmi;
  unsigned int guessed_polarity;
} pixel_counter_debug_t;

typedef struct pixel_counter_debug_ctrl {
  unsigned int ovr;
  unsigned int is_hdmi;
  unsigned int hsync_polarity;
  unsigned int vsync_polarity;
} pixel_counter_debug_ctrl_t;

typedef struct framebuffers_status {
  unsigned int valid_frames;
  unsigned int width;
  unsigned int height;
  unsigned int format;
} framebuffers_status_t;

typedef struct framebuffers_control {
  unsigned int lock;
  unsigned int skip_column;
  unsigned int skip_row;
  unsigned int double_colordepth;
  unsigned int high_res;
} framebuffers_control_t;

typedef struct clock_status {
  unsigned int locked;
  unsigned int sys_clk_counter;
  unsigned int pclk_counter;
} clock_status_t;

void dvi_get_pipeline_debug(pipeline_debug_t d[3]);
void dvi_get_pipeline_debug_pixel(pixel_t* d);
void dvi_get_channel_deskew_debug(channel_deskew_debug_t* d);
void dvi_get_debug_pixel(pixel_t* d);
void dvi_get_framebuffers_status(framebuffers_status_t* d);
void dvi_get_clock_status(clock_status_t* d);
void dvi_get_pixel_counter_debug(pixel_counter_debug_t* d);

void dvi_set_pipeline_debug_ctrl(pipeline_debug_ctrl_t c[3]);
void dvi_set_channel_deskew_debug_ctrl(channel_deskew_debug_ctrl_t* c);
void dvi_set_pixel_counter_debug_ctrl(pixel_counter_debug_ctrl_t* c);
unsigned int dvi_set_framebuffers_control(framebuffers_control_t* c);
void dvi_set_reset(unsigned int rst);
void dvi_get_pipeline_debug_ctrl(pipeline_debug_ctrl_t c[3]);
void dvi_get_channel_deskew_debug_ctrl(channel_deskew_debug_ctrl_t* c);
void dvi_get_pixel_counter_debug_ctrl(pixel_counter_debug_ctrl_t* c);
void dvi_get_framebuffers_control(framebuffers_control_t* c);
unsigned int dvi_get_reset(void);

int dvi_write_edid(const char* edid, size_t size);
char* dvi_get_edid();

uint8_t* dvi_get_framebuffer(unsigned int index);
pixel_t dvi_get_framebuffer_pixel(const framebuffers_status_t* status, int index, unsigned int x, unsigned int y);

unsigned int dvi_framebuffer_auto_lock();
void dvi_framebuffer_lock(unsigned int i);
void dvi_framebuffer_unlock(unsigned int i);
void dvi_framebuffer_wait_valid(unsigned int i);
void dvi_framebuffer_wait_invalid(unsigned int i);

#endif
