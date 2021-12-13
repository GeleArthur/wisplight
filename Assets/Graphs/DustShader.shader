Shader "DustGraph"
{
    Properties
    {
        Vector1_2f1e1aa506e142199a64d07139b44a85("NoiseScale", Float) = 5
        _Materialised("Materialised", Range(0, 1)) = 1
        Vector1_eee1783ae5744fb3b3f1036218fe3bdb("EmmisionOffset", Float) = 0.1
        Vector1_6143018700ad4236ae154b2d19051c02("Cell Density", Float) = 30
        [HDR]Color_f24be94f3f7140f2b052f1ea234c3ffb("Emission Color", Color) = (1, 1, 1, 1)
        Vector1_d7448e8c4bfe4629a845c4b4cf37f445("Sparkle Edge", Range(0, 1)) = 0.65
        Vector1_b508357b1e0b4ebfae0a54a8a1d8153c("Sparkle Speed", Float) = 0.5
        [NonModifiableTextureData][NoScaleOffset]_SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_Texture_1("Texture2D", 2D) = "white" {}
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
        SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue" = "Transparent"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

        // Render State
        Cull Back
    Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
    ZTest LEqual
    ZWrite On

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 4.5
    #pragma exclude_renderers gles gles3 glcore
    #pragma multi_compile_instancing
    #pragma multi_compile_fog
    #pragma multi_compile _ DOTS_INSTANCING_ON
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
    #pragma multi_compile _ LIGHTMAP_ON
    #pragma multi_compile _ DIRLIGHTMAP_COMBINED
    #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
    #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
    #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
    #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
    #pragma multi_compile _ _SHADOWS_SOFT
    #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
    #pragma multi_compile _ SHADOWS_SHADOWMASK
        // GraphKeywords: <None>

        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _NORMALMAP 1
        #define _SPECULAR_SETUP
        #define _NORMAL_DROPOFF_OS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        float4 uv0 : TEXCOORD0;
        float4 uv1 : TEXCOORD1;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float3 positionWS;
        float3 normalWS;
        float4 tangentWS;
        float4 texCoord0;
        float3 viewDirectionWS;
        #if defined(LIGHTMAP_ON)
        float2 lightmapUV;
        #endif
        #if !defined(LIGHTMAP_ON)
        float3 sh;
        #endif
        float4 fogFactorAndVertexLight;
        float4 shadowCoord;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 WorldSpaceNormal;
        float4 uv0;
        float3 TimeParameters;
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        float3 interp0 : TEXCOORD0;
        float3 interp1 : TEXCOORD1;
        float4 interp2 : TEXCOORD2;
        float4 interp3 : TEXCOORD3;
        float3 interp4 : TEXCOORD4;
        #if defined(LIGHTMAP_ON)
        float2 interp5 : TEXCOORD5;
        #endif
        #if !defined(LIGHTMAP_ON)
        float3 interp6 : TEXCOORD6;
        #endif
        float4 interp7 : TEXCOORD7;
        float4 interp8 : TEXCOORD8;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings(Varyings input)
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        output.interp0.xyz = input.positionWS;
        output.interp1.xyz = input.normalWS;
        output.interp2.xyzw = input.tangentWS;
        output.interp3.xyzw = input.texCoord0;
        output.interp4.xyz = input.viewDirectionWS;
        #if defined(LIGHTMAP_ON)
        output.interp5.xy = input.lightmapUV;
        #endif
        #if !defined(LIGHTMAP_ON)
        output.interp6.xyz = input.sh;
        #endif
        output.interp7.xyzw = input.fogFactorAndVertexLight;
        output.interp8.xyzw = input.shadowCoord;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings(PackedVaryings input)
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.positionWS = input.interp0.xyz;
        output.normalWS = input.interp1.xyz;
        output.tangentWS = input.interp2.xyzw;
        output.texCoord0 = input.interp3.xyzw;
        output.viewDirectionWS = input.interp4.xyz;
        #if defined(LIGHTMAP_ON)
        output.lightmapUV = input.interp5.xy;
        #endif
        #if !defined(LIGHTMAP_ON)
        output.sh = input.interp6.xyz;
        #endif
        output.fogFactorAndVertexLight = input.interp7.xyzw;
        output.shadowCoord = input.interp8.xyzw;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START(UnityPerMaterial)
float4 _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_Texture_1_TexelSize;
float Vector1_2f1e1aa506e142199a64d07139b44a85;
float _Materialised;
float Vector1_eee1783ae5744fb3b3f1036218fe3bdb;
float Vector1_6143018700ad4236ae154b2d19051c02;
float4 Color_f24be94f3f7140f2b052f1ea234c3ffb;
float Vector1_d7448e8c4bfe4629a845c4b4cf37f445;
float Vector1_b508357b1e0b4ebfae0a54a8a1d8153c;
CBUFFER_END

// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_Texture_1);
SAMPLER(sampler_SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_Texture_1);

// Graph Functions

void Unity_Multiply_float(float A, float B, out float Out)
{
    Out = A * B;
}

void Unity_RandomRange_float(float2 Seed, float Min, float Max, out float Out)
{
     float randomno = frac(sin(dot(Seed, float2(12.9898, 78.233))) * 43758.5453);
     Out = lerp(Min, Max, randomno);
}

void Unity_Twirl_float(float2 UV, float2 Center, float Strength, float2 Offset, out float2 Out)
{
    float2 delta = UV - Center;
    float angle = Strength * length(delta);
    float x = cos(angle) * delta.x - sin(angle) * delta.y;
    float y = sin(angle) * delta.x + cos(angle) * delta.y;
    Out = float2(x + Center.x + Offset.x, y + Center.y + Offset.y);
}

void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
{
    Out = UV * Tiling + Offset;
}


inline float Unity_SimpleNoise_RandomValue_float(float2 uv)
{
    return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
}

inline float Unity_SimpleNnoise_Interpolate_float(float a, float b, float t)
{
    return (1.0 - t) * a + (t * b);
}


inline float Unity_SimpleNoise_ValueNoise_float(float2 uv)
{
    float2 i = floor(uv);
    float2 f = frac(uv);
    f = f * f * (3.0 - 2.0 * f);

    uv = abs(frac(uv) - 0.5);
    float2 c0 = i + float2(0.0, 0.0);
    float2 c1 = i + float2(1.0, 0.0);
    float2 c2 = i + float2(0.0, 1.0);
    float2 c3 = i + float2(1.0, 1.0);
    float r0 = Unity_SimpleNoise_RandomValue_float(c0);
    float r1 = Unity_SimpleNoise_RandomValue_float(c1);
    float r2 = Unity_SimpleNoise_RandomValue_float(c2);
    float r3 = Unity_SimpleNoise_RandomValue_float(c3);

    float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
    float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
    float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
    return t;
}
void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
{
    float t = 0.0;

    float freq = pow(2.0, float(0));
    float amp = pow(0.5, float(3 - 0));
    t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

    freq = pow(2.0, float(1));
    amp = pow(0.5, float(3 - 1));
    t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

    freq = pow(2.0, float(2));
    amp = pow(0.5, float(3 - 2));
    t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

    Out = t;
}

void Unity_Add_float(float A, float B, out float Out)
{
    Out = A + B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_Step_float(float Edge, float In, out float Out)
{
    Out = step(Edge, In);
}

void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
{
    Out = A * B;
}

void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
{
    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}


float2 Unity_GradientNoise_Dir_float(float2 p)
{
    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
    p = p % 289;
    // need full precision, otherwise half overflows when p > 1
    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
    x = (34 * x + 1) * x % 289;
    x = frac(x / 41) * 2 - 1;
    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
}

void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
{
    float2 p = UV * Scale;
    float2 ip = floor(p);
    float2 fp = frac(p);
    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
}


inline float2 Unity_Voronoi_RandomVector_float(float2 UV, float offset)
{
    float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
    UV = frac(sin(mul(UV, m)));
    return float2(sin(UV.y * +offset) * 0.5 + 0.5, cos(UV.x * offset) * 0.5 + 0.5);
}

void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
{
    float2 g = floor(UV * CellDensity);
    float2 f = frac(UV * CellDensity);
    float t = 8.0;
    float3 res = float3(8.0, 0.0, 0.0);

    for (int y = -1; y <= 1; y++)
    {
        for (int x = -1; x <= 1; x++)
        {
            float2 lattice = float2(x,y);
            float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
            float d = distance(lattice + offset, f);

            if (d < res.x)
            {
                res = float3(d, offset.x, offset.y);
                Out = res.x;
                Cells = res.y;
            }
        }
    }
}

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Add_float4(float4 A, float4 B, out float4 Out)
{
    Out = A + B;
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
    VertexDescription description = (VertexDescription)0;
    description.Position = IN.ObjectSpacePosition;
    description.Normal = IN.ObjectSpaceNormal;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float3 BaseColor;
    float3 NormalOS;
    float3 Emission;
    float3 Specular;
    float Smoothness;
    float Occlusion;
    float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription)0;
    float _Split_9075b88e065c4620845a4bbb94507295_R_1 = SHADERGRAPH_OBJECT_POSITION[0];
    float _Split_9075b88e065c4620845a4bbb94507295_G_2 = SHADERGRAPH_OBJECT_POSITION[1];
    float _Split_9075b88e065c4620845a4bbb94507295_B_3 = SHADERGRAPH_OBJECT_POSITION[2];
    float _Split_9075b88e065c4620845a4bbb94507295_A_4 = 0;
    float _Multiply_9122215ecfa1426c8a05606961aa62f4_Out_2;
    Unity_Multiply_float(_Split_9075b88e065c4620845a4bbb94507295_R_1, _Split_9075b88e065c4620845a4bbb94507295_B_3, _Multiply_9122215ecfa1426c8a05606961aa62f4_Out_2);
    float _Multiply_2d509dc7f9f0402db69d4701ce482d7c_Out_2;
    Unity_Multiply_float(_Split_9075b88e065c4620845a4bbb94507295_G_2, _Split_9075b88e065c4620845a4bbb94507295_B_3, _Multiply_2d509dc7f9f0402db69d4701ce482d7c_Out_2);
    float2 _Vector2_25b956a15eb2450d82ffb981b718c892_Out_0 = float2(_Multiply_9122215ecfa1426c8a05606961aa62f4_Out_2, _Multiply_2d509dc7f9f0402db69d4701ce482d7c_Out_2);
    float _RandomRange_fab572807af44d4aa4d1c7c173801461_Out_3;
    Unity_RandomRange_float(_Vector2_25b956a15eb2450d82ffb981b718c892_Out_0, -1, 1, _RandomRange_fab572807af44d4aa4d1c7c173801461_Out_3);
    float2 _Twirl_344ad4db85314e5091310937b6b719d9_Out_4;
    Unity_Twirl_float(IN.uv0.xy, float2 (0.5, 0), _RandomRange_fab572807af44d4aa4d1c7c173801461_Out_3, float2 (0, 0), _Twirl_344ad4db85314e5091310937b6b719d9_Out_4);
    float _RandomRange_f9ab629e6ac344edb552ad4aea6e90d3_Out_3;
    Unity_RandomRange_float(_Vector2_25b956a15eb2450d82ffb981b718c892_Out_0, 0, 1, _RandomRange_f9ab629e6ac344edb552ad4aea6e90d3_Out_3);
    float _RandomRange_24cd5e2a255647cbb8fffdbe74a5ea32_Out_3;
    Unity_RandomRange_float(_Vector2_25b956a15eb2450d82ffb981b718c892_Out_0, 10, 30, _RandomRange_24cd5e2a255647cbb8fffdbe74a5ea32_Out_3);
    float2 _Vector2_6d5f4d74c2314cdd8e1288d96858efd4_Out_0 = float2(_RandomRange_f9ab629e6ac344edb552ad4aea6e90d3_Out_3, _RandomRange_24cd5e2a255647cbb8fffdbe74a5ea32_Out_3);
    float2 _TilingAndOffset_6d6a741583cb4e7d861a326a67a95b7e_Out_3;
    Unity_TilingAndOffset_float(_Twirl_344ad4db85314e5091310937b6b719d9_Out_4, _Vector2_6d5f4d74c2314cdd8e1288d96858efd4_Out_0, float2 (0, 0), _TilingAndOffset_6d6a741583cb4e7d861a326a67a95b7e_Out_3);
    float _RandomRange_958165b7c3c245b19a12b674d6634371_Out_3;
    Unity_RandomRange_float(_Vector2_25b956a15eb2450d82ffb981b718c892_Out_0, 500, 700, _RandomRange_958165b7c3c245b19a12b674d6634371_Out_3);
    float _SimpleNoise_4258d5b4269041c2b55ddb7d098e0dff_Out_2;
    Unity_SimpleNoise_float(_TilingAndOffset_6d6a741583cb4e7d861a326a67a95b7e_Out_3, _RandomRange_958165b7c3c245b19a12b674d6634371_Out_3, _SimpleNoise_4258d5b4269041c2b55ddb7d098e0dff_Out_2);
    float _RandomRange_c15bab0ae8fb4570b6bacb91e8c7b8a6_Out_3;
    Unity_RandomRange_float(_Vector2_25b956a15eb2450d82ffb981b718c892_Out_0, 150, 200, _RandomRange_c15bab0ae8fb4570b6bacb91e8c7b8a6_Out_3);
    float _SimpleNoise_2eb21a33aa7c4e3b84decb54cd5d5570_Out_2;
    Unity_SimpleNoise_float(IN.uv0.xy, _RandomRange_c15bab0ae8fb4570b6bacb91e8c7b8a6_Out_3, _SimpleNoise_2eb21a33aa7c4e3b84decb54cd5d5570_Out_2);
    float _Multiply_89d7189c8fba48e5b757d93014bfd557_Out_2;
    Unity_Multiply_float(3, _SimpleNoise_2eb21a33aa7c4e3b84decb54cd5d5570_Out_2, _Multiply_89d7189c8fba48e5b757d93014bfd557_Out_2);
    float _Add_a97a2c2aa00b452bb1df95eeced7cfb6_Out_2;
    Unity_Add_float(_SimpleNoise_4258d5b4269041c2b55ddb7d098e0dff_Out_2, _Multiply_89d7189c8fba48e5b757d93014bfd557_Out_2, _Add_a97a2c2aa00b452bb1df95eeced7cfb6_Out_2);
    float _Divide_e6407003f1734725bac05ea6e13d0c99_Out_2;
    Unity_Divide_float(_Add_a97a2c2aa00b452bb1df95eeced7cfb6_Out_2, 4, _Divide_e6407003f1734725bac05ea6e13d0c99_Out_2);
    float _Property_b576b9fc8c954aca84f6b6155afa5fa9_Out_0 = Vector1_d7448e8c4bfe4629a845c4b4cf37f445;
    float _Step_a0998484051a4502944b2193794ec2af_Out_2;
    Unity_Step_float(_Property_b576b9fc8c954aca84f6b6155afa5fa9_Out_0, _Divide_e6407003f1734725bac05ea6e13d0c99_Out_2, _Step_a0998484051a4502944b2193794ec2af_Out_2);
    float _Property_7735a84e56694723969c1dc37628b724_Out_0 = Vector1_b508357b1e0b4ebfae0a54a8a1d8153c;
    float _Multiply_9e543f00b7e34b0086558b8fef2e68b9_Out_2;
    Unity_Multiply_float(IN.TimeParameters.x, _Property_7735a84e56694723969c1dc37628b724_Out_0, _Multiply_9e543f00b7e34b0086558b8fef2e68b9_Out_2);
    float _Multiply_f1858fc18ecf4faa828d7c4a0fa84c4d_Out_2;
    Unity_Multiply_float(_Multiply_9e543f00b7e34b0086558b8fef2e68b9_Out_2, 1.5, _Multiply_f1858fc18ecf4faa828d7c4a0fa84c4d_Out_2);
    float2 _Vector2_330142494d0d4792a0c710a2364a5442_Out_0 = float2(_Multiply_9e543f00b7e34b0086558b8fef2e68b9_Out_2, _Multiply_f1858fc18ecf4faa828d7c4a0fa84c4d_Out_2);
    float2 _TilingAndOffset_85c121fb05354962a60ed37d3ef9f813_Out_3;
    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_330142494d0d4792a0c710a2364a5442_Out_0, _TilingAndOffset_85c121fb05354962a60ed37d3ef9f813_Out_3);
    float4 _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_RGBA_0 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_Texture_1).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_Texture_1).samplerstate, _TilingAndOffset_85c121fb05354962a60ed37d3ef9f813_Out_3);
    float _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_R_4 = _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_RGBA_0.r;
    float _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_G_5 = _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_RGBA_0.g;
    float _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_B_6 = _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_RGBA_0.b;
    float _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_A_7 = _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_RGBA_0.a;
    float4 _Multiply_b4ab13caabac4c0d974f6568c10abeda_Out_2;
    Unity_Multiply_float((_Step_a0998484051a4502944b2193794ec2af_Out_2.xxxx), _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_RGBA_0, _Multiply_b4ab13caabac4c0d974f6568c10abeda_Out_2);
    float _Property_6ee5d2a2b8bf49de954a3cd5216487cc_Out_0 = _Materialised;
    float _Remap_53339270754549bea2d7a6f99acc8e37_Out_3;
    Unity_Remap_float(_Property_6ee5d2a2b8bf49de954a3cd5216487cc_Out_0, float2 (1, 0), float2 (-0.15, 1.1), _Remap_53339270754549bea2d7a6f99acc8e37_Out_3);
    float _Property_460e92d704484d58a231c183f394e581_Out_0 = Vector1_eee1783ae5744fb3b3f1036218fe3bdb;
    float _Add_6318c4fdc2bf45e78bacfb15c8b5e69f_Out_2;
    Unity_Add_float(_Remap_53339270754549bea2d7a6f99acc8e37_Out_3, _Property_460e92d704484d58a231c183f394e581_Out_0, _Add_6318c4fdc2bf45e78bacfb15c8b5e69f_Out_2);
    float _Property_c106932bbbf94ea89ec8d94076689161_Out_0 = Vector1_2f1e1aa506e142199a64d07139b44a85;
    float _GradientNoise_906c40673cc14548b509ba1d1ea2b14e_Out_2;
    Unity_GradientNoise_float(IN.uv0.xy, _Property_c106932bbbf94ea89ec8d94076689161_Out_0, _GradientNoise_906c40673cc14548b509ba1d1ea2b14e_Out_2);
    float _Multiply_6bc75468206749799ee0492aaac71cef_Out_2;
    Unity_Multiply_float(_GradientNoise_906c40673cc14548b509ba1d1ea2b14e_Out_2, 2, _Multiply_6bc75468206749799ee0492aaac71cef_Out_2);
    float _Property_cd0b606707f6467b993a0f84d74c2468_Out_0 = Vector1_6143018700ad4236ae154b2d19051c02;
    float _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Out_3;
    float _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Cells_4;
    Unity_Voronoi_float(IN.uv0.xy, IN.TimeParameters.x, _Property_cd0b606707f6467b993a0f84d74c2468_Out_0, _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Out_3, _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Cells_4);
    float _Add_ca098124b82e447ba61175254f1fadf4_Out_2;
    Unity_Add_float(_Multiply_6bc75468206749799ee0492aaac71cef_Out_2, _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Out_3, _Add_ca098124b82e447ba61175254f1fadf4_Out_2);
    float _Divide_c40356c0ab504a9394d3d54abc68bfaf_Out_2;
    Unity_Divide_float(_Add_ca098124b82e447ba61175254f1fadf4_Out_2, 3, _Divide_c40356c0ab504a9394d3d54abc68bfaf_Out_2);
    float _Step_1fe338b5168449a8a07bf9b80f31d4fa_Out_2;
    Unity_Step_float(_Add_6318c4fdc2bf45e78bacfb15c8b5e69f_Out_2, _Divide_c40356c0ab504a9394d3d54abc68bfaf_Out_2, _Step_1fe338b5168449a8a07bf9b80f31d4fa_Out_2);
    float4 _Multiply_28b8a693ce7243d4b61d000abefaeae5_Out_2;
    Unity_Multiply_float(_Multiply_b4ab13caabac4c0d974f6568c10abeda_Out_2, (_Step_1fe338b5168449a8a07bf9b80f31d4fa_Out_2.xxxx), _Multiply_28b8a693ce7243d4b61d000abefaeae5_Out_2);
    float _OneMinus_b1d4304c2ad94669a04a9f96eb7fc751_Out_1;
    Unity_OneMinus_float(_Step_1fe338b5168449a8a07bf9b80f31d4fa_Out_2, _OneMinus_b1d4304c2ad94669a04a9f96eb7fc751_Out_1);
    float4 _Add_133da9716087442ea5bc5663dfeffebf_Out_2;
    Unity_Add_float4(_Multiply_28b8a693ce7243d4b61d000abefaeae5_Out_2, (_OneMinus_b1d4304c2ad94669a04a9f96eb7fc751_Out_1.xxxx), _Add_133da9716087442ea5bc5663dfeffebf_Out_2);
    float4 _Property_caf147c757e749ca85de849e9b9de43a_Out_0 = IsGammaSpace() ? LinearToSRGB(Color_f24be94f3f7140f2b052f1ea234c3ffb) : Color_f24be94f3f7140f2b052f1ea234c3ffb;
    float4 _Multiply_1ce2bd970f4148e2b1aad044712adcff_Out_2;
    Unity_Multiply_float(_Add_133da9716087442ea5bc5663dfeffebf_Out_2, _Property_caf147c757e749ca85de849e9b9de43a_Out_0, _Multiply_1ce2bd970f4148e2b1aad044712adcff_Out_2);
    float _Step_2a6ecea9c5ae4a20896d75eef11b522a_Out_2;
    Unity_Step_float(_Remap_53339270754549bea2d7a6f99acc8e37_Out_3, _Divide_c40356c0ab504a9394d3d54abc68bfaf_Out_2, _Step_2a6ecea9c5ae4a20896d75eef11b522a_Out_2);
    surface.BaseColor = (_Divide_e6407003f1734725bac05ea6e13d0c99_Out_2.xxx);
    surface.NormalOS = IN.ObjectSpaceNormal;
    surface.Emission = (_Multiply_1ce2bd970f4148e2b1aad044712adcff_Out_2.xyz);
    surface.Specular = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
    surface.Smoothness = 0;
    surface.Occlusion = 1;
    surface.Alpha = _Step_2a6ecea9c5ae4a20896d75eef11b522a_Out_2;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS.xyz;
    output.ObjectSpacePosition = input.positionOS;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

    // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
    float3 unnormalizedNormalWS = input.normalWS;
    const float renormFactor = 1.0 / length(unnormalizedNormalWS);


    output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
    output.ObjectSpaceNormal = normalize(mul(output.WorldSpaceNormal, (float3x3) UNITY_MATRIX_M));           // transposed multiplication by inverse matrix to handle normal scale


    output.uv0 = input.texCoord0;
    output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

    ENDHLSL
}
Pass
{
    Name "GBuffer"
    Tags
    {
        "LightMode" = "UniversalGBuffer"
    }

        // Render State
        Cull Back
    Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
    ZTest LEqual
    ZWrite Off

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 4.5
    #pragma exclude_renderers gles gles3 glcore
    #pragma multi_compile_instancing
    #pragma multi_compile_fog
    #pragma multi_compile _ DOTS_INSTANCING_ON
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
    #pragma multi_compile _ DIRLIGHTMAP_COMBINED
    #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
    #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
    #pragma multi_compile _ _SHADOWS_SOFT
    #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
    #pragma multi_compile _ _GBUFFER_NORMALS_OCT
        // GraphKeywords: <None>

        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _NORMALMAP 1
        #define _SPECULAR_SETUP
        #define _NORMAL_DROPOFF_OS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_GBUFFER
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        float4 uv0 : TEXCOORD0;
        float4 uv1 : TEXCOORD1;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float3 positionWS;
        float3 normalWS;
        float4 tangentWS;
        float4 texCoord0;
        float3 viewDirectionWS;
        #if defined(LIGHTMAP_ON)
        float2 lightmapUV;
        #endif
        #if !defined(LIGHTMAP_ON)
        float3 sh;
        #endif
        float4 fogFactorAndVertexLight;
        float4 shadowCoord;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 WorldSpaceNormal;
        float4 uv0;
        float3 TimeParameters;
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        float3 interp0 : TEXCOORD0;
        float3 interp1 : TEXCOORD1;
        float4 interp2 : TEXCOORD2;
        float4 interp3 : TEXCOORD3;
        float3 interp4 : TEXCOORD4;
        #if defined(LIGHTMAP_ON)
        float2 interp5 : TEXCOORD5;
        #endif
        #if !defined(LIGHTMAP_ON)
        float3 interp6 : TEXCOORD6;
        #endif
        float4 interp7 : TEXCOORD7;
        float4 interp8 : TEXCOORD8;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings(Varyings input)
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        output.interp0.xyz = input.positionWS;
        output.interp1.xyz = input.normalWS;
        output.interp2.xyzw = input.tangentWS;
        output.interp3.xyzw = input.texCoord0;
        output.interp4.xyz = input.viewDirectionWS;
        #if defined(LIGHTMAP_ON)
        output.interp5.xy = input.lightmapUV;
        #endif
        #if !defined(LIGHTMAP_ON)
        output.interp6.xyz = input.sh;
        #endif
        output.interp7.xyzw = input.fogFactorAndVertexLight;
        output.interp8.xyzw = input.shadowCoord;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings(PackedVaryings input)
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.positionWS = input.interp0.xyz;
        output.normalWS = input.interp1.xyz;
        output.tangentWS = input.interp2.xyzw;
        output.texCoord0 = input.interp3.xyzw;
        output.viewDirectionWS = input.interp4.xyz;
        #if defined(LIGHTMAP_ON)
        output.lightmapUV = input.interp5.xy;
        #endif
        #if !defined(LIGHTMAP_ON)
        output.sh = input.interp6.xyz;
        #endif
        output.fogFactorAndVertexLight = input.interp7.xyzw;
        output.shadowCoord = input.interp8.xyzw;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START(UnityPerMaterial)
float4 _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_Texture_1_TexelSize;
float Vector1_2f1e1aa506e142199a64d07139b44a85;
float _Materialised;
float Vector1_eee1783ae5744fb3b3f1036218fe3bdb;
float Vector1_6143018700ad4236ae154b2d19051c02;
float4 Color_f24be94f3f7140f2b052f1ea234c3ffb;
float Vector1_d7448e8c4bfe4629a845c4b4cf37f445;
float Vector1_b508357b1e0b4ebfae0a54a8a1d8153c;
CBUFFER_END

// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_Texture_1);
SAMPLER(sampler_SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_Texture_1);

// Graph Functions

void Unity_Multiply_float(float A, float B, out float Out)
{
    Out = A * B;
}

void Unity_RandomRange_float(float2 Seed, float Min, float Max, out float Out)
{
     float randomno = frac(sin(dot(Seed, float2(12.9898, 78.233))) * 43758.5453);
     Out = lerp(Min, Max, randomno);
}

void Unity_Twirl_float(float2 UV, float2 Center, float Strength, float2 Offset, out float2 Out)
{
    float2 delta = UV - Center;
    float angle = Strength * length(delta);
    float x = cos(angle) * delta.x - sin(angle) * delta.y;
    float y = sin(angle) * delta.x + cos(angle) * delta.y;
    Out = float2(x + Center.x + Offset.x, y + Center.y + Offset.y);
}

void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
{
    Out = UV * Tiling + Offset;
}


inline float Unity_SimpleNoise_RandomValue_float(float2 uv)
{
    return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
}

inline float Unity_SimpleNnoise_Interpolate_float(float a, float b, float t)
{
    return (1.0 - t) * a + (t * b);
}


inline float Unity_SimpleNoise_ValueNoise_float(float2 uv)
{
    float2 i = floor(uv);
    float2 f = frac(uv);
    f = f * f * (3.0 - 2.0 * f);

    uv = abs(frac(uv) - 0.5);
    float2 c0 = i + float2(0.0, 0.0);
    float2 c1 = i + float2(1.0, 0.0);
    float2 c2 = i + float2(0.0, 1.0);
    float2 c3 = i + float2(1.0, 1.0);
    float r0 = Unity_SimpleNoise_RandomValue_float(c0);
    float r1 = Unity_SimpleNoise_RandomValue_float(c1);
    float r2 = Unity_SimpleNoise_RandomValue_float(c2);
    float r3 = Unity_SimpleNoise_RandomValue_float(c3);

    float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
    float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
    float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
    return t;
}
void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
{
    float t = 0.0;

    float freq = pow(2.0, float(0));
    float amp = pow(0.5, float(3 - 0));
    t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

    freq = pow(2.0, float(1));
    amp = pow(0.5, float(3 - 1));
    t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

    freq = pow(2.0, float(2));
    amp = pow(0.5, float(3 - 2));
    t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

    Out = t;
}

void Unity_Add_float(float A, float B, out float Out)
{
    Out = A + B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_Step_float(float Edge, float In, out float Out)
{
    Out = step(Edge, In);
}

void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
{
    Out = A * B;
}

void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
{
    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}


float2 Unity_GradientNoise_Dir_float(float2 p)
{
    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
    p = p % 289;
    // need full precision, otherwise half overflows when p > 1
    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
    x = (34 * x + 1) * x % 289;
    x = frac(x / 41) * 2 - 1;
    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
}

void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
{
    float2 p = UV * Scale;
    float2 ip = floor(p);
    float2 fp = frac(p);
    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
}


inline float2 Unity_Voronoi_RandomVector_float(float2 UV, float offset)
{
    float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
    UV = frac(sin(mul(UV, m)));
    return float2(sin(UV.y * +offset) * 0.5 + 0.5, cos(UV.x * offset) * 0.5 + 0.5);
}

void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
{
    float2 g = floor(UV * CellDensity);
    float2 f = frac(UV * CellDensity);
    float t = 8.0;
    float3 res = float3(8.0, 0.0, 0.0);

    for (int y = -1; y <= 1; y++)
    {
        for (int x = -1; x <= 1; x++)
        {
            float2 lattice = float2(x,y);
            float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
            float d = distance(lattice + offset, f);

            if (d < res.x)
            {
                res = float3(d, offset.x, offset.y);
                Out = res.x;
                Cells = res.y;
            }
        }
    }
}

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Add_float4(float4 A, float4 B, out float4 Out)
{
    Out = A + B;
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
    VertexDescription description = (VertexDescription)0;
    description.Position = IN.ObjectSpacePosition;
    description.Normal = IN.ObjectSpaceNormal;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float3 BaseColor;
    float3 NormalOS;
    float3 Emission;
    float3 Specular;
    float Smoothness;
    float Occlusion;
    float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription)0;
    float _Split_9075b88e065c4620845a4bbb94507295_R_1 = SHADERGRAPH_OBJECT_POSITION[0];
    float _Split_9075b88e065c4620845a4bbb94507295_G_2 = SHADERGRAPH_OBJECT_POSITION[1];
    float _Split_9075b88e065c4620845a4bbb94507295_B_3 = SHADERGRAPH_OBJECT_POSITION[2];
    float _Split_9075b88e065c4620845a4bbb94507295_A_4 = 0;
    float _Multiply_9122215ecfa1426c8a05606961aa62f4_Out_2;
    Unity_Multiply_float(_Split_9075b88e065c4620845a4bbb94507295_R_1, _Split_9075b88e065c4620845a4bbb94507295_B_3, _Multiply_9122215ecfa1426c8a05606961aa62f4_Out_2);
    float _Multiply_2d509dc7f9f0402db69d4701ce482d7c_Out_2;
    Unity_Multiply_float(_Split_9075b88e065c4620845a4bbb94507295_G_2, _Split_9075b88e065c4620845a4bbb94507295_B_3, _Multiply_2d509dc7f9f0402db69d4701ce482d7c_Out_2);
    float2 _Vector2_25b956a15eb2450d82ffb981b718c892_Out_0 = float2(_Multiply_9122215ecfa1426c8a05606961aa62f4_Out_2, _Multiply_2d509dc7f9f0402db69d4701ce482d7c_Out_2);
    float _RandomRange_fab572807af44d4aa4d1c7c173801461_Out_3;
    Unity_RandomRange_float(_Vector2_25b956a15eb2450d82ffb981b718c892_Out_0, -1, 1, _RandomRange_fab572807af44d4aa4d1c7c173801461_Out_3);
    float2 _Twirl_344ad4db85314e5091310937b6b719d9_Out_4;
    Unity_Twirl_float(IN.uv0.xy, float2 (0.5, 0), _RandomRange_fab572807af44d4aa4d1c7c173801461_Out_3, float2 (0, 0), _Twirl_344ad4db85314e5091310937b6b719d9_Out_4);
    float _RandomRange_f9ab629e6ac344edb552ad4aea6e90d3_Out_3;
    Unity_RandomRange_float(_Vector2_25b956a15eb2450d82ffb981b718c892_Out_0, 0, 1, _RandomRange_f9ab629e6ac344edb552ad4aea6e90d3_Out_3);
    float _RandomRange_24cd5e2a255647cbb8fffdbe74a5ea32_Out_3;
    Unity_RandomRange_float(_Vector2_25b956a15eb2450d82ffb981b718c892_Out_0, 10, 30, _RandomRange_24cd5e2a255647cbb8fffdbe74a5ea32_Out_3);
    float2 _Vector2_6d5f4d74c2314cdd8e1288d96858efd4_Out_0 = float2(_RandomRange_f9ab629e6ac344edb552ad4aea6e90d3_Out_3, _RandomRange_24cd5e2a255647cbb8fffdbe74a5ea32_Out_3);
    float2 _TilingAndOffset_6d6a741583cb4e7d861a326a67a95b7e_Out_3;
    Unity_TilingAndOffset_float(_Twirl_344ad4db85314e5091310937b6b719d9_Out_4, _Vector2_6d5f4d74c2314cdd8e1288d96858efd4_Out_0, float2 (0, 0), _TilingAndOffset_6d6a741583cb4e7d861a326a67a95b7e_Out_3);
    float _RandomRange_958165b7c3c245b19a12b674d6634371_Out_3;
    Unity_RandomRange_float(_Vector2_25b956a15eb2450d82ffb981b718c892_Out_0, 500, 700, _RandomRange_958165b7c3c245b19a12b674d6634371_Out_3);
    float _SimpleNoise_4258d5b4269041c2b55ddb7d098e0dff_Out_2;
    Unity_SimpleNoise_float(_TilingAndOffset_6d6a741583cb4e7d861a326a67a95b7e_Out_3, _RandomRange_958165b7c3c245b19a12b674d6634371_Out_3, _SimpleNoise_4258d5b4269041c2b55ddb7d098e0dff_Out_2);
    float _RandomRange_c15bab0ae8fb4570b6bacb91e8c7b8a6_Out_3;
    Unity_RandomRange_float(_Vector2_25b956a15eb2450d82ffb981b718c892_Out_0, 150, 200, _RandomRange_c15bab0ae8fb4570b6bacb91e8c7b8a6_Out_3);
    float _SimpleNoise_2eb21a33aa7c4e3b84decb54cd5d5570_Out_2;
    Unity_SimpleNoise_float(IN.uv0.xy, _RandomRange_c15bab0ae8fb4570b6bacb91e8c7b8a6_Out_3, _SimpleNoise_2eb21a33aa7c4e3b84decb54cd5d5570_Out_2);
    float _Multiply_89d7189c8fba48e5b757d93014bfd557_Out_2;
    Unity_Multiply_float(3, _SimpleNoise_2eb21a33aa7c4e3b84decb54cd5d5570_Out_2, _Multiply_89d7189c8fba48e5b757d93014bfd557_Out_2);
    float _Add_a97a2c2aa00b452bb1df95eeced7cfb6_Out_2;
    Unity_Add_float(_SimpleNoise_4258d5b4269041c2b55ddb7d098e0dff_Out_2, _Multiply_89d7189c8fba48e5b757d93014bfd557_Out_2, _Add_a97a2c2aa00b452bb1df95eeced7cfb6_Out_2);
    float _Divide_e6407003f1734725bac05ea6e13d0c99_Out_2;
    Unity_Divide_float(_Add_a97a2c2aa00b452bb1df95eeced7cfb6_Out_2, 4, _Divide_e6407003f1734725bac05ea6e13d0c99_Out_2);
    float _Property_b576b9fc8c954aca84f6b6155afa5fa9_Out_0 = Vector1_d7448e8c4bfe4629a845c4b4cf37f445;
    float _Step_a0998484051a4502944b2193794ec2af_Out_2;
    Unity_Step_float(_Property_b576b9fc8c954aca84f6b6155afa5fa9_Out_0, _Divide_e6407003f1734725bac05ea6e13d0c99_Out_2, _Step_a0998484051a4502944b2193794ec2af_Out_2);
    float _Property_7735a84e56694723969c1dc37628b724_Out_0 = Vector1_b508357b1e0b4ebfae0a54a8a1d8153c;
    float _Multiply_9e543f00b7e34b0086558b8fef2e68b9_Out_2;
    Unity_Multiply_float(IN.TimeParameters.x, _Property_7735a84e56694723969c1dc37628b724_Out_0, _Multiply_9e543f00b7e34b0086558b8fef2e68b9_Out_2);
    float _Multiply_f1858fc18ecf4faa828d7c4a0fa84c4d_Out_2;
    Unity_Multiply_float(_Multiply_9e543f00b7e34b0086558b8fef2e68b9_Out_2, 1.5, _Multiply_f1858fc18ecf4faa828d7c4a0fa84c4d_Out_2);
    float2 _Vector2_330142494d0d4792a0c710a2364a5442_Out_0 = float2(_Multiply_9e543f00b7e34b0086558b8fef2e68b9_Out_2, _Multiply_f1858fc18ecf4faa828d7c4a0fa84c4d_Out_2);
    float2 _TilingAndOffset_85c121fb05354962a60ed37d3ef9f813_Out_3;
    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_330142494d0d4792a0c710a2364a5442_Out_0, _TilingAndOffset_85c121fb05354962a60ed37d3ef9f813_Out_3);
    float4 _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_RGBA_0 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_Texture_1).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_Texture_1).samplerstate, _TilingAndOffset_85c121fb05354962a60ed37d3ef9f813_Out_3);
    float _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_R_4 = _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_RGBA_0.r;
    float _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_G_5 = _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_RGBA_0.g;
    float _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_B_6 = _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_RGBA_0.b;
    float _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_A_7 = _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_RGBA_0.a;
    float4 _Multiply_b4ab13caabac4c0d974f6568c10abeda_Out_2;
    Unity_Multiply_float((_Step_a0998484051a4502944b2193794ec2af_Out_2.xxxx), _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_RGBA_0, _Multiply_b4ab13caabac4c0d974f6568c10abeda_Out_2);
    float _Property_6ee5d2a2b8bf49de954a3cd5216487cc_Out_0 = _Materialised;
    float _Remap_53339270754549bea2d7a6f99acc8e37_Out_3;
    Unity_Remap_float(_Property_6ee5d2a2b8bf49de954a3cd5216487cc_Out_0, float2 (1, 0), float2 (-0.15, 1.1), _Remap_53339270754549bea2d7a6f99acc8e37_Out_3);
    float _Property_460e92d704484d58a231c183f394e581_Out_0 = Vector1_eee1783ae5744fb3b3f1036218fe3bdb;
    float _Add_6318c4fdc2bf45e78bacfb15c8b5e69f_Out_2;
    Unity_Add_float(_Remap_53339270754549bea2d7a6f99acc8e37_Out_3, _Property_460e92d704484d58a231c183f394e581_Out_0, _Add_6318c4fdc2bf45e78bacfb15c8b5e69f_Out_2);
    float _Property_c106932bbbf94ea89ec8d94076689161_Out_0 = Vector1_2f1e1aa506e142199a64d07139b44a85;
    float _GradientNoise_906c40673cc14548b509ba1d1ea2b14e_Out_2;
    Unity_GradientNoise_float(IN.uv0.xy, _Property_c106932bbbf94ea89ec8d94076689161_Out_0, _GradientNoise_906c40673cc14548b509ba1d1ea2b14e_Out_2);
    float _Multiply_6bc75468206749799ee0492aaac71cef_Out_2;
    Unity_Multiply_float(_GradientNoise_906c40673cc14548b509ba1d1ea2b14e_Out_2, 2, _Multiply_6bc75468206749799ee0492aaac71cef_Out_2);
    float _Property_cd0b606707f6467b993a0f84d74c2468_Out_0 = Vector1_6143018700ad4236ae154b2d19051c02;
    float _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Out_3;
    float _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Cells_4;
    Unity_Voronoi_float(IN.uv0.xy, IN.TimeParameters.x, _Property_cd0b606707f6467b993a0f84d74c2468_Out_0, _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Out_3, _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Cells_4);
    float _Add_ca098124b82e447ba61175254f1fadf4_Out_2;
    Unity_Add_float(_Multiply_6bc75468206749799ee0492aaac71cef_Out_2, _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Out_3, _Add_ca098124b82e447ba61175254f1fadf4_Out_2);
    float _Divide_c40356c0ab504a9394d3d54abc68bfaf_Out_2;
    Unity_Divide_float(_Add_ca098124b82e447ba61175254f1fadf4_Out_2, 3, _Divide_c40356c0ab504a9394d3d54abc68bfaf_Out_2);
    float _Step_1fe338b5168449a8a07bf9b80f31d4fa_Out_2;
    Unity_Step_float(_Add_6318c4fdc2bf45e78bacfb15c8b5e69f_Out_2, _Divide_c40356c0ab504a9394d3d54abc68bfaf_Out_2, _Step_1fe338b5168449a8a07bf9b80f31d4fa_Out_2);
    float4 _Multiply_28b8a693ce7243d4b61d000abefaeae5_Out_2;
    Unity_Multiply_float(_Multiply_b4ab13caabac4c0d974f6568c10abeda_Out_2, (_Step_1fe338b5168449a8a07bf9b80f31d4fa_Out_2.xxxx), _Multiply_28b8a693ce7243d4b61d000abefaeae5_Out_2);
    float _OneMinus_b1d4304c2ad94669a04a9f96eb7fc751_Out_1;
    Unity_OneMinus_float(_Step_1fe338b5168449a8a07bf9b80f31d4fa_Out_2, _OneMinus_b1d4304c2ad94669a04a9f96eb7fc751_Out_1);
    float4 _Add_133da9716087442ea5bc5663dfeffebf_Out_2;
    Unity_Add_float4(_Multiply_28b8a693ce7243d4b61d000abefaeae5_Out_2, (_OneMinus_b1d4304c2ad94669a04a9f96eb7fc751_Out_1.xxxx), _Add_133da9716087442ea5bc5663dfeffebf_Out_2);
    float4 _Property_caf147c757e749ca85de849e9b9de43a_Out_0 = IsGammaSpace() ? LinearToSRGB(Color_f24be94f3f7140f2b052f1ea234c3ffb) : Color_f24be94f3f7140f2b052f1ea234c3ffb;
    float4 _Multiply_1ce2bd970f4148e2b1aad044712adcff_Out_2;
    Unity_Multiply_float(_Add_133da9716087442ea5bc5663dfeffebf_Out_2, _Property_caf147c757e749ca85de849e9b9de43a_Out_0, _Multiply_1ce2bd970f4148e2b1aad044712adcff_Out_2);
    float _Step_2a6ecea9c5ae4a20896d75eef11b522a_Out_2;
    Unity_Step_float(_Remap_53339270754549bea2d7a6f99acc8e37_Out_3, _Divide_c40356c0ab504a9394d3d54abc68bfaf_Out_2, _Step_2a6ecea9c5ae4a20896d75eef11b522a_Out_2);
    surface.BaseColor = (_Divide_e6407003f1734725bac05ea6e13d0c99_Out_2.xxx);
    surface.NormalOS = IN.ObjectSpaceNormal;
    surface.Emission = (_Multiply_1ce2bd970f4148e2b1aad044712adcff_Out_2.xyz);
    surface.Specular = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
    surface.Smoothness = 0;
    surface.Occlusion = 1;
    surface.Alpha = _Step_2a6ecea9c5ae4a20896d75eef11b522a_Out_2;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS.xyz;
    output.ObjectSpacePosition = input.positionOS;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

    // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
    float3 unnormalizedNormalWS = input.normalWS;
    const float renormFactor = 1.0 / length(unnormalizedNormalWS);


    output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
    output.ObjectSpaceNormal = normalize(mul(output.WorldSpaceNormal, (float3x3) UNITY_MATRIX_M));           // transposed multiplication by inverse matrix to handle normal scale


    output.uv0 = input.texCoord0;
    output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"

    ENDHLSL
}
Pass
{
    Name "ShadowCaster"
    Tags
    {
        "LightMode" = "ShadowCaster"
    }

        // Render State
        Cull Back
    Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
    ZTest LEqual
    ZWrite On
    ColorMask 0

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 4.5
    #pragma exclude_renderers gles gles3 glcore
    #pragma multi_compile_instancing
    #pragma multi_compile _ DOTS_INSTANCING_ON
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>

        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _NORMALMAP 1
        #define _SPECULAR_SETUP
        #define _NORMAL_DROPOFF_OS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        float4 uv0 : TEXCOORD0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float4 texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
        float4 uv0;
        float3 TimeParameters;
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        float4 interp0 : TEXCOORD0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings(Varyings input)
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        output.interp0.xyzw = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings(PackedVaryings input)
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.texCoord0 = input.interp0.xyzw;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START(UnityPerMaterial)
float4 _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_Texture_1_TexelSize;
float Vector1_2f1e1aa506e142199a64d07139b44a85;
float _Materialised;
float Vector1_eee1783ae5744fb3b3f1036218fe3bdb;
float Vector1_6143018700ad4236ae154b2d19051c02;
float4 Color_f24be94f3f7140f2b052f1ea234c3ffb;
float Vector1_d7448e8c4bfe4629a845c4b4cf37f445;
float Vector1_b508357b1e0b4ebfae0a54a8a1d8153c;
CBUFFER_END

// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_Texture_1);
SAMPLER(sampler_SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_Texture_1);

// Graph Functions

void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
{
    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}


float2 Unity_GradientNoise_Dir_float(float2 p)
{
    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
    p = p % 289;
    // need full precision, otherwise half overflows when p > 1
    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
    x = (34 * x + 1) * x % 289;
    x = frac(x / 41) * 2 - 1;
    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
}

void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
{
    float2 p = UV * Scale;
    float2 ip = floor(p);
    float2 fp = frac(p);
    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
}

void Unity_Multiply_float(float A, float B, out float Out)
{
    Out = A * B;
}


inline float2 Unity_Voronoi_RandomVector_float(float2 UV, float offset)
{
    float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
    UV = frac(sin(mul(UV, m)));
    return float2(sin(UV.y * +offset) * 0.5 + 0.5, cos(UV.x * offset) * 0.5 + 0.5);
}

void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
{
    float2 g = floor(UV * CellDensity);
    float2 f = frac(UV * CellDensity);
    float t = 8.0;
    float3 res = float3(8.0, 0.0, 0.0);

    for (int y = -1; y <= 1; y++)
    {
        for (int x = -1; x <= 1; x++)
        {
            float2 lattice = float2(x,y);
            float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
            float d = distance(lattice + offset, f);

            if (d < res.x)
            {
                res = float3(d, offset.x, offset.y);
                Out = res.x;
                Cells = res.y;
            }
        }
    }
}

void Unity_Add_float(float A, float B, out float Out)
{
    Out = A + B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_Step_float(float Edge, float In, out float Out)
{
    Out = step(Edge, In);
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
    VertexDescription description = (VertexDescription)0;
    description.Position = IN.ObjectSpacePosition;
    description.Normal = IN.ObjectSpaceNormal;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription)0;
    float _Property_6ee5d2a2b8bf49de954a3cd5216487cc_Out_0 = _Materialised;
    float _Remap_53339270754549bea2d7a6f99acc8e37_Out_3;
    Unity_Remap_float(_Property_6ee5d2a2b8bf49de954a3cd5216487cc_Out_0, float2 (1, 0), float2 (-0.15, 1.1), _Remap_53339270754549bea2d7a6f99acc8e37_Out_3);
    float _Property_c106932bbbf94ea89ec8d94076689161_Out_0 = Vector1_2f1e1aa506e142199a64d07139b44a85;
    float _GradientNoise_906c40673cc14548b509ba1d1ea2b14e_Out_2;
    Unity_GradientNoise_float(IN.uv0.xy, _Property_c106932bbbf94ea89ec8d94076689161_Out_0, _GradientNoise_906c40673cc14548b509ba1d1ea2b14e_Out_2);
    float _Multiply_6bc75468206749799ee0492aaac71cef_Out_2;
    Unity_Multiply_float(_GradientNoise_906c40673cc14548b509ba1d1ea2b14e_Out_2, 2, _Multiply_6bc75468206749799ee0492aaac71cef_Out_2);
    float _Property_cd0b606707f6467b993a0f84d74c2468_Out_0 = Vector1_6143018700ad4236ae154b2d19051c02;
    float _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Out_3;
    float _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Cells_4;
    Unity_Voronoi_float(IN.uv0.xy, IN.TimeParameters.x, _Property_cd0b606707f6467b993a0f84d74c2468_Out_0, _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Out_3, _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Cells_4);
    float _Add_ca098124b82e447ba61175254f1fadf4_Out_2;
    Unity_Add_float(_Multiply_6bc75468206749799ee0492aaac71cef_Out_2, _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Out_3, _Add_ca098124b82e447ba61175254f1fadf4_Out_2);
    float _Divide_c40356c0ab504a9394d3d54abc68bfaf_Out_2;
    Unity_Divide_float(_Add_ca098124b82e447ba61175254f1fadf4_Out_2, 3, _Divide_c40356c0ab504a9394d3d54abc68bfaf_Out_2);
    float _Step_2a6ecea9c5ae4a20896d75eef11b522a_Out_2;
    Unity_Step_float(_Remap_53339270754549bea2d7a6f99acc8e37_Out_3, _Divide_c40356c0ab504a9394d3d54abc68bfaf_Out_2, _Step_2a6ecea9c5ae4a20896d75eef11b522a_Out_2);
    surface.Alpha = _Step_2a6ecea9c5ae4a20896d75eef11b522a_Out_2;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS.xyz;
    output.ObjectSpacePosition = input.positionOS;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





    output.uv0 = input.texCoord0;
    output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

    ENDHLSL
}
Pass
{
    Name "DepthOnly"
    Tags
    {
        "LightMode" = "DepthOnly"
    }

        // Render State
        Cull Back
    Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
    ZTest LEqual
    ZWrite On
    ColorMask 0

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 4.5
    #pragma exclude_renderers gles gles3 glcore
    #pragma multi_compile_instancing
    #pragma multi_compile _ DOTS_INSTANCING_ON
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>

        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _NORMALMAP 1
        #define _SPECULAR_SETUP
        #define _NORMAL_DROPOFF_OS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        float4 uv0 : TEXCOORD0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float4 texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
        float4 uv0;
        float3 TimeParameters;
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        float4 interp0 : TEXCOORD0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings(Varyings input)
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        output.interp0.xyzw = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings(PackedVaryings input)
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.texCoord0 = input.interp0.xyzw;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START(UnityPerMaterial)
float4 _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_Texture_1_TexelSize;
float Vector1_2f1e1aa506e142199a64d07139b44a85;
float _Materialised;
float Vector1_eee1783ae5744fb3b3f1036218fe3bdb;
float Vector1_6143018700ad4236ae154b2d19051c02;
float4 Color_f24be94f3f7140f2b052f1ea234c3ffb;
float Vector1_d7448e8c4bfe4629a845c4b4cf37f445;
float Vector1_b508357b1e0b4ebfae0a54a8a1d8153c;
CBUFFER_END

// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_Texture_1);
SAMPLER(sampler_SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_Texture_1);

// Graph Functions

void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
{
    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}


float2 Unity_GradientNoise_Dir_float(float2 p)
{
    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
    p = p % 289;
    // need full precision, otherwise half overflows when p > 1
    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
    x = (34 * x + 1) * x % 289;
    x = frac(x / 41) * 2 - 1;
    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
}

void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
{
    float2 p = UV * Scale;
    float2 ip = floor(p);
    float2 fp = frac(p);
    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
}

void Unity_Multiply_float(float A, float B, out float Out)
{
    Out = A * B;
}


inline float2 Unity_Voronoi_RandomVector_float(float2 UV, float offset)
{
    float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
    UV = frac(sin(mul(UV, m)));
    return float2(sin(UV.y * +offset) * 0.5 + 0.5, cos(UV.x * offset) * 0.5 + 0.5);
}

void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
{
    float2 g = floor(UV * CellDensity);
    float2 f = frac(UV * CellDensity);
    float t = 8.0;
    float3 res = float3(8.0, 0.0, 0.0);

    for (int y = -1; y <= 1; y++)
    {
        for (int x = -1; x <= 1; x++)
        {
            float2 lattice = float2(x,y);
            float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
            float d = distance(lattice + offset, f);

            if (d < res.x)
            {
                res = float3(d, offset.x, offset.y);
                Out = res.x;
                Cells = res.y;
            }
        }
    }
}

void Unity_Add_float(float A, float B, out float Out)
{
    Out = A + B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_Step_float(float Edge, float In, out float Out)
{
    Out = step(Edge, In);
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
    VertexDescription description = (VertexDescription)0;
    description.Position = IN.ObjectSpacePosition;
    description.Normal = IN.ObjectSpaceNormal;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription)0;
    float _Property_6ee5d2a2b8bf49de954a3cd5216487cc_Out_0 = _Materialised;
    float _Remap_53339270754549bea2d7a6f99acc8e37_Out_3;
    Unity_Remap_float(_Property_6ee5d2a2b8bf49de954a3cd5216487cc_Out_0, float2 (1, 0), float2 (-0.15, 1.1), _Remap_53339270754549bea2d7a6f99acc8e37_Out_3);
    float _Property_c106932bbbf94ea89ec8d94076689161_Out_0 = Vector1_2f1e1aa506e142199a64d07139b44a85;
    float _GradientNoise_906c40673cc14548b509ba1d1ea2b14e_Out_2;
    Unity_GradientNoise_float(IN.uv0.xy, _Property_c106932bbbf94ea89ec8d94076689161_Out_0, _GradientNoise_906c40673cc14548b509ba1d1ea2b14e_Out_2);
    float _Multiply_6bc75468206749799ee0492aaac71cef_Out_2;
    Unity_Multiply_float(_GradientNoise_906c40673cc14548b509ba1d1ea2b14e_Out_2, 2, _Multiply_6bc75468206749799ee0492aaac71cef_Out_2);
    float _Property_cd0b606707f6467b993a0f84d74c2468_Out_0 = Vector1_6143018700ad4236ae154b2d19051c02;
    float _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Out_3;
    float _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Cells_4;
    Unity_Voronoi_float(IN.uv0.xy, IN.TimeParameters.x, _Property_cd0b606707f6467b993a0f84d74c2468_Out_0, _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Out_3, _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Cells_4);
    float _Add_ca098124b82e447ba61175254f1fadf4_Out_2;
    Unity_Add_float(_Multiply_6bc75468206749799ee0492aaac71cef_Out_2, _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Out_3, _Add_ca098124b82e447ba61175254f1fadf4_Out_2);
    float _Divide_c40356c0ab504a9394d3d54abc68bfaf_Out_2;
    Unity_Divide_float(_Add_ca098124b82e447ba61175254f1fadf4_Out_2, 3, _Divide_c40356c0ab504a9394d3d54abc68bfaf_Out_2);
    float _Step_2a6ecea9c5ae4a20896d75eef11b522a_Out_2;
    Unity_Step_float(_Remap_53339270754549bea2d7a6f99acc8e37_Out_3, _Divide_c40356c0ab504a9394d3d54abc68bfaf_Out_2, _Step_2a6ecea9c5ae4a20896d75eef11b522a_Out_2);
    surface.Alpha = _Step_2a6ecea9c5ae4a20896d75eef11b522a_Out_2;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS.xyz;
    output.ObjectSpacePosition = input.positionOS;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





    output.uv0 = input.texCoord0;
    output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

    ENDHLSL
}
Pass
{
    Name "DepthNormals"
    Tags
    {
        "LightMode" = "DepthNormals"
    }

        // Render State
        Cull Back
    Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
    ZTest LEqual
    ZWrite On

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 4.5
    #pragma exclude_renderers gles gles3 glcore
    #pragma multi_compile_instancing
    #pragma multi_compile _ DOTS_INSTANCING_ON
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>

        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _NORMALMAP 1
        #define _SPECULAR_SETUP
        #define _NORMAL_DROPOFF_OS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        float4 uv0 : TEXCOORD0;
        float4 uv1 : TEXCOORD1;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float3 normalWS;
        float4 tangentWS;
        float4 texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 WorldSpaceNormal;
        float4 uv0;
        float3 TimeParameters;
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        float3 interp0 : TEXCOORD0;
        float4 interp1 : TEXCOORD1;
        float4 interp2 : TEXCOORD2;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings(Varyings input)
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        output.interp0.xyz = input.normalWS;
        output.interp1.xyzw = input.tangentWS;
        output.interp2.xyzw = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings(PackedVaryings input)
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.normalWS = input.interp0.xyz;
        output.tangentWS = input.interp1.xyzw;
        output.texCoord0 = input.interp2.xyzw;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START(UnityPerMaterial)
float4 _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_Texture_1_TexelSize;
float Vector1_2f1e1aa506e142199a64d07139b44a85;
float _Materialised;
float Vector1_eee1783ae5744fb3b3f1036218fe3bdb;
float Vector1_6143018700ad4236ae154b2d19051c02;
float4 Color_f24be94f3f7140f2b052f1ea234c3ffb;
float Vector1_d7448e8c4bfe4629a845c4b4cf37f445;
float Vector1_b508357b1e0b4ebfae0a54a8a1d8153c;
CBUFFER_END

// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_Texture_1);
SAMPLER(sampler_SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_Texture_1);

// Graph Functions

void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
{
    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}


float2 Unity_GradientNoise_Dir_float(float2 p)
{
    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
    p = p % 289;
    // need full precision, otherwise half overflows when p > 1
    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
    x = (34 * x + 1) * x % 289;
    x = frac(x / 41) * 2 - 1;
    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
}

void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
{
    float2 p = UV * Scale;
    float2 ip = floor(p);
    float2 fp = frac(p);
    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
}

void Unity_Multiply_float(float A, float B, out float Out)
{
    Out = A * B;
}


inline float2 Unity_Voronoi_RandomVector_float(float2 UV, float offset)
{
    float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
    UV = frac(sin(mul(UV, m)));
    return float2(sin(UV.y * +offset) * 0.5 + 0.5, cos(UV.x * offset) * 0.5 + 0.5);
}

void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
{
    float2 g = floor(UV * CellDensity);
    float2 f = frac(UV * CellDensity);
    float t = 8.0;
    float3 res = float3(8.0, 0.0, 0.0);

    for (int y = -1; y <= 1; y++)
    {
        for (int x = -1; x <= 1; x++)
        {
            float2 lattice = float2(x,y);
            float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
            float d = distance(lattice + offset, f);

            if (d < res.x)
            {
                res = float3(d, offset.x, offset.y);
                Out = res.x;
                Cells = res.y;
            }
        }
    }
}

void Unity_Add_float(float A, float B, out float Out)
{
    Out = A + B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_Step_float(float Edge, float In, out float Out)
{
    Out = step(Edge, In);
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
    VertexDescription description = (VertexDescription)0;
    description.Position = IN.ObjectSpacePosition;
    description.Normal = IN.ObjectSpaceNormal;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float3 NormalOS;
    float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription)0;
    float _Property_6ee5d2a2b8bf49de954a3cd5216487cc_Out_0 = _Materialised;
    float _Remap_53339270754549bea2d7a6f99acc8e37_Out_3;
    Unity_Remap_float(_Property_6ee5d2a2b8bf49de954a3cd5216487cc_Out_0, float2 (1, 0), float2 (-0.15, 1.1), _Remap_53339270754549bea2d7a6f99acc8e37_Out_3);
    float _Property_c106932bbbf94ea89ec8d94076689161_Out_0 = Vector1_2f1e1aa506e142199a64d07139b44a85;
    float _GradientNoise_906c40673cc14548b509ba1d1ea2b14e_Out_2;
    Unity_GradientNoise_float(IN.uv0.xy, _Property_c106932bbbf94ea89ec8d94076689161_Out_0, _GradientNoise_906c40673cc14548b509ba1d1ea2b14e_Out_2);
    float _Multiply_6bc75468206749799ee0492aaac71cef_Out_2;
    Unity_Multiply_float(_GradientNoise_906c40673cc14548b509ba1d1ea2b14e_Out_2, 2, _Multiply_6bc75468206749799ee0492aaac71cef_Out_2);
    float _Property_cd0b606707f6467b993a0f84d74c2468_Out_0 = Vector1_6143018700ad4236ae154b2d19051c02;
    float _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Out_3;
    float _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Cells_4;
    Unity_Voronoi_float(IN.uv0.xy, IN.TimeParameters.x, _Property_cd0b606707f6467b993a0f84d74c2468_Out_0, _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Out_3, _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Cells_4);
    float _Add_ca098124b82e447ba61175254f1fadf4_Out_2;
    Unity_Add_float(_Multiply_6bc75468206749799ee0492aaac71cef_Out_2, _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Out_3, _Add_ca098124b82e447ba61175254f1fadf4_Out_2);
    float _Divide_c40356c0ab504a9394d3d54abc68bfaf_Out_2;
    Unity_Divide_float(_Add_ca098124b82e447ba61175254f1fadf4_Out_2, 3, _Divide_c40356c0ab504a9394d3d54abc68bfaf_Out_2);
    float _Step_2a6ecea9c5ae4a20896d75eef11b522a_Out_2;
    Unity_Step_float(_Remap_53339270754549bea2d7a6f99acc8e37_Out_3, _Divide_c40356c0ab504a9394d3d54abc68bfaf_Out_2, _Step_2a6ecea9c5ae4a20896d75eef11b522a_Out_2);
    surface.NormalOS = IN.ObjectSpaceNormal;
    surface.Alpha = _Step_2a6ecea9c5ae4a20896d75eef11b522a_Out_2;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS.xyz;
    output.ObjectSpacePosition = input.positionOS;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

    // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
    float3 unnormalizedNormalWS = input.normalWS;
    const float renormFactor = 1.0 / length(unnormalizedNormalWS);


    output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
    output.ObjectSpaceNormal = normalize(mul(output.WorldSpaceNormal, (float3x3) UNITY_MATRIX_M));           // transposed multiplication by inverse matrix to handle normal scale


    output.uv0 = input.texCoord0;
    output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

    ENDHLSL
}
Pass
{
    Name "Meta"
    Tags
    {
        "LightMode" = "Meta"
    }

        // Render State
        Cull Off

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 4.5
    #pragma exclude_renderers gles gles3 glcore
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
        // GraphKeywords: <None>

        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _NORMALMAP 1
        #define _SPECULAR_SETUP
        #define _NORMAL_DROPOFF_OS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        float4 uv0 : TEXCOORD0;
        float4 uv1 : TEXCOORD1;
        float4 uv2 : TEXCOORD2;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float4 texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
        float4 uv0;
        float3 TimeParameters;
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        float4 interp0 : TEXCOORD0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings(Varyings input)
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        output.interp0.xyzw = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings(PackedVaryings input)
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.texCoord0 = input.interp0.xyzw;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START(UnityPerMaterial)
float4 _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_Texture_1_TexelSize;
float Vector1_2f1e1aa506e142199a64d07139b44a85;
float _Materialised;
float Vector1_eee1783ae5744fb3b3f1036218fe3bdb;
float Vector1_6143018700ad4236ae154b2d19051c02;
float4 Color_f24be94f3f7140f2b052f1ea234c3ffb;
float Vector1_d7448e8c4bfe4629a845c4b4cf37f445;
float Vector1_b508357b1e0b4ebfae0a54a8a1d8153c;
CBUFFER_END

// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_Texture_1);
SAMPLER(sampler_SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_Texture_1);

// Graph Functions

void Unity_Multiply_float(float A, float B, out float Out)
{
    Out = A * B;
}

void Unity_RandomRange_float(float2 Seed, float Min, float Max, out float Out)
{
     float randomno = frac(sin(dot(Seed, float2(12.9898, 78.233))) * 43758.5453);
     Out = lerp(Min, Max, randomno);
}

void Unity_Twirl_float(float2 UV, float2 Center, float Strength, float2 Offset, out float2 Out)
{
    float2 delta = UV - Center;
    float angle = Strength * length(delta);
    float x = cos(angle) * delta.x - sin(angle) * delta.y;
    float y = sin(angle) * delta.x + cos(angle) * delta.y;
    Out = float2(x + Center.x + Offset.x, y + Center.y + Offset.y);
}

void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
{
    Out = UV * Tiling + Offset;
}


inline float Unity_SimpleNoise_RandomValue_float(float2 uv)
{
    return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
}

inline float Unity_SimpleNnoise_Interpolate_float(float a, float b, float t)
{
    return (1.0 - t) * a + (t * b);
}


inline float Unity_SimpleNoise_ValueNoise_float(float2 uv)
{
    float2 i = floor(uv);
    float2 f = frac(uv);
    f = f * f * (3.0 - 2.0 * f);

    uv = abs(frac(uv) - 0.5);
    float2 c0 = i + float2(0.0, 0.0);
    float2 c1 = i + float2(1.0, 0.0);
    float2 c2 = i + float2(0.0, 1.0);
    float2 c3 = i + float2(1.0, 1.0);
    float r0 = Unity_SimpleNoise_RandomValue_float(c0);
    float r1 = Unity_SimpleNoise_RandomValue_float(c1);
    float r2 = Unity_SimpleNoise_RandomValue_float(c2);
    float r3 = Unity_SimpleNoise_RandomValue_float(c3);

    float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
    float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
    float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
    return t;
}
void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
{
    float t = 0.0;

    float freq = pow(2.0, float(0));
    float amp = pow(0.5, float(3 - 0));
    t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

    freq = pow(2.0, float(1));
    amp = pow(0.5, float(3 - 1));
    t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

    freq = pow(2.0, float(2));
    amp = pow(0.5, float(3 - 2));
    t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

    Out = t;
}

void Unity_Add_float(float A, float B, out float Out)
{
    Out = A + B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_Step_float(float Edge, float In, out float Out)
{
    Out = step(Edge, In);
}

void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
{
    Out = A * B;
}

void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
{
    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}


float2 Unity_GradientNoise_Dir_float(float2 p)
{
    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
    p = p % 289;
    // need full precision, otherwise half overflows when p > 1
    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
    x = (34 * x + 1) * x % 289;
    x = frac(x / 41) * 2 - 1;
    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
}

void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
{
    float2 p = UV * Scale;
    float2 ip = floor(p);
    float2 fp = frac(p);
    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
}


inline float2 Unity_Voronoi_RandomVector_float(float2 UV, float offset)
{
    float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
    UV = frac(sin(mul(UV, m)));
    return float2(sin(UV.y * +offset) * 0.5 + 0.5, cos(UV.x * offset) * 0.5 + 0.5);
}

void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
{
    float2 g = floor(UV * CellDensity);
    float2 f = frac(UV * CellDensity);
    float t = 8.0;
    float3 res = float3(8.0, 0.0, 0.0);

    for (int y = -1; y <= 1; y++)
    {
        for (int x = -1; x <= 1; x++)
        {
            float2 lattice = float2(x,y);
            float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
            float d = distance(lattice + offset, f);

            if (d < res.x)
            {
                res = float3(d, offset.x, offset.y);
                Out = res.x;
                Cells = res.y;
            }
        }
    }
}

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Add_float4(float4 A, float4 B, out float4 Out)
{
    Out = A + B;
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
    VertexDescription description = (VertexDescription)0;
    description.Position = IN.ObjectSpacePosition;
    description.Normal = IN.ObjectSpaceNormal;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float3 BaseColor;
    float3 Emission;
    float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription)0;
    float _Split_9075b88e065c4620845a4bbb94507295_R_1 = SHADERGRAPH_OBJECT_POSITION[0];
    float _Split_9075b88e065c4620845a4bbb94507295_G_2 = SHADERGRAPH_OBJECT_POSITION[1];
    float _Split_9075b88e065c4620845a4bbb94507295_B_3 = SHADERGRAPH_OBJECT_POSITION[2];
    float _Split_9075b88e065c4620845a4bbb94507295_A_4 = 0;
    float _Multiply_9122215ecfa1426c8a05606961aa62f4_Out_2;
    Unity_Multiply_float(_Split_9075b88e065c4620845a4bbb94507295_R_1, _Split_9075b88e065c4620845a4bbb94507295_B_3, _Multiply_9122215ecfa1426c8a05606961aa62f4_Out_2);
    float _Multiply_2d509dc7f9f0402db69d4701ce482d7c_Out_2;
    Unity_Multiply_float(_Split_9075b88e065c4620845a4bbb94507295_G_2, _Split_9075b88e065c4620845a4bbb94507295_B_3, _Multiply_2d509dc7f9f0402db69d4701ce482d7c_Out_2);
    float2 _Vector2_25b956a15eb2450d82ffb981b718c892_Out_0 = float2(_Multiply_9122215ecfa1426c8a05606961aa62f4_Out_2, _Multiply_2d509dc7f9f0402db69d4701ce482d7c_Out_2);
    float _RandomRange_fab572807af44d4aa4d1c7c173801461_Out_3;
    Unity_RandomRange_float(_Vector2_25b956a15eb2450d82ffb981b718c892_Out_0, -1, 1, _RandomRange_fab572807af44d4aa4d1c7c173801461_Out_3);
    float2 _Twirl_344ad4db85314e5091310937b6b719d9_Out_4;
    Unity_Twirl_float(IN.uv0.xy, float2 (0.5, 0), _RandomRange_fab572807af44d4aa4d1c7c173801461_Out_3, float2 (0, 0), _Twirl_344ad4db85314e5091310937b6b719d9_Out_4);
    float _RandomRange_f9ab629e6ac344edb552ad4aea6e90d3_Out_3;
    Unity_RandomRange_float(_Vector2_25b956a15eb2450d82ffb981b718c892_Out_0, 0, 1, _RandomRange_f9ab629e6ac344edb552ad4aea6e90d3_Out_3);
    float _RandomRange_24cd5e2a255647cbb8fffdbe74a5ea32_Out_3;
    Unity_RandomRange_float(_Vector2_25b956a15eb2450d82ffb981b718c892_Out_0, 10, 30, _RandomRange_24cd5e2a255647cbb8fffdbe74a5ea32_Out_3);
    float2 _Vector2_6d5f4d74c2314cdd8e1288d96858efd4_Out_0 = float2(_RandomRange_f9ab629e6ac344edb552ad4aea6e90d3_Out_3, _RandomRange_24cd5e2a255647cbb8fffdbe74a5ea32_Out_3);
    float2 _TilingAndOffset_6d6a741583cb4e7d861a326a67a95b7e_Out_3;
    Unity_TilingAndOffset_float(_Twirl_344ad4db85314e5091310937b6b719d9_Out_4, _Vector2_6d5f4d74c2314cdd8e1288d96858efd4_Out_0, float2 (0, 0), _TilingAndOffset_6d6a741583cb4e7d861a326a67a95b7e_Out_3);
    float _RandomRange_958165b7c3c245b19a12b674d6634371_Out_3;
    Unity_RandomRange_float(_Vector2_25b956a15eb2450d82ffb981b718c892_Out_0, 500, 700, _RandomRange_958165b7c3c245b19a12b674d6634371_Out_3);
    float _SimpleNoise_4258d5b4269041c2b55ddb7d098e0dff_Out_2;
    Unity_SimpleNoise_float(_TilingAndOffset_6d6a741583cb4e7d861a326a67a95b7e_Out_3, _RandomRange_958165b7c3c245b19a12b674d6634371_Out_3, _SimpleNoise_4258d5b4269041c2b55ddb7d098e0dff_Out_2);
    float _RandomRange_c15bab0ae8fb4570b6bacb91e8c7b8a6_Out_3;
    Unity_RandomRange_float(_Vector2_25b956a15eb2450d82ffb981b718c892_Out_0, 150, 200, _RandomRange_c15bab0ae8fb4570b6bacb91e8c7b8a6_Out_3);
    float _SimpleNoise_2eb21a33aa7c4e3b84decb54cd5d5570_Out_2;
    Unity_SimpleNoise_float(IN.uv0.xy, _RandomRange_c15bab0ae8fb4570b6bacb91e8c7b8a6_Out_3, _SimpleNoise_2eb21a33aa7c4e3b84decb54cd5d5570_Out_2);
    float _Multiply_89d7189c8fba48e5b757d93014bfd557_Out_2;
    Unity_Multiply_float(3, _SimpleNoise_2eb21a33aa7c4e3b84decb54cd5d5570_Out_2, _Multiply_89d7189c8fba48e5b757d93014bfd557_Out_2);
    float _Add_a97a2c2aa00b452bb1df95eeced7cfb6_Out_2;
    Unity_Add_float(_SimpleNoise_4258d5b4269041c2b55ddb7d098e0dff_Out_2, _Multiply_89d7189c8fba48e5b757d93014bfd557_Out_2, _Add_a97a2c2aa00b452bb1df95eeced7cfb6_Out_2);
    float _Divide_e6407003f1734725bac05ea6e13d0c99_Out_2;
    Unity_Divide_float(_Add_a97a2c2aa00b452bb1df95eeced7cfb6_Out_2, 4, _Divide_e6407003f1734725bac05ea6e13d0c99_Out_2);
    float _Property_b576b9fc8c954aca84f6b6155afa5fa9_Out_0 = Vector1_d7448e8c4bfe4629a845c4b4cf37f445;
    float _Step_a0998484051a4502944b2193794ec2af_Out_2;
    Unity_Step_float(_Property_b576b9fc8c954aca84f6b6155afa5fa9_Out_0, _Divide_e6407003f1734725bac05ea6e13d0c99_Out_2, _Step_a0998484051a4502944b2193794ec2af_Out_2);
    float _Property_7735a84e56694723969c1dc37628b724_Out_0 = Vector1_b508357b1e0b4ebfae0a54a8a1d8153c;
    float _Multiply_9e543f00b7e34b0086558b8fef2e68b9_Out_2;
    Unity_Multiply_float(IN.TimeParameters.x, _Property_7735a84e56694723969c1dc37628b724_Out_0, _Multiply_9e543f00b7e34b0086558b8fef2e68b9_Out_2);
    float _Multiply_f1858fc18ecf4faa828d7c4a0fa84c4d_Out_2;
    Unity_Multiply_float(_Multiply_9e543f00b7e34b0086558b8fef2e68b9_Out_2, 1.5, _Multiply_f1858fc18ecf4faa828d7c4a0fa84c4d_Out_2);
    float2 _Vector2_330142494d0d4792a0c710a2364a5442_Out_0 = float2(_Multiply_9e543f00b7e34b0086558b8fef2e68b9_Out_2, _Multiply_f1858fc18ecf4faa828d7c4a0fa84c4d_Out_2);
    float2 _TilingAndOffset_85c121fb05354962a60ed37d3ef9f813_Out_3;
    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_330142494d0d4792a0c710a2364a5442_Out_0, _TilingAndOffset_85c121fb05354962a60ed37d3ef9f813_Out_3);
    float4 _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_RGBA_0 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_Texture_1).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_Texture_1).samplerstate, _TilingAndOffset_85c121fb05354962a60ed37d3ef9f813_Out_3);
    float _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_R_4 = _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_RGBA_0.r;
    float _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_G_5 = _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_RGBA_0.g;
    float _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_B_6 = _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_RGBA_0.b;
    float _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_A_7 = _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_RGBA_0.a;
    float4 _Multiply_b4ab13caabac4c0d974f6568c10abeda_Out_2;
    Unity_Multiply_float((_Step_a0998484051a4502944b2193794ec2af_Out_2.xxxx), _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_RGBA_0, _Multiply_b4ab13caabac4c0d974f6568c10abeda_Out_2);
    float _Property_6ee5d2a2b8bf49de954a3cd5216487cc_Out_0 = _Materialised;
    float _Remap_53339270754549bea2d7a6f99acc8e37_Out_3;
    Unity_Remap_float(_Property_6ee5d2a2b8bf49de954a3cd5216487cc_Out_0, float2 (1, 0), float2 (-0.15, 1.1), _Remap_53339270754549bea2d7a6f99acc8e37_Out_3);
    float _Property_460e92d704484d58a231c183f394e581_Out_0 = Vector1_eee1783ae5744fb3b3f1036218fe3bdb;
    float _Add_6318c4fdc2bf45e78bacfb15c8b5e69f_Out_2;
    Unity_Add_float(_Remap_53339270754549bea2d7a6f99acc8e37_Out_3, _Property_460e92d704484d58a231c183f394e581_Out_0, _Add_6318c4fdc2bf45e78bacfb15c8b5e69f_Out_2);
    float _Property_c106932bbbf94ea89ec8d94076689161_Out_0 = Vector1_2f1e1aa506e142199a64d07139b44a85;
    float _GradientNoise_906c40673cc14548b509ba1d1ea2b14e_Out_2;
    Unity_GradientNoise_float(IN.uv0.xy, _Property_c106932bbbf94ea89ec8d94076689161_Out_0, _GradientNoise_906c40673cc14548b509ba1d1ea2b14e_Out_2);
    float _Multiply_6bc75468206749799ee0492aaac71cef_Out_2;
    Unity_Multiply_float(_GradientNoise_906c40673cc14548b509ba1d1ea2b14e_Out_2, 2, _Multiply_6bc75468206749799ee0492aaac71cef_Out_2);
    float _Property_cd0b606707f6467b993a0f84d74c2468_Out_0 = Vector1_6143018700ad4236ae154b2d19051c02;
    float _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Out_3;
    float _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Cells_4;
    Unity_Voronoi_float(IN.uv0.xy, IN.TimeParameters.x, _Property_cd0b606707f6467b993a0f84d74c2468_Out_0, _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Out_3, _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Cells_4);
    float _Add_ca098124b82e447ba61175254f1fadf4_Out_2;
    Unity_Add_float(_Multiply_6bc75468206749799ee0492aaac71cef_Out_2, _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Out_3, _Add_ca098124b82e447ba61175254f1fadf4_Out_2);
    float _Divide_c40356c0ab504a9394d3d54abc68bfaf_Out_2;
    Unity_Divide_float(_Add_ca098124b82e447ba61175254f1fadf4_Out_2, 3, _Divide_c40356c0ab504a9394d3d54abc68bfaf_Out_2);
    float _Step_1fe338b5168449a8a07bf9b80f31d4fa_Out_2;
    Unity_Step_float(_Add_6318c4fdc2bf45e78bacfb15c8b5e69f_Out_2, _Divide_c40356c0ab504a9394d3d54abc68bfaf_Out_2, _Step_1fe338b5168449a8a07bf9b80f31d4fa_Out_2);
    float4 _Multiply_28b8a693ce7243d4b61d000abefaeae5_Out_2;
    Unity_Multiply_float(_Multiply_b4ab13caabac4c0d974f6568c10abeda_Out_2, (_Step_1fe338b5168449a8a07bf9b80f31d4fa_Out_2.xxxx), _Multiply_28b8a693ce7243d4b61d000abefaeae5_Out_2);
    float _OneMinus_b1d4304c2ad94669a04a9f96eb7fc751_Out_1;
    Unity_OneMinus_float(_Step_1fe338b5168449a8a07bf9b80f31d4fa_Out_2, _OneMinus_b1d4304c2ad94669a04a9f96eb7fc751_Out_1);
    float4 _Add_133da9716087442ea5bc5663dfeffebf_Out_2;
    Unity_Add_float4(_Multiply_28b8a693ce7243d4b61d000abefaeae5_Out_2, (_OneMinus_b1d4304c2ad94669a04a9f96eb7fc751_Out_1.xxxx), _Add_133da9716087442ea5bc5663dfeffebf_Out_2);
    float4 _Property_caf147c757e749ca85de849e9b9de43a_Out_0 = IsGammaSpace() ? LinearToSRGB(Color_f24be94f3f7140f2b052f1ea234c3ffb) : Color_f24be94f3f7140f2b052f1ea234c3ffb;
    float4 _Multiply_1ce2bd970f4148e2b1aad044712adcff_Out_2;
    Unity_Multiply_float(_Add_133da9716087442ea5bc5663dfeffebf_Out_2, _Property_caf147c757e749ca85de849e9b9de43a_Out_0, _Multiply_1ce2bd970f4148e2b1aad044712adcff_Out_2);
    float _Step_2a6ecea9c5ae4a20896d75eef11b522a_Out_2;
    Unity_Step_float(_Remap_53339270754549bea2d7a6f99acc8e37_Out_3, _Divide_c40356c0ab504a9394d3d54abc68bfaf_Out_2, _Step_2a6ecea9c5ae4a20896d75eef11b522a_Out_2);
    surface.BaseColor = (_Divide_e6407003f1734725bac05ea6e13d0c99_Out_2.xxx);
    surface.Emission = (_Multiply_1ce2bd970f4148e2b1aad044712adcff_Out_2.xyz);
    surface.Alpha = _Step_2a6ecea9c5ae4a20896d75eef11b522a_Out_2;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS.xyz;
    output.ObjectSpacePosition = input.positionOS;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





    output.uv0 = input.texCoord0;
    output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

    ENDHLSL
}
Pass
{
        // Name: <None>
        Tags
        {
            "LightMode" = "Universal2D"
        }

        // Render State
        Cull Back
    Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
    ZTest LEqual
    ZWrite Off

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 4.5
    #pragma exclude_renderers gles gles3 glcore
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>

        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _NORMALMAP 1
        #define _SPECULAR_SETUP
        #define _NORMAL_DROPOFF_OS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_2D
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        float4 uv0 : TEXCOORD0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float4 texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
        float4 uv0;
        float3 TimeParameters;
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        float4 interp0 : TEXCOORD0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings(Varyings input)
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        output.interp0.xyzw = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings(PackedVaryings input)
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.texCoord0 = input.interp0.xyzw;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START(UnityPerMaterial)
float4 _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_Texture_1_TexelSize;
float Vector1_2f1e1aa506e142199a64d07139b44a85;
float _Materialised;
float Vector1_eee1783ae5744fb3b3f1036218fe3bdb;
float Vector1_6143018700ad4236ae154b2d19051c02;
float4 Color_f24be94f3f7140f2b052f1ea234c3ffb;
float Vector1_d7448e8c4bfe4629a845c4b4cf37f445;
float Vector1_b508357b1e0b4ebfae0a54a8a1d8153c;
CBUFFER_END

// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_Texture_1);
SAMPLER(sampler_SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_Texture_1);

// Graph Functions

void Unity_Multiply_float(float A, float B, out float Out)
{
    Out = A * B;
}

void Unity_RandomRange_float(float2 Seed, float Min, float Max, out float Out)
{
     float randomno = frac(sin(dot(Seed, float2(12.9898, 78.233))) * 43758.5453);
     Out = lerp(Min, Max, randomno);
}

void Unity_Twirl_float(float2 UV, float2 Center, float Strength, float2 Offset, out float2 Out)
{
    float2 delta = UV - Center;
    float angle = Strength * length(delta);
    float x = cos(angle) * delta.x - sin(angle) * delta.y;
    float y = sin(angle) * delta.x + cos(angle) * delta.y;
    Out = float2(x + Center.x + Offset.x, y + Center.y + Offset.y);
}

void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
{
    Out = UV * Tiling + Offset;
}


inline float Unity_SimpleNoise_RandomValue_float(float2 uv)
{
    return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
}

inline float Unity_SimpleNnoise_Interpolate_float(float a, float b, float t)
{
    return (1.0 - t) * a + (t * b);
}


inline float Unity_SimpleNoise_ValueNoise_float(float2 uv)
{
    float2 i = floor(uv);
    float2 f = frac(uv);
    f = f * f * (3.0 - 2.0 * f);

    uv = abs(frac(uv) - 0.5);
    float2 c0 = i + float2(0.0, 0.0);
    float2 c1 = i + float2(1.0, 0.0);
    float2 c2 = i + float2(0.0, 1.0);
    float2 c3 = i + float2(1.0, 1.0);
    float r0 = Unity_SimpleNoise_RandomValue_float(c0);
    float r1 = Unity_SimpleNoise_RandomValue_float(c1);
    float r2 = Unity_SimpleNoise_RandomValue_float(c2);
    float r3 = Unity_SimpleNoise_RandomValue_float(c3);

    float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
    float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
    float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
    return t;
}
void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
{
    float t = 0.0;

    float freq = pow(2.0, float(0));
    float amp = pow(0.5, float(3 - 0));
    t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

    freq = pow(2.0, float(1));
    amp = pow(0.5, float(3 - 1));
    t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

    freq = pow(2.0, float(2));
    amp = pow(0.5, float(3 - 2));
    t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

    Out = t;
}

void Unity_Add_float(float A, float B, out float Out)
{
    Out = A + B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
{
    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}


float2 Unity_GradientNoise_Dir_float(float2 p)
{
    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
    p = p % 289;
    // need full precision, otherwise half overflows when p > 1
    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
    x = (34 * x + 1) * x % 289;
    x = frac(x / 41) * 2 - 1;
    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
}

void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
{
    float2 p = UV * Scale;
    float2 ip = floor(p);
    float2 fp = frac(p);
    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
}


inline float2 Unity_Voronoi_RandomVector_float(float2 UV, float offset)
{
    float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
    UV = frac(sin(mul(UV, m)));
    return float2(sin(UV.y * +offset) * 0.5 + 0.5, cos(UV.x * offset) * 0.5 + 0.5);
}

void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
{
    float2 g = floor(UV * CellDensity);
    float2 f = frac(UV * CellDensity);
    float t = 8.0;
    float3 res = float3(8.0, 0.0, 0.0);

    for (int y = -1; y <= 1; y++)
    {
        for (int x = -1; x <= 1; x++)
        {
            float2 lattice = float2(x,y);
            float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
            float d = distance(lattice + offset, f);

            if (d < res.x)
            {
                res = float3(d, offset.x, offset.y);
                Out = res.x;
                Cells = res.y;
            }
        }
    }
}

void Unity_Step_float(float Edge, float In, out float Out)
{
    Out = step(Edge, In);
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
    VertexDescription description = (VertexDescription)0;
    description.Position = IN.ObjectSpacePosition;
    description.Normal = IN.ObjectSpaceNormal;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float3 BaseColor;
    float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription)0;
    float _Split_9075b88e065c4620845a4bbb94507295_R_1 = SHADERGRAPH_OBJECT_POSITION[0];
    float _Split_9075b88e065c4620845a4bbb94507295_G_2 = SHADERGRAPH_OBJECT_POSITION[1];
    float _Split_9075b88e065c4620845a4bbb94507295_B_3 = SHADERGRAPH_OBJECT_POSITION[2];
    float _Split_9075b88e065c4620845a4bbb94507295_A_4 = 0;
    float _Multiply_9122215ecfa1426c8a05606961aa62f4_Out_2;
    Unity_Multiply_float(_Split_9075b88e065c4620845a4bbb94507295_R_1, _Split_9075b88e065c4620845a4bbb94507295_B_3, _Multiply_9122215ecfa1426c8a05606961aa62f4_Out_2);
    float _Multiply_2d509dc7f9f0402db69d4701ce482d7c_Out_2;
    Unity_Multiply_float(_Split_9075b88e065c4620845a4bbb94507295_G_2, _Split_9075b88e065c4620845a4bbb94507295_B_3, _Multiply_2d509dc7f9f0402db69d4701ce482d7c_Out_2);
    float2 _Vector2_25b956a15eb2450d82ffb981b718c892_Out_0 = float2(_Multiply_9122215ecfa1426c8a05606961aa62f4_Out_2, _Multiply_2d509dc7f9f0402db69d4701ce482d7c_Out_2);
    float _RandomRange_fab572807af44d4aa4d1c7c173801461_Out_3;
    Unity_RandomRange_float(_Vector2_25b956a15eb2450d82ffb981b718c892_Out_0, -1, 1, _RandomRange_fab572807af44d4aa4d1c7c173801461_Out_3);
    float2 _Twirl_344ad4db85314e5091310937b6b719d9_Out_4;
    Unity_Twirl_float(IN.uv0.xy, float2 (0.5, 0), _RandomRange_fab572807af44d4aa4d1c7c173801461_Out_3, float2 (0, 0), _Twirl_344ad4db85314e5091310937b6b719d9_Out_4);
    float _RandomRange_f9ab629e6ac344edb552ad4aea6e90d3_Out_3;
    Unity_RandomRange_float(_Vector2_25b956a15eb2450d82ffb981b718c892_Out_0, 0, 1, _RandomRange_f9ab629e6ac344edb552ad4aea6e90d3_Out_3);
    float _RandomRange_24cd5e2a255647cbb8fffdbe74a5ea32_Out_3;
    Unity_RandomRange_float(_Vector2_25b956a15eb2450d82ffb981b718c892_Out_0, 10, 30, _RandomRange_24cd5e2a255647cbb8fffdbe74a5ea32_Out_3);
    float2 _Vector2_6d5f4d74c2314cdd8e1288d96858efd4_Out_0 = float2(_RandomRange_f9ab629e6ac344edb552ad4aea6e90d3_Out_3, _RandomRange_24cd5e2a255647cbb8fffdbe74a5ea32_Out_3);
    float2 _TilingAndOffset_6d6a741583cb4e7d861a326a67a95b7e_Out_3;
    Unity_TilingAndOffset_float(_Twirl_344ad4db85314e5091310937b6b719d9_Out_4, _Vector2_6d5f4d74c2314cdd8e1288d96858efd4_Out_0, float2 (0, 0), _TilingAndOffset_6d6a741583cb4e7d861a326a67a95b7e_Out_3);
    float _RandomRange_958165b7c3c245b19a12b674d6634371_Out_3;
    Unity_RandomRange_float(_Vector2_25b956a15eb2450d82ffb981b718c892_Out_0, 500, 700, _RandomRange_958165b7c3c245b19a12b674d6634371_Out_3);
    float _SimpleNoise_4258d5b4269041c2b55ddb7d098e0dff_Out_2;
    Unity_SimpleNoise_float(_TilingAndOffset_6d6a741583cb4e7d861a326a67a95b7e_Out_3, _RandomRange_958165b7c3c245b19a12b674d6634371_Out_3, _SimpleNoise_4258d5b4269041c2b55ddb7d098e0dff_Out_2);
    float _RandomRange_c15bab0ae8fb4570b6bacb91e8c7b8a6_Out_3;
    Unity_RandomRange_float(_Vector2_25b956a15eb2450d82ffb981b718c892_Out_0, 150, 200, _RandomRange_c15bab0ae8fb4570b6bacb91e8c7b8a6_Out_3);
    float _SimpleNoise_2eb21a33aa7c4e3b84decb54cd5d5570_Out_2;
    Unity_SimpleNoise_float(IN.uv0.xy, _RandomRange_c15bab0ae8fb4570b6bacb91e8c7b8a6_Out_3, _SimpleNoise_2eb21a33aa7c4e3b84decb54cd5d5570_Out_2);
    float _Multiply_89d7189c8fba48e5b757d93014bfd557_Out_2;
    Unity_Multiply_float(3, _SimpleNoise_2eb21a33aa7c4e3b84decb54cd5d5570_Out_2, _Multiply_89d7189c8fba48e5b757d93014bfd557_Out_2);
    float _Add_a97a2c2aa00b452bb1df95eeced7cfb6_Out_2;
    Unity_Add_float(_SimpleNoise_4258d5b4269041c2b55ddb7d098e0dff_Out_2, _Multiply_89d7189c8fba48e5b757d93014bfd557_Out_2, _Add_a97a2c2aa00b452bb1df95eeced7cfb6_Out_2);
    float _Divide_e6407003f1734725bac05ea6e13d0c99_Out_2;
    Unity_Divide_float(_Add_a97a2c2aa00b452bb1df95eeced7cfb6_Out_2, 4, _Divide_e6407003f1734725bac05ea6e13d0c99_Out_2);
    float _Property_6ee5d2a2b8bf49de954a3cd5216487cc_Out_0 = _Materialised;
    float _Remap_53339270754549bea2d7a6f99acc8e37_Out_3;
    Unity_Remap_float(_Property_6ee5d2a2b8bf49de954a3cd5216487cc_Out_0, float2 (1, 0), float2 (-0.15, 1.1), _Remap_53339270754549bea2d7a6f99acc8e37_Out_3);
    float _Property_c106932bbbf94ea89ec8d94076689161_Out_0 = Vector1_2f1e1aa506e142199a64d07139b44a85;
    float _GradientNoise_906c40673cc14548b509ba1d1ea2b14e_Out_2;
    Unity_GradientNoise_float(IN.uv0.xy, _Property_c106932bbbf94ea89ec8d94076689161_Out_0, _GradientNoise_906c40673cc14548b509ba1d1ea2b14e_Out_2);
    float _Multiply_6bc75468206749799ee0492aaac71cef_Out_2;
    Unity_Multiply_float(_GradientNoise_906c40673cc14548b509ba1d1ea2b14e_Out_2, 2, _Multiply_6bc75468206749799ee0492aaac71cef_Out_2);
    float _Property_cd0b606707f6467b993a0f84d74c2468_Out_0 = Vector1_6143018700ad4236ae154b2d19051c02;
    float _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Out_3;
    float _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Cells_4;
    Unity_Voronoi_float(IN.uv0.xy, IN.TimeParameters.x, _Property_cd0b606707f6467b993a0f84d74c2468_Out_0, _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Out_3, _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Cells_4);
    float _Add_ca098124b82e447ba61175254f1fadf4_Out_2;
    Unity_Add_float(_Multiply_6bc75468206749799ee0492aaac71cef_Out_2, _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Out_3, _Add_ca098124b82e447ba61175254f1fadf4_Out_2);
    float _Divide_c40356c0ab504a9394d3d54abc68bfaf_Out_2;
    Unity_Divide_float(_Add_ca098124b82e447ba61175254f1fadf4_Out_2, 3, _Divide_c40356c0ab504a9394d3d54abc68bfaf_Out_2);
    float _Step_2a6ecea9c5ae4a20896d75eef11b522a_Out_2;
    Unity_Step_float(_Remap_53339270754549bea2d7a6f99acc8e37_Out_3, _Divide_c40356c0ab504a9394d3d54abc68bfaf_Out_2, _Step_2a6ecea9c5ae4a20896d75eef11b522a_Out_2);
    surface.BaseColor = (_Divide_e6407003f1734725bac05ea6e13d0c99_Out_2.xxx);
    surface.Alpha = _Step_2a6ecea9c5ae4a20896d75eef11b522a_Out_2;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS.xyz;
    output.ObjectSpacePosition = input.positionOS;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





    output.uv0 = input.texCoord0;
    output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

    ENDHLSL
}
    }
        SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue" = "Transparent"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

        // Render State
        Cull Back
    Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
    ZTest LEqual
    ZWrite Off

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 2.0
    #pragma only_renderers gles gles3 glcore d3d11
    #pragma multi_compile_instancing
    #pragma multi_compile_fog
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
    #pragma multi_compile _ LIGHTMAP_ON
    #pragma multi_compile _ DIRLIGHTMAP_COMBINED
    #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
    #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
    #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
    #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
    #pragma multi_compile _ _SHADOWS_SOFT
    #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
    #pragma multi_compile _ SHADOWS_SHADOWMASK
        // GraphKeywords: <None>

        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _NORMALMAP 1
        #define _SPECULAR_SETUP
        #define _NORMAL_DROPOFF_OS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        float4 uv0 : TEXCOORD0;
        float4 uv1 : TEXCOORD1;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float3 positionWS;
        float3 normalWS;
        float4 tangentWS;
        float4 texCoord0;
        float3 viewDirectionWS;
        #if defined(LIGHTMAP_ON)
        float2 lightmapUV;
        #endif
        #if !defined(LIGHTMAP_ON)
        float3 sh;
        #endif
        float4 fogFactorAndVertexLight;
        float4 shadowCoord;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 WorldSpaceNormal;
        float4 uv0;
        float3 TimeParameters;
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        float3 interp0 : TEXCOORD0;
        float3 interp1 : TEXCOORD1;
        float4 interp2 : TEXCOORD2;
        float4 interp3 : TEXCOORD3;
        float3 interp4 : TEXCOORD4;
        #if defined(LIGHTMAP_ON)
        float2 interp5 : TEXCOORD5;
        #endif
        #if !defined(LIGHTMAP_ON)
        float3 interp6 : TEXCOORD6;
        #endif
        float4 interp7 : TEXCOORD7;
        float4 interp8 : TEXCOORD8;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings(Varyings input)
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        output.interp0.xyz = input.positionWS;
        output.interp1.xyz = input.normalWS;
        output.interp2.xyzw = input.tangentWS;
        output.interp3.xyzw = input.texCoord0;
        output.interp4.xyz = input.viewDirectionWS;
        #if defined(LIGHTMAP_ON)
        output.interp5.xy = input.lightmapUV;
        #endif
        #if !defined(LIGHTMAP_ON)
        output.interp6.xyz = input.sh;
        #endif
        output.interp7.xyzw = input.fogFactorAndVertexLight;
        output.interp8.xyzw = input.shadowCoord;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings(PackedVaryings input)
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.positionWS = input.interp0.xyz;
        output.normalWS = input.interp1.xyz;
        output.tangentWS = input.interp2.xyzw;
        output.texCoord0 = input.interp3.xyzw;
        output.viewDirectionWS = input.interp4.xyz;
        #if defined(LIGHTMAP_ON)
        output.lightmapUV = input.interp5.xy;
        #endif
        #if !defined(LIGHTMAP_ON)
        output.sh = input.interp6.xyz;
        #endif
        output.fogFactorAndVertexLight = input.interp7.xyzw;
        output.shadowCoord = input.interp8.xyzw;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START(UnityPerMaterial)
float4 _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_Texture_1_TexelSize;
float Vector1_2f1e1aa506e142199a64d07139b44a85;
float _Materialised;
float Vector1_eee1783ae5744fb3b3f1036218fe3bdb;
float Vector1_6143018700ad4236ae154b2d19051c02;
float4 Color_f24be94f3f7140f2b052f1ea234c3ffb;
float Vector1_d7448e8c4bfe4629a845c4b4cf37f445;
float Vector1_b508357b1e0b4ebfae0a54a8a1d8153c;
CBUFFER_END

// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_Texture_1);
SAMPLER(sampler_SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_Texture_1);

// Graph Functions

void Unity_Multiply_float(float A, float B, out float Out)
{
    Out = A * B;
}

void Unity_RandomRange_float(float2 Seed, float Min, float Max, out float Out)
{
     float randomno = frac(sin(dot(Seed, float2(12.9898, 78.233))) * 43758.5453);
     Out = lerp(Min, Max, randomno);
}

void Unity_Twirl_float(float2 UV, float2 Center, float Strength, float2 Offset, out float2 Out)
{
    float2 delta = UV - Center;
    float angle = Strength * length(delta);
    float x = cos(angle) * delta.x - sin(angle) * delta.y;
    float y = sin(angle) * delta.x + cos(angle) * delta.y;
    Out = float2(x + Center.x + Offset.x, y + Center.y + Offset.y);
}

void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
{
    Out = UV * Tiling + Offset;
}


inline float Unity_SimpleNoise_RandomValue_float(float2 uv)
{
    return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
}

inline float Unity_SimpleNnoise_Interpolate_float(float a, float b, float t)
{
    return (1.0 - t) * a + (t * b);
}


inline float Unity_SimpleNoise_ValueNoise_float(float2 uv)
{
    float2 i = floor(uv);
    float2 f = frac(uv);
    f = f * f * (3.0 - 2.0 * f);

    uv = abs(frac(uv) - 0.5);
    float2 c0 = i + float2(0.0, 0.0);
    float2 c1 = i + float2(1.0, 0.0);
    float2 c2 = i + float2(0.0, 1.0);
    float2 c3 = i + float2(1.0, 1.0);
    float r0 = Unity_SimpleNoise_RandomValue_float(c0);
    float r1 = Unity_SimpleNoise_RandomValue_float(c1);
    float r2 = Unity_SimpleNoise_RandomValue_float(c2);
    float r3 = Unity_SimpleNoise_RandomValue_float(c3);

    float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
    float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
    float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
    return t;
}
void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
{
    float t = 0.0;

    float freq = pow(2.0, float(0));
    float amp = pow(0.5, float(3 - 0));
    t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

    freq = pow(2.0, float(1));
    amp = pow(0.5, float(3 - 1));
    t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

    freq = pow(2.0, float(2));
    amp = pow(0.5, float(3 - 2));
    t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

    Out = t;
}

void Unity_Add_float(float A, float B, out float Out)
{
    Out = A + B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_Step_float(float Edge, float In, out float Out)
{
    Out = step(Edge, In);
}

void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
{
    Out = A * B;
}

void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
{
    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}


float2 Unity_GradientNoise_Dir_float(float2 p)
{
    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
    p = p % 289;
    // need full precision, otherwise half overflows when p > 1
    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
    x = (34 * x + 1) * x % 289;
    x = frac(x / 41) * 2 - 1;
    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
}

void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
{
    float2 p = UV * Scale;
    float2 ip = floor(p);
    float2 fp = frac(p);
    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
}


inline float2 Unity_Voronoi_RandomVector_float(float2 UV, float offset)
{
    float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
    UV = frac(sin(mul(UV, m)));
    return float2(sin(UV.y * +offset) * 0.5 + 0.5, cos(UV.x * offset) * 0.5 + 0.5);
}

void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
{
    float2 g = floor(UV * CellDensity);
    float2 f = frac(UV * CellDensity);
    float t = 8.0;
    float3 res = float3(8.0, 0.0, 0.0);

    for (int y = -1; y <= 1; y++)
    {
        for (int x = -1; x <= 1; x++)
        {
            float2 lattice = float2(x,y);
            float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
            float d = distance(lattice + offset, f);

            if (d < res.x)
            {
                res = float3(d, offset.x, offset.y);
                Out = res.x;
                Cells = res.y;
            }
        }
    }
}

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Add_float4(float4 A, float4 B, out float4 Out)
{
    Out = A + B;
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
    VertexDescription description = (VertexDescription)0;
    description.Position = IN.ObjectSpacePosition;
    description.Normal = IN.ObjectSpaceNormal;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float3 BaseColor;
    float3 NormalOS;
    float3 Emission;
    float3 Specular;
    float Smoothness;
    float Occlusion;
    float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription)0;
    float _Split_9075b88e065c4620845a4bbb94507295_R_1 = SHADERGRAPH_OBJECT_POSITION[0];
    float _Split_9075b88e065c4620845a4bbb94507295_G_2 = SHADERGRAPH_OBJECT_POSITION[1];
    float _Split_9075b88e065c4620845a4bbb94507295_B_3 = SHADERGRAPH_OBJECT_POSITION[2];
    float _Split_9075b88e065c4620845a4bbb94507295_A_4 = 0;
    float _Multiply_9122215ecfa1426c8a05606961aa62f4_Out_2;
    Unity_Multiply_float(_Split_9075b88e065c4620845a4bbb94507295_R_1, _Split_9075b88e065c4620845a4bbb94507295_B_3, _Multiply_9122215ecfa1426c8a05606961aa62f4_Out_2);
    float _Multiply_2d509dc7f9f0402db69d4701ce482d7c_Out_2;
    Unity_Multiply_float(_Split_9075b88e065c4620845a4bbb94507295_G_2, _Split_9075b88e065c4620845a4bbb94507295_B_3, _Multiply_2d509dc7f9f0402db69d4701ce482d7c_Out_2);
    float2 _Vector2_25b956a15eb2450d82ffb981b718c892_Out_0 = float2(_Multiply_9122215ecfa1426c8a05606961aa62f4_Out_2, _Multiply_2d509dc7f9f0402db69d4701ce482d7c_Out_2);
    float _RandomRange_fab572807af44d4aa4d1c7c173801461_Out_3;
    Unity_RandomRange_float(_Vector2_25b956a15eb2450d82ffb981b718c892_Out_0, -1, 1, _RandomRange_fab572807af44d4aa4d1c7c173801461_Out_3);
    float2 _Twirl_344ad4db85314e5091310937b6b719d9_Out_4;
    Unity_Twirl_float(IN.uv0.xy, float2 (0.5, 0), _RandomRange_fab572807af44d4aa4d1c7c173801461_Out_3, float2 (0, 0), _Twirl_344ad4db85314e5091310937b6b719d9_Out_4);
    float _RandomRange_f9ab629e6ac344edb552ad4aea6e90d3_Out_3;
    Unity_RandomRange_float(_Vector2_25b956a15eb2450d82ffb981b718c892_Out_0, 0, 1, _RandomRange_f9ab629e6ac344edb552ad4aea6e90d3_Out_3);
    float _RandomRange_24cd5e2a255647cbb8fffdbe74a5ea32_Out_3;
    Unity_RandomRange_float(_Vector2_25b956a15eb2450d82ffb981b718c892_Out_0, 10, 30, _RandomRange_24cd5e2a255647cbb8fffdbe74a5ea32_Out_3);
    float2 _Vector2_6d5f4d74c2314cdd8e1288d96858efd4_Out_0 = float2(_RandomRange_f9ab629e6ac344edb552ad4aea6e90d3_Out_3, _RandomRange_24cd5e2a255647cbb8fffdbe74a5ea32_Out_3);
    float2 _TilingAndOffset_6d6a741583cb4e7d861a326a67a95b7e_Out_3;
    Unity_TilingAndOffset_float(_Twirl_344ad4db85314e5091310937b6b719d9_Out_4, _Vector2_6d5f4d74c2314cdd8e1288d96858efd4_Out_0, float2 (0, 0), _TilingAndOffset_6d6a741583cb4e7d861a326a67a95b7e_Out_3);
    float _RandomRange_958165b7c3c245b19a12b674d6634371_Out_3;
    Unity_RandomRange_float(_Vector2_25b956a15eb2450d82ffb981b718c892_Out_0, 500, 700, _RandomRange_958165b7c3c245b19a12b674d6634371_Out_3);
    float _SimpleNoise_4258d5b4269041c2b55ddb7d098e0dff_Out_2;
    Unity_SimpleNoise_float(_TilingAndOffset_6d6a741583cb4e7d861a326a67a95b7e_Out_3, _RandomRange_958165b7c3c245b19a12b674d6634371_Out_3, _SimpleNoise_4258d5b4269041c2b55ddb7d098e0dff_Out_2);
    float _RandomRange_c15bab0ae8fb4570b6bacb91e8c7b8a6_Out_3;
    Unity_RandomRange_float(_Vector2_25b956a15eb2450d82ffb981b718c892_Out_0, 150, 200, _RandomRange_c15bab0ae8fb4570b6bacb91e8c7b8a6_Out_3);
    float _SimpleNoise_2eb21a33aa7c4e3b84decb54cd5d5570_Out_2;
    Unity_SimpleNoise_float(IN.uv0.xy, _RandomRange_c15bab0ae8fb4570b6bacb91e8c7b8a6_Out_3, _SimpleNoise_2eb21a33aa7c4e3b84decb54cd5d5570_Out_2);
    float _Multiply_89d7189c8fba48e5b757d93014bfd557_Out_2;
    Unity_Multiply_float(3, _SimpleNoise_2eb21a33aa7c4e3b84decb54cd5d5570_Out_2, _Multiply_89d7189c8fba48e5b757d93014bfd557_Out_2);
    float _Add_a97a2c2aa00b452bb1df95eeced7cfb6_Out_2;
    Unity_Add_float(_SimpleNoise_4258d5b4269041c2b55ddb7d098e0dff_Out_2, _Multiply_89d7189c8fba48e5b757d93014bfd557_Out_2, _Add_a97a2c2aa00b452bb1df95eeced7cfb6_Out_2);
    float _Divide_e6407003f1734725bac05ea6e13d0c99_Out_2;
    Unity_Divide_float(_Add_a97a2c2aa00b452bb1df95eeced7cfb6_Out_2, 4, _Divide_e6407003f1734725bac05ea6e13d0c99_Out_2);
    float _Property_b576b9fc8c954aca84f6b6155afa5fa9_Out_0 = Vector1_d7448e8c4bfe4629a845c4b4cf37f445;
    float _Step_a0998484051a4502944b2193794ec2af_Out_2;
    Unity_Step_float(_Property_b576b9fc8c954aca84f6b6155afa5fa9_Out_0, _Divide_e6407003f1734725bac05ea6e13d0c99_Out_2, _Step_a0998484051a4502944b2193794ec2af_Out_2);
    float _Property_7735a84e56694723969c1dc37628b724_Out_0 = Vector1_b508357b1e0b4ebfae0a54a8a1d8153c;
    float _Multiply_9e543f00b7e34b0086558b8fef2e68b9_Out_2;
    Unity_Multiply_float(IN.TimeParameters.x, _Property_7735a84e56694723969c1dc37628b724_Out_0, _Multiply_9e543f00b7e34b0086558b8fef2e68b9_Out_2);
    float _Multiply_f1858fc18ecf4faa828d7c4a0fa84c4d_Out_2;
    Unity_Multiply_float(_Multiply_9e543f00b7e34b0086558b8fef2e68b9_Out_2, 1.5, _Multiply_f1858fc18ecf4faa828d7c4a0fa84c4d_Out_2);
    float2 _Vector2_330142494d0d4792a0c710a2364a5442_Out_0 = float2(_Multiply_9e543f00b7e34b0086558b8fef2e68b9_Out_2, _Multiply_f1858fc18ecf4faa828d7c4a0fa84c4d_Out_2);
    float2 _TilingAndOffset_85c121fb05354962a60ed37d3ef9f813_Out_3;
    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_330142494d0d4792a0c710a2364a5442_Out_0, _TilingAndOffset_85c121fb05354962a60ed37d3ef9f813_Out_3);
    float4 _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_RGBA_0 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_Texture_1).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_Texture_1).samplerstate, _TilingAndOffset_85c121fb05354962a60ed37d3ef9f813_Out_3);
    float _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_R_4 = _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_RGBA_0.r;
    float _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_G_5 = _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_RGBA_0.g;
    float _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_B_6 = _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_RGBA_0.b;
    float _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_A_7 = _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_RGBA_0.a;
    float4 _Multiply_b4ab13caabac4c0d974f6568c10abeda_Out_2;
    Unity_Multiply_float((_Step_a0998484051a4502944b2193794ec2af_Out_2.xxxx), _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_RGBA_0, _Multiply_b4ab13caabac4c0d974f6568c10abeda_Out_2);
    float _Property_6ee5d2a2b8bf49de954a3cd5216487cc_Out_0 = _Materialised;
    float _Remap_53339270754549bea2d7a6f99acc8e37_Out_3;
    Unity_Remap_float(_Property_6ee5d2a2b8bf49de954a3cd5216487cc_Out_0, float2 (1, 0), float2 (-0.15, 1.1), _Remap_53339270754549bea2d7a6f99acc8e37_Out_3);
    float _Property_460e92d704484d58a231c183f394e581_Out_0 = Vector1_eee1783ae5744fb3b3f1036218fe3bdb;
    float _Add_6318c4fdc2bf45e78bacfb15c8b5e69f_Out_2;
    Unity_Add_float(_Remap_53339270754549bea2d7a6f99acc8e37_Out_3, _Property_460e92d704484d58a231c183f394e581_Out_0, _Add_6318c4fdc2bf45e78bacfb15c8b5e69f_Out_2);
    float _Property_c106932bbbf94ea89ec8d94076689161_Out_0 = Vector1_2f1e1aa506e142199a64d07139b44a85;
    float _GradientNoise_906c40673cc14548b509ba1d1ea2b14e_Out_2;
    Unity_GradientNoise_float(IN.uv0.xy, _Property_c106932bbbf94ea89ec8d94076689161_Out_0, _GradientNoise_906c40673cc14548b509ba1d1ea2b14e_Out_2);
    float _Multiply_6bc75468206749799ee0492aaac71cef_Out_2;
    Unity_Multiply_float(_GradientNoise_906c40673cc14548b509ba1d1ea2b14e_Out_2, 2, _Multiply_6bc75468206749799ee0492aaac71cef_Out_2);
    float _Property_cd0b606707f6467b993a0f84d74c2468_Out_0 = Vector1_6143018700ad4236ae154b2d19051c02;
    float _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Out_3;
    float _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Cells_4;
    Unity_Voronoi_float(IN.uv0.xy, IN.TimeParameters.x, _Property_cd0b606707f6467b993a0f84d74c2468_Out_0, _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Out_3, _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Cells_4);
    float _Add_ca098124b82e447ba61175254f1fadf4_Out_2;
    Unity_Add_float(_Multiply_6bc75468206749799ee0492aaac71cef_Out_2, _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Out_3, _Add_ca098124b82e447ba61175254f1fadf4_Out_2);
    float _Divide_c40356c0ab504a9394d3d54abc68bfaf_Out_2;
    Unity_Divide_float(_Add_ca098124b82e447ba61175254f1fadf4_Out_2, 3, _Divide_c40356c0ab504a9394d3d54abc68bfaf_Out_2);
    float _Step_1fe338b5168449a8a07bf9b80f31d4fa_Out_2;
    Unity_Step_float(_Add_6318c4fdc2bf45e78bacfb15c8b5e69f_Out_2, _Divide_c40356c0ab504a9394d3d54abc68bfaf_Out_2, _Step_1fe338b5168449a8a07bf9b80f31d4fa_Out_2);
    float4 _Multiply_28b8a693ce7243d4b61d000abefaeae5_Out_2;
    Unity_Multiply_float(_Multiply_b4ab13caabac4c0d974f6568c10abeda_Out_2, (_Step_1fe338b5168449a8a07bf9b80f31d4fa_Out_2.xxxx), _Multiply_28b8a693ce7243d4b61d000abefaeae5_Out_2);
    float _OneMinus_b1d4304c2ad94669a04a9f96eb7fc751_Out_1;
    Unity_OneMinus_float(_Step_1fe338b5168449a8a07bf9b80f31d4fa_Out_2, _OneMinus_b1d4304c2ad94669a04a9f96eb7fc751_Out_1);
    float4 _Add_133da9716087442ea5bc5663dfeffebf_Out_2;
    Unity_Add_float4(_Multiply_28b8a693ce7243d4b61d000abefaeae5_Out_2, (_OneMinus_b1d4304c2ad94669a04a9f96eb7fc751_Out_1.xxxx), _Add_133da9716087442ea5bc5663dfeffebf_Out_2);
    float4 _Property_caf147c757e749ca85de849e9b9de43a_Out_0 = IsGammaSpace() ? LinearToSRGB(Color_f24be94f3f7140f2b052f1ea234c3ffb) : Color_f24be94f3f7140f2b052f1ea234c3ffb;
    float4 _Multiply_1ce2bd970f4148e2b1aad044712adcff_Out_2;
    Unity_Multiply_float(_Add_133da9716087442ea5bc5663dfeffebf_Out_2, _Property_caf147c757e749ca85de849e9b9de43a_Out_0, _Multiply_1ce2bd970f4148e2b1aad044712adcff_Out_2);
    float _Step_2a6ecea9c5ae4a20896d75eef11b522a_Out_2;
    Unity_Step_float(_Remap_53339270754549bea2d7a6f99acc8e37_Out_3, _Divide_c40356c0ab504a9394d3d54abc68bfaf_Out_2, _Step_2a6ecea9c5ae4a20896d75eef11b522a_Out_2);
    surface.BaseColor = (_Divide_e6407003f1734725bac05ea6e13d0c99_Out_2.xxx);
    surface.NormalOS = IN.ObjectSpaceNormal;
    surface.Emission = (_Multiply_1ce2bd970f4148e2b1aad044712adcff_Out_2.xyz);
    surface.Specular = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
    surface.Smoothness = 0;
    surface.Occlusion = 1;
    surface.Alpha = _Step_2a6ecea9c5ae4a20896d75eef11b522a_Out_2;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS.xyz;
    output.ObjectSpacePosition = input.positionOS;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

    // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
    float3 unnormalizedNormalWS = input.normalWS;
    const float renormFactor = 1.0 / length(unnormalizedNormalWS);


    output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
    output.ObjectSpaceNormal = normalize(mul(output.WorldSpaceNormal, (float3x3) UNITY_MATRIX_M));           // transposed multiplication by inverse matrix to handle normal scale


    output.uv0 = input.texCoord0;
    output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

    ENDHLSL
}
Pass
{
    Name "ShadowCaster"
    Tags
    {
        "LightMode" = "ShadowCaster"
    }

        // Render State
        Cull Back
    Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
    ZTest LEqual
    ZWrite On
    ColorMask 0

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 2.0
    #pragma only_renderers gles gles3 glcore d3d11
    #pragma multi_compile_instancing
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>

        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _NORMALMAP 1
        #define _SPECULAR_SETUP
        #define _NORMAL_DROPOFF_OS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        float4 uv0 : TEXCOORD0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float4 texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
        float4 uv0;
        float3 TimeParameters;
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        float4 interp0 : TEXCOORD0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings(Varyings input)
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        output.interp0.xyzw = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings(PackedVaryings input)
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.texCoord0 = input.interp0.xyzw;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START(UnityPerMaterial)
float4 _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_Texture_1_TexelSize;
float Vector1_2f1e1aa506e142199a64d07139b44a85;
float _Materialised;
float Vector1_eee1783ae5744fb3b3f1036218fe3bdb;
float Vector1_6143018700ad4236ae154b2d19051c02;
float4 Color_f24be94f3f7140f2b052f1ea234c3ffb;
float Vector1_d7448e8c4bfe4629a845c4b4cf37f445;
float Vector1_b508357b1e0b4ebfae0a54a8a1d8153c;
CBUFFER_END

// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_Texture_1);
SAMPLER(sampler_SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_Texture_1);

// Graph Functions

void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
{
    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}


float2 Unity_GradientNoise_Dir_float(float2 p)
{
    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
    p = p % 289;
    // need full precision, otherwise half overflows when p > 1
    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
    x = (34 * x + 1) * x % 289;
    x = frac(x / 41) * 2 - 1;
    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
}

void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
{
    float2 p = UV * Scale;
    float2 ip = floor(p);
    float2 fp = frac(p);
    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
}

void Unity_Multiply_float(float A, float B, out float Out)
{
    Out = A * B;
}


inline float2 Unity_Voronoi_RandomVector_float(float2 UV, float offset)
{
    float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
    UV = frac(sin(mul(UV, m)));
    return float2(sin(UV.y * +offset) * 0.5 + 0.5, cos(UV.x * offset) * 0.5 + 0.5);
}

void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
{
    float2 g = floor(UV * CellDensity);
    float2 f = frac(UV * CellDensity);
    float t = 8.0;
    float3 res = float3(8.0, 0.0, 0.0);

    for (int y = -1; y <= 1; y++)
    {
        for (int x = -1; x <= 1; x++)
        {
            float2 lattice = float2(x,y);
            float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
            float d = distance(lattice + offset, f);

            if (d < res.x)
            {
                res = float3(d, offset.x, offset.y);
                Out = res.x;
                Cells = res.y;
            }
        }
    }
}

void Unity_Add_float(float A, float B, out float Out)
{
    Out = A + B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_Step_float(float Edge, float In, out float Out)
{
    Out = step(Edge, In);
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
    VertexDescription description = (VertexDescription)0;
    description.Position = IN.ObjectSpacePosition;
    description.Normal = IN.ObjectSpaceNormal;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription)0;
    float _Property_6ee5d2a2b8bf49de954a3cd5216487cc_Out_0 = _Materialised;
    float _Remap_53339270754549bea2d7a6f99acc8e37_Out_3;
    Unity_Remap_float(_Property_6ee5d2a2b8bf49de954a3cd5216487cc_Out_0, float2 (1, 0), float2 (-0.15, 1.1), _Remap_53339270754549bea2d7a6f99acc8e37_Out_3);
    float _Property_c106932bbbf94ea89ec8d94076689161_Out_0 = Vector1_2f1e1aa506e142199a64d07139b44a85;
    float _GradientNoise_906c40673cc14548b509ba1d1ea2b14e_Out_2;
    Unity_GradientNoise_float(IN.uv0.xy, _Property_c106932bbbf94ea89ec8d94076689161_Out_0, _GradientNoise_906c40673cc14548b509ba1d1ea2b14e_Out_2);
    float _Multiply_6bc75468206749799ee0492aaac71cef_Out_2;
    Unity_Multiply_float(_GradientNoise_906c40673cc14548b509ba1d1ea2b14e_Out_2, 2, _Multiply_6bc75468206749799ee0492aaac71cef_Out_2);
    float _Property_cd0b606707f6467b993a0f84d74c2468_Out_0 = Vector1_6143018700ad4236ae154b2d19051c02;
    float _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Out_3;
    float _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Cells_4;
    Unity_Voronoi_float(IN.uv0.xy, IN.TimeParameters.x, _Property_cd0b606707f6467b993a0f84d74c2468_Out_0, _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Out_3, _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Cells_4);
    float _Add_ca098124b82e447ba61175254f1fadf4_Out_2;
    Unity_Add_float(_Multiply_6bc75468206749799ee0492aaac71cef_Out_2, _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Out_3, _Add_ca098124b82e447ba61175254f1fadf4_Out_2);
    float _Divide_c40356c0ab504a9394d3d54abc68bfaf_Out_2;
    Unity_Divide_float(_Add_ca098124b82e447ba61175254f1fadf4_Out_2, 3, _Divide_c40356c0ab504a9394d3d54abc68bfaf_Out_2);
    float _Step_2a6ecea9c5ae4a20896d75eef11b522a_Out_2;
    Unity_Step_float(_Remap_53339270754549bea2d7a6f99acc8e37_Out_3, _Divide_c40356c0ab504a9394d3d54abc68bfaf_Out_2, _Step_2a6ecea9c5ae4a20896d75eef11b522a_Out_2);
    surface.Alpha = _Step_2a6ecea9c5ae4a20896d75eef11b522a_Out_2;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS.xyz;
    output.ObjectSpacePosition = input.positionOS;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





    output.uv0 = input.texCoord0;
    output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

    ENDHLSL
}
Pass
{
    Name "DepthOnly"
    Tags
    {
        "LightMode" = "DepthOnly"
    }

        // Render State
        Cull Back
    Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
    ZTest LEqual
    ZWrite On
    ColorMask 0

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 2.0
    #pragma only_renderers gles gles3 glcore d3d11
    #pragma multi_compile_instancing
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>

        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _NORMALMAP 1
        #define _SPECULAR_SETUP
        #define _NORMAL_DROPOFF_OS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        float4 uv0 : TEXCOORD0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float4 texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
        float4 uv0;
        float3 TimeParameters;
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        float4 interp0 : TEXCOORD0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings(Varyings input)
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        output.interp0.xyzw = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings(PackedVaryings input)
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.texCoord0 = input.interp0.xyzw;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START(UnityPerMaterial)
float4 _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_Texture_1_TexelSize;
float Vector1_2f1e1aa506e142199a64d07139b44a85;
float _Materialised;
float Vector1_eee1783ae5744fb3b3f1036218fe3bdb;
float Vector1_6143018700ad4236ae154b2d19051c02;
float4 Color_f24be94f3f7140f2b052f1ea234c3ffb;
float Vector1_d7448e8c4bfe4629a845c4b4cf37f445;
float Vector1_b508357b1e0b4ebfae0a54a8a1d8153c;
CBUFFER_END

// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_Texture_1);
SAMPLER(sampler_SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_Texture_1);

// Graph Functions

void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
{
    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}


float2 Unity_GradientNoise_Dir_float(float2 p)
{
    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
    p = p % 289;
    // need full precision, otherwise half overflows when p > 1
    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
    x = (34 * x + 1) * x % 289;
    x = frac(x / 41) * 2 - 1;
    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
}

void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
{
    float2 p = UV * Scale;
    float2 ip = floor(p);
    float2 fp = frac(p);
    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
}

void Unity_Multiply_float(float A, float B, out float Out)
{
    Out = A * B;
}


inline float2 Unity_Voronoi_RandomVector_float(float2 UV, float offset)
{
    float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
    UV = frac(sin(mul(UV, m)));
    return float2(sin(UV.y * +offset) * 0.5 + 0.5, cos(UV.x * offset) * 0.5 + 0.5);
}

void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
{
    float2 g = floor(UV * CellDensity);
    float2 f = frac(UV * CellDensity);
    float t = 8.0;
    float3 res = float3(8.0, 0.0, 0.0);

    for (int y = -1; y <= 1; y++)
    {
        for (int x = -1; x <= 1; x++)
        {
            float2 lattice = float2(x,y);
            float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
            float d = distance(lattice + offset, f);

            if (d < res.x)
            {
                res = float3(d, offset.x, offset.y);
                Out = res.x;
                Cells = res.y;
            }
        }
    }
}

void Unity_Add_float(float A, float B, out float Out)
{
    Out = A + B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_Step_float(float Edge, float In, out float Out)
{
    Out = step(Edge, In);
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
    VertexDescription description = (VertexDescription)0;
    description.Position = IN.ObjectSpacePosition;
    description.Normal = IN.ObjectSpaceNormal;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription)0;
    float _Property_6ee5d2a2b8bf49de954a3cd5216487cc_Out_0 = _Materialised;
    float _Remap_53339270754549bea2d7a6f99acc8e37_Out_3;
    Unity_Remap_float(_Property_6ee5d2a2b8bf49de954a3cd5216487cc_Out_0, float2 (1, 0), float2 (-0.15, 1.1), _Remap_53339270754549bea2d7a6f99acc8e37_Out_3);
    float _Property_c106932bbbf94ea89ec8d94076689161_Out_0 = Vector1_2f1e1aa506e142199a64d07139b44a85;
    float _GradientNoise_906c40673cc14548b509ba1d1ea2b14e_Out_2;
    Unity_GradientNoise_float(IN.uv0.xy, _Property_c106932bbbf94ea89ec8d94076689161_Out_0, _GradientNoise_906c40673cc14548b509ba1d1ea2b14e_Out_2);
    float _Multiply_6bc75468206749799ee0492aaac71cef_Out_2;
    Unity_Multiply_float(_GradientNoise_906c40673cc14548b509ba1d1ea2b14e_Out_2, 2, _Multiply_6bc75468206749799ee0492aaac71cef_Out_2);
    float _Property_cd0b606707f6467b993a0f84d74c2468_Out_0 = Vector1_6143018700ad4236ae154b2d19051c02;
    float _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Out_3;
    float _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Cells_4;
    Unity_Voronoi_float(IN.uv0.xy, IN.TimeParameters.x, _Property_cd0b606707f6467b993a0f84d74c2468_Out_0, _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Out_3, _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Cells_4);
    float _Add_ca098124b82e447ba61175254f1fadf4_Out_2;
    Unity_Add_float(_Multiply_6bc75468206749799ee0492aaac71cef_Out_2, _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Out_3, _Add_ca098124b82e447ba61175254f1fadf4_Out_2);
    float _Divide_c40356c0ab504a9394d3d54abc68bfaf_Out_2;
    Unity_Divide_float(_Add_ca098124b82e447ba61175254f1fadf4_Out_2, 3, _Divide_c40356c0ab504a9394d3d54abc68bfaf_Out_2);
    float _Step_2a6ecea9c5ae4a20896d75eef11b522a_Out_2;
    Unity_Step_float(_Remap_53339270754549bea2d7a6f99acc8e37_Out_3, _Divide_c40356c0ab504a9394d3d54abc68bfaf_Out_2, _Step_2a6ecea9c5ae4a20896d75eef11b522a_Out_2);
    surface.Alpha = _Step_2a6ecea9c5ae4a20896d75eef11b522a_Out_2;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS.xyz;
    output.ObjectSpacePosition = input.positionOS;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





    output.uv0 = input.texCoord0;
    output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

    ENDHLSL
}
Pass
{
    Name "DepthNormals"
    Tags
    {
        "LightMode" = "DepthNormals"
    }

        // Render State
        Cull Back
    Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
    ZTest LEqual
    ZWrite On

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 2.0
    #pragma only_renderers gles gles3 glcore d3d11
    #pragma multi_compile_instancing
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>

        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _NORMALMAP 1
        #define _SPECULAR_SETUP
        #define _NORMAL_DROPOFF_OS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        float4 uv0 : TEXCOORD0;
        float4 uv1 : TEXCOORD1;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float3 normalWS;
        float4 tangentWS;
        float4 texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 WorldSpaceNormal;
        float4 uv0;
        float3 TimeParameters;
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        float3 interp0 : TEXCOORD0;
        float4 interp1 : TEXCOORD1;
        float4 interp2 : TEXCOORD2;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings(Varyings input)
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        output.interp0.xyz = input.normalWS;
        output.interp1.xyzw = input.tangentWS;
        output.interp2.xyzw = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings(PackedVaryings input)
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.normalWS = input.interp0.xyz;
        output.tangentWS = input.interp1.xyzw;
        output.texCoord0 = input.interp2.xyzw;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START(UnityPerMaterial)
float4 _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_Texture_1_TexelSize;
float Vector1_2f1e1aa506e142199a64d07139b44a85;
float _Materialised;
float Vector1_eee1783ae5744fb3b3f1036218fe3bdb;
float Vector1_6143018700ad4236ae154b2d19051c02;
float4 Color_f24be94f3f7140f2b052f1ea234c3ffb;
float Vector1_d7448e8c4bfe4629a845c4b4cf37f445;
float Vector1_b508357b1e0b4ebfae0a54a8a1d8153c;
CBUFFER_END

// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_Texture_1);
SAMPLER(sampler_SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_Texture_1);

// Graph Functions

void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
{
    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}


float2 Unity_GradientNoise_Dir_float(float2 p)
{
    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
    p = p % 289;
    // need full precision, otherwise half overflows when p > 1
    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
    x = (34 * x + 1) * x % 289;
    x = frac(x / 41) * 2 - 1;
    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
}

void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
{
    float2 p = UV * Scale;
    float2 ip = floor(p);
    float2 fp = frac(p);
    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
}

void Unity_Multiply_float(float A, float B, out float Out)
{
    Out = A * B;
}


inline float2 Unity_Voronoi_RandomVector_float(float2 UV, float offset)
{
    float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
    UV = frac(sin(mul(UV, m)));
    return float2(sin(UV.y * +offset) * 0.5 + 0.5, cos(UV.x * offset) * 0.5 + 0.5);
}

void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
{
    float2 g = floor(UV * CellDensity);
    float2 f = frac(UV * CellDensity);
    float t = 8.0;
    float3 res = float3(8.0, 0.0, 0.0);

    for (int y = -1; y <= 1; y++)
    {
        for (int x = -1; x <= 1; x++)
        {
            float2 lattice = float2(x,y);
            float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
            float d = distance(lattice + offset, f);

            if (d < res.x)
            {
                res = float3(d, offset.x, offset.y);
                Out = res.x;
                Cells = res.y;
            }
        }
    }
}

void Unity_Add_float(float A, float B, out float Out)
{
    Out = A + B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_Step_float(float Edge, float In, out float Out)
{
    Out = step(Edge, In);
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
    VertexDescription description = (VertexDescription)0;
    description.Position = IN.ObjectSpacePosition;
    description.Normal = IN.ObjectSpaceNormal;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float3 NormalOS;
    float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription)0;
    float _Property_6ee5d2a2b8bf49de954a3cd5216487cc_Out_0 = _Materialised;
    float _Remap_53339270754549bea2d7a6f99acc8e37_Out_3;
    Unity_Remap_float(_Property_6ee5d2a2b8bf49de954a3cd5216487cc_Out_0, float2 (1, 0), float2 (-0.15, 1.1), _Remap_53339270754549bea2d7a6f99acc8e37_Out_3);
    float _Property_c106932bbbf94ea89ec8d94076689161_Out_0 = Vector1_2f1e1aa506e142199a64d07139b44a85;
    float _GradientNoise_906c40673cc14548b509ba1d1ea2b14e_Out_2;
    Unity_GradientNoise_float(IN.uv0.xy, _Property_c106932bbbf94ea89ec8d94076689161_Out_0, _GradientNoise_906c40673cc14548b509ba1d1ea2b14e_Out_2);
    float _Multiply_6bc75468206749799ee0492aaac71cef_Out_2;
    Unity_Multiply_float(_GradientNoise_906c40673cc14548b509ba1d1ea2b14e_Out_2, 2, _Multiply_6bc75468206749799ee0492aaac71cef_Out_2);
    float _Property_cd0b606707f6467b993a0f84d74c2468_Out_0 = Vector1_6143018700ad4236ae154b2d19051c02;
    float _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Out_3;
    float _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Cells_4;
    Unity_Voronoi_float(IN.uv0.xy, IN.TimeParameters.x, _Property_cd0b606707f6467b993a0f84d74c2468_Out_0, _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Out_3, _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Cells_4);
    float _Add_ca098124b82e447ba61175254f1fadf4_Out_2;
    Unity_Add_float(_Multiply_6bc75468206749799ee0492aaac71cef_Out_2, _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Out_3, _Add_ca098124b82e447ba61175254f1fadf4_Out_2);
    float _Divide_c40356c0ab504a9394d3d54abc68bfaf_Out_2;
    Unity_Divide_float(_Add_ca098124b82e447ba61175254f1fadf4_Out_2, 3, _Divide_c40356c0ab504a9394d3d54abc68bfaf_Out_2);
    float _Step_2a6ecea9c5ae4a20896d75eef11b522a_Out_2;
    Unity_Step_float(_Remap_53339270754549bea2d7a6f99acc8e37_Out_3, _Divide_c40356c0ab504a9394d3d54abc68bfaf_Out_2, _Step_2a6ecea9c5ae4a20896d75eef11b522a_Out_2);
    surface.NormalOS = IN.ObjectSpaceNormal;
    surface.Alpha = _Step_2a6ecea9c5ae4a20896d75eef11b522a_Out_2;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS.xyz;
    output.ObjectSpacePosition = input.positionOS;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

    // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
    float3 unnormalizedNormalWS = input.normalWS;
    const float renormFactor = 1.0 / length(unnormalizedNormalWS);


    output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
    output.ObjectSpaceNormal = normalize(mul(output.WorldSpaceNormal, (float3x3) UNITY_MATRIX_M));           // transposed multiplication by inverse matrix to handle normal scale


    output.uv0 = input.texCoord0;
    output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

    ENDHLSL
}
Pass
{
    Name "Meta"
    Tags
    {
        "LightMode" = "Meta"
    }

        // Render State
        Cull Off

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 2.0
    #pragma only_renderers gles gles3 glcore d3d11
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
        // GraphKeywords: <None>

        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _NORMALMAP 1
        #define _SPECULAR_SETUP
        #define _NORMAL_DROPOFF_OS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        float4 uv0 : TEXCOORD0;
        float4 uv1 : TEXCOORD1;
        float4 uv2 : TEXCOORD2;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float4 texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
        float4 uv0;
        float3 TimeParameters;
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        float4 interp0 : TEXCOORD0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings(Varyings input)
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        output.interp0.xyzw = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings(PackedVaryings input)
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.texCoord0 = input.interp0.xyzw;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START(UnityPerMaterial)
float4 _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_Texture_1_TexelSize;
float Vector1_2f1e1aa506e142199a64d07139b44a85;
float _Materialised;
float Vector1_eee1783ae5744fb3b3f1036218fe3bdb;
float Vector1_6143018700ad4236ae154b2d19051c02;
float4 Color_f24be94f3f7140f2b052f1ea234c3ffb;
float Vector1_d7448e8c4bfe4629a845c4b4cf37f445;
float Vector1_b508357b1e0b4ebfae0a54a8a1d8153c;
CBUFFER_END

// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_Texture_1);
SAMPLER(sampler_SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_Texture_1);

// Graph Functions

void Unity_Multiply_float(float A, float B, out float Out)
{
    Out = A * B;
}

void Unity_RandomRange_float(float2 Seed, float Min, float Max, out float Out)
{
     float randomno = frac(sin(dot(Seed, float2(12.9898, 78.233))) * 43758.5453);
     Out = lerp(Min, Max, randomno);
}

void Unity_Twirl_float(float2 UV, float2 Center, float Strength, float2 Offset, out float2 Out)
{
    float2 delta = UV - Center;
    float angle = Strength * length(delta);
    float x = cos(angle) * delta.x - sin(angle) * delta.y;
    float y = sin(angle) * delta.x + cos(angle) * delta.y;
    Out = float2(x + Center.x + Offset.x, y + Center.y + Offset.y);
}

void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
{
    Out = UV * Tiling + Offset;
}


inline float Unity_SimpleNoise_RandomValue_float(float2 uv)
{
    return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
}

inline float Unity_SimpleNnoise_Interpolate_float(float a, float b, float t)
{
    return (1.0 - t) * a + (t * b);
}


inline float Unity_SimpleNoise_ValueNoise_float(float2 uv)
{
    float2 i = floor(uv);
    float2 f = frac(uv);
    f = f * f * (3.0 - 2.0 * f);

    uv = abs(frac(uv) - 0.5);
    float2 c0 = i + float2(0.0, 0.0);
    float2 c1 = i + float2(1.0, 0.0);
    float2 c2 = i + float2(0.0, 1.0);
    float2 c3 = i + float2(1.0, 1.0);
    float r0 = Unity_SimpleNoise_RandomValue_float(c0);
    float r1 = Unity_SimpleNoise_RandomValue_float(c1);
    float r2 = Unity_SimpleNoise_RandomValue_float(c2);
    float r3 = Unity_SimpleNoise_RandomValue_float(c3);

    float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
    float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
    float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
    return t;
}
void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
{
    float t = 0.0;

    float freq = pow(2.0, float(0));
    float amp = pow(0.5, float(3 - 0));
    t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

    freq = pow(2.0, float(1));
    amp = pow(0.5, float(3 - 1));
    t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

    freq = pow(2.0, float(2));
    amp = pow(0.5, float(3 - 2));
    t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

    Out = t;
}

void Unity_Add_float(float A, float B, out float Out)
{
    Out = A + B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_Step_float(float Edge, float In, out float Out)
{
    Out = step(Edge, In);
}

void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
{
    Out = A * B;
}

void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
{
    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}


float2 Unity_GradientNoise_Dir_float(float2 p)
{
    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
    p = p % 289;
    // need full precision, otherwise half overflows when p > 1
    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
    x = (34 * x + 1) * x % 289;
    x = frac(x / 41) * 2 - 1;
    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
}

void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
{
    float2 p = UV * Scale;
    float2 ip = floor(p);
    float2 fp = frac(p);
    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
}


inline float2 Unity_Voronoi_RandomVector_float(float2 UV, float offset)
{
    float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
    UV = frac(sin(mul(UV, m)));
    return float2(sin(UV.y * +offset) * 0.5 + 0.5, cos(UV.x * offset) * 0.5 + 0.5);
}

void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
{
    float2 g = floor(UV * CellDensity);
    float2 f = frac(UV * CellDensity);
    float t = 8.0;
    float3 res = float3(8.0, 0.0, 0.0);

    for (int y = -1; y <= 1; y++)
    {
        for (int x = -1; x <= 1; x++)
        {
            float2 lattice = float2(x,y);
            float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
            float d = distance(lattice + offset, f);

            if (d < res.x)
            {
                res = float3(d, offset.x, offset.y);
                Out = res.x;
                Cells = res.y;
            }
        }
    }
}

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Add_float4(float4 A, float4 B, out float4 Out)
{
    Out = A + B;
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
    VertexDescription description = (VertexDescription)0;
    description.Position = IN.ObjectSpacePosition;
    description.Normal = IN.ObjectSpaceNormal;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float3 BaseColor;
    float3 Emission;
    float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription)0;
    float _Split_9075b88e065c4620845a4bbb94507295_R_1 = SHADERGRAPH_OBJECT_POSITION[0];
    float _Split_9075b88e065c4620845a4bbb94507295_G_2 = SHADERGRAPH_OBJECT_POSITION[1];
    float _Split_9075b88e065c4620845a4bbb94507295_B_3 = SHADERGRAPH_OBJECT_POSITION[2];
    float _Split_9075b88e065c4620845a4bbb94507295_A_4 = 0;
    float _Multiply_9122215ecfa1426c8a05606961aa62f4_Out_2;
    Unity_Multiply_float(_Split_9075b88e065c4620845a4bbb94507295_R_1, _Split_9075b88e065c4620845a4bbb94507295_B_3, _Multiply_9122215ecfa1426c8a05606961aa62f4_Out_2);
    float _Multiply_2d509dc7f9f0402db69d4701ce482d7c_Out_2;
    Unity_Multiply_float(_Split_9075b88e065c4620845a4bbb94507295_G_2, _Split_9075b88e065c4620845a4bbb94507295_B_3, _Multiply_2d509dc7f9f0402db69d4701ce482d7c_Out_2);
    float2 _Vector2_25b956a15eb2450d82ffb981b718c892_Out_0 = float2(_Multiply_9122215ecfa1426c8a05606961aa62f4_Out_2, _Multiply_2d509dc7f9f0402db69d4701ce482d7c_Out_2);
    float _RandomRange_fab572807af44d4aa4d1c7c173801461_Out_3;
    Unity_RandomRange_float(_Vector2_25b956a15eb2450d82ffb981b718c892_Out_0, -1, 1, _RandomRange_fab572807af44d4aa4d1c7c173801461_Out_3);
    float2 _Twirl_344ad4db85314e5091310937b6b719d9_Out_4;
    Unity_Twirl_float(IN.uv0.xy, float2 (0.5, 0), _RandomRange_fab572807af44d4aa4d1c7c173801461_Out_3, float2 (0, 0), _Twirl_344ad4db85314e5091310937b6b719d9_Out_4);
    float _RandomRange_f9ab629e6ac344edb552ad4aea6e90d3_Out_3;
    Unity_RandomRange_float(_Vector2_25b956a15eb2450d82ffb981b718c892_Out_0, 0, 1, _RandomRange_f9ab629e6ac344edb552ad4aea6e90d3_Out_3);
    float _RandomRange_24cd5e2a255647cbb8fffdbe74a5ea32_Out_3;
    Unity_RandomRange_float(_Vector2_25b956a15eb2450d82ffb981b718c892_Out_0, 10, 30, _RandomRange_24cd5e2a255647cbb8fffdbe74a5ea32_Out_3);
    float2 _Vector2_6d5f4d74c2314cdd8e1288d96858efd4_Out_0 = float2(_RandomRange_f9ab629e6ac344edb552ad4aea6e90d3_Out_3, _RandomRange_24cd5e2a255647cbb8fffdbe74a5ea32_Out_3);
    float2 _TilingAndOffset_6d6a741583cb4e7d861a326a67a95b7e_Out_3;
    Unity_TilingAndOffset_float(_Twirl_344ad4db85314e5091310937b6b719d9_Out_4, _Vector2_6d5f4d74c2314cdd8e1288d96858efd4_Out_0, float2 (0, 0), _TilingAndOffset_6d6a741583cb4e7d861a326a67a95b7e_Out_3);
    float _RandomRange_958165b7c3c245b19a12b674d6634371_Out_3;
    Unity_RandomRange_float(_Vector2_25b956a15eb2450d82ffb981b718c892_Out_0, 500, 700, _RandomRange_958165b7c3c245b19a12b674d6634371_Out_3);
    float _SimpleNoise_4258d5b4269041c2b55ddb7d098e0dff_Out_2;
    Unity_SimpleNoise_float(_TilingAndOffset_6d6a741583cb4e7d861a326a67a95b7e_Out_3, _RandomRange_958165b7c3c245b19a12b674d6634371_Out_3, _SimpleNoise_4258d5b4269041c2b55ddb7d098e0dff_Out_2);
    float _RandomRange_c15bab0ae8fb4570b6bacb91e8c7b8a6_Out_3;
    Unity_RandomRange_float(_Vector2_25b956a15eb2450d82ffb981b718c892_Out_0, 150, 200, _RandomRange_c15bab0ae8fb4570b6bacb91e8c7b8a6_Out_3);
    float _SimpleNoise_2eb21a33aa7c4e3b84decb54cd5d5570_Out_2;
    Unity_SimpleNoise_float(IN.uv0.xy, _RandomRange_c15bab0ae8fb4570b6bacb91e8c7b8a6_Out_3, _SimpleNoise_2eb21a33aa7c4e3b84decb54cd5d5570_Out_2);
    float _Multiply_89d7189c8fba48e5b757d93014bfd557_Out_2;
    Unity_Multiply_float(3, _SimpleNoise_2eb21a33aa7c4e3b84decb54cd5d5570_Out_2, _Multiply_89d7189c8fba48e5b757d93014bfd557_Out_2);
    float _Add_a97a2c2aa00b452bb1df95eeced7cfb6_Out_2;
    Unity_Add_float(_SimpleNoise_4258d5b4269041c2b55ddb7d098e0dff_Out_2, _Multiply_89d7189c8fba48e5b757d93014bfd557_Out_2, _Add_a97a2c2aa00b452bb1df95eeced7cfb6_Out_2);
    float _Divide_e6407003f1734725bac05ea6e13d0c99_Out_2;
    Unity_Divide_float(_Add_a97a2c2aa00b452bb1df95eeced7cfb6_Out_2, 4, _Divide_e6407003f1734725bac05ea6e13d0c99_Out_2);
    float _Property_b576b9fc8c954aca84f6b6155afa5fa9_Out_0 = Vector1_d7448e8c4bfe4629a845c4b4cf37f445;
    float _Step_a0998484051a4502944b2193794ec2af_Out_2;
    Unity_Step_float(_Property_b576b9fc8c954aca84f6b6155afa5fa9_Out_0, _Divide_e6407003f1734725bac05ea6e13d0c99_Out_2, _Step_a0998484051a4502944b2193794ec2af_Out_2);
    float _Property_7735a84e56694723969c1dc37628b724_Out_0 = Vector1_b508357b1e0b4ebfae0a54a8a1d8153c;
    float _Multiply_9e543f00b7e34b0086558b8fef2e68b9_Out_2;
    Unity_Multiply_float(IN.TimeParameters.x, _Property_7735a84e56694723969c1dc37628b724_Out_0, _Multiply_9e543f00b7e34b0086558b8fef2e68b9_Out_2);
    float _Multiply_f1858fc18ecf4faa828d7c4a0fa84c4d_Out_2;
    Unity_Multiply_float(_Multiply_9e543f00b7e34b0086558b8fef2e68b9_Out_2, 1.5, _Multiply_f1858fc18ecf4faa828d7c4a0fa84c4d_Out_2);
    float2 _Vector2_330142494d0d4792a0c710a2364a5442_Out_0 = float2(_Multiply_9e543f00b7e34b0086558b8fef2e68b9_Out_2, _Multiply_f1858fc18ecf4faa828d7c4a0fa84c4d_Out_2);
    float2 _TilingAndOffset_85c121fb05354962a60ed37d3ef9f813_Out_3;
    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_330142494d0d4792a0c710a2364a5442_Out_0, _TilingAndOffset_85c121fb05354962a60ed37d3ef9f813_Out_3);
    float4 _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_RGBA_0 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_Texture_1).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_Texture_1).samplerstate, _TilingAndOffset_85c121fb05354962a60ed37d3ef9f813_Out_3);
    float _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_R_4 = _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_RGBA_0.r;
    float _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_G_5 = _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_RGBA_0.g;
    float _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_B_6 = _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_RGBA_0.b;
    float _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_A_7 = _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_RGBA_0.a;
    float4 _Multiply_b4ab13caabac4c0d974f6568c10abeda_Out_2;
    Unity_Multiply_float((_Step_a0998484051a4502944b2193794ec2af_Out_2.xxxx), _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_RGBA_0, _Multiply_b4ab13caabac4c0d974f6568c10abeda_Out_2);
    float _Property_6ee5d2a2b8bf49de954a3cd5216487cc_Out_0 = _Materialised;
    float _Remap_53339270754549bea2d7a6f99acc8e37_Out_3;
    Unity_Remap_float(_Property_6ee5d2a2b8bf49de954a3cd5216487cc_Out_0, float2 (1, 0), float2 (-0.15, 1.1), _Remap_53339270754549bea2d7a6f99acc8e37_Out_3);
    float _Property_460e92d704484d58a231c183f394e581_Out_0 = Vector1_eee1783ae5744fb3b3f1036218fe3bdb;
    float _Add_6318c4fdc2bf45e78bacfb15c8b5e69f_Out_2;
    Unity_Add_float(_Remap_53339270754549bea2d7a6f99acc8e37_Out_3, _Property_460e92d704484d58a231c183f394e581_Out_0, _Add_6318c4fdc2bf45e78bacfb15c8b5e69f_Out_2);
    float _Property_c106932bbbf94ea89ec8d94076689161_Out_0 = Vector1_2f1e1aa506e142199a64d07139b44a85;
    float _GradientNoise_906c40673cc14548b509ba1d1ea2b14e_Out_2;
    Unity_GradientNoise_float(IN.uv0.xy, _Property_c106932bbbf94ea89ec8d94076689161_Out_0, _GradientNoise_906c40673cc14548b509ba1d1ea2b14e_Out_2);
    float _Multiply_6bc75468206749799ee0492aaac71cef_Out_2;
    Unity_Multiply_float(_GradientNoise_906c40673cc14548b509ba1d1ea2b14e_Out_2, 2, _Multiply_6bc75468206749799ee0492aaac71cef_Out_2);
    float _Property_cd0b606707f6467b993a0f84d74c2468_Out_0 = Vector1_6143018700ad4236ae154b2d19051c02;
    float _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Out_3;
    float _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Cells_4;
    Unity_Voronoi_float(IN.uv0.xy, IN.TimeParameters.x, _Property_cd0b606707f6467b993a0f84d74c2468_Out_0, _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Out_3, _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Cells_4);
    float _Add_ca098124b82e447ba61175254f1fadf4_Out_2;
    Unity_Add_float(_Multiply_6bc75468206749799ee0492aaac71cef_Out_2, _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Out_3, _Add_ca098124b82e447ba61175254f1fadf4_Out_2);
    float _Divide_c40356c0ab504a9394d3d54abc68bfaf_Out_2;
    Unity_Divide_float(_Add_ca098124b82e447ba61175254f1fadf4_Out_2, 3, _Divide_c40356c0ab504a9394d3d54abc68bfaf_Out_2);
    float _Step_1fe338b5168449a8a07bf9b80f31d4fa_Out_2;
    Unity_Step_float(_Add_6318c4fdc2bf45e78bacfb15c8b5e69f_Out_2, _Divide_c40356c0ab504a9394d3d54abc68bfaf_Out_2, _Step_1fe338b5168449a8a07bf9b80f31d4fa_Out_2);
    float4 _Multiply_28b8a693ce7243d4b61d000abefaeae5_Out_2;
    Unity_Multiply_float(_Multiply_b4ab13caabac4c0d974f6568c10abeda_Out_2, (_Step_1fe338b5168449a8a07bf9b80f31d4fa_Out_2.xxxx), _Multiply_28b8a693ce7243d4b61d000abefaeae5_Out_2);
    float _OneMinus_b1d4304c2ad94669a04a9f96eb7fc751_Out_1;
    Unity_OneMinus_float(_Step_1fe338b5168449a8a07bf9b80f31d4fa_Out_2, _OneMinus_b1d4304c2ad94669a04a9f96eb7fc751_Out_1);
    float4 _Add_133da9716087442ea5bc5663dfeffebf_Out_2;
    Unity_Add_float4(_Multiply_28b8a693ce7243d4b61d000abefaeae5_Out_2, (_OneMinus_b1d4304c2ad94669a04a9f96eb7fc751_Out_1.xxxx), _Add_133da9716087442ea5bc5663dfeffebf_Out_2);
    float4 _Property_caf147c757e749ca85de849e9b9de43a_Out_0 = IsGammaSpace() ? LinearToSRGB(Color_f24be94f3f7140f2b052f1ea234c3ffb) : Color_f24be94f3f7140f2b052f1ea234c3ffb;
    float4 _Multiply_1ce2bd970f4148e2b1aad044712adcff_Out_2;
    Unity_Multiply_float(_Add_133da9716087442ea5bc5663dfeffebf_Out_2, _Property_caf147c757e749ca85de849e9b9de43a_Out_0, _Multiply_1ce2bd970f4148e2b1aad044712adcff_Out_2);
    float _Step_2a6ecea9c5ae4a20896d75eef11b522a_Out_2;
    Unity_Step_float(_Remap_53339270754549bea2d7a6f99acc8e37_Out_3, _Divide_c40356c0ab504a9394d3d54abc68bfaf_Out_2, _Step_2a6ecea9c5ae4a20896d75eef11b522a_Out_2);
    surface.BaseColor = (_Divide_e6407003f1734725bac05ea6e13d0c99_Out_2.xxx);
    surface.Emission = (_Multiply_1ce2bd970f4148e2b1aad044712adcff_Out_2.xyz);
    surface.Alpha = _Step_2a6ecea9c5ae4a20896d75eef11b522a_Out_2;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS.xyz;
    output.ObjectSpacePosition = input.positionOS;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





    output.uv0 = input.texCoord0;
    output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

    ENDHLSL
}
Pass
{
        // Name: <None>
        Tags
        {
            "LightMode" = "Universal2D"
        }

        // Render State
        Cull Back
    Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
    ZTest LEqual
    ZWrite Off

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 2.0
    #pragma only_renderers gles gles3 glcore d3d11
    #pragma multi_compile_instancing
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>

        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _NORMALMAP 1
        #define _SPECULAR_SETUP
        #define _NORMAL_DROPOFF_OS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_2D
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        float4 uv0 : TEXCOORD0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float4 texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
        float4 uv0;
        float3 TimeParameters;
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        float4 interp0 : TEXCOORD0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings(Varyings input)
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        output.interp0.xyzw = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings(PackedVaryings input)
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.texCoord0 = input.interp0.xyzw;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START(UnityPerMaterial)
float4 _SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_Texture_1_TexelSize;
float Vector1_2f1e1aa506e142199a64d07139b44a85;
float _Materialised;
float Vector1_eee1783ae5744fb3b3f1036218fe3bdb;
float Vector1_6143018700ad4236ae154b2d19051c02;
float4 Color_f24be94f3f7140f2b052f1ea234c3ffb;
float Vector1_d7448e8c4bfe4629a845c4b4cf37f445;
float Vector1_b508357b1e0b4ebfae0a54a8a1d8153c;
CBUFFER_END

// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_Texture_1);
SAMPLER(sampler_SampleTexture2D_3f088af80c334db6ae47e5e3f5a5435b_Texture_1);

// Graph Functions

void Unity_Multiply_float(float A, float B, out float Out)
{
    Out = A * B;
}

void Unity_RandomRange_float(float2 Seed, float Min, float Max, out float Out)
{
     float randomno = frac(sin(dot(Seed, float2(12.9898, 78.233))) * 43758.5453);
     Out = lerp(Min, Max, randomno);
}

void Unity_Twirl_float(float2 UV, float2 Center, float Strength, float2 Offset, out float2 Out)
{
    float2 delta = UV - Center;
    float angle = Strength * length(delta);
    float x = cos(angle) * delta.x - sin(angle) * delta.y;
    float y = sin(angle) * delta.x + cos(angle) * delta.y;
    Out = float2(x + Center.x + Offset.x, y + Center.y + Offset.y);
}

void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
{
    Out = UV * Tiling + Offset;
}


inline float Unity_SimpleNoise_RandomValue_float(float2 uv)
{
    return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
}

inline float Unity_SimpleNnoise_Interpolate_float(float a, float b, float t)
{
    return (1.0 - t) * a + (t * b);
}


inline float Unity_SimpleNoise_ValueNoise_float(float2 uv)
{
    float2 i = floor(uv);
    float2 f = frac(uv);
    f = f * f * (3.0 - 2.0 * f);

    uv = abs(frac(uv) - 0.5);
    float2 c0 = i + float2(0.0, 0.0);
    float2 c1 = i + float2(1.0, 0.0);
    float2 c2 = i + float2(0.0, 1.0);
    float2 c3 = i + float2(1.0, 1.0);
    float r0 = Unity_SimpleNoise_RandomValue_float(c0);
    float r1 = Unity_SimpleNoise_RandomValue_float(c1);
    float r2 = Unity_SimpleNoise_RandomValue_float(c2);
    float r3 = Unity_SimpleNoise_RandomValue_float(c3);

    float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
    float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
    float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
    return t;
}
void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
{
    float t = 0.0;

    float freq = pow(2.0, float(0));
    float amp = pow(0.5, float(3 - 0));
    t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

    freq = pow(2.0, float(1));
    amp = pow(0.5, float(3 - 1));
    t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

    freq = pow(2.0, float(2));
    amp = pow(0.5, float(3 - 2));
    t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

    Out = t;
}

void Unity_Add_float(float A, float B, out float Out)
{
    Out = A + B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
{
    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}


float2 Unity_GradientNoise_Dir_float(float2 p)
{
    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
    p = p % 289;
    // need full precision, otherwise half overflows when p > 1
    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
    x = (34 * x + 1) * x % 289;
    x = frac(x / 41) * 2 - 1;
    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
}

void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
{
    float2 p = UV * Scale;
    float2 ip = floor(p);
    float2 fp = frac(p);
    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
}


inline float2 Unity_Voronoi_RandomVector_float(float2 UV, float offset)
{
    float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
    UV = frac(sin(mul(UV, m)));
    return float2(sin(UV.y * +offset) * 0.5 + 0.5, cos(UV.x * offset) * 0.5 + 0.5);
}

void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
{
    float2 g = floor(UV * CellDensity);
    float2 f = frac(UV * CellDensity);
    float t = 8.0;
    float3 res = float3(8.0, 0.0, 0.0);

    for (int y = -1; y <= 1; y++)
    {
        for (int x = -1; x <= 1; x++)
        {
            float2 lattice = float2(x,y);
            float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
            float d = distance(lattice + offset, f);

            if (d < res.x)
            {
                res = float3(d, offset.x, offset.y);
                Out = res.x;
                Cells = res.y;
            }
        }
    }
}

void Unity_Step_float(float Edge, float In, out float Out)
{
    Out = step(Edge, In);
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
    VertexDescription description = (VertexDescription)0;
    description.Position = IN.ObjectSpacePosition;
    description.Normal = IN.ObjectSpaceNormal;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float3 BaseColor;
    float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription)0;
    float _Split_9075b88e065c4620845a4bbb94507295_R_1 = SHADERGRAPH_OBJECT_POSITION[0];
    float _Split_9075b88e065c4620845a4bbb94507295_G_2 = SHADERGRAPH_OBJECT_POSITION[1];
    float _Split_9075b88e065c4620845a4bbb94507295_B_3 = SHADERGRAPH_OBJECT_POSITION[2];
    float _Split_9075b88e065c4620845a4bbb94507295_A_4 = 0;
    float _Multiply_9122215ecfa1426c8a05606961aa62f4_Out_2;
    Unity_Multiply_float(_Split_9075b88e065c4620845a4bbb94507295_R_1, _Split_9075b88e065c4620845a4bbb94507295_B_3, _Multiply_9122215ecfa1426c8a05606961aa62f4_Out_2);
    float _Multiply_2d509dc7f9f0402db69d4701ce482d7c_Out_2;
    Unity_Multiply_float(_Split_9075b88e065c4620845a4bbb94507295_G_2, _Split_9075b88e065c4620845a4bbb94507295_B_3, _Multiply_2d509dc7f9f0402db69d4701ce482d7c_Out_2);
    float2 _Vector2_25b956a15eb2450d82ffb981b718c892_Out_0 = float2(_Multiply_9122215ecfa1426c8a05606961aa62f4_Out_2, _Multiply_2d509dc7f9f0402db69d4701ce482d7c_Out_2);
    float _RandomRange_fab572807af44d4aa4d1c7c173801461_Out_3;
    Unity_RandomRange_float(_Vector2_25b956a15eb2450d82ffb981b718c892_Out_0, -1, 1, _RandomRange_fab572807af44d4aa4d1c7c173801461_Out_3);
    float2 _Twirl_344ad4db85314e5091310937b6b719d9_Out_4;
    Unity_Twirl_float(IN.uv0.xy, float2 (0.5, 0), _RandomRange_fab572807af44d4aa4d1c7c173801461_Out_3, float2 (0, 0), _Twirl_344ad4db85314e5091310937b6b719d9_Out_4);
    float _RandomRange_f9ab629e6ac344edb552ad4aea6e90d3_Out_3;
    Unity_RandomRange_float(_Vector2_25b956a15eb2450d82ffb981b718c892_Out_0, 0, 1, _RandomRange_f9ab629e6ac344edb552ad4aea6e90d3_Out_3);
    float _RandomRange_24cd5e2a255647cbb8fffdbe74a5ea32_Out_3;
    Unity_RandomRange_float(_Vector2_25b956a15eb2450d82ffb981b718c892_Out_0, 10, 30, _RandomRange_24cd5e2a255647cbb8fffdbe74a5ea32_Out_3);
    float2 _Vector2_6d5f4d74c2314cdd8e1288d96858efd4_Out_0 = float2(_RandomRange_f9ab629e6ac344edb552ad4aea6e90d3_Out_3, _RandomRange_24cd5e2a255647cbb8fffdbe74a5ea32_Out_3);
    float2 _TilingAndOffset_6d6a741583cb4e7d861a326a67a95b7e_Out_3;
    Unity_TilingAndOffset_float(_Twirl_344ad4db85314e5091310937b6b719d9_Out_4, _Vector2_6d5f4d74c2314cdd8e1288d96858efd4_Out_0, float2 (0, 0), _TilingAndOffset_6d6a741583cb4e7d861a326a67a95b7e_Out_3);
    float _RandomRange_958165b7c3c245b19a12b674d6634371_Out_3;
    Unity_RandomRange_float(_Vector2_25b956a15eb2450d82ffb981b718c892_Out_0, 500, 700, _RandomRange_958165b7c3c245b19a12b674d6634371_Out_3);
    float _SimpleNoise_4258d5b4269041c2b55ddb7d098e0dff_Out_2;
    Unity_SimpleNoise_float(_TilingAndOffset_6d6a741583cb4e7d861a326a67a95b7e_Out_3, _RandomRange_958165b7c3c245b19a12b674d6634371_Out_3, _SimpleNoise_4258d5b4269041c2b55ddb7d098e0dff_Out_2);
    float _RandomRange_c15bab0ae8fb4570b6bacb91e8c7b8a6_Out_3;
    Unity_RandomRange_float(_Vector2_25b956a15eb2450d82ffb981b718c892_Out_0, 150, 200, _RandomRange_c15bab0ae8fb4570b6bacb91e8c7b8a6_Out_3);
    float _SimpleNoise_2eb21a33aa7c4e3b84decb54cd5d5570_Out_2;
    Unity_SimpleNoise_float(IN.uv0.xy, _RandomRange_c15bab0ae8fb4570b6bacb91e8c7b8a6_Out_3, _SimpleNoise_2eb21a33aa7c4e3b84decb54cd5d5570_Out_2);
    float _Multiply_89d7189c8fba48e5b757d93014bfd557_Out_2;
    Unity_Multiply_float(3, _SimpleNoise_2eb21a33aa7c4e3b84decb54cd5d5570_Out_2, _Multiply_89d7189c8fba48e5b757d93014bfd557_Out_2);
    float _Add_a97a2c2aa00b452bb1df95eeced7cfb6_Out_2;
    Unity_Add_float(_SimpleNoise_4258d5b4269041c2b55ddb7d098e0dff_Out_2, _Multiply_89d7189c8fba48e5b757d93014bfd557_Out_2, _Add_a97a2c2aa00b452bb1df95eeced7cfb6_Out_2);
    float _Divide_e6407003f1734725bac05ea6e13d0c99_Out_2;
    Unity_Divide_float(_Add_a97a2c2aa00b452bb1df95eeced7cfb6_Out_2, 4, _Divide_e6407003f1734725bac05ea6e13d0c99_Out_2);
    float _Property_6ee5d2a2b8bf49de954a3cd5216487cc_Out_0 = _Materialised;
    float _Remap_53339270754549bea2d7a6f99acc8e37_Out_3;
    Unity_Remap_float(_Property_6ee5d2a2b8bf49de954a3cd5216487cc_Out_0, float2 (1, 0), float2 (-0.15, 1.1), _Remap_53339270754549bea2d7a6f99acc8e37_Out_3);
    float _Property_c106932bbbf94ea89ec8d94076689161_Out_0 = Vector1_2f1e1aa506e142199a64d07139b44a85;
    float _GradientNoise_906c40673cc14548b509ba1d1ea2b14e_Out_2;
    Unity_GradientNoise_float(IN.uv0.xy, _Property_c106932bbbf94ea89ec8d94076689161_Out_0, _GradientNoise_906c40673cc14548b509ba1d1ea2b14e_Out_2);
    float _Multiply_6bc75468206749799ee0492aaac71cef_Out_2;
    Unity_Multiply_float(_GradientNoise_906c40673cc14548b509ba1d1ea2b14e_Out_2, 2, _Multiply_6bc75468206749799ee0492aaac71cef_Out_2);
    float _Property_cd0b606707f6467b993a0f84d74c2468_Out_0 = Vector1_6143018700ad4236ae154b2d19051c02;
    float _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Out_3;
    float _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Cells_4;
    Unity_Voronoi_float(IN.uv0.xy, IN.TimeParameters.x, _Property_cd0b606707f6467b993a0f84d74c2468_Out_0, _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Out_3, _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Cells_4);
    float _Add_ca098124b82e447ba61175254f1fadf4_Out_2;
    Unity_Add_float(_Multiply_6bc75468206749799ee0492aaac71cef_Out_2, _Voronoi_04b8c689af7746bd9a0bad278f1885cf_Out_3, _Add_ca098124b82e447ba61175254f1fadf4_Out_2);
    float _Divide_c40356c0ab504a9394d3d54abc68bfaf_Out_2;
    Unity_Divide_float(_Add_ca098124b82e447ba61175254f1fadf4_Out_2, 3, _Divide_c40356c0ab504a9394d3d54abc68bfaf_Out_2);
    float _Step_2a6ecea9c5ae4a20896d75eef11b522a_Out_2;
    Unity_Step_float(_Remap_53339270754549bea2d7a6f99acc8e37_Out_3, _Divide_c40356c0ab504a9394d3d54abc68bfaf_Out_2, _Step_2a6ecea9c5ae4a20896d75eef11b522a_Out_2);
    surface.BaseColor = (_Divide_e6407003f1734725bac05ea6e13d0c99_Out_2.xxx);
    surface.Alpha = _Step_2a6ecea9c5ae4a20896d75eef11b522a_Out_2;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS.xyz;
    output.ObjectSpacePosition = input.positionOS;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





    output.uv0 = input.texCoord0;
    output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

    ENDHLSL
}
    }
        CustomEditor "ShaderGraph.PBRMasterGUI"
        FallBack "Hidden/Shader Graph/FallbackError"
}