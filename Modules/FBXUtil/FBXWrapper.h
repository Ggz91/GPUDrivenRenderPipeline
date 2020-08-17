/*
	FBX的功能类，对针对FBX的一系列操作进行封装
*/

#pragma once

#include <fbxsdk.h>
#include <fbxsdk/fileio/fbxiosettings.h>
#include <algorithm>
#include <iostream>
#include <unordered_map>
#include <vector>
#include "../Common/ResLoadCommon.h"
#include "../Geometry/GeometryDefines.h"

GRPAppBegin
struct ObjectData;

class FBXWrapper
{
public:
	FBXWrapper();
	~FBXWrapper();

	/*
		单例
	*/
	static FBXWrapper* Instance();
	ResLoadStatus LoadScene(std::string file_name, std::vector<std::unique_ptr<ObjectData>>& object_datas);
private:
	/*
		初始化
	*/
	void Init();
private:
	FbxManager* m_manager;
	FbxIOSettings* m_io_settings;

	static FBXWrapper* m_instance;

	std::unordered_map<std::string, FbxScene*> m_loaded_scenes;
};

#define FBXWrapperInstance FBXWrapper::Instance()

GRPAppEnd