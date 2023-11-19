`timescale 1ns / 1ps

module testbench();

reg rst, clk;
reg [9:0] number_btn;
reg [1:0] control_btn;

wire LCD_E, LCD_RS, LCD_RW;
wire [7:0] LCD_DATA;
wire [7:0] LED_out;

LCD_cursor tb(rst, clk, LCD_E, LCD_RS, LCD_RW, LCD_DATA, LED_out, number_btn, control_btn);

initial begin
    clk <= 0;
    rst <= 1;
    #1 rst <= 0;
    #1 rst <= 1;
    #1 number_btn <= 10'b0000_0000_00;
       control_btn <= 10'b0000_0000_00;
    #50 number_btn <= 10'b0100_0000_00; //2 => {RS, RW, DATA} <= 10'b1_0_0011_0010
    #50 number_btn <= 10'b0000_0100_00; //6 => {RS ,RW, DATA} <= 10'b1_0_0011_0110
    #50 number_btn <= 10'b0000_0000_10; //9 => {RS, RW, DATA} <= 10'b1_0_0011_1001
    #10 number_btn <= 10'b0000_0000_00;
    #30 control_btn <= 2'b10; //shift left
    #30 control_btn <= 2'b01; //shift right
    end
    
always begin
    #1 clk <= ~clk;
end

endmodule
