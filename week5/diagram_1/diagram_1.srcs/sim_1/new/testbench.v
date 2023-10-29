`timescale 1ns / 1ps

module testbench();

reg clk, rst, x;
wire [1:0]state;
wire  y;

diagram_1 u1(clk, rst, x, y, state);

initial begin
    clk <= 0;
    rst <= 1; 
    x <= 0;
    #10 rst <= 0;
    #10 rst <= 1;
    
//    #30 x <= 1'b1; //     4.1.1 / 4.1.3 / 4.1.5
    
//    #5 x <= 1'b1; 
//    #5 x <= 1'b0; //        4.1.2
    
//      #10 x <= 1'b1;
//      #30 x <= 1'b0; //     4.1.4

//    #10 x <= 1'b1;
//    #20 x <= 1'b0; //       4.1.6
    
   end
    
always begin
   #5 clk <= ~clk;
end
   
   endmodule