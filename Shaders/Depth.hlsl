#include "Common.hlsl"

StructuredBuffer<ObjectContants> object_data : register(t0);
StructuredBuffer<PassContants> pass_data : register(t1);

DepthVertexOut DepthVS(VertexIn vin, out float4 pos_h : SV_POSITION)
{
	DepthVertexOut vout = (DepthVertexOut)0.0f;

    float4 posW = mul(float4(vin.PosL, 1.0f), object_data[0].gWorld);
    vout.PosH = mul(posW, pass_data[0].gViewProj);
    pos_h = vout.PosH;

    return vout;
}

float DepthPS(DepthVertexOut pin) : SV_TARGET
{
    return pin.PosH.z / pin.PosH.w;
}

