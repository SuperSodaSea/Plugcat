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

    output valid,
    input ready,
    input [6:0] address,
    input rw, // 0: Write, 1: Read
    input [7:0] register,
    input [7:0] data_write,
    output ack // 0: ACK, 1: NACK
);

localparam
    STATE_IDLE = 0,
    STATE_START = 1,
    STATE_STOP = 2,
    STATE_WRITE = 3,
    STATE_READ_ACK = 4,
    STATE_DONE = 5;

localparam COUNT_RESET_VALUE = CLOCK_FREQUENCY / FREQUENCY / 4 - 1;

reg scl_output_reg;
reg sda_output_reg;
reg valid_reg;
reg ack_reg;

reg [7:0] data_reg[0:2];
reg [1:0] data_index;
reg [2:0] data_bit_index;
reg [31:0] count;
reg [1:0] phase;

reg [2:0] state;

always @(posedge clock) begin
    if (reset) begin
        state <= STATE_IDLE;
        scl_output_reg <= 1;
        sda_output_reg <= 1;
        valid_reg <= 0;
        ack_reg <= 0;
    end else begin
        case (state)
        STATE_IDLE:
            if (ready) begin
                state <= STATE_START;
                data_reg[0] <= { address, rw };
                data_reg[1] <= register;
                data_reg[2] <= data_write;
                count <= COUNT_RESET_VALUE;
                phase <= 0;
            end
        STATE_START:
            if (count != 0) begin
                count <= count - 1;
            end else begin
                case (phase)
                2:
                    sda_output_reg <= 0;
                3: begin
                    scl_output_reg <= 0;
                    data_index <= 0;
                    data_bit_index <= 7;
                    state <= STATE_WRITE;
                end
                endcase
                count <= COUNT_RESET_VALUE;
                phase <= phase + 1;
            end
        STATE_STOP:
            if (count != 0) begin
                count <= count - 1;
            end else begin
                case (phase)
                0:
                    sda_output_reg <= 0;
                1:
                    scl_output_reg <= 1;
                2:
                    sda_output_reg <= 1;
                3: begin
                    valid_reg <= 1;
                    state <= STATE_DONE;
                end
                endcase
                count <= COUNT_RESET_VALUE;
                phase <= phase + 1;
            end
        STATE_WRITE:
            if (count != 0) begin
                count <= count - 1;
            end else begin
                case (phase)
                0:
                    sda_output_reg <= data_reg[data_index][data_bit_index];
                1:
                    scl_output_reg <= 1;
                3: begin
                    scl_output_reg <= 0;
                    if (data_bit_index != 0) begin
                        data_bit_index <= data_bit_index - 1;
                    end else begin
                        state <= STATE_READ_ACK;
                    end
                end
                endcase
                count <= COUNT_RESET_VALUE;
                phase <= phase + 1;
            end
        STATE_READ_ACK:
            if (count != 0) begin
                count <= count - 1;
            end else begin
                case (phase)
                0:
                    sda_output_reg <= 1;
                1:
                    scl_output_reg <= 1;
                2:
                    ack_reg <= sda_input;
                3: begin
                    scl_output_reg <= 0;
                    if (~ack_reg & (data_index != 2)) begin
                        data_index <= data_index + 1;
                        data_bit_index <= 7;
                        state <= STATE_WRITE;
                    end else begin
                        state <= STATE_STOP;
                    end
                end
                endcase
                count <= COUNT_RESET_VALUE;
                phase <= phase + 1;
            end
        STATE_DONE: begin
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
assign valid = valid_reg;
assign ack = ack_reg;

endmodule
