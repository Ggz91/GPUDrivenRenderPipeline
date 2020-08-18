#include <windows.h>
#include "Interface/VoidEngineInterface.h"
#include <iostream>
#include "Modules/FBXUtil/FBXWrapper.h"
#include "Modules/App/App.h"
#include "Modules/Common/d3dUtil.h"

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE prevInstance,
	PSTR cmdLine, int showCmd)
{
#if defined(DEBUG) | defined(_DEBUG)
	_CrtSetDbgFlag(_CRTDBG_ALLOC_MEM_DF | _CRTDBG_LEAK_CHECK_DF);
#endif
	App theApp(hInstance);
	try
	{
		if (!theApp.Initialize())
			return 0;

		return theApp.Run();
	}
	catch (DxException& e)
	{
		theApp.Debug();
		MessageBox(nullptr, e.ToString().c_str(), L"HR Failed", MB_OK);
		return 0;
	}
}