`timescale 1ns / 1ps



module encoder_4to2(D0, D1, D2, D3, x, y);

input D0, D1, D2, D3;

output x, y;

wire x, y;

assign x = D3 | D2;

assign y = D3 | (D1 & (~D2));

endmodule
