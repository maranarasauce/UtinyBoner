// Copyright (c) Valve Corporation, All rights reserved. ======================================================================================================

using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;

[ExecuteInEditMode]
[RequireComponent( typeof( Light ) )]
public class ValveRealtimeLight : MonoBehaviour
{
	[NonSerialized] [HideInInspector] public static List< ValveRealtimeLight > s_allLights = new List< ValveRealtimeLight >();
	[NonSerialized] [HideInInspector] public Light m_cachedLight    ;
	[NonSerialized] [HideInInspector] public Matrix4x4[] m_shadowTransform = { Matrix4x4.identity, Matrix4x4.identity, Matrix4x4.identity, Matrix4x4.identity, Matrix4x4.identity, Matrix4x4.identity };
	[NonSerialized] [HideInInspector] public Matrix4x4[] m_lightCookieTransform = { Matrix4x4.identity, Matrix4x4.identity, Matrix4x4.identity, Matrix4x4.identity, Matrix4x4.identity, Matrix4x4.identity };
    [NonSerialized] [HideInInspector] public Matrix4x4[] m_lightPointTransform = { Matrix4x4.identity, Matrix4x4.identity, Matrix4x4.identity, Matrix4x4.identity, Matrix4x4.identity, Matrix4x4.identity };
	[NonSerialized] [HideInInspector] public int[] m_shadowX = { 0, 0, 0, 0, 0, 0 };
	[NonSerialized] [HideInInspector] public int[] m_shadowY = { 0, 0, 0, 0, 0, 0 };
	[NonSerialized] [HideInInspector] public bool m_bRenderShadowsThisFrame = false;
	[NonSerialized] [HideInInspector] public bool m_bInCameraFrustum = false;

    [HideInInspector] public int cookieNumber;
    [HideInInspector] public Vector2 DirectionalCookieOffset;

	//[Header( "Spotlight Settings" )]
	[Range( 0.0f, 100.0f )] public float m_innerSpotPercent = 50.0f;

    [Tooltip("Lambert wrap amount. Value of 1 is normal light behavior. Self shadowing objects may have artifacting if used in combination.")]
    [Range(0, 1)]
    public float Hardness = 1;

	//[Header( "Shadow Settings" )]
	[Range( 16.0f, 1024.0f * 8.0f )] public int m_shadowResolution = 1024;
       
	public float m_shadowNearClipPlane = 1.0f;
	public LayerMask m_shadowCastLayerMask = ~0;


	// !!! I need to hide these values for non-directional lights
    [HideInInspector] 
	public float m_directionalLightShadowRadius = 100.0f;
    [HideInInspector] 
	public float m_directionalLightShadowRange = 100.0f;


	public bool m_useOcclusionCullingForShadows = true;




    [Tooltip ("Don't turn off light when out of view. Leave off unless needed.")]
    public bool IgnoreCameraFrustum = false;
      
    public bool cookieEnabled;

	void OnValidate()
	{
        //if (!Mathf.IsPowerOfTwo(m_shadowResolution))
        //{
        //    m_shadowResolution = Mathf.ClosestPowerOfTwo(m_shadowResolution);
        //}

        if ((m_shadowResolution % 16) != 0)
        {
            m_shadowResolution -= m_shadowResolution % 16;
        }

		if ( m_shadowNearClipPlane < 0.01f )
		{
			m_shadowNearClipPlane = 0.01f;
		}
	}

	void OnEnable()
	{
		if ( !s_allLights.Contains( this ) )
		{
			s_allLights.Add( this );
			m_cachedLight = GetComponent< Light >();
		}
	}

	void OnDisable()
	{
		s_allLights.Remove( this );
	}

	public bool IsEnabled()
	{
		Light l = m_cachedLight;

		if ( !l.enabled || !l.isActiveAndEnabled )
		{
			//Debug.Log( "Skipping disabled light " + l.name );
			return false;
		}

		if ( l.intensity <= 0.0f )
		{
			//Debug.Log( "Skipping light with zero intensity " + l.name );
			return false;
		}

		if ( l.range <= 0.0f )
		{
			//Debug.Log( "Skipping light with zero range " + l.name );
			return false;
		}

		if ( ( l.color.linear.r <= 0.0f ) && ( l.color.linear.g <= 0.0f ) && ( l.color.linear.b <= 0.0f ) )
		{
			//Debug.Log( "Skipping black light " + l.name );
			return false;
		}

        //if ( l.bakingOutput.isBaked  )
		//{
			// AV - Disabling this early-out because we may want lights to bake indirect and have realtime direct
			//Debug.Log( "Skipping lightmapped light " + l.name );
			//return false;
		//}

        if (!m_bInCameraFrustum && !IgnoreCameraFrustum)
		{
			//Debug.Log( "Skipping light culled by camera frustum " + l.name );
			return false;
		}

		return true;
	}

	public bool CastsShadows()
	{
		Light l = m_cachedLight;

		if ( ( ( l.type == LightType.Spot ) || ( l.type == LightType.Point ) || ( l.type == LightType.Directional ) ) && ( l.shadows != LightShadows.None ) )
		{
			return true;
		}

		return false;
	}


    void OnDrawGizmosSelected()
    {
        if (m_cachedLight != null)
        {
            if (m_cachedLight.type == LightType.Directional)
            {
                Gizmos.color = new Color(1f, 1f, 0.597f);
                Gizmos.matrix = Matrix4x4.TRS(transform.position, transform.rotation, new Vector3(1.0f, 1.0f, m_directionalLightShadowRange / m_directionalLightShadowRadius));
                Gizmos.DrawFrustum(Vector3.zero, m_directionalLightShadowRadius * 4, m_directionalLightShadowRadius, m_directionalLightShadowRadius, 1.0f);
            }
        }
    }
}
