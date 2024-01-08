`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/08 15:04:02
// Design Name: 
// Module Name: Divider
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


module Divider(
    input clk12Mhz,
    output reg clk2Mhz = 0
    );
    integer cnt1 = 32'd0;
    always @(posedge clk12Mhz) begin
        if (cnt1 < 6 / 2 - 1)
            cnt1 <= cnt1 + 1'b1;
        else begin
            cnt1 <= 32'd0;
            clk2Mhz <= ~clk2Mhz;
        end
    end
endmodule
