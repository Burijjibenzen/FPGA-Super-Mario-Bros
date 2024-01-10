`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/10 00:15:57
// Design Name: 
// Module Name: mario_tb
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


module mario_testbench();
    reg clk;
    reg clk_walk;
    reg rst;
    reg left;
    reg right;
    reg jump;
    
    wire [5:0] id;
    wire oriental;
    wire walk;
    wire rising;
    
	Mario mario(
        .clk(clk), 
        .clk_walk(clk_walk),  
        .rst(rst), 
        .left(left), 
        .right(right), 
        .jump(jump), 
        .id(id),
        .oriental(oriental), 
        .walk(walk),
        .rising(rising)
    );
    
    initial
    begin
        clk = 1;
        forever
        begin
            #1 clk = 0;
            #1 clk = 1;
        end
    end
    
    initial
    begin
        clk_walk = 1;
        forever
        begin
            #50 clk_walk = 0;
            #50 clk_walk = 1;
        end
    end
    
    initial
    begin
        rst = 0;
        #1 rst = 1;
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
