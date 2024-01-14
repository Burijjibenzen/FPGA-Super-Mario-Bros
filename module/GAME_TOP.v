`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/30 22:07:29
// Design Name: 
// Module Name: GAME_TOP
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module GAME_TOP(
    input   clk_100,               //100Mhz
    input   rst,                    //复位
    
    //VGA
    output [3:0]    color_r,    //R
    output [3:0]    color_g,    //G
    output [3:0]    color_b,    //B
    output              hs,         //行同步
    output              vs,         //场同步
    
    //MP3
    input       SO,             //传出
    input       DREQ,           //数据请求，高电平时可传输数据
    output      XCS,            //SCI 传输读写指令
    output      XDCS,           //SDI 传输数据
    output      SCK,            //时钟
    output      SI,             //传入mp3
    output      XRESET,         //硬件复位，低电平有效
    
    //键盘
    input   key_clk,                //键盘时钟
    input   key_data,               //键盘输入数据
    
    //七段数码管
    output [7:0] shift,
    output [6:0] oData
    );
    
    wire [10:0] mario_x;
    wire [9:0] mario_y;
    wire [5:0] mario_id;
    wire [32:0] view;
    wire [31:0] score;
    wire hit_left;
    
    //时钟
    wire clk_108, clk_12, clk_10, clk_40, clk_1000, locked;
    
    //键盘输入
    wire [8:0] keys;
    wire key_state;
	wire left;
    wire jump;
    wire right;
    
    assign left = (keys == 65);
    assign right = (keys == 68);
    assign jump = (keys == 87);
    
    clk_wiz_0 uut_clk(
        .reset(~rst),
        .locked(locked),
        .clk_in1(clk_100),
        .clk_out1(clk_108),
        .clk_out2(clk_12)
    );
    
    VGA uut_vga(
        .clk(clk_108),
        .clk_view(clk_10),
        .rst(rst),
        .mario_x(mario_x),
        .mario_y(mario_y),
        .mario_id(mario_id),
        .right(right && !hit_left),
        .O_red(color_r),
        .O_green(color_g),
        .O_blue(color_b),
        .hs(hs),
        .vs(vs),
        .view(view)
    );
    
    Divider uut_divider(
        .clk12Mhz(clk_12),
        .clk2Mhz(clk_2),
        .clk10Hz(clk_10),
        .clk40Hz(clk_40),
        .clk1000Hz(clk_1000)
    );
    
    mp3 uut_mp3(
        .clk(clk_2),
        .rst(rst),
        .play(1'd1),
        .SO(SO),
        .DREQ(DREQ),
        .XCS(XCS),
        .XDCS(XDCS),
        .SCK(SCK),
        .SI(SI),
        .XRESET(XRESET)
    );
    
    World uut_world(
        .clk(clk_40),
        .clk_10(clk_10),
        .rst(rst),
        .jump(jump),
        .left(left),
        .right(right),
        .view(view),
        .mario_x(mario_x),
        .mario_y(mario_y),
        .mario_id(mario_id),
        .score(score),
        .hit_left(hit_left)
    );
    
    Keyboard uut_keyboard(
        .clk_in(clk_100),
        .rst(rst),
        .key_clk(key_clk),
        .key_data(key_data),
        .key_state(key_state),
        .key_ascii(keys)
    );
    
    //数码管显示分数
    Display uut_score(
        .clk_1000hz(clk_1000),
        .score(score),
        .shift(shift),//第几个数码管(片选)
        .oData(oData)
    );
    
endmodule
