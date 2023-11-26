`timescale 1ns / 1ps

module oneshot_universal(clk, rst, btn, btn_t);

parameter WIDTH = 1;
input clk, rst;
input [WIDTH-1:0] btn;
reg [WIDTH-1:0] btn_reg;
output reg [WIDTH-1:0] btn_t;

always @(negedge rst or posedge clk) begin
    if(!rst) begin
        btn_reg <= {WIDTH{1'b0}};
        btn_t <= {WIDTH{1'b0}};
      end
      else begin
        btn_reg <= btn;
        btn_t <= btn & ~ btn_reg;
      end
   end
   
   endmodule
