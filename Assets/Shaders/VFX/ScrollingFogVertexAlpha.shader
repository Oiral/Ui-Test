// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "MC/Map/Scrolling Fog Vertex Alpha" {
Properties {
	_BaseColor ("Base Color", Color) = (1,1,1,1)
    _TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
    _MainTex ("Particle Texture", 2D) = "white" {}
	_ScrollMap ("Scrolling Texture", 2D) = "white" {}
    _InvFade ("Soft Particles Factor", Range(0.01,3.0)) = 1.0
	_ScrollSpeed("Horizontal Scroll Speed", Range(-5.0,5.0)) = 1.0
	_ScrollSpeedBase("Base Horizontal Scroll Speed", Range(-5.0,5.0)) = 0.0
	_EdgeTightness("Edge Tightness", Range(0.0,2.0)) = 0.5
}

Category {
    Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }
    Blend One OneMinusSrcAlpha
    Cull Off Lighting Off ZWrite Off

    SubShader {
        Pass {

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
            #pragma multi_compile_particles
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            sampler2D _MainTex;
			sampler2D _ScrollMap;
			float _ScrollSpeed;
			float _ScrollSpeedBase;
			float _EdgeTightness;
            fixed4 _TintColor;
			fixed4 _BaseColor;

            struct appdata_t {
                float4 vertex : POSITION;
                fixed4 color : COLOR;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR;
                float2 texcoord : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                UNITY_VERTEX_OUTPUT_STEREO
            };

            float4 _MainTex_ST;
			float4 _ScrollMap_ST;

            v2f vert (appdata_t v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.vertex = UnityObjectToClipPos(v.vertex);

                o.color = v.color * _TintColor;
                o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            float _InvFade;

            fixed4 frag (v2f i) : SV_Target
            {

                fixed4 col = 2.0f * i.color * tex2D(_MainTex, i.texcoord +  frac((_Time.yy * float2(_ScrollSpeedBase,0)))) * tex2D(_ScrollMap, i.texcoord + frac((_Time.yy * float2(_ScrollSpeed,0))));
                col.a = saturate(smoothstep(_EdgeTightness*0.1,_EdgeTightness,col.a)); // alpha should not have double-brightness applied to it, but we can't fix that legacy behaior without breaking everyone's effects, so instead clamp the output to get sensible HDR behavior (case 967476)
				col *= _BaseColor;
				//UNITY_APPLY_FOG(i.fogCoord, col);
				col.rgb *= col.a;
				
                return col;
            }
            ENDCG
        }
    }
}
}
