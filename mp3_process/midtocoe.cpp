/* 2251206 冯羽芯 计科 */
#include <iostream>
#include <fstream>
#include <iomanip>
using namespace std;

int usage()
{
	cerr << "文件名以下形式均可以:" << endl;
	cerr << "    " << "a.txt                     : 不带路径形式" << endl;
	cerr << "    " << "..\\data\\b.dat             : 相对路径形式" << endl;
	cerr << "    " << "C:\\Windows\\System32\\c.dat : 绝对相对路径形式" << endl;

	return 0;
}

int main(int argc, char** argv)
{
	//以二进制方式读取
	usage();
	cerr << "请输入文件名 : ";
	char name[100];
	cin >> name;

	ifstream in(name, ios::in | ios::binary);
	if (in.is_open() == false) {
		cout << "输入文件" << name << "打开失败!" << endl;
		return -1;
	}

	char str[16] = { 0 };
	//先获取文件大小，移动文件指针
	in.seekg(0, ios::end);
	int size = (int)(in.tellg());
	in.seekg(0, ios::beg); // 复原

	cout << "memory_initialization_radix=16;\n";
	cout << "memory_initialization_vector=\n";

	unsigned char ch;
	for (int i = 1; i <= size; i++) {

		ch = in.get();

		cout << setiosflags(ios::uppercase);
		cout << hex << setw(2) << setfill('0') << int(ch);
		cout << setfill(' ');
		cout << resetiosflags(ios::uppercase);

		if (i % 4 == 0)
			cout << ',' << endl;
	}

	in.close();
	return 0;
}