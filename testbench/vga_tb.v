`timescale 10ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/07 14:39:16
// Design Name: 
// Module Name: vga_tb
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


module vga_testbench;
    reg   clk_100;               //100
    reg   rst;               
    wire [3:0]    color_r;    //R
    wire [3:0]    color_g;    //G
    wire [3:0]    color_b;    //B
    wire          hs;         
    wire          vs;        
    reg jump;
    reg left;
    reg right;

    wire clk_108,locked, rising;

    clk_wiz_0 uut_clk(
        .reset(~rst),
        .locked(locked),
        .clk_in1(clk_100),
        .clk_out1(clk_108),
        .clk_out2(clk_12)
    );
    
    wire [10:0] mario_x;
    wire [9:0] mario_y;
    wire [5:0] mario_id;
    wire [5:0] id;
    
    //时钟
    wire clk_10;
    
    wire [32:0] div; // 用于游戏界面的时钟
    clkdiv uut_clkdiv(
        .clk(clk_100), 
        .rst(rst), 
        .clkdiv(div)
    );

    Divider uut_divider(
        .clk12Mhz(clk_12),
        .clk10Hz(clk_10)
    );

//    VGA
    VGA uut_vga(
        .clk(clk_108),
        .clk_view(clk_10),
        .rst(rst),
        .mario_x(mario_x),
        .mario_y(mario_y),
        .mario_id(mario_id),
        .O_red(color_r),
        .O_green(color_g),
        .O_blue(color_b),
        .hs(hs),
        .vs(vs)
    );
    
    World uut_world(
        .clkdiv(div),
        .rst(rst),
        .jump(jump),
        .left(left),
        .right(right),
        .mario_x(mario_x),
        .mario_y(mario_y),
        .mario_id(mario_id),
        .m_id(id),
        .rising(rising)
    );
    
    initial
    begin
        clk_100 = 1;
        forever
        begin
            #5 clk_100 = 0;
            #5 clk_100 = 1;
        end
    end
    
    initial
    begin
        rst = 0;
        #100 rst = 1;
    end
    
    initial
    begin
        right = 1;
        forever
        begin
        #13 right = 0;
        #13 right = 1;
        end
    end
    
    initial
    begin
        left = 0;
//        forever
//        begin
//        #18 left = 1;
//        #18 left = 0;
//        end
    end
    
    initial
    begin
        jump = 0;
    end
    
endmodule
