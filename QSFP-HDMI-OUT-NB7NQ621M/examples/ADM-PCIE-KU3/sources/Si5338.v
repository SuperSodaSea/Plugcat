module Si5338 #(
    parameter CLOCK_FREQUENCY = 0,
    parameter REFERENCE_CLOCK_FREQUENCY = 0
) (
    input clock,
    input reset,

    input scl_input,
    output scl_output,
    input sda_input,
    output sda_output,

    output ready
);

localparam SI5338_ADDRESS = 7'h70;

localparam
    STATE_RESET = 0,
    STATE_START = 1,
    STATE_READ = 2,
    STATE_WRITE = 3,
    STATE_WAIT_READ = 4,
    STATE_WAIT_25MS = 5,
    STATE_COPY_FCAL_READ_1 = 6,
    STATE_COPY_FCAL_WRITE_1 = 7,
    STATE_COPY_FCAL_READ_2 = 8,
    STATE_COPY_FCAL_WRITE_2 = 9,
    STATE_COPY_FCAL_READ_3 = 10,
    STATE_COPY_FCAL_WRITE_3 = 11,
    STATE_READY = 12;

localparam
    COMMAND_WRITE = 8'd0,
    COMMAND_WAIT_READ = 8'd1,
    COMMAND_WAIT_25MS = 8'd2,
    COMMAND_COPY_FCAL = 8'd3,
    COMMAND_READY = 8'd4;


wire [2:0] P1DIV;
wire [2:0] R0DIV;
wire [2:0] R1DIV;
wire [2:0] R2DIV;
wire [2:0] R3DIV;
wire [6:0] PLL_KPHI;
wire [2:0] VCO_GAIN;
wire [1:0] RSEL;
wire [1:0] BWSEL;
wire [5:0] MSCAL;
wire [17:0] MS0_P1;
wire [29:0] MS0_P2;
wire [29:0] MS0_P3;
wire [17:0] MS1_P1;
wire [29:0] MS1_P2;
wire [29:0] MS1_P3;
wire [17:0] MS2_P1;
wire [29:0] MS2_P2;
wire [29:0] MS2_P3;
wire [17:0] MS3_P1;
wire [29:0] MS3_P2;
wire [29:0] MS3_P3;
wire [17:0] MSN_P1;
wire [29:0] MSN_P2;
wire [29:0] MSN_P3;

generate
    if (REFERENCE_CLOCK_FREQUENCY == 121_584_000) begin
        assign P1DIV = 3'd2; // P1 = 4
        assign R0DIV = 3'd0; // R0 = 1
        assign R1DIV = 3'd0; // R1 = 1
        assign R2DIV = 3'd0; // R2 = 1
        assign R3DIV = 3'd0; // R3 = 1
        // PLL Parameters
        assign PLL_KPHI = 7'd61;
        assign VCO_GAIN = 3'd0;
        assign RSEL = 2'd0;
        assign BWSEL = 2'd0;
        assign MSCAL = 6'd4;
        // MS0 = 20
        assign MS0_P1 = 18'd2048;
        assign MS0_P2 = 30'd0;
        assign MS0_P3 = 30'd1;
        // MS1 = 9 + 2271/3125 = 9.72672
        assign MS1_P1 = 18'd733;
        assign MS1_P2 = 30'd63;
        assign MS1_P3 = 30'd3125;
        // MS2 = 20
        assign MS2_P1 = 18'd2048;
        assign MS2_P2 = 30'd0;
        assign MS2_P3 = 30'd1;
        // MS3 = 24 + 198/625 = 24.3168
        assign MS3_P1 = 18'd2600;
        assign MS3_P2 = 30'd344;
        assign MS3_P3 = 30'd625;
        // MSN = 97 + 167/625 = 97.2672
        assign MSN_P1 = 18'd11938;
        assign MSN_P2 = 30'd126;
        assign MSN_P3 = 30'd625;
    end else if (REFERENCE_CLOCK_FREQUENCY == 148_500_000) begin
        assign P1DIV = 3'd2; // P1 = 4
        assign R0DIV = 3'd0; // R0 = 1
        assign R1DIV = 3'd0; // R1 = 1
        assign R2DIV = 3'd0; // R2 = 1
        assign R3DIV = 3'd0; // R3 = 1
        // PLL Parameters
        assign PLL_KPHI = 7'd48;
        assign VCO_GAIN = 3'd1;
        assign RSEL = 2'd0;
        assign BWSEL = 2'd0;
        assign MSCAL = 6'd5;
        // MS0 = 16
        assign MS0_P1 = 18'd1536;
        assign MS0_P2 = 30'd0;
        assign MS0_P3 = 30'd1;
        // MS1 = 9 + 63/125 = 9.504
        assign MS1_P1 = 18'd704;
        assign MS1_P2 = 30'd64;
        assign MS1_P3 = 30'd125;
        // MS2 = 16
        assign MS2_P1 = 18'd1536;
        assign MS2_P2 = 30'd0;
        assign MS2_P3 = 30'd1;
        // MS3 = 23 + 19/25 = 23.76
        assign MS3_P1 = 18'd2529;
        assign MS3_P2 = 30'd7;
        assign MS3_P3 = 30'd25;
        // MSN = 95 + 1/25 = 95.04
        assign MSN_P1 = 18'd11653;
        assign MSN_P2 = 30'd3;
        assign MSN_P3 = 30'd25;
    end
endgenerate


function [31:0] COMMANDS(
    input [6:0] index
);
    case (index)
    // Select Page 0
    0: COMMANDS = { COMMAND_WRITE, 8'd255, 8'h00, 8'hFF }; // PAGE_SEL = 0

    // Disable Output
    1: COMMANDS = { COMMAND_WRITE, 8'd230, 8'h10, 8'hFF }; // OEB_ALL = 1, OEB_3 = 0, OEB_2 = 0, OEB_1 = 0, OEB_0 = 0

    // Disable LOL
    2: COMMANDS = { COMMAND_WRITE, 8'd241, 8'hE5, 8'hFF }; // DIS_LOL = 1

    // Start Write Configuration

    // Mask Bits
    3: COMMANDS = { COMMAND_WRITE, 8'd6, 8'h08, 8'h1D }; // PLL_LOL_MASK = 0, LOS_FDBK_MASK = 1, LOS_CLKIN_MASK = 0, SYS_CAL_MASK = 0

    // Input Mux Configuration
    4: COMMANDS = { COMMAND_WRITE, 8'd28, 8'h00, 8'hFF }; // P2DIV_IN = 0b100, P1DIV_IN = 0b00000, XTAL_FREQ = 0b00
    5: COMMANDS = { COMMAND_WRITE, 8'd29, { 5'b01000, P1DIV }, 8'hFF }; // PFD_IN_REF = 0b010, P1DIV
    6: COMMANDS = { COMMAND_WRITE, 8'd30, 8'hB0, 8'hFF }; // PFD_IN_FB = 0b101, P2DIV = 0b000

    // Output Configuration
    7: COMMANDS = { COMMAND_WRITE, 8'd31, { 3'b110, R0DIV, 2'b00 }, 8'hFF }; // R0DIV_IN = 0b110, R0DIV, MS0_PDN = 0, DRV0_PDN = 0
    8: COMMANDS = { COMMAND_WRITE, 8'd32, { 3'b110, R1DIV, 2'b00 }, 8'hFF }; // R1DIV_IN = 0b110, R1DIV, MS1_PDN = 0, DRV1_PDN = 0
    9: COMMANDS = { COMMAND_WRITE, 8'd33, { 3'b110, R2DIV, 2'b00 }, 8'hFF }; // R2DIV_IN = 0b110, R2DIV, MS2_PDN = 0, DRV2_PDN = 0
    10: COMMANDS = { COMMAND_WRITE, 8'd34, { 3'b110, R3DIV, 2'b00 }, 8'hFF }; // R3DIV_IN = 0b110, R3DIV, MS3_PDN = 0, DRV3_PDN = 0

    // PLL Configuration
    11: COMMANDS = { COMMAND_WRITE, 8'd48, { 1'b0, PLL_KPHI }, 8'hFF }; // PFD_EXTFB = 0, PLL_KPHI
    12: COMMANDS = { COMMAND_WRITE, 8'd49, { 1'b0, VCO_GAIN, RSEL, BWSEL }, 8'hFF }; // FCAL_OVRD_EN = 0, VCO_GAIN, RSEL, BWSEL
    13: COMMANDS = { COMMAND_WRITE, 8'd50, { 2'b11, MSCAL }, 8'hFF }; // PLL_ENABLE = 0b11, MSCAL
    14: COMMANDS = { COMMAND_WRITE, 8'd51, 8'h07, 8'hFF }; // MS3_HS = 0, MS2_HS = 0, MS1_HS = 0, MS0_HS = 0, MS_PEC = 0b111

    // MultiSynth0 Frequency Configuration
    15: COMMANDS = { COMMAND_WRITE, 8'd52, 8'h10, 8'h7F }; // MS0_FIDCT = 0b00, MS0_FIDDIS = 1, MS0_SSMODE = 0b00, MS0_PHIDCT = 0b00
    16: COMMANDS = { COMMAND_WRITE, 8'd53, MS0_P1[7:0], 8'hFF }; // MS0_P1
    17: COMMANDS = { COMMAND_WRITE, 8'd54, MS0_P1[15:8], 8'hFF };
    18: COMMANDS = { COMMAND_WRITE, 8'd55, { MS0_P2[5:0], MS0_P1[17:16] }, 8'hFF }; // MS0_P2
    19: COMMANDS = { COMMAND_WRITE, 8'd56, MS0_P2[13:6], 8'hFF };
    20: COMMANDS = { COMMAND_WRITE, 8'd57, MS0_P2[21:14], 8'hFF };
    21: COMMANDS = { COMMAND_WRITE, 8'd58, MS0_P2[29:22], 8'hFF };
    22: COMMANDS = { COMMAND_WRITE, 8'd59, MS0_P3[7:0], 8'hFF }; // MS0_P3
    23: COMMANDS = { COMMAND_WRITE, 8'd60, MS0_P3[15:8], 8'hFF };
    24: COMMANDS = { COMMAND_WRITE, 8'd61, MS0_P3[23:16], 8'hFF };
    25: COMMANDS = { COMMAND_WRITE, 8'd62, { 2'b00, MS0_P3[29:24] }, 8'h3F };

    // MultiSynth1 Frequency Configuration
    26: COMMANDS = { COMMAND_WRITE, 8'd63, 8'h10, 8'h7F }; // MS1_FIDCT = 0b00, MS1_FIDDIS = 1, MS1_SSMODE = 0b00, MS1_PHIDCT = 0b00
    27: COMMANDS = { COMMAND_WRITE, 8'd64, MS1_P1[7:0], 8'hFF }; // MS1_P1
    28: COMMANDS = { COMMAND_WRITE, 8'd65, MS1_P1[15:8], 8'hFF };
    29: COMMANDS = { COMMAND_WRITE, 8'd66, { MS1_P2[5:0], MS1_P1[17:16] }, 8'hFF }; // MS1_P2
    30: COMMANDS = { COMMAND_WRITE, 8'd67, MS1_P2[13:6], 8'hFF };
    31: COMMANDS = { COMMAND_WRITE, 8'd68, MS1_P2[21:14], 8'hFF };
    32: COMMANDS = { COMMAND_WRITE, 8'd69, MS1_P2[29:22], 8'hFF };
    33: COMMANDS = { COMMAND_WRITE, 8'd70, MS1_P3[7:0], 8'hFF }; // MS1_P3
    34: COMMANDS = { COMMAND_WRITE, 8'd71, MS1_P3[15:8], 8'hFF };
    35: COMMANDS = { COMMAND_WRITE, 8'd72, MS1_P3[23:16], 8'hFF };
    36: COMMANDS = { COMMAND_WRITE, 8'd73, { 2'b00, MS1_P3[29:24] }, 8'h3F };

    // MultiSynth2 Frequency Configuration
    37: COMMANDS = { COMMAND_WRITE, 8'd74, 8'h10, 8'h7F }; // MS2_FIDCT = 0b00, MS2_FIDDIS = 1, MS2_SSMODE = 0b00, MS2_PHIDCT = 0b00
    38: COMMANDS = { COMMAND_WRITE, 8'd75, MS2_P1[7:0], 8'hFF }; // MS2_P1
    39: COMMANDS = { COMMAND_WRITE, 8'd76, MS2_P1[15:8], 8'hFF };
    40: COMMANDS = { COMMAND_WRITE, 8'd77, { MS2_P2[5:0], MS2_P1[17:16] }, 8'hFF }; // MS2_P2
    41: COMMANDS = { COMMAND_WRITE, 8'd78, MS2_P2[13:6], 8'hFF };
    42: COMMANDS = { COMMAND_WRITE, 8'd79, MS2_P2[21:14], 8'hFF };
    43: COMMANDS = { COMMAND_WRITE, 8'd80, MS2_P2[29:22], 8'hFF };
    44: COMMANDS = { COMMAND_WRITE, 8'd81, MS2_P3[7:0], 8'hFF }; // MS2_P3
    45: COMMANDS = { COMMAND_WRITE, 8'd82, MS2_P3[15:8], 8'hFF };
    46: COMMANDS = { COMMAND_WRITE, 8'd83, MS2_P3[23:16], 8'hFF };
    47: COMMANDS = { COMMAND_WRITE, 8'd84, { 2'b00, MS2_P3[29:24] }, 8'h3F };

    // MultiSynth3 Frequency Configuration
    48: COMMANDS = { COMMAND_WRITE, 8'd85, 8'h10, 8'h7F }; // MS3_FIDCT = 0b00, MS3_FIDDIS = 1, MS3_SSMODE = 0b00, MS3_PHIDCT = 0b00
    49: COMMANDS = { COMMAND_WRITE, 8'd86, MS3_P1[7:0], 8'hFF }; // MS3_P1
    50: COMMANDS = { COMMAND_WRITE, 8'd87, MS3_P1[15:8], 8'hFF };
    51: COMMANDS = { COMMAND_WRITE, 8'd88, { MS3_P2[5:0], MS3_P1[17:16] }, 8'hFF }; // MS3_P2
    52: COMMANDS = { COMMAND_WRITE, 8'd89, MS3_P2[13:6], 8'hFF };
    53: COMMANDS = { COMMAND_WRITE, 8'd90, MS3_P2[21:14], 8'hFF };
    54: COMMANDS = { COMMAND_WRITE, 8'd91, MS3_P2[29:22], 8'hFF };
    55: COMMANDS = { COMMAND_WRITE, 8'd92, MS3_P3[7:0], 8'hFF }; // MS3_P3
    56: COMMANDS = { COMMAND_WRITE, 8'd93, MS3_P3[15:8], 8'hFF };
    57: COMMANDS = { COMMAND_WRITE, 8'd94, MS3_P3[23:16], 8'hFF };
    58: COMMANDS = { COMMAND_WRITE, 8'd95, { 2'b00, MS3_P3[29:24] }, 8'h3F };

    // MultiSynthN Frequency Configuration
    59: COMMANDS = { COMMAND_WRITE, 8'd97, MSN_P1[7:0], 8'hFF }; // MSN_P1
    60: COMMANDS = { COMMAND_WRITE, 8'd98, MSN_P1[15:8], 8'hFF };
    61: COMMANDS = { COMMAND_WRITE, 8'd99, { MSN_P2[5:0], MSN_P1[17:16] }, 8'hFF }; // MSN_P2
    62: COMMANDS = { COMMAND_WRITE, 8'd100, MSN_P2[13:6], 8'hFF };
    63: COMMANDS = { COMMAND_WRITE, 8'd101, MSN_P2[21:14], 8'hFF };
    64: COMMANDS = { COMMAND_WRITE, 8'd102, MSN_P2[29:22], 8'hFF };
    65: COMMANDS = { COMMAND_WRITE, 8'd103, MSN_P3[7:0], 8'hFF }; // MSN_P3
    66: COMMANDS = { COMMAND_WRITE, 8'd104, MSN_P3[15:8], 8'hFF };
    67: COMMANDS = { COMMAND_WRITE, 8'd105, MSN_P3[23:16], 8'hFF };
    68: COMMANDS = { COMMAND_WRITE, 8'd106, { 2'b10, MSN_P3[29:24] }, 8'hBF };

    // MultiSynth0 Phase Configuration
    69: COMMANDS = { COMMAND_WRITE, 8'd107, 8'h00, 8'hFF }; // MS0_PHOFF = 0
    70: COMMANDS = { COMMAND_WRITE, 8'd108, 8'h00, 8'h7F };
    71: COMMANDS = { COMMAND_WRITE, 8'd109, 8'h00, 8'hFF }; // MS0_PHSTEP = 0
    72: COMMANDS = { COMMAND_WRITE, 8'd110, 8'h00, 8'hFF }; // CLK0_DISST = 0

    // MultiSynth1 Phase Configuration
    73: COMMANDS = { COMMAND_WRITE, 8'd111, 8'h00, 8'hFF }; // MS1_PHOFF = 0
    74: COMMANDS = { COMMAND_WRITE, 8'd112, 8'h00, 8'h7F };
    75: COMMANDS = { COMMAND_WRITE, 8'd113, 8'h00, 8'hFF }; // MS1_PHSTEP = 0
    76: COMMANDS = { COMMAND_WRITE, 8'd114, 8'h00, 8'hFF }; // CLK1_DISST = 0

    // MultiSynth2 Phase Configuration
    77: COMMANDS = { COMMAND_WRITE, 8'd115, 8'h00, 8'hFF }; // MS2_PHOFF = 0
    78: COMMANDS = { COMMAND_WRITE, 8'd116, 8'h80, 8'hFF };
    79: COMMANDS = { COMMAND_WRITE, 8'd117, 8'h00, 8'hFF }; // MS2_PHSTEP = 0
    80: COMMANDS = { COMMAND_WRITE, 8'd118, 8'h00, 8'hFF }; // CLK2_DISST = 0

    // MultiSynth3 Phase Configuration
    81: COMMANDS = { COMMAND_WRITE, 8'd119, 8'h00, 8'hFF }; // MS3_PHOFF = 0
    82: COMMANDS = { COMMAND_WRITE, 8'd120, 8'h00, 8'hFF };
    83: COMMANDS = { COMMAND_WRITE, 8'd121, 8'h00, 8'hFF }; // MS3_PHSTEP = 0
    84: COMMANDS = { COMMAND_WRITE, 8'd122, 8'h00, 8'hFF }; // CLK3_DISST = 0

    // Disable Increment/Decrement Clock
    85: COMMANDS = { COMMAND_WRITE, 8'd242, 8'h02, 8'h02 }; // DCLK_DIS = 1

    // End Write Configuration

    // Wait Input Clock Valid
    86: COMMANDS = { COMMAND_WAIT_READ, 8'd218, 8'h00, 8'h04 }; // LOS_CLKIN = 0

    // Disable FCAL Override
    87: COMMANDS = { COMMAND_WRITE, 8'd49, 8'h00, 8'h80 }; // FCAL_OVRD_EN = 0

    // Soft Reset
    88: COMMANDS = { COMMAND_WRITE, 8'd246, 8'h02, 8'hFF }; // SOFT_RESET = 1

    // Wait 25ms
    89: COMMANDS = { COMMAND_WAIT_25MS, 24'd0 };

    // Enable LOL
    90: COMMANDS = { COMMAND_WRITE, 8'd241, 8'h65, 8'hFF }; // DIS_LOL = 0

    // Wait PLL Lock
    91: COMMANDS = { COMMAND_WAIT_READ, 8'd218, 8'h00, 8'h11 }; // PLL_LOL = 0, SYS_CAL = 0

    // Copy FCAL
    92: COMMANDS = { COMMAND_COPY_FCAL, 24'd0 };

    // Enable FCAL Override
    93: COMMANDS = { COMMAND_WRITE, 8'd49, 8'h80, 8'h80 }; // FCAL_OVRD_EN = 1

    // Enable Output
    94: COMMANDS = { COMMAND_WRITE, 8'd230, 8'h00, 8'hFF }; // OEB_ALL = 0, OEB_3 = 0, OEB_2 = 0, OEB_1 = 0, OEB_0 = 0

    default: COMMANDS = { COMMAND_READY, 24'd0 };
    endcase
endfunction


wire i2c_valid;
reg i2c_ready;
reg i2c_rw;
reg [7:0] i2c_register;
reg [7:0] i2c_data_write;
wire i2c_nack;
wire [7:0] i2c_data_read;

I2CMaster #(.CLOCK_FREQUENCY (CLOCK_FREQUENCY), .FREQUENCY(100_000)) i2c_master(
    .clock (clock),
    .reset (reset),

    .scl_input (scl_input),
    .scl_output (scl_output),
    .sda_input (sda_input),
    .sda_output (sda_output),

    .request (),
    .grant (1'b1),

    .valid (i2c_valid),
    .ready (i2c_ready),
    .address (SI5338_ADDRESS),
    .rw (i2c_rw),
    .register (i2c_register),
    .data_write (i2c_data_write),
    .nack (i2c_nack),
    .data_read (i2c_data_read)
);


reg [6:0] command_index;
wire [31:0] command = COMMANDS(command_index);

reg [31:0] wait_count;

reg [4:0] state;

always @(posedge clock) begin
    if (reset) begin
        i2c_ready <= 0;
        state <= STATE_RESET;
    end else begin
        case (state)
        STATE_RESET: begin
            command_index <= 0;
            state <= STATE_START;
        end
        STATE_START: begin
            case (command[31:24])
            COMMAND_WRITE: begin
                i2c_ready <= 1;
                i2c_register <= command[23:16];
                if (command[7:0] == 8'hFF) begin
                    i2c_rw <= 0;
                    i2c_data_write <= command[15:8];
                    state <= STATE_WRITE;
                end else begin
                    i2c_rw <= 1;
                    state <= STATE_READ;
                end
            end
            COMMAND_WAIT_READ: begin
                i2c_ready <= 1;
                i2c_rw <= 1;
                i2c_register <= command[23:16];
                state <= STATE_WAIT_READ;
            end
            COMMAND_WAIT_25MS: begin
                wait_count <= CLOCK_FREQUENCY / 1000 * 25 - 1;
                state <= STATE_WAIT_25MS;
            end
            COMMAND_COPY_FCAL: begin
                i2c_ready <= 1;
                i2c_rw <= 1;
                i2c_register <= 237;
                state <= STATE_COPY_FCAL_READ_1;
            end
            COMMAND_READY: state <= STATE_READY;
            default: state <= STATE_RESET;
            endcase
        end
        STATE_READ:
            if (i2c_valid) begin
                if (i2c_nack) begin
                    i2c_ready <= 0;
                    state <= STATE_RESET;
                end else begin
                    i2c_ready <= 1;
                    i2c_rw <= 0;
                    i2c_data_write <= (i2c_data_read & ~command[7:0]) | (command[15:8] & command[7:0]);
                    state <= STATE_WRITE;
                end
            end
        STATE_WRITE:
            if (i2c_valid) begin
                if (i2c_nack) begin
                    i2c_ready <= 0;
                    state <= STATE_RESET;
                end else begin
                    i2c_ready <= 0;
                    command_index <= command_index + 1;
                    state <= STATE_START;
                end
            end
        STATE_WAIT_READ:
            if (i2c_valid) begin
                if (i2c_nack) begin
                    i2c_ready <= 0;
                    state <= STATE_RESET;
                end else if ((i2c_data_read & command[7:0]) == (command[15:8] & command[7:0])) begin
                    i2c_ready <= 0;
                    command_index <= command_index + 1;
                    state <= STATE_START;
                end
            end
        STATE_WAIT_25MS:
            if (wait_count != 0) begin
                wait_count <= wait_count - 1;
            end else begin
                command_index <= command_index + 1;
                state <= STATE_START;
            end
        STATE_COPY_FCAL_READ_1:
            if (i2c_valid) begin
                if (i2c_nack) begin
                    i2c_ready <= 0;
                    state <= STATE_RESET;
                end else begin
                    i2c_ready <= 1;
                    i2c_rw <= 0;
                    i2c_register <= 47;
                    i2c_data_write <= { 6'b000101, i2c_data_read[1:0] };
                    state <= STATE_COPY_FCAL_WRITE_1;
                end
            end
        STATE_COPY_FCAL_WRITE_1:
            if (i2c_valid) begin
                if (i2c_nack) begin
                    i2c_ready <= 0;
                    state <= STATE_RESET;
                end else begin
                    i2c_ready <= 1;
                    i2c_rw <= 1;
                    i2c_register <= 236;
                    state <= STATE_COPY_FCAL_READ_2;
                end
            end
        STATE_COPY_FCAL_READ_2:
            if (i2c_valid) begin
                if (i2c_nack) begin
                    i2c_ready <= 0;
                    state <= STATE_RESET;
                end else begin
                    i2c_ready <= 1;
                    i2c_rw <= 0;
                    i2c_register <= 46;
                    i2c_data_write <= i2c_data_read;
                    state <= STATE_COPY_FCAL_WRITE_2;
                end
            end
        STATE_COPY_FCAL_WRITE_2:
            if (i2c_valid) begin
                if (i2c_nack) begin
                    i2c_ready <= 0;
                    state <= STATE_RESET;
                end else begin
                    i2c_ready <= 1;
                    i2c_rw <= 1;
                    i2c_register <= 235;
                    state <= STATE_COPY_FCAL_READ_3;
                end
            end
        STATE_COPY_FCAL_READ_3:
            if (i2c_valid) begin
                if (i2c_nack) begin
                    i2c_ready <= 0;
                    state <= STATE_RESET;
                end else begin
                    i2c_ready <= 1;
                    i2c_rw <= 0;
                    i2c_register <= 45;
                    i2c_data_write <= i2c_data_read;
                    state <= STATE_COPY_FCAL_WRITE_3;
                end
            end
        STATE_COPY_FCAL_WRITE_3:
            if (i2c_valid) begin
                if (i2c_nack) begin
                    i2c_ready <= 0;
                    state <= STATE_RESET;
                end else begin
                    i2c_ready <= 0;
                    command_index <= command_index + 1;
                    state <= STATE_START;
                end
            end
        endcase
    end
end

assign ready = state == STATE_READY;

endmodule
