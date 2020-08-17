#pragma once

#ifdef __Engine_Export
#define	EngineDLL _declspec(dllexport)
#else
#define	EngineDLL _declspec(dllimport)
#endif __Engine_Export
#include <iostream>
#include <string>

extern "C" class EngineDLL IEngineWrapper
{
public:
	void Init();
	void Update();
	void Draw();

private:
		
};

