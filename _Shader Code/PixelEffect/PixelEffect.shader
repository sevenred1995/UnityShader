Shader "Unlit/PixelEffect"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Params("PixelNumPerRow(x)Ratio(y)",Vector)=(80,1,1,1.5)
	}
	SubShader
	{
		Cull Off
		ZWrite Off
		ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex   vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct vertexInput
			{
				float2 texcoord:TEXCOORD0;
				float4 vertex:POSITION;
			};
			struct vertexOutput{
				float2 texcoord:TEXCOORD0;
				float4 vertex:SV_POSITION;
			};
			sampler2D _MainTex;
			half4 _Params;
			vertexOutput vert(vertexInput Input)
			{
				vertexOutput o;
				o.vertex=mul(UNITY_MATRIX_MVP,Input.vertex);
				o.texcoord=Input.texcoord;
				return o;
			}
			//进行像素化操作的自定义函数PixelateOperation  
            half4 PixelateOperation(sampler2D tex, half2 uv, half scale, half ratio)  
            {
            	half PixelSize=1.0/scale;
            	half coordX =PixelSize*ceil(uv.x/PixelSize);
            	half coordY = (ratio * PixelSize)* ceil(uv.y / PixelSize / ratio);  
                half2 coord = half2(coordX,coordY);  
                return half4(tex2D(tex, coord).xyzw);  
            }
            half4 frag(vertexOutput Input):COLOR
            {
            	return PixelateOperation(_MainTex,Input.texcoord,_Params.x,_Params.y);
            }
			ENDCG
		}
	}
}
