`ifndef RESOLUTION
    `define RESOLUTION "1920x1080"
`endif
`ifndef REFRESH_RATE
    `define REFRESH_RATE 60
`endif


module Top(
    input clock_100,

    output [8:0] led,

    inout i2c_scl,
    inout i2c_sda,

    input qsfp0_refclk,
    output [3:0] qsfp0_tx,

    input qsfp1_refclk,
    output [3:0] qsfp1_tx
);

localparam CLOCK_FREQUENCY = 200_000_000;


wire system_reset_input;

ResetRelease resetRelease (
    .ninit_done (system_reset_input)
);

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


wire [1:0] tx_clock;
wire [1:0] tx_reset;
wire [159:0] tx_data[1:0];

XCVRWrapper0 xcvr_wrapper_0(
    .clock (system_clock),
    .reset (system_reset),

    .refclk (qsfp0_refclk),
    .tx (qsfp0_tx),

    .tx_clock (tx_clock[0]),
    .tx_reset (tx_reset[0]),
    .tx_data (tx_data[0])
);

XCVRWrapper0 xcvr_wrapper_1(
    .clock (system_clock),
    .reset (system_reset),

    .refclk (qsfp1_refclk),
    .tx (qsfp1_tx),

    .tx_clock (tx_clock[1]),
    .tx_reset (tx_reset[1]),
    .tx_data (tx_data[1])
);


wire i2c_scl_input;
wire [3:0] i2c_scl_output;
wire i2c_sda_input;
wire [3:0] i2c_sda_output;

alt_iobuf i2c_scl_iobuf(
    .I (1'b0),
    .OE (~&i2c_scl_output),
    .O (i2c_scl_input),
    .IO (i2c_scl)
);
alt_iobuf i2c_sda_iobuf(
    .I (1'b0),
    .OE (~&i2c_sda_output),
    .O (i2c_sda_input),
    .IO (i2c_sda)
);


wire [3:0] i2c_request;
wire [3:0] i2c_grant;

Arbiter #(
    .REQUEST_COUNT (4)
) arbiter (
    .clock (system_clock),
    .reset (system_reset),

    .request (i2c_request),
    .grant (i2c_grant)
);


wire ds250df810_ready;

DS250DF810 #(
    .CLOCK_FREQUENCY (CLOCK_FREQUENCY)
) ds250df810 (
    .clock (system_clock),
    .reset (system_reset),

    .scl_input (i2c_scl_input),
    .scl_output (i2c_scl_output[0]),
    .sda_input (i2c_sda_input),
    .sda_output (i2c_sda_output[0]),

    .i2c_request (i2c_request[0]),
    .i2c_grant (i2c_grant[0]),

    .ready (ds250df810_ready)
);


wire fpc202_ready;
wire [3:0] fpc202_in_a;
wire [3:0] fpc202_in_b;
wire [3:0] fpc202_in_c;
wire [3:0] fpc202_out_a;
wire [3:0] fpc202_out_b;

FPC202 #(
    .CLOCK_FREQUENCY (CLOCK_FREQUENCY)
) fpc202 (
    .clock (system_clock),
    .reset (system_reset),

    .scl_input (i2c_scl_input),
    .scl_output (i2c_scl_output[1]),
    .sda_input (i2c_sda_input),
    .sda_output (i2c_sda_output[1]),

    .i2c_request (i2c_request[1]),
    .i2c_grant (i2c_grant[1]),

    .ready (fpc202_ready),
    .in_a (fpc202_in_a),
    .in_b (fpc202_in_b),
    .in_c (fpc202_in_c),
    .out_a (fpc202_out_a),
    .out_b (fpc202_out_b)
);

wire [1:0] qsfp_modprsl = { fpc202_in_b[2], fpc202_in_b[0] };
wire [1:0] qsfp_intl = { fpc202_in_a[2], fpc202_in_a[0] };
wire [1:0] qsfp_resetl;
wire [1:0] qsfp_lpmode;
assign fpc202_out_a = { 1'b0, qsfp_resetl[1], 1'b0, qsfp_resetl[0] };
assign fpc202_out_b = { 1'b0, qsfp_lpmode[1], 1'b0, qsfp_lpmode[0] };


wire init_ready = ds250df810_ready & fpc202_ready;

wire [1:0] hpd = { ~qsfp_modprsl[1], ~qsfp_modprsl[0] };
wire [1:0] run;

localparam FPC202_PORT_0_DEVICE_0_ADDRESS = 7'h78;
localparam FPC202_PORT_0_DEVICE_1_ADDRESS = 7'h79;
localparam FPC202_PORT_1_DEVICE_0_ADDRESS = 7'h7C;
localparam FPC202_PORT_1_DEVICE_1_ADDRESS = 7'h7D;

genvar i;

generate
    for (i = 0; i < 2; i = i + 1) begin: hdmi_out_examples
        HDMIOUTExample #(
            .CLOCK_FREQUENCY (CLOCK_FREQUENCY),
            .RESOLUTION (`RESOLUTION),
            .REFRESH_RATE (`REFRESH_RATE),
            .SCDC_ADDRESS (i == 0 ? FPC202_PORT_0_DEVICE_0_ADDRESS : FPC202_PORT_1_DEVICE_0_ADDRESS),
            .NB7NQ621M_ADDRESS (i == 0 ? FPC202_PORT_0_DEVICE_1_ADDRESS : FPC202_PORT_1_DEVICE_1_ADDRESS)
        ) hdmi_out_example(
            .system_clock (system_clock),
            .system_reset (system_reset | ~init_ready),
            .tx_clock (tx_clock[i]),
            .tx_reset (tx_reset[i]),
            .tx_data (tx_data[i]),
            .hpd (hpd[i]),
            .scl_input (i2c_scl_input),
            .scl_output (i2c_scl_output[2 + i]),
            .sda_input (i2c_sda_input),
            .sda_output (i2c_sda_output[2 + i]),
            .i2c_request (i2c_request[2 + i]),
            .i2c_grant (i2c_grant[2 + i]),
            .run (run[i])
        );

        assign qsfp_resetl[i] = ~system_reset & init_ready;
        assign qsfp_lpmode[i] = 1'b0;
    end
endgenerate

assign led = {
    ~system_reset & init_ready,
    ~system_reset,
    ~system_reset & run[1],
    ~system_reset & hpd[1] & ~run[1],
    ~system_reset & run[0],
    ~system_reset & hpd[0] & ~run[0]
};

endmodule
