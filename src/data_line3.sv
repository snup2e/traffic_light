// 라인-1에 디스플레이된 문자 데이터(표 12.5의 ASCII 코드값을 할당)
function [7:0] data_line3;
    input [3:0] addr_in;

    begin
        case (addr_in)
            0  : data_line3 = 8'b0100_0101;  // E
            1  : data_line3 = 8'b0101_0111;  // W
            2  : data_line3 = 8'b0010_0000;  // blank
            3  : data_line3 = 8'b0010_0000;  // blank
            4  : data_line3 = 8'b0010_0000;  // blank
            5  : data_line3 = 8'b0010_0000;  // blank
            6  : data_line3 = 8'b0010_0000;  // blank
            7  : data_line3 = 8'b0010_0000;  // blank
            8  : data_line3 = 8'b0101_0010;  // R
            9  : data_line3 = 8'b0100_0101;  // E
            10 : data_line3 = 8'b0100_0100;  // D
            11 : data_line3 = 8'b0010_0000;  // blank
            12 : data_line3 = 8'b0010_0000;  // blank
            13 : data_line3 = 8'b0010_0000;  // blank
            14 : data_line3 = 8'b0010_0000;  // blank
            15 : data_line3 = 8'b0010_0000;  // blank
            default : data_line3 = 8'b0000_0000;
        endcase
    end
endfunction