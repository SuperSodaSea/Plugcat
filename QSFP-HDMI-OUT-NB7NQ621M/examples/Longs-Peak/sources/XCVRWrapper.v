module XCVRWrapper0(
    input clock,
    input reset,

    input refclk,
    output [3:0] tx,

    output tx_clock,
    output tx_reset,
    input [159:0] tx_data
);

wire pll_powerdown;
wire [3:0] tx_analogreset;
wire [3:0] tx_digitalreset;
wire [3:0] tx_ready;
wire pll_locked;
wire [3:0] tx_cal_busy;

wire tx_serial_clk;
wire [3:0] tx_clocks;

XCVRReset0 xcvr_reset(
    .clock (clock),
    .reset (reset),
    .pll_powerdown (pll_powerdown),
    .tx_analogreset (tx_analogreset),
    .tx_digitalreset (tx_digitalreset),
    .tx_ready (tx_ready),
    .pll_locked (pll_locked),
    .pll_select (1'b0),
    .tx_cal_busy (tx_cal_busy)
);

XCVRFPLL0 xcvr_fpll(
    .pll_refclk0 (refclk),
    .pll_powerdown (pll_powerdown),
    .pll_locked (pll_locked),
    .tx_serial_clk (tx_serial_clk),
    .pll_cal_busy ()
);

XCVR0 xcvr(
    .tx_analogreset (tx_analogreset),
    .tx_digitalreset (tx_digitalreset),
    .tx_cal_busy (tx_cal_busy),
    .tx_serial_clk0 ({ 4 { tx_serial_clk } }),
    .tx_serial_data (tx),
    .tx_coreclkin ({ 4 { tx_clock } }),
    .tx_clkout (tx_clocks),
    .tx_parallel_data (tx_data),
    .unused_tx_parallel_data (352'b0)
);

assign tx_clock = tx_clocks[1];
assign tx_reset = ~&tx_ready;

endmodule
