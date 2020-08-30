#include "Common.hlsl"

// Constant data that varies per frame.
cbuffer cbPerObject : register(b0)
{
    float4x4 gWorld;
	float4x4 gTexTransform;
	uint gMaterialIndex;
	uint gObjPad0;
	uint gObjPad1;
	uint gObjPad2;
};

// Constant data that varies per material.
cbuffer cbPass : register(b1)
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

    // Indices [0, NUM_DIR_LIGHTS) are directional lights;
    // indices [NUM_DIR_LIGHTS, NUM_DIR_LIGHTS+NUM_POINT_LIGHTS) are point lights;
    // indices [NUM_DIR_LIGHTS+NUM_POINT_LIGHTS, NUM_DIR_LIGHTS+NUM_POINT_LIGHT+NUM_SPOT_LIGHTS)
    // are spot lights for a maximum of MaxLights per object.
    Light gLights[MaxLights];
};

DeferredGSVertexOut DeferredGSVS(VertexIn vin)
{
	DeferredGSVertexOut vout = (DeferredGSVertexOut)0.0f;

    float4 posW = mul(float4(vin.PosL, 1.0f), gWorld);

    vout.NormalW = mul(vin.NormalL, (float3x3)gWorld);
	vout.TangentW = mul(vin.TangentL, (float3x3)gWorld);
    vout.PosH = mul(posW, gViewProj);

	vout.TexC = vin.TexC;

    return vout;
}

DeferredGSPixelOut DeferredGSPS(DeferredGSVertexOut pin)
{
    DeferredGSPixelOut res = (DeferredGSPixelOut) 0;
    res.Normal_UV_Depth.x = CodeNormal(pin.NormalW.xyz);
    res.Normal_UV_Depth.y = CodeNormal(pin.TangentW.xyz);
    res.Normal_UV_Depth.z = CodeUV(pin.TexC);
    res.Normal_UV_Depth.w = CodeDepth(pin.PosH.z);
    res.Mat_ID = gMaterialIndex;
    return res;
}


