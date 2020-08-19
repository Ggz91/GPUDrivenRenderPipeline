#include "App.h"
#include "../Common/Common.h"
#include "../FBXUtil/FBXWrapper.h"
#include "../Common/RenderItems.h"
#include "../ObjectDataToRenderItemConverter/ObjectDataToRenderItemConverter.h"
#include "../Common/GeometryGenerator.h"

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
// 	std::vector<std::unique_ptr<ObjectData>> objects_data;
// 	auto res_status = FBXWrapperInstance->LoadScene(m_scene_path, objects_data);
// 	if (ResLoadStatus::LS_SUCCESS != res_status)
// 	{
// 		LogError("Load Scene Failed, file name : {}", m_scene_path);
// 		return;
// 	}
// 	LogInfo(" Load Scene Success, file name : {}", m_scene_path);
// 
//  	auto converter = std::make_unique<ObjectDataToRenderItemConverter>(&objects_data);
//  	
//  	D3DApp::PushModels(converter->Result());

	auto gen = new GeometryGenerator;
	std::vector<std::unique_ptr<ObjectData>> objects_data;
	for (int i = 0; i < 1000; ++i)
	{
		GeometryGenerator::MeshData mesh;
		int type = std::rand() % 4;
		LogInfo("[App Load Scene] Mesh Type : {}", type );
		switch (type)
		{
		case 2:
			mesh = gen->CreateBox(std::rand()%100, std::rand()%100, std::rand()%100, 3);
			break;
		case 1:
 			mesh = gen->CreateGeosphere(std::rand() % 100, 3);
 			break;
		case 0:
			mesh = gen->CreateSphere(std::rand() % 100, 10, 10);
			break;
		case 3:
			mesh = gen->CreateCylinder(std::rand()%100, std::rand()%100, std::rand()%100, 20, 20);
			break;
		default:
			break;
		}
		std::unique_ptr<ObjectData> data = std::make_unique<ObjectData>();
		for (int i = 0; i < mesh.Vertices.size(); ++i)
		{
			VertexData vertex;
			vertex.Pos = mesh.Vertices[i].Position;
			data->Mesh.Vertices.push_back(vertex);
		}
		data->Mesh.Indices.insert(data->Mesh.Indices.end(), mesh.GetIndices16().begin(), mesh.GetIndices16().end());
		objects_data.push_back(std::move(data));
	}
	
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