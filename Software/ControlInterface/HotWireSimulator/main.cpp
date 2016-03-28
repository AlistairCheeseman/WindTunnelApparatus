#include <Windows.h>
#include <stdio.h>
#include <tchar.h>
#include <SDKDDKVer.h>


int main()
{
	HANDLE serialHandle;
	CHAR *comPort = "\\\\.\\COM13";
	serialHandle = CreateFile(comPort, GENERIC_WRITE, 0, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);

	// Do some basic settings
	DCB serialParams = { 0 };
	serialParams.DCBlength = sizeof(serialParams);

	GetCommState(serialHandle, &serialParams);
	serialParams.BaudRate = 2000000;
	serialParams.ByteSize = 8;
	serialParams.StopBits = ONESTOPBIT;
	serialParams.Parity = NOPARITY;
	SetCommState(serialHandle, &serialParams);


	DWORD byteswritten;
	byte data[] = {
		0x0F,0xFC }; // 2 bytes payload -  14 bit reading + 2 bits padding
	while (true)
	{
		WriteFile(serialHandle, data, 2, &byteswritten, NULL); // hot wire writes data at FULL speed.
	}
	CloseHandle(serialHandle);
	return 0;
}
