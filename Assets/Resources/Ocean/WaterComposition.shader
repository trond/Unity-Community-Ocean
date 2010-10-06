// Upgrade NOTE: replaced 'PositionFog()' with multiply of UNITY_MATRIX_MVP by position
// Upgrade NOTE: replaced 'V2F_POS_FOG' with 'float4 pos : SV_POSITION'
// Upgrade NOTE: replaced 'samplerRect' with 'sampler2D'
// Upgrade NOTE: replaced 'texRECT' with 'tex2D'

Shader "WaterComposition" {
	Properties 
	{
		_MainTex ("Overwater (RGB)", Rect) = "white" {}
		_DepthTex ("Depth (RGB)", 2D) = "black" {}
		_UnderwaterTex ("Underwater (RGB)", 2D) = "white" {}
		_UnderwaterDistortionTex ("Underwater Distortion (RGB)", 2D) = "bump" {}
		_MainTexSize ("MainTexSize", Vector) = (512,512,0,0)
		_WaterColor ("WaterColor", Color) = (0.2, 0.3, 0.2, 1.0)
	}
	SubShader 
	{
		Pass {
		Cull Off

CGPROGRAM
// Upgrade NOTE: excluded shader from OpenGL ES 2.0 because it uses non-square matrices
#pragma exclude_renderers gles
// Upgrade NOTE: excluded shader from Xbox360; has structs without semantics (struct v2f members maskSpacePos,uv)
#pragma exclude_renderers xbox360
#pragma vertex vert
#pragma fragment frag
#pragma fragmentoption ARB_fog_exp2
#include "UnityCG.cginc"

struct v2f 
{
    float4 pos : SV_POSITION;
    float4 maskSpacePos;
    float4 uv;
};


sampler2D _MainTex;
sampler2D _DepthTex;
sampler2D _UnderwaterTex;
sampler2D _UnderwaterDistortionTex;

uniform float4x4 _DepthCamMV;
uniform float4x4 _DepthCamProj;
float4 _WaterColor;

uniform float4 _MainTex_TexelSize;

v2f vert (appdata_base v)
{
    v2f o;   
    
    o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
    
    o.uv.xy = v.texcoord.xy;
    o.uv.zw = v.texcoord.xy;
    
    #if SHADER_API_D3D9
    if (_MainTex_TexelSize.y < 0)
    {
    	o.uv.w = 1.0 - o.uv.w;
    }
    
    o.uv.zw += float2(_MainTex_TexelSize.x * 0.5, abs(_MainTex_TexelSize.y) * 0.5);
    #endif
    
    //The plane is already defined in world space.
    float4 tmpModelView = mul(_DepthCamMV, v.vertex);
    float4 tmpProj = mul(_DepthCamProj, tmpModelView);
    
    
    //Bias matrix for converting clip-space vertex positions
    //to texture coordinates.
    float3x4 mat = float3x4(
    0.5, 0.0, 0.0, 0.5,
    0.0, 0.5 * _ProjectionParams.x, 0.0, 0.5,
    0.0, 0.0, 0.0, 0.0
    );
    
    o.maskSpacePos.xy = mul(mat, tmpProj).xy;
    
    //Note: 20.0 is to keep viewspace values in the 0-1 range. This is because the depth camera has
    //a view distance of 20.0. Also, -0.3 is to offset the water intersection a bit, this can be
    //tweaked until it "feels" right. This is somewhat related to the offset in DeepWaterBelow.shader.
    o.maskSpacePos.z = -(tmpModelView.z - 0.3)/20.0;
 
    return o;
}

half4 frag (v2f i) : COLOR
{
	half3 source = tex2D(_MainTex, i.uv.zw).rgb;
	float depth = tex2D(_DepthTex, i.maskSpacePos.xy).r;
	
	//Yann's tweak
	float2 uvscaled = i.uv.xy*0.03 + _Time.x/10.0;
	float2 distort = ((tex2D(_UnderwaterDistortionTex, uvscaled).rg * 4.0) - 2.2);
	
	half3 underwater = tex2D(_UnderwaterTex, i.uv.xy + distort * 0.05).rgb;


	
	float delta =  i.maskSpacePos.z - depth;
	
	float underwaterFactor = 0.0;
	
	if (delta >= 0)
		underwaterFactor = 1.0;
	
	//Smooth out the water/air intersection. This can be used to sample from a foam texture
	//for improved effect.
	underwaterFactor += (0.01 - clamp(abs(delta), 0, 0.01)) * 100;
	
	underwaterFactor = clamp(underwaterFactor, 0, 1);
	
	half3 result = lerp(source, underwater * _WaterColor, underwaterFactor);
	

    return half4(result, 1.0);
}
ENDCG

    }
	} 
}