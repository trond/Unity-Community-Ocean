// Upgrade NOTE: replaced 'PositionFog()' with multiply of UNITY_MATRIX_MVP by position
// Upgrade NOTE: replaced 'V2F_POS_FOG' with 'float4 pos : SV_POSITION'
// Upgrade NOTE: replaced 'glstate.matrix.modelview[0]' with 'UNITY_MATRIX_MV'

Shader "WaterHeight" 
{
	Properties 
	{
	}
	SubShader 
	{
		Pass {
		Cull Off

CGPROGRAM
// Upgrade NOTE: excluded shader from Xbox360; has structs without semantics (struct v2f members depth)
#pragma exclude_renderers xbox360
#pragma vertex vert
#pragma fragment frag
#pragma fragmentoption ARB_fog_exp2
#include "UnityCG.cginc"

struct v2f 
{
    float4 pos : SV_POSITION;
    float depth;
};

v2f vert (appdata_base v)
{
    v2f o;   
    
    
    o.pos = mul (UNITY_MATRIX_MVP, v.vertex);


    o.depth = -mul(UNITY_MATRIX_MV, v.vertex).z/20.0;//(o.pos.z + 1)/2.0;

    
    return o;
}

float4 frag (v2f i) : COLOR
{
    return float4(i.depth);
}
ENDCG

    }
	} 
	FallBack "Diffuse", 1
}
