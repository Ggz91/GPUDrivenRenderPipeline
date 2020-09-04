Texture2D<float> input_tex : register(t0);
RWTexture2D<float> output_tex : register(u0);

cbuffer Param : register(b0)
{
    float2 texl_size;
    int mip_level;
};


SamplerState g_max_sampler : register(s0);

static float2 Offset[4] =
{
    float2(-1, -1),
    float2(-1, 1),
    float2(1, 1),
    float2(1, -1)
};

[numthreads(8, 8, 1)]
void GenerateHiZMipmaps(uint3 thread_id : SV_DISPATCHTHREADID)
{
    float max_z = 0;
    for(int i=0; i<4; ++i)
    {
        float2 uv = float2(texl_size * (thread_id.xy + Offset[i] + 0.5));
        float z =  input_tex.SampleLevel(g_max_sampler, uv, mip_level).r;
        max_z = max(max_z, z);
    }
    output_tex[thread_id.xy] = max_z;
}