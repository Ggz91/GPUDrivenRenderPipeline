#pragma once

#include <windows.h>
#include "MathHelper.h"

struct MatData
{
	DirectX::XMFLOAT4 DiffuseAlbedo = { 1.0f, 1.0f, 1.0f, 1.0f };
	DirectX::XMFLOAT3 FresnelR0 = { 0.01f, 0.01f, 0.01f };
	float Roughness = 0.5f;

	// Used in texture mapping.
	DirectX::XMFLOAT4X4 MatTransform = MathHelper::Identity4x4();

	UINT DiffuseMapIndex = 0;
	UINT NormalMapIndex = 0;
	UINT MaterialPad1;
	UINT MaterialPad2;
};

struct VertexData
{
	DirectX::XMFLOAT3 Pos;
	DirectX::XMFLOAT3 Normal;
	DirectX::XMFLOAT2 TexC;
	DirectX::XMFLOAT3 TangentU;
};

struct SkinnedVertex
{
	DirectX::XMFLOAT3 Pos;
	DirectX::XMFLOAT3 Normal;
	DirectX::XMFLOAT2 TexC;
	DirectX::XMFLOAT3 TangentU;
	DirectX::XMFLOAT3 BoneWeights;
	BYTE BoneIndices[4];
};

struct MeshData
{
	std::vector<VertexData> Vertices;
	std::vector<int> Indices;
};

struct ObjectData
{
	MeshData Mesh;
	MatData Mat;

	ObjectData(ObjectData&& r)
	{
		std::swap(Mesh, r.Mesh);
		std::swap(Mat, r.Mat);
	}

	ObjectData& operator=(ObjectData&& r)
	{
		std::swap(Mesh, r.Mesh);
		std::swap(Mat, r.Mat);
		return *this;
	}

	ObjectData()
	{

	}

	ObjectData(ObjectData& r) = delete;
	ObjectData& operator=(const ObjectData& r) = delete;
};