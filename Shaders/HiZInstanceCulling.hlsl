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
    uint3 pad0;

    // Indices [0, NUM_DIR_LIGHTS) are directional lights;
    // indices [NUM_DIR_LIGHTS, NUM_DIR_LIGHTS+NUM_POINT_LIGHTS) are point lights;
    // indices [NUM_DIR_LIGHTS+NUM_POINT_LIGHTS, NUM_DIR_LIGHTS+NUM_POINT_LIGHT+NUM_SPOT_LIGHTS)
    // are spot lights for a maximum of MaxLights per object.
    Light gLights[MaxLights];
    float4 pad1[11];
}

Texture2D<float> hiz_tex : register(t0);
StructuredBuffer<ObjectContants> object_data : register(t1);
AppendStructuredBuffer<InstanceChunk> output_buffer : register(u0);
SamplerState g_sampler : register(s0);

[numthreads(BufferThreadSize, 1, 1)]
void HiZInstanceCulling(uint3 thread_id : SV_DISPATCHTHREADID)
{
    if(thread_id.x >= gObjectNum)
    {
        return;
    }
  
    ObjectContants cur_data = object_data[thread_id.x];

    //根据bounds确定NDC空间的aabb和最小深度
    //AABB 世界空间位置
    float4 aabb_vertexes[8] = 
    {
        float4(cur_data.BoundsMinVertex.x, cur_data.BoundsMinVertex.y, cur_data.BoundsMinVertex.z, 1.0f),
        float4(cur_data.BoundsMinVertex.x, cur_data.BoundsMinVertex.y, cur_data.BoundsMaxVertex.z, 1.0f),
        float4(cur_data.BoundsMaxVertex.x, cur_data.BoundsMinVertex.y, cur_data.BoundsMinVertex.z, 1.0f),
        float4(cur_data.BoundsMaxVertex.x, cur_data.BoundsMinVertex.y, cur_data.BoundsMaxVertex.z, 1.0f),
        float4(cur_data.BoundsMinVertex.x, cur_data.BoundsMaxVertex.y, cur_data.BoundsMinVertex.z, 1.0f),
        float4(cur_data.BoundsMinVertex.x, cur_data.BoundsMaxVertex.y, cur_data.BoundsMaxVertex.z, 1.0f),
        float4(cur_data.BoundsMaxVertex.x, cur_data.BoundsMaxVertex.y, cur_data.BoundsMinVertex.z, 1.0f),
        float4(cur_data.BoundsMaxVertex.x, cur_data.BoundsMaxVertex.y, cur_data.BoundsMaxVertex.z, 1.0f),
    };

    float4x4 local_to_ndc = mul(cur_data.gWorld, gViewProj);
    float min_depth = 1.0f;
    float left = 1.0f;
    float right = 0.0f;
    float top = 0.0f;
    float bottom = 1.0f;

    //根据世界空间映射到NDC空间
    [unroll(8)]
    for(int index=0; index<8; ++index)
    {
        float4 ndc_cor = mul(aabb_vertexes[index], local_to_ndc);
        ndc_cor.x /= ndc_cor.w;
        ndc_cor.y /= ndc_cor.w;
        min_depth = min(min_depth, ndc_cor.z / ndc_cor.w);
        left = min(left, ndc_cor.x);
        right = max(right, ndc_cor.x);
        top = max(top, ndc_cor.y);    
        bottom = min(bottom, ndc_cor.y);    
    }

    //根据长宽确定取第几层的hi z buffer，保证最长边刚好在相邻的两个纹素上
    float width = right - left;
    float height = top - bottom;
    float size = max(width, height) / 2;
    size = size * gRenderTargetSize.x;
    uint level = min(8, (uint)log2(size));

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

    //没culling的加入到最终的buffer中
    if(!culling)
    {
        //为了后续的负载平衡，把单个instance按照ClusterPerChunk个cluster进行拆分
        uint chunk_size = cur_data.DrawArguments.x / MaxVertexNumPerChunk;
        chunk_size += ( 0 == cur_data.DrawArguments.x % MaxVertexNumPerChunk) ? 0 : 1;

        [unroll(MaxChunkNumPerInstance)]
        for(uint j=0; j<chunk_size; ++j)
        {
            InstanceChunk chunk_data = (InstanceChunk) 0.0f;
            chunk_data.InstanceID = thread_id.x;
            chunk_data.ChunkID = j;
            output_buffer.Append(chunk_data);
        }
    }
}

