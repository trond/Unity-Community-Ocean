Shader "Hidden/Grayscale Effect" {
Properties {
	_MainTex ("Base (RGB)", RECT) = "white" {}
	_RampTex ("Base (RGB)", 2D) = "grayscaleRamp" {}
}

#warning Upgrade NOTE: SubShader commented out because of manual shader assembly
/*SubShader {
	Pass {
		ZTest Always Cull Off ZWrite Off
		Fog { Mode off }

/*

Cg 1.5 has a bug where this shader compiles incorrectly for D3D.
So we don't actually compile the shader, instead below is the
compiled&fixed assembly version.
		
CGPROGRAM
#pragma vertex vert_img
#pragma fragment frag
#pragma fragmentoption ARB_precision_hint_fastest
#include "UnityCG.cginc"

uniform samplerRECT _MainTex;
uniform sampler2D _RampTex;
uniform float4    _RampOffset;

float4 frag (v2f_img i) : COLOR
{
	float4 orig = texRECT(_MainTex, i.uv);
	float4 color;	
	
	color.r = tex2D(_RampTex, float2(orig.r + _RampOffset.r, 0)).r;
	color.g = tex2D(_RampTex, float2(orig.g + _RampOffset.g, 0)).g;
	color.b = tex2D(_RampTex, float2(orig.b + _RampOffset.b, 0)).b;
	color.a = orig.a;
	
	return color;
}
ENDCG
*/


Program "" {
SubProgram {
Keywords { }
Bind "vertex", Vertex
Bind "texcoord", TexCoord0
"!!ARBvp1.0
# 8 instructions
PARAM c[9] = { { 0 },
		state.matrix.mvp,
		state.matrix.texture[0] };
TEMP R0;
MOV R0.zw, c[0].x;
MOV R0.xy, vertex.texcoord[0];
DP4 result.texcoord[0].y, R0, c[6];
DP4 result.texcoord[0].x, R0, c[5];
DP4 result.position.w, vertex.position, c[4];
DP4 result.position.z, vertex.position, c[3];
DP4 result.position.y, vertex.position, c[2];
DP4 result.position.x, vertex.position, c[1];
END
"
}

SubProgram {
Keywords { }
Bind "vertex", Vertex
Bind "texcoord", TexCoord0
Matrix 0, [glstate_matrix_mvp]
Matrix 4, [glstate_matrix_texture0]
"vs_1_1
dcl_position v0
dcl_texcoord0 v1
def c8, 0.000000, 0, 0, 0
mov r0.zw, c8.x
mov r0.xy, v1
dp4 oT0.y, r0, c5
dp4 oT0.x, r0, c4
dp4 oPos.w, v0, c3
dp4 oPos.z, v0, c2
dp4 oPos.y, v0, c1
dp4 oPos.x, v0, c0
"
}

SubProgram {
Keywords { }
Local 0, [_RampOffset]
SetTexture [_MainTex] {RECT}
SetTexture [_RampTex] {2D}
"!!ARBfp1.0
OPTION ARB_precision_hint_fastest;
PARAM c[2] = { program.local[0],
		{ 0 } };
TEMP R0;
TEX R0, fragment.texcoord[0], texture[0], RECT;
MOV result.color.w, R0;
MOV R0.w, c[1].x;
ADD R0.z, R0, c[0];
TEX result.color.z, R0.zwzw, texture[1], 2D;
ADD R0.z, R0.y, c[0].y;
MOV R0.w, c[1].x;
MOV R0.y, c[1].x;
ADD R0.x, R0, c[0];
TEX result.color.y, R0.zwzw, texture[1], 2D;
TEX result.color.x, R0, texture[1], 2D;
END
"
}

SubProgram {
Keywords { }
Local 0, [_RampOffset]
SetTexture [_MainTex] {RECT}
SetTexture [_RampTex] {2D}
"ps_2_0
dcl_2d s0
dcl_2d s1
def c1, 0.000000, 0, 0, 0
dcl t0.xy
texld r3, t0, s0
add r0.x, r3.y, c0.y
mov r0.y, c1.x
add r2.x, r3.z, c0.z
add r1.x, r3, c0
mov r2.y, c1.x
mov r1.y, c1.x
texld r0, r0, s1
texld r1, r1, s1
texld r2, r2, s1
mov r0.x, r1
mov r0.y, r0
mov r0.z, r2
mov r0.w, r3
mov oC0, r0
"
}

}


	}
}*/

Fallback off

}