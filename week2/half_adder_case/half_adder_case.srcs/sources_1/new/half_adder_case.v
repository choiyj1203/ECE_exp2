`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/10 20:01:32
// Design Name: 
// Module Name: half_adder_case
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


module half_adder_case(a, b, c, s);

input a, b;
output reg c;
output reg s;

always @* begin
 case ({a, b})
   2'b00: begin
   s=1'b0;
   c=1'b0;
  end
   2'b01: begin
   s=1'b1;
   c=1'b0;
  end
   2'b10: begin
   s=1'b1;
   c=1'b0;
  end
   2'b11: begin
   s=1'b0;
   c=1'b1;
  end
  
  default: begin
   s=1'b0;
   c=1'b0;
  end
 endcase
end

endmodule
