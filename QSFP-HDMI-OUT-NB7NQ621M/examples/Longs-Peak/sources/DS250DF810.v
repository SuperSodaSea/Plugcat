module DS250DF810 #(
    parameter CLOCK_FREQUENCY = 0
) (
    input clock,
    input reset,

    input scl_input,
    output scl_output,
    input sda_input,
    output sda_output,

    output i2c_request,
    input i2c_grant,

    output ready
);

localparam
    STATE_RESET = 0,
    STATE_WRITE_START = 1,
    STATE_WRITE_WAIT = 2,
    STATE_READY = 3;

localparam DS250DF810_ADDRESS = 7'h22;

localparam DATA_COUNT = 4;

function [15:0] DATA(
    input [2:0] index
);
    case (index)
    0: DATA = { 8'hFC, 8'h0F }; // EN_CH = 0b00001111
    1: DATA = { 8'hFF, 8'h01 }; // EN_SHARE_Q1 = 0, EN_SHARE_Q0 = 0, WRITE_ALL_CH = 0, EN_CH_SMB = 1
    2: DATA = { 8'h00, 8'h04 }; // RST_REGS = 1
    3: DATA = { 8'h1E, 8'h09 }; // PFD_SEL_DATA_MUX = 0b000
    default: DATA = 16'h0;
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

    .request (i2c_request),
    .grant (i2c_grant),

    .valid (i2c_valid),
    .ready (i2c_ready),
    .address (DS250DF810_ADDRESS),
    .rw (1'b0),
    .register (i2c_register),
    .data_write (i2c_data_write),
    .nack (i2c_nack),
    .data_read ()
);


reg [2:0] data_index;
wire [15:0] data = DATA(data_index);

reg [1:0] state;

always @(posedge clock) begin
    if (reset) begin
        i2c_ready <= 0;
        state <= STATE_RESET;
    end else begin
        case (state)
        STATE_RESET: begin
            data_index <= 0;
            state <= STATE_WRITE_START;
        end
        STATE_WRITE_START: begin
            i2c_ready <= 1;
            i2c_register <= data[15:8];
            i2c_data_write <= data[7:0];
            state <= STATE_WRITE_WAIT;
        end
        STATE_WRITE_WAIT: begin
            if (i2c_valid) begin
                i2c_ready <= 0;
                if (i2c_nack) begin
                    state <= STATE_RESET;
                end else begin
                    if (data_index != DATA_COUNT - 1) begin
                        data_index <= data_index + 1;
                        state <= STATE_WRITE_START;
                    end else begin
                        state <= STATE_READY;
                    end
                end
            end
        end
        endcase
    end
end

assign ready = state == STATE_READY;

endmodule
