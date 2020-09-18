//***************************************************************************************
// Common.hlsl by Frank Luna (C) 2015 All Rights Reserved.
//***************************************************************************************

// Defaults for number of lights.
#ifndef NUM_DIR_LIGHTS
    #define NUM_DIR_LIGHTS 3
#endif

#ifndef NUM_POINT_LIGHTS
    #define NUM_POINT_LIGHTS 0
#endif

#ifndef NUM_SPOT_LIGHTS
    #define NUM_SPOT_LIGHTS 0
#endif

#ifndef BufferThreadSize
    #define BufferThreadSize 128
#endif

#ifndef VertexPerCluster
    #define VertexPerCluster 64
#endif

#ifndef ClusterPerChunk
    #define ClusterPerChunk 8
#endif

#ifndef MaxVertexNumPerInstance
    #define MaxVertexNumPerInstance 2000
#endif

static const uint MaxVertexNumPerChunk = ClusterPerChunk * VertexPerCluster;
static const uint MaxChunkNumPerInstance = MaxVertexNumPerInstance / MaxVertexNumPerChunk;

#include "LightingUtil.hlsl"

SamplerState gsamPointWrap        : register(s0);
SamplerState gsamPointClamp       : register(s1);
SamplerState gsamLinearWrap       : register(s2);
SamplerState gsamLinearClamp      : register(s3);
SamplerState gsamAnisotropicWrap  : register(s4);
SamplerState gsamAnisotropicClamp : register(s5);
SamplerComparisonState gsamShadow : register(s6);

struct AABB
{
    float3 MinVertex;
    float3 MaxVertex;
};

struct MaterialData
{
	float4   DiffuseAlbedo;
	float3   FresnelR0;
	float    Roughness;
	float4x4 MatTransform;
	uint     DiffuseMapIndex;
	uint     NormalMapIndex;
	uint     MatPad1;
	uint     MatPad2;
};

struct VertexIn
{
	float3 PosL    : POSITION;
    float3 NormalL : NORMAL;
	float2 TexC    : TEXCOORD;
	float3 TangentL : TANGENT;
};

struct VertexOut
{
	float4 PosH    : SV_POSITION;
    float3 PosW    : POSITION2;
    float3 NormalW : NORMAL;
	float3 TangentW : TANGENT;
	float2 TexC    : TEXCOORD;
};

struct DepthVertexOut
{
    float4 PosH : POSITION1;
};

struct DeferredGSVertexOut
{
	float4 PosH    : SV_POSITION;
    float3 NormalW : NORMAL;
	float3 TangentW : TANGENT;
	float2 TexC    : TEXCOORD;
};

struct DeferredGSPixelOut
{
   uint4 Normal_UV_Depth: SV_Target0;
   uint Mat_ID: SV_Target1;
};

struct DeferredShadingVertexOut
{
	float4 PosH    : SV_POSITION;
	float2 TexC    : TEXCOORD;
};

struct IndirectCommand
{
    uint2 ObjCbv;
    uint2 PassCbv;
	uint4 DrawArguments;
    uint DrawArgumentsEx;
};

struct ObjectContants
{
    float4x4 gWorld;
	float4x4 gTexTransform;
    AABB Bounds;
    IndirectCommand DrawCommand;
	uint gMaterialIndex;
    uint IndexOffset;
};

struct InstanceChunk
{
    uint InstanceID;
    uint ChunkID;
};

struct PassContants
{
    float4x4 gView;
    float4x4 gInvView;
    float4x4 gProj;
    float4x4 gInvProj;
    float4x4 gViewProj;
    float4x4 gInvViewProj;
    float4x4 gViewProjTex;
    float4x4 gShadowTransform;
    float3 gEyePosW;
    float cbPerObjectPad1;
    float2 gRenderTargetSize;
    float2 gInvRenderTargetSize;
    float gNearZ;
    float gFarZ;
    float gTotalTime;
    float gDeltaTime;
    float4 gAmbientLight;
    uint gObjectNum;

    // Indices [0, NUM_DIR_LIGHTS) are directional lights;
    // indices [NUM_DIR_LIGHTS, NUM_DIR_LIGHTS+NUM_POINT_LIGHTS) are point lights;
    // indices [NUM_DIR_LIGHTS+NUM_POINT_LIGHTS, NUM_DIR_LIGHTS+NUM_POINT_LIGHT+NUM_SPOT_LIGHTS)
    // are spot lights for a maximum of MaxLights per object.
    Light gLights[MaxLights];
};

struct ClusterChunk
{
    uint InstanceID;
    uint ClusterID;
};

//---------------------------------------------------------------------------------------
// Transforms a normal map sample to world space.
//---------------------------------------------------------------------------------------
float3 NormalSampleToWorldSpace(float3 normalMapSample, float3 unitNormalW, float3 tangentW)
{
	// Uncompress each component from [0,1] to [-1,1].
	float3 normalT = 2.0f*normalMapSample - 1.0f;

	// Build orthonormal basis.
	float3 N = unitNormalW;
	float3 T = normalize(tangentW - dot(tangentW, N)*N);
	float3 B = cross(N, T);

	float3x3 TBN = float3x3(T, B, N);

	// Transform from tangent space to world space.
	float3 bumpedNormalW = mul(normalT, TBN);

	return bumpedNormalW;
}

//---------------------------------------------------------------------------------------
// PCF for shadow mapping.
//---------------------------------------------------------------------------------------
//#define SMAP_SIZE = (2048.0f)
//#define SMAP_DX = (1.0f / SMAP_SIZE)
/*float CalcShadowFactor(float4 shadowPosH)
{
    // Complete projection by doing division by w.
    shadowPosH.xyz /= shadowPosH.w;

    // Depth in NDC space.
    float depth = shadowPosH.z;

    uint width, height, numMips;
    gShadowMap.GetDimensions(0, width, height, numMips);

    // Texel size.
    float dx = 1.0f / (float)width;

    float percentLit = 0.0f;
    const float2 offsets[9] =
    {
        float2(-dx,  -dx), float2(0.0f,  -dx), float2(dx,  -dx),
        float2(-dx, 0.0f), float2(0.0f, 0.0f), float2(dx, 0.0f),
        float2(-dx,  +dx), float2(0.0f,  +dx), float2(dx,  +dx)
    };

    [unroll]
    for(int i = 0; i < 9; ++i)
    {
        percentLit += gShadowMap.SampleCmpLevelZero(gsamShadow,
            shadowPosH.xy + offsets[i], depth).r;
    }
    
    return percentLit / 9.0f;
}*/

#define TWO_15_POWER 32768
#define TWO_16_POWER 65536

float4 UnpackNormal(float2 normal)
{
    float denom = 2 / (1 + normal.x * normal.x + normal.y * normal.y);
    float4 res;
    res.x = normal.x * denom;
    res.y = normal.y * denom;
    res.z = denom - 1;
    res.w = 1;
    return res;
}

uint CodeNormal(float3 normal)
{
    float x = normal.x / (1 + normal.z);
    float y = normal.y / (1 + normal.z);
    uint normal_x = (uint)(abs(x) * TWO_15_POWER) << 16 + (1 << 31);
    normal_x &= x < 0 ? 0xffff0000 : 0x7fff0000; 
    uint normal_y = (uint)(abs(y) * TWO_15_POWER)  + (1 << 15);
    normal_y &= y < 0 ? 0x0000ffff : 0x00007fff;
    return (normal_x + normal_y);
}

float2 DecodeNormal(uint code_normal)
{
    uint normal_x = code_normal & 0x7fff0000;
    uint normal_y = code_normal & 0x00007fff;
    float2 res;
    res.x = (normal_x >> 16) * 1.0f/ TWO_15_POWER;
    res.y = (normal_y) * 1.0f / TWO_15_POWER;
    res.x *= ((code_normal & (1 << 31)) <=0 ? 1 : -1);
    res.y *= ((code_normal & (1 << 15)) <=0 ? 1 : -1);
    return res;
}

uint CodeUV(float2 uv)
{
    //把uv坐标变换到[0,1]范围内，不考虑正负
    if(uv.x < 0)
    {
        uv.x = 1 + frac(uv.x);
    }
    if(uv.y < 0)
    {
        uv.y = 1+ frac(uv.y);
    }
    uint uv_x = (uint)(abs(frac(uv.x)) * TWO_16_POWER) << 16 ;
    uint uv_y = (uint)(abs(frac(uv.y)) * TWO_16_POWER) ;
    return (uv_x + uv_y);
}

float2 DecodeUV(uint uint_uv)
{
    float2 res;
    res.x = ((uint_uv & 0xffff0000) >> 16) * 1.0f / TWO_16_POWER;
    res.y = (uint_uv & 0x0000ffff) * 1.0f / TWO_16_POWER;
    return res;
}

uint CodeDepth(float depth)
{
    return (uint)(depth * TWO_16_POWER); 
}

float DecodeDepth(uint depth)
{
    float frac = depth * 1.0f / TWO_16_POWER;
    return frac;
}
