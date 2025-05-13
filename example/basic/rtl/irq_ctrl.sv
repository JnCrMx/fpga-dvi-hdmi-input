module irq_ctrl #(
    parameter int IRQ_MAX = 32
) (
    input logic clk_i,
    input logic rst_ni,

    output tlul_pkg::tl_d2h_t tl_o,
    input  tlul_pkg::tl_h2d_t tl_i,

    input  logic [IRQ_MAX-1:0] irq_i,
    output logic irq_o
);

  import irq_ctrl_reg_pkg::*;

  irq_ctrl_reg2hw_t reg2hw;
  irq_ctrl_hw2reg_t hw2reg;

  irq_ctrl_reg_top irq_ctrl_reg
  (
    .clk_i,
    .rst_ni,
    .tl_i,
    .tl_o,
    .reg2hw,
    .hw2reg,
    .devmode_i('1)
  );

  logic [IRQ_MAX-1:0] irq_masked;
  logic [IRQ_MAX-1:0] irq_in;

  assign irq_in = (reg2hw.test.q == '1) ? reg2hw.test_irq.q : irq_i;
  assign irq_masked = irq_in & reg2hw.mask.q;
  assign hw2reg.status.de = '1;
  assign hw2reg.status.d = irq_in;
  assign hw2reg.irq_no.de = '1;
  assign irq_o = (irq_masked != '0 && reg2hw.all_en.q == '1) ? '1 : '0;

  always_comb begin
    hw2reg.irq_no.d = IRQ_MAX;
    for (int i = 0; i < IRQ_MAX; i++) begin //prio
      if (irq_masked[i]) begin
        hw2reg.irq_no.d = i;
        break;
      end
    end
  end

  always_ff @(posedge clk_i, negedge rst_ni) begin
    if (~rst_ni) begin
    end else begin
      hw2reg.mask.de <= '0;
      if (reg2hw.mask_clr.qe == '1) begin //clear bit in mask after sw has written
        hw2reg.mask.de <= '1;
        hw2reg.mask.d <= reg2hw.mask.q;
        hw2reg.mask.d[reg2hw.mask_clr.q] <= 0;
      end
      if (reg2hw.mask_set.qe == '1) begin  //set bit in mask after sw has written
        hw2reg.mask.de <= '1;
        hw2reg.mask.d <= reg2hw.mask.q;
        hw2reg.mask.d[reg2hw.mask_set.q] <= 1;
      end
    end
  end

endmodule
