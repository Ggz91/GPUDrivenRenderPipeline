#pragma once

#include <vector>
#include "../Common/Common.h"

struct ObjectData;
struct RenderItem;

GRPAppBegin

class ObjectDataToRenderItemConverter
{
public:
	ObjectDataToRenderItemConverter(std::vector<std::unique_ptr<ObjectData>>* object_data);
	~ObjectDataToRenderItemConverter();

	std::vector<RenderItem*> Result();
private:
	std::vector<std::unique_ptr<ObjectData>>* m_ptr_objs_data;
};

GRPAppEnd