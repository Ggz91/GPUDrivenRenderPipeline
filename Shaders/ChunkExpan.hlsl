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

cbuffer Counter : register(b1)
{
    uint g_instance_culling_res_num;
}

StructuredBuffer<InstanceChunk> input_buffer : register(t0);
StructuredBuffer<ObjectContants> object_data : register(t1);
AppendStructuredBuffer<ClusterChunk> output_buffer : register(u0);

[numthreads(BufferThreadSize, 1, 1)]
void ChunkExpan(uint3 thread_id : SV_DISPATCHTHREADID)
{
    if(thread_id.x >= g_instance_culling_res_num)
    {
        return;
    }

    InstanceChunk cur_chunk = input_buffer[thread_id.x];

    //根据chunk的顶点数，划分cluster
    uint instance_vertex_num = object_data[cur_chunk.InstanceID].DrawCommand.DrawArguments.x;
    uint cur_chunk_vertex_offset = cur_chunk.ChunkID * MaxVertexNumPerChunk;
    uint cur_chunk_vertex_num = instance_vertex_num - cur_chunk_vertex_offset;
    uint cluster_num = cur_chunk_vertex_num / VertexPerCluster;
    uint cur_chunk_cluster_offset = cur_chunk.ChunkID * ClusterPerChunk;

    [unroll(ClusterPerChunk)]
    for(uint i=0; i<cluster_num; ++i)
    {
        ClusterChunk cur_cluster = (ClusterChunk) 0.0f;
        cur_cluster.InstanceID = cur_chunk.InstanceID;
        cur_cluster.ClusterID = cur_chunk_cluster_offset + i;
        output_buffer.Append(cur_cluster);
    }
}