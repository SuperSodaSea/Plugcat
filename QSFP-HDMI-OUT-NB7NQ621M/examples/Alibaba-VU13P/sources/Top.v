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

    input qsfp1_refclk_p,
    input qsfp1_refclk_n,
    input [3:0] qsfp1_rxp,
    input [3:0] qsfp1_rxn,
    output [3:0] qsfp1_txp,
    output [3:0] qsfp1_txn,
    input qsfp1_modprsl,
    output qsfp1_resetl,
    inout qsfp1_scl,
    inout qsfp1_sda,
    output qsfp1_led_y,
    output qsfp1_led_g,

    input qsfp2_refclk_p,
    input qsfp2_refclk_n,
    input [3:0] qsfp2_rxp,
    input [3:0] qsfp2_rxn,
    output [3:0] qsfp2_txp,
    output [3:0] qsfp2_txn,
    input qsfp2_modprsl,
    output qsfp2_resetl,
    inout qsfp2_scl,
    inout qsfp2_sda,
    output qsfp2_led_y,
    output qsfp2_led_g
);

localparam CLOCK_FREQUENCY = 200_000_000;


wire system_reset_input = 0;

wire system_clock;
wire gt_config_clock;
wire pll0_locked;

PLL0 pll0(
    .clk_in1_p (clock_100_p),
    .clk_in1_n (clock_100_n),
    .reset (system_reset_input),
    .clk_out1 (system_clock),
    .clk_out2 (gt_config_clock),
    .locked (pll0_locked)
);


wire system_reset = ~pll0_locked;

wire [1:0] tx_clock;
wire [1:0] tx_reset;
wire [159:0] tx_data[1:0];

GTWizardWrapper0 gt_wizard_wrapper_0(
    .clock (gt_config_clock),
    .reset (system_reset),

    .refclk_p (qsfp1_refclk_p),
    .refclk_n (qsfp1_refclk_n),
    .rxp (qsfp1_rxp),
    .rxn (qsfp1_rxn),
    .txp (qsfp1_txp),
    .txn (qsfp1_txn),

    .tx_clock (tx_clock[0]),
    .tx_reset (tx_reset[0]),
    .tx_data (tx_data[0])
);

GTWizardWrapper1 gt_wizard_wrapper_1(
    .clock (gt_config_clock),
    .reset (system_reset),

    .refclk_p (qsfp2_refclk_p),
    .refclk_n (qsfp2_refclk_n),
    .rxp (qsfp2_rxp),
    .rxn (qsfp2_rxn),
    .txp (qsfp2_txp),
    .txn (qsfp2_txn),

    .tx_clock (tx_clock[1]),
    .tx_reset (tx_reset[1]),
    .tx_data (tx_data[1])
);


wire [1:0] qsfp_scl_input;
wire [1:0] qsfp_scl_output;
wire [1:0] qsfp_sda_input;
wire [1:0] qsfp_sda_output;

IOBUF qsfp1_scl_iobuf(
    .O (qsfp_scl_input[0]),
    .I (qsfp_scl_output[0]),
    .IO (qsfp1_scl),
    .T (qsfp_scl_output[0])
);
IOBUF qsfp1_sda_iobuf(
    .O (qsfp_sda_input[0]),
    .I (qsfp_sda_output[0]),
    .IO (qsfp1_sda),
    .T (qsfp_sda_output[0])
);

IOBUF qsfp2_scl_iobuf(
    .O (qsfp_scl_input[1]),
    .I (qsfp_scl_output[1]),
    .IO (qsfp2_scl),
    .T (qsfp_scl_output[1])
);
IOBUF qsfp2_sda_iobuf(
    .O (qsfp_sda_input[1]),
    .I (qsfp_sda_output[1]),
    .IO (qsfp2_sda),
    .T (qsfp_sda_output[1])
);

wire [1:0] hpd = { ~qsfp2_modprsl, ~qsfp1_modprsl };
wire [1:0] run;

genvar i;

generate
    for (i = 0; i < 2; i = i + 1) begin: hdmi_out_examples
        HDMIOUTExample #(
            .CLOCK_FREQUENCY (CLOCK_FREQUENCY),
            .RESOLUTION (`RESOLUTION),
            .REFRESH_RATE (`REFRESH_RATE)
        ) hdmi_out_example(
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
            .i2c_request (),
            .i2c_grant (1'b1),
            .run (run[i])
        );
    end
endgenerate

assign led_run = ~system_reset;
assign led = 0;

assign qsfp1_resetl = ~system_reset;
assign qsfp1_led_y = ~system_reset & hpd[0] & ~run[0];
assign qsfp1_led_g = ~system_reset & run[0];

assign qsfp2_resetl = ~system_reset;
assign qsfp2_led_y = ~system_reset & hpd[1] & ~run[1];
assign qsfp2_led_g = ~system_reset & run[1];

endmodule
