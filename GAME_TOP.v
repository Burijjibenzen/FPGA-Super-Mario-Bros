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
    output      XRESET          //硬件复位，低电平有效
    );
    
    //时钟
    wire clk_108, clk_12, locked;
    
    clk_wiz_0 uut_clk(
        .reset(~rst),
        .locked(locked),
        .clk_in1(clk_100),
        .clk_out1(clk_108),
        .clk_out2(clk_12)
    );
    
    VGA uut_vga(
        .clk(clk_108),
        .rst(rst),
        .view(7'd10),
        .O_red(color_r),
        .O_green(color_g),
        .O_blue(color_b),
        .hs(hs),
        .vs(vs)
    );
    
    Divider uut_divider(
        .clk12Mhz(clk_12),
        .clk2Mhz(clk_2)
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
    
endmodule
