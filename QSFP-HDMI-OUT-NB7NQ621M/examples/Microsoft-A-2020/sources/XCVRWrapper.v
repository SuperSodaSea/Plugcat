module XCVRWrapper0(
    input clock,
    input reset,

    input refclk,
    output [3:0] tx,

    output tx_clock,
    output tx_reset,
    input [159:0] tx_data
);

wire [3:0] tx_analogreset;
wire [3:0] tx_digitalreset;
wire [3:0] tx_analogreset_stat;
wire [3:0] tx_digitalreset_stat;
wire [3:0] tx_ready;
wire pll_locked;
wire [3:0] tx_cal_busy;

wire [5:0] tx_bonding_clocks;
wire [3:0] tx_clocks;

XCVRReset0 xcvr_reset(
    .clock (clock),
    .reset (reset),
    .tx_analogreset (tx_analogreset),
    .tx_digitalreset (tx_digitalreset),
    .tx_ready (tx_ready),
    .pll_locked (pll_locked),
    .pll_select (1'b0),
    .tx_cal_busy (tx_cal_busy),
    .tx_analogreset_stat (tx_analogreset_stat),
    .tx_digitalreset_stat (tx_digitalreset_stat)
);

XCVRFPLL0 xcvr_fpll(
    .pll_refclk0 (refclk),
    .tx_serial_clk (),
    .pll_locked (pll_locked),
    .pll_cal_busy (),
    .tx_bonding_clocks (tx_bonding_clocks)
);

XCVR0 xcvr(
    .tx_analogreset (tx_analogreset),
    .tx_digitalreset (tx_digitalreset),
    .tx_analogreset_stat (tx_analogreset_stat),
    .tx_digitalreset_stat (tx_digitalreset_stat),
    .tx_cal_busy (tx_cal_busy),
    .tx_bonding_clocks ({ 4 { tx_bonding_clocks } }),
    .tx_serial_data (tx),
    .tx_coreclkin ({ 4 { tx_clock } }),
    .tx_clkout (tx_clocks),
    .tx_parallel_data (tx_data),
    .unused_tx_parallel_data (160'b0)
);

assign tx_clock = tx_clocks[1];
assign tx_reset = ~&tx_ready;

endmodule
