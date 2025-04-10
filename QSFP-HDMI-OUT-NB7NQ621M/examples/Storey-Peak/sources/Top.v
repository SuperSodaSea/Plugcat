`ifndef RESOLUTION
    `define RESOLUTION "1920x1080"
`endif
`ifndef REFRESH_RATE
    `define REFRESH_RATE 60
`endif


module Top(
    input clock_125,

    output [7:0] led,

    inout idt8n4q001_scl,
    inout idt8n4q001_sda,

    input qsfp_refclk,

    output [3:0] qsfp0_tx,
    inout qsfp0_scl,
    inout qsfp0_sda,

    output [3:0] qsfp1_tx,
    inout qsfp1_scl,
    inout qsfp1_sda
);

localparam CLOCK_FREQUENCY = 200_000_000;

localparam REFERENCE_CLOCK_FREQUENCY =
    `RESOLUTION == "1920x1080" ? 148_500_000 :
    `RESOLUTION == "2560x1440" ? (`REFRESH_RATE == 144 ? 145_900_800 : 121_584_000) :
    `RESOLUTION == "3840x2160" ? 148_500_000 :
    0;


reg [2:0] system_reset_input_reg = 3'b111;
wire system_reset_input = system_reset_input_reg[0];

always @(posedge clock_125) begin
    system_reset_input_reg <= system_reset_input_reg >> 1;
end

wire system_clock;
wire pll0_locked;

PLL0 pll0 (
    .refclk (clock_125),
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


wire idt8n4q001_scl_input;
wire idt8n4q001_scl_output;
wire idt8n4q001_sda_input;
wire idt8n4q001_sda_output;

alt_iobuf idt8n4q001_scl_iobuf(
    .I (idt8n4q001_scl_output),
    .OE (~idt8n4q001_scl_output),
    .O (idt8n4q001_scl_input),
    .IO (idt8n4q001_scl)
);
alt_iobuf idt8n4q0010_sda_iobuf(
    .I (idt8n4q001_sda_output),
    .OE (~idt8n4q001_sda_output),
    .O (idt8n4q001_sda_input),
    .IO (idt8n4q001_sda)
);

wire idt8n4q001_ready;

IDT8N4Q001 #(
    .CLOCK_FREQUENCY (CLOCK_FREQUENCY),
    .REFERENCE_CLOCK_FREQUENCY (REFERENCE_CLOCK_FREQUENCY)
) idt8n4q001(
    .clock (system_clock),
    .reset (system_reset),

    .scl_input (idt8n4q001_scl_input),
    .scl_output (idt8n4q001_scl_output),
    .sda_input (idt8n4q001_sda_input),
    .sda_output (idt8n4q001_sda_output),

    .ready (idt8n4q001_ready)
);



wire [1:0] tx_clock;
wire [1:0] tx_reset;
wire [159:0] tx_data[1:0];

XCVRWrapper0 xcvr_wrapper_0(
    .clock (system_clock),
    .reset (~idt8n4q001_ready),

    .refclk_0 (qsfp_refclk),
    .tx_0 (qsfp0_tx),

    .tx_clock_0 (tx_clock[0]),
    .tx_reset_0 (tx_reset[0]),
    .tx_data_0 (tx_data[0]),

    .refclk_1 (qsfp_refclk),
    .tx_1 (qsfp1_tx),

    .tx_clock_1 (tx_clock[1]),
    .tx_reset_1 (tx_reset[1]),
    .tx_data_1 (tx_data[1])
);


wire [1:0] qsfp_scl_input;
wire [1:0] qsfp_scl_output;
wire [1:0] qsfp_sda_input;
wire [1:0] qsfp_sda_output;

alt_iobuf qsfp0_scl_iobuf(
    .I (qsfp_scl_output[0]),
    .OE (~qsfp_scl_output[0]),
    .O (qsfp_scl_input[0]),
    .IO (qsfp0_scl)
);
alt_iobuf qsfp0_sda_iobuf(
    .I (qsfp_sda_output[0]),
    .OE (~qsfp_sda_output[0]),
    .O (qsfp_sda_input[0]),
    .IO (qsfp0_sda)
);

alt_iobuf qsfp1_scl_iobuf(
    .I (qsfp_scl_output[1]),
    .OE (~qsfp_scl_output[1]),
    .O (qsfp_scl_input[1]),
    .IO (qsfp1_scl)
);
alt_iobuf qsfp1_sda_iobuf(
    .I (qsfp_sda_output[1]),
    .OE (~qsfp_sda_output[1]),
    .O (qsfp_sda_input[1]),
    .IO (qsfp1_sda)
);

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
            .hpd (1'b1),
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

assign led = {
    ~system_reset & run[1],
    ~system_reset & run[0],
    ~system_reset
};

endmodule
