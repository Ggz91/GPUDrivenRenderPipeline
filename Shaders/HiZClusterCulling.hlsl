#include "Common.hlsl"

cbuffer PassData : register(b0)
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

    Light gLights[MaxLights];
}

StructuredBuffer<ObjectContants> object_data : register(t0);
Texture2D<float> hiz_tex : register(t1);
StructuredBuffer<VertexIn> vertex_buffer : register(t2);
StructuredBuffer<uint> index_buffer : register(t3);  

ConsumeStructuredBuffer<ClusterChunk> cluster_chunk_data : register(u0);
AppendStructuredBuffer<IndirectCommand> output_buffer : register(u1);

[numthreads(BufferThreadSize, 1, 1)]
void HiZClusterCulling(uint3 thread_id : SV_DISPATCHTHREADID)
{

}