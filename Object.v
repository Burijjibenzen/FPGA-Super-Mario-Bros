`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/06 20:00:43
// Design Name: 
// Module Name: Object
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

//////////////////////////////////////////////////////////////////////////////////
// ¹¦ÄÜ£ºMap object id to address in the rom.
//////////////////////////////////////////////////////////////////////////////////
//box: 0
//boxempty: 1
//block: 2
//ground: 3

//castle1: 4
//castle2: 5
//castle3: 6
//castle4: 7
//castle5: 8
//castle6: 9

//goomba1: 10
//goomba2: 11
//goomba3: 12

//obstacle: 13

//mushroom: 14

//hill_up: 15
//hill_left: 24
//hill_down: 25
//hill_right: 26

//coin1: 16
//coin2: 17
//coin3: 18
//coin4: 19

//cloud1: 20
//cloud2: 21
//cloud3: 30
//cloud4: 31

//grass_left: 22
//grass_right: 23

//flag: 27
//pillar: 28
//ball: 29

//player1l: 32
//player1r: 42
//player2l: 33
//player2r: 43
//player3l: 34
//player3r: 44
//player4l: 35
//player4r: 45
//player5l: 36
//player5r: 46
//player_die: 37

//tunnel1: 38
//tunnel2: 39
//tunnel3: 48
//tunnel4: 49

//sky: 40

module Object(
	input [5:0] id, // 0 - 49 (64)
	output reg [17:0] addr
);

	always@(*) begin
		case(id)
			0: addr <= 0;
			1: addr <= 64 * 1;
			2: addr <= 64 * 2;
			3: addr <= 64 * 3;
			4: addr <= 64 * 4;
			5: addr <= 64 * 5;
			6: addr <= 64 * 6;
			7: addr <= 64 * 7;
			8: addr <= 64 * 8;
			9: addr <= 64 * 9;
			10: addr <= 640 * 64;
			11: addr <= 640 * 64 + 64 * 1;
			12: addr <= 640 * 64 + 64 * 2;
			13: addr <= 640 * 64 + 64 * 3;
			14: addr <= 640 * 64 + 64 * 4;
			15: addr <= 640 * 64 + 64 * 5;
			16: addr <= 640 * 64 + 64 * 6;
			17: addr <= 640 * 64 + 64 * 7;
			18: addr <= 640 * 64 + 64 * 8;
			19: addr <= 640 * 64 + 64 * 9;
			20: addr <= 640 * 64 * 2;
			21: addr <= 640 * 64 * 2 + 64 * 1;
			22: addr <= 640 * 64 * 2 + 64 * 2;
			23: addr <= 640 * 64 * 2 + 64 * 3;
			24: addr <= 640 * 64 * 2 + 64 * 4;
			25: addr <= 640 * 64 * 2 + 64 * 5;
			26: addr <= 640 * 64 * 2 + 64 * 6;
			27: addr <= 640 * 64 * 2 + 64 * 7;
			28: addr <= 640 * 64 * 2 + 64 * 8;
			29: addr <= 640 * 64 * 2 + 64 * 9;
			30: addr <= 640 * 64 * 3;
			31: addr <= 640 * 64 * 3 + 64 * 1;
			32: addr <= 640 * 64 * 3 + 64 * 2;
			33: addr <= 640 * 64 * 3 + 64 * 3;
			34: addr <= 640 * 64 * 3 + 64 * 4;
			35: addr <= 640 * 64 * 3 + 64 * 5;
			36: addr <= 640 * 64 * 3 + 64 * 6;
			37: addr <= 640 * 64 * 3 + 64 * 7;
			38: addr <= 640 * 64 * 3 + 64 * 8;
			39: addr <= 640 * 64 * 3 + 64 * 9;
			40: addr <= 640 * 64 * 4;
			42: addr <= 640 * 64 * 4 + 64 * 2;
			43: addr <= 640 * 64 * 4 + 64 * 3;
			44: addr <= 640 * 64 * 4 + 64 * 4;
			45: addr <= 640 * 64 * 4 + 64 * 5;
			46: addr <= 640 * 64 * 4 + 64 * 6;
			48: addr <= 640 * 64 * 4 + 64 * 8;
			49: addr <= 640 * 64 * 4 + 64 * 9;
			default: 
				addr <= 640 * 64 * 4;
		endcase
	end
	
endmodule
