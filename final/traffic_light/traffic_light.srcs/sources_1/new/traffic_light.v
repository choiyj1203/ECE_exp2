`timescale 1ns / 1ps
//10khz의 주파수를 기본으로
module traffic_light(rst, clk, hour_up, amb,a,b,c, LCD_E,LCD_RS,LCD_RW,LCD_DATA, S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW, S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT );

input clk,rst,hour_up,amb,a,b,c;
output reg S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN; 
output reg S_W_RED, N_W_RED, W_W_RED, E_W_RED;         
output reg S_GREEN, N_GREEN, W_GREEN, E_GREEN;         
output reg S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW;     
output reg S_RED, N_RED, W_RED, E_RED;              
output reg S_LEFT, N_LEFT, W_LEFT, E_LEFT;             
output LCD_E;
output reg LCD_RS, LCD_RW;
output reg [7:0] LCD_DATA;

wire hour_up_t,amb_t;
reg [7:0] hour,min,sec;
reg [31:0] hold_t=0;
reg x=0;

integer cccnt;
integer ccnt;
integer cnt;

reg [3:0] state,state3;
parameter A1	=5'b00000,
	  A1toD =5'b00001,
	  D	=5'b00010,
	  DtoF  =5'b00011,
	  F	=5'b00100,
	  FtoE1 =5'b00101,
	  E1	=5'b00110,
	  E1toG =5'b00111,
	  G	=5'b01000,
	  GtoE2 =5'b01001,
	  E2	=5'b01010,
	  E2toA1=5'b01011,
	  B	=5'b01100,
	  BtoA2 =5'b01101,
	  A2toC =5'b01110,
	  C	=5'b01111,
	  CtoA3 =5'b10000,
	  A3	=5'b10001,
	  A3toE3=5'b10010,
	  E3toH =5'b10011,
	  HtoB	=5'b10100,
	  A2	=5'b10101,
	  E3	=5'b10110,
	  H	=5'b10111;  
	  

reg [3:0] state2 = 4'b0011;
parameter DELAY2 =4'b0011,
          FUNCTION_SET =4'b0100,
          ENTRY_MODE =4'b0101,
          DISP_ONOFF =4'b0110,
          LINE1 =4'b0111,
          LINE2 =4'b1000,
          DELAY_T =4'b1001;

wire [7:0] bcd1,bcd2,bcd3;

bin2bcd b1 (.clk(clk), .rst(rst), .bin(hour), .bcd(bcd1));
bin2bcd b2 (.clk(clk), .rst(rst), .bin(min), .bcd(bcd2));
bin2bcd b3 (.clk(clk), .rst(rst), .bin(sec), .bcd(bcd3));
              
 
oneshot_universal #(.width(2)) uut(.clk(clk), .rst(rst), .btn({hour_up, amb}), .btn_trig({hour_up_t,amb_t})); //10kHz의 주파수로 설정 시에 실제시간의 100배의 비율로 시간흐름
 
 integer d=99;
always @(posedge clk or posedge rst) begin   
        if(rst) begin
        cccnt <=0;
        hour <=0;
        sec <=0;
        min <=0;
        end
    else if(hour_up_t && hour < 23) hour <= hour+1;
    else if(hour_up_t && hour == 23) hour <= 0;// 1시간 증가
    else if (cccnt < d)  begin cccnt <= cccnt+1; //기본 설정=100배율
            d <= a? 9999 :(b? 999 : (c? 49: 99)); //a=1배율, b= 실제시간의 10배율, c=실제시간의 200배 dip 스위치를 사용할것이니, 꾹 누르지 않아도 됨(배율 유지가능)
            end
       else begin
           cccnt <= 0;
         if (sec < 59) sec <= sec+1;
          else begin
           sec <= 0; //sec 60되면 0으로, min 1증가
         if (min < 59) min <= min+1;
          else begin
           min <= 0; //min 60되면 0으로, hour 1증가
          if (hour < 23) hour <= hour+1; 
           else begin
            hour <= 0; //hour 24되면 0으로
            end 
         end
      end           
  end
end         
           
          
always @(posedge clk or posedge rst)
begin
    if(rst) begin
        state2 <= DELAY2;
        ccnt <=0;
        end
    else
    begin
        case(state2)
        DELAY2 :begin
            if(ccnt >=700) ccnt <= 0;
            else ccnt <= ccnt+1;
            if(ccnt == 700) state2 <= FUNCTION_SET;
        end
        FUNCTION_SET :begin
            if(ccnt >=30) ccnt <= 0;
            else ccnt <= ccnt+1;
            if(ccnt == 30) state2 <= DISP_ONOFF;
        end
        DISP_ONOFF :begin
            if(ccnt >=30) ccnt <= 0;
            else ccnt <= ccnt+1;
            if(ccnt == 30) state2 <= ENTRY_MODE;
        end
        ENTRY_MODE :begin
            if(ccnt >=30) ccnt <= 0;
            else ccnt <= ccnt+1;
            if(ccnt == 30) state2 <= LINE1;
        end
        LINE1 :begin
            if(ccnt >=20) ccnt <= 0;
            else ccnt <= ccnt+1;
            if(ccnt == 20) state2 <= LINE2;
           end
         LINE2 :begin
            if(ccnt >=20) ccnt <= 0;
            else ccnt <= ccnt+1;
            if(ccnt == 20) state2 <= DELAY_T;
           end
        DELAY_T :begin
            if(ccnt >= 5) ccnt <= 0;
            else ccnt <= ccnt+1;
            if(ccnt == 5) state2 <= LINE1;
        end
        default : state2 <= DELAY2;
     endcase
  end
end
                              
always @(posedge clk or posedge rst)
begin
    if(rst)
        {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_1_00000000;
    else begin
        case(state2)
            FUNCTION_SET :
                {LCD_RS, LCD_RW, LCD_DATA} <=10'b0_0_0011_1000;
            DISP_ONOFF :
                {LCD_RS, LCD_RW, LCD_DATA} <=10'b0_0_0000_1100;
            ENTRY_MODE :
                {LCD_RS, LCD_RW, LCD_DATA} <=10'b0_0_0000_0110;   
            LINE1 : begin
                case(ccnt)
                    00 : {LCD_RS, LCD_RW, LCD_DATA} <=10'b0_0_1000_0000; //    
                    01 : {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0101_0100; // T
                    02 : {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0110_1001; // i
                    03 : {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0110_1101; // m
                    04 : {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0110_0101; // e
                    05 : {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0010_0000; // 
                    06 : {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_1010; // : 
                    07 : {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0010_0000; //   
                    08 : begin case(bcd1[7:4]) //hour 10의자리
                            0: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0000; // 0
                            1: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0001; // 1
                            2: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0010; // 2
                        endcase
                        end                  
                    09 : begin case(bcd1[3:0]) //hour 1의자리
                            0: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0000; // 0
                            1: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0001; // 1
                            2: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0010; // 2
                            3: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0011; // 3
                            4: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0100; // 4
                            5: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0101; // 5
                            6: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0110; // 6
                            7: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0111; // 7
                            8: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_1000; // 8
                            9: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_1001; // 9
                        endcase
                        end 
                    10 : {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_1010; // :                    
                    11 :begin case(bcd2[7:4]) //min 10의 자리
                            0: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0000; // 0
                            1: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0001; // 1
                            2: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0010; // 2
                            3: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0011; // 3
                            4: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0100; // 4
                            5: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0101; // 5
                        endcase
                        end
                    12 :begin case(bcd2[3:0]) //min 1의 자리
                            0: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0000; // 0
                            1: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0001; // 1
                            2: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0010; // 2
                            3: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0011; // 3
                            4: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0100; // 4
                            5: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0101; // 5
                            6: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0110; // 6
                            7: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0111; // 7
                            8: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_1000; // 8
                            9: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_1001; // 9
                        endcase
                        end     
                      13 : {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_1010; // :      
                      14 :begin case(bcd3[7:4]) //sec 10의 자리
                            0: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0000; // 0
                            1: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0001; // 1
                            2: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0010; // 2
                            3: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0011; // 3
                            4: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0100; // 4
                            5: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0101; // 5
                        endcase
                        end          
                      15 :begin case(bcd3[3:0]) //sec 1의 자리
                            0: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0000; // 0
                            1: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0001; // 1
                            2: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0010; // 2
                            3: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0011; // 3
                            4: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0100; // 4
                            5: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0101; // 5
                            6: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0110; // 6
                            7: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_0111; // 7
                            8: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_1000; // 8
                            9: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_1001; // 9
                        endcase
                        end                            
                    default : {LCD_RS, LCD_RW, LCD_DATA} <=10'b1_0_0010_0000; // 
                 endcase
              end
               LINE2 : begin
                case(ccnt)
                    00 : {LCD_RS, LCD_RW, LCD_DATA} <=10'b0_0_1100_0000; //    
                    01 : {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0101_0011; // S
                    02 : {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0111_0100; // t
                    03 : {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0110_0001; // a
                    04 : {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0111_0100; // t
                    05 : {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0110_0101; // e
                    06 : {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0010_0000; //  
                    07 : {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0011_1010; // :  
                    08 : {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0010_0000; //  
                    09 : begin case(state) // state
                           A1,A2,A3: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0100_0001; // A
                            B: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0100_0010; // B
                            C: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0100_0011; // C
                            D: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0100_0100; // D
                          E1,E2,E3: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0100_0101; // E
                            F: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0100_0110; // F
                            G: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0100_0111; // G
                            H: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0100_1000; // H
                        endcase
                        end                  
                    10 : {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0010_1000; // (                   
                    11 :begin case(hour)
                            8,9,10,11,12,13,14,15,16,17,18,19,20,21,22: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0010_0000; //
                            23,0,1,2,3,4,5,6,7: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0110_1110; // n
                        endcase
                        end
                    12 :begin case(hour)
                            8,9,10,11,12,13,14,15,16,17,18,19,20,21,22: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0110_0100; // d
                            23,0,1,2,3,4,5,6,7: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0110_1001; // i
                        endcase
                        end
                     13 :begin case(hour)
                            8,9,10,11,12,13,14,15,16,17,18,19,20,21,22: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0110_0001; // a
                            23,0,1,2,3,4,5,6,7: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0110_0111; // g
                        endcase
                        end     
                     14 :begin case(hour)
                            8,9,10,11,12,13,14,15,16,17,18,19,20,21,22: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0111_1001; // y
                            23,0,1,2,3,4,5,6,7: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0110_1000; // h
                        endcase
                        end    
                     15 :begin case(hour)
                            8,9,10,11,12,13,14,15,16,17,18,19,20,21,22: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0010_0000; //
                            23,0,1,2,3,4,5,6,7: {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0111_0100; // t
                        endcase //11-15: 주/야간 판단
                        end 
                     16 : {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_0_0010_1001; // )                         
                    default : {LCD_RS, LCD_RW, LCD_DATA} <=10'b1_0_0010_0000; // 
                 endcase
              end
            DELAY_T :
                {LCD_RS, LCD_RW, LCD_DATA} <= 10'b0_0_0000_0010;
            default :
                {LCD_RS, LCD_RW, LCD_DATA} <= 10'b1_1_0000_0000;              
          endcase
      end
  end
  
  assign LCD_E = clk;                         


always @(posedge clk or posedge rst) begin
    if(rst) begin 
        state <= A1;
        cnt <=0;
        end
    else if(amb_t || x) begin
        hold_t<= 150000;
        state <= (cnt >= 160000) ? state3 : ((cnt >= 10000 && x==1) ? A1 : state3 ); //1초 흐르고 A1으로 전환, 15초 유지 후 원래 state로
        if(cnt >= 160000)  cnt <=0;
            else cnt <= (x==0)? 0: cnt+1;
        x <= (cnt >= 160000) ? 0:1;  //1초 흐르고 A1으로 전환, 15초 유지 후 원래 state로
        end //수동조작
        
        
    else if(hour >= 8 && hour < 23) begin
        hold_t<= 50000;
        state3 <=state;
        case(state)
            A1:begin if(cnt >= 40000) state <= A1toD;
            if(cnt >= 40000) cnt <=0;
                else cnt <= cnt+1;
            end    
            A1toD:begin if(cnt >= 10000) state <= D;
            if(cnt >= 10000) cnt <=0;
                else cnt <= cnt+1;
            end
            D:begin if(cnt >= 40000) state <= DtoF;
            if(cnt >= 40000) cnt <=0;
                else cnt <= cnt+1;
            end
            DtoF:begin if(cnt >= 10000) state <= F;
            if(cnt >= 10000) cnt <=0;
                else cnt <= cnt+1;
	    end
            F:begin if(cnt >= 40000) state <= FtoE1;
            if(cnt >= 40000) cnt <=0;
                else cnt <= cnt+1;
            end
            FtoE1:begin if(cnt >= 10000) state <= E1;
            if(cnt >= 10000) cnt <=0;
                else cnt <= cnt+1;
            end
            E1:begin if(cnt >= 40000) state <= E1toG;
            if(cnt >= 40000) cnt <=0;
                else cnt <= cnt+1;
            end
            E1toG:begin if(cnt >= 10000) state <= G;
            if(cnt >= 10000) cnt <=0;
                else cnt <= cnt+1;
            end
            G:begin if(cnt >= 40000) state <= GtoE2;
            if(cnt >= 40000) cnt <=0;
                else cnt <= cnt+1;
            end
            GtoE2:begin if(cnt >= 10000) state <= E2;
            if(cnt >= 10000) cnt <=0;
                else cnt <= cnt+1;
            end
            E2:begin if(cnt >= 40000) state <= E2toA1;
            if(cnt >= 40000) cnt <=0;
                else cnt <= cnt+1;
            end
            E2toA1:begin if(cnt >= 10000) state <= A1;
            if(cnt >= 10000) cnt <=0;
                else cnt <= cnt+1;
            end                  
            default: state <= A1;
       endcase
     end  // 주간 state 변화
     
     
    else if(hour < 8 || hour == 23) begin
         hold_t<= 100000;
         state3 <=state;
       case(state)
            B:begin if(cnt >= 90000) state <= BtoA2;
            if(cnt >= 90000) cnt <=0;
                else cnt <= cnt+1;
            end
            BtoA2:begin if(cnt >= 10000) state <= A2;
            if(cnt >= 10000) cnt <=0;
                else cnt <= cnt+1;
            end
            A2:begin if(cnt >= 90000) state <= A2toC;
            if(cnt >= 90000) cnt <=0;
                else cnt <= cnt+1;
	    end
            A2toC:begin if(cnt >= 10000) state <= C;
            if(cnt >= 10000) cnt <=0;
                else cnt <= cnt+1;
            end
            C:begin if(cnt >= 90000) state <= CtoA3;
            if(cnt >= 90000) cnt <=0;
                else cnt <= cnt+1;
            end
            CtoA3:begin if(cnt >= 10000) state <= A3;
            if(cnt >= 10000) cnt <=0;
                else cnt <= cnt+1;
            end  
            A3:begin if(cnt >= 90000) state <= A3toE3;
            if(cnt >= 90000) cnt <=0;
                else cnt <= cnt+1;
            end
            A3toE3:begin if(cnt >= 10000) state <= E3;
            if(cnt >= 10000) cnt <=0;
                else cnt <= cnt+1;
            end
            E3:begin if(cnt >= 90000) state <= E3toH;
            if(cnt >= 90000) cnt <=0;
                else cnt <= cnt+1;
            end
            E3toH:begin if(cnt >= 10000) state <= H;
            if(cnt >= 10000) cnt <=0;
                else cnt <= cnt+1;
            end
            H:begin if(cnt >= 90000) state <= HtoB;
            if(cnt >= 90000) cnt <=0;
                else cnt <= cnt+1;
            end
            HtoB:begin if(cnt >= 10000) state <= B;
            if(cnt >= 10000) cnt <=0;
                else cnt <= cnt+1;
            end
            default: state <= B;
       endcase    
      end // 야간 state 변화
end // 주/야간별 state 변화



always @(posedge clk or posedge rst) begin
    if(rst)
        {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
      S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
      S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b0000_0000_0000_0000_0000_0000; 
      else begin
        case(state)
         A1 : if(cnt <= 25000)
                {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
                S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b0011_1100_1100_0000_0011_0000;
                else if(cnt <= 30000)
                {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
                S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b0000_1100_1100_0000_0011_0000; //flick off
                else if(cnt <= 35000)
                {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
                S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b0011_1100_1100_0000_0011_0000; //flick on
                else if(cnt <= 39000)
                {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
                S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b0000_1100_1100_0000_0011_0000; //flick off
                else if(cnt <= 40000)
                {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
                S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b0011_1100_1100_0000_0011_0000; //flick on
           A1toD : if(cnt <= 10000)
               {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
                S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b0000_1111_0000_1100_0011_0000;
           D : if(cnt <= 40000)
                {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
                S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b0000_1111_0000_0000_0011_1100;  
           DtoF : if(cnt <= 10000)
               {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
                S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b0000_1111_0000_1100_0011_0000;  
           F : if(cnt <= 40000)
                {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
                S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b0100_1011_0010_0000_1101_0010; 
           FtoE1 : if(cnt <= 10000)
               {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
                S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b0000_1111_0000_0010_1101_0010; 
           E1 : if(cnt <= 25000)
                {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
                S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b1100_0011_0011_0000_1100_0000;
                else if(cnt <= 30000)
                {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
                S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b0000_0011_0011_0000_1100_0000; //flick off
                else if(cnt <= 35000)
                {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
                S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b1100_0011_0011_0000_1100_0000; //flick on
                else if(cnt <= 40000)
                {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
                S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b0000_0011_0011_0000_1100_0000; //flick off
           E1toG : if(cnt <= 10000)
               {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
                S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b0000_1111_0000_0011_1100_0000;
           G : if(cnt <= 25000)
                {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
                S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b1000_0111_0001_0000_1110_0001;
                else if(cnt <= 30000)
                {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
                S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b0000_0111_0001_0000_1110_0001; //flick off
                else if(cnt <= 35000)
                {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
                S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b1000_0111_0001_0000_1110_0001; //flick on
                else if(cnt <= 40000)
                {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
                S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b0000_0111_0001_0000_1110_0001; //flick off
           GtoE2 : if(cnt <= 10000)
               {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
                S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b0000_1111_0000_0001_1110_0000; 
           E2 : if(cnt <= 25000)
                {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
                S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b1100_0011_0011_0000_1100_0000; 
                else if(cnt <= 30000)
                {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
                S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b0000_0011_0011_0000_1100_0000; //flick off
                else if(cnt <= 35000)
                {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
                S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b1100_0011_0011_0000_1100_0000; //flick on
                else if(cnt <= 40000)
                {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
                S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b0000_0011_0011_0000_1100_0000; //flick off
           E2toA1 : if(cnt <= 10000)
               {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
                S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
                S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b0000_1111_0000_0011_1100_0000;
//주간 state


       B : if(cnt <= 50000)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
           S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b0001_1110_0100_0000_1011_0100; //flick on
           else if(cnt <= 60000)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
           S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b0000_1110_0100_0000_1011_0100; //flick off
           else if(cnt <= 70000)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
           S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b0001_1110_0100_0000_1011_0100; //flick on
           else if(cnt <= 80000)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
           S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b0000_1110_0100_0000_1011_0100; //flick off
           else if(cnt <= 90000)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
           S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b0001_1110_0100_0000_1011_0100; //flick on
       BtoA2 : if(cnt <= 10000)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
           S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b0000_1111_0000_0100_1011_0000;
       A2 : if(cnt <= 50000)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
           S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b0011_1100_1100_0000_0011_0000;
           else if(cnt <= 60000)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
           S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b0000_1100_1100_0000_0011_0000; //flick off
           else if(cnt <= 70000)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
           S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b0011_1100_1100_0000_0011_0000; //flick on
           else if(cnt <= 80000)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
           S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b0000_1100_1100_0000_0011_0000; //flick off
           else if(cnt <= 90000)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
           S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b0011_1100_1100_0000_0011_0000; //flick on
       A2toC : if(cnt <= 10000)
           {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
           S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b0000_1111_0000_1100_0011_0000;
       C : if(cnt <= 50000)
           {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
          S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
          S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b0010_1101_1000_0000_0111_1000;
          else if(cnt <= 60000)
           {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
          S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
          S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b0000_1101_1000_0000_0111_1000; //flick off
          else if(cnt <= 70000)
           {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
          S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
          S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b0010_1101_1000_0000_0111_1000; //flick on
          else if(cnt <= 80000)
           {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
          S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
          S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b0000_1101_1000_0000_0111_1000; //flick off
          else if(cnt <= 90000)
           {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
          S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
          S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b0010_1101_1000_0000_0111_1000; //flick on
      CtoA3 : if(cnt <= 10000)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
          S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
          S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b0000_1111_0000_1000_0111_0000;
      A3 : if(cnt <= 50000)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
           S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b0011_1100_1100_0000_0011_0000;
           else if(cnt <= 60000)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
           S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b0000_1100_1100_0000_0011_0000; //flick off
           else if(cnt <= 70000)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
           S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b0011_1100_1100_0000_0011_0000; //flick on
           else if(cnt <= 80000)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
           S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b0000_1100_1100_0000_0011_0000; //flick off
           else if(cnt <= 90000)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
           S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b0011_1100_1100_0000_0011_0000; //flick on
       A3toE3 : if(cnt <= 10000)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
           S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b0000_1111_0000_1100_0011_0000;
       E3 : if(cnt <= 50000)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
           S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b1100_0011_0011_0000_1100_0000;
           else if(cnt <= 60000)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
           S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b0000_0011_0011_0000_1100_0000; //flick off
           else if(cnt <= 70000)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
           S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b1100_0011_0011_0000_1100_0000; //flick on
           else if(cnt <= 80000)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
           S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b0000_0011_0011_0000_1100_0000;//flick off
           else if(cnt <= 90000)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
           S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b1100_0011_0011_0000_1100_0000;
       E3toH : if(cnt <= 10000)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
           S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b0000_1111_0000_0011_1100_0000;
       H : if(cnt <= 90000)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
           S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b0000_1111_0000_0000_1100_0011;
       HtoB : if(cnt <= 10000)
          {S_W_GREEN, N_W_GREEN, W_W_GREEN, E_W_GREEN, S_W_RED, N_W_RED, W_W_RED, E_W_RED, 
           S_GREEN, N_GREEN, W_GREEN, E_GREEN, S_YELLOW, N_YELLOW, W_YELLOW, E_YELLOW,
           S_RED, N_RED, W_RED, E_RED, S_LEFT, N_LEFT, W_LEFT, E_LEFT} = 24'b0000_1111_0000_0011_1100_0000;
//야간 state

       endcase
   end
end          

endmodule
