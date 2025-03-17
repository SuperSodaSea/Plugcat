`ifndef RESOLUTION
    `define RESOLUTION "1920x1080"
`endif
`ifndef REFRESH_RATE
    `define REFRESH_RATE 60
`endif


module Top(
    input clock_200_p,
    input clock_200_n,

    output [2:0] led,

    inout si5338_scl,
    inout si5338_sda,

    input qsfp0_refclk_p,
    input qsfp0_refclk_n,
    input [3:0] qsfp0_rxp,
    input [3:0] qsfp0_rxn,
    output [3:0] qsfp0_txp,
    output [3:0] qsfp0_txn,
    input qsfp0_modprsl,
    output qsfp0_resetl,
    inout qsfp0_scl,
    inout qsfp0_sda,

    input qsfp1_refclk_p,
    input qsfp1_refclk_n,
    input [3:0] qsfp1_rxp,
    input [3:0] qsfp1_rxn,
    output [3:0] qsfp1_txp,
    output [3:0] qsfp1_txn,
    input qsfp1_modprsl,
    output qsfp1_resetl,
    inout qsfp1_scl,
    inout qsfp1_sda
);

localparam CLOCK_FREQUENCY = 200_000_000;

localparam REFERENCE_CLOCK_FREQUENCY =
    `RESOLUTION == "1920x1080" ? 148_500_000 :
    `RESOLUTION == "2560x1440" ? 121_584_000 :
    `RESOLUTION == "3840x2160" ? 148_500_000 :
    0;


wire system_reset_input = 0;

wire system_clock;
wire gt_config_clock;
wire mmcm_0_locked;

MMCM0 mmcm_0(
    .clk_in1_p (clock_200_p),
    .clk_in1_n (clock_200_n),
    .reset (system_reset_input),
    .clk_out1 (system_clock),
    .clk_out2 (gt_config_clock),
    .locked (mmcm_0_locked)
);


wire si5338_scl_input;
wire si5338_scl_output;
wire si5338_sda_input;
wire si5338_sda_output;

IOBUF si5338_scl_iobuf(
    .O (si5338_scl_input),
    .I (si5338_scl_output),
    .IO (si5338_scl),
    .T (si5338_scl_output)
);
IOBUF si5338_sda_iobuf(
    .O (si5338_sda_input),
    .I (si5338_sda_output),
    .IO (si5338_sda),
    .T (si5338_sda_output)
);

wire si5338_ready;

Si5338 #(
    .CLOCK_FREQUENCY (CLOCK_FREQUENCY),
    .REFERENCE_CLOCK_FREQUENCY (REFERENCE_CLOCK_FREQUENCY)
) si5338(
    .clock (system_clock),
    .reset (~mmcm_0_locked),

    .scl_input (si5338_scl_input),
    .scl_output (si5338_scl_output),
    .sda_input (si5338_sda_input),
    .sda_output (si5338_sda_output),

    .ready (si5338_ready)
);


reg [2:0] system_reset_reg;

always @(posedge system_clock) begin
    if (~si5338_ready) begin
        system_reset_reg <= 3'b111;
    end else begin
        system_reset_reg <= system_reset_reg >> 1;
    end
end

wire system_reset = system_reset_reg[0];


wire [1:0] tx_clock;
wire [1:0] tx_reset;
wire [159:0] tx_data[1:0];

GTWizardWrapper0 gt_wizard_wrapper_0(
    .clock (gt_config_clock),
    .reset (system_reset),

    .refclk_p (qsfp0_refclk_p),
    .refclk_n (qsfp0_refclk_n),
    .rxp (qsfp0_rxp),
    .rxn (qsfp0_rxn),
    .txp (qsfp0_txp),
    .txn (qsfp0_txn),

    .tx_clock (tx_clock[0]),
    .tx_reset (tx_reset[0]),
    .tx_data (tx_data[0])
);

GTWizardWrapper1 gt_wizard_wrapper_1(
    .clock (gt_config_clock),
    .reset (system_reset),

    .refclk_p (qsfp1_refclk_p),
    .refclk_n (qsfp1_refclk_n),
    .rxp (qsfp1_rxp),
    .rxn (qsfp1_rxn),
    .txp (qsfp1_txp),
    .txn (qsfp1_txn),

    .tx_clock (tx_clock[1]),
    .tx_reset (tx_reset[1]),
    .tx_data (tx_data[1])
);


wire [1:0] qsfp_scl_input;
wire [1:0] qsfp_scl_output;
wire [1:0] qsfp_sda_input;
wire [1:0] qsfp_sda_output;

IOBUF qsfp0_scl_iobuf(
    .O (qsfp_scl_input[0]),
    .I (qsfp_scl_output[0]),
    .IO (qsfp0_scl),
    .T (qsfp_scl_output[0])
);
IOBUF qsfp0_sda_iobuf(
    .O (qsfp_sda_input[0]),
    .I (qsfp_sda_output[0]),
    .IO (qsfp0_sda),
    .T (qsfp_sda_output[0])
);

IOBUF qsfp1_scl_iobuf(
    .O (qsfp_scl_input[1]),
    .I (qsfp_scl_output[1]),
    .IO (qsfp1_scl),
    .T (qsfp_scl_output[1])
);
IOBUF qsfp1_sda_iobuf(
    .O (qsfp_sda_input[1]),
    .I (qsfp_sda_output[1]),
    .IO (qsfp1_sda),
    .T (qsfp_sda_output[1])
);

wire [1:0] hpd = { ~qsfp1_modprsl, ~qsfp0_modprsl };
wire [1:0] run;

generate
    for (genvar i = 0; i < 2; i = i + 1) begin
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
            .run (run[i])
        );
    end
endgenerate

reg led_reg;
reg [31:0] led_count;

always @(posedge system_clock) begin
    if (system_reset) begin
        led_reg <= 0;
        led_count <= 0;
    end else begin
        if (led_count != CLOCK_FREQUENCY / 2 - 1) begin
            led_count <= led_count + 1;
        end else begin
            led_count <= 0;
            led_reg <= ~led_reg;
        end
    end
end

assign led = {
    ~system_reset,
    ~(~system_reset & ((led_reg & hpd[1]) | run[1])),
    ~(~system_reset & ((led_reg & hpd[0]) | run[0]))
};

assign qsfp0_resetl = ~system_reset;

assign qsfp1_resetl = ~system_reset;

endmodule
