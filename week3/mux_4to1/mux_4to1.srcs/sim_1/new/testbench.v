`timescale 1ns / 1ps


module testbench();

reg [1:0] S0, S1;
reg [1:0] I0, I1, I2, I3;
wire [1:0] Y;

mux_4to1 tb(
.S0(S0),
.S1(S1),
.I0(I0),
.I1(I1),
.I2(I2),
.I3(I3),
.Y(Y)
);

initial begin
S0=1'b0;
S1=1'b0;
I0=2'b00;
I1=2'b01;
I2=2'b10;
I3=2'b11;
#10;

S0=1'b1;
S1=1'b0;
#10;

S0=1'b0;
S1=1'b1;
#10;

S0=1'b1;
S1=1'b1;
#10;

$finish;
end
endmodule
