`timescale 1ns / 1ps

module testbench();

reg [1:0] D0, D1, D2, D3;
wire x, y;

encoder_4to2 tb(
.D0(D0),
.D1(D1),
.D2(D2),
.D3(D3),
.x(x),
.y(y)
);

initial begin
D0=1'b0;
D1=1'b0;
D2=1'b0;
D3=1'b0;
#10;

D0=1'b0;
D1=1'b0;
D2=1'b0;
D3=1'b1;
#10;

D0=1'b1;
D1=1'b1;
D2=1'b0;
D3=1'b1;
#10;

D0=1'b1;
D1=1'b0;
D2=1'b1;
D3=1'b0;
#10;

D0=1'b1;
D1=1'b0;
D2=1'b0;
D3=1'b0;
#10;

$finish;
end
endmodule
