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

	// Fetch the material data.
    // Transform to world space.
    float4 posW = mul(float4(vin.PosL, 1.0f), gWorld);

    // Assumes nonuniform scaling; otherwise, need to use inverse-transpose of world matrix.
    vout.NormalW = mul(vin.NormalL, (float3x3)gWorld);
    // Transform to homogeneous clip space.
    vout.PosH = mul(posW, gViewProj);

	// Output vertex attributes for interpolation across triangle.
	//float4 texC = mul(float4(vin.TexC, 0.0f, 1.0f), gTexTransform);
	//vout.TexC = mul(texC, matData.MatTransform).xy;
	vout.TexC = vin.TexC;

    return vout;
}

DeferredGSPixelOut DeferredGSPS(DeferredGSVertexOut pin)
{
    DeferredGSPixelOut res;
    res.Normal_UV.x = pin.NormalW.x;
    res.Normal_UV.y = pin.NormalW.y;
    res.Normal_UV.z = pin.TexC.x;
    res.Normal_UV.a = pin.TexC.y;
    res.Mat_ID = gMaterialIndex;
    return res;
}


