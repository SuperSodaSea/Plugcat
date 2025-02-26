`ifndef RESOLUTION
    `define RESOLUTION "1920x1080"
`endif
`ifndef REFRESH_RATE
    `define REFRESH_RATE 60
`endif


module Top(
    input clock_100_p,
    input clock_100_n,

    output led_run,
    output [7:0] led,

    input qsfp_0_refclk_p,
    input qsfp_0_refclk_n,
    input [3:0] qsfp_0_rxp,
    input [3:0] qsfp_0_rxn,
    output [3:0] qsfp_0_txp,
    output [3:0] qsfp_0_txn,
    input qsfp_0_modprsl,
    output qsfp_0_resetl,
    inout qsfp_0_scl,
    inout qsfp_0_sda,
    output qsfp_0_led_y,
    output qsfp_0_led_g,

    input qsfp_1_refclk_p,
    input qsfp_1_refclk_n,
    input [3:0] qsfp_1_rxp,
    input [3:0] qsfp_1_rxn,
    output [3:0] qsfp_1_txp,
    output [3:0] qsfp_1_txn,
    input qsfp_1_modprsl,
    output qsfp_1_resetl,
    inout qsfp_1_scl,
    inout qsfp_1_sda,
    output qsfp_1_led_y,
    output qsfp_1_led_g
);

localparam CLOCK_FREQUENCY = 200_000_000;

wire system_reset_input = 0;

wire system_clock;
wire gt_config_clock;
wire pll_0_locked;

PLL0 pll_0(
    .clk_in1_p (clock_100_p),
    .clk_in1_n (clock_100_n),
    .reset (system_reset_input),
    .clk_out1 (system_clock),
    .clk_out2 (gt_config_clock),
    .locked (pll_0_locked)
);

wire system_reset = ~pll_0_locked;

wire tx_clock[0:1];
wire tx_reset[0:1];
wire [159:0] tx_data[0:1];

GTWizardWrapper0 gt_wizard_wrapper_0(
    .clock (gt_config_clock),
    .reset (system_reset),

    .refclk_p (qsfp_0_refclk_p),
    .refclk_n (qsfp_0_refclk_n),
    .rxp (qsfp_0_rxp),
    .rxn (qsfp_0_rxn),
    .txp (qsfp_0_txp),
    .txn (qsfp_0_txn),

    .tx_clock (tx_clock[0]),
    .tx_reset (tx_reset[0]),
    .tx_data (tx_data[0])
);

GTWizardWrapper1 gt_wizard_wrapper_1(
    .clock (gt_config_clock),
    .reset (system_reset),

    .refclk_p (qsfp_1_refclk_p),
    .refclk_n (qsfp_1_refclk_n),
    .rxp (qsfp_1_rxp),
    .rxn (qsfp_1_rxn),
    .txp (qsfp_1_txp),
    .txn (qsfp_1_txn),

    .tx_clock (tx_clock[1]),
    .tx_reset (tx_reset[1]),
    .tx_data (tx_data[1])
);

wire [1:0] qsfp_scl_input;
wire [1:0] qsfp_scl_output;
wire [1:0] qsfp_sda_input;
wire [1:0] qsfp_sda_output;

IOBUF qsfp_0_scl_iobuf(
    .O  (qsfp_scl_input[0]),
    .I  (qsfp_scl_output[0]),
    .IO (qsfp_0_scl),
    .T  (qsfp_scl_output[0])
);
IOBUF qsfp_0_sda_iobuf(
    .O  (qsfp_sda_input[0]),
    .I  (qsfp_sda_output[0]),
    .IO (qsfp_0_sda),
    .T  (qsfp_sda_output[0])
);

IOBUF qsfp_1_scl_iobuf(
    .O  (qsfp_scl_input[1]),
    .I  (qsfp_scl_output[1]),
    .IO (qsfp_1_scl),
    .T  (qsfp_scl_output[1])
);
IOBUF qsfp_1_sda_iobuf(
    .O  (qsfp_sda_input[1]),
    .I  (qsfp_sda_output[1]),
    .IO (qsfp_1_sda),
    .T  (qsfp_sda_output[1])
);

wire [1:0] hpd = { ~qsfp_1_modprsl, ~qsfp_0_modprsl };
wire [1:0] run;

generate
    for (genvar i = 0; i < 2; i = i + 1) begin
        HDMIOUTExample #(.CLOCK_FREQUENCY (CLOCK_FREQUENCY), .RESOLUTION (`RESOLUTION), .REFRESH_RATE (`REFRESH_RATE)) hdmi_out_example(
            .system_clock (system_clock),
            .system_reset (system_reset),
            .tx_clock (tx_clock[i]),
            .tx_reset (tx_reset[i]),
            .tx_data (tx_data[i]),
            .hpd (hpd[i]),
            .scl_input (qsfp_scl_input[i]),
            .scl_output (qsfp_scl_output[i]),
            .sda_input (qsfp_sda_input[i]),
            .sda_output (qsfp_sda_output[i]),
            .run (run[i])
        );
    end
endgenerate

assign led_run = ~system_reset;
assign led = 0;

assign qsfp_0_resetl = ~system_reset;
assign qsfp_0_led_y = ~system_reset & hpd[0] & ~run[0];
assign qsfp_0_led_g = ~system_reset & run[0];

assign qsfp_1_resetl = ~system_reset;
assign qsfp_1_led_y = ~system_reset & hpd[1] & ~run[1];
assign qsfp_1_led_g = ~system_reset & run[1];

endmodule
