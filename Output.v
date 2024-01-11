`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/06 20:41:32
// Design Name: 
// Module Name: Output
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


module VGA(
    input  clk   ,     // 时钟
    input  clk_view,
    input  rst   ,     // 复位,低电平有效
    input  [10:0] mario_x, // mario左上角的横坐标
    input  [9:0]  mario_y, // mario左上角的纵坐标
    input  [5:0]  mario_id,// mario id
    input  right,          // 右移信号
	//output [8:0] row_addr, // pixel ram row address, 320 (512) lines
	//output [9:0] col_addr, // pixel ram col address, 640 (1024) pixels
    output   reg   [3:0]    O_red   , // VGA红色分量
    output   reg   [3:0]    O_green , // VGA绿色分量
    output   reg   [3:0]    O_blue  , // VGA蓝色分量
    output                    hs    , // 行同步信号
    output                    vs      // 场同步信号
	);
	
    //行时序常数
    parameter  HS_SYNC     = 112,   
                HS_BACK     = 248,   
                HS_ACTIVE   = 1280,  
                HS_FRONT    = 48;   
    //场时序常数
    parameter  VS_SYNC     = 3,    
                VS_BACK     = 38,   
                VS_ACTIVE   = 1024,  
                VS_FRONT    = 1;   
    //最大行列
    parameter  COL = 1688,
                ROW = 1066;
                
    parameter      COLOR_BAR_WIDTH   =   HS_ACTIVE / 8  ;  

    reg [10:0]      h_cnt         ; // 行时序计数器
    reg [10:0]      v_cnt         ; // 列时序计数器

    wire            active        ; // 激活标志，当这个信号为1时RGB的数据可以显示在屏幕上
    wire [10:0] x;
    wire [9:0]  y;//坐标
    
    parameter      IMAGE_WIDTH       =   1280    ,
                    IMAGE_HEIGHT      =   896     ,
                    IMAGE_PIX_NUM     =   204800  ;
//////////////////////////////////////////////////////////////////
// 功能：产生行时序
//////////////////////////////////////////////////////////////////
    always @(posedge clk or negedge rst)
    begin
        if(!rst)
            h_cnt <=  12'd0   ;
        else if(h_cnt == COL - 1'b1)
            h_cnt <=  12'd0   ;
        else
            h_cnt <=  h_cnt + 1'b1  ;                
    end                

    assign hs =   (h_cnt < HS_SYNC) ? 1'b0 : 1'b1    ; 
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// 功能：产生场时序
//////////////////////////////////////////////////////////////////
    always @(posedge clk or negedge rst)
    begin
        if(!rst)
            v_cnt <=  12'd0   ;
        else if(v_cnt == ROW - 1'b1)
            v_cnt <=  12'd0   ;
        else if(h_cnt == COL - 1'b1)
            v_cnt <=  v_cnt + 1'b1  ;
        else
            v_cnt <=  v_cnt ;                        
    end                

    assign vs =   (v_cnt < VS_SYNC) ? 1'b0 : 1'b1    ; 
//////////////////////////////////////////////////////////////////  
// 产生有效区域标志，当这个信号为高时往RGB送的数据才会显示到屏幕上
////////////////////////////////////////////////////////////////// 
    assign active =     (h_cnt >= (HS_SYNC + HS_BACK            ))  &&
                        (h_cnt <= (HS_SYNC + HS_BACK + HS_ACTIVE))  && 
                        (v_cnt >= (VS_SYNC + VS_BACK            ))  &&
                        (v_cnt <= (VS_SYNC + VS_BACK + HS_ACTIVE))  ;        
////////////////////////////////////////////////////////////////// 

	reg  [11:0]         rom_addr_map; // 存放地图的rom地址
    wire [5:0]                typeid; // 元素的id
    wire [11:0]      map_addr_offset; // 地图偏移地址
    wire [17:0]     rom_addr_sprites; // 存放元素的rom地址
    wire [17:0]           mario_addr; // 马里奥动作在rom中的起始地址
    wire [17:0]    mario_addr_offset; // 马里奥偏移地址
    wire [17:0]  sprites_addr_offset; // 元素偏移地址
    wire [15:0]         sprites_data; // 元素的rgb信息
    wire [15:0]           mario_data; // mario的rgb信息
    reg  [4:0]               map_row; // 当前显示地图方格为当前地图的第几行
    reg  [4:0]               map_col; // 当前显示地图方格为当前地图的第几列
    reg  [5:0]           sprites_row; // 当前显示像素为当前元素的第几行
    reg  [5:0]           sprites_col; // 当前显示像素为当前元素的第几列
    reg  [32:0]                 view; // 当前视野的位置
        
    assign map_addr_offset     = rom_addr_map     + 212 * map_row     + map_col; // 当前的地图块元素位置
    assign sprites_addr_offset = rom_addr_sprites + 640 * sprites_row + sprites_col; // 当前的像素位置
    assign mario_addr_offset   = mario_addr     + 640 * (y - mario_y) + x - mario_x; // 当前马里奥像素位置
    assign x = (active) ? h_cnt - (HS_SYNC + HS_BACK):0;
    assign y = (active) ? v_cnt - (VS_SYNC + VS_BACK):0; //当前VGA中显示的像素在VGA上的位置
    
	blk_mem_gen_map map(
	    .clka(clk),              // input clka
        .addra(map_addr_offset), // input [11 : 0] addra
        .douta(typeid)           // output [5 : 0] douta
    );	
    
    Object object_ground(
        .id(typeid),  
        .addr(rom_addr_sprites)
    );
    
    Object object_mario(
        .id(mario_id),  
        .addr(mario_addr)
    );
    
    blk_mem_gen_0 sprites(
        .clka(clk),                  // input clka
        .addra(sprites_addr_offset), // input [17 : 0] addra
        .douta(sprites_data),        // output [15 : 0] douta
        .clkb(clk),                  // input clkb
        .addrb(mario_addr_offset),   // input [17 : 0] addrb
        .doutb(mario_data)           // output [15 : 0] doutb
    );
    
    always @(posedge clk or negedge rst)
    begin
        if(!rst) 
        begin
             rom_addr_map <=  12'd0 ;
                  map_row <=   5'd0 ;
                  map_col <=   5'd0 ;
              sprites_row <=   6'd0 ;
              sprites_col <=   6'd0 ;
        end
        else if(active)     
        begin
            if(h_cnt >= (HS_SYNC + HS_BACK                      )  && 
               h_cnt <= (HS_SYNC + HS_BACK + IMAGE_WIDTH  - 1'b1)  &&
               v_cnt >= (VS_SYNC + VS_BACK                      )  && 
               v_cnt <= (VS_SYNC + VS_BACK + IMAGE_HEIGHT - 1'b1)  )
            begin
                rom_addr_map <= (view - 11'd640) / 64;
                map_row <= y / 64;
                map_col <= (x + (view - 11'd640) % 64) / 64;
                sprites_row <=  y % 64;
                sprites_col <=  (x - 2 + (view - 11'd640) % 64) % 64; // 减二消除毛刺
                if((x <= mario_x + 63) && (x >= mario_x) && (y >= mario_y) && (y <= mario_y + 63) && mario_data != 16'd23743) begin
                    O_red       <=  mario_data[15:12];
                    O_green     <=  mario_data[10:7];
                    O_blue      <=  mario_data[4:1];
                end
                else begin
                    O_red       <=  sprites_data[15:12];
                    O_green     <=  sprites_data[10:7];
                    O_blue      <=  sprites_data[4:1];
                end
                // 记得增加view的变化逻辑
            end
            else
            begin
                O_red       <=  4'd0;
                O_green     <=  4'd0;
                O_blue      <=  4'd0;
            end                   
        end
        else
        begin
            O_red       <=  4'd0;
            O_green     <=  4'd0;
            O_blue      <=  4'd0;
        end
    end
	
	always @(posedge clk_view or negedge rst) begin
	   if(!rst)
           view <=  32'd640 ;
       else if (mario_x >= 640 && right == 1) begin
           view <= view + 32'd8;
           if(view >= 12800)
                view <= view;
       end
       else
           view <= view;
	end
	
endmodule