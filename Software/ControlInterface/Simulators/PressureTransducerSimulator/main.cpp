#include <Windows.h>
#include <stdio.h>
#include <tchar.h>
#include <SDKDDKVer.h>


int main()
{
	HANDLE serialHandle;
	CHAR *comPort = "\\\\.\\COM10";
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

	/*	// Set timeouts
	COMMTIMEOUTS timeout = { 0 };
	timeout.ReadIntervalTimeout = 50;
	timeout.ReadTotalTimeoutConstant = 50;
	timeout.ReadTotalTimeoutMultiplier = 50;
	timeout.WriteTotalTimeoutConstant = 50;
	timeout.WriteTotalTimeoutMultiplier = 10;

	SetCommTimeouts(serialHandle, &timeout);
	*/
	DWORD byteswritten;
	byte data[] = {
		0x01,0x02,0x03,0x04,0x01,0x00,
		0x01,0x02,0x03,0x04,0x02,0x00,
		0x01,0x02,0x03,0x04,0x03,0x00,
		0x01,0x02,0x03,0x04,0x04,0x00,
		0x01,0x02,0x03,0x04,0x05,0x00,
		0x01,0x02,0x03,0x04,0x06,0x00,
		0x01,0x02,0x03,0x04,0x07,0x00,
		0x01,0x02,0x03,0x04,0x08,0x00,
		0x01,0x02,0x03,0x04,0x09,0x00,
		0x01,0x02,0x03,0x04,0x0A,0x00,
		0xFF };
	while (true)
	{
		WriteFile(serialHandle, data, 61, &byteswritten, NULL);
		Sleep(2);
		//	Sleep(5);
	}
	CloseHandle(serialHandle);
	return 0;
}
