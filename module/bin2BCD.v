`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/12 15:37:25
// Design Name: 
// Module Name: bin2BCD
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

//BCD转换
module bin2BCD(
    input [31:0] number,     //数字
    output [3:0] bcd0,
    output [3:0] bcd1,
    output [3:0] bcd2,
    output [3:0] bcd3,
    output [3:0] bcd4,
    output [3:0] bcd5,
    output [3:0] bcd6,
    output [3:0] bcd7
    );

    reg [31:0]  bin;
    reg [31:0]  result;
    reg [31:0]  bcd;
    
    //转换为BCD码
    always @(number) begin
        bin = number[31:0];
        result = 32'd0;
        repeat (31)             
        begin
            result[0] = bin[31];
            if (result[3:0] > 4)
                result[3:0] = result[3:0] + 4'd3;
            else
                result[3:0] = result[3:0];
            if (result[7:4] > 4)
                result[7:4] = result[7:4] + 4'd3;
            else
                result[7:4] = result[7:4];
            if (result[11:8] > 4)
                result[11:8] = result[11:8] + 4'd3;
            else
                result[11:8] = result[11:8];
            if (result[15:12] > 4)
                result[15:12] = result[15:12] + 4'd3;
            else
                result[15:12] = result[15:12];
            if (result[19:16] > 4)
                result[19:16] = result[19:16] + 4'd3;
            else
                result[19:16] = result[19:16];
                
            if (result[23:20] > 4)
                result[23:20] = result[23:20] + 4'd3;
            else
                result[23:20] = result[23:20];

            if (result[27:24] > 4)
                result[27:24] = result[27:24] + 4'd3;
            else
                result[27:24] = result[27:24];
            if (result[31:28] > 4)
                result[31:28] = result[31:28] + 4'd3;
            else
                result[31:28] = result[31:28];
            result = result << 1;
            bin = bin << 1;
        end
        result[0] = bin[31];
        bcd = result;
    end

    assign bcd0 = bcd[3:0];
    assign bcd1 = bcd[7:4];
    assign bcd2 = bcd[11:8];
    assign bcd3 = bcd[15:12];
    assign bcd4 = bcd[19:16];
    assign bcd5 = bcd[23:20];
    assign bcd6 = bcd[27:24];
    assign bcd7 = bcd[31:28];
    
endmodule
