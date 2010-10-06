// Upgrade NOTE: replaced 'PositionFog()' with multiply of UNITY_MATRIX_MVP by position
// Upgrade NOTE: replaced 'V2F_POS_FOG' with 'float4 pos : SV_POSITION'
// Upgrade NOTE: replaced 'glstate.matrix.mvp' with 'UNITY_MATRIX_MVP'

Shader "OceanReflectionRefraction" 
{
	Properties 
	{
		_SurfaceColor ("SurfaceColor", Color) = (1,1,1,1)
		_WaterColor ("WaterColor", Color) = (1,1,1,1)
		_Refraction ("Refraction (RGB)", 2D) = "white" {}
		_Reflection ("Reflection (RGB)", 2D) = "white" {}
		_Fresnel ("Fresnel (A) ", 2D) = "gray" {}
		_Bump ("Bump (RGB)", 2D) = "bump" {}
		_Foam ("Foam (RGB)", 2D) = "white" {}
		_Size ("Size", Vector) = (1, 1, 1, 1)
		_SunDir ("SunDir", Vector) = (0.3, -0.6, -1, 0)
	}
	SubShader {
    Pass {

CGPROGRAM
// Upgrade NOTE: excluded shader from Xbox360; has structs without semantics (struct v2f members projTexCoord,bumpTexCoord,viewDir,lightDir,objSpaceNormal,foamStrengthAndDistance)
#pragma exclude_renderers xbox360
#pragma vertex vert
#pragma fragment frag
#pragma fragmentoption ARB_fog_exp2
#include "UnityCG.cginc"

struct v2f 
{
    float4 pos : SV_POSITION;
    float4  projTexCoord;
    float2  bumpTexCoord;
    float3  viewDir;
    float3  lightDir;
    float3  objSpaceNormal;
    float2   foamStrengthAndDistance;
};

float4 _Size;
float4 _SunDir;

v2f vert (appdata_tan v)
{
    v2f o;
    
    
    o.bumpTexCoord.xy = v.vertex.xz/float2(_Size.x, _Size.z)*10;
    
    
    o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
    
    o.foamStrengthAndDistance.x = v.tangent.w;
    o.foamStrengthAndDistance.y = clamp(o.pos.z, 0, 1.0);
    
    
  	float4 projSource = float4(v.vertex.x, 0.0, v.vertex.z, 1.0);
    float4 tmpProj = mul( UNITY_MATRIX_MVP, projSource);
    o.projTexCoord = tmpProj;
  /*  
    //Bias matrix for converting clip-space vertex positions
    //to texture coordinates.
    float3x4 mat = float3x4(
    0.5, 0.0, 0.0, 0.5,
    0.0, 0.5 * _ProjectionParams.x, 0.0, 0.5,
    0.0, 0.0, 0.5, 0.5
    );
    
    o.projTexCoord.xy = mul(mat, tmpProj).xy;
    o.projTexCoord.xy /= tmpProj.w;
   */ 
    float3 objSpaceViewDir = ObjSpaceViewDir(v.vertex);
    
    //o.normal = v.normal;
    float3 binormal = cross( normalize(v.normal), normalize(v.tangent.xyz) );
	float3x3 rotation = float3x3( v.tangent.xyz, binormal, v.normal );
    
    o.objSpaceNormal = v.normal;
    o.viewDir = mul(rotation, objSpaceViewDir);
    
    o.lightDir = mul(rotation, float3(_SunDir.xyz));
    
    return o;
}

sampler2D _Refraction;
sampler2D _Reflection;
sampler2D _Fresnel;
sampler2D _Bump;
sampler2D _Foam;
half4 _SurfaceColor;
half4 _WaterColor;

half4 frag (v2f i) : COLOR
{
	half3 normViewDir = normalize(i.viewDir);

	half4 buv = half4(i.bumpTexCoord.x + _Time.x * 0.03, i.bumpTexCoord.y + _SinTime.x * 0.2, i.bumpTexCoord.x + _Time.y * 0.04, i.bumpTexCoord.y + _SinTime.y * 0.5);

	half3 tangentNormal0 = (tex2D(_Bump, buv.xy).rgb * 2.0) - 1;
	half3 tangentNormal1 = (tex2D(_Bump, buv.zw).rgb * 2.0) - 1;
	half3 tangentNormal = normalize(tangentNormal0 + tangentNormal1);
	
	float2 projTexCoord = 0.5 * i.projTexCoord.xy * float2(1, _ProjectionParams.x) / i.projTexCoord.w + float2(0.5, 0.5);
	
	half4 result = half4(0, 0, 0, 1);
	
	float2 bumpSampleOffset = i.objSpaceNormal.xz * 0.05 + tangentNormal.xy * 0.05;
	
	
	half3 reflection = tex2D(_Reflection, projTexCoord.xy + bumpSampleOffset).rgb * _SurfaceColor.rgb;
	half3 refraction = tex2D(_Refraction, projTexCoord.xy + bumpSampleOffset).rgb * _WaterColor.rgb;

	float fresnelLookup = dot(tangentNormal, normViewDir);
	
	//float fresnelTerm = tex2D(_Fresnel, float2(fresnelLookup, 0.5)).a;
	
	float bias = 0.06;
	float power = 4.0;
	float fresnelTerm = bias + (1.0-bias)*pow(1.0 - fresnelLookup, power);
	
	float foamStrength = i.foamStrengthAndDistance.x * 1.8;
	
	half4 foam = clamp(tex2D(_Foam, i.bumpTexCoord.xy * 1.0)  - 0.5, 0.0, 1.0) * foamStrength;

	
	float3 halfVec = normalize(normViewDir - normalize(i.lightDir));
    float specular = pow(max(dot(halfVec, tangentNormal.xyz), 0.0), 250.0);

	result.rgb = lerp(refraction, reflection, fresnelTerm) + clamp(foam.r, 0.0, 1.0) + specular;

	result.rgb = result.rgb;//*0.001 + fresnelTerm;// * 0.001 + fresnelTerm;
	result.a = 1.0;

    return result;
}
ENDCG

    }
}

}
