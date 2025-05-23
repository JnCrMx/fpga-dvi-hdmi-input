#include "edid.h"

const char edid_dvi_640x480[EDID_DVI_SIZE] = {
	0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00,
	0x4a, 0xcc, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x1e, 0x22, 0x01, 0x03, 0x80, 0x16, 0x10, 0x78,
	0xea, 0x5e, 0xc0, 0xa4, 0x59, 0x4a, 0x98, 0x25,
	0x20, 0x50, 0x54, 0x10, 0x00, 0x00, 0x31, 0x40,
	0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01,
	0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xd8, 0x09,
	0x80, 0xa0, 0x20, 0xe0, 0x2d, 0x10, 0x10, 0x60,
	0x73, 0x00, 0xde, 0xa6, 0x00, 0x00, 0x00, 0x18,
	0x00, 0x00, 0x00, 0xff, 0x00, 0x72, 0x76, 0x6c,
	0x61, 0x62, 0x30, 0x39, 0x2d, 0x31, 0x0a, 0x20,
	0x20, 0x20, 0x00, 0x00, 0x00, 0xfd, 0x00, 0x3b,
	0x3d, 0x1e, 0x20, 0x03, 0x00, 0x0a, 0x20, 0x20,
	0x20, 0x20, 0x20, 0x20, 0x00, 0x00, 0x00, 0xfc,
	0x00, 0x72, 0x76, 0x6c, 0x61, 0x62, 0x30, 0x39,
	0x20, 0x56, 0x47, 0x41, 0x0a, 0x20, 0x00, 0x07,
};
const char edid_dvi_800x600[EDID_DVI_SIZE] = {
	0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00,
	0x4a, 0xcc, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x1e, 0x22, 0x01, 0x03, 0x80, 0x1b, 0x14, 0x78,
	0xea, 0x5e, 0xc0, 0xa4, 0x59, 0x4a, 0x98, 0x25,
	0x20, 0x50, 0x54, 0x01, 0x00, 0x00, 0x45, 0x40,
	0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01,
	0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xa0, 0x0f,
	0x20, 0x00, 0x31, 0x58, 0x1c, 0x20, 0x28, 0x80,
	0x14, 0x00, 0x15, 0xd0, 0x10, 0x00, 0x00, 0x18,
	0x00, 0x00, 0x00, 0xff, 0x00, 0x72, 0x76, 0x6c,
	0x61, 0x62, 0x30, 0x39, 0x2d, 0x31, 0x0a, 0x20,
	0x20, 0x20, 0x00, 0x00, 0x00, 0xfd, 0x00, 0x3b,
	0x3d, 0x24, 0x26, 0x05, 0x00, 0x0a, 0x20, 0x20,
	0x20, 0x20, 0x20, 0x20, 0x00, 0x00, 0x00, 0xfc,
	0x00, 0x72, 0x76, 0x6c, 0x61, 0x62, 0x30, 0x39,
	0x20, 0x53, 0x56, 0x47, 0x41, 0x0a, 0x00, 0x18,
};
const char edid_dvi_1024x768[EDID_DVI_SIZE] = {
	0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00,
	0x4a, 0xcc, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x1e, 0x22, 0x01, 0x03, 0x80, 0x23, 0x1a, 0x78,
	0xea, 0x5e, 0xc0, 0xa4, 0x59, 0x4a, 0x98, 0x25,
	0x20, 0x50, 0x54, 0x00, 0x08, 0x00, 0x61, 0x40,
	0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01,
	0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x64, 0x19,
	0x00, 0x40, 0x41, 0x00, 0x26, 0x30, 0x08, 0x90,
	0x36, 0x00, 0x63, 0x0a, 0x11, 0x00, 0x00, 0x18,
	0x00, 0x00, 0x00, 0xff, 0x00, 0x72, 0x76, 0x6c,
	0x61, 0x62, 0x30, 0x39, 0x2d, 0x31, 0x0a, 0x20,
	0x20, 0x20, 0x00, 0x00, 0x00, 0xfd, 0x00, 0x3b,
	0x3d, 0x2f, 0x31, 0x07, 0x00, 0x0a, 0x20, 0x20,
	0x20, 0x20, 0x20, 0x20, 0x00, 0x00, 0x00, 0xfc,
	0x00, 0x72, 0x76, 0x6c, 0x61, 0x62, 0x30, 0x39,
	0x20, 0x58, 0x47, 0x41, 0x0a, 0x20, 0x00, 0xa5,
};
const char edid_dvi_1280x720[EDID_DVI_SIZE] = {
	0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00,
	0x4a, 0xcc, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x1e, 0x22, 0x01, 0x03, 0x80, 0x21, 0x12, 0x78,
	0xea, 0x5e, 0xc0, 0xa4, 0x59, 0x4a, 0x98, 0x25,
	0x20, 0x50, 0x54, 0x00, 0x00, 0x00, 0x81, 0xc0,
	0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01,
	0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x1a, 0x1d,
	0x00, 0x80, 0x51, 0xd0, 0x1c, 0x20, 0x40, 0x80,
	0x35, 0x00, 0x4d, 0xbb, 0x10, 0x00, 0x00, 0x18,
	0x00, 0x00, 0x00, 0xff, 0x00, 0x72, 0x76, 0x6c,
	0x61, 0x62, 0x30, 0x39, 0x2d, 0x31, 0x0a, 0x20,
	0x20, 0x20, 0x00, 0x00, 0x00, 0xfd, 0x00, 0x3b,
	0x3d, 0x2b, 0x2d, 0x08, 0x00, 0x0a, 0x20, 0x20,
	0x20, 0x20, 0x20, 0x20, 0x00, 0x00, 0x00, 0xfc,
	0x00, 0x72, 0x76, 0x6c, 0x61, 0x62, 0x30, 0x39,
	0x20, 0x48, 0x44, 0x0a, 0x20, 0x20, 0x00, 0xd1,
};
const char edid_dvi_1920x1080[EDID_DVI_SIZE] = {
	0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00,
	0x4a, 0xcc, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x1e, 0x22, 0x01, 0x03, 0x80, 0x32, 0x1c, 0x78,
	0xea, 0x5e, 0xc0, 0xa4, 0x59, 0x4a, 0x98, 0x25,
	0x20, 0x50, 0x54, 0x00, 0x00, 0x00, 0xd1, 0x93,
	0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01,
	0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x80, 0x0e,
	0x80, 0x18, 0x71, 0x38, 0x2d, 0x40, 0x58, 0x2c,
	0x45, 0x00, 0xf4, 0x19, 0x11, 0x00, 0x00, 0x18,
	0x00, 0x00, 0x00, 0xff, 0x00, 0x72, 0x76, 0x6c,
	0x61, 0x62, 0x30, 0x39, 0x2d, 0x31, 0x0a, 0x20,
	0x20, 0x20, 0x00, 0x00, 0x00, 0xfd, 0x00, 0x0e,
	0x10, 0x0f, 0x11, 0x04, 0x00, 0x0a, 0x20, 0x20,
	0x20, 0x20, 0x20, 0x20, 0x00, 0x00, 0x00, 0xfc,
	0x00, 0x72, 0x76, 0x30, 0x39, 0x20, 0x46, 0x48,
	0x44, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x00, 0xd0,
};

const char edid_hdmi_640x480[EDID_HDMI_SIZE] = {
	0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00,
	0x4a, 0xcc, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x1e, 0x22, 0x01, 0x03, 0x80, 0x16, 0x10, 0x78,
	0xea, 0x5e, 0xc0, 0xa4, 0x59, 0x4a, 0x98, 0x25,
	0x20, 0x50, 0x54, 0x10, 0x00, 0x00, 0x31, 0x40,
	0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01,
	0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xd8, 0x09,
	0x80, 0xa0, 0x20, 0xe0, 0x2d, 0x10, 0x10, 0x60,
	0x73, 0x00, 0xde, 0xa6, 0x00, 0x00, 0x00, 0x18,
	0x00, 0x00, 0x00, 0xff, 0x00, 0x72, 0x76, 0x6c,
	0x61, 0x62, 0x30, 0x39, 0x2d, 0x31, 0x0a, 0x20,
	0x20, 0x20, 0x00, 0x00, 0x00, 0xfd, 0x00, 0x3b,
	0x3d, 0x1e, 0x20, 0x03, 0x00, 0x0a, 0x20, 0x20,
	0x20, 0x20, 0x20, 0x20, 0x00, 0x00, 0x00, 0xfc,
	0x00, 0x72, 0x76, 0x6c, 0x61, 0x62, 0x30, 0x39,
	0x20, 0x56, 0x47, 0x41, 0x0a, 0x20, 0x01, 0x06,
	0x02, 0x03, 0x0d, 0x80, 0x66, 0x03, 0x0c, 0x00,
	0x10, 0x00, 0x00, 0x41, 0x01, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xa7,
};
const char edid_hdmi_800x600[EDID_HDMI_SIZE] = {
	0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00,
	0x4a, 0xcc, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x1e, 0x22, 0x01, 0x03, 0x80, 0x1b, 0x14, 0x78,
	0xea, 0x5e, 0xc0, 0xa4, 0x59, 0x4a, 0x98, 0x25,
	0x20, 0x50, 0x54, 0x01, 0x00, 0x00, 0x45, 0x40,
	0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01,
	0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xa0, 0x0f,
	0x20, 0x00, 0x31, 0x58, 0x1c, 0x20, 0x28, 0x80,
	0x14, 0x00, 0x15, 0xd0, 0x10, 0x00, 0x00, 0x18,
	0x00, 0x00, 0x00, 0xff, 0x00, 0x72, 0x76, 0x6c,
	0x61, 0x62, 0x30, 0x39, 0x2d, 0x31, 0x0a, 0x20,
	0x20, 0x20, 0x00, 0x00, 0x00, 0xfd, 0x00, 0x3b,
	0x3d, 0x24, 0x26, 0x05, 0x00, 0x0a, 0x20, 0x20,
	0x20, 0x20, 0x20, 0x20, 0x00, 0x00, 0x00, 0xfc,
	0x00, 0x72, 0x76, 0x6c, 0x61, 0x62, 0x30, 0x39,
	0x20, 0x53, 0x56, 0x47, 0x41, 0x0a, 0x01, 0x17,
	0x02, 0x03, 0x0d, 0x80, 0x66, 0x03, 0x0c, 0x00,
	0x10, 0x00, 0x00, 0x41, 0x01, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xa7,
};
const char edid_hdmi_1024x768[EDID_HDMI_SIZE] = {
	0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00,
	0x4a, 0xcc, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x1e, 0x22, 0x01, 0x03, 0x80, 0x23, 0x1a, 0x78,
	0xea, 0x5e, 0xc0, 0xa4, 0x59, 0x4a, 0x98, 0x25,
	0x20, 0x50, 0x54, 0x00, 0x08, 0x00, 0x61, 0x40,
	0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01,
	0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x64, 0x19,
	0x00, 0x40, 0x41, 0x00, 0x26, 0x30, 0x08, 0x90,
	0x36, 0x00, 0x63, 0x0a, 0x11, 0x00, 0x00, 0x18,
	0x00, 0x00, 0x00, 0xff, 0x00, 0x72, 0x76, 0x6c,
	0x61, 0x62, 0x30, 0x39, 0x2d, 0x31, 0x0a, 0x20,
	0x20, 0x20, 0x00, 0x00, 0x00, 0xfd, 0x00, 0x3b,
	0x3d, 0x2f, 0x31, 0x07, 0x00, 0x0a, 0x20, 0x20,
	0x20, 0x20, 0x20, 0x20, 0x00, 0x00, 0x00, 0xfc,
	0x00, 0x72, 0x76, 0x6c, 0x61, 0x62, 0x30, 0x39,
	0x20, 0x58, 0x47, 0x41, 0x0a, 0x20, 0x01, 0xa4,
	0x02, 0x03, 0x0d, 0x80, 0x66, 0x03, 0x0c, 0x00,
	0x10, 0x00, 0x00, 0x41, 0x01, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xa7,
};
const char edid_hdmi_1280x720[EDID_HDMI_SIZE] = {
	0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00,
	0x4a, 0xcc, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x1e, 0x22, 0x01, 0x03, 0x80, 0x21, 0x12, 0x78,
	0xea, 0x5e, 0xc0, 0xa4, 0x59, 0x4a, 0x98, 0x25,
	0x20, 0x50, 0x54, 0x00, 0x00, 0x00, 0x81, 0xc0,
	0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01,
	0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x1a, 0x1d,
	0x00, 0x80, 0x51, 0xd0, 0x1c, 0x20, 0x40, 0x80,
	0x35, 0x00, 0x4d, 0xbb, 0x10, 0x00, 0x00, 0x18,
	0x00, 0x00, 0x00, 0xff, 0x00, 0x72, 0x76, 0x6c,
	0x61, 0x62, 0x30, 0x39, 0x2d, 0x31, 0x0a, 0x20,
	0x20, 0x20, 0x00, 0x00, 0x00, 0xfd, 0x00, 0x3b,
	0x3d, 0x2b, 0x2d, 0x08, 0x00, 0x0a, 0x20, 0x20,
	0x20, 0x20, 0x20, 0x20, 0x00, 0x00, 0x00, 0xfc,
	0x00, 0x72, 0x76, 0x6c, 0x61, 0x62, 0x30, 0x39,
	0x20, 0x48, 0x44, 0x0a, 0x20, 0x20, 0x01, 0xd0,
	0x02, 0x03, 0x0d, 0x80, 0x66, 0x03, 0x0c, 0x00,
	0x10, 0x00, 0x00, 0x41, 0x01, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xa7,
};
const char edid_hdmi_1920x1080[EDID_HDMI_SIZE] = {
	0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00,
	0x4a, 0xcc, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x1e, 0x22, 0x01, 0x03, 0x80, 0x32, 0x1c, 0x78,
	0xea, 0x5e, 0xc0, 0xa4, 0x59, 0x4a, 0x98, 0x25,
	0x20, 0x50, 0x54, 0x00, 0x00, 0x00, 0xd1, 0x93,
	0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01,
	0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x80, 0x0e,
	0x80, 0x18, 0x71, 0x38, 0x2d, 0x40, 0x58, 0x2c,
	0x45, 0x00, 0xf4, 0x19, 0x11, 0x00, 0x00, 0x18,
	0x00, 0x00, 0x00, 0xff, 0x00, 0x72, 0x76, 0x6c,
	0x61, 0x62, 0x30, 0x39, 0x2d, 0x31, 0x0a, 0x20,
	0x20, 0x20, 0x00, 0x00, 0x00, 0xfd, 0x00, 0x0e,
	0x10, 0x0f, 0x11, 0x04, 0x00, 0x0a, 0x20, 0x20,
	0x20, 0x20, 0x20, 0x20, 0x00, 0x00, 0x00, 0xfc,
	0x00, 0x72, 0x76, 0x30, 0x39, 0x20, 0x46, 0x48,
	0x44, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x01, 0xcf,
	0x02, 0x03, 0x0d, 0x80, 0x66, 0x03, 0x0c, 0x00,
	0x10, 0x00, 0x00, 0x41, 0x01, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xa7,
};
