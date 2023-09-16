`timescale 1ns / 1ps

module testbench();

reg [1:0] S0, S1, S2;
reg [3:0] I0, I1, I2, I3, I4, I5, I6, I7;
wire [3:0] Y;

mux_8to1 tb(
.S0(S0),
.S1(S1),
.S2(S2),
.I0(I0),
.I1(I1),
.I2(I2),
.I3(I3),
.I4(I4),
.I5(I5),
.I6(I6),
.I7(I7),
.Y(Y)
);

initial begin
S0=1'b0;
S1=1'b0;
S2=1'b0;
I0=4'b0000;
I1=4'b0001;
I2=4'b0011;
I3=4'b0100;
I4=4'b0101;
I5=4'b0111;
I6=4'b1000;
I7=4'b1111;
#10;

S0=1'b1;
S1=1'b0;
S2=1'b0;
#10;

S0=1'b0;
S1=1'b1;
S2=1'b0;
#10;

S0=1'b1;
S1=1'b1;
S2=1'b0;
#10;

S0=1'b0;
S1=1'b0;
S2=1'b1;
#10;

S0=1'b1;
S1=1'b0;
S2=1'b1;
#10;

S0=1'b0;
S1=1'b1;
S2=1'b1;
#10;

S0=1'b1;
S1=1'b1;
S2=1'b1;
#10;

$finish;
end
endmodule
