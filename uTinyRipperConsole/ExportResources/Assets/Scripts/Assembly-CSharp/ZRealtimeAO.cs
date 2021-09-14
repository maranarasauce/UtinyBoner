using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ZRealtimeAO : MonoBehaviour
{

    [NonSerialized] [HideInInspector]  public static List<ZRealtimeAO> s_allAOSpheres = new List<ZRealtimeAO>();
    [NonSerialized] [HideInInspector]  public static List<ZRealtimeAO> s_allAOPoints = new List<ZRealtimeAO>();
   // [HideInInspector]  public  float SphereRadius;
    [HideInInspector]  public Vector3 SphereScale;
    public enum AOShape { Point, Sphere };

    public AOShape TypeOfShape = AOShape.Point;

   [SerializeField] private bool AccountForScale = true;
   [SerializeField] private float TargetRadius = 0.5f;



#if UNITY_EDITOR
    public void OnDrawGizmos()
    {

        if (UnityEditor.Selection.Contains(gameObject))
        {


            UpdateVars();


            if (TypeOfShape == AOShape.Point)
            {

                Gizmos.color = Color.grey;
                Gizmos.DrawWireSphere(transform.position, SphereScale.z);

         
            }

            if (TypeOfShape == AOShape.Sphere)
            {
                Gizmos.color = Color.black;
               // Gizmos.DrawWireSphere(transform.position, SphereRadius);
                Gizmos.DrawLine(transform.position + transform.up * transform.lossyScale.y * 0.5f , transform.position  - transform.up * transform.lossyScale.y * 0.5f );
                Gizmos.DrawLine(transform.position + transform.forward * transform.lossyScale.z * 0.5f , transform.position - transform.forward * transform.lossyScale.z * 0.5f );
                Gizmos.DrawLine(transform.position + transform.right * transform.lossyScale.x * 0.5f , transform.position - transform.right * transform.lossyScale.x * 0.5f );           


            }

        }

    }
#endif

    //void OnValidate()
    //{
    //    UpdateVars();
    //}

#if UNITY_EDITOR
    void Update()
    {
        if (Application.isEditor && !Application.isPlaying)
        {
            UpdateVars();
        }
    }
#endif

    void OnEnable()
    {
        UpdateVars();
    }


    void UpdateVars()
    {

        if (AccountForScale == true)
        {
            SphereScale = new Vector3(1 / transform.lossyScale.x , 1 / transform.lossyScale.y , 1 / transform.lossyScale.z ) / TargetRadius;
        }
        else
        {
            SphereScale = new Vector3(1 / transform.lossyScale.x , 1 / transform.lossyScale.y, 1 / transform.lossyScale.z ) * transform.lossyScale.magnitude / TargetRadius;
        }


        if (!s_allAOSpheres.Contains(this) && TypeOfShape == AOShape.Sphere)
        {
            s_allAOSpheres.Add(this);
        }

        if (!s_allAOPoints.Contains(this) && TypeOfShape == AOShape.Point)
        {
            s_allAOPoints.Add(this);
        }


    }



    void OnDisable()
    {
        s_allAOSpheres.Remove(this);
        s_allAOPoints.Remove(this);
    }

}
