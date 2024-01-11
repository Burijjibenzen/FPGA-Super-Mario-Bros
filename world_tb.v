`timescale 10ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/10 02:09:54
// Design Name: 
// Module Name: world_tb
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


module world_tb();
    reg clk;
    reg clk_10;
    reg rst;
    reg jump;
    reg left;
    reg right;
    reg [32:0] view;
    
    wire [10:0] mario_x;
    wire [9:0]  mario_y;
    wire [5:0]  id;
//    wire rising;
    
    World uut_world(
        .clk(clk),
        .clk_10(clk_10),
        .rst(rst),
        .jump(jump),
        .left(left),
        .right(right),
        .view(view),
        .mario_x(mario_x),
        .mario_y(mario_y),
        .mario_id(id)
//        .rising(rising)
    );
    
    initial
    begin
        clk = 1;
        forever
        begin
            #5 clk = 0;
            #5 clk = 1;
        end
    end
    
    initial
    begin
        clk_10 = 1;
        forever
        begin
            #5000000 clk_10 = 0;
            #5000000 clk_10 = 1;
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
//        forever
//        begin
//        #13 right = 0;
//        #13 right = 1;
//        end
    end
    
    initial
    begin
        left = 0;
//        #5000050 left = 1;
//        forever
//        begin
//        #18 left = 1;
//        #18 left = 0;
//        end
    end
    
    initial
    begin
        jump = 1;
        view = 640;
    end
    
endmodule
