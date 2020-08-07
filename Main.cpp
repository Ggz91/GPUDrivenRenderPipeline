#include <windows.h>
#include "Interface/VoidEngine.h"
#include <iostream>

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE prevInstance,
	PSTR cmdLine, int showCmd)
{
	auto test = new Test();
	test->test();
	system("pause");
}