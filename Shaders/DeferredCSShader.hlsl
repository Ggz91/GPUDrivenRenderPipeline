#include "Common.hlsl"

Texture2D g_buffer0            : register(t0);
Texture2D g_buffer1        : register(t1);
StructuredBuffer<MaterialData> mat_data : register(t0, space1);
Texture2D textures[1] : register(t1, space1);
RWTexture2D<float4> g_output : register(u0);


#define CacheSize N

[numthreads(16, 16, 1)]
void Shading(int3 groupThreadID : SV_GroupThreadID,
				int3 dispatchThreadID : SV_DispatchThreadID)
{
    g_output[dispatchThreadID.xy] = float4(1, 1, 1, 1);
}
