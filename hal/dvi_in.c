#include "dvi_in.h"

#define REG_GET_FIELD(value, reg, field) \
  ((value >> DVI_IN_ ## reg ## _ ## field ## _LSB) & DVI_IN_ ## reg ## _ ## field ## _MASK)
#define REG_VALUE(reg, index) \
  (REG32(DVI_IN_ ## reg (index)))

#define REG_SET_FIELD(value, reg, field, v) \
  value = value | ((v & DVI_IN_ ## reg ## _ ## field ## _MASK) << DVI_IN_ ## reg ## _ ## field ## _LSB)

void dvi_get_pipeline_debug(pipeline_debug_t d[3]) {
  uint32_t r0 = REG_VALUE(REG_PIPELINE_DEBUG0, 0);
  uint32_t r1 = REG_VALUE(REG_PIPELINE_DEBUG1, 0);
  uint32_t r2 = REG_VALUE(REG_PIPELINE_DEBUG2, 0);

  uint32_t t0 = REG_VALUE(REG_TMDS_DEBUG0, 0);
  uint32_t t1 = REG_VALUE(REG_TMDS_DEBUG1, 0);
  uint32_t t2 = REG_VALUE(REG_TMDS_DEBUG2, 0);

  d[0].valid = REG_GET_FIELD(r0, REG_PIPELINE_DEBUG0, VALID0);
  d[0].delay = REG_GET_FIELD(r0, REG_PIPELINE_DEBUG0, DELAY0);
  d[0].quality = REG_GET_FIELD(r0, REG_PIPELINE_DEBUG0, QUALITY0);
  d[0].last_valid = REG_GET_FIELD(t0, REG_TMDS_DEBUG0, LAST_VALID0);
  d[0].last_invalid = REG_GET_FIELD(t0, REG_TMDS_DEBUG0, LAST_INVALID0);

  d[1].valid = REG_GET_FIELD(r1, REG_PIPELINE_DEBUG1, VALID1);
  d[1].delay = REG_GET_FIELD(r1, REG_PIPELINE_DEBUG1, DELAY1);
  d[1].quality = REG_GET_FIELD(r1, REG_PIPELINE_DEBUG1, QUALITY1);
  d[1].last_valid = REG_GET_FIELD(t1, REG_TMDS_DEBUG1, LAST_VALID1);
  d[1].last_invalid = REG_GET_FIELD(t1, REG_TMDS_DEBUG1, LAST_INVALID1);

  d[2].valid = REG_GET_FIELD(r2, REG_PIPELINE_DEBUG2, VALID2);
  d[2].delay = REG_GET_FIELD(r2, REG_PIPELINE_DEBUG2, DELAY2);
  d[2].quality = REG_GET_FIELD(r2, REG_PIPELINE_DEBUG2, QUALITY2);
  d[2].last_valid = REG_GET_FIELD(t2, REG_TMDS_DEBUG2, LAST_VALID2);
  d[2].last_invalid = REG_GET_FIELD(t2, REG_TMDS_DEBUG2, LAST_INVALID2);
}

void dvi_get_pipeline_debug_pixel(pixel_t* d) {
  uint32_t r = REG_VALUE(REG_PIPELINE_DEBUG_PIXEL, 0);

  d->red = REG_GET_FIELD(r, REG_PIPELINE_DEBUG_PIXEL, RED);
  d->green = REG_GET_FIELD(r, REG_PIPELINE_DEBUG_PIXEL, GREEN);
  d->blue = REG_GET_FIELD(r, REG_PIPELINE_DEBUG_PIXEL, BLUE);
}

void dvi_get_debug_pixel(pixel_t* d) {
  uint32_t r = REG_VALUE(REG_DEBUG_PIXEL, 0);

  d->red = REG_GET_FIELD(r, REG_DEBUG_PIXEL, RED);
  d->green = REG_GET_FIELD(r, REG_DEBUG_PIXEL, GREEN);
  d->blue = REG_GET_FIELD(r, REG_DEBUG_PIXEL, BLUE);
}

void dvi_get_channel_deskew_debug(channel_deskew_debug_t* d) {
  uint32_t r = REG_VALUE(REG_CHANNEL_DESKEW_DEBUG, 0);

  d->valid = REG_GET_FIELD(r, REG_CHANNEL_DESKEW_DEBUG, VALID);
  d->offset_r = REG_GET_FIELD(r, REG_CHANNEL_DESKEW_DEBUG, OFFSET_R);
  d->offset_g = REG_GET_FIELD(r, REG_CHANNEL_DESKEW_DEBUG, OFFSET_G);
  d->offset_b = REG_GET_FIELD(r, REG_CHANNEL_DESKEW_DEBUG, OFFSET_B);
  d->de = REG_GET_FIELD(r, REG_CHANNEL_DESKEW_DEBUG, DE);
  d->error_count = REG_GET_FIELD(r, REG_CHANNEL_DESKEW_DEBUG, ERROR_COUNT);
}

void dvi_get_framebuffers_status(framebuffers_status_t* d) {
  uint32_t r = REG_VALUE(REG_FRAMEBUFFERS_STATUS, 0);

  d->valid_frames = REG_GET_FIELD(r, REG_FRAMEBUFFERS_STATUS, VALID_FRAMES);
  d->width = REG_GET_FIELD(r, REG_FRAMEBUFFERS_STATUS, WIDTH);
  d->height = REG_GET_FIELD(r, REG_FRAMEBUFFERS_STATUS, HEIGHT);
  d->format = REG_GET_FIELD(r, REG_FRAMEBUFFERS_STATUS, FORMAT);
}

void dvi_get_pixel_counter_debug(pixel_counter_debug_t* d) {
  uint32_t r = REG_VALUE(REG_PIXEL_COUNTER_DEBUG, 0);

  d->cx = REG_GET_FIELD(r, REG_PIXEL_COUNTER_DEBUG, CX);
  d->cy = REG_GET_FIELD(r, REG_PIXEL_COUNTER_DEBUG, CY);
  d->is_video_data = REG_GET_FIELD(r, REG_PIXEL_COUNTER_DEBUG, IS_VIDEO_DATA);
  d->is_hdmi = REG_GET_FIELD(r, REG_PIXEL_COUNTER_DEBUG, IS_HDMI);
  d->guessed_polarity = REG_GET_FIELD(r, REG_PIXEL_COUNTER_DEBUG, GUESSED_POLARITY);
}

void dvi_get_clock_status(clock_status_t* d) {
  uint32_t r = REG_VALUE(REG_CLOCK_STATUS, 0);

  d->locked = REG_GET_FIELD(r, REG_CLOCK_STATUS, LOCKED);
  d->pclk_counter = REG_GET_FIELD(r, REG_CLOCK_STATUS, PCLK_COUNTER);
  d->sys_clk_counter = REG_GET_FIELD(r, REG_CLOCK_STATUS, SYS_CLK_COUNTER);
}

void dvi_set_pipeline_debug_ctrl(pipeline_debug_ctrl_t c[3]) {
  uint32_t r0 = 0;
  uint32_t r1 = 0;
  uint32_t r2 = 0;

  REG_SET_FIELD(r0, REG_PIPELINE_DEBUG_CTRL0, OVERRIDE0, c[0].ovr);
  REG_SET_FIELD(r0, REG_PIPELINE_DEBUG_CTRL0, DELAY0, c[0].delay);
  REG_SET_FIELD(r0, REG_PIPELINE_DEBUG_CTRL0, BITSLIP0, c[0].bitslip);
  REG_SET_FIELD(r0, REG_PIPELINE_DEBUG_CTRL0, DELAY_INCREMENT0, c[0].delay_increment);

  REG_SET_FIELD(r1, REG_PIPELINE_DEBUG_CTRL1, OVERRIDE1, c[1].ovr);
  REG_SET_FIELD(r1, REG_PIPELINE_DEBUG_CTRL1, DELAY1, c[1].delay);
  REG_SET_FIELD(r1, REG_PIPELINE_DEBUG_CTRL1, BITSLIP1, c[1].bitslip);
  REG_SET_FIELD(r1, REG_PIPELINE_DEBUG_CTRL1, DELAY_INCREMENT1, c[1].delay_increment);

  REG_SET_FIELD(r2, REG_PIPELINE_DEBUG_CTRL2, OVERRIDE2, c[2].ovr);
  REG_SET_FIELD(r2, REG_PIPELINE_DEBUG_CTRL2, DELAY2, c[2].delay);
  REG_SET_FIELD(r2, REG_PIPELINE_DEBUG_CTRL2, BITSLIP2, c[2].bitslip);
  REG_SET_FIELD(r2, REG_PIPELINE_DEBUG_CTRL2, DELAY_INCREMENT2, c[2].delay_increment);

  REG32(DVI_IN_REG_PIPELINE_DEBUG_CTRL0(0)) = r0;
  REG32(DVI_IN_REG_PIPELINE_DEBUG_CTRL1(0)) = r1;
  REG32(DVI_IN_REG_PIPELINE_DEBUG_CTRL2(0)) = r2;
}

void dvi_set_channel_deskew_debug_ctrl(channel_deskew_debug_ctrl_t* c) {
  uint32_t r = 0;

  REG_SET_FIELD(r, REG_CHANNEL_DESKEW_DEBUG_CTRL, OVERRIDE, c->ovr);
  REG_SET_FIELD(r, REG_CHANNEL_DESKEW_DEBUG_CTRL, OFFSET_R, c->offset_r);
  REG_SET_FIELD(r, REG_CHANNEL_DESKEW_DEBUG_CTRL, OFFSET_G, c->offset_g);
  REG_SET_FIELD(r, REG_CHANNEL_DESKEW_DEBUG_CTRL, OFFSET_B, c->offset_b);

  REG32(DVI_IN_REG_CHANNEL_DESKEW_DEBUG_CTRL(0)) = r;
}

void dvi_set_pixel_counter_debug_ctrl(pixel_counter_debug_ctrl_t* c) {
  uint32_t r = 0;

  REG_SET_FIELD(r, REG_PIXEL_COUNTER_DEBUG_CTRL, OVERRIDE, c->ovr);
  REG_SET_FIELD(r, REG_PIXEL_COUNTER_DEBUG_CTRL, IS_HDMI, c->is_hdmi);
  REG_SET_FIELD(r, REG_PIXEL_COUNTER_DEBUG_CTRL, HSYNC_POLARITY, c->hsync_polarity);
  REG_SET_FIELD(r, REG_PIXEL_COUNTER_DEBUG_CTRL, VSYNC_POLARITY, c->vsync_polarity);

  REG32(DVI_IN_REG_PIXEL_COUNTER_DEBUG_CTRL(0)) = r;
}

unsigned int dvi_set_framebuffers_control(framebuffers_control_t* c) {

  //catch invalid input (high_res && double_colordepth not allowed)
  if (c->double_colordepth && c->high_res) return 1;
  uint32_t r = 0;

  REG_SET_FIELD(r, REG_FRAMEBUFFERS_CONTROL, LOCK, c->lock);
  REG_SET_FIELD(r, REG_FRAMEBUFFERS_CONTROL, SKIP_COLUMN, c->skip_column);
  REG_SET_FIELD(r, REG_FRAMEBUFFERS_CONTROL, SKIP_ROW, c->skip_row);
  REG_SET_FIELD(r, REG_FRAMEBUFFERS_CONTROL, DOUBLE_COLORDEPTH, c->double_colordepth);
  REG_SET_FIELD(r, REG_FRAMEBUFFERS_CONTROL, HIGH_RES, c->high_res);

  REG32(DVI_IN_REG_FRAMEBUFFERS_CONTROL(0)) = r;

  return 0;
}

void dvi_set_reset(unsigned int rst) {
  REG32(DVI_IN_REG_RESET(0)) = rst;
}

void dvi_get_pipeline_debug_ctrl(pipeline_debug_ctrl_t c[3]) {
  uint32_t r0 = REG_VALUE(REG_PIPELINE_DEBUG_CTRL0, 0);
  uint32_t r1 = REG_VALUE(REG_PIPELINE_DEBUG_CTRL1, 0);
  uint32_t r2 = REG_VALUE(REG_PIPELINE_DEBUG_CTRL2, 0);


  c[0].ovr = REG_GET_FIELD(r0, REG_PIPELINE_DEBUG_CTRL0, OVERRIDE0);
  c[0].delay = REG_GET_FIELD(r0, REG_PIPELINE_DEBUG_CTRL0, DELAY0);
  c[0].bitslip = REG_GET_FIELD(r0, REG_PIPELINE_DEBUG_CTRL0, BITSLIP0);
  c[0].delay_increment = REG_GET_FIELD(r0, REG_PIPELINE_DEBUG_CTRL0, DELAY_INCREMENT0);

  c[1].ovr = REG_GET_FIELD(r1, REG_PIPELINE_DEBUG_CTRL1, OVERRIDE1);
  c[1].delay = REG_GET_FIELD(r1, REG_PIPELINE_DEBUG_CTRL1, DELAY1);
  c[1].bitslip = REG_GET_FIELD(r1, REG_PIPELINE_DEBUG_CTRL1, DELAY1);
  c[1].delay_increment = REG_GET_FIELD(r1, REG_PIPELINE_DEBUG_CTRL1, DELAY1);

  c[2].ovr = REG_GET_FIELD(r2, REG_PIPELINE_DEBUG_CTRL2, OVERRIDE2);
  c[2].delay = REG_GET_FIELD(r2, REG_PIPELINE_DEBUG_CTRL2, DELAY2);
  c[2].bitslip = REG_GET_FIELD(r2, REG_PIPELINE_DEBUG_CTRL2, DELAY2);
  c[2].delay_increment = REG_GET_FIELD(r2, REG_PIPELINE_DEBUG_CTRL2, DELAY2);
}

void dvi_get_channel_deskew_debug_ctrl(channel_deskew_debug_ctrl_t* c) {
  uint32_t r = REG_VALUE(REG_CHANNEL_DESKEW_DEBUG_CTRL, 0);

  c->ovr = REG_GET_FIELD(r, REG_CHANNEL_DESKEW_DEBUG_CTRL, OVERRIDE);
  c->offset_r = REG_GET_FIELD(r, REG_CHANNEL_DESKEW_DEBUG_CTRL, OFFSET_R);
  c->offset_g = REG_GET_FIELD(r, REG_CHANNEL_DESKEW_DEBUG_CTRL, OFFSET_G);
  c->offset_b = REG_GET_FIELD(r, REG_CHANNEL_DESKEW_DEBUG_CTRL, OFFSET_B);
}

void dvi_get_pixel_counter_debug_ctrl(pixel_counter_debug_ctrl_t* c) {
  uint32_t r = REG_VALUE(REG_PIXEL_COUNTER_DEBUG_CTRL, 0);

  c->ovr = REG_GET_FIELD(r, REG_PIXEL_COUNTER_DEBUG_CTRL, OVERRIDE);
  c->is_hdmi = REG_GET_FIELD(r, REG_PIXEL_COUNTER_DEBUG_CTRL, IS_HDMI);
  c->hsync_polarity = REG_GET_FIELD(r, REG_PIXEL_COUNTER_DEBUG_CTRL, HSYNC_POLARITY);
  c->vsync_polarity = REG_GET_FIELD(r, REG_PIXEL_COUNTER_DEBUG_CTRL, VSYNC_POLARITY);
}

void dvi_get_framebuffers_control(framebuffers_control_t* c) {
  uint32_t r = REG_VALUE(REG_FRAMEBUFFERS_CONTROL, 0);

  c->lock = REG_GET_FIELD(r, REG_FRAMEBUFFERS_CONTROL, LOCK);
  c->skip_column = REG_GET_FIELD(r, REG_FRAMEBUFFERS_CONTROL, SKIP_COLUMN);
  c->skip_row = REG_GET_FIELD(r, REG_FRAMEBUFFERS_CONTROL, SKIP_ROW);
  c->double_colordepth = REG_GET_FIELD(r, REG_FRAMEBUFFERS_CONTROL, DOUBLE_COLORDEPTH);
  c->high_res = REG_GET_FIELD(r, REG_FRAMEBUFFERS_CONTROL, HIGH_RES);
}

unsigned int dvi_get_reset(void) {
  uint32_t r = REG_VALUE(REG_RESET, 0);

  return REG_GET_FIELD(r, REG_RESET, RST);
}

int dvi_write_edid(const char* edid, size_t size) {
  if(size > 256) {
    size = 256;
  }
  char* edid_ram = (char*) DVI_IN0_EDID_ADDR;
  for(unsigned int i=0; i<size; i++) {
    edid_ram[i] = edid[i];
  }
  return size;
}

char* dvi_get_edid() {
  return (char*) DVI_IN0_EDID_ADDR;
}

uint8_t* dvi_get_framebuffer(unsigned int index) {
  switch(index) {
    case 0: return ((uint8_t*) DVI_IN0_FB_ADDR) + 0*800*600;
    case 1: return ((uint8_t*) DVI_IN0_FB_ADDR) + 1*800*600;
    default: return NULL;
  }
}

pixel_t dvi_get_framebuffer_pixel(const framebuffers_status_t* status, int index, unsigned int x, unsigned int y) {
  pixel_t p;
  if(x >= status->width || y >= status->height || index > 1 || (index > 0 && status->format == 1)) {
    p.red = p.green = p.blue = ((x/16 % 2 == 0)^(y/16 % 2 == 0)) ? 0xff : 0x00;
    return p;
  }

  if(status->format == 0) {
    const uint8_t* fb = dvi_get_framebuffer(index);
    uint8_t c = fb[y*(status->width)+x];
    p.red   = (c & 0b11100000) << 0 | (c & 0b11100000) >> 3 | (c & 0b11100000) >> 6;
    p.green = (c & 0b00011100) << 3 | (c & 0b00011100) << 0 | (c & 0b00011100) >> 3;
    p.blue  = (c & 0b00000011) << 6 | (c & 0b00000011) << 4 | (c & 0b00000011) << 2 | (c & 0b00000011) << 0;
  } else if(status->format == 1) {
    const uint16_t* fb = (const uint16_t*)dvi_get_framebuffer(0);
    uint16_t c = fb[y*(status->width)+x];
    p.red   = (c & 0b1111100000000000) >> 11 << 3 | 0b00000011;
    p.green = (c & 0b0000011111100000) >>  5 << 2 | 0b00000001;
    p.blue  = (c & 0b0000000000011111) >>  0 << 3 | 0b00000011;
  }
  return p;
}

unsigned int dvi_framebuffer_auto_lock() {
  unsigned int selection = 0;

  framebuffers_control_t ctrl;
  framebuffers_status_t status;

  dvi_get_framebuffers_control(&ctrl);
  if(ctrl.double_colordepth || ctrl.high_res) {
    selection = 0;
  } else {
    while(1) {
      dvi_get_framebuffers_status(&status);
      if(status.valid_frames & 0b11) {
        selection = status.valid_frames & 0b01 ? 0 : 1;
        break;
      }
    }
  }
  dvi_framebuffer_lock(selection);

  while(1) {
    dvi_get_framebuffers_status(&status);
    if(status.valid_frames & (1<<selection))
      break;
  }
  return selection;
}
void dvi_framebuffer_lock(unsigned int i) {
  if(i > 1) {
    return;
  }
  framebuffers_control_t ctrl;
  dvi_get_framebuffers_control(&ctrl);
  ctrl.lock |= 1 << i;
  dvi_set_framebuffers_control(&ctrl);
}
void dvi_framebuffer_unlock(unsigned int i) {
  if(i > 1) {
    return;
  }
  framebuffers_control_t ctrl;
  dvi_get_framebuffers_control(&ctrl);
  ctrl.lock &= ~(1 << i);
  dvi_set_framebuffers_control(&ctrl);
}

void dvi_framebuffer_wait_valid(unsigned int i) {
  framebuffers_status_t status;
  while(1) {
    dvi_get_framebuffers_status(&status);
    if(status.valid_frames & (1<<i))
      break;
  }
}
void dvi_framebuffer_wait_invalid(unsigned int i) {
  framebuffers_status_t status;
  while(1) {
    dvi_get_framebuffers_status(&status);
    if(!(status.valid_frames & (1<<i)))
      break;
  }
}
