module dvi_in_delay_ctrl (
    input logic rst_ps,
    input logic pclk1x,

    input logic valid,

    output logic [4:0] delay,
    output logic bitslip,
    output logic [27:0] error_counter,

    input logic [3:0] increment
);
  localparam int ERROR_INCREMENT = 28'h200000;
  localparam int ERROR_DECREMENT = 1;

  logic [9:0] cooldown;

  always_ff @(posedge pclk1x, posedge rst_ps) begin
    bitslip <= 0;
    if (rst_ps) begin
      delay <= 5'b0;
      bitslip <= 0;
      cooldown <= 0;
      error_counter <= 0;
    end else if (cooldown == 0) begin
      if (~valid) begin
        error_counter <= error_counter + ERROR_INCREMENT;
      end else begin
        if (error_counter >= ERROR_DECREMENT) begin
          error_counter <= error_counter - ERROR_DECREMENT;
        end
      end
      if (~valid && error_counter[27:24] == '1) begin
        if (delay == '1) begin
          bitslip <= 1;
        end
        delay <= delay + increment;
        cooldown <= '1;
        error_counter[27:24] <= 4'b0100;
      end
    end else begin
      cooldown <= cooldown - 1;
    end
  end

endmodule
