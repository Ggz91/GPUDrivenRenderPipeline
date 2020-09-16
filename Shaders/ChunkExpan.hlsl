#include "Common.hlsl"

#ifndef BufferThreadSize
    #define BufferThreadSize 128
#endif



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

StructuredBuffer<InstanceChunk> input_buffer : register(t0);
StructuredBuffer<ObjectContants> object_data : register(t1);
AppendStructuredBuffer<ClusterChunk> output_buffer : register(u0);

[numthreads(BufferThreadSize, 1, 1)]
void ChunkExpan(uint3 thread_id : SV_DISPATCHTHREADID)
{

}