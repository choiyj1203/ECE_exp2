`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/10 17:23:19
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

reg [1:0] a,b;
wire x, y, z, p, q;

logic_gate tb(
.a(a),
.b(b),
.x(x),
.y(y),
.z(z),
.p(p),
.q(q)
);

initial begin
a=1'b0;
b=1'b0;
#10;

a=1'b0;
b=1'b1;
#10;

a=1'b1;
b=1'b0;
#10;

a=1'b1;
b=1'b1;
#10;

$finish;
end
endmodule
