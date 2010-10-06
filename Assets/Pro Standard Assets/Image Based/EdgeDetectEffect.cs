// Implements Edge Detection using a Roberts cross filter.

using UnityEngine;

[ExecuteInEditMode]
[AddComponentMenu("Image Effects/Edge Detection")]
public class EdgeDetectEffect : ImageEffectBase
{
	public float threshold = 0.2F;
	
	// Called by camera to apply image effect
	void OnRenderImage (RenderTexture source, RenderTexture destination)
	{
		material.SetFloat("_Treshold", threshold * threshold);
		ImageEffects.BlitWithMaterial (material, source, destination);
	}
}
