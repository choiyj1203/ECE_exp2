`timescale 1ns / 1ps

module DAC(clk, rst, btn, add_sel, dac_csn, dac_ldacn, dac_wrn, dac_a_b, dac_d, led_out, seg_data, seg_sel, LCD_E, LCD_RS, LCD_RW, LCD_DATA);

input clk, rst;
input [5:0] btn;
input add_sel;
output reg dac_csn, dac_ldacn, dac_wrn, dac_a_b;
output reg [7:0] dac_d;
output reg [7:0] led_out;

output [7:0] seg_data;
output [7:0] seg_sel;
output LCD_E, LCD_RS, LCD_RW;
output [7:0] LCD_DATA;


reg [7:0] dac_d_temp;

wire [5:0] btn_t;

reg [1:0] state;

parameter DELAY = 2'b00,
          SET_WRN = 2'b01,
          UP_DATA = 2'b10;
          
integer cnt;

          
oneshot_universal #(.WIDTH(6)) O1(clk, rst, {btn[5:0]}, {btn_t[5:0]});
seg7_controller s1(clk, rst, led_out, seg_data, seg_sel); // 7-segment
text_LCD t1(rst, clk, led_out, LCD_E, LCD_RS, LCD_RW, LCD_DATA);
 
always @(posedge clk or negedge rst) begin
    if(!rst) begin
        state <= DELAY;
        cnt <= 0;
     end
     else begin
        case(state)
            DELAY : begin
            if(cnt == 200) 
            {state, cnt} <= {SET_WRN, 0};            
            else cnt <= cnt + 1;        
            end      
                  
            SET_WRN :  begin
            if(cnt == 50)
             {state, cnt} <= {UP_DATA, 0};
             else cnt <= cnt + 1;
             end  
                   
            UP_DATA : begin
            if(cnt == 30)
            {state, cnt} <= {DELAY, 0};
            else cnt <= cnt + 1;
            end     
         endcase
      end
  end
  
always @(posedge clk or negedge rst) begin
    if(!rst) begin
        dac_wrn <= 1;
     end
     else begin
        case(state)
            DELAY :
                dac_wrn <= 1;
            SET_WRN :
                dac_wrn <= 0;
            UP_DATA :
                dac_d <= dac_d_temp;
         endcase
     end
 end
 
 always @(posedge clk or negedge rst) begin
    if(!rst) begin
        dac_d_temp <= 8'b0000_0000;
        led_out <= 8'b0101_0101;
        end
        else begin
            if      (btn_t == 6'b100000) dac_d_temp <= dac_d_temp - 8'b0000_0001;
            else if (btn_t == 6'b010000) dac_d_temp <= dac_d_temp + 8'b0000_0001;
            else if (btn_t == 6'b001000) dac_d_temp <= dac_d_temp - 8'b0000_0010;
            else if (btn_t == 6'b000100) dac_d_temp <= dac_d_temp + 8'b0000_0010;
            else if (btn_t == 6'b000010) dac_d_temp <= dac_d_temp - 8'b0000_1000;
            else if (btn_t == 6'b000001) dac_d_temp <= dac_d_temp + 8'b0000_1000;
             led_out <= dac_d_temp;
         end
         
     end
     
     always @(posedge clk) begin
        dac_csn <= 0;
        dac_ldacn <= 0;
        dac_a_b <= add_sel;  // 0 : select A, 1 : select B
     end
     
     endmodule   

