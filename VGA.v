`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/30 21:48:59
// Design Name: 
// Module Name: VGA
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


module vga111 (
    input                     clk   , // 时钟
    input                     rst   , // 复位,低电平有效
    input          [11:0]  rom_addr , // 内存地址
    input          [7:0]     view   , // 代表当前的视野位置
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

    reg [11:0]      h_cnt         ; // 行时序计数器
    reg [11:0]      v_cnt         ; // 列时序计数器

    wire            active        ; // 激活标志，当这个信号为1时RGB的数据可以显示在屏幕上
    wire [11:0] x;
    wire [11:0] y;//坐标
    
    wire    [15:0]  rom_data      ; // ROM中存储的数据
    
    parameter      IMAGE_WIDTH       =   640     ,
                    IMAGE_HEIGHT      =   320     ,
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
    
                       
endmodule
//////////////////////////////////////////////////////////////////
// 功能：把ROM里面的图片数据输出
//////////////////////////////////////////////////////////////////
/*
always @(posedge clk or negedge rst)
begin 
    if(!rst) 
        rom_addr  <=  15'd0 ;
    else if(active)     
        begin
            if(h_cnt >= (HS_SYNC + HS_BACK                      )  && 
               h_cnt <= (HS_SYNC + HS_BACK + IMAGE_WIDTH  - 1'b1)  &&
               v_cnt >= (VS_SYNC + VS_BACK                      )  && 
               v_cnt <= (VS_SYNC + VS_BACK + IMAGE_HEIGHT - 1'b1)  )
                begin
                    O_red       <= rom_data[15:12]    ; // 红色分量
                    O_green     <= rom_data[10:7]     ; // 绿色分量
                    O_blue      <= rom_data[4:1]      ; // 蓝色分量
                    if(rom_addr == IMAGE_PIX_NUM - 1'b1)
                        rom_addr  <=  18'd0 ;
                    else
                        rom_addr  <=  rom_addr  +  1'b1 ;        
                end
            else
                begin
                    O_red       <=  4'd0        ;
                    O_green     <=  4'd0        ;
                    O_blue      <=  4'd0        ;
                    rom_addr    <=  rom_addr    ;
                end                          
        end
    else
        begin
            O_red       <=  4'd0        ;
            O_green     <=  4'd0        ;
            O_blue      <=  4'd0        ;
            rom_addr    <=  rom_addr    ;
        end          
end

blk_mem_gen_0 uut_image (
  .clka(clk), // input clka
  .addra(rom_addr), // input [17 : 0] addra
  .douta(rom_data) // output [15 : 0] douta
);
*/
//////////////////////////////////////////////////////////////////
// 功能：把显示器屏幕分成8个纵列，每个纵列的宽度是80
//////////////////////////////////////////////////////////////////
    /*
    always @(posedge clk or negedge rst)
    begin
        if(!rst) 
            begin
                O_red   <=  5'b00000    ;
                O_green <=  6'b000000   ;
                O_blue  <=  5'b00000    ; 
            end
        else if(active)     
            begin
                 if(h_cnt < (HS_SYNC + HS_BACK + COLOR_BAR_WIDTH)) // 红色彩条
                begin
                    O_red   <=  5'b11111    ; // 红色彩条把红色分量全部给1，绿色和蓝色给0
                    O_green <=  6'b000000   ;
                    O_blue  <=  5'b00000    ;
                end
            else if(h_cnt < (HS_SYNC + HS_BACK + COLOR_BAR_WIDTH*2)) // 绿色彩条
                begin
                    O_red   <=  5'b00000    ;
                    O_green <=  6'b111111   ; // 绿色彩条把绿色分量全部给1，红色和蓝色分量给0
                    O_blue  <=  5'b00000    ;
                end 
            else if(h_cnt < (HS_SYNC + HS_BACK + COLOR_BAR_WIDTH*3)) // 蓝色彩条
                begin
                    O_red   <=  5'b00000    ;
                    O_green <=  6'b000000   ;
                    O_blue  <=  5'b11111    ; // 蓝色彩条把蓝色分量全部给1，红色和绿分量给0
                end 
            else if(h_cnt < (HS_SYNC + HS_BACK + COLOR_BAR_WIDTH*4)) // 白色彩条
                begin
                    O_red   <=  5'b11111    ; // 白色彩条是有红绿蓝三基色混合而成
                    O_green <=  6'b111111   ; // 所以白色彩条要把红绿蓝三个分量全部给1
                    O_blue  <=  5'b11111    ;
                end 
            else if(h_cnt < (HS_SYNC + HS_BACK + COLOR_BAR_WIDTH*5)) // 黑色彩条
                begin
                    O_red   <=  5'b00000    ; // 黑色彩条就是把红绿蓝所有分量全部给0
                    O_green <=  6'b000000   ;
                    O_blue  <=  5'b00000    ;
                end 
            else if(h_cnt < (HS_SYNC + HS_BACK + COLOR_BAR_WIDTH*6)) // 黄色彩条
                begin
                    O_red   <=  5'b11111    ; // 黄色彩条是有红绿两种颜色混合而成
                    O_green <=  6'b111111   ; // 所以黄色彩条要把红绿两个分量给1
                    O_blue  <=  5'b00000    ; // 蓝色分量给0
                end 
            else if(h_cnt < (HS_SYNC + HS_BACK + COLOR_BAR_WIDTH*7)) // 紫色彩条
                begin
                    O_red   <=  5'b11111    ; // 紫色彩条是有红蓝两种颜色混合而成
                    O_green <=  6'b000000   ; // 所以紫色彩条要把红蓝两个分量给1
                    O_blue  <=  5'b11111    ; // 绿色分量给0
                end 
            else                              // 青色彩条
                begin
                    O_red   <=  5'b00000    ; // 青色彩条是由蓝绿两种颜色混合而成
                    O_green <=  6'b111111   ; // 所以青色彩条要把蓝绿两个分量给1
                    O_blue  <=  5'b11111    ; // 红色分量给0
                end                   
            end
        else
            begin
                O_red   <=  5'b00000    ;
                O_green <=  6'b000000   ;
                O_blue  <=  5'b00000    ; 
            end           
    end
    */
