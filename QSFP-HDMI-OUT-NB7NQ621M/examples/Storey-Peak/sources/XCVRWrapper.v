module XCVRWrapper0(
    input clock,
    input reset,

    input refclk_0,
    output [3:0] tx_0,

    output tx_clock_0,
    output tx_reset_0,
    input [159:0] tx_data_0,

    input refclk_1,
    output [3:0] tx_1,

    output tx_clock_1,
    output tx_reset_1,
    input [159:0] tx_data_1
);

wire [349:0] reconfig_to_xcvr[1:0];
wire [229:0] reconfig_from_xcvr[1:0];

XCVRReconfiguration0 xcvr_reconfiguration(
    .reconfig_busy (),
    .mgmt_clk_clk (clock),
    .mgmt_rst_reset (reset),
    .reconfig_mgmt_address (7'b0),
    .reconfig_mgmt_read (1'b0),
    .reconfig_mgmt_readdata (),
    .reconfig_mgmt_waitrequest (),
    .reconfig_mgmt_write (1'b0),
    .reconfig_mgmt_writedata (32'b0),
    .reconfig_to_xcvr ({ reconfig_to_xcvr[1], reconfig_to_xcvr[0] }),
    .reconfig_from_xcvr ({ reconfig_from_xcvr[1], reconfig_from_xcvr[0] })
);

wire [1:0] pll_powerdown;
wire [3:0] tx_analogreset[1:0];
wire [3:0] tx_digitalreset[1:0];
wire [3:0] tx_ready[1:0];
wire [1:0] pll_locked;
wire [3:0] tx_cal_busy[1:0];

wire [3:0] tx_std_clock[1:0];

wire [1:0] refclk = { refclk_1, refclk_0 };
wire [3:0] tx[1:0];
assign tx_0 = tx[0];
assign tx_1 = tx[1];
wire [1:0] tx_clock;
assign tx_clock_0 = tx_clock[0];
assign tx_clock_1 = tx_clock[1];
wire [1:0] tx_reset;
assign tx_reset_0 = tx_reset[0];
assign tx_reset_1 = tx_reset[1];
wire [159:0] tx_data[1:0];
assign tx_data[0] = tx_data_0;
assign tx_data[1] = tx_data_1;

genvar i;

generate
    for (i = 0; i < 2; i = i + 1) begin: xcvrs
        XCVRReset0 xcvr_reset(
            .clock (clock),
            .reset (reset),
            .pll_powerdown (pll_powerdown[i]),
            .tx_analogreset (tx_analogreset[i]),
            .tx_digitalreset (tx_digitalreset[i]),
            .tx_ready (tx_ready[i]),
            .pll_locked (pll_locked[i]),
            .pll_select (1'b0),
            .tx_cal_busy (tx_cal_busy[i])
        );

        XCVR0 xcvr(
            .pll_powerdown (pll_powerdown[i]),
            .tx_analogreset (tx_analogreset[i]),
            .tx_digitalreset (tx_digitalreset[i]),
            .tx_pll_refclk (refclk[i]),
            .tx_serial_data (tx[i]),
            .pll_locked (pll_locked[i]),
            .tx_std_coreclkin ({ 4 { tx_clock[i] } }),
            .tx_std_clkout (tx_std_clock[i]),
            .tx_cal_busy (tx_cal_busy[i]),
            .reconfig_to_xcvr (reconfig_to_xcvr[i]),
            .reconfig_from_xcvr (reconfig_from_xcvr[i]),
            .tx_parallel_data (tx_data[i]),
            .unused_tx_parallel_data (96'b0)
        );

        assign tx_clock[i] = tx_std_clock[i][1];
        assign tx_reset[i] = ~&tx_ready[i];
    end
endgenerate

endmodule
