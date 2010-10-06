using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
[AddComponentMenu("Image Effects/Color Correction")]
public class ColorCorrectionEffect : ImageEffectBase {
	public Texture  textureRamp;
	public float    rampOffsetR;
	public float    rampOffsetG;
	public float    rampOffsetB;

	// Called by camera to apply image effect
	void OnRenderImage (RenderTexture source, RenderTexture destination) {
		material.SetTexture("_RampTex", textureRamp);
		material.SetVector("_RampOffset", new Vector4 (rampOffsetR, rampOffsetG, rampOffsetB, 0));
		ImageEffects.BlitWithMaterial( material, source, destination );
	}
}