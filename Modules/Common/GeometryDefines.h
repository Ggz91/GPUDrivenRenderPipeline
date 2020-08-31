#pragma once

#include <windows.h>
#include "MathHelper.h"

// Simple struct to represent a material for our demos.  A production 3D engine
// would likely create a class hierarchy of Materials.
struct Material
{
	// Unique material name for lookup.
	std::string Name;

	// Index into constant buffer corresponding to this material.
	int MatCBIndex = -1;

	std::string DiffuseMapPath = "";
	// Index into SRV heap for diffuse texture.
	int DiffuseSrvHeapIndex = -1;

	std::string NormalMapPath = "";
	// Index into SRV heap for normal texture.
	int NormalSrvHeapIndex = -1;

	// Dirty flag indicating the material has changed and we need to update the constant buffer.
	// Because we have a material constant buffer for each FrameResource, we have to apply the
	// update to each FrameResource.  Thus, when we modify a material we should set 
	// NumFramesDirty = gNumFrameResources so that each frame resource gets the update.
	int NumFramesDirty = 3;

	// Material constant buffer data used for shading.
	DirectX::XMFLOAT4 DiffuseAlbedo = { 1.0f, 1.0f, 1.0f, 1.0f };
	DirectX::XMFLOAT3 FresnelR0 = { 0.01f, 0.01f, 0.01f };
	float Roughness = .25f;
	DirectX::XMFLOAT4X4 MatTransform = MathHelper::Identity4x4();
};

struct MatData
{
	DirectX::XMFLOAT4   DiffuseAlbedo;
	DirectX::XMFLOAT3   FresnelR0;
	float    Roughness;
	DirectX::XMFLOAT4X4 MatTransform;
	UINT     DiffuseMapIndex;
	UINT     NormalMapIndex;
	UINT     MatPad1;
	UINT     MatPad2;
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
	std::vector<std::uint16_t> Indices;
};

struct  AABB
{
	DirectX::XMFLOAT3 MinVertex;
	DirectX::XMFLOAT3 MaxVertex;
};

struct ObjectData
{
	MeshData Mesh;
	Material Mat;
	DirectX::XMFLOAT4X4 World = MathHelper::Identity4x4();
	AABB Bounds;

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