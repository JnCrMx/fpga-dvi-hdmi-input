module dvi_in_pipeline (
  input logic rst_ps,

  input logic tmds_in,

  input logic pclk1x,
  input logic pclk5x,

  output logic [9:0] tmds_symbol,
  output logic [7:0] channel_data,
  output logic [1:0] control_data,
  output logic de,

  output dvi_in_pkg::pipeline_debug_t debug_o,
  input dvi_in_pkg::pipeline_debug_ctrl_t debug_ctrl_i
);

logic [9:0] tmds_symbol_raw;

logic [9:0] lastinv;
logic bitslip;
logic bitslip_effective;
logic valid;
logic [4:0] delay;
logic [4:0] delay_effective;

always_comb begin
  if(debug_ctrl_i.override) begin
    delay_effective = debug_ctrl_i.delay;
    bitslip_effective = debug_ctrl_i.bitslip;
  end else begin
    delay_effective = delay;
    bitslip_effective = bitslip;
  end
end


logic [27:0] error_counter;
assign debug_o.quality = error_counter[27:2];

always_ff @(posedge pclk1x) begin
  if(rst_ps) begin
    debug_o.pixel_value <= 0;
  end else begin
    if(de) begin
      debug_o.pixel_value <= channel_data;
    end
  end
end

assign debug_o.valid = valid;
assign debug_o.delay = delay;

//Deserializer
//-------------
dvi_in_deserializer dvi_in_des (
   .rst_ps,
   .pclk1x,
   .pclk5x,

   .delay(delay_effective),
   .bitslip(bitslip_effective),

   .in(tmds_in),
   .out(tmds_symbol_raw)
);

`ifdef MODEL_TECH
  function logic [9:0] rotate_vector(
      input logic [9:0] vector,
      input int unsigned positions
  );
      logic [9:0] result;
      begin
          positions = positions % 10;

          // Rotate left
          result = (vector << positions) | (vector >> (10 - positions));
          
          return result;
      end
  endfunction
  assign tmds_symbol = rotate_vector({<<{tmds_symbol_raw}}, 7);
`else
  assign tmds_symbol = tmds_symbol_raw;
`endif

//Delay Control
//-------------
dvi_in_delay_ctrl dvi_in_delayctrl (
  .rst_ps,
  .pclk1x,
  .valid,
  .delay,
  .bitslip,
  .increment(debug_ctrl_i.delay_increment),
  .error_counter
);

//TMDS Decoder
//------------
tmds_decoder tmds_decoder (
  .tmds_symbol,
  .valid,
  .channel_data(channel_data),
  .c(control_data),
  .de
);

always_ff @(posedge pclk1x) begin 
  if(rst_ps) begin
    debug_o.last_valid_tmds <= '0;
    debug_o.last_invalid_tmds <= '0;
  end else begin
    if(valid) begin
      debug_o.last_valid_tmds <= tmds_symbol;
    end else begin
      debug_o.last_invalid_tmds <= tmds_symbol;
    end
  end
end

endmodule
