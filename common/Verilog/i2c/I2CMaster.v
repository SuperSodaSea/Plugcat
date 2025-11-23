module I2CMaster #(
    parameter CLOCK_FREQUENCY = 0,
    parameter FREQUENCY = 0
) (
    input clock,
    input reset,

    input scl_input,
    output scl_output,
    input sda_input,
    output sda_output,

    output request,
    input grant,

    output valid,
    input ready,
    input [6:0] address,
    input rw, // 0: Write, 1: Read
    input [7:0] register,
    input [7:0] data_write,
    output nack, // 0: ACK, 1: NACK
    output [7:0] data_read
);

localparam
    STATE_IDLE = 0,
    STATE_WAIT_ARBITRATION = 1,
    STATE_START = 2,
    STATE_STOP = 3,
    STATE_WRITE_ADDRESS_WRITE = 4,
    STATE_READ_ACK_1 = 5,
    STATE_WRITE_REGISTER = 6,
    STATE_READ_ACK_2 = 7,
    STATE_WRITE_DATA = 8,
    STATE_READ_ACK_3 = 9,
    STATE_RESTART = 10,
    STATE_WRITE_ADDRESS_READ = 11,
    STATE_READ_ACK_4 = 12,
    STATE_READ_DATA = 13,
    STATE_WRITE_NACK = 14,
    STATE_DONE = 15;

localparam COUNT_RESET_VALUE = CLOCK_FREQUENCY / FREQUENCY / 4 - 1;

reg scl_output_reg;
reg sda_output_reg;
reg request_reg;
reg valid_reg;
reg nack_reg;
reg [7:0] data_read_reg;

reg [7:0] data_write_reg;
reg [2:0] data_bit_index;
reg [31:0] count;
reg [1:0] phase;

reg [3:0] state;

always @(posedge clock) begin
    if (reset) begin
        state <= STATE_IDLE;
        scl_output_reg <= 1'b1;
        sda_output_reg <= 1'b1;
        request_reg <= 1'b0;
        valid_reg <= 1'b0;
        nack_reg <= 1'b0;
    end else begin
        case (state)
        STATE_IDLE:
            if (ready) begin
                request_reg <= 1'b1;
                state <= STATE_WAIT_ARBITRATION;
            end
        STATE_WAIT_ARBITRATION:
            if (grant) begin
                count <= COUNT_RESET_VALUE;
                phase <= 2'd0;
                state <= STATE_START;
            end
        STATE_START:
            if (count != 32'd0) begin
                count <= count - 32'd1;
            end else begin
                case (phase)
                2:
                    sda_output_reg <= 1'b0;
                3: begin
                    scl_output_reg <= 1'b0;
                    data_write_reg <= { address, 1'b0 };
                    data_bit_index <= 3'd7;
                    state <= STATE_WRITE_ADDRESS_WRITE;
                end
                endcase
                count <= COUNT_RESET_VALUE;
                phase <= phase + 2'd1;
            end
        STATE_STOP:
            if (count != 32'd0) begin
                count <= count - 32'd1;
            end else begin
                case (phase)
                0:
                    sda_output_reg <= 1'b0;
                1:
                    scl_output_reg <= 1'b1;
                2:
                    sda_output_reg <= 1'b1;
                3: begin
                    valid_reg <= 1'b1;
                    state <= STATE_DONE;
                end
                endcase
                count <= COUNT_RESET_VALUE;
                phase <= phase + 2'd1;
            end
        STATE_WRITE_ADDRESS_WRITE,
        STATE_WRITE_REGISTER,
        STATE_WRITE_DATA,
        STATE_WRITE_ADDRESS_READ:
            if (count != 32'd0) begin
                count <= count - 32'd1;
            end else if (phase == 2'd2 && scl_input == 1'b0) begin
                // Clock stretching
            end else begin
                case (phase)
                0:
                    sda_output_reg <= data_write_reg[7];
                1:
                    scl_output_reg <= 1'b1;
                3: begin
                    scl_output_reg <= 1'b0;
                    if (data_bit_index != 3'd0) begin
                        data_write_reg <= data_write_reg << 1;
                        data_bit_index <= data_bit_index - 3'd1;
                    end else begin
                        case (state)
                        STATE_WRITE_ADDRESS_WRITE: state <= STATE_READ_ACK_1;
                        STATE_WRITE_REGISTER: state <= STATE_READ_ACK_2;
                        STATE_WRITE_DATA: state <= STATE_READ_ACK_3;
                        STATE_WRITE_ADDRESS_READ: state <= STATE_READ_ACK_4;
                        endcase
                    end
                end
                endcase
                count <= COUNT_RESET_VALUE;
                phase <= phase + 2'd1;
            end
        STATE_READ_ACK_1,
        STATE_READ_ACK_2,
        STATE_READ_ACK_3,
        STATE_READ_ACK_4:
            if (count != 32'd0) begin
                count <= count - 32'd1;
            end else if (phase == 2'd2 && scl_input == 1'b0) begin
                // Clock stretching
            end else begin
                case (phase)
                0:
                    sda_output_reg <= 1'b1;
                1:
                    scl_output_reg <= 1'b1;
                2:
                    nack_reg <= sda_input;
                3: begin
                    scl_output_reg <= 1'b0;
                    if (nack_reg) begin
                        state <= STATE_STOP;
                    end else begin
                        case (state)
                        STATE_READ_ACK_1: begin
                            data_write_reg <= register;
                            data_bit_index <= 3'd7;
                            state <= STATE_WRITE_REGISTER;
                        end
                        STATE_READ_ACK_2: begin
                            if (~rw) begin
                                data_write_reg <= data_write;
                                data_bit_index <= 3'd7;
                                state <= STATE_WRITE_DATA;
                            end else begin
                                state <= STATE_RESTART;
                            end
                        end
                        STATE_READ_ACK_3: begin
                            state <= STATE_STOP;
                        end
                        STATE_READ_ACK_4: begin
                            data_bit_index <= 3'd7;
                            state <= STATE_READ_DATA;
                        end
                        endcase
                    end
                end
                endcase
                count <= COUNT_RESET_VALUE;
                phase <= phase + 2'd1;
            end
        STATE_RESTART:
            if (count != 32'd0) begin
                count <= count - 32'd1;
            end else begin
                case (phase)
                0:
                    sda_output_reg <= 1'b1;
                1:
                    scl_output_reg <= 1'b1;
                2:
                    sda_output_reg <= 1'b0;
                3: begin
                    scl_output_reg <= 1'b0;
                    data_write_reg <= { address, 1'b1 };
                    data_bit_index <= 3'd7;
                    state <= STATE_WRITE_ADDRESS_READ;
                end
                endcase
                count <= COUNT_RESET_VALUE;
                phase <= phase + 2'd1;
            end
        STATE_READ_DATA:
            if (count != 32'd0) begin
                count <= count - 32'd1;
            end else if (phase == 2'd2 && scl_input == 1'b0) begin
                // Clock stretching
            end else begin
                case (phase)
                1:
                    scl_output_reg <= 1'b1;
                2:
                    data_read_reg <= (data_read_reg << 1) | sda_input;
                3: begin
                    scl_output_reg <= 1'b0;
                    if (data_bit_index != 3'd0) begin
                        data_bit_index <= data_bit_index - 3'd1;
                    end else begin
                        state <= STATE_WRITE_NACK;
                    end
                end
                endcase
                count <= COUNT_RESET_VALUE;
                phase <= phase + 2'd1;
            end
        STATE_WRITE_NACK:
            if (count != 32'd0) begin
                count <= count - 32'd1;
            end else if (phase == 2'd2 && scl_input == 1'b0) begin
                // Clock stretching
            end else begin
                case (phase)
                0:
                    sda_output_reg <= 1'b1;
                1:
                    scl_output_reg <= 1'b1;
                3: begin
                    scl_output_reg <= 1'b0;
                    state <= STATE_STOP;
                end
                endcase
                count <= COUNT_RESET_VALUE;
                phase <= phase + 2'd1;
            end
        STATE_DONE: begin
            request_reg <= 0;
            valid_reg <= 0;
            state <= STATE_IDLE;
        end
        default:
            state <= STATE_IDLE;
        endcase
    end
end

assign scl_output = scl_output_reg;
assign sda_output = sda_output_reg;
assign request = request_reg;
assign valid = valid_reg;
assign nack = nack_reg;
assign data_read = data_read_reg;

endmodule
