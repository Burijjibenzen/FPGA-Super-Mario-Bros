`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/12 15:40:21
// Design Name: 
// Module Name: Display
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


module Display(
    input clk_1000hz,
    input [31:0] score,
    output reg [7:0] shift,//第几个数码管(片选)
    output reg [6:0] oData
);
    wire [3:0] Data[7:0];
    reg  [3:0]     cnt=0;//计数器
    
    //转换为BCD
    bin2BCD uut_bin2BCD(
        .number(score),
        .bcd0(Data[0]),
        .bcd1(Data[1]),
        .bcd2(Data[2]),
        .bcd3(Data[3]),
        .bcd4(Data[4]),
        .bcd5(Data[5]),
        .bcd6(Data[6]),
        .bcd7(Data[7])
    );
    
    //片选输出
    always@(posedge clk_1000hz)begin
        if(cnt == 4'd8)
            cnt <= 0;
        else
            cnt <= cnt + 1;
        shift <= 8'b1111_1111;
        shift[cnt] <= 0;//选择一个数码管进行输出
        
        case (Data[cnt])
            4'b0000: oData <= 7'b1000000;
            4'b0001: oData <= 7'b1111001;
            4'b0010: oData <= 7'b0100100;
            4'b0011: oData <= 7'b0110000;
            4'b0100: oData <= 7'b0011001;
            4'b0101: oData <= 7'b0010010;
            4'b0110: oData <= 7'b0000010;
            4'b0111: oData <= 7'b1111000;
            4'b1000: oData <= 7'b0000000;
            4'b1001: oData <= 7'b0010000;
            default: oData <= 7'b1111111;
        endcase
    end
    
endmodule
