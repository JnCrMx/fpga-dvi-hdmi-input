module dvi_in_reset_ctrl(
  input logic rst_request,
  input logic pclk1x,

  input logic locked,

  output logic rst
);

logic [7:0] reset_counter;

always_ff @(posedge pclk1x) begin
    if (rst_request || ~locked) begin
        reset_counter <= 8'hff;
        rst <= '1;
    end else begin
        if (reset_counter != 0) begin
            reset_counter <= reset_counter - 1;
            rst <= '1;
        end else begin
            rst <= '0;
        end
    end
end

endmodule
