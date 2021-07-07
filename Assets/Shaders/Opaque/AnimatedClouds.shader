Shader "Squad/Map/Animated Clouds"
{
    Properties
    {
        _MainTex ("Base Texture", 2D) = "white" {}
		_CloudsTex ("Clouds Texture", 2D) = "white" {}

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag


            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
				float4 color    : COLOR;
                float2 uv : TEXCOORD0;

            };

            struct v2f
            {
				float4 color    : COLOR;
                float2 uv : TEXCOORD0;
				float2 uv3 : TEXCOORD1;
				float2 uv4 : TEXCOORD2;
				float2 uv5 : TEXCOORD3;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
			sampler2D _CloudsTex;

            float4 _MainTex_ST;
			float4 _CloudsTex_ST;

            v2f vert (appdata v)
            {
                v2f o;				
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color= v.color;

                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv3 = TRANSFORM_TEX(v.uv , _CloudsTex);
				o.uv4 = (o.uv3 *2) - half2(_Time.x*0.16,0);
				o.uv5 = (o.uv3) - half2(_Time.x *0.05,0);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                // sample the texture
                half4 base = tex2D(_MainTex, i.uv);
				
				//clouds
				half4 distort = tex2D(_CloudsTex, i.uv3);
				half4 unrevealedMask = tex2D(_CloudsTex, i.uv4);
				half4 distortLowFreq = tex2D(_CloudsTex, i.uv5);
				half4 unrevealed = tex2D(_MainTex, i.uv + half2(distortLowFreq.a* distortLowFreq.a * unrevealedMask.a * unrevealedMask.a* unrevealedMask.a ,0));
				//unrevealed  = max(unrevealed, base);

                
                base.rgb = lerp(unrevealed.rgb, base.rgb ,base.a); //add lines
				
                return base;
            }
            ENDCG
        }
    }
}
