`timescale 1ns / 1ps

module DFF(clk, D, Q);

input D, clk;
output reg Q;
always @(posedge clk)
begin
    Q <= D;
end

endmodule
