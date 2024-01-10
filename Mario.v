`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/08 17:36:04
// Design Name: 
// Module Name: Mario
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


module Mario(
	input clk,      // �����ж����ҷ����
	input clk_walk, // �����л�mario�Ķ���
	input rst, 
	input left,  // ������
	input right, // ������
	input jump, 

	output reg [5:0] id, 
	output reg oriental, // 0: right 1: left 
	output reg walk,     // 0: no 1: yes
	output rising
   );

    //state machine walk
    parameter walk1 = 2'd0;
    parameter walk2 = 2'd1;
    parameter walk3 = 2'd2;
    parameter walk4 = 2'd3;
    
    // ��������id
	parameter player1r = 32;
    parameter player1l = 42;
	parameter player2r = 33;
	parameter player2l = 43;
	parameter player3r = 34;
	parameter player3l = 44;
	parameter player4r = 35;
	parameter player4l = 45;

	reg [1:0] walk_state; // 0/1/2/3 //����֡

    reg pre_walk_0;
    reg pre_walk_1;
    //wire rising;
    
    assign rising = pre_walk_0 & ~pre_walk_1;
    
	always@(posedge clk, negedge rst) begin
		if (!rst) 
		begin
			oriental <= 0;
            walk <= 0;
            walk_state <= walk1;
            pre_walk_0 <= 0;
            pre_walk_1 <= 0;
            id <= player1r;
        end
        else
        begin
			if (~oriental & left & ~right) // �жϷ�������ȫΪ0or1�����򲻱�
				oriental <= 1;
			else if (oriental & ~left & right)
				oriental <= 0;
				
			walk <= left ^ right; // ȫΪ0/1�Ͳ���
			
			pre_walk_1 <= pre_walk_0;
			pre_walk_0 <= clk_walk;

			if (rising)
              if(jump == 0)
				if (left != 1) // û������
				        case (walk_state)
						    walk1: begin
						              if(right == 1) begin
						                  walk_state <= walk3;
						                  id <= player3r;
						              end
						              else begin
						                  walk_state <= walk1;
						                  id <= player1r;
						              end
						           end
						    walk2: begin 
						              if(right == 1) begin
                                          walk_state <= walk4;
                                          id <= player4r;
                                      end
                                      else begin
                                          walk_state <= walk1;
                                          id <= player1r;
                                      end
                                   end
						    walk3: begin 
						              walk_state <= walk2;
						              id <= player2r; 
						           end
						    walk4: begin 
						              if(right == 1) begin
						                  walk_state <= walk3;
						                  id <= player3r;
						              end
                                      else begin
                                          walk_state <= walk2; 
                                          id <= player2r;
                                      end
                                   end
					   endcase
			     else
				case (walk_state)
                walk1: begin
                          if(right == 0) begin
                              walk_state <= walk3;
                              id <= player3l;
                          end
                          else begin
                              walk_state <= walk1;
                              id <= player1l;
                          end
                       end
                walk2: begin 
                          if(right == 0) begin
                              walk_state <= walk4;
                              id <= player4l;
                          end
                          else begin
                              walk_state <= walk1;
                              id <= player1l;
                          end
                       end
                walk3: begin 
                          walk_state <= walk2;
                          id <= player2l; 
                       end
                walk4: begin 
                          if(right == 0) begin
                              walk_state <= walk3;
                              id <= player3l;
                          end
                          else begin
                              walk_state <= walk2; 
                              id <= player2l;
                          end
                       end
                endcase
		end 
	end

endmodule
