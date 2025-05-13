module dvi_in_channel_deskew (
    input logic pclk1x,
    input logic rst_ps,

    input logic [7:0] channel_data_i[3],
    input logic [1:0] control_data_i[3],
    input logic [9:0] tmds_symbol_i[3],
    input logic de_i[3],

    output logic [7:0] channel_data_o[3],
    output logic [1:0] control_data_o[3],
    output logic [9:0] tmds_symbol_o[3],
    output logic de_o[3],

    output dvi_in_pkg::channel_deskew_debug_t debug_o,
    input dvi_in_pkg::channel_deskew_debug_ctrl_t debug_ctrl_i
);

logic [1:0] channel_delay[3];
logic [1:0] channel_delay_effective[3];

logic [7:0] channel_data_buffer[3][3];
logic [1:0] control_data_buffer[3][3];
logic [9:0] tmds_symbol_buffer[3][3];
logic de_buffer[3][3];

assign debug_o.valid = 0;
assign debug_o.offset_r = channel_delay[2];
assign debug_o.offset_g = channel_delay[1];
assign debug_o.offset_b = channel_delay[0];

always_comb begin
  if(debug_ctrl_i.override)begin
    channel_delay_effective[2] <= debug_ctrl_i.offset_r;
    channel_delay_effective[1] <= debug_ctrl_i.offset_g;
    channel_delay_effective[0] <= debug_ctrl_i.offset_b;
  end else begin
    channel_delay_effective <= channel_delay;
  end
end

always_comb begin
    for (int i = 0; i < 3; i++) begin
        channel_data_o[i] = channel_data_buffer[channel_delay_effective[i]][i];
        control_data_o[i] = control_data_buffer[channel_delay_effective[i]][i];
        tmds_symbol_o[i] = tmds_symbol_buffer[channel_delay_effective[i]][i];
        de_o[i] = de_buffer[channel_delay_effective[i]][i];
    end
end

logic [0:2] de_edge_0;
logic [0:2] de_edge_1;

assign de_edge_0[0] = de_buffer[0][0] == 1 && de_buffer[1][0] == 0;
assign de_edge_1[0] = de_buffer[1][0] == 1 && de_buffer[2][0] == 0;

assign de_edge_0[1] = de_buffer[0][1] == 1 && de_buffer[1][1] == 0;
assign de_edge_1[1] = de_buffer[1][1] == 1 && de_buffer[2][1] == 0;

assign de_edge_0[2] = de_buffer[0][2] == 1 && de_buffer[1][2] == 0;
assign de_edge_1[2] = de_buffer[1][2] == 1 && de_buffer[2][2] == 0;

always_ff @(posedge pclk1x) begin
    if(rst_ps) begin
        for (int i = 0; i < 3; i++) begin
            channel_delay[i] <= 0;
            channel_data_buffer[i] <= '{default: 0};
        end
    end else begin
        // shift values
        channel_data_buffer[2] <= channel_data_buffer[1];
        channel_data_buffer[1] <= channel_data_buffer[0];
        channel_data_buffer[0] <= channel_data_i;

        control_data_buffer[2] <= control_data_buffer[1];
        control_data_buffer[1] <= control_data_buffer[0];
        control_data_buffer[0] <= control_data_i;

        tmds_symbol_buffer[2] <= tmds_symbol_buffer[1];
        tmds_symbol_buffer[1] <= tmds_symbol_buffer[0];
        tmds_symbol_buffer[0] <= tmds_symbol_i;

        de_buffer[2] <= de_buffer[1];
        de_buffer[1] <= de_buffer[0];
        de_buffer[0] <= de_i;
        // calculate delay
        
        /*
           0 1 2
        R  1 0 0
        G  0 0 0
        B  0 0 0
        => R is too fast

           0 1 2
        R  1 0 0
        G  1 0 0
        B  0 0 0
        => R is too fast
        => G is too fast

           0 1 2
        R  1 0 0
        G  1 1 0
        B  1 1 0
        => G is too fast
        => B is too fast
        */
        if(de_edge_0[0]) begin
            if(de_edge_1[1] || de_edge_1[2]) begin
                channel_delay[0] <= 0;
                channel_delay[1] <= 0;
                channel_delay[2] <= 0;
                if(de_edge_1[1]) begin
                    channel_delay[1] <= 1;
                end
                if(de_edge_1[2]) begin
                    channel_delay[2] <= 1;
                end
            end else if(~de_edge_0[1] || ~de_edge_0[2]) begin
                channel_delay[0] <= 1;
                channel_delay[1] <= 0;
                channel_delay[2] <= 0;
                if(de_edge_0[1]) begin
                    channel_delay[1] <= 1;
                end
                if(de_edge_0[2]) begin
                    channel_delay[2] <= 1;
                end
            end else if(de_edge_0[1] && de_edge_0[2]) begin
                channel_delay[0] <= 0;
                channel_delay[1] <= 0;
                channel_delay[2] <= 0;
            end
        end
    end
end

assign debug_o.de[0] = de_o[0];
assign debug_o.de[1] = de_o[1];
assign debug_o.de[2] = de_o[2];
always_ff @(posedge pclk1x) begin
    if(rst_ps) begin
        debug_o.error_count <= 0;
    end else begin
        if(de_o[0] == de_o[1] && de_o[1] == de_o[2]) begin
            if(debug_o.error_count != 0) begin
                //debug_o.error_count <= debug_o.error_count - 1;
            end
        end else begin
            debug_o.error_count <= debug_o.error_count + 1;
        end
    end
end

endmodule
