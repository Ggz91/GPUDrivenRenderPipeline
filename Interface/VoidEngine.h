#pragma once

#ifdef __Engine_Export
#define	EngineDLLExport _declspec(dllexport)
#else
#define	EngineDLLExport _declspec(dllimport)
#endif __Engine_Export
#include <iostream>
#include <string>

extern "C" class EngineDLLExport Test
{
public:
	Test();
	void test();
};

