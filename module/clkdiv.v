`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/09 16:34:22
// Design Name: 
// Module Name: clkdiv
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


module clkdiv(
	input clk, 
	input rst, 
	output reg [32:0] clkdiv
    );

	always @ (posedge clk, negedge rst) begin
		if (!rst) clkdiv <= 0;
		else clkdiv <= clkdiv + 1'b1;
	end

endmodule