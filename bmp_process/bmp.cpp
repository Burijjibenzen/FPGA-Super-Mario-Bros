#define _CRT_SECURE_NO_WARNINGS
#include<stdio.h>
#include<stdlib.h>
#include<string.h>

typedef unsigned char BYTE;
typedef unsigned short WORD;
typedef unsigned int DWORD;
typedef unsigned long	LDWORD;
typedef long LONG;

#pragma pack(1)/* 必须在结构体定义之前使用,这是为了让结构体中各成员按1字节对齐*/
typedef struct tagBITMAPFILEHEADER
{
	WORD bfType; //保存图片类型。 'BM'
	DWORD bfSize; //位图文件的大小，以字节为单位（3-6字节，低位在前）
	WORD bfReserved1;//位图文件保留字，必须为0(7-8字节）
	WORD bfReserved2;//位图文件保留字，必须为0(9-10字节） 
	DWORD bfOffBits;   //RGB数据偏移地址,位图数据的起始位置，以相对于位图（11-14字节，低位在前）
}BITMAPFILEHEADER;

typedef struct tagBITMAPINFOHEADER
{
	DWORD biSize;	//本结构所占用字节数（15-18字节）
	DWORD biWidth;	//位图的宽度，以像素为单位（19-22字节）
	DWORD biHeight;	//位图的高度，以像素为单位（23-26字节）
	WORD biPlanes;	//目标设备的级别，必须为1(27-28字节）
	WORD biBitCount;	//每个像素所需的位数，必须是1（双色）（29-30字节）,4(16色），8(256色）16(高彩色)或24（真彩色）之一

	DWORD biCompression;//位图压缩类型，必须是0（不压缩），（31-34字节）
	//1(BI_RLE8压缩类型）或2(BI_RLE4压缩类型）之一

	DWORD biSizeImage;	//位图的大小(其中包含了为了补齐行数是4的倍数而添加的空字节)，以字节为单位（35-38字节）

	DWORD biXPelsPerMeter;//位图水平分辨率，每米像素数（39-42字节）
	DWORD biYPelsPerMeter;//位图垂直分辨率，每米像素数（43-46字节)
	DWORD biClrUsed;	//位图实际使用的颜色表中的颜色数（47-50字节）
	DWORD biClrImportant;	//位图显示过程中重要的颜色数（51-54字节）
}BITMAPINFOHEADER;

/*
 函数名称：Bmp_Smaller
 函数功能：图片放大缩小
 参数    ：old_bmp_path,new_bmp_path
 返回值  ：0	ok
		   1	fail
 作者    ：zhoubing
 修改时间：20190808
 */
int Bmp_Bigger_And_Smaller(const char* old_bmp_path, const char* new_bmp_path)
{

	//定义原照片信息结构体
	BITMAPFILEHEADER head;
	BITMAPINFOHEADER info;

	//将结构体清空
	memset(&head, 0, sizeof(BITMAPFILEHEADER));
	memset(&info, 0, sizeof(BITMAPINFOHEADER));

	FILE* fpr1 = fopen(old_bmp_path, "rb");
	FILE* fpw2 = fopen(new_bmp_path, "wb");


	if (fpr1 == NULL || fpw2 == NULL)
	{
		printf("图片打开失败!\n");
		return -1;
	}
	//读取原照片的头信息
	fread(&head, sizeof(BITMAPFILEHEADER), 1, fpr1);
	fread(&info, sizeof(BITMAPINFOHEADER), 1, fpr1);

	unsigned int old_width = info.biWidth;//获取原图片的宽
	unsigned int old_height = info.biHeight;//获取原图片的高

	//获取原图片的位图数据
	unsigned char* src_data = (unsigned char*)malloc(old_width * old_height * 3);
	fseek(fpr1, 54, SEEK_SET);
	fread(src_data, old_width * old_height * 3, 1, fpr1);

	printf("原图片的宽:%d\n", old_width);
	printf("原图片的高:%d\n", old_height);

	//修改原照片的宽高
	unsigned int new_Width, new_Height;
	printf("请输入新图片的宽:\n");
	scanf("%d", &new_Width);
	printf("请输入新图片的高:\n");
	scanf("%d", &new_Height);


	head.bfSize = new_Width * new_Height * 3 + 54;
	info.biWidth = new_Width;
	info.biHeight = new_Height;

	//将修改过的头信息写进新照片
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
			memcpy(pucDest + j * 3, pucSrc + dwsrcX * 3, 3);//数据拷贝
		}
	}
	fseek(fpw2, 54, SEEK_SET);
	fwrite(dest_data, new_Width * new_Height * 3, 1, fpw2);
	printf("生成新图片成功!\n");

	//释放堆空间
	free(dest_data);
	free(src_data);

	//关闭文件
	fclose(fpr1);
	fclose(fpw2);

	return 0;
}

/*
 函数名称：main
 函数功能：主函数
 参数：void
 返回值：int
 */
int main()
{
	Bmp_Bigger_And_Smaller("sprites.bmp", "new_scale.bmp");
	return 0;
}