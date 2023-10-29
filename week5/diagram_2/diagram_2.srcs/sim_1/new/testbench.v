`timescale 1ns / 1ps

module testbench();

reg clk, rst;
reg A, B, C;
wire [2:0] state;
wire y;

diagram_2 tb(clk, rst, A, B, C, state, y);

initial begin
    clk <= 0;
    rst <= 1;
    A <= 0;
    B <= 0;
    C <= 0;
    #10 rst <= 0;
    #10 rst <= 1;
    #50 A <= 1;
    #20 A <= 0;
    #50 B <= 1;
    #20 B <= 0;
    #50 A <= 1;
    #20 A <= 0;
    #50 B <= 1;
    #20 B <= 0;
    #50 C <= 1;
    #80 C <= 0;
    #10 rst <= 0;
    #10 rst <= 1;
    #50 A <= 1;
    #20 A <= 0;
    #50 B <= 1;
    #20 B <= 0;
    #50 C <= 1;
end

always begin
    #5 clk <= ~clk;
end

endmodule
