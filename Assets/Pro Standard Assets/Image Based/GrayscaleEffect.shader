// Upgrade NOTE: replaced 'samplerRECT' with 'sampler2D'
// Upgrade NOTE: replaced 'texRECT' with 'tex2D'

Shader "Hidden/Grayscale Effect" {
Properties {
	_MainTex ("Base (RGB)", RECT) = "white" {}
	_RampTex ("Base (RGB)", 2D) = "grayscaleRamp" {}
}

SubShader {
	Pass {
		ZTest Always Cull Off ZWrite Off
		Fog { Mode off }
				
CGPROGRAM
#pragma vertex vert_img
#pragma fragment frag
#pragma fragmentoption ARB_precision_hint_fastest 
#include "UnityCG.cginc"

uniform sampler2D _MainTex;
uniform sampler2D _RampTex;
uniform float _RampOffset;

float4 frag (v2f_img i) : COLOR
{
	float4 original = tex2D(_MainTex, i.uv);
	float grayscale = Luminance(original.rgb);
	float2 remap = float2 (grayscale + _RampOffset, .5);
	float4 output = tex2D(_RampTex, remap);
	output.a = original.a;
	return output;
}
ENDCG

	}
}

Fallback off

}