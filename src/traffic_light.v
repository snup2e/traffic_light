`timescale 1ns / 1ps

module traffic_light #(parameter cnt1ms = 100000)
(   input clk,
    input resetn,
    output lcd_e,
    output lcd_rs,
    output lcd_rw,
    output reg [7:0] lcd_data,
    output reg [7:0] digit,
    output reg [7:0] seg_data
);

reg [31:0] cnt_clk;
reg [4:0] cnt_4m, cnt_line;
reg [11:0] cnt_1s, cnt_2s, cnt_4s, cnt_42, cnt_24;
reg tick1m, tick4m, tick1s,tick2s, tick4s,tick42_delay, tick24_delay, tick_line;
reg [3:0] lcd_routine;
reg lcd_e, lcd_rs;

parameter delay_4ms = 0;
parameter function_set =1;
parameter entry_mode =2;
parameter disp_on =3;
parameter disp_000 =4;
parameter disp_001 =5;
parameter disp_010 =6;
parameter disp_011 =7;
parameter disp_110 =8;
parameter disp_111 =9;
parameter disp_100 =10;
parameter disp_101 =11;
parameter start_clear = 12;

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

/////////////////1s tick////////////////////
always @(posedge clk)
begin
    if(!resetn)
    begin
        cnt_1s <=0;
        tick1s <= 1'b0;
    end
    else
    begin
        if(tick4m)
            if(cnt_1s == 249)
            begin
                cnt_1s <=0;
                tick1s <=1'b1;
            end
            else cnt_1s <= cnt_1s + 1;
         else  tick1s <= 1'b0;
    end
end

/////////////////2s tick////////////////////
always @(posedge clk)
begin
    if(!resetn)
    begin
        cnt_2s <=0;
        tick2s <= 1'b0;
    end
    else
    begin
        if(tick1s)
            if(cnt_2s == 1)
            begin
                cnt_2s <=0;
                tick2s <=1'b1;
            end
            else cnt_2s <= cnt_2s + 1;
         else  tick2s <= 1'b0;
    end
end     

/////////////////4s tick////////////////////
always @(posedge clk)
begin
    if(!resetn)
    begin
        cnt_4s <=0;
        tick4s <= 1'b0;
    end
    else
    begin
        if(tick1s)
            if(cnt_4s == 3)
            begin
                cnt_4s <=0;
                tick4s <=1'b1;
            end
            else cnt_4s <= cnt_4s + 1;
         else  tick4s <= 1'b0;
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
always @(posedge clk)
begin
    if(!resetn)
    begin
        cnt_42 <=0;
        tick42_delay <= 1'b0;
    end
    else
    begin
        if(tick4m)
            if(cnt_42 == 483 )   // 499 - 16(line tick) = 483
            begin
                cnt_42 <=0;
                tick42_delay <=1'b1;
            end
            else cnt_42 <= cnt_42 + 1;
         else  tick42_delay <= 1'b0;
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
        if(tick4m)
            if(cnt_24 == 233 )   // 249 - 16(line tick) = 233
            begin
                cnt_24 <=0;
                tick24_delay <=1'b1;
            end
            else cnt_24 <= cnt_24 + 1;
         else  tick24_delay <= 1'b0;
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
            disp_001 : if(tick42_delay)   lcd_routine <= disp_010;
            
            disp_010 : if(tick_line)   lcd_routine <= disp_011;
            disp_011 : if(tick24_delay)   lcd_routine <= disp_110;
           
            disp_110 : if(tick_line)   lcd_routine <= disp_111;
            disp_111 : if(tick42_delay)   lcd_routine <= disp_100;
            
            disp_100 : if(tick_line)   lcd_routine <= disp_101;
            disp_101 : if(tick24_delay)   lcd_routine <= disp_000;
            
            default  : lcd_routine <= start_clear;
         endcase
     end
 end
 
 assign lcd_rw = 1'b0;
 wire [2:0] half4m = 3;
 
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
                                  
                                  
             endcase       
       end                                                    
    end
end

////////////////7-segment///////////////////////

////////////display 할때마다 카운터 증가시키고 한사이클 지나면 초기화////////
reg [2:0] display_cnt;
always @(posedge clk)
begin
    if(!resetn) display_cnt <= 0;
    else if (cnt_line == 1)                    //cnt_line이 상승하는 가장 빠른 타이밍(쓰기르 시작할 때)
    begin
        if (display_cnt == 7) display_cnt <=0;
        else display_cnt <= display_cnt + 1;           /////한 사이클 돌면 초기화
    end                                            
end            

//////////////// 4초,2초, 왼쪽,오른쪽 따라서 digit 분할/////////////
wire clk_1hz;
clock_divider #(49999999) div1(clk,clk_1hz);  // 1hz signal 
      
always @(posedge clk_1hz)
begin
    if(!resetn) digit <= 8'b0000_0001;  ///가장 왼쪽 segment
    else
    begin
        if (display_cnt < 4) digit <= 8'b0000_0001 << display_cnt; //왼쪽 segment 구간
        else                                                        
        begin            
            digit <= 8'b0001_0000 >> (display_cnt-4);                    // 오른쪽 segment 구간
        end
    end
end

///////////////// digit에 따라서 seg_data 할당 ////////////
always @(posedge clk_1hz)
begin
    if(!resetn) seg_data <= 8'b0000_0000;
    else
        if (display_cnt[1] == 0) // 4초 구간
        begin
            case(digit)
                8'b0000_0001 : seg_data <= 8'b0110_0000;// 1 출력 (왼쪽 4비트)
                8'b1000_0000 : seg_data <= 8'b1101_1010;// 2
                8'b0100_0000 : seg_data <= 8'b1111_0010;// 3
                8'b0010_0000 : seg_data <= 8'b0100_0110;// 4
                8'b0001_0000 : seg_data <= 8'b0110_0000;// 1 출력 (오른쪽 4비트)
                8'b0000_1000 : seg_data <= 8'b1101_1010;// 2
                8'b0000_0100 : seg_data <= 8'b1111_0010;// 3
                8'b0000_0010 : seg_data <= 8'b0100_0110;// 4
                default : seg_data <= 8'd0;
            endcase
        end
        else if(display_cnt[1] == 1'b1)      // 2초 구간
        begin
            case(digit)
                8'b0000_0001 : seg_data <= 8'b0110_0000;// 1 출력 (왼쪽 4비트)
                8'b1000_0000 : seg_data <= 8'b1101_1010;// 2              
                8'b0001_0000 : seg_data <= 8'b0110_0000;// 1 출력 (오른쪽 4비트)
                8'b0000_1000 : seg_data <= 8'b1101_1010;// 2
                default : seg_data <= 8'd0;
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