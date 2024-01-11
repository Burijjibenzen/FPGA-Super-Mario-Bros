`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/08 01:30:44
// Design Name: 
// Module Name: mp3
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


module mp3(
    input       clk,            //12.288/6MHZʱ��
    input       rst,
    input       play,           //��ʼ����ʼ��������
    input       SO,             //����
    input       DREQ,           //�������󣬸ߵ�ƽʱ�ɴ�������

    output reg  XCS,            //SCI �����дָ��
    output reg  XDCS,           //SDI ��������
    output      SCK,            //ʱ��
    output reg  SI,             //����mp3
    output reg  XRESET         //Ӳ����λ���͵�ƽ��Ч
    );
    parameter  H_RESET     = 4'd0,         //Ӳ��λ
                S_RESET     = 4'd1,         //��λ
                SET_CLOCKF  = 4'd2,         //����ʱ�ӼĴ���
                SET_BASS    = 4'd3,         //���������Ĵ���
                SET_VOL     = 4'd4,         //��������
                WAIT        = 4'd5,         //�ȴ�
                PLAY        = 4'd6,         //����
                END         = 6'd7;         //����
    
    reg [3:0]       state       = WAIT ;            //״̬
    reg [31:0]      cntdown     = 32'd0;            //��ʱ
    reg [31:0]      cmd         = 32'd0;            //ָ����� 
    reg [7:0]       cntData     = 8'd32;            //SCIָ���ַλ������

    reg [31:0]      music_data  = 32'd0;           //��������
    reg [31:0]      cntSended   = 32'd32;          //SDI��ǰ4�ֽ��Ѵ���BIT

    reg  [9:0]      addra       = 10'd0;           //ROM�еĵ�ַ
    wire [31:0]     data;                         //ROM����
 
    reg             ena         = 0;
    
    assign SCK = (clk & ena);
    //�ٶȿ���
    reg [31:0] mp3Speed = 1700000;//�ӳ�

    always @(negedge clk) begin
        if(!rst) begin
            XDCS <= 1'b1;
            ena <= 0;
            SI <= 1'b0;
            XCS <= 1'b1;
            state <= WAIT;
            XRESET <= 1'b1; // Ӳ������λ
            addra <= 17'd0;
            cntSended <= 32'd32;
            music_data <= 32'd0;
        end
        else begin
            case (state)
                /*----------------�ȴ�---------------*/
                WAIT:begin
                        if(cntdown > 0)
                            cntdown <= cntdown - 1'b1;
                        //ת��Ӳ��λ
                        else begin
                            cntdown <= 32'd1000;
                            state <= H_RESET;
                        end
                    end
                /*-----------------Ӳ��------------------*/
                H_RESET:begin
                            if(cntdown > 0)
                                cntdown <= cntdown - 1'b1;
                            else begin
                                XCS <= 1'b1;
                                XRESET <= 1'b0;
                                cntdown <= 32'd16700;               //��λ����ʱһ��ʱ

                                state <= S_RESET;                   //ת�Ƶ���λ
                                cmd <= 32'h02_00_08_04;            //��λָ
                                cntData <= 8'd32;                 //ָ��ء����ݳ���
                            end
                        end
                /*------------------��-----------------*/
                S_RESET:begin
                            if(cntdown > 0) begin
                                XRESET <= (cntdown < 32'd16650);
                                cntdown <= cntdown - 1'b1;
                            end
                            else if(cntData == 0) begin           //��λ��
                                cntdown <= 32'd16600;

                                state <= SET_VOL;                   //ת�Ƶ�����VOL
                                cmd <= 32'h02_0b_00_00;
                                cntData <= 8'd32;

                                XCS <= 1'b1;                        //����XCS
                                ena <= 1'b0;                        //�ر�����ʱ��
                                SI <= 1'b0;
                            end
                            else if(DREQ) begin                     //��DREQ��Чʱ��ʼ��λ
                                XCS <= 1'b0;
                                ena <= 1'b1;
                                SI <= cmd[cntData - 1];
                                cntData <= cntData - 1'b1;
                            end
                        else begin
                                XCS <= 1'b1;                        //DREQ��Чʱ������
                                ena <= 1'b0;
                                SI <= 1'b0;
                        end 
                    end            

                /*----------��������----------*/
                PLAY:begin
                        if(cntdown > 0)
                            cntdown <= cntdown - 1'b1;
                        else if(play)begin
                            XDCS <= 1'b0;
                            ena <= 1'b1;
                            if(cntSended == 0) begin              //����4�ֽ�
                            XDCS <= 1'b1;                   //����XDCS
                            ena <= 1'b0;
                            SI <= 1'b0;
                            cntSended <= 32'd32;
                            music_data <= data;
                            addra <= addra + 1'b1;
                        end
                        else begin
                        //��DREQ��Ч ��ǰ�ֽ���δ������ �������
                            if(DREQ || (cntSended != 32 && cntSended != 24 && cntSended != 16 && cntSended != 8)) begin
                                SI <= music_data[cntSended - 1];
                                cntSended <= cntSended - 1'b1; 
                                ena <= 1;
                                XDCS <= 1'b0;
                            end
                        else begin      //DREQ���ͣ�ֹͣ��
                            ena <= 1'b0;
                            XDCS <= 1'b1;
                            SI <= 1'b0;
                        end
                    end
                end
                else;                                           
                end
                /*---------------------�Ĵ�����------------------*/
                default:
                if(cntdown > 0)
                    cntdown <= cntdown - 1'b1;
                else if(cntData == 0) begin           //������SCIд��
                    if(state == SET_CLOCKF) begin
                        cntdown <= mp3Speed;//32'd1700000;
                        state <= PLAY;
                    end
                    else if(state == SET_BASS) begin
                        cntdown <= 32'd2100;
                        cmd <= 32'h02_03_70_00;
                        state <= SET_CLOCKF;
                    end
                    else begin //SET_VAL
                        cntdown <= 32'd2100;
                        cmd <= 32'h02_02_00_00;
                        state <= SET_BASS;
                    end
                    cntData <= 8'd32;
                    XCS <= 1'b1;
                    ena <= 1'b0;
                    SI <= 1'b0;
                end
                else if(DREQ) begin                     //д��SCIָ��ء���
                    XCS <= 1'b0;
                    ena <= 1'b1;
                    SI <= cmd[cntData - 1];
                    cntData <= cntData - 1'b1;
                end
                else begin                              //DREQ���ͣ���
                    XCS <= 1'b1;
                    ena <= 1'b0;
                    SI <= 1'b0;
                end
            endcase
        end
    end

    blk_mem_gen_maintheme maintheme (
        .clka(clk),             // ʱ��
        .addra(addra),          // ��ַ
        .douta(data)           // �������
    );
 
endmodule

