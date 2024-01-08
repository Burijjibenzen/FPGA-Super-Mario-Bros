`timescale 1ns / 1ns
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
     
    initial begin
        clk_100<=0;
        rst<=0;
        #1 rst<=1;
    end
    
    always #1 clk_100 <= ~clk_100;

    wire clk_108,locked;

    clk_wiz_0 uut_clk(
        .reset(~rst),
        .locked(locked),
        .clk_in1(clk_100),
        .clk_out1(clk_108)
    );

    //VGA
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
endmodule
