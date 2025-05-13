module dvi_in_deserializer (
    input logic rst_ps,
    input logic pclk1x,
    input logic pclk5x,

    input logic [4:0] delay,
    input logic bitslip,

    input logic in,
    output logic [9:0] out
);

logic in_delayed;
logic [1:0] iserdesshift;


//IDELAY
//------

(* IODELAY_GROUP = "dvi_in_delay_group" *)
IDELAYE2 #(
     .CINVCTRL_SEL("FALSE"),          // Enable dynamic clock inversion (FALSE, TRUE)
     .DELAY_SRC("IDATAIN"),           // Delay input (IDATAIN, DATAIN)
     .HIGH_PERFORMANCE_MODE("TRUE"), // Reduced jitter ("TRUE"), Reduced power ("FALSE")
     .IDELAY_TYPE("VAR_LOAD"),           // FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
     .IDELAY_VALUE(0),                // Input delay tap setting (0-31)
     .PIPE_SEL("FALSE"),              // Select pipelined mode, FALSE, TRUE
     .REFCLK_FREQUENCY(200.0),        // IDELAYCTRL clock input frequency in MHz (190.0-210.0, 290.0-310.0).
     .SIGNAL_PATTERN("DATA")          // DATA, CLOCK input signal
    )
IDELAYE2_inst (
     .CNTVALUEOUT(), // 5-bit output: Counter value output
     .DATAOUT(in_delayed),         // 1-bit output: Delayed data output
     .C(pclk1x),                     // 1-bit input: Clock input
     .CE(1'b1),                   // 1-bit input: Active high enable increment/decrement input
     .CINVCTRL(1'b0),       // 1-bit input: Dynamic clock inversion input
     .CNTVALUEIN(delay),   // 5-bit input: Counter value input
     .DATAIN(1'b0),           // 1-bit input: Internal delay data input
     .IDATAIN(in),         // 1-bit input: Data input from the I/O
     .INC(1'b0),                 // 1-bit input: Increment / Decrement tap delay input
     .LD(1'b1),                   // 1-bit input: Load IDELAY_VALUE input
     .LDPIPEEN(1'b0),       // 1-bit input: Enable PIPELINE register to load data input
     .REGRST(rst_ps)            // 1-bit input: Active-high reset tap-delay input
  );

//ISERDES (master-slave bitwith extension configuration)
//-------

ISERDESE2 #(
   .DATA_RATE("DDR"),           // DDR, SDR
   .DATA_WIDTH(10),              // Parallel data width (2-8,10,14)
   .DYN_CLKDIV_INV_EN("FALSE"), // Enable DYNCLKDIVINVSEL inversion (FALSE, TRUE)
   .DYN_CLK_INV_EN("FALSE"),    // Enable DYNCLKINVSEL inversion (FALSE, TRUE)
   // INIT_Q1 - INIT_Q4: Initial value on the Q outputs (0/1)
   .INIT_Q1(1'b0),
   .INIT_Q2(1'b0),
   .INIT_Q3(1'b0),
   .INIT_Q4(1'b0),
   .INTERFACE_TYPE("NETWORKING"),   // MEMORY, MEMORY_DDR3, MEMORY_QDR, NETWORKING, OVERSAMPLE
   .IOBDELAY("IFD"),           // NONE, BOTH, IBUF, IFD
   .NUM_CE(1),                  // Number of clock enables (1,2)
   .OFB_USED("FALSE"),          // Select OFB path (FALSE, TRUE)
   .SERDES_MODE("MASTER"),      // MASTER, SLAVE
   // SRVAL_Q1 - SRVAL_Q4: Q output values when SR is used (0/1)
   .SRVAL_Q1(1'b0),
   .SRVAL_Q2(1'b0),
   .SRVAL_Q3(1'b0),
   .SRVAL_Q4(1'b0)
)
ISERDESE2_master (
   .O(),                       // 1-bit output: Combinatorial output
   // Q1 - Q8: 1-bit (each) output: Registered data outputs
   .Q1(out[9]),
   .Q2(out[8]),
   .Q3(out[7]),
   .Q4(out[6]),
   .Q5(out[5]),
   .Q6(out[4]),
   .Q7(out[3]),
   .Q8(out[2]),
   // SHIFTOUT1, SHIFTOUT2: 1-bit (each) output: Data width expansion output ports
   .SHIFTOUT1(iserdesshift[0]),
   .SHIFTOUT2(iserdesshift[1]),
   .BITSLIP(bitslip),           // 1-bit input: The BITSLIP pin performs a Bitslip operation synchronous to
                                // CLKDIV when asserted (active High). Subsequently, the data seen on the Q1
                                // to Q8 output ports will shift, as in a barrel-shifter operation, one
                                // position every time Bitslip is invoked (DDR operation is different from
                                // SDR).

   // CE1, CE2: 1-bit (each) input: Data register clock enable inputs
   .CE1(1'b1),
   .CE2(1'b1),
   .CLKDIVP(1'b0),           // 1-bit input: TBD
   // Clocks: 1-bit (each) input: ISERDESE2 clock input ports
   .CLK(pclk5x),                   // 1-bit input: High-speed clock
   .CLKB(~pclk5x),                 // 1-bit input: High-speed secondary clock
   .CLKDIV(pclk1x),             // 1-bit input: Divided clock
   .OCLK(1'b0),                 // 1-bit input: High speed output clock used when INTERFACE_TYPE="MEMORY"
   // Dynamic Clock Inversions: 1-bit (each) input: Dynamic clock inversion pins to switch clock polarity
   .DYNCLKDIVSEL(1'b0), // 1-bit input: Dynamic CLKDIV inversion
   .DYNCLKSEL(1'b0),       // 1-bit input: Dynamic CLK/CLKB inversion
   // Input Data: 1-bit (each) input: ISERDESE2 data input ports
   .D(1'b0),                       // 1-bit input: Data input
   .DDLY(in_delayed),                 // 1-bit input: Serial data from IDELAYE2
   .OFB(1'b0),                   // 1-bit input: Data feedback from OSERDESE2
   .OCLKB(1'b0),               // 1-bit input: High speed negative edge output clock
   .RST(rst_ps),                   // 1-bit input: Active high asynchronous reset
   // SHIFTIN1, SHIFTIN2: 1-bit (each) input: Data width expansion input ports
   .SHIFTIN1(1'b0),
   .SHIFTIN2(1'b0)
);

ISERDESE2 #(
   .DATA_RATE("DDR"),           // DDR, SDR
   .DATA_WIDTH(10),              // Parallel data width (2-8,10,14)
   .DYN_CLKDIV_INV_EN("FALSE"), // Enable DYNCLKDIVINVSEL inversion (FALSE, TRUE)
   .DYN_CLK_INV_EN("FALSE"),    // Enable DYNCLKINVSEL inversion (FALSE, TRUE)
   // INIT_Q1 - INIT_Q4: Initial value on the Q outputs (0/1)
   .INIT_Q1(1'b0),
   .INIT_Q2(1'b0),
   .INIT_Q3(1'b0),
   .INIT_Q4(1'b0),
   .INTERFACE_TYPE("NETWORKING"),   // MEMORY, MEMORY_DDR3, MEMORY_QDR, NETWORKING, OVERSAMPLE
   .IOBDELAY("IFD"),           // NONE, BOTH, IBUF, IFD
   .NUM_CE(1),                  // Number of clock enables (1,2)
   .OFB_USED("FALSE"),          // Select OFB path (FALSE, TRUE)
   .SERDES_MODE("SLAVE"),      // MASTER, SLAVE
   // SRVAL_Q1 - SRVAL_Q4: Q output values when SR is used (0/1)
   .SRVAL_Q1(1'b0),
   .SRVAL_Q2(1'b0),
   .SRVAL_Q3(1'b0),
   .SRVAL_Q4(1'b0)
)
ISERDESE2_slave (
   .O(),                       // 1-bit output: Combinatorial output
   // Q1 - Q8: 1-bit (each) output: Registered data outputs
   .Q1(),
   .Q2(),
   .Q3(out[1]),
   .Q4(out[0]),
   .Q5(),
   .Q6(),
   .Q7(),
   .Q8(),
   // SHIFTOUT1, SHIFTOUT2: 1-bit (each) output: Data width expansion output ports
   .SHIFTOUT1(),
   .SHIFTOUT2(),
   .BITSLIP(bitslip),           // 1-bit input: The BITSLIP pin performs a Bitslip operation synchronous to
                                // CLKDIV when asserted (active High). Subsequently, the data seen on the Q1
                                // to Q8 output ports will shift, as in a barrel-shifter operation, one
                                // position every time Bitslip is invoked (DDR operation is different from
                                // SDR).

   // CE1, CE2: 1-bit (each) input: Data register clock enable inputs
   .CE1(1'b1),
   .CE2(1'b1),
   .CLKDIVP(1'b0),           // 1-bit input: TBD
   // Clocks: 1-bit (each) input: ISERDESE2 clock input ports
   .CLK(pclk5x),                   // 1-bit input: High-speed clock
   .CLKB(~pclk5x),                 // 1-bit input: High-speed secondary clock
   .CLKDIV(pclk1x),             // 1-bit input: Divided clock
   .OCLK(1'b0),                 // 1-bit input: High speed output clock used when INTERFACE_TYPE="MEMORY"
   // Dynamic Clock Inversions: 1-bit (each) input: Dynamic clock inversion pins to switch clock polarity
   .DYNCLKDIVSEL(1'b0), // 1-bit input: Dynamic CLKDIV inversion
   .DYNCLKSEL(1'b0),       // 1-bit input: Dynamic CLK/CLKB inversion
   // Input Data: 1-bit (each) input: ISERDESE2 data input ports
   .D(1'b0),                       // 1-bit input: Data input
   .DDLY(1'b0),                 // 1-bit input: Serial data from IDELAYE2
   .OFB(1'b0),                   // 1-bit input: Data feedback from OSERDESE2
   .OCLKB(1'b0),               // 1-bit input: High speed negative edge output clock
   .RST(rst_ps),                   // 1-bit input: Active high asynchronous reset
   // SHIFTIN1, SHIFTIN2: 1-bit (each) input: Data width expansion input ports
   .SHIFTIN1(iserdesshift[0]),
   .SHIFTIN2(iserdesshift[1])
);

endmodule
