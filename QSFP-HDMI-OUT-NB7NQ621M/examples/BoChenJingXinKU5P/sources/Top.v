`ifndef RESOLUTION
    `define RESOLUTION "1920x1080"
`endif
`ifndef REFRESH_RATE
    `define REFRESH_RATE 60
`endif


module Top(
    input clock_50,

    input [1:0] key,
    output [5:0] led,

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
wire mmcm_0_locked;

MMCM0 mmcm_0(
    .clk_in1 (clock_50),
    .reset (system_reset_input),
    .clk_out1 (system_clock),
    .clk_out2 (gt_config_clock),
    .locked (mmcm_0_locked)
);

wire system_reset = ~mmcm_0_locked;

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

wire scl_input;
wire scl_output;
wire sda_input;
wire sda_output;

IOBUF scl_iobuf(
    .O  (scl_input),
    .I  (scl_output),
    .IO (qsfp_scl),
    .T  (scl_output)
);
IOBUF sda_iobuf(
    .O  (sda_input),
    .I  (sda_output),
    .IO (qsfp_sda),
    .T  (sda_output)
);

wire hpd = ~qsfp_modprsl;
wire run;
assign qsfp_resetl = ~system_reset;
HDMIOUTExample #(.CLOCK_FREQUENCY (CLOCK_FREQUENCY), .RESOLUTION (`RESOLUTION), .REFRESH_RATE (`REFRESH_RATE)) hdmi_out_example(
    .system_clock (system_clock),
    .system_reset (system_reset),
    .tx_clock (tx_clock),
    .tx_reset (tx_reset),
    .tx_data (tx_data),
    .hpd (hpd),
    .scl_input (scl_input),
    .scl_output (scl_output),
    .sda_input (sda_input),
    .sda_output (sda_output),
    .run (run)
);

assign led = { ~system_reset & run, ~system_reset & hpd & ~run, ~system_reset };

endmodule
