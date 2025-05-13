module dvi_in_registers(
  input logic clk_i,
  input logic rst_ni,
  output logic [1:0] irq_valid_frames,
  output logic irq_pll_locked,
  output logic irq_pll_lost,
  input  tlul_pkg::tl_h2d_t tl_i,  //master input (incoming request)
  output tlul_pkg::tl_d2h_t tl_o,  //slave output (this module's response)

  input logic pclk1x_i,
  input logic locked,

  output logic rst_ps,

  input dvi_in_pkg::pipeline_debug_t [2:0] pipeline_debug_i,
  input dvi_in_pkg::channel_deskew_debug_t channel_deskew_debug_i,
  input dvi_in_pkg::framebuffers_status_t framebuffers_status_i,
  input dvi_in_pkg::debug_pixel_t main_debug_pixel_i,
  input dvi_in_pkg::pixel_counter_debug_t pixel_counter_debug_i,

  output dvi_in_pkg::pipeline_debug_ctrl_t [2:0] pipeline_debug_ctrl_o,
  output dvi_in_pkg::channel_deskew_debug_ctrl_t channel_deskew_debug_ctrl_o,
  output dvi_in_pkg::pixel_counter_debug_ctrl_t pixel_counter_debug_ctrl_o,
  output dvi_in_pkg::framebuffers_control_t framebuffers_control_o
);

import dvi_in_reg_pkg::*;

dvi_in_reg2hw_t reg2hw;
dvi_in_hw2reg_t hw2reg;

dvi_in_reg_top dvi_in_reg_top
(
  .clk_i,
  .rst_ni,
  .tl_i,
  .tl_o,
  .reg2hw,
  .hw2reg,
  .devmode_i('1)
);

typedef struct packed {
  dvi_in_pkg::pipeline_debug_t [2:0] pipeline_debug;
  dvi_in_pkg::channel_deskew_debug_t channel_deskew_debug;
  dvi_in_pkg::framebuffers_status_t framebuffers_status;
  dvi_in_pkg::debug_pixel_t main_debug_pixel;
  dvi_in_pkg::pixel_counter_debug_t pixel_counter_debug;
  logic [20:0] pclk_counter;
} hw2reg_fifo_t;

logic [20:0] pclk_counter;

hw2reg_fifo_t hw2reg_fifo_in;
hw2reg_fifo_t hw2reg_fifo_out;
logic hw2reg_fifo_out_valid;

prim_fifo_async #(
  .Width($bits(hw2reg_fifo_t)),
  .Depth(3)
) hw2reg_fifo (
  .clk_wr_i(pclk1x_i),
  .rst_wr_ni(~rst_ps),
  .wvalid(locked),
  .wdata(hw2reg_fifo_in),

  .clk_rd_i(clk_i),
  .rst_rd_ni(rst_ni),
  .rvalid(hw2reg_fifo_out_valid),
  .rready('1),
  .rdata(hw2reg_fifo_out)
);

assign hw2reg_fifo_in.pipeline_debug = pipeline_debug_i;
assign hw2reg_fifo_in.channel_deskew_debug = channel_deskew_debug_i;
assign hw2reg_fifo_in.framebuffers_status = framebuffers_status_i;
assign hw2reg_fifo_in.main_debug_pixel = main_debug_pixel_i;
assign hw2reg_fifo_in.pixel_counter_debug = pixel_counter_debug_i;
assign hw2reg_fifo_in.pclk_counter = pclk_counter;

(* ASYNC_REG = "TRUE" *)
dvi_in_pkg::pipeline_debug_ctrl_t [2:0] pipeline_debug_ctrl_reg;
(* ASYNC_REG = "TRUE" *)
dvi_in_pkg::channel_deskew_debug_ctrl_t channel_deskew_debug_ctrl_reg;
(* ASYNC_REG = "TRUE" *)
dvi_in_pkg::pixel_counter_debug_ctrl_t pixel_counter_debug_ctrl_reg;
(* ASYNC_REG = "TRUE" *)
dvi_in_pkg::framebuffers_control_t framebuffers_control_reg;
(* ASYNC_REG = "TRUE" *)
dvi_in_pkg::reset_t reset_t_reg;

dvi_in_pkg::reset_t reset_t_sync;
logic [20:0] sys_clk_counter;
logic locked_sync;

prim_flop_2sync #(
  .Width(1)
) locked_flop (
  .clk_i(clk_i),
  .rst_ni(rst_ni),
  .d(locked),
  .q(locked_sync)
);

dvi_in_reset_ctrl dvi_in_reset(
  .rst_request(reset_t_sync.rst),
  .pclk1x(pclk1x_i),
  .locked(locked),
  .rst(rst_ps)
);

always_ff @(posedge pclk1x_i) begin
  if(rst_ps) begin
    pclk_counter <= 0;
  end else begin
    pclk_counter <= pclk_counter + 1;
  end
end
always_ff @(posedge clk_i, negedge rst_ni) begin
  if(~rst_ni) begin
    sys_clk_counter <= 0;
  end else begin
    sys_clk_counter <= sys_clk_counter + 1;
  end
end


//interrupt detection valid_frames
logic [1:0] last_valid_frames;

always_ff @(posedge clk_i, negedge rst_ni) begin
  if(~rst_ni) begin
    irq_valid_frames <= '0;
    last_valid_frames <= '0;
  end else begin
    for (int i = 0; i < 2; i++) begin
      if (~last_valid_frames[i] && hw2reg_fifo_out.framebuffers_status.valid_frames[i]) irq_valid_frames[i] <= 1;
    end
    if (reg2hw.reg_framebuffers_status.valid_frames.re) irq_valid_frames <= '0;
    last_valid_frames <= hw2reg_fifo_out.framebuffers_status.valid_frames;
  end
end

logic last_locked_sync;
always_ff @(posedge clk_i, negedge rst_ni) begin
  if(~rst_ni) begin
    last_locked_sync <= 0;
    irq_pll_locked <= 0;
    irq_pll_lost <= 0;
  end else begin
    if(last_locked_sync == 0 && locked_sync == 1) begin
      irq_pll_locked <= 1;
      irq_pll_lost <= 0;
    end else if(last_locked_sync == 1 && locked_sync == 0) begin
      irq_pll_lost <= 1;
      irq_pll_locked <= 0;
    end

    if(reg2hw.reg_clock_status.locked.re) begin
      irq_pll_locked <= 0;
      irq_pll_lost <= 0;
    end

    last_locked_sync <= locked_sync;
  end
end

//First FF sys_clk -> pclk
//--------

generate
  for (genvar i = 0; i < 3; i = i + 1) begin
    always_ff @(posedge pclk1x_i) begin
      if(rst_ps) begin

      end else begin
        pipeline_debug_ctrl_reg[i].override <= reg2hw.reg_pipeline_debug_ctrl[i].override.q;
        pipeline_debug_ctrl_reg[i].delay <= reg2hw.reg_pipeline_debug_ctrl[i].delay.q;
        pipeline_debug_ctrl_reg[i].bitslip <= reg2hw.reg_pipeline_debug_ctrl[i].bitslip.q && reg2hw.reg_pipeline_debug_ctrl[i].bitslip.qe;
        pipeline_debug_ctrl_reg[i].delay_increment <= reg2hw.reg_pipeline_debug_ctrl[i].delay_increment.q;
      end
    end
  end
endgenerate

always_ff @(posedge pclk1x_i) begin
  if(rst_ps) begin

  end else begin
    channel_deskew_debug_ctrl_reg.override <= reg2hw.reg_channel_deskew_debug_ctrl.override.q;
    channel_deskew_debug_ctrl_reg.offset_r <= reg2hw.reg_channel_deskew_debug_ctrl.offset_r.q;
    channel_deskew_debug_ctrl_reg.offset_g <= reg2hw.reg_channel_deskew_debug_ctrl.offset_g.q;
    channel_deskew_debug_ctrl_reg.offset_b <= reg2hw.reg_channel_deskew_debug_ctrl.offset_b.q;

    pixel_counter_debug_ctrl_reg.override <= reg2hw.reg_pixel_counter_debug_ctrl.override.q;
    pixel_counter_debug_ctrl_reg.is_hdmi <= reg2hw.reg_pixel_counter_debug_ctrl.is_hdmi.q;
    pixel_counter_debug_ctrl_reg.hsync_polarity <= reg2hw.reg_pixel_counter_debug_ctrl.hsync_polarity.q;
    pixel_counter_debug_ctrl_reg.vsync_polarity <= reg2hw.reg_pixel_counter_debug_ctrl.vsync_polarity.q;

    framebuffers_control_reg.lock <= reg2hw.reg_framebuffers_control.lock.q;
    framebuffers_control_reg.skip_column <= reg2hw.reg_framebuffers_control.skip_column.q;
    framebuffers_control_reg.skip_row <= reg2hw.reg_framebuffers_control.skip_row.q;
    framebuffers_control_reg.double_colordepth <= reg2hw.reg_framebuffers_control.double_colordepth.q;
    framebuffers_control_reg.high_res <= reg2hw.reg_framebuffers_control.high_res.q;

    reset_t_reg.rst <= reg2hw.reg_reset.q;
  end
end

//Second FF sys_clk -> pclk
//---------

always_ff @(posedge pclk1x_i) begin
  if(rst_ps) begin

  end else begin
    pipeline_debug_ctrl_o <= pipeline_debug_ctrl_reg;
    channel_deskew_debug_ctrl_o <= channel_deskew_debug_ctrl_reg;
    pixel_counter_debug_ctrl_o <= pixel_counter_debug_ctrl_reg;
    framebuffers_control_o <= framebuffers_control_reg;
    reset_t_sync <= reset_t_reg;
  end
end

//Second FF pclk -> sys_clk
//---------

generate
  for (genvar i = 0; i < 3; i = i + 1) begin
    always_ff @(posedge clk_i, negedge rst_ni) begin
      if(~rst_ni) begin
        hw2reg.reg_pipeline_debug[i].valid.d <= 0;
        hw2reg.reg_pipeline_debug[i].delay.d <= 0;
        hw2reg.reg_pipeline_debug[i].quality.d <= 0;
        hw2reg.reg_tmds_debug[i].last_valid.d <= 0;
        hw2reg.reg_tmds_debug[i].last_invalid.d <= 0;
      end else if(hw2reg_fifo_out_valid) begin
        hw2reg.reg_pipeline_debug[i].valid.d <= hw2reg_fifo_out.pipeline_debug[i].valid;
        hw2reg.reg_pipeline_debug[i].delay.d <= hw2reg_fifo_out.pipeline_debug[i].delay;
        hw2reg.reg_pipeline_debug[i].quality.d <= hw2reg_fifo_out.pipeline_debug[i].quality;
        hw2reg.reg_tmds_debug[i].last_valid.d <= hw2reg_fifo_out.pipeline_debug[i].last_valid_tmds;
        hw2reg.reg_tmds_debug[i].last_invalid.d <= hw2reg_fifo_out.pipeline_debug[i].last_invalid_tmds;
      end
    end
  end
endgenerate

always_ff @(posedge clk_i, negedge rst_ni) begin
  if(~rst_ni) begin
    hw2reg.reg_pipeline_debug_pixel.red.d <= 0;
    hw2reg.reg_pipeline_debug_pixel.green.d <= 0;
    hw2reg.reg_pipeline_debug_pixel.blue.d <= 0;

    hw2reg.reg_debug_pixel.red.d <= 0;
    hw2reg.reg_debug_pixel.green.d <= 0;
    hw2reg.reg_debug_pixel.blue.d <= 0;

    hw2reg.reg_pixel_counter_debug.cx.d <= 0;
    hw2reg.reg_pixel_counter_debug.cy.d <= 0;
    hw2reg.reg_pixel_counter_debug.is_video_data.d <= 0;
    hw2reg.reg_pixel_counter_debug.is_hdmi.d <= 0;

    hw2reg.reg_channel_deskew_debug.valid.d <= 0;
    hw2reg.reg_channel_deskew_debug.offset_r.d <= 0;
    hw2reg.reg_channel_deskew_debug.offset_g.d <= 0;
    hw2reg.reg_channel_deskew_debug.offset_b.d <= 0;
    hw2reg.reg_channel_deskew_debug.de.d <= 0;
    hw2reg.reg_channel_deskew_debug.error_count.d <= 0;

    hw2reg.reg_framebuffers_status.valid_frames.d <= 0;
    hw2reg.reg_framebuffers_status.width.d <= 0;
    hw2reg.reg_framebuffers_status.height.d <= 0;
    hw2reg.reg_framebuffers_status.format.d <= 0;

    hw2reg.reg_clock_status.locked.d <= 0;
    hw2reg.reg_clock_status.sys_clk_counter.d <= 0;
    hw2reg.reg_clock_status.pclk_counter.d <= 0;
  end else begin
    if(hw2reg_fifo_out_valid) begin
      hw2reg.reg_pipeline_debug_pixel.red.d <= hw2reg_fifo_out.pipeline_debug[2].pixel_value;
      hw2reg.reg_pipeline_debug_pixel.green.d <= hw2reg_fifo_out.pipeline_debug[1].pixel_value;
      hw2reg.reg_pipeline_debug_pixel.blue.d <= hw2reg_fifo_out.pipeline_debug[0].pixel_value;

      hw2reg.reg_debug_pixel.red.d <= hw2reg_fifo_out.main_debug_pixel.red;
      hw2reg.reg_debug_pixel.green.d <= hw2reg_fifo_out.main_debug_pixel.green;
      hw2reg.reg_debug_pixel.blue.d <= hw2reg_fifo_out.main_debug_pixel.blue;

      hw2reg.reg_pixel_counter_debug.cx.d <= hw2reg_fifo_out.pixel_counter_debug.cx;
      hw2reg.reg_pixel_counter_debug.cy.d <= hw2reg_fifo_out.pixel_counter_debug.cy;
      hw2reg.reg_pixel_counter_debug.is_video_data.d <= hw2reg_fifo_out.pixel_counter_debug.is_video_data;
      hw2reg.reg_pixel_counter_debug.is_hdmi.d <= hw2reg_fifo_out.pixel_counter_debug.is_hdmi;
      hw2reg.reg_pixel_counter_debug.guessed_polarity.d <= hw2reg_fifo_out.pixel_counter_debug.guessed_polarity;

      hw2reg.reg_channel_deskew_debug.valid.d <= hw2reg_fifo_out.channel_deskew_debug.valid;
      hw2reg.reg_channel_deskew_debug.offset_r.d <= hw2reg_fifo_out.channel_deskew_debug.offset_r;
      hw2reg.reg_channel_deskew_debug.offset_g.d <= hw2reg_fifo_out.channel_deskew_debug.offset_g;
      hw2reg.reg_channel_deskew_debug.offset_b.d <= hw2reg_fifo_out.channel_deskew_debug.offset_b;
      hw2reg.reg_channel_deskew_debug.de.d <= hw2reg_fifo_out.channel_deskew_debug.de;
      hw2reg.reg_channel_deskew_debug.error_count.d <= hw2reg_fifo_out.channel_deskew_debug.error_count;

      hw2reg.reg_framebuffers_status.valid_frames.d <= hw2reg_fifo_out.framebuffers_status.valid_frames;
      hw2reg.reg_framebuffers_status.width.d <= hw2reg_fifo_out.framebuffers_status.width;
      hw2reg.reg_framebuffers_status.height.d <= hw2reg_fifo_out.framebuffers_status.height;
      hw2reg.reg_framebuffers_status.format.d <= hw2reg_fifo_out.framebuffers_status.format;

      hw2reg.reg_clock_status.sys_clk_counter.d <= sys_clk_counter;
      hw2reg.reg_clock_status.pclk_counter.d <= hw2reg_fifo_out.pclk_counter;
    end
    hw2reg.reg_clock_status.locked.d <= locked_sync;
  end
end

//DEs
//---

assign hw2reg.reg_pipeline_debug_pixel.red.de = '1;
assign hw2reg.reg_pipeline_debug_pixel.green.de = '1;
assign hw2reg.reg_pipeline_debug_pixel.blue.de = '1;

assign hw2reg.reg_debug_pixel.red.de = '1;
assign hw2reg.reg_debug_pixel.green.de = '1;
assign hw2reg.reg_debug_pixel.blue.de = '1;

assign hw2reg.reg_pixel_counter_debug.cx.de = '1;
assign hw2reg.reg_pixel_counter_debug.cy.de = '1;
assign hw2reg.reg_pixel_counter_debug.is_video_data.de = '1;
assign hw2reg.reg_pixel_counter_debug.is_hdmi.de = '1;
assign hw2reg.reg_pixel_counter_debug.guessed_polarity.de = '1;

assign hw2reg.reg_channel_deskew_debug.valid.de = '1;
assign hw2reg.reg_channel_deskew_debug.offset_r.de = '1;
assign hw2reg.reg_channel_deskew_debug.offset_g.de = '1;
assign hw2reg.reg_channel_deskew_debug.offset_b.de = '1;
assign hw2reg.reg_channel_deskew_debug.de.de = '1;
assign hw2reg.reg_channel_deskew_debug.error_count.de = '1;

//assign hw2reg.reg_framebuffers_status.valid_frames.de = '1;
//assign hw2reg.reg_framebuffers_status.width.de = '1;
//assign hw2reg.reg_framebuffers_status.height.de = '1;
//assign hw2reg.reg_framebuffers_status.format.de = '1;

//assign hw2reg.reg_clock_status.locked.de = '1;
//assign hw2reg.reg_clock_status.pclk_counter.de = '1;
//assign hw2reg.reg_clock_status.sys_clk_counter.de = '1;

generate
  for (genvar i = 0; i < 3; i = i + 1) begin
    assign hw2reg.reg_pipeline_debug[i].valid.de = '1;
    assign hw2reg.reg_pipeline_debug[i].delay.de = '1;
    assign hw2reg.reg_pipeline_debug[i].quality.de = '1;
    assign hw2reg.reg_tmds_debug[i].last_valid.de = '1;
    assign hw2reg.reg_tmds_debug[i].last_invalid.de = '1;
  end
endgenerate

endmodule
