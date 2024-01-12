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
    input clk, // 40hz
	input clk_10, //10hz
	input rst, 
	input jump,
	input left,
	input right,
	input [32:0] view,

	output reg [10:0] mario_x,
	output reg [9:0] mario_y,
	output reg [5:0] mario_id = 6'd32,
	output [5:0] m_id,
	output reg [31:0] score,
	output reg death
	);

	// Common data
	wire clk_walk = clk_10; // 0.1s

	// Mario
	parameter init_mario_x = 11'd128;
	parameter init_mario_y = 10'd704;
	reg [1:0] jump_state; // 00: reset; 10: up; 11: down
//	reg [5:0] down_ticks; // 64: up -> down
	reg [5:0] up_ticks;   // 64: nomove -> up
	wire mario_oriental; 
	wire mario_walk;
	
	// 碰撞检测部分
    reg hit_up;
    reg hit_down;
    reg hit_left;
    reg hit_right;
    wire [11:0] map_addr_offset[7:0]; // 地图偏移地址
    reg  [4:0]          map_row[7:0]; // 当前马里奥方格为当前地图的第几行
    reg  [4:0]          map_col[7:0]; // 当前马里奥方格为当前地图的第几列
    reg  [11:0]         rom_addr_map; // 存放地图的rom地址
    wire [5:0]           typeid[7:0]; // 碰撞检测用
    
    parameter UP_1 = 0;
    parameter UP_2 = 1;
    parameter DOWN_1 = 2;
    parameter DOWN_2 = 3;
    parameter LEFT_1 = 4;
    parameter LEFT_2 = 5;
    parameter RIGHT_1 = 6;
    parameter RIGHT_2 = 7;
    
    // 碰撞检测
    always @(posedge clk or negedge rst) begin
         if(!rst) begin
                rom_addr_map <=  12'd0 ;
                map_row[UP_1] <=   5'd0 ;
                map_row[UP_2] <=   5'd0 ;
                map_col[UP_1] <=   5'd0 ;
                map_col[UP_2] <=   5'd0 ;
                map_row[DOWN_1] <=   5'd0 ;
                map_row[DOWN_2] <=   5'd0 ;
                map_col[DOWN_1] <=   5'd0 ;
                map_col[DOWN_2] <=   5'd0 ;
                map_row[LEFT_1] <=   5'd0 ;
                map_row[LEFT_2] <=   5'd0 ;
                map_col[LEFT_1] <=   5'd0 ;
                map_col[LEFT_2] <=   5'd0 ;
                map_row[RIGHT_1] <=   5'd0 ;
                map_row[RIGHT_2] <=   5'd0 ;
                map_col[RIGHT_1] <=   5'd0 ;
                map_col[RIGHT_2] <=   5'd0 ;
                hit_up <= 0;
                hit_down <= 0;
                hit_left <= 0;
                hit_right <= 0;
            end
         else begin
                rom_addr_map <= (view - 11'd640) / 64;
                map_row[UP_1] <= (mario_y - 1) / 64;
                map_col[UP_1] <= (mario_x + (view - 11'd640) % 64) / 64;
                map_row[UP_2] <= (mario_y - 1) / 64;
                map_col[UP_2] <= (mario_x + 63 + (view - 11'd640) % 64) / 64;
                
                map_row[DOWN_1] <= (mario_y + 64) / 64;
                map_col[DOWN_1] <= (mario_x + (view - 11'd640) % 64) / 64;
                map_row[DOWN_2] <= (mario_y + 64) / 64;
                map_col[DOWN_2] <= (mario_x + 63 + (view - 11'd640) % 64) / 64;
                
                map_row[LEFT_1] <= (mario_y) / 64;
                map_col[LEFT_1] <= (mario_x - 1 + (view - 11'd640) % 64) / 64;
                map_row[LEFT_2] <= (mario_y + 63) / 64;
                map_col[LEFT_2] <= (mario_x - 1 + (view - 11'd640) % 64) / 64;
                
                map_row[RIGHT_1] <= (mario_y) / 64;
                map_col[RIGHT_1] <= (mario_x + 64 + (view - 11'd640) % 64) / 64;
                map_row[RIGHT_2] <= (mario_y + 63) / 64;
                map_col[RIGHT_2] <= (mario_x + 64 + (view - 11'd640) % 64) / 64;
                
                if((typeid[UP_1] == 0 || typeid[UP_1] == 1 || typeid[UP_1] == 2) ||
                   (typeid[UP_2] == 0 || typeid[UP_2] == 1 || typeid[UP_2] == 2))
                    hit_down <= 1;
                else
                    hit_down <= 0;
                    
                if((typeid[DOWN_1] == 0 || typeid[DOWN_1] == 1 || typeid[DOWN_1] == 2 || typeid[DOWN_1] == 3 || typeid[DOWN_1] == 13 || typeid[DOWN_1] == 38 || typeid[DOWN_1] == 39) ||
                   (typeid[DOWN_2] == 0 || typeid[DOWN_2] == 1 || typeid[DOWN_2] == 2 || typeid[DOWN_2] == 3 || typeid[DOWN_2] == 13 || typeid[DOWN_2] == 38 || typeid[DOWN_2] == 39))
                    hit_up <= 1;
                else
                    hit_up <= 0;
                    
                if((typeid[LEFT_1] == 0 || typeid[LEFT_1] == 1 || typeid[LEFT_1] == 2 || typeid[LEFT_1] == 3 || typeid[LEFT_1] == 13 || typeid[LEFT_1] == 39 || typeid[LEFT_1] == 49) ||
                   (typeid[LEFT_2] == 0 || typeid[LEFT_2] == 1 || typeid[LEFT_2] == 2 || typeid[LEFT_2] == 3 || typeid[LEFT_2] == 13 || typeid[LEFT_2] == 39 || typeid[LEFT_2] == 49))
                    hit_right <= 1;
                else
                    hit_right <= 0;
                    
                if((typeid[RIGHT_1] == 0 || typeid[RIGHT_1] == 1 || typeid[RIGHT_1] == 2 || typeid[RIGHT_1] == 3 || typeid[RIGHT_1] == 13 || typeid[RIGHT_1] == 38 || typeid[RIGHT_1] == 48) ||
                   (typeid[RIGHT_2] == 0 || typeid[RIGHT_2] == 1 || typeid[RIGHT_2] == 2 || typeid[RIGHT_2] == 3 || typeid[RIGHT_2] == 13 || typeid[RIGHT_2] == 38 || typeid[RIGHT_2] == 48))
                    hit_left <= 1;
                else
                    hit_left <= 0;
              end
         end
        
    genvar i;
    generate
        for(i = 0; i <= 7; i = i + 1) begin: calculate
           blk_mem_gen_map map(
            .clka(clk),              // input clka
            .addra(map_addr_offset[i]), // input [11 : 0] addra
            .douta(typeid[i])           // output [5 : 0] douta
            );   
           assign map_addr_offset[i] = rom_addr_map + 212 * map_row[i] + map_col[i]; // 当前的地图块元素位置
        end
    endgenerate

    // 实现走路帧
	Mario mario(
		.clk_walk(clk_walk),  
		.rst(rst), 
		.left(left), 
		.right(right), 
		.jump(jump), 
		.id(m_id),
		.oriental(mario_oriental), 
		.walk(mario_walk)
    );
    
    //mario 走路跳跃状态机
	always@(posedge clk_10, negedge rst) begin
		if (!rst) begin
			mario_x <= init_mario_x; 
			mario_y <= init_mario_y;

			up_ticks <= 6'd0;
//			down_ticks <= 6'd0;
			jump_state <= 2'b00;

			mario_id <= 6'd32;
			death <= 0;
		end 
		else begin
                       
					// Let Mario walks! 
					if (mario_walk && !death) begin
					   if((hit_right == 1 && right == 1)|| (hit_left == 1 && left == 1))
					       mario_x <= mario_x;
					   else
					    if(mario_x >= 640 && right == 1)
					       mario_x <= 640;
					    else
						   mario_x <= mario_oriental ? mario_x - 11'd16 : mario_x + 11'd16;
						   
						if(jump_state == 2'b10 || jump_state == 2'b11)
						   mario_id <= mario_oriental ? 6'd46 : 6'd36;
						else if(right == 0 && left == 0)
						   mario_id <= mario_oriental ? 6'd42 : 6'd32;
						else
						   mario_id <= m_id;
					end
					
					//die
					if(mario_y >= 832) begin
					   death <= 1;
					   mario_id <= 37;
				    end
					
					// Let Mario jumps! 
					if(death == 0)
					case(jump_state)
					   2'b00: begin
					       if(jump == 1) begin
					           jump_state <= 2'b10;
					           mario_id <= mario_oriental ? 6'd46 : 6'd36;
					       end
					       else if(hit_up == 0) begin
					           jump_state <= 2'b11;
					       end
					       else begin
					           jump_state <= jump_state;
					       end
					   end
					   2'b10: begin
					       if(up_ticks == 6'd10) begin
					           up_ticks <= 0;
                               jump_state <= 2'b11;
                               mario_id <= mario_oriental ? 6'd46 : 6'd36;
					       end
					       else begin
					           if(hit_down == 1 || mario_y == 0) begin
					               up_ticks <= 0;
					               jump_state <= 2'b11;
					           end
					           else begin
					               up_ticks <= up_ticks + 1;
                                   mario_y <= mario_y - 10'd32;
                                   jump_state <= jump_state;
                               end
					       end
					   end
					   2'b11: begin
					       if(hit_up == 1) begin
					           jump_state <= 2'b00;
					           mario_id <= mario_oriental ? 6'd42 : 6'd32;
					       end
					       else begin
					           mario_y <= mario_y + 10'd32;
					           jump_state <= jump_state;
					       end
					   end
					endcase
		end
	end
	
	// 加分机制
	always@(posedge clk_10, negedge rst) begin
	   if(!rst) begin
	       score <= 0;
	   end
	   else begin
	       if(typeid[UP_1] == 0 || typeid[UP_2] == 0)
	           score <= score + 100;
	   end
	end

endmodule