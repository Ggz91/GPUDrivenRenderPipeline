#include "ObjectDataToRenderItemConverter.h"
#include "../Common/RenderItems.h"
#include "../Common/GeometryDefines.h"

GRPAppBegin



ObjectDataToRenderItemConverter::ObjectDataToRenderItemConverter(std::vector<std::unique_ptr<ObjectData>>* object_data)
	: m_ptr_objs_data(object_data)
{

}

void ObjectDataToRenderItemConverter::GetResult(std::vector<RenderItem*>& res, RenderItemClassifyParam& param)
{
	for(int i=0; i<m_ptr_objs_data->size(); ++i)
	{
		auto&& data = m_ptr_objs_data->at(i);
		auto render_item = std::make_unique<RenderItem>();
		render_item->ObjCBIndex = i;
		render_item->IndexCount = data->Mesh.Indices.size();
		render_item->World = data->World;
		render_item->Bounds = data->Bounds;
		render_item->Data = *(data.get());
		render_item->Layer =  Distance(XMFLOAT3(data->World._41, data->World._42, data->World._43), param.EyePos) < param.ThresholdDisctance ? RenderLayer::Occluder : RenderLayer::Opaque;
		res.push_back(render_item.release());
		res.back()->Mat = new Material();
		res.back()->Mat->DiffuseMapPath = data->Mat.DiffuseMapPath;
		res.back()->Mat->NormalMapPath = data->Mat.NormalMapPath;
		res.back()->Mat->Name = data->Mat.Name;
		res.back()->Mat->MatCBIndex = data->Mat.MatCBIndex;
		res.back()->Mat->DiffuseAlbedo = data->Mat.DiffuseAlbedo;
		res.back()->Mat->FresnelR0 = data->Mat.FresnelR0;
		res.back()->Mat->Roughness = data->Mat.Roughness;
		res.back()->Mat->MatTransform = data->Mat.MatTransform;
	}
}

float GRPApp::ObjectDataToRenderItemConverter::Distance(const DirectX::XMFLOAT3& ori, const DirectX::XMFLOAT3& end)
{
	DirectX::XMFLOAT3 delta = DirectX::XMFLOAT3(end.x - ori.x, end.y - ori.y, end.z - ori.z);
	return sqrtf(delta.x * delta.x + delta.y * delta.y + delta.z * delta.z);
}

ObjectDataToRenderItemConverter::~ObjectDataToRenderItemConverter()
{

}

GRPAppEnd