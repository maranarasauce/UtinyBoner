// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SDK/Flowmap Alpha"
{
	Properties
	{
		[NoScaleOffset][Header(Motion Vectors)]_MotionVectors("Motion Vectors", 2D) = "white" {}
		_UVMotionMultiplier("UV Motion Multiplier", Float) = 0
		_Speed("Speed", Float) = 1
		[Header(Main Properties)]_MainTex("Main Texture", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
		[NoScaleOffset]_Texture0("Bump Map", 2D) = "bump" {}
		_BumpScale("Bump Scale", Float) = 1
		_Glossiness("Glossiness", Range( 0 , 1)) = 0
		_Metallic("Metallic", Range( 0 , 1)) = 0
		_OffsetUnits("Offset Units", Int) = -1
		_OffsetFactor("Offset Factor", Int) = -1
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
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
		LOD 100
		
		



		Pass
		{
			Name "VRBase"
			Tags { "LightMode"="ForwardBase" "PassFlags"="OnlyDirectional" } // NOTE: "OnlyDirectional" prevents Unity from baking dynamic lights into SH terms at runtime


			CGINCLUDE
			#pragma target 3.0
			ENDCG
			Blend SrcAlpha OneMinusSrcAlpha
			ColorMask RGBA
			ZWrite Off
			ZTest LEqual
			Offset [_OffsetFactor] , [_OffsetUnits]
			
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



			#include "UnityShaderVariables.cginc"


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

			uniform int _OffsetFactor;
			uniform int _OffsetUnits;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform sampler2D _MotionVectors;
			uniform float _Speed;
			uniform float _UVMotionMultiplier;
			uniform float4 _Color;
			uniform sampler2D _Texture0;
			uniform float _BumpScale;
			uniform float _Metallic;
			uniform float _Glossiness;

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
				float2 uv0_MainTex = i.ase_texcoord1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 temp_output_63_0 = (tex2D( _MotionVectors, uv0_MainTex )).rg;
				float2 temp_cast_0 = (0.5).xx;
				float mulTime32 = _Time.y * _Speed;
				float2 temp_output_21_0 = ( uv0_MainTex + ( ( temp_output_63_0 - temp_cast_0 ) * frac( mulTime32 ) * -_UVMotionMultiplier ) );
				float2 temp_cast_1 = (0.5).xx;
				float temp_output_14_0 = ( 1.0 - frac( mulTime32 ) );
				float2 temp_output_20_0 = ( uv0_MainTex + ( ( temp_output_63_0 - temp_cast_1 ) * temp_output_14_0 * -1.0 * -_UVMotionMultiplier ) );
				float4 lerpResult24 = lerp( tex2D( _MainTex, temp_output_21_0 ) , tex2D( _MainTex, temp_output_20_0 ) , frac( mulTime32 ));
				float4 temp_output_26_0 = ( lerpResult24 * _Color );
				
				float2 temp_cast_3 = (0.5).xx;
				float2 temp_cast_4 = (0.5).xx;
				
				float3 temp_cast_5 = (_Metallic).xxx;
				


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


				float3 Albedo = temp_output_26_0.rgb;
				float3 Normal = BlendNormals( UnpackScaleNormal( tex2D( _Texture0, temp_output_21_0 ), ( _BumpScale * temp_output_14_0 ) ) , UnpackScaleNormal( tex2D( _Texture0, temp_output_20_0 ), ( _BumpScale * frac( mulTime32 ) ) ) );  //vNormalTs
				float3 Emission = fixed3(0,0,0);
				float Metallic = temp_cast_5;
				float Roughness = 1 - saturate( _Glossiness );
				float Retroreflective = 0;
				float AnisotropicDirection = 0;
				float AnisotropicRatio = 1;
				float DiffuseOcclusion = 1;
				float SpecularOcclusion = 1;
				float Alpha = ( (temp_output_26_0).a * i.ase_color.a );
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
65;173;1262;859;434.2383;277.8239;1.164181;True;True
Node;AmplifyShaderEditor.CommentaryNode;3;-3209.867,279.5115;Float;False;1541.69;636.4142;Motion Vector interpolation;16;14;20;21;18;17;11;13;15;12;10;8;9;7;5;31;63;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-3236.938,-104.6966;Float;False;Property;_Speed;Speed;2;0;Create;True;0;0;False;0;1;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;31;-3173.88,337.8394;Float;False;0;19;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;5;-3159.867,492.3456;Float;True;Property;_MotionVectors;Motion Vectors;0;1;[NoScaleOffset];Create;True;0;0;False;1;Header(Motion Vectors);None;7bbf61cdf64f7924e88a1cf279c710b3;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleTimeNode;32;-3036.967,-83.42313;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;37;-2801.675,-26.52748;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;7;-2822.412,367.0664;Float;True;Property;_TextureSample2;Texture Sample 2;3;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RelayNode;35;-2156.69,-69.69698;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;63;-2516.88,415.0787;Float;False;FLOAT2;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-2765.948,821.1539;Float;False;Property;_UVMotionMultiplier;UV Motion Multiplier;1;0;Create;True;0;0;False;0;0;0.06;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-2406.758,502.5175;Float;False;Constant;_5;.5;3;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-2261.969,752.2297;Float;False;Constant;_Float0;Float 0;3;0;Create;True;0;0;False;0;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;12;-2472.52,789.7024;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;15;-2274.2,393.4151;Float;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;14;-2112.407,573.3732;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;13;-2264.157,590.0854;Float;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;16;-1424.072,-240.9597;Float;False;1091.596;477.5999;Main Texture frame blend;4;24;23;22;19;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;-2080.022,390.2114;Float;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-2088.98,719.7828;Float;False;4;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;20;-1879.434,563.1824;Float;True;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;21;-1869.644,326.1999;Float;True;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;19;-1381.9,-85.73202;Float;True;Property;_MainTex;Main Texture;3;0;Create;False;0;0;False;1;Header(Main Properties);None;ef92e2642d709e04890b0c2b0e40c32a;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SamplerNode;22;-925.9753,6.640089;Float;True;Property;_TextureSample1;Texture Sample 1;0;0;Create;True;0;0;False;0;None;None;True;1;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;23;-924.6756,-190.9597;Float;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;48;-1463.429,349.438;Float;False;1195.681;483.853;Main Texture frame blend;7;55;59;57;49;50;51;56;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-1434.16,639.3347;Float;False;Property;_BumpScale;Bump Scale;6;0;Create;True;0;0;False;0;1;0.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;24;-569.0896,-99.81689;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;25;-295.6392,-507.4594;Float;False;Property;_Color;Color;4;0;Create;True;0;0;False;0;1,1,1,1;1,1,1,0.7058824;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;-1233.45,687.5551;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;49;-1433.035,400.8514;Float;True;Property;_Texture0;Bump Map;5;1;[NoScaleOffset];Create;False;0;0;False;0;None;0dbeceaaed7301a4a8bd2a5bb1b31c01;True;bump;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;-1232.726,583.8216;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;79.70188,-254.0547;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;51;-964.0329,399.438;Float;True;Property;_TextureSample5;Texture Sample 5;0;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;50;-965.3325,597.0377;Float;True;Property;_TextureSample4;Texture Sample 4;0;0;Create;True;0;0;False;0;None;None;True;1;False;white;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;2;-2383.116,-883.1053;Float;False;624.7802;563.0769;Vertex inputs;5;30;29;28;6;4;;1,1,1,1;0;0
Node;AmplifyShaderEditor.VertexColorNode;70;69.27008,442.222;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwizzleNode;66;-38.99877,143.0275;Float;False;FLOAT;3;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;4;-2021.421,-824.0052;Float;False;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SinOpNode;36;-2805.051,-136.5555;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;62;-1625.386,-4.305231;Float;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;8;-2830.752,565.9059;Float;True;Property;_TextureSample3;Texture Sample 3;3;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;30;-2309.801,-503.8096;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-1854.062,-166.9863;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;28;-2330.82,-833.1053;Float;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.IntNode;69;403.39,363.0577;Float;False;Property;_OffsetUnits;Offset Units;9;0;Create;True;0;0;True;0;-1;-1;0;1;INT;0
Node;AmplifyShaderEditor.RangedFloatNode;65;135.5955,-53.11901;Float;False;Property;_Metallic;Metallic;8;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;29;-2323.657,-651.9739;Float;False;1;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwizzleNode;6;-2020.121,-701.8049;Float;False;FLOAT2;2;3;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;71;391.7482,160.4902;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;64;98.14169,26.11019;Float;False;Property;_Glossiness;Glossiness;7;0;Create;True;0;0;False;0;0;0.93;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;68;401.0617,283.8934;Float;False;Property;_OffsetFactor;Offset Factor;10;0;Create;True;0;0;True;0;-1;-1;0;1;INT;0
Node;AmplifyShaderEditor.BlendNormalsNode;55;-568.6594,503.434;Float;True;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;61;-1691.324,-157.6475;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;656.3586,-162.6267;Float;False;True;2;Float;ASEMaterialInspector;0;11;SLZ/Flowmap Alpha;1f6ac94e27bd0934ab97faa6217ad58e;True;VRBase;0;0;VRBase;15;False;False;False;False;False;False;False;False;False;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;False;0;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;True;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;True;0;True;68;0;True;69;True;2;LightMode=ForwardBase;PassFlags=OnlyDirectional;True;2;0;;0;0;Standard;0;0;1;True;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;11;FLOAT;0;False;12;FLOAT3;0,0,0;False;13;FLOAT4;0,0,0,0;False;14;FLOAT3;0,0,0;False;0
WireConnection;32;0;33;0
WireConnection;37;0;32;0
WireConnection;7;0;5;0
WireConnection;7;1;31;0
WireConnection;35;0;37;0
WireConnection;63;0;7;0
WireConnection;12;0;10;0
WireConnection;15;0;63;0
WireConnection;15;1;9;0
WireConnection;14;0;35;0
WireConnection;13;0;63;0
WireConnection;13;1;9;0
WireConnection;17;0;15;0
WireConnection;17;1;35;0
WireConnection;17;2;12;0
WireConnection;18;0;13;0
WireConnection;18;1;14;0
WireConnection;18;2;11;0
WireConnection;18;3;12;0
WireConnection;20;0;31;0
WireConnection;20;1;18;0
WireConnection;21;0;31;0
WireConnection;21;1;17;0
WireConnection;22;0;19;0
WireConnection;22;1;20;0
WireConnection;23;0;19;0
WireConnection;23;1;21;0
WireConnection;24;0;23;0
WireConnection;24;1;22;0
WireConnection;24;2;35;0
WireConnection;59;0;56;0
WireConnection;59;1;14;0
WireConnection;57;0;56;0
WireConnection;57;1;35;0
WireConnection;26;0;24;0
WireConnection;26;1;25;0
WireConnection;51;0;49;0
WireConnection;51;1;21;0
WireConnection;51;5;59;0
WireConnection;50;0;49;0
WireConnection;50;1;20;0
WireConnection;50;5;57;0
WireConnection;66;0;26;0
WireConnection;4;0;28;0
WireConnection;36;0;32;0
WireConnection;62;0;61;0
WireConnection;8;0;5;0
WireConnection;8;1;31;0
WireConnection;60;0;35;0
WireConnection;60;1;35;0
WireConnection;6;0;28;0
WireConnection;71;0;66;0
WireConnection;71;1;70;4
WireConnection;55;0;51;0
WireConnection;55;1;50;0
WireConnection;61;0;60;0
WireConnection;61;1;60;0
WireConnection;1;0;26;0
WireConnection;1;1;55;0
WireConnection;1;3;65;0
WireConnection;1;4;64;0
WireConnection;1;10;71;0
ASEEND*/
//CHKSM=42BCDF7E1A30D0BD6B68B0644B0D9AE97A6EB086