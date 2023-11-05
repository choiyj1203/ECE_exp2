`timescale 1ns / 1ps

module testbench();

reg clk, rst;
reg btn;
wire [7:0] seg_data;
wire [7:0] seg_sel;

seg_array tb(clk, rst, btn, seg_data, seg_sel);

initial begin
    clk <= 0;
    rst <= 1;
    btn <= 0;
    
    #50 rst <= 0;
    #50 rst <= 1;
    
    #50 btn <= 1;
    #50 btn <= 0;
    
    #50 btn <= 1;
    #50 btn <= 0;
    
    #50 btn <= 1;
    #50 btn <= 0;
    
    #50 btn <= 1;
    #50 btn <= 0;
    
    #50 btn <= 1;
    #50 btn <= 0;
    
    #50 btn <= 1;
    #50 btn <= 0;
    
    #50 btn <= 1;
    #50 btn <= 0;
    
    #50 btn <= 1;
    #50 btn <= 0;
    
    #50 btn <= 1;
    #50 btn <= 0;
    
    #50 btn <= 1;
    #50 btn <= 0;
    
    #50 btn <= 1;
    #50 btn <= 0;
    
    #50 btn <= 1;
    #50 btn <= 0;
    
    #50 btn <= 1;
    #50 btn <= 0;
    
    #50 btn <= 1;
    #50 btn <= 0;
    
    #50 btn <= 1;
    #50 btn <= 0;
    
    #50 btn <= 1;
    #50 btn <= 0;
    
    #50 btn <= 1;
    #50 btn <= 0;
end

always begin
    #5 clk <= ~clk;
end
 
endmodule
