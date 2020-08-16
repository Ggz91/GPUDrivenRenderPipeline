#include <windows.h>
#include "Interface/VoidEngine.h"
#include <iostream>
#include "Modules/FBXUtil/FBXWrapper.h"

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE prevInstance,
	PSTR cmdLine, int showCmd)
{
	std::vector<GRPApp::Vertex> vertex;
	GRPApp::FBXWrapperInstance->LoadScene("../Resources/City/Fbx.fbx", &vertex);
	spdlog::get("console")->info("{} {}","Load FBX Vertex Num:", vertex.size());
	system("pause");
}