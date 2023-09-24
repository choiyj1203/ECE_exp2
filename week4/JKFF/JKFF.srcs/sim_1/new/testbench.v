`timescale 1ns / 1ps

module testbench();

reg clk, J, K;
wire Q;

JKFF FF(clk, J, K, Q);

initial begin
    clk <= 0;
    #30 J <= 0;
        K <= 0;
    #30 J <= 0;
        K <= 1;
    #30 J <= 0;
        K <= 0;
    #30 J <= 1;
        K <= 0;
    #30 J <= 0;
        K <= 0;
    #30 J <= 1;
        K <= 1;
    #30 J <= 0;
        K <= 0;
end

always begin
    #5 clk <= ~clk;
end
    
endmodule
