module Arbiter #(
    parameter REQUEST_COUNT = 0
) (
    input clock,
    input reset,

    input [REQUEST_COUNT - 1:0] request,
    output [REQUEST_COUNT - 1:0] grant
);

reg [REQUEST_COUNT - 1:0] grant_reg;

always @(posedge clock) begin
    if (reset)
        grant_reg <= 0;
    else begin
        if ((request & grant_reg) == 0)
            grant_reg <= request & -request;
    end
end

assign grant = grant_reg;

endmodule
