#pragma once

#include "../Common/Common.h"
#include "../App/d3dUtil.h"
#include <vector>
#include <windows.h>

using namespace DirectX;

GRPAppBegin

struct VertexData
{
	XMFLOAT3 Pos;
	XMFLOAT3 Normal;
	XMFLOAT2 UV;
};

struct MeshData
{
	std::vector<VertexData> Vertices;
	std::vector<int> Indices;
};

struct  MatData
{
	DirectX::XMFLOAT4 DiffuseAlbedo = { 1.0f, 1.0f, 1.0f, 1.0f };
	DirectX::XMFLOAT3 FresnelR0 = { 0.01f, 0.01f, 0.01f };
	float Roughness = 0.5f;

	DirectX::XMFLOAT4X4 MatTransform = MathHelper::Identity4x4();

	UINT DiffuseMapIndex = 0;
	UINT NormalMapIndex = 0;
	UINT MaterialPad1;
	UINT MaterialPad2;
};

struct ObjectData
{
	MeshData Mesh;
	MatData Mat;
};


GRPAppEnd