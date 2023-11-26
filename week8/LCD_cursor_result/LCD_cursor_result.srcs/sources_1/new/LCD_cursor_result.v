`timescale 1ns / 1ps

module LCD_cursor_result(rst, clk, LCD_E, LCD_RS, LCD_RW, LCD_DATA, LED_out, number_btn, control_btn, switch);

input rst, clk;
input [9:0] number_btn;
input [1:0] control_btn;
input switch;



wire [9:0] number_btn_t;
wire [1:0] control_btn_t;

oneshot_universal #(.WIDTH(12)) O1(clk, rst, {number_btn[9:0], control_btn[1:0]}, {number_btn_t[9:0], control_btn_t[1:0]});


output LCD_E, LCD_RS, LCD_RW;
output reg[7:0] LCD_DATA;
output reg[7:0] LED_out;

wire LCD_E;
reg LCD_RS, LCD_RW;



reg [2:0] state;
parameter DELAY = 3'b000;
parameter FUNCTION_SET = 3'b001;
parameter DISP_ONOFF   = 3'b010;
parameter ENTRY_MODE   = 3'b011;

parameter SET_ADDRESS  = 3'b100;
parameter DELAY_T      = 3'b101; 
parameter WRITE        = 3'b110; 
parameter CURSOR       = 3'b111;
          
integer cnt;
integer a;

always @(posedge clk or negedge rst)
begin
    if(!rst) begin
        {state, cnt} <= {DELAY, 0};
        LED_out = 8'b0000_0000;
        a <= 0;
       end
    else begin
        case(state)
            DELAY : begin
                if(cnt == 70) 
                begin {state, cnt} <= {FUNCTION_SET, 0};
                                LED_out = 8'b1000_0000;
                end
                else cnt <= cnt + 1;
            end
            FUNCTION_SET : begin  
                if(cnt == 30)
                begin {state, cnt} <= {DISP_ONOFF, 0};
                LED_out = 8'b0100_0000;
                end
                else cnt <= cnt + 1;
            end

            DISP_ONOFF : begin
                if(cnt == 30)
                begin {state, cnt} <= {ENTRY_MODE, 0};
                LED_out <= 8'b0010_0000; // cursor blink
                end
                else cnt <= cnt + 1;
            end
            ENTRY_MODE : begin   
                if(cnt == 30)
                begin {state, cnt} <= {SET_ADDRESS, 0};
                LED_out <= 8'b0001_0000;
                end
                else cnt <= cnt + 1;
            end
            SET_ADDRESS : begin
                if(cnt == 100)
                begin {state, cnt} <= {DELAY_T, 0};
                LED_out <= 8'b0000_1000;
                end
                else cnt <= cnt + 1;
            end
            DELAY_T : begin
                LED_out <= 8'b0000_0100; 
                state <= |number_btn_t ? WRITE : (|control_btn_t ? CURSOR : DELAY_T);
                cnt <= 0 ;
               
            end
            WRITE : begin
                LED_out <= 8'b0000_0010;
                if(cnt == 30) {state, cnt} <= {DELAY_T, 0};
                else cnt <= cnt + 1;
            end
            CURSOR : begin
                LED_out <= 8'b0000_0001;
                if(cnt == 30) {state, cnt} <= {DELAY_T, 0};
                else cnt <= cnt + 1;
            end
            default : state = DELAY;
         endcase
     end
  end
   
always @(posedge clk or negedge rst)
begin
    if(!rst)
        {LCD_RS, LCD_RW, LCD_DATA} <= 10'b0_0_00000001; // clear display
    else if(switch == 1)
        {LCD_RS, LCD_RW, LCD_DATA} <= 10'b0_0_1100_0000;   
        else if(switch == 0)
        {LCD_RS, LCD_RW, LCD_DATA} <= 10'b0_0_1000_0000;
    else begin
        case(state)
            FUNCTION_SET :             
                {LCD_RS, LCD_RW, LCD_DATA} <= 10'b0_0_0011_1000; // 2line if switch = 1
            DISP_ONOFF :
                {LCD_RS, LCD_RW, LCD_DATA} <= 10'b0_0_0000_1111;
            ENTRY_MODE :
                {LCD_RS, LCD_RW, LCD_DATA} <= 10'b0_0_0000_0110;
            SET_ADDRESS :
                {LCD_RS, LCD_RW, LCD_DATA} <= 10'b0_0_0000_0010;
            DELAY_T :
                {LCD_RS, LCD_RW, LCD_DATA} <= 10'b0_0_0000_1111;        
                
           WRITE : begin
                if(cnt == 20) begin
                    case(number_btn)
                        10'b1000_0000_00 : {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0001;
                        10'b0100_0000_00 : {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0010;
                        10'b0010_0000_00 : {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0011;
                        10'b0001_0000_00 : {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0100;
                        10'b0000_1000_00 : {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0101;
                        10'b0000_0100_00 : {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0110;
                        10'b0000_0010_00 : {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0111;
                        10'b0000_0001_00 : {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_1000;
                        10'b0000_0000_10 : {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_1001;
                        10'b0000_0000_01 : {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0000;
                        endcase
                    end
                    else {LCD_RS, LCD_RW, LCD_DATA} <= 10'b0_0_0000_1111;
                 end
                 
           CURSOR :
            if(cnt == 20) begin
                case(control_btn)
                    2'b10 : {LCD_RS, LCD_RW, LCD_DATA} <= 10'b0_0_0001_0000;                      
                    2'b01 : {LCD_RS, LCD_RW, LCD_DATA} <= 10'b0_0_0001_0100;
              endcase  
                    if( control_btn == 2'b10) begin
                    {LCD_RS, LCD_RW, LCD_DATA} <= 10'b0_0_0001_0000;
                    a <= a - 1;
                    end
                    else if( control_btn == 2'b01) begin
                     {LCD_RS, LCD_RW, LCD_DATA} <= 10'b0_0_0001_0100;
                     a <= a + 1;
                     end
               else if( a == 16) begin
                {LCD_RS, LCD_RW, LCD_DATA} <= 10'b0_0_1100_0000;
                a <= 0;
                end
                else if( a== 55) begin
                {LCD_RS, LCD_RW, LCD_DATA} <= 10'b0_0_1000_0000;
                a <= 40;
                end
                
            end
           
            
            
            
            else  {LCD_RS, LCD_RW, LCD_DATA} <= 10'b0_0_0000_1111;
        
      endcase
    end
 end
 
 
 assign LCD_E = clk;
 
  endmodule    