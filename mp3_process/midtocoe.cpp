/* 2251206 ����о �ƿ� */
#include <iostream>
#include <fstream>
#include <iomanip>
using namespace std;

int usage()
{
	cerr << "�ļ���������ʽ������:" << endl;
	cerr << "    " << "a.txt                     : ����·����ʽ" << endl;
	cerr << "    " << "..\\data\\b.dat             : ���·����ʽ" << endl;
	cerr << "    " << "C:\\Windows\\System32\\c.dat : �������·����ʽ" << endl;

	return 0;
}

int main(int argc, char** argv)
{
	//�Զ����Ʒ�ʽ��ȡ
	usage();
	cerr << "�������ļ��� : ";
	char name[100];
	cin >> name;

	ifstream in(name, ios::in | ios::binary);
	if (in.is_open() == false) {
		cout << "�����ļ�" << name << "��ʧ��!" << endl;
		return -1;
	}

	char str[16] = { 0 };
	//�Ȼ�ȡ�ļ���С���ƶ��ļ�ָ��
	in.seekg(0, ios::end);
	int size = (int)(in.tellg());
	in.seekg(0, ios::beg); // ��ԭ

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