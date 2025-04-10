module IDT8N4Q001 #(
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

localparam IDT8N4Q001_ADDRESS = 7'h6E;

localparam
    STATE_RESET = 0,
    STATE_WRITE_START = 1,
    STATE_WRITE_WAIT = 2,
    STATE_RECALIBRATE_START = 3,
    STATE_RECALIBRATE_WAIT = 4,
    STATE_WAIT = 5,
    STATE_READY = 6;


wire [5:0] MINT;
wire [17:0] MFRAC;
wire [6:0] N;
wire [1:0] P = 2'b00;
wire DG = 1'b1;
wire [1:0] DSM = 2'b11;
wire DSM_ENA = 1'b1;
wire LF = 1'b1;
wire [1:0] CP = 2'b00;
wire [1:0] FSEL = 2'b00;
wire NPLL_BYP = 1'b1;
wire ADC_ENA = 1'b1;

generate
    if (REFERENCE_CLOCK_FREQUENCY == 121_584_000) begin
        // M = 21.88512, N = 18
        assign MINT = 6'd21;
        assign MFRAC = 18'd232028;
        assign N = 7'd18;
    end else if (REFERENCE_CLOCK_FREQUENCY == 145_900_800) begin
        // M = 20.426112, N = 14
        assign MINT = 6'd20;
        assign MFRAC = 18'd111702;
        assign N = 7'd14;
    end else if (REFERENCE_CLOCK_FREQUENCY == 148_500_000) begin
        // M = 20.79, N = 14
        assign MINT = 6'd20;
        assign MFRAC = 18'd207093;
        assign N = 7'd14;
    end
endgenerate


localparam DATA_COUNT = 24;

function [7:0] DATA(
    input [4:0] index
);
    case (index)
    0, 1, 2, 3: DATA = { CP, MINT[4:0], MFRAC[17] };
    4, 5, 6, 7: DATA = MFRAC[16:9];
    8, 9, 10, 11: DATA = MFRAC[8:1];
    12, 13, 14, 15: DATA = { MFRAC[0], N };
    18: DATA = { ADC_ENA, 1'b0, NPLL_BYP, ~FSEL, 3'b0 };
    20, 21, 22, 23: DATA = { P, MINT[5], DSM, DG, DSM_ENA, LF };
    default: DATA = 8'h0;
    endcase
endfunction


wire i2c_valid;
reg i2c_ready;
reg [7:0] i2c_register;
reg [7:0] i2c_data_write;
wire i2c_nack;

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
    .address (IDT8N4Q001_ADDRESS),
    .rw (1'b0),
    .register (i2c_register),
    .data_write (i2c_data_write),
    .nack (i2c_nack),
    .data_read ()
);


reg [4:0] register_index;
wire [7:0] data = DATA(register_index);

reg [31:0] wait_count;

reg [2:0] state;

always @(posedge clock) begin
    if (reset) begin
        i2c_ready <= 0;
        state <= STATE_RESET;
    end else begin
        case (state)
        STATE_RESET: begin
            register_index <= 0;
            state <= STATE_WRITE_START;
        end
        STATE_WRITE_START: begin
            i2c_ready <= 1;
            i2c_register <= register_index;
            i2c_data_write <= data;
            state <= STATE_WRITE_WAIT;
        end
        STATE_WRITE_WAIT: begin
            if (i2c_valid) begin
                i2c_ready <= 0;
                if (i2c_nack) begin
                    state <= STATE_RESET;
                end else begin
                    if (register_index != DATA_COUNT - 1) begin
                        register_index <= register_index + 1;
                        state <= STATE_WRITE_START;
                    end else begin
                        state <= STATE_RECALIBRATE_START;
                    end
                end
            end
        end
        STATE_RECALIBRATE_START: begin
            i2c_ready <= 1;
            i2c_register <= 18;
            i2c_data_write <= { ADC_ENA, 1'b0, NPLL_BYP, FSEL, 3'b0 }; // Toggle FSEL to recalibrate PLL
            state <= STATE_RECALIBRATE_WAIT;
        end
        STATE_RECALIBRATE_WAIT: begin
            if (i2c_valid) begin
                i2c_ready <= 0;
                if (i2c_nack) begin
                    state <= STATE_RESET;
                end else begin
                    wait_count <= CLOCK_FREQUENCY / 1000 - 1; // Wait 1ms
                    state <= STATE_WAIT;
                end
            end
        end
        STATE_WAIT: begin
            if (wait_count != 0) begin
                wait_count <= wait_count - 1;
            end else begin
                state <= STATE_READY;
            end
        end
        endcase
    end
end

assign ready = state == STATE_READY;

endmodule
