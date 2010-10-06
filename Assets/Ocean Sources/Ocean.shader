// Upgrade NOTE: replaced 'PositionFog()' with multiply of UNITY_MATRIX_MVP by position
// Upgrade NOTE: replaced 'V2F_POS_FOG' with 'float4 pos : SV_POSITION'
// Upgrade NOTE: replaced '_PPLAmbient' with 'UNITY_LIGHTMODEL_AMBIENT'

Shader "Reflective/Ocean Bumped Diffuse" {
Properties {
	_Color ("Main Color", Color) = (1,1,1,1)
	_ReflectColor ("Reflection Color", Color) = (1,1,1,0.5)
	_MainTex ("Base (RGB) RefStrength (A)", 2D) = "white" {}
	_Cube ("Reflection Cubemap", Cube) = "_Skybox" { TexGen CubeReflect }
	_BumpMap ("Bumpmap A (RGB)", 2D) = "bump" {}
	_BumpMap2 ("Bumpmap B (RGB)", 2D) = "bump2" {}
	_BlendA ("BlendA", Range(-1.0,1.0)) = 0.0
	_BlendB ("BlendB", Range(-1.0,1.0)) = 0.0
      
}

Category {
	/* Upgrade NOTE: commented out, possibly part of old style per-pixel lighting: Blend AppSrcAdd AppDstAdd */
	Fog { Color [_AddFog] }
	
	// ------------------------------------------------------------------
	// ARB fragment program / Radeon 9000
	
	SubShader {
//		UsePass "Reflective/Ocean Bumped Unlit/BASE" 
		Pass {
			Name "BASE"
			Tags {"LightMode" = "Always"}
CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma fragmentoption ARB_fog_exp2
#pragma fragmentoption ARB_precision_hint_fastest

#include "UnityCG.cginc"
#include "AutoLight.cginc" 

struct v2f {
	float4 pos : SV_POSITION;
	float2	uv		: TEXCOORD0;
	float2	uv2		: TEXCOORD1;
	float3	I		: TEXCOORD2;
	float3	TtoW0 	: TEXCOORD3;
	float3	TtoW1	: TEXCOORD4;
	float3	TtoW2	: TEXCOORD5;
};

uniform float4 _MainTex_ST, _BumpMap_ST;

v2f vert(appdata_tan v)
{
	v2f o;
	o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
	o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
	o.uv2 = TRANSFORM_TEX(v.texcoord,_BumpMap);
	
	o.I = mul( (float3x3)_Object2World, -ObjSpaceViewDir( v.vertex ) );	
	
	TANGENT_SPACE_ROTATION;
	o.TtoW0 = mul(rotation, _Object2World[0].xyz);
	o.TtoW1 = mul(rotation, _Object2World[1].xyz);
	o.TtoW2 = mul(rotation, _Object2World[2].xyz);
	
	return o; 
}
 
uniform sampler2D _BumpMap;
uniform sampler2D _BumpMap2;
uniform sampler2D _MainTex;
uniform samplerCUBE _Cube;
uniform float4 _ReflectColor;
uniform float4 _Color;
uniform float _BlendA;
uniform float _BlendB;

float4 frag (v2f i) : COLOR
{
	// Sample and expand the normal map texture	
	half4 normal = ((tex2D (_BumpMap,i.uv2) - 0.5) *_BlendA + (tex2D(_BumpMap2,i.uv2) - 0.5)*_BlendB)*2;
	normal.z = tex2D (_BumpMap,i.uv2).z + tex2D (_BumpMap2,i.uv2).z;
	normal.w = 1.0;
	normal = normalize (normal);
	
	half4 texcol = tex2D(_MainTex,i.uv);
	
	// transform normal to world space
	half3 wn;
	wn.x = dot(i.TtoW0, normal.xyz);
	wn.y = dot(i.TtoW1, normal.xyz);
	wn.z = dot(i.TtoW2, normal.xyz);
	
	// calculate reflection vector in world space
	half3 r = reflect(i.I, wn);

// N - normal
// E - Eye
// (L - light) 
	float3 eye = -normalize(i.I);
//	wn = normalize (wn);
	
	// fresnel - could use 1D tex lookup for this
    float facing = 1.0 - max(dot(eye, wn), 0);
    float fresnel = 0.05 + (1.0-0.2)*exp(log(facing) * 6.0);
	
	half4 c = UNITY_LIGHTMODEL_AMBIENT * texcol;
	c.rgb *= 2;
	half4 reflcolor = _ReflectColor * texCUBE(_Cube, r);// *  * texcol.a;
	return lerp (c, reflcolor, fresnel);
}
ENDCG  
		}
/*		
		Pass { 
			Name "BASE"
			Tags {"LightMode" = "Vertex"}
			Blend AppSrcAdd AppDstAdd
			Material {
				Diffuse [_Color]
			}
			Lighting On
			SetTexture [_MainTex] { combine texture alpha * primary DOUBLE, texture * primary }
		}
		UsePass "Bumped Diffuse/PPL"

		Pass {	
			Name "PPL"
			Tags { "LightMode" = "Pixel" }
				
CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma multi_compile_builtin
#pragma fragmentoption ARB_fog_exp2
#pragma fragmentoption ARB_precision_hint_fastest
#include "UnityCG.cginc"
#include "AutoLight.cginc"

struct v2f { 
	V2F_POS_FOG;
	LIGHTING_COORDS
	float2	uv;
	float2	uv2;
	float3	lightDirT;
};

uniform float4 _MainTex_ST, _BumpMap_ST;

v2f vert (appdata_tan v)
{
	v2f o;
	PositionFog( v.vertex, o.pos, o.fog );
	o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
	o.uv2 = TRANSFORM_TEX(v.texcoord,_BumpMap);
	
	TANGENT_SPACE_ROTATION;
	o.lightDirT = mul( rotation, ObjSpaceLightDir( v.vertex ) );	
	
	TRANSFER_VERTEX_TO_FRAGMENT(o);
	return o;
}

uniform sampler2D _BumpMap;
uniform sampler2D _BumpMap2;
uniform sampler2D _MainTex;
uniform float _BlendA;
uniform float _BlendB;

float4 frag (v2f i) : COLOR
{
	float4 texcol = tex2D(_MainTex,i.uv);
	
	// get normal from the normal map
//	float3 normal = tex2D(_BumpMap, i.uv2).xyz * 2 - 1;

	float3 normal = ((tex2D (_BumpMap,i.uv2).xyz - 0.5) *_BlendA + (tex2D(_BumpMap2,i.uv2).xyz - 0.5)*_BlendB)*2;
	normal.z = tex2D (_BumpMap,i.uv2).z + tex2D (_BumpMap2,i.uv2).z;
	normal = normalize (normal);

	return DiffuseLight( i.lightDirT, normal, texcol, LIGHT_ATTENUATION(i) );
}
ENDCG  
		}
		*/
	}
}

FallBack "Reflective/VertexLit", 1

}
