`ifndef RESOLUTION
    `define RESOLUTION "1920x1080"
`endif
`ifndef REFRESH_RATE
    `define REFRESH_RATE 60
`endif


module Top(
    input clock_100_p,
    input clock_100_n,

    input [1:0] key,
    output [1:0] led,

    input qsfp_refclk_p,
    input qsfp_refclk_n,
    input [3:0] qsfp_rxp,
    input [3:0] qsfp_rxn,
    output [3:0] qsfp_txp,
    output [3:0] qsfp_txn,
    input qsfp_modprsl,
    output qsfp_resetl,
    inout qsfp_scl,
    inout qsfp_sda
);

localparam CLOCK_FREQUENCY = 200_000_000;


wire system_reset_input = ~key[0];

wire system_clock;
wire gt_config_clock;
wire mmcm0_locked;

MMCM0 mmcm0(
    .clk_in1_p (clock_100_p),
    .clk_in1_n (clock_100_n),
    .reset (system_reset_input),
    .clk_out1 (system_clock),
    .clk_out2 (gt_config_clock),
    .locked (mmcm0_locked)
);


wire system_reset = ~mmcm0_locked;

wire tx_clock;
wire tx_reset;
wire [159:0] tx_data;

GTWizardWrapper0 gt_wizard_wrapper_0(
    .clock (gt_config_clock),
    .reset (system_reset),

    .refclk_p (qsfp_refclk_p),
    .refclk_n (qsfp_refclk_n),
    .rxp (qsfp_rxp),
    .rxn (qsfp_rxn),
    .txp (qsfp_txp),
    .txn (qsfp_txn),

    .tx_clock (tx_clock),
    .tx_reset (tx_reset),
    .tx_data (tx_data)
);


wire qsfp_scl_input;
wire qsfp_scl_output;
wire qsfp_sda_input;
wire qsfp_sda_output;

IOBUF qsfp_scl_iobuf(
    .O (qsfp_scl_input),
    .I (qsfp_scl_output),
    .IO (qsfp_scl),
    .T (qsfp_scl_output)
);
IOBUF qsfp_sda_iobuf(
    .O (qsfp_sda_input),
    .I (qsfp_sda_output),
    .IO (qsfp_sda),
    .T (qsfp_sda_output)
);

wire hpd = ~qsfp_modprsl;
wire run;

HDMIOUTExample #(
    .CLOCK_FREQUENCY (CLOCK_FREQUENCY),
    .RESOLUTION (`RESOLUTION),
    .REFRESH_RATE (`REFRESH_RATE)
) hdmi_out_example(
    .system_clock (system_clock),
    .system_reset (system_reset),
    .tx_clock (tx_clock),
    .tx_reset (tx_reset),
    .tx_data (tx_data),
    .hpd (hpd),
    .scl_input (qsfp_scl_input),
    .scl_output (qsfp_scl_output),
    .sda_input (qsfp_sda_input),
    .sda_output (qsfp_sda_output),
    .i2c_request (),
    .i2c_grant (1'b1),
    .run (run)
);

assign qsfp_resetl = ~system_reset;

assign led = {
    ~system_reset & run,
    ~system_reset & hpd & ~run
};

endmodule
