module HDMIOUTExample #(
    parameter CLOCK_FREQUENCY = 0,
    parameter RESOLUTION = "1920x1080",
    parameter REFRESH_RATE = 60
) (
    input system_clock,
    input system_reset,

    input tx_clock,
    input tx_reset,
    output [159:0] tx_data,

    input hpd,
    input scl_input,
    output scl_output,
    input sda_input,
    output sda_output,

    output run
);

localparam
    STATE_IDLE = 0,
    STATE_WAIT = 1,
    STATE_CONFIGURE_NB7NQ621M = 2,
    STATE_CHECK_HDMI_2_0 = 3,
    STATE_CONFIGURE_TMDS = 4,
    STATE_RUN = 5;

localparam COUNT_RESET_VALUE = CLOCK_FREQUENCY / 10 - 1;

localparam SCDC_ADDRESS = 7'h54;
localparam NB7NQ621M_ADDRESS = 7'h5E;


wire [15:0] h_active;
wire [15:0] h_front_porch;
wire [15:0] h_sync;
wire [15:0] h_back_porch;
wire [15:0] v_active;
wire [15:0] v_front_porch;
wire [15:0] v_sync;
wire [15:0] v_back_porch;
wire h_sync_polarity;
wire v_sync_polarity;

if (RESOLUTION == "1920x1080") begin
    assign h_active = 1920;
    assign h_front_porch = 88;
    assign h_sync = 44;
    assign h_back_porch = 148;
    assign v_active = 1080;
    assign v_front_porch = 4;
    assign v_sync = 5;
    assign v_back_porch = 36;
    assign h_sync_polarity = 1;
    assign v_sync_polarity = 1;
end else if (RESOLUTION == "2560x1440") begin
    assign h_active = 2560;
    assign h_front_porch = 8;
    assign h_sync = 32;
    assign h_back_porch = 120;
    assign v_active = 1440;
    assign v_front_porch = 13;
    assign v_sync = 8;
    assign v_back_porch = 29;
    assign h_sync_polarity = 1;
    assign v_sync_polarity = 1;
end else if (RESOLUTION == "3840x2160") begin
    assign h_active = 3840;
    assign h_front_porch = 176;
    assign h_sync = 88;
    assign h_back_porch = 296;
    assign v_active = 2160;
    assign v_front_porch = 8;
    assign v_sync = 10;
    assign v_back_porch = 72;
    assign h_sync_polarity = 1;
    assign v_sync_polarity = 1;
end

wire [15:0] refresh_rate = REFRESH_RATE;

wire [15:0] h_total = h_active + h_front_porch + h_sync + h_back_porch;
wire [15:0] v_total = v_active + v_front_porch + v_sync + v_back_porch;
wire [31:0] tmds_clock_frequency = { 16'b0, refresh_rate } * h_total * v_total;
wire tmds_clock_over_340mhz = tmds_clock_frequency > 340_000_000;

wire scrambler_enable = tmds_clock_over_340mhz;
wire tmds_bit_clock_ratio = tmds_clock_over_340mhz;


localparam NB7NQ621M_I2C_DATA_COUNT = 9;
function [15:0] NB7NQ621M_I2C_DATA(
    input [3:0] index
);
    case (index)
    0: NB7NQ621M_I2C_DATA = { 8'h0A, 8'b00001100 }; // Functional Controls 0
    1: NB7NQ621M_I2C_DATA = { 8'h0B, 8'b00001111 }; // Functional Controls 1
    2: NB7NQ621M_I2C_DATA = { 8'h0C, 8'b00000000 }; // Termination Controls
    3: NB7NQ621M_I2C_DATA = { 8'h0D, 8'b00110000 }; // CLK Controls 0
    4: NB7NQ621M_I2C_DATA = { 8'h0E, 8'b00000011 }; // CLK Controls 1
    5: NB7NQ621M_I2C_DATA = { 8'h0F, 8'b00110000 }; // Data Controls 0
    6: NB7NQ621M_I2C_DATA = { 8'h10, 8'b00000011 }; // Data Controls 1
    7: NB7NQ621M_I2C_DATA = { 8'h11, 8'b00001111 }; // Channel Enable / Disable
    8: NB7NQ621M_I2C_DATA = { 8'h12, 8'b10101010 }; // Channel Signal Detect Threshold
    default: NB7NQ621M_I2C_DATA = 0;
    endcase
endfunction

wire i2c_valid;
reg i2c_ready;
reg [6:0] i2c_address;
reg [15:0] i2c_data;
wire i2c_nack;
reg [3:0] i2c_index;

I2CMaster #(.CLOCK_FREQUENCY (CLOCK_FREQUENCY), .FREQUENCY(100_000)) i2c_master(
    .clock (system_clock),
    .reset (system_reset),

    .scl_input (scl_input),
    .scl_output (scl_output),
    .sda_input (sda_input),
    .sda_output (sda_output),

    .valid (i2c_valid),
    .ready (i2c_ready),
    .address (i2c_address),
    .rw (0),
    .register (i2c_data[15:8]),
    .data_write (i2c_data[7:0]),
    .nack (i2c_nack),
    .data_read ()
);

reg [31:0] wait_count;

reg [2:0] state;

always @(posedge system_clock) begin
    if (system_reset) begin
        i2c_ready <= 0;
        state <= STATE_IDLE;
    end else begin
        case (state)
        STATE_IDLE:
            if (hpd) begin
                wait_count <= COUNT_RESET_VALUE;
                state <= STATE_WAIT;
            end
        STATE_WAIT:
            if (~hpd) begin
                state <= STATE_IDLE;
            end else begin
                if (wait_count != 0) begin
                    wait_count <= wait_count - 1;
                end else begin
                    i2c_ready <= 1;
                    i2c_address <= NB7NQ621M_ADDRESS;
                    i2c_data <= NB7NQ621M_I2C_DATA(0);
                    i2c_index <= 0;
                    state <= STATE_CONFIGURE_NB7NQ621M;
                end
            end
        STATE_CONFIGURE_NB7NQ621M:
            if (~hpd) begin
                i2c_ready <= 0;
                state <= STATE_IDLE;
            end else begin
                if (i2c_valid) begin
                    if (i2c_nack) begin
                        i2c_ready <= 0;
                        wait_count <= COUNT_RESET_VALUE;
                        state <= STATE_WAIT;
                    end else begin
                        if (i2c_index != NB7NQ621M_I2C_DATA_COUNT - 1) begin
                            i2c_data <= NB7NQ621M_I2C_DATA(i2c_index + 1);
                            i2c_index <= i2c_index + 1;
                        end else begin
                            i2c_ready <= 1;
                            i2c_address <= SCDC_ADDRESS;
                            i2c_data <= { 8'h02, 8'h01 }; // Source Version
                            state <= STATE_RUN;
                        end
                    end
                end
            end
        STATE_CHECK_HDMI_2_0:
            if (~hpd) begin
                i2c_ready <= 0;
                state <= STATE_IDLE;
            end else begin
                if (i2c_valid) begin
                    if (i2c_nack) begin
                        // HDMI 2.0 Not Supported
                        i2c_ready <= 0;
                        if (tmds_clock_over_340mhz) begin
                            wait_count <= COUNT_RESET_VALUE;
                            state <= STATE_WAIT;
                        end else begin
                            state <= STATE_RUN;
                        end
                    end else begin
                        // HDMI 2.0 Supported
                        i2c_ready <= 1;
                        i2c_address <= SCDC_ADDRESS;
                        i2c_data <= { 8'h20, { 6'b0, tmds_bit_clock_ratio, scrambler_enable } }; // TMDS Configuration
                        state <= STATE_CONFIGURE_TMDS;
                    end
                end
            end
        STATE_CONFIGURE_TMDS:
            if (~hpd) begin
                i2c_ready <= 0;
                state <= STATE_IDLE;
            end else begin
                if (i2c_valid) begin
                    i2c_ready <= 0;
                    if (i2c_nack) begin
                        wait_count <= COUNT_RESET_VALUE;
                        state <= STATE_WAIT;
                    end else begin
                        state <= STATE_RUN;
                    end
                end
            end
        STATE_RUN:
            if (~hpd) begin
                state <= STATE_IDLE;
            end
        endcase
    end
end

wire start_frame;
wire video_ready;
wire video_valid;
wire [63:0] video_bits_0;
wire [63:0] video_bits_1;
wire [63:0] video_bits_2;
wire [63:0] video_bits_3;

VideoGenerator video_generator(
    .clock (tx_clock),
    .reset (tx_reset),
    .video_width (h_active),
    .video_height (v_active),
    .start_frame (start_frame),
    .ready (video_ready),
    .valid (video_valid),
    .bits_0 (video_bits_0),
    .bits_1 (video_bits_1),
    .bits_2 (video_bits_2),
    .bits_3 (video_bits_3)
);

HDMISource hdmi_source(
    .clock (tx_clock),
    .reset (tx_reset),
    .video_timing_h_active (h_active),
    .video_timing_h_front_porch (h_front_porch),
    .video_timing_h_sync (h_sync),
    .video_timing_h_back_porch (h_back_porch),
    .video_timing_v_active (v_active),
    .video_timing_v_front_porch (v_front_porch),
    .video_timing_v_sync (v_sync),
    .video_timing_v_back_porch (v_back_porch),
    .video_timing_h_sync_polarity (h_sync_polarity),
    .video_timing_v_sync_polarity (v_sync_polarity),
    .scrambler_enable (scrambler_enable),
    .tmds_bit_clock_ratio (tmds_bit_clock_ratio),
    .start_frame (start_frame),
    .input_ready (video_ready),
    .input_valid (video_valid),
    .input_bits_0 (video_bits_0),
    .input_bits_1 (video_bits_1),
    .input_bits_2 (video_bits_2),
    .input_bits_3 (video_bits_3),
    .lane0_0 (tx_data[49:40]),
    .lane0_1 (tx_data[59:50]),
    .lane0_2 (tx_data[69:60]),
    .lane0_3 (tx_data[79:70]),
    .lane1_0 (tx_data[89:80]),
    .lane1_1 (tx_data[99:90]),
    .lane1_2 (tx_data[109:100]),
    .lane1_3 (tx_data[119:110]),
    .lane2_0 (tx_data[129:120]),
    .lane2_1 (tx_data[139:130]),
    .lane2_2 (tx_data[149:140]),
    .lane2_3 (tx_data[159:150]),
    .lane3_0 (tx_data[9:0]),
    .lane3_1 (tx_data[19:10]),
    .lane3_2 (tx_data[29:20]),
    .lane3_3 (tx_data[39:30]));

assign run = state == STATE_RUN;

endmodule
