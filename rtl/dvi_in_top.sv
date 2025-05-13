module dvi_in_top (
  input logic clk_i,
  input logic clk_200_i,
  input logic rst_ni,
  output logic [1:0] irq_valid_frames,
  output logic irq_pll_locked,
  output logic irq_pll_lost,

  input logic [2:0] tmds_channel,
  input logic tmds_clk,
  input logic sda,
  output logic sda_oe,
  input logic scl,
  output logic hpa,
  output logic txen,
  output logic cec_oe,

  input  tlul_pkg::tl_h2d_t tl_registers_i,
  output tlul_pkg::tl_d2h_t tl_registers_o,
  input  tlul_pkg::tl_h2d_t tl_framebuffer_i,
  output tlul_pkg::tl_d2h_t tl_framebuffer_o,
  input  tlul_pkg::tl_h2d_t tl_edid_i,
  output tlul_pkg::tl_d2h_t tl_edid_o

);

logic pclk1x;
logic pclk5x;
logic locked;

logic clk_200_buf;

logic rst_ps;

dvi_in_pkg::pipeline_debug_t [2:0] pipeline_debug;
dvi_in_pkg::channel_deskew_debug_t channel_deskew_debug;
dvi_in_pkg::framebuffers_status_t framebuffers_status;
dvi_in_pkg::debug_pixel_t main_debug_pixel;
dvi_in_pkg::pixel_counter_debug_t pixel_counter_debug;
  
dvi_in_pkg::pipeline_debug_ctrl_t [2:0] pipeline_debug_ctrl;
dvi_in_pkg::channel_deskew_debug_ctrl_t channel_deskew_debug_ctrl;
dvi_in_pkg::pixel_counter_debug_ctrl_t pixel_counter_debug_ctrl;
dvi_in_pkg::framebuffers_control_t framebuffers_control;

// raw data from the pipelines
logic [7:0] channel_data_raw[3];
logic [1:0] control_data_raw[3];
logic [9:0] tmds_symbol_raw[3];
logic de_raw[3];

// deskewed data
logic [7:0] channel_data[3];
logic [1:0] control_data[3];
logic [9:0] tmds_symbol[3];
logic de[3];

// processed data (with pixel counter to remove HDMI stuff)
logic [7:0] red;
logic [7:0] green;
logic [7:0] blue;
logic is_video_data;
logic frame_complete;
logic row_complete;
logic [11:0] cx;
logic [11:0] cy;

// required for enabling HDMI input
assign hpa = '1;
assign txen = '1;
assign cec_oe = '0; // we don't support CEC

generate
  for (genvar i = 0; i < 3; i = i + 1) begin
    dvi_in_pipeline dvi_in_pipeline(
    .rst_ps,
    .tmds_in(tmds_channel[i]),
    .pclk1x,
    .pclk5x,
    .channel_data(channel_data_raw[i]),
    .control_data(control_data_raw[i]),
    .tmds_symbol(tmds_symbol_raw[i]),
    .de(de_raw[i]),
    .debug_o(pipeline_debug[i]),
    .debug_ctrl_i(pipeline_debug_ctrl[i])
    );
  end
endgenerate

dvi_in_channel_deskew dvi_in_channel_deskew(
  .pclk1x,
  .rst_ps,
  .channel_data_i(channel_data_raw),
  .control_data_i(control_data_raw),
  .tmds_symbol_i(tmds_symbol_raw),
  .de_i(de_raw),
  .channel_data_o(channel_data),
  .control_data_o(control_data),
  .tmds_symbol_o(tmds_symbol),
  .de_o(de),
  .debug_o(channel_deskew_debug),
  .debug_ctrl_i(channel_deskew_debug_ctrl)
);

dvi_in_pixel_counter dvi_in_pixel_counter(
  .pclk1x,
  .rst_ps,
  .channel_data,
  .control_data,
  .tmds_symbol,
  .de,
  .red, .green, .blue,
  .is_video_data,
  .is_hdmi(pixel_counter_debug.is_hdmi),
  .frame_complete,
  .row_complete,
  .cx, .cy,
  .guessed_polarity(pixel_counter_debug.guessed_polarity),
  .debug_ctrl_i(pixel_counter_debug_ctrl)
);
assign main_debug_pixel.red = red;
assign main_debug_pixel.green = green;
assign main_debug_pixel.blue = blue;
assign pixel_counter_debug.cx = cx;
assign pixel_counter_debug.cy = cy;
assign pixel_counter_debug.is_video_data = is_video_data;

dvi_in_registers dvi_in_registers (
  .clk_i,
  .rst_ni,
  .irq_valid_frames,
  .irq_pll_locked,
  .irq_pll_lost,
  .tl_i(tl_registers_i),
  .tl_o(tl_registers_o),

  .pclk1x_i(pclk1x),
  .rst_ps,
  .locked,
  .pipeline_debug_i(pipeline_debug),
  .channel_deskew_debug_i(channel_deskew_debug),
  .framebuffers_status_i(framebuffers_status),
  .pipeline_debug_ctrl_o(pipeline_debug_ctrl),
  .channel_deskew_debug_ctrl_o(channel_deskew_debug_ctrl),
  .pixel_counter_debug_ctrl_o(pixel_counter_debug_ctrl),
  .framebuffers_control_o(framebuffers_control),
  .main_debug_pixel_i(main_debug_pixel),
  .pixel_counter_debug_i(pixel_counter_debug)
);

logic sda_o;
logic sda_oe_inner;
dvi_in_edid dvi_in_edid(
  .clk_i,
  .rst_ni,

  .sda_i(sda),
  .sda_o(sda_o),
  .oe(sda_oe_inner),
  .scl,

  .tl_i(tl_edid_i),
  .tl_o(tl_edid_o)
);

assign sda_oe = sda_oe_inner ? ~sda_o : 0;

dvi_in_framebuffers #(.WIDTH(800), .HEIGHT(600), .ADDR_WIDTH(18)) dvi_in_framebuffers (
  .clk_i,
  .rst_ni,
  .pclk1x,
  .rst_ps,
  .red,
  .green,
  .blue,
  .is_video_data,
  .row_complete,
  .frame_complete,
  .cx,
  .cy,
  .framebuffers_control_i(framebuffers_control),
  .framebuffers_status_o(framebuffers_status),
  .tl_i(tl_framebuffer_i),
  .tl_o(tl_framebuffer_o)
);


dvi_in_pll dvi_in_pll(
  .pclk_in (tmds_clk),
  .reset (),
  .locked,
  .pclk1x_out (pclk1x),
  .pclk5x_out (pclk5x)
);

(* IODELAY_GROUP = "dvi_in_delay_group" *) 
IDELAYCTRL IDELAYCTRL_inst (
  .RDY(),
  .REFCLK(clk_200_i),
  .RST('0)
);

endmodule
