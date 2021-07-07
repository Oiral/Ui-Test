#ifndef UNIVERSAL_SIMPLE_LIT_INPUT_INCLUDED
#define UNIVERSAL_SIMPLE_LIT_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Assets/Shaders/SurfaceInputCustom.hlsl"

CBUFFER_START(UnityPerMaterial)
float4 _BaseMap_ST;
half4 _BaseColor;
//half4 _SpecColor;
half4 _EmissionColor;
half _BaseBlend;
half _Cutoff;
half _Surface;
half4 _LerpColor;
half4 _GlowColor;
half4 _GlowColor2;
half _GlowAmount;
half _GlowAmount2;
half _GlowHeightThreshold;
half4 _GlowOriginWS;
half _GlowSoftness;
half _GlowRange;
half _InnerWipe;
half4 ProbeExtentsWSMin;
half4 ProbeExtentsWSMax;
half _LightProbeOffset;
half _BoundsRadius;
CBUFFER_END



half4 SampleSpecularSmoothness(half2 uv, half alpha, half4 specColor, TEXTURE2D_PARAM(specMap, sampler_specMap))
{
    half4 specularSmoothness = half4(0.0h, 0.0h, 0.0h, 1.0h);
#ifdef _SPECGLOSSMAP
    specularSmoothness = SAMPLE_TEXTURE2D(specMap, sampler_specMap, uv) * specColor;
#elif defined(_SPECULAR_COLOR)
    specularSmoothness = specColor;
#endif

#ifdef _GLOSSINESS_FROM_BASE_ALPHA
    specularSmoothness.a = exp2(10 * alpha + 1);
#else
    specularSmoothness.a = exp2(10 * specularSmoothness.a + 1);
#endif

    return specularSmoothness;
}

#endif
