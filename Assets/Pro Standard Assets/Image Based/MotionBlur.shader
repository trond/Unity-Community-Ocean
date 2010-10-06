Shader "Hidden/MotionBlur" {
Properties {
	_MainTex ("Base (RGB)", RECT) = "white" {}
	_AccumOrig("AccumOrig", Float) = 0.65
}

SubShader {
	ZTest Always Cull Off ZWrite Off
	Fog { Mode off }
	Pass {
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask RGB
		SetTexture [_MainTex] {
			ConstantColor (0,0,0,[_AccumOrig])
			Combine texture, constant
		}
	}
	Pass {
		Blend One Zero
		ColorMask A
		SetTexture [_MainTex] {
			Combine texture
		}
	}
}

Fallback off

}