// Upgrade NOTE: replaced 'PositionFog()' with multiply of UNITY_MATRIX_MVP by position
// Upgrade NOTE: replaced 'V2F_POS_FOG' with 'float4 pos : SV_POSITION'
// Upgrade NOTE: replaced 'glstate.matrix.mvp' with 'UNITY_MATRIX_MVP'

Shader "DeepWaterBelow" 
{
	Properties 
	{
		_Color ("Main Color", Color) = (1,1,1,1)
		_UnderWaterRefraction ("UnderWaterRefraction (RGB)", 2D) = "white" {}
		_UnderWaterBump ("UnderWaterBump (RGB)", 2D) = "bump" {}
		_Fresnel ("Fresnel (A) ", 2D) = "gray" {}
		_Size ("Size", Vector) = (1, 1, 1, 1)
	}
	SubShader {
    Pass {

CGPROGRAM
// Upgrade NOTE: excluded shader from Xbox360; has structs without semantics (struct v2f members viewDir,projTexCoord,bumpTexCoord)
#pragma exclude_renderers xbox360
#pragma vertex vert
#pragma fragment frag
#pragma fragmentoption ARB_fog_exp2
#include "UnityCG.cginc"

struct v2f 
{
    float4 pos : SV_POSITION;
    float3  viewDir;
 //   float3  normal;
    float4  projTexCoord;
    float4 bumpTexCoord;
};

float4 _Size;

v2f vert (appdata_tan v)
{
    v2f o;
    
       
    //Need to offset a bit in height, so we don't completely miss the
    //water intersection filter.
    v.vertex.y += 0.5;
 
 
    float4 projSource = float4(v.vertex.x, 0.0, v.vertex.z, 1.0);
    float4 tmpProj = mul( UNITY_MATRIX_MVP, projSource);
    o.projTexCoord = tmpProj;
   
    o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
 
 	o.bumpTexCoord.xy = v.vertex.xz/float2(_Size.x, _Size.z)*10;
    
    float3 objSpaceViewDir = ObjSpaceViewDir(v.vertex);
  //  o.normal = -v.normal;
    
    float3 binormal = cross( normalize(v.normal), normalize(v.tangent.xyz) );
	float3x3 rotation = float3x3( v.tangent.xyz, binormal, v.normal );
    
    o.viewDir = mul(rotation, objSpaceViewDir);
    
    return o;
}

sampler2D _UnderWaterRefraction;
sampler2D _UnderWaterBump;
sampler2D _Fresnel;


half4 frag (v2f i) : COLOR
{
	float2 projTexCoord = 0.5 * i.projTexCoord.xy * float2(1, _ProjectionParams.x) / i.projTexCoord.w + float2(0.5, 0.5);

	half4 buv = half4(i.bumpTexCoord.x + _Time.x * 0.03, i.bumpTexCoord.y + _SinTime.x * 0.2, i.bumpTexCoord.x + _Time.y * 0.04, i.bumpTexCoord.y + _SinTime.y * 0.5);


	half3 tangentNormal0 = (tex2D(_UnderWaterBump, buv.xy).rgb * 2.0) - 1;
	half3 tangentNormal1 = (tex2D(_UnderWaterBump, buv.zw).rgb * 2.0) - 1;
	half3 tangentNormal = -normalize(tangentNormal0 + tangentNormal1);	

	half3 refraction = tex2D(_UnderWaterRefraction, projTexCoord.xy + tangentNormal.xy * 0.2).rgb;

	half3 normViewDir = normalize(i.viewDir);
	//half3 normNormal = normalize(i.normal);

	float fresnelLookup = dot(tangentNormal, normViewDir);
	
	//float fresnelTerm = tex2D(_Fresnel, float2(fresnelLookup, 0.5)).a;
	
	float bias = 0.0;
	float power = 1.0;
	float fresnelTerm = bias + (1.0-bias)*pow(1.0 - fresnelLookup, power);

	half4 clr;
	
	clr.rgb = lerp(refraction, float3(0.3, 0.3, 0.3), fresnelTerm);// * 0.001 + fresnelTerm;
	clr.a = 1.0;

    return clr;
}
ENDCG

    }
}
Fallback "VertexLit"
}
