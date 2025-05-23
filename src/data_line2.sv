// 라인-1에 디스플레이된 문자 데이터(표 12.5의 ASCII 코드값을 할당)
function [7:0] data_line2;
    input [3:0] addr_in;

    begin
        case (addr_in)
            0  : data_line2 = 8'b0100_0101;  // E
            1  : data_line2 = 8'b0101_0111;  // W
            2  : data_line2 = 8'b0010_0000;  // blank
            3  : data_line2 = 8'b0010_0000;  // blank
            4  : data_line2 = 8'b0010_0000;  // blank
            5  : data_line2 = 8'b0010_0000;  // blank
            6  : data_line2 = 8'b0010_0000;  // blank
            7  : data_line2 = 8'b0010_0000;  // blank
            8  : data_line2 = 8'b0101_1001;  // Y 
            9  : data_line2 = 8'b0100_0101;  // E
            10 : data_line2 = 8'b0100_1100;  // L
            11 : data_line2 = 8'b0100_1100;  // L
            12 : data_line2 = 8'b0100_1111;  // O
            13 : data_line2 = 8'b0101_0111;  // W
            14 : data_line2 = 8'b0010_0000;  // blank
            15 : data_line2 = 8'b0010_0000;  // blank
            default : data_line2 = 8'b0000_0000;
        endcase
    end
endfunction
