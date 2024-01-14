#define _CRT_SECURE_NO_WARNINGS
#include<stdio.h>
#include<stdlib.h>
#include<string.h>

typedef unsigned char BYTE;
typedef unsigned short WORD;
typedef unsigned int DWORD;
typedef unsigned long	LDWORD;
typedef long LONG;

#pragma pack(1)/* �����ڽṹ�嶨��֮ǰʹ��,����Ϊ���ýṹ���и���Ա��1�ֽڶ���*/
typedef struct tagBITMAPFILEHEADER
{
	WORD bfType; //����ͼƬ���͡� 'BM'
	DWORD bfSize; //λͼ�ļ��Ĵ�С�����ֽ�Ϊ��λ��3-6�ֽڣ���λ��ǰ��
	WORD bfReserved1;//λͼ�ļ������֣�����Ϊ0(7-8�ֽڣ�
	WORD bfReserved2;//λͼ�ļ������֣�����Ϊ0(9-10�ֽڣ� 
	DWORD bfOffBits;   //RGB����ƫ�Ƶ�ַ,λͼ���ݵ���ʼλ�ã��������λͼ��11-14�ֽڣ���λ��ǰ��
}BITMAPFILEHEADER;

typedef struct tagBITMAPINFOHEADER
{
	DWORD biSize;	//���ṹ��ռ���ֽ�����15-18�ֽڣ�
	DWORD biWidth;	//λͼ�Ŀ�ȣ�������Ϊ��λ��19-22�ֽڣ�
	DWORD biHeight;	//λͼ�ĸ߶ȣ�������Ϊ��λ��23-26�ֽڣ�
	WORD biPlanes;	//Ŀ���豸�ļ��𣬱���Ϊ1(27-28�ֽڣ�
	WORD biBitCount;	//ÿ�����������λ����������1��˫ɫ����29-30�ֽڣ�,4(16ɫ����8(256ɫ��16(�߲�ɫ)��24�����ɫ��֮һ

	DWORD biCompression;//λͼѹ�����ͣ�������0����ѹ��������31-34�ֽڣ�
	//1(BI_RLE8ѹ�����ͣ���2(BI_RLE4ѹ�����ͣ�֮һ

	DWORD biSizeImage;	//λͼ�Ĵ�С(���а�����Ϊ�˲���������4�ı�������ӵĿ��ֽ�)�����ֽ�Ϊ��λ��35-38�ֽڣ�

	DWORD biXPelsPerMeter;//λͼˮƽ�ֱ��ʣ�ÿ����������39-42�ֽڣ�
	DWORD biYPelsPerMeter;//λͼ��ֱ�ֱ��ʣ�ÿ����������43-46�ֽ�)
	DWORD biClrUsed;	//λͼʵ��ʹ�õ���ɫ���е���ɫ����47-50�ֽڣ�
	DWORD biClrImportant;	//λͼ��ʾ��������Ҫ����ɫ����51-54�ֽڣ�
}BITMAPINFOHEADER;

/*
 �������ƣ�Bmp_Smaller
 �������ܣ�ͼƬ�Ŵ���С
 ����    ��old_bmp_path,new_bmp_path
 ����ֵ  ��0	ok
		   1	fail
 ����    ��zhoubing
 �޸�ʱ�䣺20190808
 */
int Bmp_Bigger_And_Smaller(const char* old_bmp_path, const char* new_bmp_path)
{

	//����ԭ��Ƭ��Ϣ�ṹ��
	BITMAPFILEHEADER head;
	BITMAPINFOHEADER info;

	//���ṹ�����
	memset(&head, 0, sizeof(BITMAPFILEHEADER));
	memset(&info, 0, sizeof(BITMAPINFOHEADER));

	FILE* fpr1 = fopen(old_bmp_path, "rb");
	FILE* fpw2 = fopen(new_bmp_path, "wb");


	if (fpr1 == NULL || fpw2 == NULL)
	{
		printf("ͼƬ��ʧ��!\n");
		return -1;
	}
	//��ȡԭ��Ƭ��ͷ��Ϣ
	fread(&head, sizeof(BITMAPFILEHEADER), 1, fpr1);
	fread(&info, sizeof(BITMAPINFOHEADER), 1, fpr1);

	unsigned int old_width = info.biWidth;//��ȡԭͼƬ�Ŀ�
	unsigned int old_height = info.biHeight;//��ȡԭͼƬ�ĸ�

	//��ȡԭͼƬ��λͼ����
	unsigned char* src_data = (unsigned char*)malloc(old_width * old_height * 3);
	fseek(fpr1, 54, SEEK_SET);
	fread(src_data, old_width * old_height * 3, 1, fpr1);

	printf("ԭͼƬ�Ŀ�:%d\n", old_width);
	printf("ԭͼƬ�ĸ�:%d\n", old_height);

	//�޸�ԭ��Ƭ�Ŀ��
	unsigned int new_Width, new_Height;
	printf("��������ͼƬ�Ŀ�:\n");
	scanf("%d", &new_Width);
	printf("��������ͼƬ�ĸ�:\n");
	scanf("%d", &new_Height);


	head.bfSize = new_Width * new_Height * 3 + 54;
	info.biWidth = new_Width;
	info.biHeight = new_Height;

	//���޸Ĺ���ͷ��Ϣд������Ƭ
	fwrite(&head, sizeof(BITMAPFILEHEADER), 1, fpw2);
	fwrite(&info, sizeof(BITMAPINFOHEADER), 1, fpw2);

	int i = 0, j = 0;
	unsigned long dwsrcX, dwsrcY;
	unsigned char* pucDest;
	unsigned char* pucSrc;
	unsigned char* dest_data = (unsigned char*)malloc(new_Width * new_Height * 3);

	for (i = 0; i < new_Height; i++)
	{
		dwsrcY = i * old_height / new_Height;
		pucDest = dest_data + i * new_Width * 3;
		pucSrc = src_data + dwsrcY * old_width * 3;
		for (j = 0; j < new_Width; j++)
		{
			dwsrcX = j * old_width / new_Width;
			memcpy(pucDest + j * 3, pucSrc + dwsrcX * 3, 3);//���ݿ���
		}
	}
	fseek(fpw2, 54, SEEK_SET);
	fwrite(dest_data, new_Width * new_Height * 3, 1, fpw2);
	printf("������ͼƬ�ɹ�!\n");

	//�ͷŶѿռ�
	free(dest_data);
	free(src_data);

	//�ر��ļ�
	fclose(fpr1);
	fclose(fpw2);

	return 0;
}

/*
 �������ƣ�main
 �������ܣ�������
 ������void
 ����ֵ��int
 */
int main()
{
	Bmp_Bigger_And_Smaller("sprites.bmp", "new_scale.bmp");
	return 0;
}