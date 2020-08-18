#include "FBXWrapper.h"
#include <fbxsdk/fileio/fbximporter.h>
#include "spdlog/sinks/stdout_color_sinks.h"
#include "../Common/Common.h"

GRPAppBegin
FBXWrapper* FBXWrapper::m_instance = NULL;

FBXWrapper::FBXWrapper()
{
	Init();
}

FBXWrapper::~FBXWrapper()
{
	m_manager->Destroy();
	m_manager = NULL;


}

FBXWrapper* FBXWrapper::Instance()
{
	if (NULL == m_instance)
	{
		m_instance = new FBXWrapper;
	}
	return m_instance;
}

ResLoadStatus FBXWrapper::LoadScene(std::string file_name, std::vector<std::unique_ptr<ObjectData>>& object_datas)
{
	auto impoter = FbxImporter::Create(m_manager, "");
	bool impoter_status = impoter->Initialize(file_name.c_str(), -1, m_manager->GetIOSettings());
	if (!impoter_status)
	{
		LogError("{} {}", "FBX Importer Init Failed. file name :", file_name.c_str(), "Error code :", impoter->GetStatus().GetErrorString());
		return ResLoadStatus::LS_FAILED;
	}
	
	auto scene = FbxScene::Create(m_manager, "");
	impoter_status = impoter->Import(scene);
	if (!impoter_status)
	{
		LogError("{} {}", "FBX Importer Init Failed. file name :", file_name.c_str(), "Error code :", impoter->GetStatus().GetErrorString());
		return ResLoadStatus::LS_FAILED;
	}
	impoter->Destroy();

	auto root_node = scene->GetRootNode();
	if (NULL == root_node)
	{
		LogError("{} {}","FBX Importer Init Failed. file name :", file_name.c_str(), "root node is null");
		return ResLoadStatus::LS_FAILED;
	}

	for (int i=0; i<root_node->GetChildCount(); ++i)
	{
		auto chid_node = root_node->GetChild(i);
		if (NULL == chid_node || NULL == chid_node->GetNodeAttribute())
		{
			continue;
		}

		auto attr_type = chid_node->GetNodeAttribute()->GetAttributeType();
		if (FbxNodeAttribute::eMesh != attr_type)
		{
			continue;
		}
		auto object_data = std::make_unique<ObjectData>();

		//mesh
		auto mesh = (FbxMesh*)(chid_node->GetNodeAttribute());
		auto vertices = mesh->GetControlPoints();
		for (int j=0; j<mesh->GetPolygonCount(); ++j)
		{
			int vetex_num = mesh->GetPolygonSize(j);
			assert(3 == vetex_num);

			for (int k=0; k<vetex_num; ++k)
			{
				int control_point_index = mesh->GetPolygonVertex(j, k);
				VertexData vertex;
				vertex.Pos.x = (float)vertices[control_point_index].mData[0];
				vertex.Pos.y = (float)vertices[control_point_index].mData[1];
				vertex.Pos.z = (float)vertices[control_point_index].mData[2];
				object_data->Mesh.Vertices.push_back(vertex);
				object_data->Mesh.Indices.push_back(control_point_index);
			}
		}

		//mat
// 		auto mat = (FbxSurfaceMaterial*)(chid_node->GetNodeAttribute());
// 		if (NULL == mat)
// 		{
// 			continue;
// 		}
// 		object_data->Mat.DiffuseAlbedo = mat->sDiffuse;
// 		object_data->Mat.FresnelR0 = mat->sReflection;
// 		object_data->Mat.Roughness = mat->sSpecularFactor;
		object_datas.push_back(std::move(object_data));
	}
	LogInfo("{} {}","FBX Importer Init Sucess. file name :", file_name.c_str());
	return ResLoadStatus::LS_SUCCESS;
}

void FBXWrapper::Init()
{
	m_manager = FbxManager::Create();
	m_io_settings = FbxIOSettings::Create(m_manager, IOSROOT);
	m_manager->SetIOSettings(m_io_settings);
}
GRPAppEnd