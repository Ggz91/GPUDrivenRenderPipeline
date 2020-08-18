#include "App.h"
#include "../Common/Common.h"


App::App(HINSTANCE instance) : D3DApp(instance)
{

}

void App::Update(const GameTimer& gt)
{
	D3DApp::Update(gt);
}

void App::Draw(const GameTimer& gt)
{
	D3DApp::Draw(gt);
}

void App::Debug()
{
	D3DApp::Debug();
}

bool App::Initialize()
{
	if(!D3DApp::Initialize())
	{
		return false;
	}

	return D3DApp::InitResources();
}

