#ifndef EDID_H
#define EDID_H

#define EDID_DVI_SIZE 128
extern const char edid_dvi_640x480[EDID_DVI_SIZE];
extern const char edid_dvi_800x600[EDID_DVI_SIZE];
extern const char edid_dvi_1024x768[EDID_DVI_SIZE];
extern const char edid_dvi_1280x720[EDID_DVI_SIZE];
extern const char edid_dvi_1920x1080[EDID_DVI_SIZE];

#define EDID_HDMI_SIZE 256
extern const char edid_hdmi_640x480[EDID_HDMI_SIZE];
extern const char edid_hdmi_800x600[EDID_HDMI_SIZE];
extern const char edid_hdmi_1024x768[EDID_HDMI_SIZE];
extern const char edid_hdmi_1280x720[EDID_HDMI_SIZE];
extern const char edid_hdmi_1920x1080[EDID_HDMI_SIZE];

#endif