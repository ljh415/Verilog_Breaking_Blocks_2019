module final
// VGA test module to display a bouncing ball. By controlling the switch, the
// speed of the ball can be changed.
//
(
    CLK100MHZ,
    BTNC,
    SW,		       // switch inputs
    VGA_HS,		   // horizontal sync
    VGA_VS,		   // vertical sync
    VGA_R,	
    VGA_G,
    VGA_B,
    
    BTND,           // bar
    BTNU,            // bar
    BTNR,
    BTNL,
    
    AN,
    CA,CB, CC, CD, CE, CF, CG,
    
    LED
);

input           CLK100MHZ;
input           BTNC;
input   [15:0]  SW;
output          VGA_HS;
output          VGA_VS;
output  [3:0]   VGA_R;
output  [3:0]   VGA_G;
output  [3:0]   VGA_B;

input           BTND;
input           BTNU;
input           BTNR;
input           BTNL;

output  [7:0]   AN;
output          CA, CB, CC, CD, CE, CF, CG;

output  [15:0]  LED;

// local signal declaration
wire       reset = BTNC;

reg  [11:0] rgb;             //4bit x 3(RGB)

wire [9:0]  hcount;          // 0~799 -> 10bit
wire [9:0]  vcount;          // 0~521 -> 10bit
reg         pclk;
reg  [7:0]  counter;         // 내부적으로 쓰일것

reg  [3:0]  ball_speed;      // 공의 속도를 나타내는 신호 4비트(하위 4비트 스위치 사용)
reg         ball_h_dir;      // 수평방향을 나타내는 것. 끝에 벽을 만나면 방향이 바뀐다. (왼쪽인지 오른쪽인지)
reg         ball_v_dir;      // 수직방향, 위아래 벽을 만나면 방향이 바뀐다(위, 아래)
reg  [3:0]  switch_speed;    //맨 처음에 스위치에서 속도를 받아옴

reg  [3:0]  ball_yspd;     //ball_speed를 대신해서 세로축 속도
reg  [3:0]  ball_xspd;     //                      가로축 속도

reg  [9:0]  ball_hpos;       //볼의 위치를 알고 있어야 그 다음 프레임에 볼의 스피드만큼 표시를 해준다.
reg  [9:0]  ball_vpos;

reg  [9:0]  bar_hpos;
reg  [9:0]  bar_vpos;        // 바의 위치(바의 스피드 만큼 표시)

//벽돌의 위치
reg  [9:0]  block1_hpos;
reg  [9:0]  block1_vpos;
reg  [9:0]  block2_hpos;
reg  [9:0]  block2_vpos;
reg  [9:0]  block3_hpos;
reg  [9:0]  block3_vpos;
reg  [9:0]  block4_hpos;
reg  [9:0]  block4_vpos;
reg  [9:0]  block5_hpos;
reg  [9:0]  block5_vpos;
reg  [9:0]  block6_hpos;
reg  [9:0]  block6_vpos;
reg  [9:0]  block7_hpos;
reg  [9:0]  block7_vpos;
reg  [9:0]  block8_hpos;
reg  [9:0]  block8_vpos;
reg  [9:0]  block9_hpos;
reg  [9:0]  block9_vpos;
reg  [9:0]  block10_hpos;
reg  [9:0]  block10_vpos;

reg  [9:0]  block11_hpos;
reg  [9:0]  block11_vpos;
reg  [9:0]  block12_hpos;
reg  [9:0]  block12_vpos;
reg  [9:0]  block13_hpos;
reg  [9:0]  block13_vpos;
reg  [9:0]  block14_hpos;
reg  [9:0]  block14_vpos;
reg  [9:0]  block15_hpos;
reg  [9:0]  block15_vpos;
reg  [9:0]  block16_hpos;
reg  [9:0]  block16_vpos;
reg  [9:0]  block17_hpos;
reg  [9:0]  block17_vpos;
reg  [9:0]  block18_hpos;
reg  [9:0]  block18_vpos;
reg  [9:0]  block19_hpos;
reg  [9:0]  block19_vpos;
reg  [9:0]  block20_hpos;
reg  [9:0]  block20_vpos;

reg  [9:0]  block21_hpos;
reg  [9:0]  block21_vpos;
reg  [9:0]  block22_hpos;
reg  [9:0]  block22_vpos;
reg  [9:0]  block23_hpos;
reg  [9:0]  block23_vpos;
reg  [9:0]  block24_hpos;
reg  [9:0]  block24_vpos;
reg  [9:0]  block25_hpos;
reg  [9:0]  block25_vpos;
reg  [9:0]  block26_hpos;
reg  [9:0]  block26_vpos;
reg  [9:0]  block27_hpos;
reg  [9:0]  block27_vpos;
reg  [9:0]  block28_hpos;
reg  [9:0]  block28_vpos;


`define HPIXELS     11'd640
`define VLINES      11'd480

//공크기 8 x 8
`define BALL_HSIZE  10'd10
`define BALL_VSIZE  10'd10

//바크기 8 x 24
`define BAR_HSIZE   10'd15
`define BAR_VSIZE   10'd70

//블록 7 x 58

`define BLOCK_HSIZE 10'd15
`define BLOCK_VSIZE 10'd60


//리셋버튼을 누르고 초기화시키는 공의 위치. 중앙
`define BALL_HPOS_INIT 10'd310
`define BALL_VPOS_INIT 10'd230

//바의 초기화 위치
`define BAR_HPOS_INIT 10'd0
`define BAR_VPOS_INIT 10'd230

//블록의 초기화 위치
`define BLOCK1_HPOS_INIT    10'd480
`define BLOCK1_VPOS_INIT    10'd10
`define BLOCK2_HPOS_INIT    10'd500
`define BLOCK2_VPOS_INIT    10'd10
`define BLOCK3_HPOS_INIT    10'd520
`define BLOCK3_VPOS_INIT    10'd10
`define BLOCK4_HPOS_INIT    10'd540
`define BLOCK4_VPOS_INIT    10'd10

`define BLOCK5_HPOS_INIT    10'd480
`define BLOCK5_VPOS_INIT    10'd78
`define BLOCK6_HPOS_INIT    10'd500
`define BLOCK6_VPOS_INIT    10'd78
`define BLOCK7_HPOS_INIT    10'd520
`define BLOCK7_VPOS_INIT    10'd78
`define BLOCK8_HPOS_INIT    10'd540
`define BLOCK8_VPOS_INIT    10'd78

`define BLOCK9_HPOS_INIT    10'd480
`define BLOCK9_VPOS_INIT    10'd143
`define BLOCK10_HPOS_INIT   10'd500
`define BLOCK10_VPOS_INIT   10'd143
`define BLOCK11_HPOS_INIT   10'd520
`define BLOCK11_VPOS_INIT   10'd143
`define BLOCK12_HPOS_INIT   10'd540
`define BLOCK12_VPOS_INIT   10'd143

`define BLOCK13_HPOS_INIT   10'd480
`define BLOCK13_VPOS_INIT   10'd210
`define BLOCK14_HPOS_INIT   10'd500
`define BLOCK14_VPOS_INIT   10'd210
`define BLOCK15_HPOS_INIT   10'd520
`define BLOCK15_VPOS_INIT   10'd210
`define BLOCK16_HPOS_INIT   10'd540
`define BLOCK16_VPOS_INIT   10'd210

`define BLOCK17_HPOS_INIT   10'd480
`define BLOCK17_VPOS_INIT   10'd276
`define BLOCK18_HPOS_INIT   10'd500
`define BLOCK18_VPOS_INIT   10'd276
`define BLOCK19_HPOS_INIT   10'd520
`define BLOCK19_VPOS_INIT   10'd276
`define BLOCK20_HPOS_INIT   10'd540
`define BLOCK20_VPOS_INIT   10'd276

`define BLOCK21_HPOS_INIT   10'd480
`define BLOCK21_VPOS_INIT   10'd343
`define BLOCK22_HPOS_INIT   10'd500
`define BLOCK22_VPOS_INIT   10'd343
`define BLOCK23_HPOS_INIT   10'd520
`define BLOCK23_VPOS_INIT   10'd343 
`define BLOCK24_HPOS_INIT   10'd540
`define BLOCK24_VPOS_INIT   10'd343

`define BLOCK25_HPOS_INIT   10'd480
`define BLOCK25_VPOS_INIT   10'd410
`define BLOCK26_HPOS_INIT   10'd500
`define BLOCK26_VPOS_INIT   10'd410
`define BLOCK27_HPOS_INIT   10'd520
`define BLOCK27_VPOS_INIT   10'd410
`define BLOCK28_HPOS_INIT   10'd540
`define BLOCK28_VPOS_INIT   10'd410

`define BLOCK_BREAK     10'd650

`define LEVEL_GAP       10'd45

//볼이 끝을 만나기 전까지는 자신의 방향을 기억
`define RIGHT       1'b0
`define LEFT        1'b1
`define DOWN        1'b0
`define UP          1'b1

`define COLOR_BLACK 12'h0          //RGB (0, 0, 0)
`define COLOR_WHITE	 12'hfff        //RGB (f, f, f)
`define ALL_COLOR	 SW[15:4]       //상위 12비트 버튼은 공의 색깔을 바꾸는거

`define BAR_SPEED   10'd8

reg clk_50M;
always @(posedge CLK100MHZ)
    clk_50M <= ~clk_50M;            //100M를 분주시켜서 50M펄스 생성
 
// 1KHz clock by dividing the 100MHz system clock.   
reg clk_1KHz;
reg [15:0] clkCnt_1KHz;
always @(posedge CLK100MHZ, posedge reset) begin
    if (reset) begin
        clk_1KHz <= 0;
        clkCnt_1KHz <= 0;
    end
    else begin
    if (clkCnt_1KHz == (100000/2 - 1)) begin
        clk_1KHz <= ~clk_1KHz;
        clkCnt_1KHz <= 0;
    end
    else
        clkCnt_1KHz <= clkCnt_1KHz + 1;
    end
end
    
// 100Hz clock by dividing the 1KHz system clock.
reg clk_100Hz;
reg [2:0] clkCnt_100Hz;
always @(posedge clk_1KHz, posedge reset) begin
    if (reset) begin
        clk_100Hz <= 0;
        clkCnt_100Hz <= 0;
    end
    else begin
    if (clkCnt_100Hz == (10/2 - 1)) begin
        clk_100Hz <= ~clk_100Hz;
        clkCnt_100Hz <= 0;
    end
    else
        clkCnt_100Hz <= clkCnt_100Hz + 1;
    end
end
    
// 1Hz clock by dividing the 100Hz clock.
reg clk_1Hz;
    reg [5:0] clkCnt_1Hz;
    always @(posedge clk_100Hz, posedge reset) begin
        if (reset) begin
    clk_1Hz <= 0;
    clkCnt_1Hz <= 0;
        end else begin
    if (clkCnt_1Hz == (100/2 - 1)) begin
        clk_1Hz <= ~clk_1Hz;
        clkCnt_1Hz <= 0;
    end
    else
        clkCnt_1Hz <= clkCnt_1Hz + 1;
        end
    end  

wire    sys_clk = clk_1KHz;


reg game_over;
always @(posedge clk_50M) begin
    pclk <= ~pclk;	 // 50MHz/2 = 25MHz
    switch_speed <= SW[3:0];          
    
    ball_speed <= switch_speed;
    ball_xspd <= switch_speed;
    ball_yspd <= switch_speed;

    if((ball_vpos < (bar_vpos + 10'd20)) && (ball_vpos >= bar_vpos - 10'd2) && (ball_hpos == (bar_hpos + `BAR_HSIZE))) begin
        if(ball_v_dir == `DOWN) begin
            ball_xspd <= ball_speed << 1;
            ball_yspd <= ball_speed;
        end
        else if(ball_v_dir == `UP) begin
            ball_xspd <= ball_speed;
            ball_yspd <= ball_speed << 1;
        end
    end
    
    else if ((ball_vpos < (bar_vpos + 10'd50)) && (ball_vpos >= (bar_vpos + 10'd20)) && (ball_hpos == (bar_hpos + `BAR_HSIZE))) begin
        ball_xspd <= ball_speed;
        ball_yspd <= ball_speed;
    end
    
    else if ((ball_vpos < (bar_vpos + `BAR_VSIZE + 10'd2)) && (ball_vpos >= (bar_vpos + 10'd50)) && (ball_hpos == (bar_hpos + `BAR_HSIZE))) begin
        if(ball_v_dir == `DOWN) begin
        ball_xspd <= ball_speed ;
        ball_yspd <= ball_speed << 1;
    end
    else if(ball_v_dir == `UP) begin
        ball_xspd <= ball_speed << 1;
        ball_yspd <= ball_speed;
    end
    end
    
    // 왼쪽 벽에 부딛힐 경우 볼의 위치를 밖으로 내보낸다        
    if(ball_hpos == `BLOCK_BREAK) begin
        ball_speed <= 4'd0;
        ball_xspd <= 4'd0;
        ball_yspd <= 4'd0;
    end
end

// VGA timing controller
vga_ctrl vgac
(
    .pclk        ( pclk   ),
    .reset       ( reset  ),
    .hcount      ( hcount ),
    .vcount      ( vcount ),
    .hs          ( VGA_HS ),
    .vs          ( VGA_VS )
);


// VGA color output
always @(posedge pclk) begin
    if (hcount >= ball_hpos && hcount <= (ball_hpos + `BALL_HSIZE) &&
        vcount >= ball_vpos && vcount <= (ball_vpos + `BALL_VSIZE)) begin
        rgb <= `COLOR_WHITE;
        end
        
    else if(hcount >= bar_hpos && hcount <= (bar_hpos + `BAR_HSIZE) &&
        vcount >= bar_vpos && vcount <= (bar_vpos + `BAR_VSIZE))
        begin
        rgb <= `ALL_COLOR;
        end
        
        
    else if(
        hcount >= block1_hpos && hcount <= (block1_hpos + `BLOCK_HSIZE) &&
        vcount >= block1_vpos && vcount <= (block1_vpos + `BLOCK_VSIZE) ||
        hcount >= block2_hpos && hcount <= (block2_hpos + `BLOCK_HSIZE) &&
        vcount >= block2_vpos && vcount <= (block2_vpos + `BLOCK_VSIZE) ||
        hcount >= block3_hpos && hcount <= (block3_hpos + `BLOCK_HSIZE) &&
        vcount >= block3_vpos && vcount <= (block3_vpos + `BLOCK_VSIZE) ||
        hcount >= block4_hpos && hcount <= (block4_hpos + `BLOCK_HSIZE) &&
        vcount >= block4_vpos && vcount <= (block4_vpos + `BLOCK_VSIZE) ||
        hcount >= block5_hpos && hcount <= (block5_hpos + `BLOCK_HSIZE) &&
        vcount >= block5_vpos && vcount <= (block5_vpos + `BLOCK_VSIZE) ||
        hcount >= block6_hpos && hcount <= (block6_hpos + `BLOCK_HSIZE) &&
        vcount >= block6_vpos && vcount <= (block6_vpos + `BLOCK_VSIZE) ||
        hcount >= block7_hpos && hcount <= (block7_hpos + `BLOCK_HSIZE) &&
        vcount >= block7_vpos && vcount <= (block7_vpos + `BLOCK_VSIZE) ||
        hcount >= block8_hpos && hcount <= (block8_hpos + `BLOCK_HSIZE) &&
        vcount >= block8_vpos && vcount <= (block8_vpos + `BLOCK_VSIZE) ||
        hcount >= block9_hpos && hcount <= (block9_hpos + `BLOCK_HSIZE) &&
        vcount >= block9_vpos && vcount <= (block9_vpos + `BLOCK_VSIZE) ||
        hcount >= block10_hpos && hcount <= (block10_hpos + `BLOCK_HSIZE) &&
        vcount >= block10_vpos && vcount <= (block10_vpos + `BLOCK_VSIZE) ||
        hcount >= block11_hpos && hcount <= (block11_hpos + `BLOCK_HSIZE) &&
        vcount >= block11_vpos && vcount <= (block11_vpos + `BLOCK_VSIZE) ||
        hcount >= block12_hpos && hcount <= (block12_hpos + `BLOCK_HSIZE) &&
        vcount >= block12_vpos && vcount <= (block12_vpos + `BLOCK_VSIZE) ||
        hcount >= block13_hpos && hcount <= (block13_hpos + `BLOCK_HSIZE) &&
        vcount >= block13_vpos && vcount <= (block13_vpos + `BLOCK_VSIZE) ||
        hcount >= block14_hpos && hcount <= (block14_hpos + `BLOCK_HSIZE) &&
        vcount >= block14_vpos && vcount <= (block14_vpos + `BLOCK_VSIZE) ||
        hcount >= block15_hpos && hcount <= (block15_hpos + `BLOCK_HSIZE) &&
        vcount >= block15_vpos && vcount <= (block15_vpos + `BLOCK_VSIZE) ||
        hcount >= block16_hpos && hcount <= (block16_hpos + `BLOCK_HSIZE) &&
        vcount >= block16_vpos && vcount <= (block16_vpos + `BLOCK_VSIZE) ||
        hcount >= block17_hpos && hcount <= (block17_hpos + `BLOCK_HSIZE) &&
        vcount >= block17_vpos && vcount <= (block17_vpos + `BLOCK_VSIZE) ||
        hcount >= block18_hpos && hcount <= (block18_hpos + `BLOCK_HSIZE) &&
        vcount >= block18_vpos && vcount <= (block18_vpos + `BLOCK_VSIZE) ||
        hcount >= block19_hpos && hcount <= (block19_hpos + `BLOCK_HSIZE) &&
        vcount >= block19_vpos && vcount <= (block19_vpos + `BLOCK_VSIZE) ||
        hcount >= block20_hpos && hcount <= (block20_hpos + `BLOCK_HSIZE) &&
        vcount >= block20_vpos && vcount <= (block20_vpos + `BLOCK_VSIZE) ||
        hcount >= block21_hpos && hcount <= (block21_hpos + `BLOCK_HSIZE) &&
        vcount >= block21_vpos && vcount <= (block21_vpos + `BLOCK_VSIZE) ||
        hcount >= block22_hpos && hcount <= (block22_hpos + `BLOCK_HSIZE) &&
        vcount >= block22_vpos && vcount <= (block22_vpos + `BLOCK_VSIZE) ||
        hcount >= block23_hpos && hcount <= (block23_hpos + `BLOCK_HSIZE) &&
        vcount >= block23_vpos && vcount <= (block23_vpos + `BLOCK_VSIZE) ||
        hcount >= block24_hpos && hcount <= (block24_hpos + `BLOCK_HSIZE) &&
        vcount >= block24_vpos && vcount <= (block24_vpos + `BLOCK_VSIZE) ||
        hcount >= block25_hpos && hcount <= (block25_hpos + `BLOCK_HSIZE) &&
        vcount >= block25_vpos && vcount <= (block25_vpos + `BLOCK_VSIZE) ||
        hcount >= block26_hpos && hcount <= (block26_hpos + `BLOCK_HSIZE) &&
        vcount >= block26_vpos && vcount <= (block26_vpos + `BLOCK_VSIZE) ||
        hcount >= block27_hpos && hcount <= (block27_hpos + `BLOCK_HSIZE) &&
        vcount >= block27_vpos && vcount <= (block27_vpos + `BLOCK_VSIZE) ||
        hcount >= block28_hpos && hcount <= (block28_hpos + `BLOCK_HSIZE) &&
        vcount >= block28_vpos && vcount <= (block28_vpos + `BLOCK_VSIZE)) begin
        rgb <= `ALL_COLOR;
    end 
    else begin
        rgb <= `COLOR_BLACK;                // 일상적인 상황
    end
end

assign VGA_R = rgb[11:8];
assign VGA_G = rgb[ 7:4];
assign VGA_B = rgb[ 3:0];

reg vs_d;
always @(posedge pclk) vs_d <= VGA_VS;          // vsync를 한번 챈다.

// vsync pulse
wire vs_p = VGA_VS & ~vs_d;

reg left_btn_d1, left_btn_d2;
reg right_btn_d1, right_btn_d2;
reg left_btn_pressed;
reg right_btn_pressed;

always@(posedge pclk, posedge reset) begin
        right_btn_d1 <= BTNR;
    right_btn_d2 <= right_btn_d1;
    right_btn_pressed = right_btn_d1 & ~right_btn_d2;

    left_btn_d1 <= BTNL;
    left_btn_d2 <= left_btn_d1;
    left_btn_pressed = left_btn_d1 & ~left_btn_d2;
end

reg     [5:0]   block_counter;      //6비트
reg             ssd_state;
always@(posedge sys_clk, posedge reset) begin
    if(reset)
        ssd_state <= 0;
    else
        ssd_state <= ssd_state + 1;
end

assign  AN[0]   =   ~(ssd_state == 0);
assign  AN[1]   =   ~(ssd_state == 1);
assign  AN[7:2] =   6'b 111111;

wire    [3:0]   ssd0 = block_counter[3:0];
wire    [3:0]   ssd1 = block_counter[5:4];
reg     [3:0]   ssd;
always @(ssd_state, ssd0, ssd1)
begin
    case (ssd_state)
        0 : ssd = ssd0;
        1 : ssd = ssd1;
    endcase
end

assign {CA, CB, CC, CD, CE, CF, CG } = hex2ssd(ssd);


reg [15:0] walking_leds;
always @ (game_over) begin
    case (game_over)
        0: walking_leds = 16'b 0000_0000_0000_0000;
        1: walking_leds = 16'b 1111_1111_1111_1111;
        default : walking_leds = 0;
    endcase
end

assign LED[15:0] = (game_over) ? {16{clk_1Hz}} : 0;

always @(posedge pclk or posedge reset) begin
    if (reset) begin
        ball_hpos <= `BALL_HPOS_INIT;
        ball_vpos <= `BALL_VPOS_INIT;
        ball_h_dir <= `LEFT;
        ball_v_dir <= `DOWN;
        
        bar_hpos <= `BAR_HPOS_INIT;
        bar_vpos <= `BAR_VPOS_INIT;
        
        block1_hpos <= `BLOCK1_HPOS_INIT;
        block1_vpos <= `BLOCK1_VPOS_INIT;
        block2_hpos <= `BLOCK2_HPOS_INIT;
        block2_vpos <= `BLOCK2_VPOS_INIT;
        block3_hpos <= `BLOCK3_HPOS_INIT;
        block3_vpos <= `BLOCK3_VPOS_INIT;
        block4_hpos <= `BLOCK4_HPOS_INIT;
        block4_vpos <= `BLOCK4_VPOS_INIT;
        block5_hpos <= `BLOCK5_HPOS_INIT;
        block5_vpos <= `BLOCK5_VPOS_INIT;
        block6_hpos <= `BLOCK6_HPOS_INIT;
        block6_vpos <= `BLOCK6_VPOS_INIT;
        block7_hpos <= `BLOCK7_HPOS_INIT;
        block7_vpos <= `BLOCK7_VPOS_INIT;
        block8_hpos <= `BLOCK8_HPOS_INIT;
        block8_vpos <= `BLOCK8_VPOS_INIT;
        block9_hpos <= `BLOCK9_HPOS_INIT;
        block9_vpos <= `BLOCK9_VPOS_INIT;
        block10_hpos <= `BLOCK10_HPOS_INIT;
        block10_vpos <= `BLOCK10_VPOS_INIT;
        
        block11_hpos <= `BLOCK11_HPOS_INIT;
        block11_vpos <= `BLOCK11_VPOS_INIT;
        block12_hpos <= `BLOCK12_HPOS_INIT;
        block12_vpos <= `BLOCK12_VPOS_INIT;
        block13_hpos <= `BLOCK13_HPOS_INIT;
        block13_vpos <= `BLOCK13_VPOS_INIT;
        block14_hpos <= `BLOCK14_HPOS_INIT;
        block14_vpos <= `BLOCK14_VPOS_INIT;
        block15_hpos <= `BLOCK15_HPOS_INIT;
        block15_vpos <= `BLOCK15_VPOS_INIT;
        block16_hpos <= `BLOCK16_HPOS_INIT;
        block16_vpos <= `BLOCK16_VPOS_INIT;
        block17_hpos <= `BLOCK17_HPOS_INIT;
        block17_vpos <= `BLOCK17_VPOS_INIT;
        block18_hpos <= `BLOCK18_HPOS_INIT;
        block18_vpos <= `BLOCK18_VPOS_INIT;
        block19_hpos <= `BLOCK19_HPOS_INIT;
        block19_vpos <= `BLOCK19_VPOS_INIT;
        block20_hpos <= `BLOCK20_HPOS_INIT;
        block20_vpos <= `BLOCK20_VPOS_INIT;
        
        block21_hpos <= `BLOCK21_HPOS_INIT;
        block21_vpos <= `BLOCK21_VPOS_INIT;
        block22_hpos <= `BLOCK22_HPOS_INIT;
        block22_vpos <= `BLOCK22_VPOS_INIT;
        block23_hpos <= `BLOCK23_HPOS_INIT;
        block23_vpos <= `BLOCK23_VPOS_INIT;
        block24_hpos <= `BLOCK24_HPOS_INIT;
        block24_vpos <= `BLOCK24_VPOS_INIT;
        block25_hpos <= `BLOCK25_HPOS_INIT;
        block25_vpos <= `BLOCK25_VPOS_INIT;
        block26_hpos <= `BLOCK26_HPOS_INIT;
        block26_vpos <= `BLOCK26_VPOS_INIT;
        block27_hpos <= `BLOCK27_HPOS_INIT;
        block27_vpos <= `BLOCK27_VPOS_INIT;
        block28_hpos <= `BLOCK28_HPOS_INIT;
        block28_vpos <= `BLOCK28_VPOS_INIT;
        
        block_counter <= 6'd0;
        game_over <= 0;
           
    end
    
    else if (vs_p) begin
        
//        right_btn_d1 <= BTNR;
//        right_btn_d2 <= right_btn_d1;
//        right_btn_pressed = right_btn_d1 & ~right_btn_d2;
        
//        left_btn_d1 <= BTNL;
//        left_btn_d2 <= left_btn_d1;
//        left_btn_pressed = left_btn_d1 & ~left_btn_d2;
        
        if((ball_hpos == `BALL_HPOS_INIT) && (ball_vpos == `BALL_VPOS_INIT)) begin
            if(right_btn_pressed) begin
                if((bar_hpos >= 10'd90))
                    bar_hpos <= 10'd90;
                else
                    bar_hpos <= bar_hpos + `LEVEL_GAP;

            end
            else if (left_btn_pressed) begin
                if((bar_hpos == 10'd0))
                    bar_hpos <= 10'd0;                   
                else 
                    bar_hpos <= bar_hpos - `LEVEL_GAP;
            end
        end
        
        if (ball_h_dir == `LEFT) begin
        
            // bar에 부딛힐 경우
            if ((ball_vpos < (bar_vpos + `BAR_VSIZE + 10'd2)) && (ball_vpos >= bar_vpos - 10'd2) && (ball_hpos == (bar_hpos + `BAR_HSIZE)))
                ball_h_dir <= `RIGHT;

            else begin      //왼쪽일 경우
                
            if((ball_vpos < (block1_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= block1_vpos) && (ball_hpos == block1_hpos + `BLOCK_HSIZE)) begin
                ball_h_dir <= `RIGHT;
                block1_vpos <= `BLOCK_BREAK;
                block1_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                    block_counter[5:4] <= block_counter[5:4] + 1;
                    block_counter[3:0] <= 0;
                end
                else
                    block_counter <= block_counter+ 1;
            end
            if ((ball_vpos < (block2_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= block2_vpos) && (ball_hpos == block2_hpos + `BLOCK_HSIZE)) begin
                ball_h_dir <= `RIGHT;
                block2_vpos <= `BLOCK_BREAK;
                block2_hpos <= `BLOCK_BREAK;
                 if(block_counter[3:0] >= 4'b1001)begin
                    block_counter[5:4] <= block_counter[5:4] + 1;
                    block_counter[3:0] <= 0;
                end
                else
                    block_counter <= block_counter+ 1;
            end
            if ((ball_vpos < (block3_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= block3_vpos) && (ball_hpos == block3_hpos + `BLOCK_HSIZE)) begin
                ball_h_dir <= `RIGHT;
                block3_vpos <= `BLOCK_BREAK;
                block3_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                    block_counter[5:4] <= block_counter[5:4] + 1;
                    block_counter[3:0] <= 0;
                end
                else
                    block_counter <= block_counter+ 1;
            end
            if ((ball_vpos < (block4_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= block4_vpos) && (ball_hpos == block4_hpos + `BLOCK_HSIZE)) begin
                ball_h_dir <= `RIGHT;
                block4_vpos <= `BLOCK_BREAK;
                block4_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                    block_counter[5:4] <= block_counter[5:4] + 1;
                    block_counter[3:0] <= 0;
                end
                else
                    block_counter <= block_counter+ 1;
            end
            if ((ball_vpos < (block5_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= block5_vpos) && (ball_hpos == block5_hpos + `BLOCK_HSIZE)) begin
                ball_h_dir <= `RIGHT;
                block5_vpos <= `BLOCK_BREAK;
                block5_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                    block_counter[5:4] <= block_counter[5:4] + 1;
                    block_counter[3:0] <= 0;
                end
                else
                    block_counter <= block_counter+ 1;
            end
            if ((ball_vpos < (block6_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= block6_vpos) && (ball_hpos == block6_hpos + `BLOCK_HSIZE)) begin
                ball_h_dir <= `RIGHT;
                block6_vpos <= `BLOCK_BREAK;
                block6_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                    block_counter[5:4] <= block_counter[5:4] + 1;
                    block_counter[3:0] <= 0;
                end
                else
                    block_counter <= block_counter+ 1;
            end
            if ((ball_vpos < (block7_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= block7_vpos) && (ball_hpos == block7_hpos + `BLOCK_HSIZE)) begin
                ball_h_dir <= `RIGHT;
                block7_vpos <= `BLOCK_BREAK;
                block7_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                    block_counter[5:4] <= block_counter[5:4] + 1;
                    block_counter[3:0] <= 0;
                end
                else
                    block_counter <= block_counter+ 1;
            end
            if ((ball_vpos < (block8_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= block8_vpos) && (ball_hpos == block8_hpos + `BLOCK_HSIZE)) begin
                ball_h_dir <= `RIGHT;
                block8_vpos <= `BLOCK_BREAK;
                block8_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                    block_counter[5:4] <= block_counter[5:4] + 1;
                    block_counter[3:0] <= 0;
                end
                else
                    block_counter <= block_counter+ 1;
            end
            if ((ball_vpos < (block9_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= block9_vpos) && (ball_hpos == block9_hpos + `BLOCK_HSIZE)) begin
                ball_h_dir <= `RIGHT;
                block9_vpos <= `BLOCK_BREAK;
                block9_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                    block_counter[5:4] <= block_counter[5:4] + 1;
                    block_counter[3:0] <= 0;
                end
                else
                    block_counter <= block_counter+ 1;
            end
            if ((ball_vpos < (block10_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= block10_vpos) && (ball_hpos == block10_hpos + `BLOCK_HSIZE)) begin
                ball_h_dir <= `RIGHT;
                block10_vpos <= `BLOCK_BREAK;
                block10_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                    block_counter[5:4] <= block_counter[5:4] + 1;
                    block_counter[3:0] <= 0;
                end
                else
                    block_counter <= block_counter+ 1;
            end
            
            if ((ball_vpos < (block11_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= block11_vpos) && (ball_hpos == block11_hpos + `BLOCK_HSIZE)) begin
                ball_h_dir <= `RIGHT;
                block11_vpos <= `BLOCK_BREAK;
                block11_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                    block_counter[5:4] <= block_counter[5:4] + 1;
                    block_counter[3:0] <= 0;
                end
                else
                    block_counter <= block_counter+ 1;
            end
            if ((ball_vpos < (block12_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= block12_vpos) && (ball_hpos == block12_hpos + `BLOCK_HSIZE)) begin
                ball_h_dir <= `RIGHT;
                block12_vpos <= `BLOCK_BREAK;
                block12_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                    block_counter[5:4] <= block_counter[5:4] + 1;
                    block_counter[3:0] <= 0;
                end
                else
                    block_counter <= block_counter+ 1;
            end
            if ((ball_vpos < (block13_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= block13_vpos) && (ball_hpos == block13_hpos + `BLOCK_HSIZE)) begin
                ball_h_dir <= `RIGHT;
                block13_vpos <= `BLOCK_BREAK;
                block13_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                    block_counter[5:4] <= block_counter[5:4] + 1;
                    block_counter[3:0] <= 0;
                end
                else
                    block_counter <= block_counter+ 1;
            end
            if ((ball_vpos < (block14_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= block14_vpos) && (ball_hpos == block14_hpos + `BLOCK_HSIZE)) begin
                ball_h_dir <= `RIGHT;
                block14_vpos <= `BLOCK_BREAK;
                block14_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                    block_counter[5:4] <= block_counter[5:4] + 1;
                    block_counter[3:0] <= 0;
                end
                else
                    block_counter <= block_counter+ 1;
            end
            if ((ball_vpos < (block15_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= block15_vpos) && (ball_hpos == block15_hpos + `BLOCK_HSIZE)) begin
                ball_h_dir <= `RIGHT;
                block15_vpos <= `BLOCK_BREAK;
                block15_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                    block_counter[5:4] <= block_counter[5:4] + 1;
                    block_counter[3:0] <= 0;
                end
                else
                    block_counter <= block_counter+ 1;
            end
            if ((ball_vpos < (block16_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= block16_vpos) && (ball_hpos == block16_hpos + `BLOCK_HSIZE)) begin
                ball_h_dir <= `RIGHT;
                block16_vpos <= `BLOCK_BREAK;
                block16_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                    block_counter[5:4] <= block_counter[5:4] + 1;
                    block_counter[3:0] <= 0;
                end
                else
                    block_counter <= block_counter+ 1;
            end
            if ((ball_vpos < (block17_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= block17_vpos) && (ball_hpos == block17_hpos + `BLOCK_HSIZE)) begin
                ball_h_dir <= `RIGHT;
                block17_vpos <= `BLOCK_BREAK;
                block17_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                    block_counter[5:4] <= block_counter[5:4] + 1;
                    block_counter[3:0] <= 0;
                end
                else
                    block_counter <= block_counter+ 1;
            end            
            if ((ball_vpos < (block18_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= block18_vpos) && (ball_hpos == block18_hpos + `BLOCK_HSIZE)) begin
                ball_h_dir <= `RIGHT;
                block18_vpos <= `BLOCK_BREAK;
                block18_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                    block_counter[5:4] <= block_counter[5:4] + 1;
                    block_counter[3:0] <= 0;
                end
                else
                    block_counter <= block_counter+ 1;
            end            
            if ((ball_vpos < (block19_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= block19_vpos) && (ball_hpos == block19_hpos + `BLOCK_HSIZE)) begin
                ball_h_dir <= `RIGHT;
                block19_vpos <= `BLOCK_BREAK;
                block19_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                    block_counter[5:4] <= block_counter[5:4] + 1;
                    block_counter[3:0] <= 0;
                end
                else
                    block_counter <= block_counter+ 1;
            end            
            if ((ball_vpos < (block20_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= block20_vpos) && (ball_hpos == block20_hpos + `BLOCK_HSIZE)) begin
                ball_h_dir <= `RIGHT;
                block20_vpos <= `BLOCK_BREAK;
                block20_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                    block_counter[5:4] <= block_counter[5:4] + 1;
                    block_counter[3:0] <= 0;
                end
                else
                    block_counter <= block_counter+ 1;
            end            
            if ((ball_vpos < (block21_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= block21_vpos) && (ball_hpos == block21_hpos + `BLOCK_HSIZE)) begin
                ball_h_dir <= `RIGHT;
                block21_vpos <= `BLOCK_BREAK;
                block21_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                    block_counter[5:4] <= block_counter[5:4] + 1;
                    block_counter[3:0] <= 0;
                end
                else
                    block_counter <= block_counter+ 1;
            end            
            if ((ball_vpos < (block22_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= block22_vpos) && (ball_hpos == block22_hpos + `BLOCK_HSIZE)) begin
                ball_h_dir <= `RIGHT;
                block22_vpos <= `BLOCK_BREAK;
                block22_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                    block_counter[5:4] <= block_counter[5:4] + 1;
                    block_counter[3:0] <= 0;
                end
                else
                    block_counter <= block_counter+ 1;
            end
            if ((ball_vpos < (block23_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= block23_vpos) && (ball_hpos == block23_hpos + `BLOCK_HSIZE)) begin
                ball_h_dir <= `RIGHT;
                block23_vpos <= `BLOCK_BREAK;
                block23_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                    block_counter[5:4] <= block_counter[5:4] + 1;
                    block_counter[3:0] <= 0;
                end
                else
                    block_counter <= block_counter+ 1;
            end
            if ((ball_vpos < (block24_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= block24_vpos) && (ball_hpos == block24_hpos + `BLOCK_HSIZE)) begin
                ball_h_dir <= `RIGHT;
                block24_vpos <= `BLOCK_BREAK;
                block24_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                    block_counter[5:4] <= block_counter[5:4] + 1;
                    block_counter[3:0] <= 0;
                end
                else
                    block_counter <= block_counter+ 1;
            end
            if ((ball_vpos < (block25_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= block25_vpos) && (ball_hpos == block25_hpos + `BLOCK_HSIZE)) begin
                ball_h_dir <= `RIGHT;
                block25_vpos <= `BLOCK_BREAK;
                block25_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                    block_counter[5:4] <= block_counter[5:4] + 1;
                    block_counter[3:0] <= 0;
                end
                else
                    block_counter <= block_counter+ 1;
            end
            if ((ball_vpos < (block26_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= block26_vpos) && (ball_hpos == block26_hpos + `BLOCK_HSIZE)) begin
                ball_h_dir <= `RIGHT;
                block26_vpos <= `BLOCK_BREAK;
                block26_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                    block_counter[5:4] <= block_counter[5:4] + 1;
                    block_counter[3:0] <= 0;
                end
                else
                    block_counter <= block_counter+ 1;
            end
            if ((ball_vpos < (block27_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= block27_vpos) && (ball_hpos == block27_hpos + `BLOCK_HSIZE)) begin
                ball_h_dir <= `RIGHT;
                block27_vpos <= `BLOCK_BREAK;
                block27_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                    block_counter[5:4] <= block_counter[5:4] + 1;
                    block_counter[3:0] <= 0;
                end
                else
                    block_counter <= block_counter+ 1;
            end
            if ((ball_vpos < (block28_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= block28_vpos) && (ball_hpos == block28_hpos + `BLOCK_HSIZE)) begin
                ball_h_dir <= `RIGHT;
                block28_vpos <= `BLOCK_BREAK;
                block28_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                    block_counter[5:4] <= block_counter[5:4] + 1;
                    block_counter[3:0] <= 0;
                end
                else
                    block_counter <= block_counter+ 1;
            end
            
                else begin
                    if(ball_hpos < ball_xspd)begin
//                        ball_h_dir <= `RIGHT;
                        ball_vpos <= `BLOCK_BREAK;
                        ball_hpos <= `BLOCK_BREAK;
                        game_over <= 1;
                        end
                    else
                        ball_hpos <= ball_hpos - ball_xspd;
                end
            end
        end     //left일때 begin의 end
        
        //수평이동일때
        else begin  //공의 진행방향이 오른쪽 일경우
        
            if((ball_vpos < (block1_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= (block1_vpos - 10'd2)) && ((ball_hpos + `BALL_HSIZE) == block1_hpos)) begin
                ball_h_dir <= `LEFT;
                block1_vpos <= `BLOCK_BREAK;
                block1_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                    block_counter[5:4] <= block_counter[5:4] + 1;
                    block_counter[3:0] <= 0;
                end
                else
                    block_counter <= block_counter+ 1;
            end
            if ((ball_vpos < (block2_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= (block2_vpos - 10'd2)) && ((ball_hpos + `BALL_HSIZE) == block2_hpos)) begin
                ball_h_dir <= `LEFT;
                block2_vpos <= `BLOCK_BREAK;
                block2_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                    block_counter[5:4] <= block_counter[5:4] + 1;
                    block_counter[3:0] <= 0;
                end
                else
                    block_counter <= block_counter+ 1;
            end
            if ((ball_vpos < (block3_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= (block3_vpos - 10'd2)) && ((ball_hpos + `BALL_HSIZE) == block3_hpos)) begin
                ball_h_dir <= `LEFT;
                block3_vpos <= `BLOCK_BREAK;
                block3_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                    block_counter[5:4] <= block_counter[5:4] + 1;
                    block_counter[3:0] <= 0;
                end
                else
                    block_counter <= block_counter+ 1;
            end
            if ((ball_vpos < (block4_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= (block4_vpos - 10'd10)) && ((ball_hpos + `BALL_HSIZE) == block4_hpos)) begin
                ball_h_dir <= `LEFT;
                block4_vpos <= `BLOCK_BREAK;
                block4_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                    block_counter[5:4] <= block_counter[5:4] + 1;
                    block_counter[3:0] <= 0;
                end
                else
                    block_counter <= block_counter+ 1;
            end
            if ((ball_vpos < (block5_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= (block5_vpos - 10'd2)) && ((ball_hpos + `BALL_HSIZE) == block5_hpos)) begin
                ball_h_dir <= `LEFT;
                block5_vpos <= `BLOCK_BREAK;
                block5_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                    block_counter[5:4] <= block_counter[5:4] + 1;
                    block_counter[3:0] <= 0;
                    end
                    else
                        block_counter <= block_counter+ 1;
            end
            if ((ball_vpos < (block6_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= (block6_vpos - 10'd2)) && ((ball_hpos + `BALL_HSIZE) == block6_hpos)) begin
                        ball_h_dir <= `LEFT;
                        block6_vpos <= `BLOCK_BREAK;
                        block6_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                            block_counter[5:4] <= block_counter[5:4] + 1;
                            block_counter[3:0] <= 0;
                        end
                        else
                            block_counter <= block_counter+ 1;
                    end
            if ((ball_vpos < (block7_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= (block7_vpos - 10'd8)) && ((ball_hpos + `BALL_HSIZE) == block7_hpos)) begin
                        ball_h_dir <= `LEFT;
                        block7_vpos <= `BLOCK_BREAK;
                        block7_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                            block_counter[5:4] <= block_counter[5:4] + 1;
                            block_counter[3:0] <= 0;
                        end
                        else
                            block_counter <= block_counter+ 1;
                    end
            if ((ball_vpos < (block8_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= (block8_vpos - 10'd2)) && ((ball_hpos + `BALL_HSIZE) == block8_hpos)) begin
                        ball_h_dir <= `LEFT;
                        block8_vpos <= `BLOCK_BREAK;
                        block8_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                            block_counter[5:4] <= block_counter[5:4] + 1;
                            block_counter[3:0] <= 0;
                        end
                        else
                            block_counter <= block_counter+ 1;
                    end
            if ((ball_vpos < (block9_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= (block9_vpos - 10'd2)) && ((ball_hpos + `BALL_HSIZE) == block9_hpos)) begin
                        ball_h_dir <= `LEFT;
                        block9_vpos <= `BLOCK_BREAK;
                        block9_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                            block_counter[5:4] <= block_counter[5:4] + 1;
                            block_counter[3:0] <= 0;
                        end
                        else
                            block_counter <= block_counter+ 1;
                    end
            if ((ball_vpos < (block10_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= (block10_vpos - 10'd2)) && ((ball_hpos + `BALL_HSIZE) == block10_hpos)) begin
                        ball_h_dir <= `LEFT;
                        block10_vpos <= `BLOCK_BREAK;
                        block10_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                            block_counter[5:4] <= block_counter[5:4] + 1;
                            block_counter[3:0] <= 0;
                        end
                        else
                            block_counter <= block_counter+ 1;
                    end
                    
            if ((ball_vpos < (block11_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= (block11_vpos - 10'd2)) && ((ball_hpos + `BALL_HSIZE) == block11_hpos)) begin
                        ball_h_dir <= `LEFT;
                        block11_vpos <= `BLOCK_BREAK;
                        block11_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                            block_counter[5:4] <= block_counter[5:4] + 1;
                            block_counter[3:0] <= 0;
                        end
                        else
                            block_counter <= block_counter+ 1;
                    end
            if ((ball_vpos < (block12_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= (block12_vpos - 10'd2)) && ((ball_hpos + `BALL_HSIZE) == block12_hpos)) begin
                        ball_h_dir <= `LEFT;
                        block12_vpos <= `BLOCK_BREAK;
                        block12_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                            block_counter[5:4] <= block_counter[5:4] + 1;
                            block_counter[3:0] <= 0;
                        end
                        else
                            block_counter <= block_counter+ 1;
                    end
            if ((ball_vpos < (block13_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= (block13_vpos - 10'd2)) && ((ball_hpos + `BALL_HSIZE) == block13_hpos)) begin
                        ball_h_dir <= `LEFT;
                        block13_vpos <= `BLOCK_BREAK;
                        block13_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                            block_counter[5:4] <= block_counter[5:4] + 1;
                            block_counter[3:0] <= 0;
                        end
                        else
                            block_counter <= block_counter+ 1;
                    end
            if ((ball_vpos < (block14_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= (block14_vpos - 10'd2)) && ((ball_hpos + `BALL_HSIZE) == block14_hpos)) begin
                        ball_h_dir <= `LEFT;
                        block14_vpos <= `BLOCK_BREAK;
                        block14_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                            block_counter[5:4] <= block_counter[5:4] + 1;
                            block_counter[3:0] <= 0;
                        end
                        else
                            block_counter <= block_counter+ 1;
                    end
            if ((ball_vpos < (block15_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= (block15_vpos - 10'd2)) && ((ball_hpos + `BALL_HSIZE) == block15_hpos)) begin
                        ball_h_dir <= `LEFT;
                        block15_vpos <= `BLOCK_BREAK;
                        block15_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                            block_counter[5:4] <= block_counter[5:4] + 1;
                            block_counter[3:0] <= 0;
                        end
                        else
                            block_counter <= block_counter+ 1;
                    end
            if ((ball_vpos < (block16_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= (block16_vpos - 10'd2)) && ((ball_hpos + `BALL_HSIZE) == block16_hpos)) begin
                        ball_h_dir <= `LEFT;
                        block16_vpos <= `BLOCK_BREAK;
                        block16_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                            block_counter[5:4] <= block_counter[5:4] + 1;
                            block_counter[3:0] <= 0;
                        end
                        else
                            block_counter <= block_counter+ 1;
                    end
            if ((ball_vpos < (block17_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= (block17_vpos - 10'd2)) && ((ball_hpos + `BALL_HSIZE) == block17_hpos)) begin
                        ball_h_dir <= `LEFT;
                        block17_vpos <= `BLOCK_BREAK;
                        block17_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                            block_counter[5:4] <= block_counter[5:4] + 1;
                            block_counter[3:0] <= 0;
                        end
                        else
                            block_counter <= block_counter+ 1;
                    end
            if ((ball_vpos < (block18_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= (block18_vpos - 10'd2)) && ((ball_hpos + `BALL_HSIZE) == block18_hpos)) begin
                        ball_h_dir <= `LEFT;
                        block18_vpos <= `BLOCK_BREAK;
                        block18_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                            block_counter[5:4] <= block_counter[5:4] + 1;
                            block_counter[3:0] <= 0;
                        end
                        else
                            block_counter <= block_counter+ 1;
                    end
            if ((ball_vpos < (block19_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= (block19_vpos - 10'd2)) && ((ball_hpos + `BALL_HSIZE) == block19_hpos)) begin
                        ball_h_dir <= `LEFT;
                        block19_vpos <= `BLOCK_BREAK;
                        block19_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                            block_counter[5:4] <= block_counter[5:4] + 1;
                            block_counter[3:0] <= 0;
                        end
                        else
                            block_counter <= block_counter+ 1;
                    end
            if ((ball_vpos < (block20_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= (block20_vpos - 10'd2)) && ((ball_hpos + `BALL_HSIZE) == block20_hpos)) begin
                        ball_h_dir <= `LEFT;
                        block20_vpos <= `BLOCK_BREAK;
                        block20_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                            block_counter[5:4] <= block_counter[5:4] + 1;
                            block_counter[3:0] <= 0;
                        end
                        else
                            block_counter <= block_counter+ 1;
                    end
                    
            if ((ball_vpos < (block21_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= (block21_vpos - 10'd2)) && ((ball_hpos + `BALL_HSIZE) == block21_hpos)) begin
                        ball_h_dir <= `LEFT;
                        block21_vpos <= `BLOCK_BREAK;
                        block21_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                            block_counter[5:4] <= block_counter[5:4] + 1;
                            block_counter[3:0] <= 0;
                        end
                        else
                            block_counter <= block_counter+ 1;
                    end
            if ((ball_vpos < (block22_vpos + `BLOCK_VSIZE + 10'd3)) && (ball_vpos >= (block22_vpos - 10'd2)) && ((ball_hpos + `BALL_HSIZE) == block22_hpos)) begin
                        ball_h_dir <= `LEFT;
                        block22_vpos <= `BLOCK_BREAK;
                        block22_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                            block_counter[5:4] <= block_counter[5:4] + 1;
                            block_counter[3:0] <= 0;
                        end
                        else
                            block_counter <= block_counter+ 1;
                    end
            if ((ball_vpos < (block23_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= (block23_vpos - 10'd2)) && ((ball_hpos + `BALL_HSIZE) == block23_hpos)) begin
                        ball_h_dir <= `LEFT;
                        block23_vpos <= `BLOCK_BREAK;
                        block23_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                            block_counter[5:4] <= block_counter[5:4] + 1;
                            block_counter[3:0] <= 0;
                        end
                        else
                            block_counter <= block_counter+ 1;
                    end
            if ((ball_vpos < (block24_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= (block24_vpos - 10'd2)) && ((ball_hpos + `BALL_HSIZE) == block24_hpos)) begin
                        ball_h_dir <= `LEFT;
                        block24_vpos <= `BLOCK_BREAK;
                        block24_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                            block_counter[5:4] <= block_counter[5:4] + 1;
                            block_counter[3:0] <= 0;
                        end
                        else
                            block_counter <= block_counter+ 1;
                    end
            if ((ball_vpos < (block25_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= (block25_vpos - 10'd2)) && ((ball_hpos + `BALL_HSIZE) == block25_hpos)) begin
                        ball_h_dir <= `LEFT;
                        block25_vpos <= `BLOCK_BREAK;
                        block25_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                            block_counter[5:4] <= block_counter[5:4] + 1;
                            block_counter[3:0] <= 0;
                        end
                        else
                            block_counter <= block_counter+ 1;
                    end
            if ((ball_vpos < (block26_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= (block26_vpos - 10'd2)) && ((ball_hpos + `BALL_HSIZE) == block26_hpos)) begin
                        ball_h_dir <= `LEFT;
                        block26_vpos <= `BLOCK_BREAK;
                        block26_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                            block_counter[5:4] <= block_counter[5:4] + 1;
                            block_counter[3:0] <= 0;
                        end
                        else
                            block_counter <= block_counter+ 1;
                    end
            if ((ball_vpos < (block27_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= (block27_vpos - 10'd2)) && ((ball_hpos + `BALL_HSIZE) == block27_hpos)) begin
                        ball_h_dir <= `LEFT;
                        block27_vpos <= `BLOCK_BREAK;
                        block27_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                            block_counter[5:4] <= block_counter[5:4] + 1;
                            block_counter[3:0] <= 0;
                        end
                        else
                            block_counter <= block_counter+ 1;
                    end
            if ((ball_vpos < (block28_vpos + `BLOCK_VSIZE + 10'd2)) && (ball_vpos >= (block28_vpos - 10'd2)) && ((ball_hpos + `BALL_HSIZE) == block28_hpos)) begin
                        ball_h_dir <= `LEFT;
                        block28_vpos <= `BLOCK_BREAK;
                        block28_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                            block_counter[5:4] <= block_counter[5:4] + 1;
                            block_counter[3:0] <= 0;
                        end
                        else
                            block_counter <= block_counter+ 1;
                    end
            
            if((ball_hpos + `BALL_HSIZE + ball_xspd) >= `HPIXELS)
                ball_h_dir <= `LEFT;
            else
                ball_hpos <= ball_hpos + ball_xspd;
        end
         
        //상하
        if(ball_v_dir == `DOWN) begin
                       
                   if((ball_hpos >= block1_hpos) && (ball_hpos < block1_hpos+`BLOCK_HSIZE + 10'd1) && ((ball_vpos+`BALL_VSIZE) == block1_vpos)) begin
                       ball_v_dir <= `UP;
                       block1_vpos <= `BLOCK_BREAK;
                       block1_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                           block_counter[5:4] <= block_counter[5:4] + 1;
                           block_counter[3:0] <= 0;
                       end
                       else
                           block_counter <= block_counter+ 1;
                   end
                   if((ball_hpos >= block2_hpos) && (ball_hpos < block2_hpos+`BLOCK_HSIZE + 10'd1) && ((ball_vpos+`BALL_VSIZE) == block2_vpos)) begin
                       ball_v_dir <= `UP;
                       block2_vpos <= `BLOCK_BREAK;
                       block2_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                           block_counter[5:4] <= block_counter[5:4] + 1;
                           block_counter[3:0] <= 0;
                       end
                       else
                           block_counter <= block_counter+ 1;
                   end
                   if((ball_hpos >= block3_hpos) && (ball_hpos < block3_hpos+`BLOCK_HSIZE + 10'd1) && ((ball_vpos+`BALL_VSIZE) == block3_vpos)) begin
                       ball_v_dir <= `UP;
                       block3_vpos <= `BLOCK_BREAK;
                       block3_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                           block_counter[5:4] <= block_counter[5:4] + 1;
                           block_counter[3:0] <= 0;
                       end
                       else
                           block_counter <= block_counter+ 1;
                   end
                   if((ball_hpos >= block4_hpos) && (ball_hpos < block4_hpos+`BLOCK_HSIZE + 10'd1) && ((ball_vpos+`BALL_VSIZE) == block4_vpos)) begin
                       ball_v_dir <= `UP;
                       block4_vpos <= `BLOCK_BREAK;
                       block4_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                           block_counter[5:4] <= block_counter[5:4] + 1;
                           block_counter[3:0] <= 0;
                       end
                       else
                           block_counter <= block_counter+ 1;
                   end
                   if((ball_hpos >= block5_hpos) && (ball_hpos < block5_hpos+`BLOCK_HSIZE + 10'd1) && ((ball_vpos+`BALL_VSIZE) == block5_vpos)) begin
                       ball_v_dir <= `UP;
                       block5_vpos <= `BLOCK_BREAK;
                       block5_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                           block_counter[5:4] <= block_counter[5:4] + 1;
                           block_counter[3:0] <= 0;
                       end
                       else
                           block_counter <= block_counter+ 1;
                   end
                   if((ball_hpos >= block6_hpos) && (ball_hpos < block6_hpos+`BLOCK_HSIZE + 10'd1) && ((ball_vpos+`BALL_VSIZE) == block6_vpos)) begin
                       ball_v_dir <= `UP;
                       block6_vpos <= `BLOCK_BREAK;
                       block6_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                           block_counter[5:4] <= block_counter[5:4] + 1;
                           block_counter[3:0] <= 0;
                       end
                       else
                           block_counter <= block_counter+ 1;
                   end
                   if((ball_hpos >= block7_hpos) && (ball_hpos < block7_hpos+`BLOCK_HSIZE + 10'd1) && ((ball_vpos+`BALL_VSIZE) == block7_vpos)) begin
                       ball_v_dir <= `UP;
                       block7_vpos <= `BLOCK_BREAK;
                       block7_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                           block_counter[5:4] <= block_counter[5:4] + 1;
                           block_counter[3:0] <= 0;
                       end
                       else
                           block_counter <= block_counter+ 1;
                   end
                   if((ball_hpos >= block8_hpos) && (ball_hpos < block8_hpos+`BLOCK_HSIZE + 10'd1) && ((ball_vpos+`BALL_VSIZE) == block8_vpos)) begin
                       ball_v_dir <= `UP;
                       block8_vpos <= `BLOCK_BREAK;
                       block8_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                           block_counter[5:4] <= block_counter[5:4] + 1;
                           block_counter[3:0] <= 0;
                       end
                       else
                           block_counter <= block_counter+ 1;
                   end
                   if((ball_hpos >= block9_hpos) && (ball_hpos < block9_hpos+`BLOCK_HSIZE + 10'd1) && ((ball_vpos+`BALL_VSIZE) == block9_vpos)) begin
                       ball_v_dir <= `UP;
                       block9_vpos <= `BLOCK_BREAK;
                       block9_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                           block_counter[5:4] <= block_counter[5:4] + 1;
                           block_counter[3:0] <= 0;
                       end
                       else
                           block_counter <= block_counter+ 1;
                   end
                   if((ball_hpos >= (block10_hpos-10'd3)) && (ball_hpos < block10_hpos+`BLOCK_HSIZE + 10'd1) && ((ball_vpos+`BALL_VSIZE) == block10_vpos)) begin
                       ball_v_dir <= `UP;
                       block10_vpos <= `BLOCK_BREAK;
                       block10_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                           block_counter[5:4] <= block_counter[5:4] + 1;
                           block_counter[3:0] <= 0;
                       end
                       else
                           block_counter <= block_counter+ 1;
                   end
                   
                   if((ball_hpos >= block11_hpos) && (ball_hpos < block11_hpos+`BLOCK_HSIZE + 10'd1) && ((ball_vpos+`BALL_VSIZE) == block11_vpos)) begin
                       ball_v_dir <= `UP;
                       block11_vpos <= `BLOCK_BREAK;
                       block11_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                           block_counter[5:4] <= block_counter[5:4] + 1;
                           block_counter[3:0] <= 0;
                       end
                       else
                           block_counter <= block_counter+ 1;
                   end
                   if((ball_hpos >= block12_hpos) && (ball_hpos < block12_hpos+`BLOCK_HSIZE + 10'd1) && ((ball_vpos+`BALL_VSIZE) == block12_vpos)) begin
                       ball_v_dir <= `UP;
                       block12_vpos <= `BLOCK_BREAK;
                       block12_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                           block_counter[5:4] <= block_counter[5:4] + 1;
                           block_counter[3:0] <= 0;
                       end
                       else
                           block_counter <= block_counter+ 1;
                   end
                   if((ball_hpos >= block13_hpos) && (ball_hpos < block13_hpos+`BLOCK_HSIZE + 10'd1) && ((ball_vpos+`BALL_VSIZE) == block13_vpos)) begin
                       ball_v_dir <= `UP;
                       block13_vpos <= `BLOCK_BREAK;
                       block13_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                           block_counter[5:4] <= block_counter[5:4] + 1;
                           block_counter[3:0] <= 0;
                       end
                       else
                           block_counter <= block_counter+ 1;
                   end
                   if((ball_hpos >= block14_hpos) && (ball_hpos < block14_hpos+`BLOCK_HSIZE + 10'd1) && ((ball_vpos+`BALL_VSIZE) == block14_vpos)) begin
                       ball_v_dir <= `UP;
                       block14_vpos <= `BLOCK_BREAK;
                       block14_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                           block_counter[5:4] <= block_counter[5:4] + 1;
                           block_counter[3:0] <= 0;
                       end
                       else
                           block_counter <= block_counter+ 1;
                   end
                   if((ball_hpos >= block15_hpos) && (ball_hpos < block15_hpos+`BLOCK_HSIZE + 10'd1) && ((ball_vpos+`BALL_VSIZE) == block15_vpos)) begin
                       ball_v_dir <= `UP;
                       block15_vpos <= `BLOCK_BREAK;
                       block15_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                           block_counter[5:4] <= block_counter[5:4] + 1;
                           block_counter[3:0] <= 0;
                       end
                       else
                           block_counter <= block_counter+ 1;
                   end
                   if((ball_hpos >= block16_hpos) && (ball_hpos < block16_hpos+`BLOCK_HSIZE + 10'd1) && ((ball_vpos+`BALL_VSIZE) == block16_vpos)) begin
                       ball_v_dir <= `UP;
                       block16_vpos <= `BLOCK_BREAK;
                       block16_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                           block_counter[5:4] <= block_counter[5:4] + 1;
                           block_counter[3:0] <= 0;
                       end
                       else
                           block_counter <= block_counter+ 1;
                   end
                   if((ball_hpos >= block17_hpos) && (ball_hpos < block17_hpos+`BLOCK_HSIZE + 10'd1) && ((ball_vpos+`BALL_VSIZE) == block17_vpos)) begin
                       ball_v_dir <= `UP;
                       block17_vpos <= `BLOCK_BREAK;
                       block17_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                           block_counter[5:4] <= block_counter[5:4] + 1;
                           block_counter[3:0] <= 0;
                       end
                       else
                           block_counter <= block_counter+ 1;
                   end
                   if((ball_hpos >= block18_hpos) && (ball_hpos < block18_hpos+`BLOCK_HSIZE + 10'd1) && ((ball_vpos+`BALL_VSIZE) == block18_vpos)) begin
                       ball_v_dir <= `UP;
                       block18_vpos <= `BLOCK_BREAK;
                       block18_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                           block_counter[5:4] <= block_counter[5:4] + 1;
                           block_counter[3:0] <= 0;
                       end
                       else
                           block_counter <= block_counter+ 1;
                   end
                   if((ball_hpos >= block19_hpos) && (ball_hpos < block19_hpos+`BLOCK_HSIZE + 10'd1) && ((ball_vpos+`BALL_VSIZE) == block19_vpos)) begin
                       ball_v_dir <= `UP;
                       block19_vpos <= `BLOCK_BREAK;
                       block19_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                           block_counter[5:4] <= block_counter[5:4] + 1;
                           block_counter[3:0] <= 0;
                       end
                       else
                           block_counter <= block_counter+ 1;
                   end
                   if((ball_hpos >= block20_hpos) && (ball_hpos < block20_hpos+`BLOCK_HSIZE + 10'd1) && ((ball_vpos+`BALL_VSIZE) == block20_vpos)) begin
                       ball_v_dir <= `UP;
                       block20_vpos <= `BLOCK_BREAK;
                       block20_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                           block_counter[5:4] <= block_counter[5:4] + 1;
                           block_counter[3:0] <= 0;
                       end
                       else
                           block_counter <= block_counter+ 1;
                   end
                   
                   if((ball_hpos >= block21_hpos) && (ball_hpos < block21_hpos+`BLOCK_HSIZE + 10'd1) && ((ball_vpos+`BALL_VSIZE) == block21_vpos)) begin
                       ball_v_dir <= `UP;
                       block21_vpos <= `BLOCK_BREAK;
                       block21_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                           block_counter[5:4] <= block_counter[5:4] + 1;
                           block_counter[3:0] <= 0;
                       end
                       else
                           block_counter <= block_counter+ 1;
                   end
                   if((ball_hpos >= block22_hpos + 10'd2) && (ball_hpos < block22_hpos+`BLOCK_HSIZE + 10'd1) && ((ball_vpos+`BALL_VSIZE) == block22_vpos)) begin
                       ball_v_dir <= `UP;
                       block22_vpos <= `BLOCK_BREAK;
                       block22_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                           block_counter[5:4] <= block_counter[5:4] + 1;
                           block_counter[3:0] <= 0;
                       end
                       else
                           block_counter <= block_counter+ 1;
                   end
                   if((ball_hpos >= block23_hpos) && (ball_hpos < block23_hpos+`BLOCK_HSIZE + 10'd1) && ((ball_vpos+`BALL_VSIZE) == block23_vpos)) begin
                       ball_v_dir <= `UP;
                       block23_vpos <= `BLOCK_BREAK;
                       block23_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                           block_counter[5:4] <= block_counter[5:4] + 1;
                           block_counter[3:0] <= 0;
                       end
                       else
                           block_counter <= block_counter+ 1;
                   end
                   if((ball_hpos >= block24_hpos) && (ball_hpos < block24_hpos+`BLOCK_HSIZE + 10'd1) && ((ball_vpos+`BALL_VSIZE) == block24_vpos)) begin
                       ball_v_dir <= `UP;
                       block24_vpos <= `BLOCK_BREAK;
                       block24_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                           block_counter[5:4] <= block_counter[5:4] + 1;
                           block_counter[3:0] <= 0;
                       end
                       else
                           block_counter <= block_counter+ 1;
                   end
                   if((ball_hpos >= block25_hpos) && (ball_hpos < block25_hpos+`BLOCK_HSIZE + 10'd1) && ((ball_vpos+`BALL_VSIZE) == block25_vpos)) begin
                       ball_h_dir <= `UP;
                       block25_vpos <= `BLOCK_BREAK;
                       block25_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                           block_counter[5:4] <= block_counter[5:4] + 1;
                           block_counter[3:0] <= 0;
                       end
                       else
                           block_counter <= block_counter+ 1;
                   end
                   if((ball_hpos >= block26_hpos) && (ball_hpos < block26_hpos+`BLOCK_HSIZE + 10'd1) && ((ball_vpos+`BALL_VSIZE) == block26_vpos)) begin
                       ball_v_dir <= `UP;
                       block26_vpos <= `BLOCK_BREAK;
                       block26_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                           block_counter[5:4] <= block_counter[5:4] + 1;
                           block_counter[3:0] <= 0;
                       end
                       else
                           block_counter <= block_counter+ 1;
                   end
                   if((ball_hpos >= block27_hpos) && (ball_hpos < block27_hpos+`BLOCK_HSIZE + 10'd1) && ((ball_vpos+`BALL_VSIZE) == block27_vpos)) begin
                       ball_v_dir <= `UP;
                       block27_vpos <= `BLOCK_BREAK;
                       block27_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                           block_counter[5:4] <= block_counter[5:4] + 1;
                           block_counter[3:0] <= 0;
                       end
                       else
                           block_counter <= block_counter+ 1;
                   end
                   if((ball_hpos >= block28_hpos) && (ball_hpos < block28_hpos+`BLOCK_HSIZE + 10'd1) && ((ball_vpos+`BALL_VSIZE) == block28_vpos)) begin
                       ball_v_dir <= `UP;
                       block28_vpos <= `BLOCK_BREAK;
                       block28_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                           block_counter[5:4] <= block_counter[5:4] + 1;
                           block_counter[3:0] <= 0;
                       end
                       else
                           block_counter <= block_counter+ 1;
                   end
        
        
            if((ball_vpos + `BALL_VSIZE + ball_yspd) >= `VLINES) begin
                ball_v_dir <= `UP;
                end
            else
                ball_vpos <= ball_vpos + ball_yspd;
       end
        
        
        else begin      //기존의 공의 방향이 up일때
        
        if((ball_hpos >= block1_hpos) && (ball_hpos < block1_hpos+`BLOCK_HSIZE + 10'd1) && (ball_vpos == (block1_vpos+`BLOCK_VSIZE))) begin
            ball_v_dir <= `DOWN;
            block1_vpos <= `BLOCK_BREAK;
            block1_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                block_counter[5:4] <= block_counter[5:4] + 1;
                block_counter[3:0] <= 0;
            end
            else
                block_counter <= block_counter+ 1;
        end
        if((ball_hpos >= block2_hpos) && (ball_hpos < block2_hpos+`BLOCK_HSIZE + 10'd1) && (ball_vpos == (block2_vpos+`BLOCK_VSIZE))) begin
            ball_v_dir <= `DOWN;
            block2_vpos <= `BLOCK_BREAK;
            block2_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                block_counter[5:4] <= block_counter[5:4] + 1;
                block_counter[3:0] <= 0;
            end
            else
                block_counter <= block_counter+ 1;
        end
        if((ball_hpos >= block3_hpos) && (ball_hpos < block3_hpos+`BLOCK_HSIZE + 10'd1) && (ball_vpos == (block3_vpos+`BLOCK_VSIZE))) begin
            ball_v_dir <= `DOWN;
            block3_vpos <= `BLOCK_BREAK;
            block3_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                block_counter[5:4] <= block_counter[5:4] + 1;
                block_counter[3:0] <= 0;
            end
            else
                block_counter <= block_counter+ 1;
        end
        if((ball_hpos >= block4_hpos) && (ball_hpos < block4_hpos+`BLOCK_HSIZE + 10'd1) && (ball_vpos == (block4_vpos+`BLOCK_VSIZE))) begin
            ball_v_dir <= `DOWN;
            block4_vpos <= `BLOCK_BREAK;
            block4_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                block_counter[5:4] <= block_counter[5:4] + 1;
                block_counter[3:0] <= 0;
            end
            else
                block_counter <= block_counter+ 1;
        end
        if((ball_hpos >= block5_hpos) && (ball_hpos < block5_hpos+`BLOCK_HSIZE + 10'd1) && (ball_vpos == (block5_vpos+`BLOCK_VSIZE))) begin
            ball_v_dir <= `DOWN;
            block5_vpos <= `BLOCK_BREAK;
            block5_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                block_counter[5:4] <= block_counter[5:4] + 1;
                block_counter[3:0] <= 0;
            end
            else
                block_counter <= block_counter+ 1;
        end
        if((ball_hpos >= block6_hpos) && (ball_hpos < block6_hpos+`BLOCK_HSIZE + 10'd1) && (ball_vpos == (block6_vpos+`BLOCK_VSIZE))) begin
            ball_v_dir <= `DOWN;
            block6_vpos <= `BLOCK_BREAK;
            block6_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                block_counter[5:4] <= block_counter[5:4] + 1;
                block_counter[3:0] <= 0;
            end
            else
                block_counter <= block_counter+ 1;
        end
        if((ball_hpos >= block7_hpos) && (ball_hpos < block7_hpos+`BLOCK_HSIZE + 10'd1) && (ball_vpos == (block7_vpos+`BLOCK_VSIZE))) begin
            ball_v_dir <= `DOWN;
            block7_vpos <= `BLOCK_BREAK;
            block7_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                block_counter[5:4] <= block_counter[5:4] + 1;
                block_counter[3:0] <= 0;
            end
            else
                block_counter <= block_counter+ 1;
        end
        if((ball_hpos >= block8_hpos) && (ball_hpos < block8_hpos+`BLOCK_HSIZE + 10'd1) && (ball_vpos == (block8_vpos+`BLOCK_VSIZE))) begin
            ball_v_dir <= `DOWN;
            block8_vpos <= `BLOCK_BREAK;
            block8_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                block_counter[5:4] <= block_counter[5:4] + 1;
                block_counter[3:0] <= 0;
            end
            else
                block_counter <= block_counter+ 1;
        end
        if((ball_hpos >= block9_hpos) && (ball_hpos < block9_hpos+`BLOCK_HSIZE + 10'd1) && (ball_vpos == (block9_vpos+`BLOCK_VSIZE))) begin
            ball_v_dir <= `DOWN;
            block9_vpos <= `BLOCK_BREAK;
            block9_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                block_counter[5:4] <= block_counter[5:4] + 1;
                block_counter[3:0] <= 0;
            end
            else
                block_counter <= block_counter+ 1;
        end
        if((ball_hpos >= block10_hpos) && (ball_hpos < block10_hpos+`BLOCK_HSIZE + 10'd1) && (ball_vpos == (block10_vpos+`BLOCK_VSIZE))) begin
            ball_v_dir <= `DOWN;
            block10_vpos <= `BLOCK_BREAK;
            block10_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                block_counter[5:4] <= block_counter[5:4] + 1;
                block_counter[3:0] <= 0;
            end
            else
                block_counter <= block_counter+ 1;
        end
        
        if((ball_hpos >= block11_hpos) && (ball_hpos < block11_hpos+`BLOCK_HSIZE + 10'd1) && (ball_vpos == (block11_vpos+`BLOCK_VSIZE))) begin
            ball_v_dir <= `DOWN;
            block11_vpos <= `BLOCK_BREAK;
            block11_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                block_counter[5:4] <= block_counter[5:4] + 1;
                block_counter[3:0] <= 0;
            end
            else
                block_counter <= block_counter+ 1;
        end
        if((ball_hpos >= block12_hpos) && (ball_hpos < block12_hpos+`BLOCK_HSIZE + 10'd1) && (ball_vpos == (block12_vpos+`BLOCK_VSIZE))) begin
            ball_v_dir <= `DOWN;
            block12_vpos <= `BLOCK_BREAK;
            block12_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                block_counter[5:4] <= block_counter[5:4] + 1;
                block_counter[3:0] <= 0;
            end
            else
                block_counter <= block_counter+ 1;
        end
        if((ball_hpos >= block13_hpos) && (ball_hpos < block13_hpos+`BLOCK_HSIZE + 10'd1) && (ball_vpos == (block13_vpos+`BLOCK_VSIZE))) begin
            ball_v_dir <= `DOWN;
            block13_vpos <= `BLOCK_BREAK;
            block13_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                block_counter[5:4] <= block_counter[5:4] + 1;
                block_counter[3:0] <= 0;
            end
            else
                block_counter <= block_counter+ 1;
        end
        if((ball_hpos >= block14_hpos) && (ball_hpos < block14_hpos+`BLOCK_HSIZE + 10'd1) && (ball_vpos == (block14_vpos+`BLOCK_VSIZE))) begin
            ball_v_dir <= `DOWN;
            block14_vpos <= `BLOCK_BREAK;
            block14_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                block_counter[5:4] <= block_counter[5:4] + 1;
                block_counter[3:0] <= 0;
            end
            else
                block_counter <= block_counter+ 1;
        end
        if((ball_hpos >= block15_hpos) && (ball_hpos < block15_hpos+`BLOCK_HSIZE + 10'd1) && (ball_vpos == (block15_vpos+`BLOCK_VSIZE))) begin
            ball_v_dir <= `DOWN;
            block15_vpos <= `BLOCK_BREAK;
            block15_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                block_counter[5:4] <= block_counter[5:4] + 1;
                block_counter[3:0] <= 0;
            end
            else
                block_counter <= block_counter+ 1;
        end
        if((ball_hpos >= block16_hpos) && (ball_hpos < block16_hpos+`BLOCK_HSIZE + 10'd1) && (ball_vpos == (block16_vpos+`BLOCK_VSIZE))) begin
            ball_v_dir <= `DOWN;
            block16_vpos <= `BLOCK_BREAK;
            block16_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                block_counter[5:4] <= block_counter[5:4] + 1;
                block_counter[3:0] <= 0;
            end
            else
                block_counter <= block_counter+ 1;
        end
        if((ball_hpos >= block17_hpos) && (ball_hpos < block17_hpos+`BLOCK_HSIZE + 10'd1) && (ball_vpos == (block17_vpos+`BLOCK_VSIZE))) begin
            ball_v_dir <= `DOWN;
            block17_vpos <= `BLOCK_BREAK;
            block17_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                block_counter[5:4] <= block_counter[5:4] + 1;
                block_counter[3:0] <= 0;
            end
            else
                block_counter <= block_counter+ 1;
        end
        if((ball_hpos >= block18_hpos) && (ball_hpos < block18_hpos+`BLOCK_HSIZE + 10'd1) && (ball_vpos == (block18_vpos+`BLOCK_VSIZE))) begin
            ball_v_dir <= `DOWN;
            block18_vpos <= `BLOCK_BREAK;
            block18_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                block_counter[5:4] <= block_counter[5:4] + 1;
                block_counter[3:0] <= 0;
            end
            else
                block_counter <= block_counter+ 1;
        end
        if((ball_hpos >= block19_hpos) && (ball_hpos < block19_hpos+`BLOCK_HSIZE + 10'd1) && (ball_vpos == (block19_vpos+`BLOCK_VSIZE))) begin
            ball_v_dir <= `DOWN;
            block19_vpos <= `BLOCK_BREAK;
            block19_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                block_counter[5:4] <= block_counter[5:4] + 1;
                block_counter[3:0] <= 0;
            end
            else
                block_counter <= block_counter+ 1;
        end
        if((ball_hpos >= block20_hpos) && (ball_hpos < block20_hpos+`BLOCK_HSIZE + 10'd1) && (ball_vpos == (block20_vpos+`BLOCK_VSIZE))) begin
            ball_v_dir <= `DOWN;
            block20_vpos <= `BLOCK_BREAK;
            block20_hpos <= `BLOCK_BREAK;
                 if(block_counter[3:0] >= 4'b1001)begin
                block_counter[5:4] <= block_counter[5:4] + 1;
                block_counter[3:0] <= 0;
            end
            else
                block_counter <= block_counter+ 1;
        end
        
        if((ball_hpos >= block21_hpos) && (ball_hpos < block21_hpos+`BLOCK_HSIZE + 10'd1) && (ball_vpos == (block21_vpos+`BLOCK_VSIZE))) begin
            ball_v_dir <= `DOWN;
            block21_vpos <= `BLOCK_BREAK;
            block21_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                block_counter[5:4] <= block_counter[5:4] + 1;
                block_counter[3:0] <= 0;
            end
            else
                block_counter <= block_counter+ 1;
        end
        if((ball_hpos >= block22_hpos) && (ball_hpos < block22_hpos+`BLOCK_HSIZE + 10'd1) && (ball_vpos == (block22_vpos+`BLOCK_VSIZE))) begin
            ball_v_dir <= `DOWN;
            block22_vpos <= `BLOCK_BREAK;
            block22_hpos <= `BLOCK_BREAK; 
                if(block_counter[3:0] >= 4'b1001)begin
                block_counter[5:4] <= block_counter[5:4] + 1;
                block_counter[3:0] <= 0;
            end
            else
                block_counter <= block_counter+ 1;
        end
        if((ball_hpos >= block23_hpos) && (ball_hpos < block23_hpos+`BLOCK_HSIZE + 10'd1) && (ball_vpos == (block23_vpos+`BLOCK_VSIZE))) begin
            ball_v_dir <= `DOWN;
            block23_vpos <= `BLOCK_BREAK;
            block23_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                block_counter[5:4] <= block_counter[5:4] + 1;
                block_counter[3:0] <= 0;
            end
            else
                block_counter <= block_counter+ 1;
        end
        if((ball_hpos >= block24_hpos) && (ball_hpos < block24_hpos+`BLOCK_HSIZE + 10'd1) && (ball_vpos == (block24_vpos+`BLOCK_VSIZE))) begin
            ball_v_dir <= `DOWN;
            block24_vpos <= `BLOCK_BREAK;
            block24_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                block_counter[5:4] <= block_counter[5:4] + 1;
                block_counter[3:0] <= 0;
            end
            else
                block_counter <= block_counter+ 1;
        end
        if((ball_hpos >= block25_hpos) && (ball_hpos < block25_hpos+`BLOCK_HSIZE + 10'd1) && (ball_vpos == (block25_vpos+`BLOCK_VSIZE))) begin
            ball_v_dir <= `DOWN;
            block25_vpos <= `BLOCK_BREAK;
            block25_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                block_counter[5:4] <= block_counter[5:4] + 1;
                block_counter[3:0] <= 0;
            end
            else
                block_counter <= block_counter+ 1;
        end
        if((ball_hpos >= block26_hpos) && (ball_hpos < block26_hpos+`BLOCK_HSIZE + 10'd1) && (ball_vpos == (block26_vpos+`BLOCK_VSIZE))) begin
            ball_v_dir <= `DOWN;
            block26_vpos <= `BLOCK_BREAK;
            block26_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                block_counter[5:4] <= block_counter[5:4] + 1;
                block_counter[3:0] <= 0;
            end
            else
                block_counter <= block_counter+ 1;
        end
        if((ball_hpos >= block27_hpos) && (ball_hpos < block27_hpos+`BLOCK_HSIZE + 10'd1) && (ball_vpos == (block27_vpos+`BLOCK_VSIZE))) begin
            ball_h_dir <= `DOWN;
            block27_vpos <= `BLOCK_BREAK;
            block27_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                block_counter[5:4] <= block_counter[5:4] + 1;
                block_counter[3:0] <= 0;
            end
            else
                block_counter <= block_counter+ 1;
        end
        if((ball_hpos >= block28_hpos) && (ball_hpos < block28_hpos+`BLOCK_HSIZE + 10'd1) && (ball_vpos == (block28_vpos+`BLOCK_VSIZE))) begin
            ball_v_dir <= `DOWN;
            block28_vpos <= `BLOCK_BREAK;
            block28_hpos <= `BLOCK_BREAK;
                if(block_counter[3:0] >= 4'b1001)begin
                block_counter[5:4] <= block_counter[5:4] + 1;
                block_counter[3:0] <= 0;
            end
            else
                block_counter <= block_counter+ 1;
        end
        
            if(ball_vpos < ball_yspd)
                ball_v_dir <= `DOWN;
            else
                ball_vpos <= ball_vpos - ball_yspd;
        end
        
        //bar 움직이는 부분
        if(BTNU) begin
            if((bar_vpos - `BAR_SPEED) >= `VLINES) 
                bar_vpos <= 10'd7;
            else
            bar_vpos <= bar_vpos - `BAR_SPEED;
        end
        
        if(BTND) begin
            if(bar_vpos >= 11'd420)
                bar_vpos <= 11'd420;
            else
            bar_vpos <= bar_vpos +`BAR_SPEED;
        end
   
    end
end

`include "hex2ssd.v" 

endmodule