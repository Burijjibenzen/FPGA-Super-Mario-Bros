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
    input  clk   ,     // ʱ��
    input  rst   ,     // ��λ,�͵�ƽ��Ч
    input  [7:0] view, // ������ǰ����Ұλ��
	//output [8:0] row_addr, // pixel ram row address, 320 (512) lines
	//output [9:0] col_addr, // pixel ram col address, 640 (1024) pixels
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
    
    parameter      IMAGE_WIDTH       =   1280    ,
                    IMAGE_HEIGHT      =   896     ,
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
////////////////////////////////////////////////////////////////// 

	parameter TOTAL_ELEMENTS = 14 * 212;  //  ������ͼ��Ԫ�ظ������������
	reg  [11:0]         rom_addr_map; // ��ŵ�ͼ��rom��ַ
    wire [5:0]                typeid; // Ԫ�ص�id
    wire [11:0]      map_addr_offset; // ��ͼƫ�Ƶ�ַ
    wire [17:0]     rom_addr_sprites; // ���Ԫ�ص�rom��ַ
    wire [17:0]  sprites_addr_offset; // Ԫ��ƫ�Ƶ�ַ
    wire [15:0]         sprites_data; // Ԫ�ص�rgb��Ϣ
    reg  [4:0]               map_row; // ��ǰ��ʾ��ͼ����Ϊ��ǰ��ͼ�ĵڼ���
    reg  [4:0]               map_col; // ��ǰ��ʾ��ͼ����Ϊ��ǰ��ͼ�ĵڼ���
    reg  [5:0]           sprites_row; // ��ǰ��ʾ����Ϊ��ǰԪ�صĵڼ���
    reg  [5:0]           sprites_col; // ��ǰ��ʾ����Ϊ��ǰԪ�صĵڼ���
    
    assign map_addr_offset     = rom_addr_map     + 212 * map_row     + map_col; // ��ǰ�ĵ�ͼ��Ԫ��λ��
    assign sprites_addr_offset = rom_addr_sprites + 640 * sprites_row + sprites_col; // ��ǰ������λ��
    assign x = (active) ? h_cnt - (HS_SYNC + HS_BACK):0;
    assign y = (active) ? v_cnt - (VS_SYNC + VS_BACK):0; //��ǰVGA����ʾ��������VGA�ϵ�λ��
    
	blk_mem_gen_map map(
	    .clka(clk),              // input clka
        .addra(map_addr_offset), // input [11 : 0] addra
        .douta(typeid)           // output [5 : 0] douta
    );	
    
    Object object(
        .id(typeid),  
        .addr(rom_addr_sprites)
    );
    
    blk_mem_gen_0 sprites(
        .clka(clk),                  // input clka
        .addra(sprites_addr_offset), // input [17 : 0] addra
        .douta(sprites_data)         // output [15 : 0] douta
    );
    
    always @(posedge clk or negedge rst)
    begin
        if(!rst) 
        begin
            rom_addr_map  <=  12'd0 ;
                  map_row <=   5'd0 ;
                  map_col <=   5'd0 ;
              sprites_row <=   6'd0 ;
              sprites_col <=   6'd0 ;
        end
        else if(active)     
        begin
            if(h_cnt >= (HS_SYNC + HS_BACK                      )  && 
               h_cnt <= (HS_SYNC + HS_BACK + IMAGE_WIDTH  - 1'b1)  &&
               v_cnt >= (VS_SYNC + VS_BACK                 )  && 
               v_cnt <= (VS_SYNC + VS_BACK + IMAGE_HEIGHT - 1'b1)  )
            begin
                rom_addr_map <= view - 12'd10;
                sprites_row <=  y % 64;
                sprites_col <=  (x - 2) % 64; // ��������ë��
                map_row <= y / 64;
                map_col <= x / 64;
                O_red       <=  sprites_data[15:12];
                O_green     <=  sprites_data[10:7];
                O_blue      <=  sprites_data[4:1];
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
	
endmodule