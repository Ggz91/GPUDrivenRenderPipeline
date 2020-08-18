#include "App.h"
#include "../Common/Common.h"
#include "../FBXUtil/FBXWrapper.h"
#include "../Common/RenderItems.h"
#include "../ObjectDataToRenderItemConverter/ObjectDataToRenderItemConverter.h"

GRPAppBegin

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



void App::LoadScene()
{
	std::vector<std::unique_ptr<ObjectData>> objects_data;
	auto res_status = FBXWrapperInstance->LoadScene(m_scene_path, objects_data);
	if (ResLoadStatus::LS_SUCCESS != res_status)
	{
		LogError("Load Scene Failed, file name : {}", m_scene_path);
		return;
	}
	LogInfo(" Load Scene Success, file name : {}", m_scene_path);

	auto converter = std::make_unique<ObjectDataToRenderItemConverter>(&objects_data);
	
	D3DApp::PushModels(converter->Result());
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

	LoadScene();

	return D3DApp::InitResources();
}

GRPAppEnd