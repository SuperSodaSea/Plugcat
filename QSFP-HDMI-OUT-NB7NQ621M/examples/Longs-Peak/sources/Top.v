`ifndef RESOLUTION
    `define RESOLUTION "1920x1080"
`endif
`ifndef REFRESH_RATE
    `define REFRESH_RATE 60
`endif


module Top(
    input clock_100,

    output [8:0] led,

    input qsfp_refclk,

    output [3:0] qsfp_tx,
    inout qsfp_scl,
    inout qsfp_sda,
    input qsfp_modprsl
);

localparam CLOCK_FREQUENCY = 200_000_000;


reg [2:0] system_reset_input_reg = 3'b111;
wire system_reset_input = system_reset_input_reg[0];

always @(posedge clock_100) begin
    system_reset_input_reg <= system_reset_input_reg >> 1;
end

wire system_clock;
wire pll0_locked;

PLL0 pll0 (
    .refclk (clock_100),
    .rst (system_reset_input),
    .outclk_0 (system_clock),
    .locked (pll0_locked)
);

reg [2:0] system_reset_reg;

always @(posedge system_clock) begin
    if (~pll0_locked) begin
        system_reset_reg <= 3'b111;
    end else begin
        system_reset_reg <= system_reset_reg >> 1;
    end
end

wire system_reset = system_reset_reg[0];


wire tx_clock;
wire tx_reset;
wire [159:0] tx_data;

XCVRWrapper0 xcvr_wrapper_0(
    .clock (system_clock),
    .reset (system_reset),

    .refclk (qsfp_refclk),
    .tx (qsfp_tx),

    .tx_clock (tx_clock),
    .tx_reset (tx_reset),
    .tx_data (tx_data)
);


wire qsfp_scl_input;
wire [1:0] qsfp_scl_output;
wire qsfp_sda_input;
wire [1:0] qsfp_sda_output;

alt_iobuf qsfp_scl_iobuf(
    .I (&qsfp_scl_output),
    .OE (~&qsfp_scl_output),
    .O (qsfp_scl_input),
    .IO (qsfp_scl)
);
alt_iobuf qsfp_sda_iobuf(
    .I (&qsfp_sda_output),
    .OE (~&qsfp_sda_output),
    .O (qsfp_sda_input),
    .IO (qsfp_sda)
);

wire [1:0] qsfp_i2c_request;
wire [1:0] qsfp_i2c_grant;

Arbiter #(
    .REQUEST_COUNT (2)
) arbiter (
    .clock (system_clock),
    .reset (system_reset),

    .request (qsfp_i2c_request),
    .grant (qsfp_i2c_grant)
);

wire ds250df810_ready;

DS250DF810 #(
    .CLOCK_FREQUENCY (CLOCK_FREQUENCY)
) ds250df810 (
    .clock (system_clock),
    .reset (system_reset),

    .scl_input (qsfp_scl_input),
    .scl_output (qsfp_scl_output[0]),
    .sda_input (qsfp_sda_input),
    .sda_output (qsfp_sda_output[0]),

    .i2c_request (qsfp_i2c_request[0]),
    .i2c_grant (qsfp_i2c_grant[0]),

    .ready (ds250df810_ready)
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
    .scl_output (qsfp_scl_output[1]),
    .sda_input (qsfp_sda_input),
    .sda_output (qsfp_sda_output[1]),
    .i2c_request (qsfp_i2c_request[1]),
    .i2c_grant (qsfp_i2c_grant[1]),
    .run (run)
);

assign led = {
    ~system_reset & run,
    ~system_reset & hpd & ~run,
    ~system_reset
};

endmodule
