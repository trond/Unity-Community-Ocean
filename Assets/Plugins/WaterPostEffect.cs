using UnityEngine;
using System.Collections;

public class WaterPostEffect : MonoBehaviour 
{
	public Material waterCompositionMaterial = null;

	void Start()
	{
		StartCoroutine(Hack());
	}
	
	//HACK FIXME BUGREPORT?
	IEnumerator Hack()
	{
		enabled = false;
		
		yield return 0;
		
		enabled = true;
	}
	
	void OnRenderImage (RenderTexture source, RenderTexture destination) 
	{	
	
		float nearClip = camera.nearClipPlane;
		float angle = Mathf.Deg2Rad*(camera.fieldOfView/2.0f);
				
		float h = nearClip/Mathf.Cos(angle);
		float k = Mathf.Sin(angle) * h;
		
				
		Vector3 center = transform.position + transform.forward * nearClip * 1.01f;
		Vector3 right = transform.right * camera.aspect * k  * 1.01f;
		Vector3 up = transform.up * k  * 1.01f;
		
		if (waterCompositionMaterial != null)
		{
			
			//TODO: Fix this using Graphics.Blit instead.
			//Graphics.Blit(source, destination, waterCompositionMaterial);
			
			
			RenderTexture.active = destination;		
			waterCompositionMaterial.SetTexture("_MainTex", source);
		
			
			GL.PushMatrix ();
			//GL.LoadOrtho ();//Bah. This is screwing up my mind when it comes to unprojecting
			GL.Clear(true, false, Color.black);
		
			for (int i = 0; i < waterCompositionMaterial.passCount; i++)
			{
				waterCompositionMaterial.SetPass (i);
				
				GL.Begin (GL.QUADS);		
				GL.TexCoord2( 0.0f, 0.0f ); GL.Vertex(center - up - right);
				GL.TexCoord2( 1.0f, 0.0f ); GL.Vertex(center - up + right);
				GL.TexCoord2( 1.0f, 1.0f ); GL.Vertex(center + up + right);
				GL.TexCoord2( 0.0f, 1.0f ); GL.Vertex(center + up - right);
				GL.End();

			}
			GL.PopMatrix ();
		}
		else
		{
			Graphics.Blit(source, destination);
		}
	}
}
