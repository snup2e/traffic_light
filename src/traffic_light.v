`timescale 1ns / 1ps

module traffic_light #(parameter cnt1ms = 100000)
(   input clk,
    input resetn,
    output reg lcd_e,
    output reg lcd_rs,
    output lcd_rw,
    output reg [7:0] lcd_data,
    output reg [7:0] digit,
    output reg [7:0] seg_data);

reg [31:0] cnt_clk;
reg [4:0] cnt_4m, cnt_line;
reg [11:0] cnt_42,cnt_42_B,cnt_24;
reg tick1m, tick4m,tick42_delay,tick42_delay_B, tick24_delay,tick_line;
reg [4:0] lcd_routine;

///상태 파라미터//
parameter delay_4ms = 0;
parameter function_set =1;
parameter entry_mode =2;
parameter disp_on =3;
parameter disp_000 =4;
parameter disp_001 =5;
parameter display_clear = 6;
parameter disp_010 =7;
parameter disp_011 =8;
parameter display_clear_B =9;
parameter disp_110 =10;
parameter disp_111 =11;
parameter display_clear_C =12;
parameter disp_100 =13;
parameter disp_101 =14;
parameter display_clear_D =15;
parameter start_clear = 16;

parameter address_line1 = 8'b1000_0000;
parameter address_line2 = 8'b1100_0000;

`include "data_line1.sv"//EW : green
`include "data_line2.sv"//EW : yellow
`include "data_line3.sv"//Ew : red
`include "data_line4.sv"//SN : green
`include "data_line5.sv"//SN : yellow
`include "data_line6.sv"//SN : red

/////////////////1ms tick////////////////////
always @(posedge clk) 
begin
    if(!resetn)
    begin
        cnt_clk <= 32'd0;
        tick1m <=1'b0;
    end
    else
    begin
        if(cnt_clk == (cnt1ms-1))
        begin 
            cnt_clk <=0;
            tick1m <= 1'b1;
        end
        else
        begin
            cnt_clk <= cnt_clk + 1;
            tick1m <= 1'b0;
        end
     end
end

/////////////////4ms tick////////////////////
always @(posedge clk)
begin
    if(!resetn)
    begin
        cnt_4m <=0;
        tick4m <= 1'b0;
    end
    else
    begin
        if(tick1m)
            if(cnt_4m == 3)
            begin
                cnt_4m <=0;
                tick4m <=1'b1;
            end
            else cnt_4m <= cnt_4m + 1;
         else  tick4m <= 1'b0;
    end
end

/////////////////tick_line////////////////////
always @(posedge clk)
begin
    if(!resetn)
    begin
        cnt_line<=0;
        tick_line<=1'b0;
    end
    else
    begin
        if(lcd_routine == disp_000 || lcd_routine == disp_001 || lcd_routine == disp_010
               || lcd_routine == disp_011 || lcd_routine == disp_110 || lcd_routine == disp_111
               || lcd_routine == disp_100 || lcd_routine == disp_101)
        begin
            if(tick4m)
            begin
                if(cnt_line == 16)
                begin
                    cnt_line<=0;
                    tick_line <=1'b1;
                end
                else cnt_line <= cnt_line + 1;
            end
            else tick_line <= 1'b0;
         end
         else
         begin
            cnt_line <=0;
            tick_line <= 1'b0;
         end
     end
end

/////////////////tick42_delay////////////////////
////////////////4초 만들기 위한 지연///////////
always @(posedge clk)
begin
    if(!resetn)
    begin
        cnt_42 <=0;
        tick42_delay <= 1'b0;
    end
    else
    begin
        if(lcd_routine == disp_001)
            begin
            if(tick4m)
                if(cnt_42 == 977 )   // 999 - 16(line tick)-6(6 x 4ms tick) = 977
                begin
                    cnt_42 <=0;
                    tick42_delay <=1'b1;
                end
                else cnt_42 <= cnt_42 + 1;
             else  tick42_delay <= 1'b0;
             end
        else
        begin
            cnt_42 <=0;
            tick42_delay <= 1'b0;
        end
                 
    end
end

/////////////////tick42_delay_B////////////////////
always @(posedge clk)
begin
    if(!resetn)
    begin
        cnt_42_B <=0;
        tick42_delay_B <= 1'b0;
    end
    else
    begin
        if(lcd_routine == disp_111)
            begin
            if(tick4m)
                if(cnt_42_B == 982)   // 999 - 16(line tick)-1(4ms tick) = 982
                begin
                    cnt_42_B <=0;
                    tick42_delay_B <=1'b1;
                end
                else cnt_42_B <= cnt_42_B + 1;
             else  tick42_delay_B <= 1'b0;
             end
        else
        begin
            cnt_42_B <=0;
            tick42_delay_B <= 1'b0;
        end
                 
    end
end

/////////////////tick24_delay////////////////////
always @(posedge clk)
begin
    if(!resetn)
    begin
        cnt_24 <=0;
        tick24_delay <= 1'b0;
    end
    else
    begin
        if(lcd_routine == disp_001 || lcd_routine == disp_111)
            begin
            if(tick4m)
                if(cnt_24 == 482)   // 499 - 16(line tick)-1(4ms tick) = 482
                begin
                    cnt_24 <=0;
                    tick24_delay <=1'b1;
                end
                else cnt_24 <= cnt_24 + 1;
             else  tick24_delay <= 1'b0;
             end
         else
         begin
            cnt_24 <=0;
            tick24_delay <= 1'b0;
         end
    end
end


/////////////////FSM /////////////////////
always @(posedge clk)
begin
    if(!resetn)
        lcd_routine <= start_clear;
    else
    begin
        case(lcd_routine)
            start_clear : if(tick4m)lcd_routine <= delay_4ms;
            delay_4ms: if(tick4m)   lcd_routine <= function_set;
            function_set: if(tick4m)lcd_routine <= entry_mode;
            entry_mode: if(tick4m)  lcd_routine <= disp_on;
            disp_on  : if(tick4m)   lcd_routine <= disp_000;
            
            disp_000 : if(tick_line)   lcd_routine <= disp_001;
            disp_001 : if(tick42_delay)   lcd_routine <= display_clear;  
            display_clear:if(tick4m)    lcd_routine <= disp_010;        //// 여기까지 정확히 4초
            
            disp_010 : if(tick_line)   lcd_routine <= disp_011;
            disp_011 : if(tick24_delay)   lcd_routine <= display_clear_B;  
            display_clear_B:if(tick4m)    lcd_routine <= disp_110;      /// 여기까지 정확히 4+2초
           
            disp_110 : if(tick_line)   lcd_routine <= disp_111;
            disp_111 : if(tick42_delay_B)   lcd_routine <= display_clear_C; 
            display_clear_C:if(tick4m)    lcd_routine <= disp_100;      /// 여기까지 정확히 4+2+4초
            
            disp_100 : if(tick_line)   lcd_routine <= disp_101;
            disp_101 : if(tick24_delay)   lcd_routine <= display_clear_D; 
            display_clear_D:if(tick4m)    lcd_routine <= start_clear;   /// 여기까지 정확히 4+2+4+2 = 12초
            default  : lcd_routine <= start_clear;
         endcase
     end
 end
 
 //////lcd_rw 할당///////////
 assign lcd_rw = 1'b0;
localparam [2:0] half4m = 3;
 ///////////////lcd_rs 할당///////////////////////
 always@(posedge clk) begin
    if(!resetn) lcd_rs <=1'b0;
    else
    begin
        if(lcd_routine == disp_000 || lcd_routine == disp_001 || lcd_routine == disp_010
           || lcd_routine == disp_011 || lcd_routine == disp_100 || lcd_routine == disp_101
           || lcd_routine == disp_110 || lcd_routine == disp_111)
        begin
            if(cnt_line==0) lcd_rs <=0;  //for address
            else            lcd_rs <=1; // for data
        end
        else lcd_rs <= 1'b0;
    end
end
 ////////////////상태 assign///////////////////////
 always @(posedge clk)
 begin
    if(!resetn)
    begin
        lcd_data <=8'b0000_0000;
        lcd_e <= 1'b0;
    end
    else
    begin
        if(tick1m)
        begin
            case(lcd_routine)
                delay_4ms : begin lcd_data <=8'b0000_0000; lcd_e <= 1'b0; end
                function_set : begin lcd_data <= 8'b0011_1000;
                                if (cnt_4m >=1 & cnt_4m <= half4m)
                                    lcd_e <= 1'b1;
                                else
                                    lcd_e <= 1'b0; end
                entry_mode: begin lcd_data <= 8'b0000_0110; 
                                if(cnt_4m>=1&cnt_4m <=half4m)
                                    lcd_e <=1'b1;
                                else
                                    lcd_e <=1'b0; end
                disp_on: begin lcd_data <= 8'b0000_1100;
                                if(cnt_4m >=1&cnt_4m <=half4m)
                                    lcd_e<=1'b1;
                                else
                                    lcd_e <= 1'b0; end   
                disp_000: begin if(cnt_line ==0) lcd_data<= address_line1;
                                  else lcd_data<= data_line1(cnt_line-1);
                                  if(cnt_4m >=1 & cnt_4m <= half4m) lcd_e <=1'b1;
                                  else lcd_e <= 1'b0; end
                disp_001: begin if(cnt_line ==0) lcd_data<= address_line2;
                                  else lcd_data<= data_line6(cnt_line-1);
                                  if(cnt_4m >=1 & cnt_4m <= half4m) lcd_e <=1'b1;
                                  else lcd_e <= 1'b0; end
                disp_010: begin if(cnt_line ==0) lcd_data<= address_line1;
                                  else lcd_data<= data_line2(cnt_line-1);
                                  if(cnt_4m >=1 & cnt_4m <= half4m) lcd_e <=1'b1;
                                  else lcd_e <= 1'b0; end
                disp_011: begin if(cnt_line ==0) lcd_data<= address_line2;
                                  else lcd_data<= data_line6(cnt_line-1);
                                  if(cnt_4m >=1 & cnt_4m <= half4m) lcd_e <=1'b1;
                                  else lcd_e <= 1'b0; end
                disp_110: begin if(cnt_line ==0) lcd_data<= address_line1;
                                  else lcd_data<= data_line3(cnt_line-1);
                                  if(cnt_4m >=1 & cnt_4m <= half4m) lcd_e <=1'b1;
                                  else lcd_e <= 1'b0; end                                               
                disp_111: begin if(cnt_line ==0) lcd_data<= address_line2;
                                  else lcd_data<= data_line4(cnt_line-1);
                                  if(cnt_4m >=1 & cnt_4m <= half4m) lcd_e <=1'b1;
                                  else lcd_e <= 1'b0; end                   
                disp_100: begin if(cnt_line ==0) lcd_data<= address_line1;
                                  else lcd_data<= data_line3(cnt_line-1);
                                  if(cnt_4m >=1 & cnt_4m <= half4m) lcd_e <=1'b1;
                                  else lcd_e <= 1'b0; end                  
                disp_101: begin if(cnt_line ==0) lcd_data<= address_line2;
                                  else lcd_data<= data_line5(cnt_line-1);
                                  if(cnt_4m >=1 & cnt_4m <= half4m) lcd_e <=1'b1;
                                  else lcd_e <= 1'b0; end
                                  
                start_clear :begin lcd_data <= 8'b0000_0001;
                                if (cnt_4m >= 1 & cnt_4m <= half4m)
                                  lcd_e <= 1'b1;
                                else
                                  lcd_e <= 1'b0;  end                  
                display_clear :
                  begin
                    lcd_data <= 8'b0000_0001;
                    if (cnt_4m >= 1 & cnt_4m <= half4m)
                      lcd_e <= 1'b1;
                    else
                      lcd_e <= 1'b0;
                  end
                display_clear_B :
                  begin
                    lcd_data <= 8'b0000_0001;
                    if (cnt_4m >= 1 & cnt_4m <= half4m)
                      lcd_e <= 1'b1;
                    else
                      lcd_e <= 1'b0;
                  end
                display_clear_C :
                  begin
                    lcd_data <= 8'b0000_0001;
                    if (cnt_4m >= 1 & cnt_4m <= half4m)
                      lcd_e <= 1'b1;
                    else
                      lcd_e <= 1'b0;
                  end
                display_clear_D :
                  begin
                    lcd_data <= 8'b0000_0001;
                    if (cnt_4m >= 1 & cnt_4m <= half4m)
                      lcd_e <= 1'b1;
                    else
                      lcd_e <= 1'b0;
                  end                  
                                  
             endcase       
       end                                                    
    end
end

////////////////7-segment///////////////////////
wire clk_1hz;
clock_divider #(49999999) div1(clk,clk_1hz);  // 1hz signal 

// 1Hz 대신 원하는 속도로 바꿔도 되고, 예시로 clk_1hz 그대로 씁니다.
reg [3:0] i;

always @(posedge clk_1hz or negedge resetn) begin
  if (!resetn) begin
    i        <= 0;
    digit    <= 8'b1000_0000; // step 0: 1xxx_xxxx
    seg_data <= 8'b0110_0000; // '1'
  end else begin
    // 1) 인덱스 순환: 0→11→0→…
    if (i == 11)
      i <= 0;
    else
      i <= i + 1;

    // 2) digit & seg_data 동시 업데이트
    case (i)
      0:  begin digit <= 8'b1000_0000; seg_data <= 8'b0110_0000; end // 1xxx_xxxx, '1'
      1:  begin digit <= 8'b0100_0000; seg_data <= 8'b1101_1010; end // x2xx_xxxx, '2'
      2:  begin digit <= 8'b0010_0000; seg_data <= 8'b1111_0010; end // xx3x_xxxx, '3'
      3:  begin digit <= 8'b0001_0000; seg_data <= 8'b0110_0110; end // xxx4_xxxx, '4'
      4:  begin digit <= 8'b1000_0000; seg_data <= 8'b0110_0000; end // 1xxx_xxxx, '1'
      5:  begin digit <= 8'b0100_0000; seg_data <= 8'b1101_1010; end // x2xx_xxxx, '2'
      6:  begin digit <= 8'b0000_1000; seg_data <= 8'b0110_0000; end // xxxx_1xxx, '1'
      7:  begin digit <= 8'b0000_0100; seg_data <= 8'b1101_1010; end // xxxx_x2xx, '2'
      8:  begin digit <= 8'b0000_0010; seg_data <= 8'b1111_0010; end // xxxx_xx3x, '3'
      9:  begin digit <= 8'b0000_0001; seg_data <= 8'b0110_0110; end // xxxx_xxx4, '4'
      10: begin digit <= 8'b0000_1000; seg_data <= 8'b0110_0000; end // xxxx_1xxx, '1'
      11: begin digit <= 8'b0000_0100; seg_data <= 8'b1101_1010; end // xxxx_x2xx, '2'
      default: begin
        digit    <= 8'b1000_0000;
        seg_data <= 8'b0110_0000;
      end
    endcase
  end
end

endmodule
      
/////////clock divider 모듈/////////////////////
module clock_divider #(parameter div = 49999999)(input clk,output reg clk_out);

reg [25:0] q;

initial begin
q<=0;
clk_out = 0;
end

always @(posedge clk) begin
    if (q == div)begin
        clk_out <= ~clk_out;
        q<=0;
        end
    else q <= q + 1;
    end
endmodule            
    













