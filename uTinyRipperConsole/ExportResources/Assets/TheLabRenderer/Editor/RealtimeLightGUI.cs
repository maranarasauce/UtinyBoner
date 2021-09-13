using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(ValveRealtimeLight))]
[CanEditMultipleObjects]

public class RealtimeLightGUI : Editor {

    Vector2 scrollPos;
    LightCookieController LCC;
    ValveRealtimeLight VRTL;  

    public override void OnInspectorGUI()
    {

        base.OnInspectorGUI();

         VRTL = (ValveRealtimeLight)target;
        if (VRTL == null) return;            

         if (VRTL.m_cachedLight.type == LightType.Directional)
         {
             DirectionalSpace();
         }

         if (VRTL.cookieEnabled == true)
        {
            LCC = FindObjectOfType<LightCookieController>();

            //////////////
            if (LCC != null)
            {

                if (LCC.CookieList != null)
                {
                    //default to first cookie if selection is out of list
                    if (VRTL.cookieNumber + 1 > LCC.CookieList.Length) VRTL.cookieNumber = 0;
                    DoCookieSpace();
                }
                else
                {
                    Debug.LogError("No Textures in Cookie Controller");
                    VRTL.cookieEnabled = false;
                }

            }
            else
            {
                Debug.LogError("No Light Controller in Scene");
                VRTL.cookieEnabled = false;
            }
            ///////////////
        }



        GUILayout.BeginHorizontal();

        //if (GUILayout.Button("Add Light Cookie to Array"))
        //{        
        //   LCC.CookieList. VRTL.m_cachedLight
        //}

        //if (GUILayout.Button("Apply Array"))
        //{

        //    LCC.ApplyArray();

        //}

        GUILayout.EndHorizontal();


    }

    void DirectionalSpace()
    {
        GUILayout.Label("Directional Shadow Options", EditorStyles.boldLabel);

      //  GUILayout.BeginHorizontal();

        Undo.RecordObject(target, "VLGUI");

        VRTL.m_directionalLightShadowRadius = EditorGUILayout.FloatField("Radius", VRTL.m_directionalLightShadowRadius);
        VRTL.m_directionalLightShadowRange = EditorGUILayout.FloatField("Range", VRTL.m_directionalLightShadowRange);

         if (VRTL.cookieEnabled == true){

            VRTL.m_cachedLight.cookieSize = EditorGUILayout.FloatField("Cookie Size", VRTL.m_cachedLight.cookieSize);
            VRTL.DirectionalCookieOffset = EditorGUILayout.Vector2Field( "Cookie Offset" , VRTL.DirectionalCookieOffset);
         }

         foreach (Object vl in targets)
         {
             ((ValveRealtimeLight)vl).m_directionalLightShadowRadius = VRTL.m_directionalLightShadowRadius;
             ((ValveRealtimeLight)vl).m_cachedLight.cookieSize = VRTL.m_cachedLight.cookieSize;
             ((ValveRealtimeLight)vl).m_directionalLightShadowRadius = VRTL.m_directionalLightShadowRadius;
             ((ValveRealtimeLight)vl).DirectionalCookieOffset = VRTL.DirectionalCookieOffset;             
         }



      //  GUILayout.EndHorizontal();

    }





    void DoCookieSpace()
    {

        GUILayout.Label("Cookie Selection", EditorStyles.boldLabel);


        GUILayout.BeginHorizontal();
        GUILayout.Box(LCC.CookieList[VRTL.cookieNumber], GUILayout.Width(125), GUILayout.Height(125));
        scrollPos = EditorGUILayout.BeginScrollView(scrollPos, true, false, GUILayout.ExpandWidth(true), GUILayout.Height(125));

        GUILayout.BeginVertical();

        GUILayout.BeginHorizontal();
        for (int i = 0; i < LCC.CookieList.Length; i++)
        {
            if (i % 2 == 0)
            {
                if (GUILayout.Button(LCC.CookieList[i], GUILayout.Width(50), GUILayout.Height(50)))
                {
                    foreach (Object vl in targets) 
                    {
                        ((ValveRealtimeLight)vl).cookieNumber = i;
                    };
                    SceneView.RepaintAll();
                }
            }
        }
        GUILayout.EndHorizontal();


        GUILayout.BeginHorizontal();
        for (int i = 0; i < LCC.CookieList.Length; i++)
        {
            if (i % 2 != 0)
            {
                if (GUILayout.Button(LCC.CookieList[i], GUILayout.Width(50), GUILayout.Height(50)))
                {
                    foreach (Object vl in targets) 
                    {
                        ((ValveRealtimeLight)vl).cookieNumber = i;
                    };
                    SceneView.RepaintAll();
                }
            }
        }
        GUILayout.EndHorizontal();

        GUILayout.EndVertical();

        EditorGUILayout.EndScrollView();

        GUILayout.EndHorizontal();


        if (GUILayout.Button("Select Cookie Controller"))
        {
            Selection.activeObject = LCC.gameObject;
        }

    }




}
