Shader "Unlit/ScreenWaterDropEffect"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_ScreenWaterDropTex("Water Drop Texture",2D)="white"{}
		_CurTime("Time",Range(0.0,1.0))=1.0
		_SizeX("SizeX",Range(0.0,1.0))=1.0
		_SizeY("SizeY",Range(0.0,1.0))=1.0
		_DropSpeed("DropSpeed",Range(0.0,10.0))=1.0
		_Distortion("Distortion",Range(0.0,1.0))=0.87
	}
	SubShader
	{
		Pass
		{
		   ZTest Always
		   CGPROGRAM
		     #pragma vertex vert  
            #pragma fragment frag  
            #pragma fragmentoption ARB_precision_hint_fastest  

		   #pragma target 3.0

		   #include "UnityCG.cginc"
		    uniform sampler2D _MainTex;  
            uniform sampler2D _ScreenWaterDropTex;  
            uniform float _CurTime;  
            uniform float _DropSpeed;  
            uniform float _SizeX;  
            uniform float _SizeY;  
            uniform float _Distortion;  
            uniform float2 _MainTex_TexelSize;

            struct vertexInput  
            {  
                float4 vertex : POSITION;//顶点位置  
                float4 color : COLOR;//颜色值  
                float2 texcoord : TEXCOORD0;//一级纹理坐标  
            };  
  
            //顶点输出结构  
            struct vertexOutput  
            {  
                half2 texcoord : TEXCOORD0;//一级纹理坐标  
                float4 vertex : SV_POSITION;//像素位置  
                fixed4 color : COLOR;//颜色值  
            };  

            vertexOutput vert(vertexInput Input)
            {
                vertexOutput Output;
                Output.vertex=mul(UNITY_MATRIX_MVP,Input.vertex);
                Output.color=Input.color;
                Output.texcoord=Input.texcoord;
                return Output;
            }
            fixed4 frag(vertexOutput i):COLOR
            {
                float2 uv=i.texcoord.xy;
                #if UNITY_UV_STARTS_AT_TOP  
                if (_MainTex_TexelSize.y < 0)  
                    _DropSpeed = 1 - _DropSpeed;  
                #endif  
                float3 rainTex1 = tex2D(_ScreenWaterDropTex, float2(uv.x * 1.15* _SizeX, (uv.y* _SizeY *1.1) + _CurTime* _DropSpeed *0.15)).rgb / _Distortion;  
                float3 rainTex2 = tex2D(_ScreenWaterDropTex, float2(uv.x * 1.25* _SizeX - 0.1, (uv.y *_SizeY * 1.2) + _CurTime *_DropSpeed * 0.2)).rgb / _Distortion;  
                float3 rainTex3 = tex2D(_ScreenWaterDropTex, float2(uv.x* _SizeX *0.9, (uv.y *_SizeY * 1.25) + _CurTime * _DropSpeed* 0.032)).rgb / _Distortion;  
                 //整合三层水流效果的颜色信息，存于finalRainTex中  
                float2 finalRainTex = uv.xy - (rainTex1.xy - rainTex2.xy - rainTex3.xy) / 3;  
                //按照finalRainTex的坐标信息，在主纹理上进行采样  
                float3 finalColor = tex2D(_MainTex, float2(finalRainTex.x, finalRainTex.y)).rgb;  
                //返回加上alpha分量的最终颜色值  
                return fixed4(finalColor, 1.0);  
            }
            ENDCG
		}
	}
}
