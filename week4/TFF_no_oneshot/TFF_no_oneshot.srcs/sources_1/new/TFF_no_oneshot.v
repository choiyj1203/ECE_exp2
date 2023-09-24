`timescale 1ns / 1ps


module TFF_no_oneshot(clk, rst, T, Q);

input T, clk, rst;
output reg Q;

always @(negedge rst)
begin
    if(!rst)
        Q <= 1'b0;
end

always @(posedge clk)
begin
    if(T)
        Q <= ~Q;
end

endmodule
