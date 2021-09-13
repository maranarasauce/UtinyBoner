// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SDK/ParticleMotionVector"
{
	Properties
	{
		[NoScaleOffset]_MainTex("Main Texture", 2D) = "white" {}
		[NoScaleOffset]_MotionVectors("Motion Vectors", 2D) = "white" {}
		_UVMotionMultiplier("UV Motion Multiplier", Float) = 0
		_Color("Color", Color) = (1,1,1,1)
		_DepthBlend("Depth Blend", float) = 0.5
		_ShadowBlend("Shadow Blend", float) = 0.2
		_ColorDitherPercent("Color Dithering Percentage", Range(0.0,1)) = 0.03

		
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
			Offset 0 , 0
			
			Cull Back

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile _ Z_SHAPEAO
			#pragma multi_compile_instancing
			#pragma multi_compile _ D_VALVE_FOG
			#pragma skip_variants SHADOWS_SOFT
			#pragma shader_feature	_BRDFMAP
			#pragma shader_feature	S_RECEIVE_SHADOWS
			#pragma shader_feature  _FLUORESCENCEMAP
			#pragma shader_feature LIGHTPROBE_SH
			

			#pragma multi_compile	S_SPECULAR_METALLIC S_ANISOTROPIC_GLOSS S_RETROREFLECTIVE	

		//	#pragma multi_compile	LIGHTMAP_OFF LIGHTMAP_ON
			
		//	#pragma multi_compile	DIRLIGHTMAP_OFF DIRLIGHTMAP_COMBINED DIRLIGHTMAP_SEPARATE
		//	#pragma multi_compile	DYNAMICLIGHTMAP_OFF DYNAMICLIGHTMAP_ON	

			#include "UnityCG.cginc"
			#include "UnityLightingCommon.cginc"
			#include "UnityStandardUtils.cginc"
			#include "UnityGlobalIllumination.cginc"
			#include "vr_utils.cginc"
			#include "vr_lighting.cginc"
			#include "vr_matrix_palette_skinning.cginc"
			#include "vr_fog.cginc"
			//#include "vr_Dithering.cginc"

	

			#include "vr_zAO.cginc"

			float	g_flFresnelExponent;



			

			struct appdata //VS INPUT
			{
				UNITY_VERTEX_INPUT_INSTANCE_ID
				float4 vPositionOs : POSITION;		
				float3 normal : NORMAL;
				fixed4 color : COLOR;		
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 texcoord3 : TEXCOORD3;			
				float4 vTangentUOs_flTangentVSign : TANGENT;
			

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
				float4 vPositionWs : TEXCOORD0;
				float3 vNormalWs : NORMAL;
				float4 projPos : TEXCOORD3;
				float3 vTangentUWs : TEXCOORD4;
				float3 vTangentVWs : TEXCOORD5;
				float2 vFogCoords : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;

				#if ( S_OVERRIDE_LIGHTMAP || LIGHTMAP_ON || DYNAMICLIGHTMAP_ON )
					#if ( DYNAMICLIGHTMAP_ON )
						centroid float4 vLightmapUV : TEXCOORD3;
					#else
						centroid float2 vLightmapUV : TEXCOORD3;
					#endif
				#endif
			};

			uniform sampler2D _MainTex;
			uniform sampler2D _MotionVectors;
			uniform float _UVMotionMultiplier;
			uniform float4 _Color;
			uniform float _DepthBlend;
			uniform float _ShadowBlend;
			uniform float _ColorDitherPercent;

		

			//Vertex Shader
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f,o);
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v,o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				o.ase_color = v.color;
				o.ase_texcoord1 = v.texcoord.xyzw;
				o.ase_texcoord2.xy = v.texcoord1.xyzw.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;

				o.vPositionWs.xyz = mul( unity_ObjectToWorld, v.vPositionOs.xyzw ).xyz;

				float3 vNormalWs = UnityObjectToWorldNormal( v.normal.xyz );
				o.vNormalWs.xyz = vNormalWs.xyz;

				float3 vTangentUWs = UnityObjectToWorldDir( v.vTangentUOs_flTangentVSign.xyz ); // Transform tangentU into world space
				//vTangentUWs.xyz = normalize( vTangentUWs.xyz - ( vNormalWs.xyz * dot( vTangentUWs.xyz, vNormalWs.xyz ) ) ); // Force tangentU perpendicular to normal and normalize

				o.vTangentUWs.xyz = vTangentUWs.xyz;
				o.vTangentVWs.xyz = cross( vNormalWs.xyz, vTangentUWs.xyz ) * v.vTangentUOs_flTangentVSign.w;

				//vPositionWs.xyz +=  float3(0,0,0) ;

				//v.vPositionPs = UnityObjectToClipPos(v.vPositionWs);
				o.vPositionPs.xyzw = UnityObjectToClipPos( v.vPositionOs.xyzw );

				
				
			//	o.vPositionWs.xyz = vPositionWs;				
				//COMPUTE_EYEDEPTH(o.vPositionWs.w);

				//o.projPos = DepthFade_VS_ComputeProjPos(o.vPositionWs,o.vPositionPs);
				
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
					o.vFogCoords.xy = CalculateFogCoords( o.vPositionWs.xyz );				
				#endif


				return o;
			}


			/////////////////


			//Pixel Shader
			fixed4 frag (v2f i , bool bIsFrontFace : SV_IsFrontFace,  out float outDepth : SV_Depth) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				fixed4 finalColor = float4(0,0,0,0);
				float2 temp_output_8_0 = (i.ase_texcoord1).xy;
				float4 temp_cast_1 = (0.5).xxxx;
				float2 temp_output_9_0 = (i.ase_texcoord1).zw;
				float4 temp_cast_4 = (0.5).xxxx;
				float4 lerpResult4 = lerp( tex2D( _MainTex, ( float4( temp_output_8_0, 0.0 , 0.0 ) + ( ( tex2D( _MotionVectors, temp_output_8_0 ) - temp_cast_1 ) * i.ase_texcoord2.xy.x * -_UVMotionMultiplier ) ).rg ) , tex2D( _MainTex, ( float4( temp_output_9_0, 0.0 , 0.0 ) + ( ( tex2D( _MotionVectors, temp_output_9_0 ) - temp_cast_4 ) * ( 1.0 - i.ase_texcoord2.xy.x ) * -1.0 * -_UVMotionMultiplier ) ).rg ) , i.ase_texcoord2.xy.x);
				float4 temp_output_11_0 = ( i.ase_color * lerpResult4 * _Color );
				


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


				float3 Albedo = temp_output_11_0.rgb;
				float3 Normal = fixed3(0,0,1);  //vNormalTs
				float3 Emission = fixed3(0,0,0);
				float Metallic = fixed3(0,0,0);
				float Roughness = 1 - saturate( 0 );
				float Retroreflective = 0;
				float AnisotropicDirection = 0;
				float AnisotropicRatio = 1;
				float DiffuseOcclusion = 1;
				float SpecularOcclusion = 1;
				float Alpha = (temp_output_11_0).a;
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

				float4 dither = ScreenSpaceDither( cross( i.vPositionPs, frac(i.vPositionWs)).xy );
				//float4 dither = (DitherTex(ScreenSpaceNoiseUVs(i.projPos), i.ase_texcoord2.y   ).rgba - 0.5) * 2;

				float depthWithOffset = i.vPositionPs.w + (_DepthBlend * dither.w );
				outDepth = (1.0 - depthWithOffset * _ZBufferParams.w) / (depthWithOffset * _ZBufferParams.z);

				//Normal falloff Roughness
				Roughness = AdjustRoughnessByGeometricNormal( Roughness, vGeometricNormalWs.xyz );

				Albedo = DiffuseAndSpecularFromMetallic( Albedo.rgb, Metallic, vSpecColor, flOneMinusReflectivity);
				vNormalWs.xyz = Vec3TsToWsNormalized( Normal.xyz, vGeometricNormalWs.xyz, vTangentUWs.xyz, vTangentVWs.xyz  ); //Add tanget normal to world normal
				float ndotv = saturate(dot( vNormalWs.xyz , CalculatePositionToCameraDirWs( i.vPositionWs.xyz ) ));	//base Fresnel falloff
				
				lightingTerms = ComputeLighting(  ( _ShadowBlend * dither.rgb) + i.vPositionWs , vNormalWs, vTangentUWs.xyz, vTangentVWs, specularinfo, vSpecColor, g_flFresnelExponent, vLightmapUV.xyzw, ndotv );
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




			finalColor.rgb += dither.rgb * _ColorDitherPercent;

			finalColor.a = Alpha;

			// #if S_SPECULAR_BLINNPHONG
			// finalColor *= float4(0,1,0,1);
			// #endif
			
				// #if _BRDFMAP

				// finalColor = float4(1,0,0,1);
				// #endif

				return max(finalColor,0);
			}
			ENDCG
		}

				Pass
		{
			Name "META" 
			Tags { "LightMode"="Meta" }
		
			Cull Off
			CGPROGRAM
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
//	CustomEditor "ASEMaterialInspector"
//Disable to prevent changing custom code
	
	
}
/*ASEBEGIN
Version=15800
7;1;1906;1050;973.0874;776.0382;1;True;True
Node;AmplifyShaderEditor.CommentaryNode;30;-2135.565,-834.6841;Float;False;624.7802;563.0769;Vertex inputs;5;10;8;9;5;12;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;32;-2380.879,431.1962;Float;False;1565.432;670.7075;Motion Vector interpolation;14;14;19;16;27;15;29;20;24;18;26;23;25;22;21;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;5;-2083.268,-784.6841;Float;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwizzleNode;8;-1773.869,-775.5839;Float;False;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;14;-2330.879,644.0304;Float;True;Property;_MotionVectors;Motion Vectors;1;1;[NoScaleOffset];Create;True;0;0;False;0;None;832b127cde357e145bba7c3329a2b3cd;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SwizzleNode;9;-1772.569,-653.3837;Float;False;FLOAT2;2;3;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;10;-2076.106,-603.5528;Float;False;1;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;15;-1852.509,523.3021;Float;True;Property;_TextureSample2;Texture Sample 2;3;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;16;-1846.838,725.0273;Float;True;Property;_TextureSample3;Texture Sample 3;3;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;19;-1572.804,645.9233;Float;False;Constant;_5;.5;3;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-1936.96,972.8386;Float;False;Property;_UVMotionMultiplier;UV Motion Multiplier;2;0;Create;True;0;0;False;0;0;0.055;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-1432.981,903.9144;Float;False;Constant;_Float0;Float 0;3;0;Create;True;0;0;False;0;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;29;-1643.534,941.3871;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;20;-1423.579,730.1797;Float;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;26;-1328.071,670.7819;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;18;-1428.655,530.1978;Float;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;31;-1176.52,-192.5386;Float;False;1091.596;477.5999;Main Texture frame blend;4;2;1;4;3;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-1280.839,546.8636;Float;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-1259.993,871.4675;Float;False;4;4;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;3;-1126.52,-92.10968;Float;True;Property;_MainTex;Main Texture;0;1;[NoScaleOffset];Create;False;0;0;False;0;None;8049c5ec6ca7b67409741a0623d5321b;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleAddOpNode;22;-1050.446,714.8672;Float;True;2;2;0;FLOAT2;0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;21;-1113.511,481.1962;Float;True;2;2;0;FLOAT2;0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;2;-678.4235,55.06132;Float;True;Property;_TextureSample1;Texture Sample 1;0;0;Create;True;0;0;False;0;None;None;True;1;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-677.1238,-142.5386;Float;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;4;-268.9241,21.26115;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;12;-2062.249,-455.3885;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;34;-48.0874,-459.0382;Float;False;Property;_Color;Color;3;0;Create;True;0;0;False;0;1,1,1,1;1,1,1,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;140.1494,-250.3399;Float;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SwizzleNode;13;385.8634,39.8019;Float;False;FLOAT;3;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;33;731.764,-182.1625;Float;False;True;2;Float;ASEMaterialInspector;0;10;SLZ/Particle Motion Vector;1f6ac94e27bd0934ab97faa6217ad58e;0;0;VRBase;15;False;False;False;False;False;False;False;False;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;False;0;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;2;LightMode=ForwardBase;PassFlags=OnlyDirectional;True;2;0;;0;0;Standard;0;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;11;FLOAT;0;False;12;FLOAT3;0,0,0;False;13;FLOAT4;0,0,0,0;False;14;FLOAT3;0,0,0;False;0
WireConnection;8;0;5;0
WireConnection;9;0;5;0
WireConnection;15;0;14;0
WireConnection;15;1;8;0
WireConnection;16;0;14;0
WireConnection;16;1;9;0
WireConnection;29;0;27;0
WireConnection;20;0;16;0
WireConnection;20;1;19;0
WireConnection;26;0;10;1
WireConnection;18;0;15;0
WireConnection;18;1;19;0
WireConnection;25;0;18;0
WireConnection;25;1;10;1
WireConnection;25;2;29;0
WireConnection;23;0;20;0
WireConnection;23;1;26;0
WireConnection;23;2;24;0
WireConnection;23;3;29;0
WireConnection;22;0;9;0
WireConnection;22;1;23;0
WireConnection;21;0;8;0
WireConnection;21;1;25;0
WireConnection;2;0;3;0
WireConnection;2;1;22;0
WireConnection;1;0;3;0
WireConnection;1;1;21;0
WireConnection;4;0;1;0
WireConnection;4;1;2;0
WireConnection;4;2;10;1
WireConnection;11;0;12;0
WireConnection;11;1;4;0
WireConnection;11;2;34;0
WireConnection;13;0;11;0
WireConnection;33;0;11;0
WireConnection;33;10;13;0
ASEEND*/
//CHKSM=35203D4D0CBF147C8C09671A1C16F81B49F16064