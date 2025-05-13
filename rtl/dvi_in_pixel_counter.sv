module dvi_in_pixel_counter (
    input logic pclk1x,
    input logic rst_ps,

    input logic [7:0] channel_data[3],
    input logic [1:0] control_data[3],
    input logic [9:0] tmds_symbol[3],
    input logic de[3],
    input dvi_in_pkg::pixel_counter_debug_ctrl_t debug_ctrl_i,

    output logic [7:0] red,
    output logic [7:0] green,
    output logic [7:0] blue,
    output logic is_video_data,
    output logic row_complete,
    output logic frame_complete,
    output logic [11:0] cx,
    output logic [11:0] cy,
    output logic is_hdmi,
    output logic guessed_polarity
);

// used for all modes
logic waiting_for_new_frame;
logic effective_hsync_polarity;
logic effective_vsync_polarity;
logic [2:0] bad_vsync_count;

// used for DVI mode
logic waiting_for_de;
logic had_hdmi_guardband;

// used for HDMI mode
logic waiting_for_video_guard_band;
logic waiting_for_end_of_video_guard_band;
logic skip_first_pixel;

logic is_hdmi_effective;
assign is_hdmi_effective = debug_ctrl_i.override ? debug_ctrl_i.is_hdmi : is_hdmi;
assign effective_hsync_polarity = debug_ctrl_i.override ? debug_ctrl_i.hsync_polarity : guessed_polarity;
assign effective_vsync_polarity = debug_ctrl_i.override ? debug_ctrl_i.vsync_polarity : guessed_polarity;

always_ff @(posedge pclk1x) begin
    red <= 0;
    green <= 0;
    blue <= 0;

    is_video_data <= 0;
    frame_complete <= 0;
    row_complete <= 0;

    if(rst_ps) begin
        // used for all modes
        cx <= 0;
        cy <= 0;
        is_hdmi <= 0;
        waiting_for_new_frame <= 0;
        guessed_polarity <= 0;

        // used for DVI mode
        waiting_for_de <= 0;
        had_hdmi_guardband <= 0;

        // used for HDMI mode
        waiting_for_video_guard_band <= 0;
        waiting_for_end_of_video_guard_band <= 0;
        skip_first_pixel <= 0;
    end else begin
        if(is_hdmi_effective) begin // HDMI specific code
            if(waiting_for_video_guard_band) begin
                if(tmds_symbol[0] == 10'b1011001100 && tmds_symbol[1] == 10'b0100110011 && tmds_symbol[2] == 10'b1011001100) begin
                    cx <= 0;
                    if(waiting_for_new_frame) begin
                        cy <= 0;
                    end
                    skip_first_pixel <= 1;

                    waiting_for_new_frame <= 0;
                    waiting_for_video_guard_band <= 0;
                    waiting_for_end_of_video_guard_band <= 1;
                end
            end else if(waiting_for_end_of_video_guard_band) begin
                waiting_for_end_of_video_guard_band <= 0;
            end else begin
                if(~de[0] && ~de[1] && ~de[2]) begin
                    if(control_data[0][0] == effective_hsync_polarity) begin // HSYNC
                        cx <= cx + 1; // add one, so we get the total width
                        cy <= cy + 1;
                        waiting_for_video_guard_band <= 1;
                        row_complete <= 1;
                    end
                    is_video_data <= 0;
                end else begin
                    // skip first pixel, so we start counting at 0
                    if(skip_first_pixel) begin
                        skip_first_pixel <= 0;
                    end else begin
                        if(cx == '1) begin // if cx overflows (because no HSYNC) we will adjust our polarity guess
                            guessed_polarity <= ~guessed_polarity;
                            bad_vsync_count <= 0;
                        end
                        cx <= cx + 1;
                    end

                    is_video_data <= 1;
                    red <= channel_data[2];
                    green <= channel_data[1];
                    blue <= channel_data[0];
                end
            end

            if(~waiting_for_new_frame) begin
                if(~de[0] && ~de[1] && ~de[2]) begin
                    if(control_data[0][1] == effective_vsync_polarity) begin // VSYNC
                        waiting_for_video_guard_band <= 1;
                        waiting_for_new_frame <= 1;
                        frame_complete <= 1;

                        if(cy < 3) begin
                            if(bad_vsync_count == '1) begin
                                guessed_polarity <= ~guessed_polarity;
                                bad_vsync_count <= 0;
                            end else begin
                                bad_vsync_count <= bad_vsync_count + 1;
                            end
                        end else if(bad_vsync_count != 0) begin
                            bad_vsync_count <= bad_vsync_count - 1;
                        end
                    end
                end
            end
        end else begin // DVI code
            if((waiting_for_de || had_hdmi_guardband) && tmds_symbol[0] == 10'b1011001100 && tmds_symbol[1] == 10'b0100110011 && tmds_symbol[2] == 10'b1011001100) begin
                if(had_hdmi_guardband) begin
                    is_hdmi <= 1;
                    waiting_for_video_guard_band <= 0;
                    had_hdmi_guardband <= 0;
                end else begin
                    had_hdmi_guardband <= 1;
                end
            end else begin
                had_hdmi_guardband <= 0;
            end

            if(~de[0] && ~de[1] && ~de[2]) begin
                if(~waiting_for_de) begin
                    if(control_data[0][0] == effective_hsync_polarity) begin // HSYNC
                        cx <= cx + 1; // add one, so we get the total width
                        cy <= cy + 1;
                        waiting_for_de <= 1;
                        row_complete <= 1;
                    end
                end

                if(~waiting_for_new_frame) begin
                    if(control_data[0][1] == effective_vsync_polarity) begin // VSYNC
                        frame_complete <= 1;
                        waiting_for_de <= 1;
                        waiting_for_new_frame <= 1;

                        if(cy < 3) begin
                            if(bad_vsync_count == '1) begin
                                guessed_polarity <= ~guessed_polarity;
                                bad_vsync_count <= 0;
                            end else begin
                                bad_vsync_count <= bad_vsync_count + 1;
                            end
                        end else if(bad_vsync_count != 0) begin
                            bad_vsync_count <= bad_vsync_count - 1;
                        end
                    end
                end

                is_video_data <= 0;
            end else /*if(de[0] && de[1] && de[2])*/ begin
                cx <= cx + 1;
                is_video_data <= 1;
                red <= channel_data[2];
                green <= channel_data[1];
                blue <= channel_data[0];

                if(waiting_for_de) begin // we are beginning a new row
                    cx <= 0;
                end else if(cx == '1) begin // if cx overflows (because no HSYNC) we will adjust our polarity guess
                    guessed_polarity <= ~guessed_polarity;
                    bad_vsync_count <= 0;
                end
                if(waiting_for_new_frame) begin // we are beginning a new frame
                    cy <= 0;
                end

                waiting_for_de <= 0;
                waiting_for_new_frame <= 0;
            end
        end
    end
end

endmodule