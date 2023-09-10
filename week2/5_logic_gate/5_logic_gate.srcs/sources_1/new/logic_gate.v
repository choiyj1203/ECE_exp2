`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/09 14:23:51
// Design Name: 
// Module Name: logic_gate
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module logic_gate(a, b, x, y, z, p, q);

input a, b;

output x, y, z, p, q;

wire x, y, z, p, q;

//AND gate
assign x = a & b;
//OR gate
assign y = a | b;
//XOR gate
assign z = a ^ b;
//NOR gate
assign p = ~(a | b);
//NAND gate
assign q = ~(a & b);

endmodule
