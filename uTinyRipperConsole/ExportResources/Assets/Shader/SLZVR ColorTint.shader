// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SDK/VRColorTint"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo", 2D) = "white" {}
		[NoScaleOffset]_ColorMask("Color Tint", 2D) = "white" {}
		_ColorShift1("_ColorShift1", Color) = (1,1,1,1)
		_ColorShift2("_ColorShift2", Color) = (1,1,1,1)
		_ColorShift3("_ColorShift3", Color) = (1,1,1,1)
		_ColorShift4("_ColorShift4", Color) = (1,1,1,1)
		[NoScaleOffset]_MetallicGlossMap("Metallic MAS", 2D) = "white" {}
		_BumpScale("Bump Scale", Float) = 1
		[NoScaleOffset][Normal]_BumpMap("Bump Map", 2D) = "bump" {}
		[Toggle]_Emission("Emission Enable", Float) = 1
		[NoScaleOffset]_EmissionMap("Emission Map", 2D) = "white" {}
		[HDR]_EmissionColor("Emission Color", Color) = (0,0,0,0)
		_EmissionFalloff("Emission Falloff", Range( 0 , 10)) = 0
		[Toggle]_EmissiveMode("Emissive Albedo Multiplcation", Float) = 0
		[Header(Detail Maps)]_DetailAlbedoMap("Detail Albedo Map", 2D) = "gray" {}
		[NoScaleOffset][Normal]_DetailNormalMap("Detail Normal Map", 2D) = "bump" {}
		_DetailNormalMapScale("Detail Normal Map Scale", Float) = 1
		[Toggle(_VERTEXTINT_ON)] _VERTEXTINT("Vertex Tint", Float) = 0
		[Toggle(_VERTEXOCCLUSION_ON)] _VertexOcclusion("Vertex Occlusion", Float) = 0
		[Toggle(_MASMAP_ON)] _MASMAP("MAS Map Enabled", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[Space(20)]
		[Header(General Properties)]




		[KeywordEnum( Specular_Metallic, Anisotropic_Gloss, Retroreflective )] S ("Specular mode", Float) = 0

		g_flFresnelFalloff ("Fresnel Falloff Scalar" , Range(0.0 , 10.0 ) ) = 1.0
		g_flFresnelExponent( "Fresnel Exponent", Range( 0.5, 10.0 ) ) = 5.0
		[Space(5)]
		[Toggle( _BRDFMAP )] EnableBRDFMAP( "Enable BRDF remap", Int ) = 0
		[NoScaleOffset]g_tBRDFMap("BRDF LUT", 2D) = "grey" {} 
		[Space(10)]
		[Header(Override Properties)]
		g_flCubeMapScalar( "Cube Map Scalar", Range( 0.0, 2.0 ) ) = 1.0
		[Toggle( S_RECEIVE_SHADOWS )] ReceiveShadows( "Receive Shadows", Int ) = 1
		[Toggle( _FLUORESCENCEMAP )] Fluorescence( "Enable Fluorescence", Int ) = 0

		
	}
	
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100
		
		



		Pass
		{
			Name "VRBase"
			Tags { "LightMode"="ForwardBase" "PassFlags"="OnlyDirectional" } // NOTE: "OnlyDirectional" prevents Unity from baking dynamic lights into SH terms at runtime


			CGINCLUDE
			#pragma target 3.0
			ENDCG
			Blend Off
			ColorMask RGBA
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			
			Cull Back

			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile _ Z_SHAPEAO
			#pragma multi_compile_instancing
			#pragma shader_feature LIGHTPROBE_SH
			#pragma multi_compile _ D_VALVE_FOG
			#pragma skip_variants SHADOWS_SOFT
			#pragma shader_feature	_BRDFMAP
			#pragma shader_feature	S_RECEIVE_SHADOWS
			#pragma shader_feature  _FLUORESCENCEMAP

			#pragma multi_compile	S_SPECULAR_METALLIC S_ANISOTROPIC_GLOSS S_RETROREFLECTIVE	

			#pragma multi_compile	LIGHTMAP_OFF LIGHTMAP_ON
			
			#pragma multi_compile	DIRLIGHTMAP_OFF DIRLIGHTMAP_COMBINED DIRLIGHTMAP_SEPARATE
			#pragma multi_compile	DYNAMICLIGHTMAP_OFF DYNAMICLIGHTMAP_ON	

			#include "UnityCG.cginc"
			#include "UnityLightingCommon.cginc"
			#include "UnityStandardUtils.cginc"
			#include "UnityGlobalIllumination.cginc"
			#include "vr_utils.cginc"
			#include "vr_lighting.cginc"
			#include "vr_matrix_palette_skinning.cginc"
			#include "vr_fog.cginc"

	

			#include "vr_zAO.cginc"

			float	g_flFresnelExponent;



			#pragma shader_feature _VERTEXTINT_ON
			#pragma shader_feature _MASMAP_ON
			#pragma shader_feature _VERTEXOCCLUSION_ON


			struct appdata //VS INPUT
			{
				UNITY_VERTEX_INPUT_INSTANCE_ID
				float4 vPositionOs : POSITION;
				float4 vTangentUOs_flTangentVSign : TANGENT;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 texcoord3 : TEXCOORD3;				
				fixed4 color : COLOR;				
			

				// #if ( LIGHTMAP_ON )
				// 	float2 vTexCoord1 : TEXCOORD1;
				// #endif
				// #if ( DYNAMICLIGHTMAP_ON || UNITY_PASS_META )
				// 	float2 vTexCoord2 : TEXCOORD2;
				// #endif
			};
			


			struct v2f //PS INPUT
			{
				float4 vPositionPs : SV_POSITION;
				float3 vPositionWs : TEXCOORD0;
				float3 vNormalWs : NORMAL;
				float3 vTangentUWs : TEXCOORD4;
				float3 vTangentVWs : TEXCOORD5;
				float2 vFogCoords : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;

				#if ( S_OVERRIDE_LIGHTMAP || LIGHTMAP_ON || DYNAMICLIGHTMAP_ON )
					#if ( DYNAMICLIGHTMAP_ON )
						centroid float4 vLightmapUV : TEXCOORD3;
					#else
						centroid float2 vLightmapUV : TEXCOORD3;
					#endif
				#endif
			};

			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float4 _Color;
			uniform float4 _ColorShift1;
			uniform sampler2D _ColorMask;
			uniform float4 _ColorShift2;
			uniform float4 _ColorShift3;
			uniform float4 _ColorShift4;
			uniform sampler2D _DetailAlbedoMap;
			uniform float4 _DetailAlbedoMap_ST;
			uniform float _BumpScale;
			uniform sampler2D _BumpMap;
			uniform float _DetailNormalMapScale;
			uniform sampler2D _DetailNormalMap;
			uniform float _Emission;
			uniform float _EmissiveMode;
			uniform sampler2D _EmissionMap;
			uniform float4 _EmissionColor;
			uniform float _EmissionFalloff;
			uniform sampler2D _MetallicGlossMap;

			//Vertex Shader
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f,o);
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v,o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				o.ase_texcoord1.xy = v.texcoord.xyzw.xy;
				o.ase_color = v.color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;

				float3 vPositionWs = mul( unity_ObjectToWorld, v.vPositionOs.xyzw ).xyz;

				float3 vNormalWs = UnityObjectToWorldNormal( v.normal.xyz );
				o.vNormalWs.xyz = vNormalWs.xyz;

				float3 vTangentUWs = UnityObjectToWorldDir( v.vTangentUOs_flTangentVSign.xyz ); // Transform tangentU into world space
				//vTangentUWs.xyz = normalize( vTangentUWs.xyz - ( vNormalWs.xyz * dot( vTangentUWs.xyz, vNormalWs.xyz ) ) ); // Force tangentU perpendicular to normal and normalize

				o.vTangentUWs.xyz = vTangentUWs.xyz;
				o.vTangentVWs.xyz = cross( vNormalWs.xyz, vTangentUWs.xyz ) * v.vTangentUOs_flTangentVSign.w;

				vPositionWs.xyz +=  float3(0,0,0) ;

				//v.vPositionPs = UnityObjectToClipPos(v.vPositionWs);
				o.vPositionPs.xyzw = UnityObjectToClipPos( v.vPositionOs.xyzw );
				o.vPositionWs = vPositionWs;

				#if ( LIGHTMAP_ON )
				{
					// Static lightmaps
					o.vLightmapUV.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
				}
				#endif

				#if ( DYNAMICLIGHTMAP_ON )
				{
					o.vLightmapUV.zw = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
				}
				#endif

				#if ( D_VALVE_FOG )				
					o.vFogCoords.xy = CalculateFogCoords( vPositionWs.xyz );				
				#endif


				return o;
			}


			/////////////////


			//Pixel Shader
			fixed4 frag (v2f i , bool bIsFrontFace : SV_IsFrontFace) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				fixed4 finalColor = float4(0,0,0,0);
				float2 uv_MainTex = i.ase_texcoord1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 uv0_MainTex = i.ase_texcoord1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode6 = tex2D( _ColorMask, uv0_MainTex );
				float4 lerpResult15 = lerp( float4( 1,1,1,1 ) , _ColorShift1 , tex2DNode6.r);
				float4 lerpResult16 = lerp( float4( 1,1,1,1 ) , _ColorShift2 , tex2DNode6.g);
				float4 lerpResult17 = lerp( float4( 1,1,1,1 ) , _ColorShift3 , tex2DNode6.b);
				float4 lerpResult18 = lerp( float4( 1,1,1,1 ) , _ColorShift4 , tex2DNode6.a);
				float2 uv_DetailAlbedoMap = i.ase_texcoord1.xy * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
				float4 color38 = IsGammaSpace() ? float4(1,1,1,1) : float4(1,1,1,1);
				#ifdef _VERTEXTINT_ON
				float4 staticSwitch37 = i.ase_color;
				#else
				float4 staticSwitch37 = color38;
				#endif
				float4 temp_output_5_0 = ( tex2D( _MainTex, uv_MainTex ) * _Color * ( lerpResult15 * lerpResult16 * lerpResult17 * lerpResult18 ) * ( tex2D( _DetailAlbedoMap, uv_DetailAlbedoMap ) * unity_ColorSpaceDouble ) * staticSwitch37 );
				
				float2 uv0_DetailAlbedoMap = i.ase_texcoord1.xy * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
				
				float4 temp_cast_1 = (0.0).xxxx;
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(i.vPositionWs.xyz);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float dotResult57 = dot( ase_worldViewDir , i.vNormalWs.xyz );
				float4 temp_output_50_0 = ( tex2D( _EmissionMap, uv0_MainTex ) * _EmissionColor * pow( abs( dotResult57 ) , ( _EmissionFalloff * 2.0 ) ) );
				
				float4 color41 = IsGammaSpace() ? float4(0,1,0,0) : float4(0,1,0,0);
				#ifdef _MASMAP_ON
				float4 staticSwitch39 = tex2D( _MetallicGlossMap, uv0_MainTex );
				#else
				float4 staticSwitch39 = color41;
				#endif
				float4 break40 = staticSwitch39;
				float3 temp_cast_3 = (break40.r).xxx;
				
				#ifdef _VERTEXOCCLUSION_ON
				float staticSwitch42 = i.ase_color.r;
				#else
				float staticSwitch42 = 1.0;
				#endif
				float temp_output_36_0 = saturate( ( break40.g * staticSwitch42 ) );
				


				float3 vTangentUWs = float3( 1.0, 0.0, 0.0 );
				float3 vTangentVWs = float3( 0.0, 1.0, 0.0 );

				vTangentUWs.xyz = i.vTangentUWs.xyz;
				vTangentVWs.xyz = i.vTangentVWs.xyz;
				
				float3 vGeometricNormalWs = float3( 0.0, 0.0, 1.0 );		
				i.vNormalWs.xyz *= ( bIsFrontFace ? 1.0 : -1.0 ); // Flip backfacking normals
				i.vNormalWs.xyz = normalize( i.vNormalWs.xyz );
				vGeometricNormalWs.xyz = i.vNormalWs.xyz;

				float3 vNormalWs = vGeometricNormalWs.xyz;

			//	float3 vNormalTs = float3( 0.0, 0.0, 1.0 );		

				
				//Specular components
				float3 vSpecColor;
				float flOneMinusReflectivity;

				LightingTerms_t lightingTerms;
				lightingTerms.vDiffuse.rgba = float4( 1.0, 1.0, 1.0 ,1.0);
				lightingTerms.vSpecular.rgb = float3( 0.0, 0.0, 0.0 );
				lightingTerms.vIndirectDiffuse.rgb = float3( 0.0, 0.0, 0.0 );
				lightingTerms.vIndirectSpecular.rgb = float3( 0.0, 0.0, 0.0 );
				lightingTerms.vTransmissiveSunlight.rgb = float3( 0.0, 0.0, 0.0 );


				float3 Albedo = temp_output_5_0.rgb;
				float3 Normal = BlendNormals( UnpackScaleNormal( tex2D( _BumpMap, uv0_MainTex ), _BumpScale ) , UnpackScaleNormal( tex2D( _DetailNormalMap, uv0_DetailAlbedoMap ), _DetailNormalMapScale ) );  //vNormalTs
				float3 Emission = lerp(temp_cast_1,lerp(temp_output_50_0,( temp_output_50_0 * temp_output_5_0 ),_EmissiveMode),_Emission).rgb;
				float Metallic = temp_cast_3;
				float Roughness = 1 - saturate( break40.b );
				float Retroreflective = 0;
				float AnisotropicDirection = 0;
				float AnisotropicRatio = 1;
				float DiffuseOcclusion = temp_output_36_0;
				float SpecularOcclusion = temp_output_36_0;
				float Alpha = 1;
				float Cutoff = 1;
				float3 Fluorescence = fixed3(0,0,0);
				float4 Absorbance = fixed4(0,0.5,0.75,0.9);
 		

				//Added a shader graph function instead
				//#if ( _ALPHATEST_ON )
				//Magic AlphaToCoverage sharpening. Thanks Ben Golus! https://medium.com/@bgolus/anti-aliased-alpha-test-the-esoteric-alpha-to-coverage-8b177335ae4f
				//Alpha = (Alpha - Cutoff) / max(fwidth(Alpha), 0.0001) + 0.5;
				//#endif 



				// #if ( S_ANISOTROPIC_GLOSS  )
				// {
				// 	//x = Metallic, y = Gloss, z = Rotation, w = Ratio
				// 	float4 vMetallicGloss;// = MetallicGloss( i.vTextureCoords.xy );
				// 		vMetallicGloss.z = frac(vMetallicGloss.z + _AnisotropicRotation);
				// 	#else
				// 		vMetallicGloss.xyzw = half4(_Metallic, _Glossiness, _AnisotropicRotation, _AnisotropicRatio);
				// 	#endif
	
				// 	flGloss.xyz = vMetallicGloss.yzw;
				// }

				// #elif ( S_RETROREFLECTIVE )
				// {
				// 	float normalBlend = saturate( Dotfresnel );
				// 	normalBlend = pow (normalBlend , 0.25);

				// 	float2 vMetallicGloss;// = MetallicGloss( i.vTextureCoords.xy );
				// 	#ifdef _METALLICGLOSSMAP
				// 		vMetallicGloss.xy = tex2D(_MetallicGlossMap, zTextureCoords.xy).ra;
				// 	#else
				// 		vMetallicGloss.xy = half2(_Metallic, _Glossiness);
				// 	#endif
		
				// 	flGloss.x = vMetallicGloss.y ;//* normalBlend;
				
				// }



					

				float4 vLightmapUV = float4( 0.0, 0.0, 0.0, 0.0 );
				#if ( S_OVERRIDE_LIGHTMAP || LIGHTMAP_ON || DYNAMICLIGHTMAP_ON )
				{
					vLightmapUV.xy = i.vLightmapUV.xy;
					#if ( DYNAMICLIGHTMAP_ON )
					{
						vLightmapUV.zw = i.vLightmapUV.zw;
					}
					#endif
				}
				#endif

				#if (S_RETROREFLECTIVE)
				float3 specularinfo = float3(Roughness,Retroreflective,Retroreflective);
				#elif (S_ANISOTROPIC_GLOSS)
				float3 specularinfo = float3(Roughness,AnisotropicDirection,AnisotropicRatio);
				#else 
				float3 specularinfo = Roughness;
				#endif

				//Normal falloff Roughness
				Roughness = AdjustRoughnessByGeometricNormal( Roughness, vGeometricNormalWs.xyz );

				Albedo = DiffuseAndSpecularFromMetallic( Albedo.rgb, Metallic, vSpecColor, flOneMinusReflectivity);
				vNormalWs.xyz = Vec3TsToWsNormalized( Normal.xyz, vGeometricNormalWs.xyz, vTangentUWs.xyz, vTangentVWs.xyz  ); //Add tanget normal to world normal
				float ndotv = saturate(dot( vNormalWs.xyz , CalculatePositionToCameraDirWs( i.vPositionWs.xyz ) ));	//base Fresnel falloff
				
				lightingTerms = ComputeLighting( i.vPositionWs, vNormalWs, vTangentUWs.xyz, vTangentVWs, specularinfo, vSpecColor, g_flFresnelExponent, vLightmapUV.xyzw, ndotv );
		//		lightingTerms = ComputeLighting( i.vPositionWs.xyz, vNormalWs.xyz, vTangentUWs.xyz, vTangentVWs.xyz, vRoughness.xyz, vReflectance.rgb, g_flFresnelExponent, vLightmapUV.xyzw, Dotfresnel );
				finalColor.rgb = (lightingTerms.vDiffuse.rgb + lightingTerms.vIndirectDiffuse.rgb) * Albedo * DiffuseOcclusion;
				finalColor.rgb += (lightingTerms.vSpecular.rgb + lightingTerms.vIndirectSpecular.rgb) * SpecularOcclusion;

				
				#if ( _FLUORESCENCEMAP )			

					float4 FluorescenceAbsorb = (lightingTerms.vDiffuse + float4( lightingTerms.vIndirectDiffuse.rgb , 0.0 ) ) * Absorbance;					

					float Absorbed_B = FluorescenceAbsorb.b + FluorescenceAbsorb.a;
					float Absorbed_G = Absorbed_B + FluorescenceAbsorb.g;
					float Absorbed_R = Absorbed_G + FluorescenceAbsorb.r;

					float3 LitFluorescence =  float3(Absorbed_R, Absorbed_G, Absorbed_B) * Fluorescence.rgb ;
					finalColor.rgb = max(finalColor.rgb, LitFluorescence.rgb);					

				#endif

			#ifdef Z_SHAPEAO 					
				float vAO = CalculateShapeAO( i.vPositionWs.xyz, vNormalWs);
				finalColor.rgb *= vAO;			
			#endif

				finalColor.rgb += Emission;

			#if ( D_VALVE_FOG )
					// #if (_ALPHAPREMULTIPLY_ON || _ALPHAMULTIPLY_ON || _ALPHAMOD2X_ON)
					// o.vColor.rgba = ApplyFog( o.vColor.rgba, i.vFogCoords.xy, _FogMultiplier, _ColorMultiplier );
					// #else
					finalColor.rgb = ApplyFog( finalColor.rgb, i.vFogCoords.xy, 1 );
					//#endif
			#endif

			finalColor.rgb += ScreenSpaceDither( i.vPositionPs.xy );

			finalColor.a = Alpha;

			// #if S_SPECULAR_BLINNPHONG
			// finalColor *= float4(0,1,0,1);
			// #endif
			
				// #if _BRDFMAP

				// finalColor = float4(1,0,0,1);
				// #endif

				return finalColor;
			}
			ENDCG
		}

				Pass
		{
			Name "META" 
			Tags { "LightMode"="Meta" }
		
			Cull Off
			CGPROGRAM
				/*ase_pragma_before*/
				#pragma only_renderers d3d11

				#pragma vertex vert_meta
				#pragma fragment frag_meta
		
				#pragma shader_feature _EMISSION
				#pragma shader_feature _METALLICGLOSSMAP
				#pragma shader_feature ___ _DETAIL_MULX2
		
				#include "UnityStandardMeta.cginc"
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=16900
7;7;1906;1044;1475.786;1121.982;1.475714;True;True
Node;AmplifyShaderEditor.WorldNormalVector;56;-484.6259,-706.033;Float;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;55;-512.6259,-902.033;Float;True;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TextureCoordinatesNode;19;-2317.02,-100.7064;Float;False;0;4;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DotProductOpNode;57;-260.626,-836.033;Float;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;7;-1842.653,63.3339;Float;False;Property;_ColorShift1;_ColorShift1;3;0;Create;True;0;0;False;0;1,1,1,1;0.2464398,0.735849,0.3784411,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;9;-1843.955,396.1339;Float;False;Property;_ColorShift3;_ColorShift3;5;0;Create;True;0;0;False;0;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;52;-512.6591,-541.2291;Float;False;Property;_EmissionFalloff;Emission Falloff;13;0;Create;True;0;0;False;0;0;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;6;-1922.863,-123.516;Float;True;Property;_ColorMask;Color Tint;2;1;[NoScaleOffset];Create;False;0;0;False;0;None;bbed8785d11319b40912fda8c3491264;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;10;-1845.256,565.135;Float;False;Property;_ColorShift4;_ColorShift4;6;0;Create;True;0;0;False;0;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;8;-1842.655,228.4338;Float;False;Property;_ColorShift2;_ColorShift2;4;0;Create;True;0;0;False;0;1,1,1,1;0.5438323,0.6323029,0.9528301,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;16;-1488.783,257.5317;Float;False;3;0;COLOR;1,1,1,1;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;15;-1483.848,125.9432;Float;False;3;0;COLOR;1,1,1,1;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;23;-1228.112,640.2944;Float;False;0;4;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorSpaceDouble;28;-1382.423,-492.9958;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;17;-1474.755,398.7339;Float;False;3;0;COLOR;1,1,1,1;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;18;-1474.755,561.235;Float;False;3;0;COLOR;1,1,1,1;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;27;-1436.148,-699.0309;Float;True;Property;_DetailAlbedoMap;Detail Albedo Map;15;0;Create;False;0;0;False;1;Header(Detail Maps);None;None;True;0;False;gray;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;34;-1126.135,30.37822;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.AbsOpNode;54;6.340749,-803.4291;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;-200.6261,-566.033;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;59;-565.3171,-372.2101;Float;False;0;4;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;38;-1322.079,35.30484;Float;False;Constant;_Color0;Color 0;14;0;Create;True;0;0;False;0;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;53;68.94061,-664.329;Float;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;2;-1272.656,-126.1748;Float;False;Property;_Color;Color;0;0;Create;True;0;0;False;0;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;-1212.157,198.5335;Float;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;41;-777.7102,928.4866;Float;False;Constant;_Color1;Color 1;15;0;Create;True;0;0;False;0;0,1,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;22;-945.9564,674.4743;Float;True;Property;_MetallicGlossMap;Metallic MAS;7;1;[NoScaleOffset];Create;False;0;0;False;0;None;00221b33eff0e5842a350261ce135a38;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;4;-1355.403,-317.116;Float;True;Property;_MainTex;Albedo;1;0;Create;False;0;0;False;0;None;2d12fa2548bdd3d4a833986b8401f983;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;-1090.249,-549.8705;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;49;-278.6008,-432.9898;Float;True;Property;_EmissionMap;Emission Map;11;1;[NoScaleOffset];Create;True;0;0;False;0;None;d9d6fb4381891074796cd6ddf17492a8;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;37;-866.9522,-8.621437;Float;False;Property;_VERTEXTINT;Vertex Tint;18;0;Create;False;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;47;-193.6205,-225.299;Float;False;Property;_EmissionColor;Emission Color;12;1;[HDR];Create;True;0;0;False;0;0,0,0,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;-575.3586,-107.9103;Float;False;5;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;51.34497,-308.8792;Float;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;39;-558.069,785.7245;Float;False;Property;_MASMAP;MAS Map Enabled;21;0;Create;False;0;0;False;0;0;1;1;True;;Toggle;2;Key0;Key1;Create;False;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;43;-515.0508,442.5524;Float;False;Constant;_Float0;Float 0;16;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;-6.505615,-36.74738;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;42;-435.7505,515.3526;Float;False;Property;_VertexOcclusion;Vertex Occlusion;19;0;Create;False;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-1153.8,523.3629;Float;False;Property;_BumpScale;Bump Scale;8;0;Create;False;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;32;-883.3074,156.6953;Float;False;0;27;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;33;-1193.346,410.4283;Float;False;Property;_DetailNormalMapScale;Detail Normal Map Scale;17;0;Create;False;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;40;-597.7102,636.4866;Float;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;51;-112.655,70.12085;Float;False;Constant;_Float2;Float 2;20;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;26;-929.8024,472.3631;Float;True;Property;_BumpMap;Bump Map;9;2;[NoScaleOffset];[Normal];Create;False;0;0;False;0;None;039f66d3fba79dd4ca2a49c08eb7b2c1;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-257.8031,636.4937;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;60;203.4944,-84.74738;Float;False;Property;_EmissiveMode;Emissive Albedo Multiplcation;14;0;Create;False;0;0;False;0;0;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;31;-881.0685,285.921;Float;True;Property;_DetailNormalMap;Detail Normal Map;16;2;[NoScaleOffset];[Normal];Create;False;0;0;False;0;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ToggleSwitchNode;62;296.4944,55.25262;Float;False;Property;_Emission;Emission Enable;10;0;Create;False;0;0;False;0;1;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;45;-376.6,393.8023;Float;False;Constant;_Float1;Float 1;17;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;36;-93.66667,611.7089;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendNormalsNode;30;-432.2597,289.0615;Float;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;44;-197.1996,399.0023;Float;False;Property;VertexIllumination;VertexIllumination;20;0;Create;False;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;562.9401,250.4411;Float;False;True;2;Float;ASEMaterialInspector;0;11;SLZ/VR ColorTint;1f6ac94e27bd0934ab97faa6217ad58e;True;VRBase;0;0;VRBase;15;False;False;False;False;False;False;False;False;False;True;1;RenderType=Opaque=RenderType;False;0;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;True;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;2;LightMode=ForwardBase;PassFlags=OnlyDirectional;True;2;0;;0;0;Standard;0;0;1;True;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;11;FLOAT;0;False;12;FLOAT3;0,0,0;False;13;FLOAT4;0,0,0,0;False;14;FLOAT3;0,0,0;False;0
WireConnection;57;0;55;0
WireConnection;57;1;56;0
WireConnection;6;1;19;0
WireConnection;16;1;8;0
WireConnection;16;2;6;2
WireConnection;15;1;7;0
WireConnection;15;2;6;1
WireConnection;17;1;9;0
WireConnection;17;2;6;3
WireConnection;18;1;10;0
WireConnection;18;2;6;4
WireConnection;54;0;57;0
WireConnection;58;0;52;0
WireConnection;53;0;54;0
WireConnection;53;1;58;0
WireConnection;13;0;15;0
WireConnection;13;1;16;0
WireConnection;13;2;17;0
WireConnection;13;3;18;0
WireConnection;22;1;23;0
WireConnection;29;0;27;0
WireConnection;29;1;28;0
WireConnection;49;1;59;0
WireConnection;37;1;38;0
WireConnection;37;0;34;0
WireConnection;5;0;4;0
WireConnection;5;1;2;0
WireConnection;5;2;13;0
WireConnection;5;3;29;0
WireConnection;5;4;37;0
WireConnection;50;0;49;0
WireConnection;50;1;47;0
WireConnection;50;2;53;0
WireConnection;39;1;41;0
WireConnection;39;0;22;0
WireConnection;61;0;50;0
WireConnection;61;1;5;0
WireConnection;42;1;43;0
WireConnection;42;0;34;1
WireConnection;40;0;39;0
WireConnection;26;1;23;0
WireConnection;26;5;25;0
WireConnection;35;0;40;1
WireConnection;35;1;42;0
WireConnection;60;0;50;0
WireConnection;60;1;61;0
WireConnection;31;1;32;0
WireConnection;31;5;33;0
WireConnection;62;0;51;0
WireConnection;62;1;60;0
WireConnection;36;0;35;0
WireConnection;30;0;26;0
WireConnection;30;1;31;0
WireConnection;44;1;45;0
WireConnection;44;0;34;4
WireConnection;1;0;5;0
WireConnection;1;1;30;0
WireConnection;1;2;62;0
WireConnection;1;3;40;0
WireConnection;1;4;40;2
WireConnection;1;8;36;0
WireConnection;1;9;36;0
ASEEND*/
//CHKSM=125CFC14543AD3B154350E8E6CAB4481B1FB79B0