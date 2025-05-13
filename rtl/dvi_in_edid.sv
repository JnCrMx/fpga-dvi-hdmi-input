/*
Copyright (c) 2015, Takeshi Matsuya <macchan@sfc.wide.ad.jp>
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met: 

1. Redistributions of source code must retain the above copyright notice,
   this list of conditions and the following disclaimer. 
2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution. 

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS AS IS AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

The views and conclusions contained in the software and documentation are those
of the authors and should not be interpreted as representing official policies, 
either expressed or implied, of the FreeBSD Project.
*/
//`include ../../../boards/atlys/rtl/setup.v

module dvi_in_edid
(
`ifdef DEBUG
	input wire [7:0] switch,
	output wire [7:0] led,
`endif
	input wire clk_i,
	input wire rst_ni,
	input wire scl,
	input wire sda_i,
        output wire sda_o,
        output wire oe,

        input  tlul_pkg::tl_h2d_t tl_i,
        output tlul_pkg::tl_d2h_t tl_o
);

wire sda;
logic [7:0] dout;

reg         hiz = 1'b1;
reg         sda_out  = 1'b0;
reg [4:0]   count = 5'd0;
reg [15:0]  rdata = 24'h0;
reg [7:0]   addr = 8'h0;
reg [7:0]   data = 8'h0;
parameter   EDID_IDLE     = 3'b000;
parameter   EDID_ADDR     = 3'b001;
parameter   EDID_ADDR_ACK = 3'b010;
parameter   EDID_ADDR_ACK2= 3'b011;
parameter   EDID_DATA     = 3'b100;
parameter   EDID_DATA_ACK = 3'b101;
parameter   EDID_DATA_ACK2= 3'b110;
reg [2:0]   edid_state = EDID_IDLE;
reg [3:0]   scl_data = 4'h00;
reg [3:0]   sda_data = 4'h00;
`ifdef DEBUG
reg [7:0]   led_r [0:255];
reg [7:0]   led_count = 8'h00;
`endif

reg [31:0] ram [0:63];

  logic        tlul_req;
  logic        tlul_we;
  logic [5:0]  tlul_addr;
  logic [31:0] tlul_wdata;
  logic [31:0] tlul_wmask;
  logic [31:0] tlul_rdata;
  logic        tlul_rvalid;

  localparam int AddrWidth = 6;


  tlul_adapter_sram #(
    .SramAw     (AddrWidth),
    .SramDw     (32),
    .Outstanding(1)
  ) adapter_i (
    .clk_i,
    .rst_ni,

    .tl_i,
    .tl_o,

    .req_o   (tlul_req),
    .gnt_i   (1'b1),    // Always grant as only one requester exists
    .we_o    (tlul_we),
    .addr_o  (tlul_addr),
    .wdata_o (tlul_wdata),
    .wmask_o (tlul_wmask),
    .rdata_i (tlul_rdata),
    .rvalid_i(tlul_rvalid),
    .rerror_i(2'b00)
  );

wire        scl_posedge, scl_negedge, scl_high;
assign scl_posedge = (scl_data == 4'b0111);
assign scl_negedge = (scl_data == 4'b1000);
assign scl_high    = (scl_data == 4'b1111);

assign oe = ~hiz;
assign sda_o = sda_out;
assign sda = sda_i;


  always @(posedge clk_i) begin
    tlul_rdata <= '0;
    if (tlul_req) begin
      if (tlul_we) begin
        // Write access:
        if (tlul_wmask[0]) ram[tlul_addr][7:0] <= tlul_wdata[7:0];
        if (tlul_wmask[8]) ram[tlul_addr][15:8] <= tlul_wdata[15:8];
        if (tlul_wmask[16]) ram[tlul_addr][23:16] <= tlul_wdata[23:16];
        if (tlul_wmask[24]) ram[tlul_addr][31:24] <= tlul_wdata[31:24];
      end

      // Read access:
      tlul_rdata <= ram[tlul_addr];
    end
    case(addr[1:0])
      2'b00: dout[7:0] <= ram[addr[7:2]][7:0];
      2'b01: dout[7:0] <= ram[addr[7:2]][15:8];
      2'b10: dout[7:0] <= ram[addr[7:2]][23:16];
      2'b11: dout[7:0] <= ram[addr[7:2]][31:24];
    endcase
  end

  always @(posedge clk_i, negedge rst_ni) begin
    if (!rst_ni) begin
      tlul_rvalid <= '0;
    end else begin
      tlul_rvalid <= (tlul_req && !tlul_we);
    end
  end

always @(posedge clk_i) begin
	if (~rst_ni) begin
		hiz <= 1'b1;
		sda_out <= 1'b0;
		count <= 5'd0;
		rdata <= 24'h0;
		addr <= 8'h0;
		data <= 8'h0;
		scl_data <= 4'h00;
		sda_data <= 4'h00;
	end else begin
		scl_data <= {scl_data[2:0], scl};
		sda_data <= {sda_data[2:0], sda};

		if (sda_data == 4'b1000 && scl_high) begin		// Start
			count <= 5'd0;
			hiz <= 1'b1;
			sda_out <= 1'b0;
			edid_state <= EDID_ADDR;
		end else if (sda_data == 4'b0111 && scl_high) begin	// Stop
			edid_state <= EDID_IDLE;
		end else
		case (edid_state)
		EDID_IDLE: begin
			hiz <= 1'b1;
			sda_out <= 1'b0;
		end
		EDID_ADDR: begin
			if (scl_posedge) begin
				count <= count + 5'd1;
				rdata  <= {rdata[14:0], sda};
				if (count[2:0] == 3'd7) begin
`ifdef DEBUG
if (led_count != 8'd255)
led_count <= led_count + 8'd1;
led_r[ led_count ] <= {rdata[6:0], sda};
`endif
					if (count == 5'd15)
						addr <= {rdata[6:0],sda};
					edid_state <= EDID_ADDR_ACK;
				end
			end
		end
		EDID_ADDR_ACK: begin
			if (scl_negedge) begin
				hiz <= 1'b0;
				sda_out <= 1'b0;
				if (count == 5'd8 && rdata [0] == 1'b1) begin
					data <= dout;
					edid_state <= EDID_DATA;
				end else begin
					edid_state <= EDID_ADDR_ACK2;
				end
			end
		end
		EDID_ADDR_ACK2: begin
			if (scl_negedge) begin
				hiz <= 1'b1;
				edid_state <= EDID_ADDR;
			end
		end
		EDID_DATA: begin
			if (scl_negedge) begin
				count <= count + 5'd1;
				hiz <= 1'b0;
				sda_out <= data[7];
				data <= {data[6:0], 1'b0};
				if (count[2:0] == 3'd7) begin
`ifdef 	DEBUG
if (led_count != 8'd255)
led_count <= led_count + 8'd1;
led_r[ led_count ] <= dout;
`endif
					addr <= addr + 8'h1;
					edid_state <= EDID_DATA_ACK;
				end
			end
		end
		EDID_DATA_ACK: begin
			if (scl_negedge) begin
				data <= dout;
				hiz <= 1'b1;
				sda_out <= 1'b0;
				edid_state <= EDID_DATA_ACK2;
			end
		end
		EDID_DATA_ACK2: begin
			if (scl_posedge) begin
				if (sda)
					edid_state <= EDID_IDLE;
				else
					edid_state <= EDID_DATA;
			end
		end
                default: edid_state <= EDID_IDLE;
		endcase
	end
end

//assign sda = hiz ? 1'hz : sda_out;
`ifdef DEBUG
assign led = led_r[switch];
`endif

endmodule
