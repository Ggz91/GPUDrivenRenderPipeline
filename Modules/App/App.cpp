#include "App.h"
#include "../Common/Common.h"
#include "../FBXUtil/FBXWrapper.h"
#include "../Common/RenderItems.h"
#include "../ObjectDataToRenderItemConverter/ObjectDataToRenderItemConverter.h"
#include "../Common/GeometryGenerator.h"
#include "../../Interface/VoidEngineInterface.h"

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

	Material mat;
	mat.Name = "general";
	mat.MatCBIndex = 0;
	mat.DiffuseMapPath = "../Resources/Textures/bricks2.dds";
	mat.NormalMapPath = "../Resources/Textures/bricks2_nmap.dds";
	mat.DiffuseSrvHeapIndex = 0;
	mat.NormalSrvHeapIndex = 1;
	mat.DiffuseAlbedo = XMFLOAT4(1.0f, 1.0f, 1.0f, 1.0f);
	mat.FresnelR0 = XMFLOAT3(0.98f, 0.97f, 0.95f);
	mat.Roughness = 0.8f;

	auto gen = new GeometryGenerator;
	std::vector<std::unique_ptr<ObjectData>> objects_data;
	for (int i = 0; i < 1000; ++i)
	{
		GeometryGenerator::MeshData mesh;
		int type = std::rand() % 4;
		AABB bounds;
		//LogDebug("[App Load Scene] Mesh Type : {}", type );
		switch (type)
		{
		case 0:
		{
			float radius = std::rand() % 100 + 0.01;
			mesh = gen->CreateSphere(radius, 10, 10);
			bounds.MinVertex = XMFLOAT3(-radius, -radius, -radius);
			bounds.MaxVertex = XMFLOAT3(radius, radius, radius);
			break;
		}
		case 1:
		{
			float radius = std::rand() % 100 + 0.01;
			mesh = gen->CreateGeosphere(radius, 3);
			bounds.MinVertex = XMFLOAT3(-radius, -radius, -radius);
			bounds.MaxVertex = XMFLOAT3(radius, radius, radius); break;
		}
		case 2:
		{
			float width = std::rand() % 100 + 0.01;
			float height = std::rand() % 100 + 0.01;
			float depth = std::rand() % 100 + 0.01;
			mesh = gen->CreateBox(width, height, depth, 3);
			bounds.MinVertex = XMFLOAT3(-width / 2, -height / 2, -depth / 2);
			bounds.MaxVertex = XMFLOAT3(width / 2, height / 2, depth / 2);
			break;
		}
		case 3:
		{
			float bottom_radius = std::rand() % 100 + 0.01;
			float top_radius = std::rand() % 100 + 0.01;
			float height = std::rand() % 100 + 0.01;
			mesh = gen->CreateCylinder(bottom_radius, top_radius, height, 20, 20);
			bounds.MinVertex = XMFLOAT3(-bottom_radius, -height/2, -bottom_radius);
			bounds.MaxVertex = XMFLOAT3(bottom_radius, height/2, bottom_radius);
			break;
		}
		default:
			break;
		}
		std::unique_ptr<ObjectData> data = std::make_unique<ObjectData>();
		for (int i = 0; i < mesh.Vertices.size(); ++i)
		{
			VertexData vertex;
			vertex.Pos = mesh.Vertices[i].Position;
			vertex.Normal = mesh.Vertices[i].Normal;
			vertex.TangentU = mesh.Vertices[i].TangentU;
			vertex.TexC = mesh.Vertices[i].TexC;
			data->Mesh.Vertices.push_back(vertex);
		}
		data->Mesh.Indices.insert(data->Mesh.Indices.end(), mesh.GetIndices16().begin(), mesh.GetIndices16().end());
		data->Mat = mat;
		data->Bounds = bounds;
		XMStoreFloat4x4(&data->World, XMMatrixTranslation(std::rand() % 10000 * (std::rand() % 2 ? 1 : -1), std::rand() % 100, -std::rand() % 10000));
		objects_data.push_back(std::move(data));
	}
	
	auto converter = std::make_unique<ObjectDataToRenderItemConverter>(&objects_data);
	D3DApp::PushModels(converter->Result());
}

void App::OnMouseDown(WPARAM btnState, int x, int y)
{
	mLastMousePos.x = x;
	mLastMousePos.y = y;

	SetCapture(mhMainWnd);
}

void App::OnMouseUp(WPARAM btnState, int x, int y)
{
	ReleaseCapture();
}

void App::OnMouseMove(WPARAM btnState, int x, int y)
{
	if ((btnState & MK_LBUTTON) != 0)
	{
		// Make each pixel correspond to a quarter of a degree.
		float dx = XMConvertToRadians(0.25f * static_cast<float>(x - mLastMousePos.x));
		float dy = XMConvertToRadians(0.25f * static_cast<float>(y - mLastMousePos.y));

		m_ptr_engine->PitchCamera(dy);
		m_ptr_engine->RotateCameraY(dx);
	}

	mLastMousePos.x = x;
	mLastMousePos.y = y;
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