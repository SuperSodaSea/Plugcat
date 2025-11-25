module FPC202 #(
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

    output ready,
    output [3:0] in_a,
    output [3:0] in_b,
    output [3:0] in_c,
    input [3:0] out_a,
    input [3:0] out_b
);

localparam
    STATE_RESET = 0,
    STATE_WRITE_START = 1,
    STATE_WRITE_WAIT = 2,
    STATE_READ_IN_A_START = 3,
    STATE_READ_IN_A_WAIT = 4,
    STATE_READ_IN_BC_START = 5,
    STATE_READ_IN_BC_WAIT = 6,
    STATE_WRITE_OUT_AB_VALUE_START = 7,
    STATE_WRITE_OUT_AB_VALUE_WAIT = 8,
    STATE_WAIT = 9;

localparam FPC202_ADDRESS = 7'h0F;

localparam FPC202_REGISTER_IN_A = 8'h06;
localparam FPC202_REGISTER_IN_BC = 8'h07;
localparam FPC202_REGISTER_OUT_AB_CONF = 8'h08;
localparam FPC202_REGISTER_OUT_AB_VALUE = 8'h0A;
localparam FPC202_REGISTER_MOD_DEV_P0_D0 = 8'hB4;
localparam FPC202_REGISTER_MOD_DEV_P0_D1 = 8'hB5;
localparam FPC202_REGISTER_AUX_DEV_P0_D0 = 8'hB6;
localparam FPC202_REGISTER_AUX_DEV_P0_D1 = 8'hB7;
localparam FPC202_REGISTER_MOD_DEV_P1_D0 = 8'hB8;
localparam FPC202_REGISTER_MOD_DEV_P1_D1 = 8'hB9;
localparam FPC202_REGISTER_AUX_DEV_P1_D0 = 8'hBA;
localparam FPC202_REGISTER_AUX_DEV_P1_D1 = 8'hBB;

localparam SCDC_ADDRESS = 7'h54;
localparam NB7NQ621M_ADDRESS = 7'h5E;

localparam DATA_COUNT = 10;

function [15:0] DATA(
    input [3:0] index
);
    case (index)
    0: DATA = { FPC202_REGISTER_OUT_AB_CONF, 8'hFF };
    1: DATA = { FPC202_REGISTER_MOD_DEV_P0_D0, { 1'b0, SCDC_ADDRESS } };
    2: DATA = { FPC202_REGISTER_MOD_DEV_P0_D1, { 1'b0, NB7NQ621M_ADDRESS } };
    3: DATA = { FPC202_REGISTER_AUX_DEV_P0_D0, { 1'b0, SCDC_ADDRESS } };
    4: DATA = { FPC202_REGISTER_AUX_DEV_P0_D1, { 1'b0, NB7NQ621M_ADDRESS } };
    5: DATA = { FPC202_REGISTER_MOD_DEV_P1_D0, { 1'b0, SCDC_ADDRESS } };
    6: DATA = { FPC202_REGISTER_MOD_DEV_P1_D1, { 1'b0, NB7NQ621M_ADDRESS } };
    7: DATA = { FPC202_REGISTER_AUX_DEV_P1_D0, { 1'b0, SCDC_ADDRESS } };
    8: DATA = { FPC202_REGISTER_AUX_DEV_P1_D1, { 1'b0, NB7NQ621M_ADDRESS } };
    default: DATA = 16'h0;
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

    .request (i2c_request),
    .grant (i2c_grant),

    .valid (i2c_valid),
    .ready (i2c_ready),
    .address (FPC202_ADDRESS),
    .rw (i2c_rw),
    .register (i2c_register),
    .data_write (i2c_data_write),
    .nack (i2c_nack),
    .data_read (i2c_data_read)
);


reg [3:0] data_index;
wire [15:0] data = DATA(data_index);
reg [31:0] count;

reg ready_reg;
reg [3:0] in_a_reg;
reg [3:0] in_b_reg;
reg [3:0] in_c_reg;

reg [3:0] state;

always @(posedge clock) begin
    if (reset) begin
        i2c_ready <= 1'b0;
        ready_reg <= 1'b0;
        in_a_reg <= 4'b0;
        in_b_reg <= 4'b0;
        in_c_reg <= 4'b0;
        state <= STATE_RESET;
    end else begin
        case (state)
        STATE_RESET: begin
            data_index <= 1'd0;
            state <= STATE_WRITE_START;
        end
        STATE_WRITE_START: begin
            i2c_ready <= 1'b1;
            i2c_rw <= 1'b0;
            i2c_register <= data[15:8];
            i2c_data_write <= data[7:0];
            state <= STATE_WRITE_WAIT;
        end
        STATE_WRITE_WAIT: begin
            if (i2c_valid) begin
                i2c_ready <= 1'b0;
                if (i2c_nack) begin
                    state <= STATE_RESET;
                end else begin
                    if (data_index != DATA_COUNT - 1) begin
                        data_index <= data_index + 1'd1;
                        state <= STATE_WRITE_START;
                    end else begin
                        ready_reg <= 1;
                        state <= STATE_READ_IN_A_START;
                    end
                end
            end
        end
        STATE_READ_IN_A_START: begin
            i2c_ready <= 1'b1;
            i2c_rw <= 1'b1;
            i2c_register <= FPC202_REGISTER_IN_A;
            state <= STATE_READ_IN_A_WAIT;
        end
        STATE_READ_IN_A_WAIT: begin
            if (i2c_valid) begin
                i2c_ready <= 1'b0;
                if (!i2c_nack) begin
                    in_a_reg <= i2c_data_read[7:4];
                end
                state <= STATE_READ_IN_BC_START;
            end
        end
        STATE_READ_IN_BC_START: begin
            i2c_ready <= 1'b1;
            i2c_rw <= 1'b1;
            i2c_register <= FPC202_REGISTER_IN_BC;
            state <= STATE_READ_IN_BC_WAIT;
        end
        STATE_READ_IN_BC_WAIT: begin
            if (i2c_valid) begin
                i2c_ready <= 1'b0;
                if (~i2c_nack) begin
                    in_b_reg <= i2c_data_read[3:0];
                    in_c_reg <= i2c_data_read[7:4];
                end
                state <= STATE_WRITE_OUT_AB_VALUE_START;
            end
        end
        STATE_WRITE_OUT_AB_VALUE_START: begin
            i2c_ready <= 1'b1;
            i2c_rw <= 1'b0;
            i2c_register <= FPC202_REGISTER_OUT_AB_VALUE;
            i2c_data_write <= { out_b, out_a };
            state <= STATE_WRITE_OUT_AB_VALUE_WAIT;
        end
        STATE_WRITE_OUT_AB_VALUE_WAIT: begin
            if (i2c_valid) begin
                i2c_ready <= 1'b0;
                count <= CLOCK_FREQUENCY / 10 - 1;
                state <= STATE_WAIT;
            end
        end
        STATE_WAIT: begin
            if (count != 1'd0) begin
                count <= count - 1'd1;
            end else begin
                state <= STATE_READ_IN_A_START;
            end
        end
        endcase
    end
end

assign ready = ready_reg;
assign in_a = in_a_reg;
assign in_b = in_b_reg;
assign in_c = in_c_reg;

endmodule
