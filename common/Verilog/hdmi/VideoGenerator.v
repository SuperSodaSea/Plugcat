module VideoGenerator(
    input clock,
    input reset,

    input [15:0] video_width,
    input [15:0] video_height,

    input start_frame,

    input ready,
    output valid,
    output [63:0] bits_0,
    output [63:0] bits_1,
    output [63:0] bits_2,
    output [63:0] bits_3
);

reg valid_reg;
assign valid = valid_reg;

reg [63:0] bits[0:3];
assign bits_0 = bits[0];
assign bits_1 = bits[1];
assign bits_2 = bits[2];
assign bits_3 = bits[3];

wire position_ready = ready | ~valid;
reg position_valid;
reg [15:0] cx;
reg [15:0] cy;

reg [15:0] bx;
reg [15:0] by;
reg dx;
reg dy;

localparam border = 20;
localparam step = 8;

always @(posedge clock) begin
    if (reset) begin
        valid_reg <= 0;
        position_valid <= 0;
        bx <= border;
        by <= border;
        dx <= 0;
        dy <= 0;
    end else begin
        if (~position_valid) begin
            if (start_frame) begin
                position_valid <= 1;
                cx <= 0;
                cy <= 0;
            end
        end

        if (position_ready & position_valid) begin
            if (cx + 4 < video_width) begin
                cx <= cx + 4;
            end else begin
                cx <= 0;
                if (cy + 1 < video_height) begin
                    cy <= cy + 1;
                end else begin
                    position_valid <= 0;

                    if (~dx) begin
                        if (bx + step < video_width - border - 200) begin
                            bx <= bx + step;
                        end else begin
                            bx <= bx - step;
                            dx <= 1;
                        end
                    end else begin
                        if (bx - step >= border) begin
                            bx <= bx - step;
                        end else begin
                            bx <= bx + step;
                            dx <= 0;
                        end
                    end

                    if (~dy) begin
                        if (by + step < video_height - border - 200) begin
                            by <= by + step;
                        end else begin
                            by <= by - step;
                            dy <= 1;
                        end
                    end else begin
                        if (by - step >= border) begin
                            by <= by - step;
                        end else begin
                            by <= by + step;
                            dy <= 0;
                        end
                    end
                end
            end
        end

        if (position_ready) begin
            valid_reg <= position_valid;
        end
    end
end

function [63:0] generate_pixel(
    input [15:0] px,
    input [15:0] py
);
begin
    if (px == 0 || py == 0 || px == video_width - 1 || py == video_height - 1) begin
        generate_pixel = 64'h0000FF;
    end else if (px == 1 || py == 1 || px == video_width - 2 || py == video_height - 2) begin
        generate_pixel = 64'h00FF00;
    end else if (px == 2 || py == 2 || px == video_width - 3 || py == video_height - 3) begin
        generate_pixel = 64'hFF0000;
    end else if (px == 3 || py == 3 || px == video_width - 4 || py == video_height - 4) begin
        generate_pixel = 64'h000000;
    end else if (px >= bx && py >= by && px < bx + 200 && py < by + 200) begin
        generate_pixel = 64'hFFCC66;
    end else if (px >= 50 && py >= 50 && px < 250 && py <= 250) begin
        generate_pixel = 64'h0000FF;
    end else if (px >= 100 && py >= 100 && px < 300 && py <= 300) begin
        generate_pixel = 64'h00FFFF;
    end else if (px >= 150 && py >= 150 && px < 350 && py <= 350) begin
        generate_pixel = 64'h00FF00;
    end else if (px >= 200 && py >= 200 && px < 400 && py <= 400) begin
        generate_pixel = 64'hFFFF00;
    end else if (px >= 250 && py >= 250 && px < 450 && py <= 450) begin
        generate_pixel = 64'hFF0000;
    end else if (px >= 300 && py >= 300 && px < 500 && py <= 500) begin
        generate_pixel = 64'hFF00FF;
    end else if (px[5] ^ py[5]) begin
        generate_pixel = 64'hFFFFFF;
    end else begin
        generate_pixel = 64'hCCCCCC;
    end
end
endfunction

genvar i;

generate
    for (i = 0; i < 4; i = i + 1) begin: generate_pixels
        wire [15:0] px = cx + i;
        wire [15:0] py = cy;

        always @(posedge clock) begin
            if (~reset & position_ready & position_valid) begin
                bits[i] <= generate_pixel(px, py);
            end
        end
    end
endgenerate

endmodule
