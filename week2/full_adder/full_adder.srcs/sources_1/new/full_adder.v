`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/10 21:33:17
// Design Name: 
// Module Name: full_adder
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


module full_adder(a, b, cin , s, cout);
input a, b, cin;
output s, cout;
wire w1, w2, w3, w4;

xor(w1, a, b);
xor(s, w1, cin);
or(w2, a, b);
and(w3, w2, cin);
and(w4, a, b);
or(cout, w3, w4);


endmodule

