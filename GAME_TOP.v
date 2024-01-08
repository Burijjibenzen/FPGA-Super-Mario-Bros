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
    input   rst,                    //��λ
    
    output [3:0]    color_r,    //R
    output [3:0]    color_g,    //G
    output [3:0]    color_b,    //B
    output              hs,         //��ͬ��
    output              vs,         //��ͬ��
    
    //MP3
    input       SO,             //����
    input       DREQ,           //�������󣬸ߵ�ƽʱ�ɴ�������
    output      XCS,            //SCI �����дָ��
    output      XDCS,           //SDI ��������
    output      SCK,            //ʱ��
    output      SI,             //����mp3
    output      XRESET          //Ӳ����λ���͵�ƽ��Ч
    );
    
    //ʱ��
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
