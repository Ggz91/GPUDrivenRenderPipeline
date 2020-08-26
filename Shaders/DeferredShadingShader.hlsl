#include "Common.hlsl"

// Constant data that varies per material.
cbuffer cbPass : register(b1)
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

    // Indices [0, NUM_DIR_LIGHTS) are directional lights;
    // indices [NUM_DIR_LIGHTS, NUM_DIR_LIGHTS+NUM_POINT_LIGHTS) are point lights;
    // indices [NUM_DIR_LIGHTS+NUM_POINT_LIGHTS, NUM_DIR_LIGHTS+NUM_POINT_LIGHT+NUM_SPOT_LIGHTS)
    // are spot lights for a maximum of MaxLights per object.
    Light gLights[MaxLights];
};

Texture2D g_buffer0            : register(t0);
Texture2D g_buffer1        : register(t1);
StructuredBuffer<MaterialData> mats_data : register(t0, space1);
Texture2D depth_map : register(t1, space1);
Texture2D g_textures[2] : register(t2, space1);

static const float2 gTexCoords[6] = 
{
	float2(0.0f, 1.0f),
	float2(0.0f, 0.0f),
	float2(1.0f, 0.0f),
	float2(0.0f, 1.0f),
	float2(1.0f, 0.0f),
	float2(1.0f, 1.0f)
};

float MapDepthToNDCZ(float depth)
{
	float A = -gFarZ / (gNearZ - gFarZ);
	float B = gFarZ * gNearZ / (gNearZ - gFarZ);
	float z_vs = B / (depth - A);
	return depth * z_vs;
}

float3 MapNDCCorToWorldCor(float3 ndc_cor)
{
	return mul(float4(ndc_cor, 1.0f), gInvViewProj).xyz;
}

DeferredGSVertexOut ShadingVS(VertexIn input, uint vid : SV_VertexID)
{
    DeferredGSVertexOut vout = (DeferredGSVertexOut)0.0f;
	
	vout.TexC = gTexCoords[vid];
	
	vout.PosH = float4(2.0f*vout.TexC.x - 1.0f, 1.0f - 2.0f*vout.TexC.y, 0.0f, 1.0f);

    return vout;
}

float4 ShadingPS(DeferredGSVertexOut input) : SV_TARGET0
{
	int mat_id = g_buffer1.SampleLevel(gsamPointClamp, input.TexC, 0.0f).a;
	
	clip(mat_id);

	uint4 normal_uv_depth = g_buffer0.SampleLevel(gsamPointClamp, input.TexC, 0.0f);
	float2 uv = DecodeUV(normal_uv_depth.y);
	float4 normal_vertex = UnpackNormal(DecodeNormal(normal_uv_depth.x));
	MaterialData mat_data = mats_data[mat_id];

	float4 diffuse_albedo = mat_data.DiffuseAlbedo * g_textures[mat_data.DiffuseMapIndex].Sample(gsamAnisotropicWrap, uv);
	float4 normal_map_sample = g_textures[mat_data.NormalMapIndex].Sample(gsamAnisotropicWrap, uv);
	float3 bumped_normal_ws = NormalSampleToWorldSpace(normal_map_sample.rgb, normal_vertex.rgb, float3(1, 0, 0));
	float depth = DecodeDepth(normal_uv_depth.z);
	float3 ndc_cor = float3(uv, depth);
	float3 pos_ws =MapNDCCorToWorldCor(ndc_cor);
	float3 to_eye_ws = normalize(gEyePosW - pos_ws);
	float4 ambient = gAmbientLight * diffuse_albedo;
	
	float3 shadow_factor = float3(1.0f, 1.0f, 1.0f);

	const float shininess = (1.0f - mat_data.Roughness) * normal_map_sample.a;
	Material mat = {diffuse_albedo, mat_data.FresnelR0, shininess};
	float4 direct_light = ComputeLighting(gLights, mat, pos_ws, bumped_normal_ws, to_eye_ws, shadow_factor);
	float4 lit_color = ambient + direct_light;
	float3 r = reflect(-to_eye_ws, bumped_normal_ws);
	float4 reflection_color = float4(1.0, 1.0, 1.0, 1);
	lit_color.rgb += shininess * mat_data.FresnelR0 * reflection_color.rgb;
	lit_color.a = diffuse_albedo.a;
	return lit_color;
}
