package dvi_in_pkg;

typedef struct packed {
    logic valid;
    logic [4:0] delay;
    logic [25:0] quality;
    logic [7:0] pixel_value;
    logic [9:0] last_valid_tmds;
    logic [9:0] last_invalid_tmds;
} pipeline_debug_t;

typedef struct packed {
    logic override;
    logic [4:0] delay;
    logic bitslip;
    logic [3:0] delay_increment;
} pipeline_debug_ctrl_t;

typedef struct packed {
    logic [7:0] red;
    logic [7:0] green;
    logic [7:0] blue;
} debug_pixel_t;

typedef struct packed {
    logic [11:0] cx;
    logic [11:0] cy;
    logic is_video_data;
    logic is_hdmi;
    logic guessed_polarity;
} pixel_counter_debug_t;

typedef struct packed {
    logic override;
    logic is_hdmi;
    logic hsync_polarity;
    logic vsync_polarity;
} pixel_counter_debug_ctrl_t;

typedef struct packed {
    logic valid;
    logic [1:0] offset_r;
    logic [1:0] offset_g;
    logic [1:0] offset_b;
    logic [2:0] de;
    logic [21:0] error_count;
} channel_deskew_debug_t;

typedef struct packed {
    logic override;
    logic [1:0] offset_r;
    logic [1:0] offset_g;
    logic [1:0] offset_b;
} channel_deskew_debug_ctrl_t;

typedef struct packed {
    logic [1:0] valid_frames;
    logic [11:0] width;
    logic [11:0] height;
    logic [5:0] format;
} framebuffers_status_t;

typedef struct packed {
    logic [1:0] lock;
    logic [3:0] skip_column;
    logic [3:0] skip_row;
    logic double_colordepth;
    logic high_res;
} framebuffers_control_t;

typedef struct packed {
    logic rst;
} reset_t;

endpackage
