#pragma once

#ifdef __Engine_Export
#define	EngineDLL _declspec(dllexport)
#else
#define	EngineDLL _declspec(dllimport)
#endif __Engine_Export

#include <windows.h>
#include "Modules/Common/GameTimer.h"
#include <vector>

struct RenderItem;

extern "C" class EngineDLL IEngineWrapper
{
public:
	virtual void Init() = 0;
	virtual void Update(const GameTimer& gt) = 0;
	virtual void Draw(const GameTimer& gt) = 0;
	virtual void PushModels(std::vector<RenderItem*>& render_items) = 0;
};

extern "C" EngineDLL IEngineWrapper* GetEngineWrapper(HINSTANCE h_instance, HWND h_wnd);

