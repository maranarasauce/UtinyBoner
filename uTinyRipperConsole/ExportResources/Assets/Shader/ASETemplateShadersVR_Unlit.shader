Shader /*ase_name*/ "ASETemplateShaders/VR_Unlit" /*end*/
{
	Properties
	{
		/*ase_props*/
	}
	
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100
		/*ase_all_modules*/
		/*ase_pass*/

		Pass
		{
			Name "Unlit"
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile _ Z_SHAPEAO
			#pragma multi_compile_instancing

			#include "UnityCG.cginc"

			#include "UnityLightingCommon.cginc"
			#include "UnityStandardUtils.cginc"
			#include "UnityStandardCore.cginc"
		//	#include "vr_StandardInput.cginc"
			#include "vr_utils.cginc"
			#include "vr_lighting.cginc"
			#include "vr_matrix_palette_skinning.cginc"
			#include "vr_fog.cginc"
			

			#include "vr_zAO.cginc"



			/*ase_pragma*/

			struct appdata //VS INPUT
			{
				float4 vPositionOs : POSITION;
				float4 vTangentUOs_flTangentVSign : TANGENT;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 texcoord3 : TEXCOORD3;
				
				fixed4 color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			/*ase_vdata:p=p;t=t;n=n;uv0=tc0.xyzw;uv1=tc1.xyzw;uv2=tc2.xyzw;uv3=tc3.xyzw;c=c*/
			};
			
			struct v2f //PS INPUT
			{
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				float4 vPositionPs : SV_POSITION;
				float3 vPositionWs : TEXCOORD0;
				float3 vNormalWs : TEXCOORD1;
				float3 vTangentUWs : TEXCOORD4;
				float3 vTangentVWs : TEXCOORD5;
			#if ( D_VALVE_FOG )
				float2 vFogCoords : TEXCOORD6;
			#endif

				/*ase_interp(0,):sp=sp.xyzw;uv0=tc0.xyz;uv1=tc1.xyz;uv4=tc4.xyz;uv5=tc5.xyz*/
			};

			/*ase_globals*/

			//Vertex Shader
			v2f vert ( appdata v /*ase_vert_input*/)
			{
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f,o);
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v,o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				/*ase_vert_code:v=appdata;o=v2f*/

				float3 vPositionWs = mul( unity_ObjectToWorld, v.vPositionOs.xyzw ).xyz;

				float3 vNormalWs = UnityObjectToWorldNormal( v.normal.xyz );
				o.vNormalWs.xyz = vNormalWs.xyz;

				float3 vTangentUWs = UnityObjectToWorldDir( v.vTangentUOs_flTangentVSign.xyz ); // Transform tangentU into world space
				//vTangentUWs.xyz = normalize( vTangentUWs.xyz - ( vNormalWs.xyz * dot( vTangentUWs.xyz, vNormalWs.xyz ) ) ); // Force tangentU perpendicular to normal and normalize

				o.vTangentUWs.xyz = vTangentUWs.xyz;
				o.vTangentVWs.xyz = cross( vNormalWs.xyz, vTangentUWs.xyz ) * v.vTangentUOs_flTangentVSign.w;





				vPositionWs.xyz += /*ase_vert_out:Local Vertex;Float3*/ float3(0,0,0) /*end*/;

				//v.vPositionPs = UnityObjectToClipPos(v.vPositionWs);
				o.vPositionPs.xyzw = UnityObjectToClipPos( v.vPositionOs.xyzw );
				o.vPositionWs = vPositionWs;


				return o;
			}


			/////////////////


			//Pixel Shader
			fixed4 frag (v2f i /*ase_frag_input*/) : SV_Target
			{
				fixed4 finalColor;
				/*ase_frag_code:i=v2f*/
				UNITY_SETUP_INSTANCE_ID(i);

				float3 vTangentUWs = float3( 1.0, 0.0, 0.0 );
				float3 vTangentVWs = float3( 0.0, 1.0, 0.0 );

				vTangentUWs.xyz = i.vTangentUWs.xyz;
				vTangentVWs.xyz = i.vTangentVWs.xyz;
				
				float3 vGeometricNormalWs = float3( 0.0, 0.0, 1.0 );		
						
				i.vNormalWs.xyz = normalize( i.vNormalWs.xyz );
				vGeometricNormalWs.xyz = i.vNormalWs.xyz;

				float3 vNormalWs = vGeometricNormalWs.xyz;

				float3 vNormalTs = float3( 0.0, 0.0, 1.0 );
				//vNormalTs.xyz = UnpackScaleNormal( tex2D( g_tNormalMap, zTextureCoords.xy ), g_flBumpScale );
			//	vNormalWs.xyz = Vec3TsToWsNormalized( vNormalTs.xyz, vGeometricNormalWs.xyz, vTangentUWs.xyz, vTangentVWs.xyz  );


			


				LightingTerms_t lightingTerms;
				lightingTerms.vDiffuse.rgba = float4( 1.0, 1.0, 1.0 ,1.0);
				lightingTerms.vSpecular.rgb = float3( 0.0, 0.0, 0.0 );
				lightingTerms.vIndirectDiffuse.rgb = float3( 0.0, 0.0, 0.0 );
				lightingTerms.vIndirectSpecular.rgb = float3( 0.0, 0.0, 0.0 );
				lightingTerms.vTransmissiveSunlight.rgb = float3( 0.0, 0.0, 0.0 );

				
				float3 Albedo = /*ase_frag_out:Albedo;Float3;-1;-1;_Albedo*/fixed3(0,0,0)/*end*/;
				float3 Normal = /*ase_frag_out:World Normal;Float3;-1;-1;_Normal*/fixed3(0,0,1)/*end*/;
				float3 Emission = /*ase_frag_out:Emission;Float3;-1;-1;_Emission*/fixed3(0,0,0)/*end*/;
				float3 Specular = /*ase_frag_out:Specular;Float3;-1;-1;_Specular*/fixed3(0,0,0)/*end*/;
				float Smoothness = /*ase_frag_out:Smoothness;Float;-1;-1;_Smoothness*/0/*end*/;
				float Occlusion = /*ase_frag_out:Occlusion;Float;-1;-1;_Occlusion*/1/*end*/;
				float Alpha = /*ase_frag_out:Alpha;Float;-1;-1;_Alpha*/1/*end*/;		

				lightingTerms = ComputeLighting( i.vPositionWs, vNormalWs, vTangentUWs.xyz, vTangentVWs, float3(0.0,0.0,0.0), float3(0.0,0.0,0.0), 0.0, float4(0.0,0.0,0.0,0.0), 1.0 );
		//		lightingTerms = ComputeLighting( i.vPositionWs.xyz, vNormalWs.xyz, vTangentUWs.xyz, vTangentVWs.xyz, vRoughness.xyz, vReflectance.rgb, g_flFresnelExponent, vLightmapUV.xyzw, Dotfresnel );

				finalColor.rgb = lightingTerms.vDiffuse.rgb * Albedo * Occlusion;

			#ifdef Z_SHAPEAO 					
				float vAO = CalculateShapeAO( i.vPositionWs.xyz, vNormalWs);
				finalColor.rgb *= vAO;			
			#endif

				finalColor.rgb += Emission;
			
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
}
