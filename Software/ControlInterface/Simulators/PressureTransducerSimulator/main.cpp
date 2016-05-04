#include <Windows.h>
#include <stdio.h>
#include <tchar.h>
#include <SDKDDKVer.h>


int main()
{
	HANDLE serialHandle;
	CHAR *comPort = "\\\\.\\COM10";// variable to hold the port number
	serialHandle = CreateFile(comPort, GENERIC_WRITE, 0, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0); // open the serial port

	// Do some basic settings
	DCB serialParams = { 0 };
	serialParams.DCBlength = sizeof(serialParams);// set the length

	GetCommState(serialHandle, &serialParams);// get ptr to the serial settings
	serialParams.BaudRate = 2000000; // 2M baud
	serialParams.ByteSize = 8; // 8 data bits
	serialParams.StopBits = ONESTOPBIT; // one stop bit
	serialParams.Parity = NOPARITY; // no parity bit
	SetCommState(serialHandle, &serialParams); // apply the settings

	DWORD byteswritten;
	byte data[] = { // create some sample data to send
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
		WriteFile(serialHandle, data, 61, &byteswritten, NULL); // send the data
		Sleep(2); // wait 2 ms.
		//	Sleep(5);
	}
	CloseHandle(serialHandle); // close the serial port
	return 0;
}
