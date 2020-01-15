// Function that converts 4 bit hex number to 7 bit ssd control signal.

function [6:0] hex2ssd;
    input [3:0] ssd;
    case (ssd)
	4'b0000: hex2ssd = 7'b0000001 ; // 0
	4'b0001: hex2ssd = 7'b1001111 ; // 1
	4'b0010: hex2ssd = 7'b0010010 ; // 2
	4'b0011: hex2ssd = 7'b0000110 ; // 3
	4'b0100: hex2ssd = 7'b1001100 ; // 4
	4'b0101: hex2ssd = 7'b0100100 ; // 5
	4'b0110: hex2ssd = 7'b0100000 ; // 6
	4'b0111: hex2ssd = 7'b0001111 ; // 7
	4'b1000: hex2ssd = 7'b0000000 ; // 8
	4'b1001: hex2ssd = 7'b0000100 ; // 9
	4'b1010: hex2ssd = 7'b0001000 ; // A
	4'b1011: hex2ssd = 7'b1100000 ; // b
	4'b1100: hex2ssd = 7'b0110001 ; // C
	4'b1101: hex2ssd = 7'b1000010 ; // d
	4'b1110: hex2ssd = 7'b0110000 ; // E
	4'b1111: hex2ssd = 7'b0111000 ; // F    
	default: hex2ssd = 7'bXXXXXXX ; // default isnot needed as we covered all cases
    endcase
endfunction
