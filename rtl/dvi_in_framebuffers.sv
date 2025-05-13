module dvi_in_framebuffers #(parameter int WIDTH = 800, parameter int HEIGHT = 600, parameter int ADDR_WIDTH = 18)(
    input logic clk_i,
    input logic rst_ni,
    input logic pclk1x,
    input logic rst_ps,

    input logic [7:0] red,
    input logic [7:0] green,
    input logic [7:0] blue,

    input logic is_video_data,
    input logic row_complete,
    input logic frame_complete,
    input logic [11:0] cx,
    input logic [11:0] cy,

    output dvi_in_pkg::framebuffers_status_t framebuffers_status_o,
    input dvi_in_pkg::framebuffers_control_t framebuffers_control_i,
 
    input  tlul_pkg::tl_h2d_t tl_i,
    output tlul_pkg::tl_d2h_t tl_o
);

//ADDR_WIDTH = log2((WIDTH*HEIGHT)/2)
logic fb_we;  
logic fb_select; 
logic [ADDR_WIDTH+1:0] fb_addr;
logic [1:0] fb_overflow;
logic [1:0] fb_valid;   
logic [1:0] fb_locked;
logic high_res;
logic double_colordepth;

logic [31:0] ram_word; 
logic ram_we;
logic [ADDR_WIDTH-1:0] ram_addr;

logic [3:0] skip_row;
logic [3:0] skip_column;

logic rst_active;

localparam fb1_addr_start = 0;
localparam fb1_addr_stop = ((WIDTH*HEIGHT)/4)-1;
localparam fb2_addr_start = ((WIDTH*HEIGHT)/4);
localparam fb2_addr_stop = ((WIDTH*HEIGHT)/2)-1;

assign framebuffers_status_o.valid_frames = fb_valid;
assign framebuffers_status_o.format = (double_colordepth) ? 6'b000001 : 6'b000000;
assign fb_locked = framebuffers_control_i.lock;

logic        tlul_req;
logic        tlul_we;
logic [ADDR_WIDTH-1:0]  tlul_addr;
logic [31:0] tlul_wdata;
logic [31:0] tlul_wmask;
logic [31:0] tlul_rdata;
logic        tlul_rvalid;

tlul_adapter_sram #(
  .SramAw     (ADDR_WIDTH),
  .SramDw     (32),
  .Outstanding(1)
) adapter_i (
  .clk_i,
  .rst_ni,

  .tl_i,
  .tl_o,

  .req_o   (tlul_req),
  .gnt_i   (1'b1),
  .we_o    (tlul_we),
  .addr_o  (tlul_addr),
  .wdata_o (tlul_wdata),
  .wmask_o (tlul_wmask),
  .rdata_i (tlul_rdata),
  .rvalid_i(tlul_rvalid),
  .rerror_i(2'b00)
);

rams_tdp_rf_rf #(.WIDTH(WIDTH), .HEIGHT(HEIGHT), .ADDR_WIDTH(ADDR_WIDTH)) framebuffer_ram (
  .clka(clk_i),
  .clkb(pclk1x),
  .ena(tlul_req),
  .enb('1),
  .wea(tlul_we),
  .web(ram_we),
  .addra(tlul_addr),
  .addrb(ram_addr),
  .dia(tlul_wdata),
  .dib(ram_word),
  .doa(tlul_rdata),
  .dob()
);

always @(posedge clk_i, negedge rst_ni) begin
  if (~rst_ni) begin
    tlul_rvalid <= '0;
  end else begin
    tlul_rvalid <= (tlul_req && !tlul_we);
  end
end

always_ff @(posedge pclk1x, posedge rst_ps) begin
  ram_we <= '0;

  //reset
  if (rst_ps) begin                  
    rst_active <= '1;
    fb_we <= '0;
    fb_addr <= '0;
    fb_overflow <= '0;
    fb_valid <= '0;
    fb_select <= '1;
    ram_word <= '0;
    ram_we <= '0;
    ram_addr <= '0;
    skip_column <= '0;
    skip_row <= '0;
    framebuffers_status_o.width <= '0;
    framebuffers_status_o.height <= '0;
    double_colordepth <= '0;
    high_res <= '0;

  //write frame to framebuffer (video data comes in and skips are 0)
  end else if (is_video_data && !rst_active && fb_we) begin
    if (skip_column == 0 && skip_row == 0) begin

      //8-bit color or 16-bit color
      if (double_colordepth) begin
        case (fb_addr[1]) //rgb565
          1'b0: ram_word[15:0] <= {red[7:3], green[7:2], blue[7:3]};
          1'b1: ram_word[31:16] <= {red[7:3], green[7:2], blue[7:3]};
        endcase
      end else begin
        case (fb_addr[1:0]) //rgb332
          2'b00: ram_word[7:0] <= {red[7:5], green[7:5], blue[7:6]};
          2'b01: ram_word[15:8] <= {red[7:5], green[7:5], blue[7:6]};
          2'b10: ram_word[23:16] <= {red[7:5], green[7:5], blue[7:6]};
          2'b11: ram_word[31:24] <= {red[7:5], green[7:5], blue[7:6]};
        endcase
      end

      ram_we <= '1;
      fb_valid[fb_select] <= 0;
      fb_overflow[fb_select] <= 0;

      //turn framebuffer off when ram is full
      if (double_colordepth || high_res) begin
        if (ram_addr == fb2_addr_stop) begin
          ram_we <= '0;
          fb_we <= '0;
        end
      end else begin
        if (ram_addr == fb1_addr_stop && ~fb_select || ram_addr == fb2_addr_stop && fb_select) begin
          ram_we <= '0;
          fb_we <= '0;
        end
      end

      //calc ram address
      case (fb_select)
        1'b0: ram_addr[ADDR_WIDTH-1:0] <= fb_addr[ADDR_WIDTH+1:2];
        1'b1: ram_addr[ADDR_WIDTH-1:0] <= fb2_addr_start + fb_addr[ADDR_WIDTH:2];
      endcase

      //calc new fb address
      if (double_colordepth) fb_addr <= fb_addr + 2'b10;
      else fb_addr <= fb_addr + 1'b1;
      
      //skip column
      skip_column <= framebuffers_control_i.skip_column;
    end else skip_column <= skip_column - 1;

  //detect overflow (ram is full, but video data still comes in (or both of framebuffers are locked and video data comes in)
  end else if (~fb_we && is_video_data) fb_overflow[fb_select] <= 1'b1;
  
  else begin

    //skip row
    if (row_complete) begin
      skip_column <= '0;
      if (skip_row == 0) begin
        skip_row <= framebuffers_control_i.skip_row;
      end else begin
        skip_row <= skip_row - 1;
      end
    end

    //frame complete
    if (frame_complete) begin

      //reset signals to capture new frame
      rst_active <= '0;
      fb_we <= '1;
      fb_valid[fb_select] <= 1;
      fb_addr <= '0;
      ram_addr <= '0;
      skip_row <= '0;
      skip_column <= '0;
      
      //get new control input
      high_res <= framebuffers_control_i.high_res;
      double_colordepth <= framebuffers_control_i.double_colordepth;
      
      //set status output
      framebuffers_status_o.width <= cx;
      framebuffers_status_o.height <= cy;

      //select new framebuffer based on locked and mode
      if (high_res || double_colordepth) begin
        fb_select <= '0;
        fb_valid[1] <= 0;
        if (fb_locked[0]) fb_we <= '0;
      end else begin
        fb_select <= ~fb_select;
        if (fb_locked == 2'b11 && fb_valid[~fb_select]) fb_we <= '0;
        else if (~fb_locked[fb_select] && fb_locked[~fb_select]) fb_select <= fb_select; 
      end
    end
  end
end

endmodule

// modified RAM instantiation template
// Dual-Port Block RAM with Two Write Ports
// File: rams_tdp_rf_rf.v
module rams_tdp_rf_rf #(parameter int WIDTH = 800, parameter int HEIGHT = 600, parameter int ADDR_WIDTH = 18)
(clka, clkb, ena, enb, wea, web, addra, addrb, dia, dib, doa, dob);

input clka, clkb, ena, enb, wea, web;
input [ADDR_WIDTH-1:0] addra, addrb;
input [31:0] dia, dib;
output [31:0] doa, dob;
reg [31:0] ram [((HEIGHT*WIDTH)/2)-1:0];
reg [31:0] doa, dob;

always @(posedge clka) begin
  if (ena) begin
    if (wea) ram[addra] <= dia;
    doa <= ram[addra];
  end
end

always @(posedge clkb) begin
  if (enb) begin
    if (web) ram[addrb] <= dib;
    dob <= ram[addrb];
  end
end

endmodule 
