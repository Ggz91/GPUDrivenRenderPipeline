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

cbuffer CounterData : register(b1)
{
    uint gChunkCounter;
}

StructuredBuffer<ObjectContants> object_data : register(t0);
Texture2D<float> hiz_tex : register(t1);
StructuredBuffer<VertexIn> vertex_buffer : register(t2);
StructuredBuffer<uint> index_buffer : register(t3);  

ConsumeStructuredBuffer<ClusterChunk> cluster_chunk_data : register(u0);
AppendStructuredBuffer<IndirectCommand> output_buffer : register(u1);

SamplerState g_sampler : register(s0);

[numthreads(BufferThreadSize, 1, 1)]
void HiZClusterCulling(uint3 thread_id : SV_DISPATCHTHREADID)
{
    //1、根据ClusterChunk信息取cluster的顶点信息
    //2、根据cluster的顶点信息确定cluster的bounds
    //3、根据bounds使用跟Instance Culling类似的方法进行cluster culling

    if(thread_id.x >= gChunkCounter)
    {
        return;
    }

    //1、取顶点信息
    ClusterChunk cur_cluster_data =  cluster_chunk_data.Consume();
    ObjectContants cur_obj_data = object_data[cur_cluster_data.InstanceID];
    uint instance_index_count = cur_obj_data.DrawCommand.DrawArguments.x;
    uint index_count_offset = cur_obj_data.DrawCommand.DrawArguments.z + cur_cluster_data.ClusterID * VertexPerCluster * 3;
    uint cur_index_count = instance_index_count - cur_cluster_data.ClusterID * VertexPerCluster * 3;
    uint index_contant_offset = cur_obj_data.DrawCommand.DrawArguments.w;

    //2、确定bounds
    float4x4 local_to_ndc = mul(cur_obj_data.gWorld, gViewProj);
    float min_depth = 1.0f;
    float left = 1.0f;
    float right = 0.0f;
    float top = 0.0f;
    float bottom = 1.0f;
    [unroll(3 * VertexPerCluster)]
    for(uint i=0; i<cur_index_count; ++i)
    {
        uint cur_index_index = index_count_offset + i;
        
        //cpu端index是16位，这里是32位，需要解码
        cur_index_index /= 2;
        uint cur_index = index_buffer[cur_index_index];
        cur_index &= (cur_index_index % 2 == 1) ? 0x0000ffff : 0xffff0000;
        cur_index += index_contant_offset;

        float4 ndc_cor = mul(float4(vertex_buffer[cur_index].PosL, 1.0f), local_to_ndc);
        min_depth = min(min_depth, ndc_cor.z / ndc_cor.w);
        left = min(left, ndc_cor.x);
        right = max(right, ndc_cor.x);
        top = max(top, ndc_cor.y);    
        bottom = min(bottom, ndc_cor.y);   
    }

    //3、剔除
    //根据长宽确定取第几层的hi z buffer，保证最长边刚好在相邻的两个纹素上
    float width = right - left;
    float height = top - bottom;
    float size = max(width, height);
    size = size * gRenderTargetSize.x;
    int level = 10 - log2(size);

    //根据ndc bounds 4个点的位置和最近点的关系进行剔除
    float2 ndc_aabb[4] = 
    {
        float2(left, bottom),
        float2(left, top),
        float2(right, bottom),
        float2(right, top),
    };

    //只有4个点都比最近点的depth小才被剔除
    bool culling = true; 
    [unroll(4)]
    for(int k=0; k < 4; ++k)
    {
        float sample_depth = hiz_tex.SampleLevel(g_sampler, ndc_aabb[k], level);
        culling = culling && (sample_depth < min_depth);
        if(!culling)
        {
            break;
        }
    }

    if(!culling)
    {
        //填充indirect command
        IndirectCommand command = (IndirectCommand) 0.0f;
        command.DrawArguments.x = cur_index_count;
        command.DrawArguments.y = 1;
        command.DrawArguments.z = index_count_offset;
        command.DrawArguments.w = cur_obj_data.DrawCommand.DrawArguments.w;
        command.DrawArgumentsEx = 0;
        command.ObjCbv = cur_obj_data.DrawCommand.ObjCbv;
        command.PassCbv = cur_obj_data.DrawCommand.PassCbv;
        output_buffer.Append(command);
    }
}