module example (
  input logic clk_i,
  input logic clk_200_i,
  input logic rst_ni,

  input  top_pkg::userio_board2fpga_t userio_i,
  output top_pkg::userio_fpga2board_t userio_o,

  output logic irq_o,

  input  tlul_pkg::tl_h2d_t tl_device_peri_i,
  output tlul_pkg::tl_d2h_t tl_device_peri_o,
  input  tlul_pkg::tl_h2d_t tl_device_fast_i,
  output tlul_pkg::tl_d2h_t tl_device_fast_o,

  input  tlul_pkg::tl_d2h_t tl_host_i,
  output tlul_pkg::tl_h2d_t tl_host_o
);


  localparam int NUM_MUX = 5;
  localparam int IRQ_MAX = 32;

  tlul_pkg::tl_d2h_t tl_device_o [NUM_MUX-1:0];
  tlul_pkg::tl_h2d_t tl_device_i [NUM_MUX-1:0];

  logic [IRQ_MAX-1:0] irq_i;

  logic [7:0] led;
  logic hdmi_rx_sda_oe;
  logic hdmi_rx_hpa;
  logic hdmi_rx_txen;
  logic hdmi_rx_cec_oe;
  assign userio_o = '{
    led: led,
    hdmi_rx_sda_oe: hdmi_rx_sda_oe,
    hdmi_rx_hpa: hdmi_rx_hpa,
    hdmi_rx_txen: hdmi_rx_txen,
    hdmi_rx_cec_oe: hdmi_rx_cec_oe,
    default: '0
  };

  tlul_mux #(.NUM(NUM_MUX)) tlul_mux_i (
    .clk_i,
    .rst_ni,
    .tl_device_o,
    .tl_device_i,
    .tl_host_o (tl_device_peri_o),
    .tl_host_i (tl_device_peri_i)
  );

  irq_ctrl #(.IRQ_MAX(IRQ_MAX)) irq_ctrl_i
  (
    .clk_i,
    .rst_ni,
    .tl_o (tl_device_o[0]),
    .tl_i (tl_device_i[0]),
    .irq_i,
    .irq_o
  );

  dvi_in_top dvi_in (
    .clk_i,
    .clk_200_i,
    .rst_ni,
    .irq_valid_frames(irq_i[3:2]),
    .irq_pll_locked(irq_i[4]),
    .irq_pll_lost(irq_i[5]),
    .tmds_channel(userio_i.hdmi_rx),
    .tmds_clk(userio_i.hdmi_rx_clk),
    .sda(userio_i.hdmi_rx_sda),
    .sda_oe(hdmi_rx_sda_oe),
    .scl(userio_i.hdmi_rx_scl),
    .hpa(hdmi_rx_hpa),
    .txen(hdmi_rx_txen),
    .cec_oe(hdmi_rx_cec_oe),
    .tl_registers_i(tl_device_i[3]),
    .tl_registers_o(tl_device_o[3]),
    .tl_edid_i(tl_device_i[4]),
    .tl_edid_o(tl_device_o[4]),
    .tl_framebuffer_i(tl_device_fast_i),
    .tl_framebuffer_o(tl_device_fast_o)
  );

endmodule
