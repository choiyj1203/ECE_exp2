`timescale 1ns / 1ps

module testbench();

reg rst, clk;
wire LCD_E, LCD_RS, LCD_RW;
wire [7:0] LCD_DATA;
wire [7:0] LED_out;

text_LCD_basic tb(rst, clk, LCD_E, LCD_RS, LCD_RW, LCD_DATA, LED_out);

initial begin
    clk <= 0;
    rst <= 1;
    #10 rst <= 0;
    #10 rst <= 1;
    end
    
always begin
    #1 clk <= ~clk;
end

endmodule
