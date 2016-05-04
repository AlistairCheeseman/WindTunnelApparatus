#include <Windows.h>
#include <stdio.h>
#include <tchar.h>
#include <SDKDDKVer.h>


int main()
{
	HANDLE serialHandle;
	CHAR *comPort = "\\\\.\\COM13"; // variable to hold the port number
	serialHandle = CreateFile(comPort, GENERIC_WRITE, 0, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0); // open the serial port

	// Do some basic settings
	DCB serialParams = { 0 }; // create settings
	serialParams.DCBlength = sizeof(serialParams); // set the length

	GetCommState(serialHandle, &serialParams); // get ptr to the serial settings
	serialParams.BaudRate = 2000000; // 2M baud
	serialParams.ByteSize = 8; // 8 data bits
	serialParams.StopBits = ONESTOPBIT; // one stop bit
	serialParams.Parity = NOPARITY; // no parity bit
	SetCommState(serialHandle, &serialParams); // update th settings


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
