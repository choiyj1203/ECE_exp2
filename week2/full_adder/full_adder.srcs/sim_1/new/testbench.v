`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/10 21:37:32
// Design Name: 
// Module Name: testbench
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


module testbench();

reg [1:0] a, b, cin;
wire s, cout;

full_adder tb(
.a(a),
.b(b),
.cin(cin),
.s(s),
.cout(cout)
);

initial begin
a=1'b0;
b=1'b0;
cin=1'b0;
#10;

a=1'b0;
b=1'b0;
cin=1'b1;
#10;

a=1'b0;
b=1'b1;
cin=1'b0;
#10;

a=1'b0;
b=1'b1;
cin=1'b1;
#10;

a=1'b1;
b=1'b0;
cin=1'b0;
#10;

a=1'b1;
b=1'b0;
cin=1'b1;
#10;

a=1'b1;
b=1'b1;
cin=1'b0;
#10;

a=1'b1;
b=1'b1;
cin=1'b1;
#10;

$finish;
end
endmodule
