#pragma once

#include <vector>
#include <DirectXMath.h>
#include "../Common/Common.h"

struct ObjectData;
struct RenderItem;

GRPAppBegin

struct RenderItemClassifyParam
{
	DirectX::XMFLOAT3 EyePos;
	float ThresholdDisctance;
};

class ObjectDataToRenderItemConverter
{
public:
	ObjectDataToRenderItemConverter(std::vector<std::unique_ptr<ObjectData>>* object_data);
	~ObjectDataToRenderItemConverter();

	void GetResult(std::vector<RenderItem*>& res, RenderItemClassifyParam& param);
	float Distance(const DirectX::XMFLOAT3& ori, const DirectX::XMFLOAT3& end);
private:
	std::vector<std::unique_ptr<ObjectData>>* m_ptr_objs_data;
};

GRPAppEnd