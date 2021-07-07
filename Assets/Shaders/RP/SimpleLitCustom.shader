// Shader targeted for low end devices. Single Pass Forward Rendering.
Shader "Universal Render Pipeline/Simple Lit Custom"
{
    // Keep properties of StandardSpecular shader for upgrade reasons.
    Properties
    {
        [MainColor] _BaseColor("Base Color", Color) = (0.5, 0.5, 0.5, 1)
        [MainTexture] _BaseMap("Base Map (RGB) Occlusion(A)", 2D) = "white" {}
        _BlendMap("Blend Map (RGB) Occlusion(A)", 2D) = "white" {}
        _BaseBlend("Basemap Blend", Range(-3, 3)) = 0.0

        _Cutoff("Alpha Clipping", Range(0.0, 1.0)) = 0.0
        _LerpColor("Lerp Color", Color) = (1, 1, 1, 0)

		[PerRendererData]
		_LightmapCustom("Custom Lightmap", 2D) = "white" {}
		[HideInInspector] _GlowColor("Glow Color", Color) = (0, 0, 0, 0)
        [HideInInspector] _GlowColor2("Glow Color 2", Color) = (0, 0, 0, 0)
		[HideInInspector] _GlowAmount("Glow Amount", Range(0,1)) = 0
        [HideInInspector] _GlowAmount2("Glow Amount 2", Range(0,1)) = 0
		[HideInInspector] _GlowHeightThreshold("Glow Height Threshold", Range(0,2)) = 0
		_GlowOriginWS ("Glow Origin WS", Vector) = (0,0,0,0)
		[HideInInspector] _GlowSoftness ("Glow Softness", Float) = 0.1
		[HideInInspector] _GlowRange ("Glow Range", Range(1,100)) = 36
		[HideInInspector] _InnerWipe ("Inner Wipe Ratio", Range(0.5,4)) = 0.5
        _BoundsRadius("Bounds Radius", Range(0,16)) = 2.0
        [Toggle(_GLOW_ALPHAFADE)]
        _GlowAlphaFade("Glow Alpha Fade", Float) = 0

        [HideInInspector] _BumpScale("Scale", Float) = 1.0
        [NoScaleOffset] _BumpMap("Normal Map", 2D) = "bump" {}

        _EmissionColor("Data Multiplier", Color) = (0,0,0,1)
        [NoScaleOffset]_EmissionMap("Data - MetalGloss(R) Emissive(G) LightWrap(B) Curvature(A)", 2D) = "white" {}

        // Blending state
        [HideInInspector] _Surface("__surface", Float) = 0.0
        [HideInInspector] _Blend("__blend", Float) = 0.0
        [HideInInspector] _AlphaClip("__clip", Float) = 0.0
        [HideInInspector] _SrcBlend("__src", Float) = 1.0
        [HideInInspector] _DstBlend("__dst", Float) = 0.0
        [HideInInspector] _ZWrite("__zw", Float) = 1.0
        [HideInInspector] _Cull("__cull", Float) = 2.0

        [ToggleOff] _ReceiveShadows("Receive Shadows", Float) = 1.0

        // Editmode props
        [HideInInspector] _QueueOffset("Queue offset", Float) = 0.0
        [HideInInspector] _Smoothness("SMoothness", Float) = 0.5

        // ObsoleteProperties
        [HideInInspector] _MainTex("BaseMap", 2D) = "white" {}
        [HideInInspector] _Color("Base Color", Color) = (0.5, 0.5, 0.5, 1)
        [HideInInspector] _Shininess("Smoothness", Float) = 0.0
        [HideInInspector] _GlossinessSource("GlossinessSource", Float) = 0.0
        [HideInInspector] _SpecSource("SpecularHighlights", Float) = 0.0
        //[HideInInspector] _SpecColor("Spec Color", Color) = (0.5, 0.5, 0.5, 1)

		[HideInInspector] _ProbeMap("3D Texture Probe Map", 3D) =  "white" {}
		[HideInInspector] ProbeExtentsWSMin("ProbeExtentsWSMin", Vector) = (0.0, 0.0, 0.0, 0.0)
        [HideInInspector] ProbeExtentsWSMax("ProbeExtentsWSMax", Vector) = (0.0, 0.0, 0.0, 0.0)
		[HideInInspector] _LightProbeOffset("Probe Texture Offset Sample Factor", Float) = 0.0
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "IgnoreProjector" = "True"}
        LOD 300

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            // Use same blending / depth states as Standard shader
            Blend[_SrcBlend][_DstBlend]
            ZWrite On
            Cull[_Cull]


            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            // -------------------------------------
            // Material Keywords
			#pragma skip_variants _ALPHAPREMULTIPLY_ON _SPECGLOSSMAP _SPECULAR_COLOR _GLOSSINESS_FROM_BASE_ALPHA DIRLIGHTMAP_COMBINED _MAIN_LIGHT_SHADOWS_CASCADE _ADDITIONAL_LIGHT_SHADOWS _MIXED_LIGHTING_SUBTRACTIVE
            #pragma shader_feature _ _ALPHA_TRANSPARENCY
           // #pragma shader_feature _GLOW_ALPHAFADE
            #pragma multi_compile _ _ALPHATEST_ON
            #pragma shader_feature _ _NORMALMAP _VERTEX_COLOR _VERTEX_WIND _VERTEX_WIND_TILING
            #define _EMISSION
			#pragma multi_compile _ _RUNTIMEMODE _RUNTIMEMODESHADOW _CUSTOMBAKED
            //#pragma multi_compile _ _SIMPLEDYNAMIC
            //#pragma multi_compile _ _RECEIVE_SHADOWS_OFF

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #define _ADDITIONAL_LIGHTS
            #define _SHADOWS_SOFT

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fog

            //--------------------------------------
            // GPU Instancing
            //#pragma multi_compile_instancing

            #pragma vertex LitPassVertexSimple
            #pragma fragment LitPassFragmentSimple
            #define BUMP_SCALE_NOT_SUPPORTED 1


            #include "Assets/Shaders/SimpleLitInputCustom.hlsl"
            #include "Assets/Shaders/SimpleLitForwardPassCustom.hlsl"
            ENDHLSL
        }
		

		Pass
        {
			Name "Depth Write"
			Tags { "LightMode" = "DepthPrime" }
			ZWrite On
			ColorMask 0
			
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Assets/Shaders/SimpleLitInputCustom.hlsl"

            struct Attributes
            {
                float4 positionOS       : POSITION;
            };

            struct Varyings
            {
                float4 vertex : SV_POSITION;
            };

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                output.vertex = vertexInput.positionCS;

                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                return half4(1,1,1,1);
            }
            ENDHLSL
        }

        Pass
        {
            Name "Glow"
            Tags { "LightMode" = "Glow" }
            ZWrite Off
            Blend One OneMinusSrcAlpha
            Offset 0,-1


            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
                // make fog work
                #pragma multi_compile_fog

                #include "Assets/Shaders/SimpleLitInputCustom.hlsl"

                struct Attributes
                {
                   float4 positionOS       : POSITION;
                   float3 normalOS         : NORMAL;
                   float2 uv               : TEXCOORD0;
                };

                struct Varyings
                {
                    float2 uv : TEXCOORD0;
                    float4 vertex : SV_POSITION;
                    float transparency : TEXCOORD2;
                };



                Varyings vert(Attributes input)
                {
                    Varyings output = (Varyings)0;

                    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                    output.vertex = vertexInput.positionCS;

                    float vignette = 1 - smoothstep(0.0, _GlowSoftness,length(vertexInput.positionWS.xyz - _GlowOriginWS.xyz) / (_GlowRange + 0.01));
                    float vignetteInner = smoothstep(0.0,_GlowSoftness, length(vertexInput.positionWS.xyz - _GlowOriginWS.xyz) / ((_GlowRange + 0.01) * _InnerWipe));
                    float revealEdgeOuter = smoothstep(_GlowHeightThreshold * 5,_GlowHeightThreshold * 5 - 2, input.positionOS.y);
                    revealEdgeOuter *= revealEdgeOuter;
                    float revealEdgeInner = revealEdgeOuter * smoothstep(_GlowHeightThreshold * 4 - 2,_GlowHeightThreshold * 4, input.positionOS.y);
                    revealEdgeInner *= revealEdgeInner * 8;
                    output.transparency = max(revealEdgeOuter,revealEdgeInner) * min(vignette,vignetteInner);
                    output.uv = TRANSFORM_TEX(input.uv, _BaseMap);

                    return output;
                }

                half4 frag(Varyings i) : SV_Target
                {
                    // sample the texture
                    half4 col = _GlowAmount * _GlowColor * 2 * lerp(half4(1,0.8,0.4,1),half4(1,1,1,1),i.transparency) * i.transparency;

                    return col;
                }
                ENDHLSL

            }
/*
            Pass
                {
                    Name "SSS"
                    Tags { "LightMode" = "SSS" }
                    ZWrite Off
                    Blend One OneMinusSrcAlpha
                    Offset -1,0

                    HLSLPROGRAM
                    #pragma vertex vert
                    #pragma fragment frag
                    // make fog work
                    #pragma multi_compile_fog

                    #include "Assets/Shaders/SimpleLitInputCustom.hlsl"

                    struct Attributes
                    {
                       float4 positionOS       : POSITION;
                       float3 normalOS         : NORMAL;
                       float2 uv               : TEXCOORD0;
                    };

                    struct Varyings
                    {
                        float2 uv : TEXCOORD0;
                        float4 vertex : SV_POSITION;
                        float transparency : TEXCOORD2;
                        half2 distance : TEXCOORD3;
                        half4 glow : TEXCOORD4;
                    };



                    Varyings vert(Attributes input)
                    {
                        Varyings output = (Varyings)0;


                        VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                        
                        float3 originVector = (vertexInput.positionWS.xyz - _GlowOriginWS.xyz);
                        float distance = length(originVector);
                        half4 periodicFactor = lerp(_SinTime, half4(1, 1, 1, 1), _InnerWipe);
                        float vignette = 1 - smoothstep(0.0, _GlowSoftness+ (periodicFactor.z + 1) * 0.2, distance / (_GlowRange + 0.01 + ((periodicFactor.z ) * 0.02)));

                        output.transparency = lerp(vignette,0,_Cutoff *_Cutoff* _Cutoff * _Cutoff);
                        output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
                        output.distance.x = length(distance /_BoundsRadius);
                        output.glow.rgb = lerp(_GlowColor * _GlowAmount, _GlowColor2, output.transparency) * lerp(0.1, 1, (periodicFactor.w + 1) * 0.5);
                        output.glow.a = (periodicFactor.w + 1) * 0.25;
                        output.distance.y = lerp(0, smoothstep(0, output.distance, _Cutoff), _Cutoff*_Cutoff);
                        //vertexInput = GetVertexPositionInputs(input.positionOS.xyz + (normalize(input.normalOS.xyz - originVector) * output.distance.y));
                        output.vertex = vertexInput.positionCS;

                        return output;
                    }

                    half4 frag(Varyings i) : SV_Target
                    {
                        // sample the texture
                        half4 data = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, i.uv);
                        half4 base = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv);
                        half edgeMask = 1 - data.a;
                        half3 glow = edgeMask * _GlowAmount * i.glow; 
                        half crackAlpha = saturate(1 - smoothstep(_GlowAmount2 - 0.4 - i.glow.a, _GlowAmount2 + i.glow.a, 1 - data.g))*lerp(1-data.a,i.transparency, _GlowAmount2);
                        half3 crack = 2 * lerp(_GlowColor2*_GlowAmount, _GlowColor, smoothstep(_GlowAmount2 - 0.4,_GlowAmount2 ,1 - data.g));
                        half alpha = max(crackAlpha, i.transparency);
                        half smoothalpha = smoothstep(_Cutoff - 0.1, _Cutoff + 0.1, i.distance.x * (1-data.g));
                        alpha *= smoothalpha;
                        half4 cutoffglow = saturate(sin(smoothalpha * 3.14159*2)) * (_GlowColor2*_GlowAmount *4);
     
                        return half4((glow + crack +cutoffglow) * alpha, alpha);
                    }
                    ENDHLSL

                }

*/
        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            ZTest LEqual
            Cull[_Cull]

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            // -------------------------------------
            // Material Keywords
            //#pragma shader_feature _GLOW_ALPHAFADE
            #pragma multi_compile _ _ALPHATEST_ON
            #pragma skip_variants _GLOSSINESS_FROM_BASE_ALPHA

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "Assets/Shaders/SimpleLitInputCustom.hlsl"
            #include "Assets/Shaders/ShadowCasterPassCustom.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags{"LightMode" = "DepthOnly"}

            ZWrite On
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            // -------------------------------------
            // Material Keywords
            #pragma multi_compile _ _ALPHATEST_ON
            #pragma skip_variants _GLOSSINESS_FROM_BASE_ALPHA

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #include "Assets/Shaders/SimpleLitInputCustom.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"
            ENDHLSL
        }

            // This pass it not used during regular rendering, only for lightmap baking.
            Pass
        {
            Name "Meta"
            Tags{ "LightMode" = "Meta" }

            Cull Off

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x

            #pragma vertex UniversalVertexMeta
            #pragma fragment UniversalFragmentMetaSimple

            #pragma shader_feature _EMISSION
            #pragma shader_feature _SPECGLOSSMAP

            #include "Assets/Shaders/SimpleLitInputCustom.hlsl"
            #include "Assets/Shaders/SimpleLitMetaPassCustom.hlsl"

            ENDHLSL
        }
            Pass
        {
            Name "Universal2D"
            Tags{ "LightMode" = "Universal2D" }
            Tags{ "RenderType" = "Transparent" "Queue" = "Transparent" }

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x

            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature _ALPHATEST_ON
            #pragma skip_variants _ALPHAPREMULTIPLY_ON

            #include "Assets/Shaders/SimpleLitInputCustom.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/Utils/Universal2D.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "Outline"
            Tags{ "LightMode" = "Outline" }

            Cull Front
            //Blend DstColor Zero

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x

            #pragma vertex vert
            #pragma fragment frag

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fog
            #pragma multi_compile_instancing
            #pragma multi_compile _ _ALPHATEST_ON

            #include "Assets/Shaders/SimpleLitInputCustom.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"


            struct Attributes
            {
                float4 positionOS       : POSITION;
                float3 normalOS         : NORMAL;
                float2 uv               : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float2 uv            : TEXCOORD0;
                float2 fogCoord     : TEXCOORD1;
                float4 vertex       : SV_POSITION;

                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                float4 clipPosition = vertexInput.positionCS;
                float3 clipNormal = mul((float3x3) UNITY_MATRIX_VP, mul((float3x3) UNITY_MATRIX_M, input.normalOS.xyz));
  //  #if ENABLE_PULSE
  //              float pulse = lerp(1, sin(_Time.x * 128) + 3, 0);
  //              float2 offset = normalize(clipNormal.xy) / _ScreenParams.xy * 1 * clipPosition.w * 2 * pulse;
  //  #else
                float ReferenceScreenHeightFactor = (_ScreenParams.y / 1080) *1.1;
                float2 offset = normalize(clipNormal.xy) / _ScreenParams.xy * ReferenceScreenHeightFactor * clipPosition.w * 2.2;
  //  #endif
                clipPosition.xy += offset;
                output.vertex = clipPosition;
                output.fogCoord = ComputeFogFactor(clipPosition.z);
                output.uv = TRANSFORM_TEX(input.uv, _BaseMap);

                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                half4 color = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);
                
                color.rgb = lerp(0,color.rgb * color.rgb *0.5, 0.5);
                color.rgb = MixFog(color.rgb, input.fogCoord);
                AlphaDiscard(0.01, _Cutoff);
                return color;
            }
            ENDHLSL
        }

            Pass
            {
                Name "OutlineUI"
                Tags{ "LightMode" = "OutlineUI" }

                Cull Front
                //Blend DstColor Zero

                HLSLPROGRAM
                // Required to compile gles 2.0 with standard srp library
                #pragma prefer_hlslcc gles
                #pragma exclude_renderers d3d11_9x

                #pragma vertex vert
                #pragma fragment frag

                // -------------------------------------
                // Unity defined keywords
                #pragma multi_compile_fog
                #pragma multi_compile_instancing
                #pragma multi_compile _ _ALPHATEST_ON

                #include "Assets/Shaders/SimpleLitInputCustom.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"


                struct Attributes
                {
                    float4 positionOS       : POSITION;
                    float3 normalOS         : NORMAL;
                    float2 uv               : TEXCOORD0;
                    UNITY_VERTEX_INPUT_INSTANCE_ID
                };

                struct Varyings
                {
                    float2 uv : TEXCOORD0;
                    float2 fogCoord     : TEXCOORD1;
                    float4 vertex       : SV_POSITION;

                    UNITY_VERTEX_INPUT_INSTANCE_ID
                    UNITY_VERTEX_OUTPUT_STEREO
                };

                Varyings vert(Attributes input)
                {
                    Varyings output = (Varyings)0;

                    UNITY_SETUP_INSTANCE_ID(input);
                    UNITY_TRANSFER_INSTANCE_ID(input, output);
                    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                    float4 clipPosition = vertexInput.positionCS;
                    float3 clipNormal = mul((float3x3) UNITY_MATRIX_VP, mul((float3x3) UNITY_MATRIX_M, input.normalOS.xyz));
                    //  #if ENABLE_PULSE
                    //              float pulse = lerp(1, sin(_Time.x * 128) + 3, 0);
                    //              float2 offset = normalize(clipNormal.xy) / _ScreenParams.xy * 1 * clipPosition.w * 2 * pulse;
                    //  #else
                    float ReferenceScreenHeightFactor = (_ScreenParams.y /  1080)*1.6;
                    float2 offset = normalize(clipNormal.xy) / _ScreenParams.xy * ReferenceScreenHeightFactor * clipPosition.w * 1.8;
                                  //  #endif
                    clipPosition.xy += offset;
                    output.vertex = clipPosition;
                    output.fogCoord = ComputeFogFactor(clipPosition.z);
                    output.uv = TRANSFORM_TEX(input.uv, _BaseMap);

                    return output;
                }

                half4 frag(Varyings input) : SV_Target
                {
                    UNITY_SETUP_INSTANCE_ID(input);
                    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                    half4 color = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);
                    half4 data = SAMPLE_TEXTURE2D(_EmissionMap, sampler_BaseMap, input.uv);
                    //color.rgb *= 0.1;
                    color.rgb = lerp(0,color.rgb* color.rgb*0.25, data.b);
                    //color.rgb = MixFog(color.rgb, input.fogCoord);
                    AlphaDiscard(0.1, _Cutoff);
                
                    return color;
            }
            ENDHLSL             
        }
    }
    Fallback "Hidden/InternalErrorShader"
    //CustomEditor "UnityEditor.Rendering.Universal.ShaderGUI.SimpleLitShader"
}
