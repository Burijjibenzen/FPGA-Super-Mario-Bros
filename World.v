`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/09 16:27:53
// Design Name: 
// Module Name: World
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


module World(
	input [32:0] clkdiv, 
	input rst, 
	input jump, 
	input left, 
	input right, 

	output reg [10:0] mario_x,
	output reg [9:0] mario_y,
	output reg [5:0] mario_id = 6'd32,
	output [5:0] m_id,
    output rising
	);

	// Common data
	wire clk_walk = clkdiv[22]; // 0.17s 22
	wire [10:0] view_x;

	// Mario
	parameter init_mario_x = 11'd128;
	parameter init_mario_y = 10'd704;
	reg [1:0] jump_state; // 00: reset; 10: up; 11: down
	reg [5:0] down_ticks; // 64: up -> down
	reg [5:0] up_ticks; // 64: nomove -> up
	//wire [5:0] m_id;
	wire mario_oriental; 
	wire mario_walk;

    // ʵ����·֡
	Mario mario(
	    .clk(clkdiv[0]), 
		.clk_walk(clk_walk),  
		.rst(rst), 
		.left(left), 
		.right(right), 
		.jump(jump), 
		.id(m_id),
		.oriental(mario_oriental), 
		.walk(mario_walk),
	    .rising(rising)
    );
    
	// Frame
	reg [1:0] ticks_1;
	reg clk_17;
    
    //mario ��·��Ծ״̬��
	always@(posedge clkdiv[0], negedge rst) begin
		if (!rst) begin
			mario_x <= init_mario_x; 
			mario_y <= init_mario_y;

			ticks_1 <= 2'b0;
			up_ticks <= 6'd0;
			down_ticks <= 6'd0;
			jump_state <= 2'b00;
			clk_17 <= clkdiv[17];
			mario_id <= 6'd32;
		end 
		else begin
			if (~clk_17 & clkdiv[17]) begin
				if (ticks_1[1]) begin
					// Let Mario walks! 
					if (mario_walk) begin
						mario_x <= mario_oriental ? mario_x - 11'd4 : mario_x + 11'd4;
						mario_id <= m_id;
					end
					
					// Let Mario jumps! 
					case(jump_state)
					   2'b00: begin
					       if(jump == 1) begin
					           jump_state <= 2'b10;
					           mario_id <= mario_oriental ? 6'd46 : 6'd36;
					       end
					       else begin
					           jump_state <= jump_state;
					       end
					   end
					   2'b10: begin
					       if(up_ticks == 6'd63) begin
					           up_ticks <= 0;
                               jump_state <= 2'b11;
                               mario_id <= mario_oriental ? 6'd46 : 6'd36;
					       end
					       else begin
					           up_ticks <= up_ticks + 1;
                               mario_y <= mario_y - 10'd4;
                               jump_state <= jump_state;
					       end
					   end
					   2'b11: begin
					       if(down_ticks == 6'd63) begin
					           down_ticks <= 0;
					           jump_state <= 2'b00;
					           mario_id <= mario_oriental ? 6'd42 : 6'd32;
					       end
					       else begin
					           down_ticks <= down_ticks + 1;
					           mario_y <= mario_y + 10'd4;
					           jump_state <= jump_state;
					       end
					   end
					endcase
				
					ticks_1 <= 2'b0;
				end

				ticks_1 <= ticks_1 + 1'b1;
			end
		    clk_17 <= clkdiv[17];
		end
	end

endmodule