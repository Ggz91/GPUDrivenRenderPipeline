#include "Common.hlsl"

struct VertexIn
{
	float3 PosL    : POSITION;
    float3 NormalL : NORMAL;
	float2 TexC    : TEXCOORD;
	float3 TangentL : TANGENT;
};

struct DeferredVertexOut
{
	float4 PosH    : SV_POSITION;
    float3 NormalW : NORMAL;
	float2 TexC    : TEXCOORD;
};

struct DeferredPixelOut
{
   float4 Normal_UV: SV_Target0;
   uint Mat_ID: SV_Target1;
};


DeferredVertexOut DeferredVS(VertexIn vin)
{
	DeferredVertexOut vout = (DeferredVertexOut)0.0f;

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

DeferredPixelOut DeferredPS(DeferredVertexOut pin)
{
    DeferredPixelOut res;
    res.Normal_UV.x = pin.NormalW.x;
    res.Normal_UV.y = pin.NormalW.y;
    res.Normal_UV.z = pin.TexC.x;
    res.Normal_UV.a = pin.TexC.y;
    res.Mat_ID = gMaterialIndex;
    return res;
}


