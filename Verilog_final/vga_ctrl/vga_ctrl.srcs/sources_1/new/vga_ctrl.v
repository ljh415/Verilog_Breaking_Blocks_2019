module vga_ctrl
(
    pclk, reset,                    //pclk에 25MHz값이 들어간다면?
    hcount, vcount,	//  h & v count  ->  픽셀 counter
    hs, vs		// horizontal & vertical sync       hs => 한 라인의 시작  vs => 한 화면의 시작
);

input        pclk, reset;
output [9:0] hcount, vcount;
output       hs, vs;

reg [9:0] hcount, vcount;
reg       hs, vs;

`define HMAX   10'd 799 // h count max
`define VMAX   10'd 520 // v count max
`define HSS    10'd 655 // hsync start, pels (640) + front_porch (16) - 1 
`define HSE    10'd 751 // hsync end, HSS + pulse_width (96)
`define VSS    10'd 489 // vsync start, lines (480) + front_porch (10) - 1
`define VSE    10'd 491 // vsync end, VSS + pulse_width (2)

// h counter running from 0 to HMAX
always @(posedge pclk or posedge reset) begin
    if (reset)
        hcount <= 0;
    else if (hcount == `HMAX)
        hcount <= 0;
    else
        hcount <= hcount+1;
end

// v counter running from 0 to VMAX
always @(posedge pclk or posedge reset) begin
    if (reset)
        vcount <= 0;
    else if (hcount == `HMAX) begin
        if (vcount == `VMAX)
            vcount <= 0;
        else
            vcount <= vcount + 1;
    end
end

// h sync -> 한 라인의 시작 (active low)
always @(posedge pclk or posedge reset) begin
    if (reset)
	hs <= 1;
    else if (hcount == `HSS)
        hs <= 0;
    else if (hcount == `HSE)
        hs <= 1;
end

// v sync -> 한 화면의 시작
always @(posedge pclk or posedge reset) begin
    if(reset)
    vs <= 1;
    else if (hcount==`HSS) begin
        if(vcount == `VSS)
            vs <= 0;
        else if (vcount == `VSE)
            vs <= 1;
    end
end

endmodule
