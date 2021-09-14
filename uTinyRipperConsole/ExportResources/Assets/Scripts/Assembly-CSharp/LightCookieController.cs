using System.Collections;
using System.Collections.Generic;
using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif

public class LightCookieController : MonoBehaviour {


    

    public Texture2D[] CookieList;
    [Header("All textures will be resized to this resolution")]
    [Range(16,8192)]   
    public int MasterCookieResolution = 1024;

    [SerializeField]
    static public Texture2DArray CookieArray;


    public void OnValidate()
    {
        if (FindObjectsOfType<LightCookieController>().Length > 1)
        {
            Debug.LogError("Found another instance of Cookie Controller in scene");
            return;
        }


        if (CookieList != null)
        {
            MakeArray();
        }

    }


    public void Start()
    {

        if (FindObjectsOfType<LightCookieController>().Length > 1)
        {
            Debug.LogError("Found another instance of Cookie Controller in scene");
            return;
        }

        MakeArray();
    }



    public void MakeArray()
    {
       // Debug.Log("make it");        

        foreach (Texture tex in CookieList)
        {
            if (tex == null)
            {
                Debug.LogError("Cookie list can not have empty texture slots");
                return;
            }
        }

        if (CookieList.Length <= 0)
        {
            Debug.LogError("Cookie texture list is empty");
            return;
        }
        //Make Cookie Texture Array :: Is linear for color blending, input textures should keep sRGB color enabled
        
        CookieArray = new Texture2DArray(MasterCookieResolution, MasterCookieResolution, CookieList.Length, TextureFormat.ARGB32, true, true);
        Texture2D tempTex = new Texture2D(MasterCookieResolution, MasterCookieResolution, TextureFormat.ARGB32, false, true);
        RenderTexture TempRT = new RenderTexture(MasterCookieResolution, MasterCookieResolution, 32, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear);
                

        TempRT.Create();


        //Casting Array to RT to normalize texture sizes and avoid setting restrictions

       
        for (int i = 0; i < CookieList.Length; i++)
        {
            Graphics.Blit(CookieList[i], TempRT);
            
            //Move RT to tex2D to get pixels
            RenderTexture.active = TempRT;
            tempTex.ReadPixels(new Rect(0, 0, TempRT.width, TempRT.height), 0, 0);
            
            tempTex.Apply();

            //Set Pixels to array
             CookieArray.SetPixels32(tempTex.GetPixels32(0), i, 0);
                
        }

        CookieArray.Apply(true);

        //clear from memory

        RenderTexture.active = null;
        TempRT.Release();
        TempRT.DiscardContents();
        DestroyImmediate(TempRT);
        DestroyImmediate(tempTex);
        
        ApplyArray();

    }



    public void ApplyArray()
    {
        Shader.SetGlobalTexture("g_tVrLightCookieTexture", CookieArray);

       // AssetDatabase.CreateAsset(CookieArray, "Assets/hellothere.asset");
    }

}


#if UNITY_EDITOR

[CustomEditor(typeof(LightCookieController))]
public class LightCookieControllerGUI : Editor
{

    LightCookieController LCC;


    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        LCC = (LightCookieController)target;

        if (GUILayout.Button("Manually Update Array"))
        {
            LCC.MakeArray();

        }


    }
}


#endif
