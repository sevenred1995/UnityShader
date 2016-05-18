Shader "Unlit/SimpleRayShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color("Main Color",color)=(1,1,1,1)
		_RimColor("RimColor",color)=(1,1,1,1)

	}
	SubShader
	{
		Tags{"RenderType"="Opaque"}
		LOD 200
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			ZTest Greater
			ZWrite Off
			Lighting Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			float4 _RimColor;

			struct v2f {
				float4  pos : SV_POSITION;
				float3	color:COLOR;
			};

			v2f vert (appdata_base v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
				float3 viewDir = normalize(ObjSpaceViewDir(v.vertex));
                float dotProduct = 1 - dot(v.normal, viewDir);
                float rimWidth = 0.5;
			    o.color.rgb = smoothstep(1 - rimWidth, 1.0, dotProduct);
                o.color *= _RimColor;
				return o;
			}
			float4 frag (v2f i) : COLOR
			{

				float4 outp;
				outp.rgb = i.color+i.color;
				outp.a = i.color;
				return outp; 
			}
			ENDCG
		}
		Pass
		{
			ZTest Less
			Lighting On
			Blend SrcAlpha OneMinusSrcAlpha
			Material
			{
				Diffuse [_Color]				
			}
			SetTexture[_MainTex]
			{
				Combine texture * primary DOUBLE
			}
		}
	}
	FallBack "Diffuse"
}
