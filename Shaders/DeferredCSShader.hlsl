#include "Common.hlsl"

Texture2D g_buffer0            : register(t0);
Texture2D g_buffer1        : register(t1);
StructuredBuffer<MaterialData> mat_data : register(t0, space1);
Texture2D textures[1] : register(t1, space1);

static const float2 gTexCoords[6] = 
{
	float2(0.0f, 1.0f),
	float2(0.0f, 0.0f),
	float2(1.0f, 0.0f),
	float2(0.0f, 1.0f),
	float2(1.0f, 0.0f),
	float2(1.0f, 1.0f)
};

DeferredGSVertexOut ShadingVS(VertexIn input, uint vid : SV_VertexID)
{
    DeferredGSVertexOut vout = (DeferredGSVertexOut)0.0f;
	
	vout.TexC = gTexCoords[vid];
	
	// Map [0,1]^2 to NDC space.
	vout.PosH = float4(2.0f*vout.TexC.x - 1.0f, 1.0f - 2.0f*vout.TexC.y, 0.0f, 1.0f);

    return vout;
}

float4 ShadingPS(DeferredGSVertexOut input) : SV_TARGET0
{
    return float4(1.0f, 1.0f, 0.0f, 1.0f);
}
