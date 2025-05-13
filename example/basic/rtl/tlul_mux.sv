module tlul_mux #(
    parameter int NUM = 2
) (
    input logic clk_i,
    input logic rst_ni,

    output tlul_pkg::tl_d2h_t tl_host_o,
    input  tlul_pkg::tl_h2d_t tl_host_i,

    input  tlul_pkg::tl_d2h_t tl_device_o [NUM-1:0],
    output tlul_pkg::tl_h2d_t tl_device_i [NUM-1:0]
);

  logic [3:0] selected_device;
  assign selected_device = tl_host_i.a_address[23:20];

  always_comb begin
    tl_host_o = '0;
    for (int i = 0; i < NUM; i++) begin
      tl_device_i[i] = '0;
    end

    if (selected_device < NUM) begin
      tl_device_i[selected_device] = tl_host_i;
      tl_host_o = tl_device_o[selected_device];
    end

    for(int i=0; i<NUM; i++) begin
      if(tl_device_o[i].d_valid) begin
        tl_host_o = tl_device_o[i];
        tl_device_i[i] = tl_host_i;
        break;
      end
    end
  end

endmodule
