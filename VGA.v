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
    input                     clk   , // ʱ��
    input                     rst   , // ��λ,�͵�ƽ��Ч
    input          [11:0]  rom_addr , // �ڴ��ַ
    input          [7:0]     view   , // ����ǰ����Ұλ��
    output   reg   [3:0]    O_red   , // VGA��ɫ����
    output   reg   [3:0]    O_green , // VGA��ɫ����
    output   reg   [3:0]    O_blue  , // VGA��ɫ����
    output                    hs    , // ��ͬ���ź�
    output                    vs      // ��ͬ���ź�
    );

    //��ʱ����
    parameter  HS_SYNC     = 112,   
                HS_BACK     = 248,   
                HS_ACTIVE   = 1280,  
                HS_FRONT    = 48;   
    //��ʱ����
    parameter  VS_SYNC     = 3,    
                VS_BACK     = 38,   
                VS_ACTIVE   = 1024,  
                VS_FRONT    = 1;   
    //�������
    parameter  COL = 1688,
                ROW = 1066;
                
    parameter      COLOR_BAR_WIDTH   =   HS_ACTIVE / 8  ;  

    reg [11:0]      h_cnt         ; // ��ʱ�������
    reg [11:0]      v_cnt         ; // ��ʱ�������

    wire            active        ; // �����־��������ź�Ϊ1ʱRGB�����ݿ�����ʾ����Ļ��
    wire [11:0] x;
    wire [11:0] y;//����
    
    wire    [15:0]  rom_data      ; // ROM�д洢������
    
    parameter      IMAGE_WIDTH       =   640     ,
                    IMAGE_HEIGHT      =   320     ,
                    IMAGE_PIX_NUM     =   204800  ;
//////////////////////////////////////////////////////////////////
// ���ܣ�������ʱ��
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
// ���ܣ�������ʱ��
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
// ������Ч�����־��������ź�Ϊ��ʱ��RGB�͵����ݲŻ���ʾ����Ļ��
////////////////////////////////////////////////////////////////// 
    assign active =     (h_cnt >= (HS_SYNC + HS_BACK            ))  &&
                        (h_cnt <= (HS_SYNC + HS_BACK + HS_ACTIVE))  && 
                        (v_cnt >= (VS_SYNC + VS_BACK            ))  &&
                        (v_cnt <= (VS_SYNC + VS_BACK + HS_ACTIVE))  ;  
    
                       
endmodule
//////////////////////////////////////////////////////////////////
// ���ܣ���ROM�����ͼƬ�������
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
                    O_red       <= rom_data[15:12]    ; // ��ɫ����
                    O_green     <= rom_data[10:7]     ; // ��ɫ����
                    O_blue      <= rom_data[4:1]      ; // ��ɫ����
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
// ���ܣ�����ʾ����Ļ�ֳ�8�����У�ÿ�����еĿ����80
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
                 if(h_cnt < (HS_SYNC + HS_BACK + COLOR_BAR_WIDTH)) // ��ɫ����
                begin
                    O_red   <=  5'b11111    ; // ��ɫ�����Ѻ�ɫ����ȫ����1����ɫ����ɫ��0
                    O_green <=  6'b000000   ;
                    O_blue  <=  5'b00000    ;
                end
            else if(h_cnt < (HS_SYNC + HS_BACK + COLOR_BAR_WIDTH*2)) // ��ɫ����
                begin
                    O_red   <=  5'b00000    ;
                    O_green <=  6'b111111   ; // ��ɫ��������ɫ����ȫ����1����ɫ����ɫ������0
                    O_blue  <=  5'b00000    ;
                end 
            else if(h_cnt < (HS_SYNC + HS_BACK + COLOR_BAR_WIDTH*3)) // ��ɫ����
                begin
                    O_red   <=  5'b00000    ;
                    O_green <=  6'b000000   ;
                    O_blue  <=  5'b11111    ; // ��ɫ��������ɫ����ȫ����1����ɫ���̷�����0
                end 
            else if(h_cnt < (HS_SYNC + HS_BACK + COLOR_BAR_WIDTH*4)) // ��ɫ����
                begin
                    O_red   <=  5'b11111    ; // ��ɫ�������к���������ɫ��϶���
                    O_green <=  6'b111111   ; // ���԰�ɫ����Ҫ�Ѻ�������������ȫ����1
                    O_blue  <=  5'b11111    ;
                end 
            else if(h_cnt < (HS_SYNC + HS_BACK + COLOR_BAR_WIDTH*5)) // ��ɫ����
                begin
                    O_red   <=  5'b00000    ; // ��ɫ�������ǰѺ��������з���ȫ����0
                    O_green <=  6'b000000   ;
                    O_blue  <=  5'b00000    ;
                end 
            else if(h_cnt < (HS_SYNC + HS_BACK + COLOR_BAR_WIDTH*6)) // ��ɫ����
                begin
                    O_red   <=  5'b11111    ; // ��ɫ�������к���������ɫ��϶���
                    O_green <=  6'b111111   ; // ���Ի�ɫ����Ҫ�Ѻ�������������1
                    O_blue  <=  5'b00000    ; // ��ɫ������0
                end 
            else if(h_cnt < (HS_SYNC + HS_BACK + COLOR_BAR_WIDTH*7)) // ��ɫ����
                begin
                    O_red   <=  5'b11111    ; // ��ɫ�������к���������ɫ��϶���
                    O_green <=  6'b000000   ; // ������ɫ����Ҫ�Ѻ�������������1
                    O_blue  <=  5'b11111    ; // ��ɫ������0
                end 
            else                              // ��ɫ����
                begin
                    O_red   <=  5'b00000    ; // ��ɫ������������������ɫ��϶���
                    O_green <=  6'b111111   ; // ������ɫ����Ҫ����������������1
                    O_blue  <=  5'b11111    ; // ��ɫ������0
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
