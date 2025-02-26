module GTWizardWrapper0(
    input clock,
    input reset,

    input refclk_p,
    input refclk_n,
    input [3:0] rxp,
    input [3:0] rxn,
    output [3:0] txp,
    output [3:0] txn,

    output tx_clock,
    output tx_reset,
    input [159:0] tx_data
);

wire refclk;

IBUFDS_GTE4 ibufds_gte4 (
    .O (refclk),
    .ODIV2 (),
    .CEB (0),
    .I (refclk_p),
    .IB (refclk_n)
);

wire userclk_tx_reset;
wire userclk_tx_usrclk2;
wire userclk_tx_active;
wire buffbypass_tx_reset;
wire buffbypass_tx_done;
wire buffbypass_tx_error;
wire reset_tx_done;
wire [3:0] txpmaresetdone;
wire [3:0] txprgdivresetdone;

GTWizard0 gt_wizard(
    .gtwiz_userclk_tx_reset_in (userclk_tx_reset),
    .gtwiz_userclk_tx_srcclk_out (),
    .gtwiz_userclk_tx_usrclk_out (),
    .gtwiz_userclk_tx_usrclk2_out (userclk_tx_usrclk2),
    .gtwiz_userclk_tx_active_out (userclk_tx_active),
    .gtwiz_userclk_rx_reset_in (1),
    .gtwiz_userclk_rx_srcclk_out (),
    .gtwiz_userclk_rx_usrclk_out (),
    .gtwiz_userclk_rx_usrclk2_out (),
    .gtwiz_userclk_rx_active_out (),
    .gtwiz_buffbypass_tx_reset_in (buffbypass_tx_reset),
    .gtwiz_buffbypass_tx_start_user_in (0),
    .gtwiz_buffbypass_tx_done_out (buffbypass_tx_done),
    .gtwiz_buffbypass_tx_error_out (buffbypass_tx_error),
    .gtwiz_reset_clk_freerun_in (clock),
    .gtwiz_reset_all_in (reset),
    .gtwiz_reset_tx_pll_and_datapath_in (0),
    .gtwiz_reset_tx_datapath_in (0),
    .gtwiz_reset_rx_pll_and_datapath_in (0),
    .gtwiz_reset_rx_datapath_in (0),
    .gtwiz_reset_rx_cdr_stable_out (),
    .gtwiz_reset_tx_done_out (reset_tx_done),
    .gtwiz_reset_rx_done_out (),
    .gtwiz_userdata_tx_in (tx_data),
    .gtwiz_userdata_rx_out (),
    .gtrefclk00_in (refclk),
    .gtrefclk01_in (refclk),
    .qpll0outclk_out (),
    .qpll0outrefclk_out (),
    .qpll1outclk_out (),
    .qpll1outrefclk_out (),
    .gtyrxn_in (rxn),
    .gtyrxp_in (rxp),
    .gtpowergood_out (),
    .gtytxn_out (txn),
    .gtytxp_out (txp),
    .rxpmaresetdone_out (),
    .txpmaresetdone_out (txpmaresetdone),
    .txprgdivresetdone_out (txprgdivresetdone)
);

assign userclk_tx_reset = ~(&txpmaresetdone & &txprgdivresetdone);

reg [2:0] buffbypass_tx_reset_reg;
always @(posedge userclk_tx_usrclk2) begin
    if (~userclk_tx_active) begin
        buffbypass_tx_reset_reg <= 5;
    end else begin
        if (buffbypass_tx_reset_reg != 0)
            buffbypass_tx_reset_reg <= buffbypass_tx_reset_reg - 1;
    end
end
assign buffbypass_tx_reset = buffbypass_tx_reset_reg != 0;

assign tx_clock = userclk_tx_usrclk2;
assign tx_reset = reset | ~reset_tx_done | ~buffbypass_tx_done;

endmodule

module GTWizardWrapper1(
    input clock,
    input reset,

    input refclk_p,
    input refclk_n,
    input [3:0] rxp,
    input [3:0] rxn,
    output [3:0] txp,
    output [3:0] txn,

    output tx_clock,
    output tx_reset,
    input [159:0] tx_data
);

wire refclk;

IBUFDS_GTE4 ibufds_gte4 (
    .O (refclk),
    .ODIV2 (),
    .CEB (0),
    .I (refclk_p),
    .IB (refclk_n)
);

wire userclk_tx_reset;
wire userclk_tx_usrclk2;
wire userclk_tx_active;
wire buffbypass_tx_reset;
wire buffbypass_tx_done;
wire buffbypass_tx_error;
wire reset_tx_done;
wire [3:0] txpmaresetdone;
wire [3:0] txprgdivresetdone;

GTWizard1 gt_wizard(
    .gtwiz_userclk_tx_reset_in (userclk_tx_reset),
    .gtwiz_userclk_tx_srcclk_out (),
    .gtwiz_userclk_tx_usrclk_out (),
    .gtwiz_userclk_tx_usrclk2_out (userclk_tx_usrclk2),
    .gtwiz_userclk_tx_active_out (userclk_tx_active),
    .gtwiz_userclk_rx_reset_in (1),
    .gtwiz_userclk_rx_srcclk_out (),
    .gtwiz_userclk_rx_usrclk_out (),
    .gtwiz_userclk_rx_usrclk2_out (),
    .gtwiz_userclk_rx_active_out (),
    .gtwiz_buffbypass_tx_reset_in (buffbypass_tx_reset),
    .gtwiz_buffbypass_tx_start_user_in (0),
    .gtwiz_buffbypass_tx_done_out (buffbypass_tx_done),
    .gtwiz_buffbypass_tx_error_out (buffbypass_tx_error),
    .gtwiz_reset_clk_freerun_in (clock),
    .gtwiz_reset_all_in (reset),
    .gtwiz_reset_tx_pll_and_datapath_in (0),
    .gtwiz_reset_tx_datapath_in (0),
    .gtwiz_reset_rx_pll_and_datapath_in (0),
    .gtwiz_reset_rx_datapath_in (0),
    .gtwiz_reset_rx_cdr_stable_out (),
    .gtwiz_reset_tx_done_out (reset_tx_done),
    .gtwiz_reset_rx_done_out (),
    .gtwiz_userdata_tx_in (tx_data),
    .gtwiz_userdata_rx_out (),
    .gtrefclk00_in (refclk),
    .gtrefclk01_in (refclk),
    .qpll0outclk_out (),
    .qpll0outrefclk_out (),
    .qpll1outclk_out (),
    .qpll1outrefclk_out (),
    .gtyrxn_in (rxn),
    .gtyrxp_in (rxp),
    .gtpowergood_out (),
    .gtytxn_out (txn),
    .gtytxp_out (txp),
    .rxpmaresetdone_out (),
    .txpmaresetdone_out (txpmaresetdone),
    .txprgdivresetdone_out (txprgdivresetdone)
);

assign userclk_tx_reset = ~(&txpmaresetdone & &txprgdivresetdone);

reg [2:0] buffbypass_tx_reset_reg;
always @(posedge userclk_tx_usrclk2) begin
    if (~userclk_tx_active) begin
        buffbypass_tx_reset_reg <= 5;
    end else begin
        if (buffbypass_tx_reset_reg != 0)
            buffbypass_tx_reset_reg <= buffbypass_tx_reset_reg - 1;
    end
end
assign buffbypass_tx_reset = buffbypass_tx_reset_reg != 0;

assign tx_clock = userclk_tx_usrclk2;
assign tx_reset = reset | ~reset_tx_done | ~buffbypass_tx_done;

endmodule
