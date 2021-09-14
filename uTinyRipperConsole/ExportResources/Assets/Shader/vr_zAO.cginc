//AO terms

#ifndef VR_AO_INCLUDED
#define VR_AO_INCLUDED

CBUFFER_START( ZVrAO )

	int		g_nNumAOSpheres;
	float4x4	g_zAOSphere[ 128 ]; // xyz = position , w = raius

	int		g_nNumAOPoints;
	float4x4	g_zAOPoint[ 128 ]; // xyz = position , w = raius

CBUFFER_END





	float CalculateSphericalAO(float3 posWs, float3 vNormalWs)
	{

	float OcclusionOuts = 1;

		 for ( int i = 0; i < g_nNumAOSpheres; i++ )
		{	
		float3	LocalPosW = posWs - g_zAOSphere[i][3].xyz;

		// if (distance(posWs, g_zAOSphere[i].xyz) >= g_zAOSphere[i].w * 5)
		// {
		// continue;
		// }

		//else{

		float	ignoreBackfacing = saturate( 1 - dot( normalize(LocalPosW) , vNormalWs) ) ;
	//	float3	NormalizeRadius = LocalPosW / g_zAOSphere[i][3].w ;
	//	float	SphericalOcclusion = 1 / sqrt( pow (dot(NormalizeRadius,NormalizeRadius), 3) );

		float	SphericalOcclusion = 1 / sqrt( pow (distance (mul(LocalPosW, g_zAOSphere[i]), float3(0,0,0)) , 8) );
		float	OcclusionOutput = 1 - saturate(( SphericalOcclusion * ignoreBackfacing) );
		OcclusionOuts *=  OcclusionOutput ;
		
	//	}
		} 
	 return saturate(OcclusionOuts);
	}



	float CalculatePointAO(float3 posWs, float3 vNormalWs)
	{

	float OcclusionOuts = 1;

		 for ( int i = 0; i < g_nNumAOPoints; i++ )
		{	
		//float PointDistance = distance(posWs, g_zAOPoint[i][3].xyz);

		// if (PointDistance >= g_zAOPoint[i].w)
		// {
		// continue;
		// }

		float3	LocalPosW = posWs - g_zAOPoint[i][3].xyz;
		float	ignoreBackfacing = 1 - ((dot( normalize(LocalPosW) , vNormalWs) * 0.5) + 0.5 ) ;
		//float	PointOcclusion = saturate(1 - distance(posWs, g_zAOPoint[i].xyz) / g_zAOPoint[i].w);
		float	PointOcclusion =  saturate(1 - distance( mul(LocalPosW, g_zAOPoint[i]), float3(0,0,0) ) );

		float	OcclusionOutput = saturate(1- PointOcclusion * ignoreBackfacing);
		OcclusionOuts *= OcclusionOutput;
		
		}
	return saturate(OcclusionOuts);
	}

	float CalculateShapeAO(float3 posWs, float3 vNormalWs)
	{

		float AO = 1 * CalculateSphericalAO( posWs,  vNormalWs);
		AO *= CalculatePointAO( posWs,  vNormalWs);

		return AO;

	}



	#endif