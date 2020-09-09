#include "ObjectDataToRenderItemConverter.h"
#include "../Common/RenderItems.h"
#include "../Common/GeometryDefines.h"

GRPAppBegin

ObjectDataToRenderItemConverter::ObjectDataToRenderItemConverter(std::vector<std::unique_ptr<ObjectData>>* object_data)
	: m_ptr_objs_data(object_data)
{

}

void ObjectDataToRenderItemConverter::GetResult(std::vector<RenderItem*>& res)
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

ObjectDataToRenderItemConverter::~ObjectDataToRenderItemConverter()
{

}

GRPAppEnd