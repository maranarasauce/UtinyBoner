// Copyright (c) Valve Corporation, All rights reserved. ======================================================================================================

using UnityEngine;
using System.Collections;
using System.Collections.Generic;

[ExecuteInEditMode]
public class ValveFog : MonoBehaviour
{
	[Header( "Gradient Fog" )]

	public Gradient gradient = new Gradient();
	public float startDistance = 0.0f;
	public float endDistance = 100.0f;
   
	int textureWidth = 32;

	[Header( "Height Fog")]

	public Color heightFogColor = Color.grey;
	public float heightFogThickness = 1.15f;
	public float heightFogFalloff = 0.1f;
	public float heightFogBaseHeight = -40.0f;

    // Textures

    private void OnValidate()
    {
        if (FindObjectsOfType<ValveFog>().Length > 1)
        {
            Debug.LogError("Found another instance of Fog in scene");
            return;
        }
    }

    //private Texture2D gradientFogTexture;

    void Start()
	{
		UpdateConstants();
    }

	void OnEnable()
	{
		Shader.EnableKeyword( "D_VALVE_FOG" );
	}

	void OnDisable()
	{
		Shader.DisableKeyword( "D_VALVE_FOG" );
	}

#if UNITY_EDITOR
	void Update()
	{
		if ( !Application.isPlaying )
		{
			UpdateConstants();
		}
	}
#endif


    public void UpdateConstants(Color HColor, Gradient Grad, float endDist, float startDist)
    {
       // if (gradientFogTexture == null)
        {
            GenerateArray(Grad);
        }

        float scale = 1.0f / (endDist - startDist);
        float add = -startDist / (endDist - startDist);
        Shader.SetGlobalVector("gradientFogScaleAdd", new Vector4(scale, add, 0.0f, 0.0f));
        Shader.SetGlobalColor("gradientFogLimitColor", Grad.Evaluate(1.0f).linear);
        Shader.SetGlobalVector("heightFogParams", new Vector4(heightFogThickness, heightFogFalloff, heightFogBaseHeight, 0.0f));
        Shader.SetGlobalColor("heightFogColor", HColor.linear);
        
    }



        private void UpdateConstants()
	{
		//if ( gradientFogTexture == null )
		{
			GenerateArray();
		}

		float scale = 1.0f / ( endDistance - startDistance );
		float add = -startDistance / ( endDistance - startDistance );
		Shader.SetGlobalVector( "gradientFogScaleAdd", new Vector4( scale, add, 0.0f, 0.0f ) );
		Shader.SetGlobalColor( "gradientFogLimitColor", gradient.Evaluate( 1.0f ).linear );
		Shader.SetGlobalVector( "heightFogParams", new Vector4( heightFogThickness, heightFogFalloff, heightFogBaseHeight, 0.0f ) );
		Shader.SetGlobalColor( "heightFogColor", heightFogColor.linear );
	}


    //Switching from texture to 1D vector4 array
    public void GenerateArray(Gradient grad)
    {
        // gradientFogTexture = new Texture2D(textureWidth, 1, TextureFormat.ARGB32, false);
        // gradientFogTexture.wrapMode = TextureWrapMode.Clamp;

        List<Vector4> gradientFogArray = new List<Vector4>();

        float ds = 1.0f / (textureWidth - 1);
        float s = 0.0f;
        for (int i = 0; i < textureWidth; i++)
        {
            // gradientFogTexture.SetPixel(i, 0, grad.Evaluate(s));
            gradientFogArray.Add(grad.Evaluate(s).linear);
            s += ds;
        }
       //gradientFogTexture.Apply();
       //Shader.SetGlobalTexture("gradientFogTexture", gradientFogTexture);
        Shader.SetGlobalVectorArray("gradientFogArray", gradientFogArray);

    }


    public void GenerateArray()
	{
        GenerateArray(gradient);
    }

    public void FadeFogToDefault(float TimeToFade)
    {
        StopAllCoroutines();
        StartCoroutine(FadeFogArrayCo(gradient, TimeToFade));

    }


    public void FadeFogArray(Gradient TargetGradient, float TimeToFade)
    {
        StopAllCoroutines();
        StartCoroutine(FadeFogArrayCo(TargetGradient, TimeToFade));

    }


     IEnumerator FadeFogArrayCo(Gradient TargetGradient, float TimeToFade)
    {
        //float start = fadeType == Fade.In ? 0f : 1f;
        Vector4[] startColors = Shader.GetGlobalVectorArray("gradientFogArray"); 
       // Gradient end = fadeType == Fade.In ? 1f : 0f;

        float Timer = 0.0f;
        float step = 1.0f / TimeToFade;

        while (Timer <= 1.0f)
        {
            Timer += (Time.deltaTime * step) / Time.timeScale;

            List<Vector4> gradientFogArray = new List<Vector4>();

            float ds = 1.0f / (textureWidth - 1);
            float s = 0.0f;
            for (int i = 0; i < textureWidth; i++)
            {
                Vector4 ColorLerp = Vector4.Lerp(startColors[i], TargetGradient.Evaluate(s).linear, Timer);
              
                gradientFogArray.Add(ColorLerp);
                s += ds;
            }

            Shader.SetGlobalVectorArray("gradientFogArray", gradientFogArray);

            yield return null;
        }
        yield break;
    }



    //public void FadeIn()
    //{
    //    StopAllCoroutines();
    //    StartCoroutine(Fader(Fade.In));
    //}

    //public void FadeOut()
    //{
    //    StopAllCoroutines();
    //    StartCoroutine(Fader(Fade.Out));
    //}

    //enum Fade { In, Out };

    //private IEnumerator Fader(Fade fadeType)
    //{
    //    //float start = fadeType == Fade.In ? 0f : 1f;
    //    Gradient start = currentAlpha;
    //    Gradient end = fadeType == Fade.In ? 1f : 0f;

    //    float Timer = 0.0f;
    //    float step = 1.0f / TimeToFullyFade;

    //    while (Timer <= 1.0f)
    //    {
    //        Timer += (Time.deltaTime * step) / Time.timeScale;
    //        currentAlpha = Mathf.Lerp(start, end, Timer);

    //        for (int i = 0; i < MaterialsToFade.Length; i++)
    //        {
    //            MaterialsToFade[i].material.SetFloat(TargetVariable, currentAlpha);
    //        }
    //        yield return null;
    //    }
    //    yield return null;
    //}
}

#if UNITY_EDITOR
[UnityEditor.CustomEditor( typeof( ValveFog ) )]
public class ValveGradientFogEditor : UnityEditor.Editor
{
	// Custom Inspector GUI allows us to click from within the UI
	public override void OnInspectorGUI()
	{
		DrawDefaultInspector();

		ValveFog gradientFog = ( ValveFog )target;

		gradientFog.GenerateArray();
	}
}
#endif
