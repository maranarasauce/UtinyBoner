// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SDK/GibSkinMAS"
{
	Properties
	{
		[NoScaleOffset]_MainTex("Main Texture", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
		[NoScaleOffset]_BumpMap("Normal", 2D) = "bump" {}
		[NoScaleOffset]_MetallicGlossMap("MAS Metallic", 2D) = "white" {}
		[NoScaleOffset][Header(Bloody Properties)]_BloodyTex("BloodyTex", 2D) = "white" {}
		_BloodyColor("BloodyColor", Color) = (1,1,1,0.5607843)
		_BloodyTexScale("Bloody Tex Scaling", Float) = 1
		[NoScaleOffset][Normal]_BloodyNormal("BloodyNormal", 2D) = "bump" {}
		_BloodyNormalScale("Bloody Normal Scale", Float) = 1
		_BloodyMetallic("BloodyMetallic", Range( 0 , 1)) = 0
		_BloodySmoothness("BloodySmoothness", Range( 0 , 1)) = 0
		[HideInInspector][PerRendererData]_NumberOfElipsoids("NumberOfElipsoids", Int) = 0
		[HideInInspector][PerRendererData]_NumberOfHits("Number Of Hits", Int) = 0
		_Power("Power", Float) = 0.25
		[NoScaleOffset]_FluorescenceMap("Fluorescence Map", 2D) = "black" {}
		_Absorbance("Absorbance", Color) = (0.469,0.636,0.832,1)
		_DetailAlbedoMap("Detail Albedo Map", 2D) = "gray" {}
		[NoScaleOffset]_DetailNormalMap("Detail Normal Map", 2D) = "bump" {}
		_DetailNormalMapScale("Detail Normal Map Scale", Float) = 1
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
				float4 ase_texcoord2 : TEXCOORD2;

				#if ( S_OVERRIDE_LIGHTMAP || LIGHTMAP_ON || DYNAMICLIGHTMAP_ON )
					#if ( DYNAMICLIGHTMAP_ON )
						centroid float4 vLightmapUV : TEXCOORD3;
					#else
						centroid float2 vLightmapUV : TEXCOORD3;
					#endif
				#endif
			};

			uniform sampler2D _BloodyTex;
			uniform float _BloodyTexScale;
			uniform float4 _BloodyColor;
			uniform sampler2D _MainTex;
			uniform float4 _Color;
			uniform sampler2D _DetailAlbedoMap;
			uniform float4 _DetailAlbedoMap_ST;
			uniform float4x4 EllipsoidPosArray[128];
			uniform int _NumberOfHits;
			uniform float _Power;
			uniform float4x4 _ElipsoidMatrices[1];
			uniform int _NumberOfElipsoids;
			uniform sampler2D _BloodyNormal;
			uniform float _BloodyNormalScale;
			uniform sampler2D _BumpMap;
			uniform float _DetailNormalMapScale;
			uniform sampler2D _DetailNormalMap;
			uniform float _BloodyMetallic;
			uniform float _BloodySmoothness;
			uniform sampler2D _MetallicGlossMap;
			uniform sampler2D _FluorescenceMap;
			uniform float4 _Absorbance;
			float MyCustomExpression280( float4x4 Ellipsoids , float3 Posespace , int LoopNumber )
			{
				 float HitDistance = 1;
				for ( int i = 0; i <LoopNumber; i++ ){
				float3 LocalPosP = Posespace - EllipsoidPosArray[i][3].xyz;
				HitDistance =  min( HitDistance, clamp(  distance( mul( LocalPosP , EllipsoidPosArray[i] ) , float3( 0,0,0 ) ), 0 ,1)  );
				}
				return HitDistance;
			}
			
			float MyCustomExpression245( float4x4 Ellipsoids , float3 Posespace , int LoopNumber )
			{
				 float HitDistance = 1;
				for ( int i = 0; i <LoopNumber; i++ ){
				 HitDistance *= clamp(distance( mul( float4( ( Posespace - (Ellipsoids[0][3]) ) , 0.0 ), Ellipsoids[0] ) , float3( 0,0,0 ) ), 0 ,1);
				}
				return HitDistance;
			}
			

			//Vertex Shader
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f,o);
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v,o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				o.ase_texcoord1.xyz = v.texcoord1.xyzw.xyz;
				o.ase_texcoord2.xy = v.texcoord.xyzw.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.w = 0;
				o.ase_texcoord2.zw = 0;

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
				float3 uv15 = i.ase_texcoord1.xyz;
				uv15.xy = i.ase_texcoord1.xyz.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_74_0 = (( uv15 / _BloodyTexScale )).xy;
				float4 tex2DNode73 = tex2D( _BloodyTex, temp_output_74_0 );
				float4 lerpResult130 = lerp( ( tex2DNode73.r * _BloodyColor ) , _BloodyColor , _BloodyColor.a);
				float2 uv_MainTex64 = i.ase_texcoord2.xy;
				float2 uv_DetailAlbedoMap = i.ase_texcoord2.xy * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
				float4x4 Ellipsoids280 = EllipsoidPosArray[0];
				float3 Posespace280 = uv15;
				int LoopNumber280 = _NumberOfHits;
				float localMyCustomExpression280 = MyCustomExpression280( Ellipsoids280 , Posespace280 , LoopNumber280 );
				float MessuredDistance169 = localMyCustomExpression280;
				float clampResult97 = clamp( ( ( pow( MessuredDistance169 , _Power ) * 2.0 ) - 1.0 ) , 0.0 , 1.0 );
				float4x4 Ellipsoids245 = _ElipsoidMatrices[0];
				float3 uv1181 = i.ase_texcoord1.xyz;
				uv1181.xy = i.ase_texcoord1.xyz.xy * float2( 1,1 ) + float2( 0,0 );
				float3 Posespace245 = uv1181;
				int LoopNumber245 = _NumberOfElipsoids;
				float localMyCustomExpression245 = MyCustomExpression245( Ellipsoids245 , Posespace245 , LoopNumber245 );
				float CutoutEllipsoidDistance206 = localMyCustomExpression245;
				float clampResult210 = clamp( CutoutEllipsoidDistance206 , 0.0 , 1.0 );
				float3 break238 = ( abs( i.vNormalWs.xyz ) * float3( 1,1,1 ) );
				float2 temp_output_76_0 = (( uv15 / _BloodyTexScale )).yz;
				float2 temp_output_78_0 = (( uv15 / _BloodyTexScale )).xz;
				float blendOpSrc125 = ( clampResult97 * clampResult210 );
				float blendOpDest125 = ( ( ( tex2DNode73.r * break238.z ) + ( break238.x * tex2D( _BloodyTex, temp_output_76_0 ).r ) + ( break238.y * tex2D( _BloodyTex, temp_output_78_0 ).r ) ) / 3.0 );
				float Hits166 = ( saturate( (( blendOpSrc125 > 0.5 ) ? ( blendOpDest125 / ( ( 1.0 - blendOpSrc125 ) * 2.0 ) ) : ( 1.0 - ( ( ( 1.0 - blendOpDest125 ) * 0.5 ) / blendOpSrc125 ) ) ) ));
				float4 lerpResult57 = lerp( lerpResult130 , ( tex2D( _MainTex, uv_MainTex64 ) * _Color * ( tex2D( _DetailAlbedoMap, uv_DetailAlbedoMap ) * unity_ColorSpaceDouble ) ) , round( Hits166 ));
				
				float2 uv_BumpMap80 = i.ase_texcoord2.xy;
				float2 uv0_DetailAlbedoMap = i.ase_texcoord2.xy * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
				float3 lerpResult129 = lerp( ( ( UnpackScaleNormal( tex2D( _BloodyNormal, temp_output_74_0 ), _BloodyNormalScale ) + UnpackScaleNormal( tex2D( _BloodyNormal, temp_output_76_0 ), _BloodyNormalScale ) + UnpackScaleNormal( tex2D( _BloodyNormal, temp_output_78_0 ), _BloodyNormalScale ) ) / float3( 3,3,3 ) ) , BlendNormals( UnpackNormal( tex2D( _BumpMap, uv_BumpMap80 ) ) , UnpackScaleNormal( tex2D( _DetailNormalMap, uv0_DetailAlbedoMap ), _DetailNormalMapScale ) ) , Hits166);
				
				float3 appendResult300 = (float3(_BloodyMetallic , 1.0 , _BloodySmoothness));
				float2 uv_MetallicGlossMap133 = i.ase_texcoord2.xy;
				float4 lerpResult132 = lerp( float4( appendResult300 , 0.0 ) , tex2D( _MetallicGlossMap, uv_MetallicGlossMap133 ) , Hits166);
				float4 break136 = lerpResult132;
				float3 temp_cast_2 = (break136.r).xxx;
				
				float clampResult143 = clamp( ( MessuredDistance169 * 1.5 ) , 0.0 , 1.0 );
				float smoothstepResult289 = smoothstep( 0.2 , 0.8 , clampResult143);
				float temp_output_297_0 = ( break136.g * smoothstepResult289 );
				
				float2 uv_FluorescenceMap301 = i.ase_texcoord2.xy;
				


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


				float3 Albedo = lerpResult57.rgb;
				float3 Normal = lerpResult129;  //vNormalTs
				float3 Emission = fixed3(0,0,0);
				float Metallic = temp_cast_2;
				float Roughness = 1 - saturate( break136.b );
				float Retroreflective = 0;
				float AnisotropicDirection = 0;
				float AnisotropicRatio = 1;
				float DiffuseOcclusion = temp_output_297_0;
				float SpecularOcclusion = temp_output_297_0;
				float Alpha = 1;
				float Cutoff = 1;
				float3 Fluorescence = tex2D( _FluorescenceMap, uv_FluorescenceMap301 ).rgb;
				float4 Absorbance = _Absorbance;
 		

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
Version=16600
1948;2079;1524;832;-738.4376;-472.3672;1.098153;True;True
Node;AmplifyShaderEditor.CommentaryNode;165;-157.8962,-2541.567;Float;False;2311.296;1928.043;Comment;46;48;89;88;86;99;76;74;78;104;72;75;77;106;73;156;109;157;97;125;47;126;96;160;162;163;159;161;127;166;169;130;174;175;176;209;210;211;214;215;239;240;241;266;298;299;300;Posespace Hits;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;48;-107.8962,-2045.979;Float;False;685.0583;457.7841;Posspace impacts;5;38;36;31;5;280;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;89;225.1385,-2208.598;Float;False;Property;_BloodyTexScale;Bloody Tex Scaling;6;0;Create;False;0;0;False;0;1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;236;1091.344,-2897.511;Float;False;267;229;Comment;1;234;Replace with Pose normal;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;5;-57.89629,-1995.979;Float;False;1;-1;3;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;234;1141.344,-2847.511;Float;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GlobalArrayNode;36;-55.12887,-1726.196;Float;False;EllipsoidPosArray;0;128;3;False;False;0;1;False;Object;-1;4;0;INT;0;False;2;INT;0;False;1;INT;0;False;3;INT;0;False;1;FLOAT4x4;0
Node;AmplifyShaderEditor.IntNode;38;-46.94784,-1826.057;Float;False;Property;_NumberOfHits;Number Of Hits;12;2;[HideInInspector];[PerRendererData];Create;True;0;0;False;0;0;0;0;1;INT;0
Node;AmplifyShaderEditor.CommentaryNode;207;-1008.781,-261.4375;Float;False;2002.218;639.0782;Comment;9;189;187;188;246;193;206;190;183;179;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;88;496.1389,-2227.598;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.AbsOpNode;235;1384.895,-2901.806;Float;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;183;-595.6402,7.407621;Float;False;241;210;Posespace;1;181;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RelayNode;86;666.139,-2235.298;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CustomExpressionNode;280;293.9821,-1851.512;Float;False; float HitDistance = 1@$$for ( int i = 0@ i <LoopNumber@ i++ ){$$float3 LocalPosP = Posespace - EllipsoidPosArray[i][3].xyz@$$HitDistance =  min( HitDistance, clamp(  distance( mul( LocalPosP , EllipsoidPosArray[i] ) , float3( 0,0,0 ) ), 0 ,1)  )@$$}$$return HitDistance@;1;False;3;True;Ellipsoids;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;In;sdads;Float;True;Posespace;FLOAT3;0,0,0;In;;Float;True;LoopNumber;INT;0;In;;Float;My Custom Expression;True;False;0;3;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;2;INT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;169;591.1342,-1807.634;Float;False;MessuredDistance;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;78;890.591,-2112.644;Float;False;FLOAT2;0;2;2;2;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;181;-583.6402,57.40746;Float;False;1;-1;3;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;72;1053.942,-2491.567;Float;True;Property;_BloodyTex;BloodyTex;4;1;[NoScaleOffset];Create;True;0;0;False;1;Header(Bloody Properties);None;b16415f2f06fcb14cae4d345fda40d45;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SwizzleNode;76;882.8132,-2192.43;Float;False;FLOAT2;1;2;2;2;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;99;689.1649,-1698.159;Float;False;Property;_Power;Power;13;0;Create;True;0;0;False;0;0.25;0.54;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;246;-986.5919,-73.3175;Float;False;Property;_NumberOfElipsoids;NumberOfElipsoids;11;2;[HideInInspector];[PerRendererData];Create;True;0;0;False;0;0;0;0;1;INT;0
Node;AmplifyShaderEditor.SwizzleNode;74;883.924,-2273.549;Float;False;FLOAT2;0;1;2;2;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GlobalArrayNode;193;-958.7809,-190.1823;Float;False;_ElipsoidMatrices;0;1;3;False;False;0;1;False;Object;-1;4;0;INT;0;False;2;INT;0;False;1;INT;0;False;3;INT;0;False;1;FLOAT4x4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;244;1763.711,-2858.661;Float;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;1,1,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;77;1422.863,-1999.299;Float;True;Property;_TextureSample2;Texture Sample 2;6;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;238;1891.984,-2643.984;Float;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SamplerNode;75;1422.865,-2201.321;Float;True;Property;_TextureSample1;Texture Sample 1;6;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;73;1421.753,-2402.451;Float;True;Property;_TextureSample0;Texture Sample 0;6;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CustomExpressionNode;245;-94.83571,-387.2128;Float;False; float HitDistance = 1@$$for ( int i = 0@ i <LoopNumber@ i++ ){$$ HitDistance *= clamp(distance( mul( float4( ( Posespace - (Ellipsoids[0][3]) ) , 0.0 ), Ellipsoids[0] ) , float3( 0,0,0 ) ), 0 ,1)@$$$}$$return HitDistance@$;1;False;3;True;Ellipsoids;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;In;;Float;True;Posespace;FLOAT3;0,0,0;In;;Float;True;LoopNumber;INT;0;In;;Float;My Custom Expression;True;False;0;3;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;2;INT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;104;983.454,-1807.24;Float;False;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;240;1730.419,-2229.915;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;241;1738.598,-2120.524;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;239;1734.958,-2331.246;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;106;1165.454,-1783.24;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;206;687.2795,-173.3307;Float;False;CutoutEllipsoidDistance;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;209;974.8678,-1408.739;Float;False;206;CutoutEllipsoidDistance;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;109;1358.353,-1767.411;Float;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;156;1979.695,-2251.418;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;157;1991.375,-2085.87;Float;False;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;210;1269.605,-1407.863;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;97;1440.123,-1656.383;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;242;2159.914,-1924.196;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;211;1488.107,-1460.107;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;299;1479.49,-717.2585;Float;False;Property;_BloodySmoothness;BloodySmoothness;10;0;Create;True;0;0;False;0;0;0.822;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;266;659.4388,-917.5654;Float;False;Property;_BloodyNormalScale;Bloody Normal Scale;8;0;Create;True;0;0;False;0;1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;298;1465.741,-849.4649;Float;False;Property;_BloodyMetallic;BloodyMetallic;9;0;Create;True;0;0;False;0;0;0.292;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;125;1686.64,-1472.446;Float;False;VividLight;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;283;2901.897,282.5888;Float;False;877.6423;689.9533;Center hole spec;5;289;143;142;170;296;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexturePropertyNode;159;644.4178,-1113.713;Float;True;Property;_BloodyNormal;BloodyNormal;7;2;[NoScaleOffset];[Normal];Create;True;0;0;False;0;None;None;True;bump;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SamplerNode;127;1110.37,-1239.982;Float;True;Property;_Bloody;Bloody;12;0;Create;True;0;0;False;0;None;a96581eb69cfd2e4b93e56eac104d0b0;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;177;1668.231,-223.648;Float;False;525.8;682.4663;Variables;4;133;80;64;263;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;160;1105.907,-1043.509;Float;True;Property;_TextureSample4;Texture Sample 4;15;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;166;1768.956,-1226.666;Float;False;Hits;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;176;1922.182,-805.6692;Float;False;204;160;Specular;1;173;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;47;1643.43,-1761.654;Float;False;Property;_BloodyColor;BloodyColor;5;0;Create;True;0;0;False;0;1,1,1,0.5607843;0.2358489,0.02558741,0.02558741,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;161;1105.907,-849.1912;Float;True;Property;_TextureSample5;Texture Sample 5;15;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;170;2900.897,332.5887;Float;False;169;MessuredDistance;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;300;1765.056,-783.8908;Float;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;142;3197.946,354.8798;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;1.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorSpaceDouble;315;2055.692,584.2145;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;162;1501.055,-1008.169;Float;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;133;1722.14,31.82836;Float;True;Property;_MetallicGlossMap;MAS Metallic;3;1;[NoScaleOffset];Create;False;0;0;False;0;None;e239f45e25c9c4143935b5002c53041b;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RelayNode;173;1974.071,-750.0019;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;126;1984.4,-1795.603;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;310;1726.111,511.4778;Float;True;Property;_DetailAlbedoMap;Detail Albedo Map;16;0;Create;True;0;0;False;0;None;ef034115a2ace0842806de248f35b8a8;True;0;False;gray;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;313;1371.552,672.389;Float;False;0;310;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;312;1378.037,788.6384;Float;False;Property;_DetailNormalMapScale;Detail Normal Map Scale;18;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;167;1974.252,-399.9579;Float;False;166;Hits;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;311;1723.037,738.6382;Float;True;Property;_DetailNormalMap;Detail Normal Map;17;1;[NoScaleOffset];Create;True;0;0;False;0;None;cd7097a11da6d2c4f8e99e7b1838111e;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;132;2484.026,-174.4643;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;175;1921.403,-979.554;Float;False;204.0001;160;Normal;1;172;;0.5,0.5,1,1;0;0
Node;AmplifyShaderEditor.ClampOpNode;143;3381.407,343.7697;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;130;1978.332,-1435.467;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;174;1921.389,-1149.252;Float;False;204;160;Bloody;1;171;;1,0.0990566,0.0990566,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;316;2269.956,472.029;Float;True;2;2;0;COLOR;0.4622642,0.4622642,0.4622642,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;80;1740.551,258.6185;Float;True;Property;_BumpMap;Normal;2;1;[NoScaleOffset];Create;False;0;0;False;0;None;7d4a82e07e20f9148bc309fcc5364454;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;264;1748.291,-351.0662;Float;False;Property;_Color;Color;1;0;Create;True;0;0;False;0;1,1,1,1;1,1,1,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;163;1645.033,-1010.4;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;3,3,3;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;64;1718.231,-173.648;Float;True;Property;_MainTex;Main Texture;0;1;[NoScaleOffset];Create;False;0;0;False;0;None;22ac4e5b4642a6b41bc5bcdf74ddf9f7;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RelayNode;172;1974.192,-921.6085;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BlendNormalsNode;314;2050.41,319.5367;Float;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SmoothstepOpNode;289;3397.505,505.8646;Float;False;3;0;FLOAT;0;False;1;FLOAT;0.2;False;2;FLOAT;0.8;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;263;2051.843,-170.4326;Float;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RoundOpNode;227;2306.512,-303.3094;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;171;1971.389,-1099.252;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;136;2813.515,-94.3737;Float;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.LerpOp;129;2489.134,81.85724;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;214;1481.792,-1351.986;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;189;-11.77777,-72.55127;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClampOpNode;219;3635.158,-718.4578;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.VectorFromMatrixNode;179;-703.3745,236.1781;Float;False;Row;3;1;0;FLOAT4x4;1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;296;2917.594,585.9684;Float;False;166;Hits;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;57;2484.747,-304.4061;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendOpsNode;213;2298.838,-1344.29;Float;False;VividLight;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RoundOpNode;194;3400.147,-748.3048;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;190;297.889,-89.62183;Float;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;308;4845.079,837.515;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CustomExpressionNode;43;1469.646,-202.7031;Float;False;  return tex2D(_MainTex, UV)@;4;False;1;True;UV;FLOAT2;0,0;In;;Float;MainTex 2DSampler;True;False;0;1;0;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CustomExpressionNode;49;1495.391,-98.06308;Float;False;  return tex2D(_BumpMap, UV)@;4;False;1;True;UV;FLOAT2;0,0;In;;Float;Normal 2DSampler;True;False;0;1;0;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ClampOpNode;202;4074.162,-866.9605;Float;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT4;1,1,1,1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SwitchByFaceNode;279;4329.445,-1037.861;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;297;3870.325,168.4551;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;42;1113.319,-130.049;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwizzleNode;188;-498.5367,231.1391;Float;False;FLOAT3;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CustomExpressionNode;31;332.162,-2011.43;Float;False; float HitDistance = 1@$for ( int i = 0@ i <In0@ i++ ){$ HitDistance *= clamp(  distance( Posespace.xyz , EllipsoidPosArray[i].xyz) / EllipsoidPosArray[i].w, 0,1  )@$}$$//EllipsoidPosArray[i]$$return HitDistance@$;1;False;3;True;In0;INT;1;In;;Float;True;Posespace;FLOAT3;0,0,0;In;;Float;True;PosArray;FLOAT4;0,0,0,0;In;;Float;Distance Loop;True;False;0;3;0;INT;1;False;1;FLOAT3;0,0,0;False;2;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;215;1479.792,-1259.986;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;195;3691.445,-889.9479;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;187;-174.1741,46.00196;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;228;3909.407,-746.5067;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ColorNode;304;4134.759,851.6693;Float;False;Property;_Absorbance;Absorbance;15;0;Create;True;0;0;False;0;0.469,0.636,0.832,1;0.587,0.783,0.867,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CustomExpressionNode;50;1501.916,2.254181;Float;False;  return tex2D(_OcclusionMap, UV)@;4;False;1;True;UV;FLOAT2;0,0;In;;Float;AO 2DSampler;True;False;0;1;0;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RelayNode;230;2579.295,-1302.056;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;301;3901.242,602.0788;Float;True;Property;_FluorescenceMap;Fluorescence Map;14;1;[NoScaleOffset];Create;True;0;0;False;0;None;a2586b221d2009e44906cd53889ec5f5;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;96;772.1591,-1909.448;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;281;4312.964,-4.677668;Float;False;True;2;Float;ASEMaterialInspector;0;11;SLZ/GibSkinMAS;1f6ac94e27bd0934ab97faa6217ad58e;True;VRBase;0;0;VRBase;15;False;False;False;False;False;False;False;False;False;True;1;RenderType=Opaque=RenderType;False;0;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;True;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;2;LightMode=ForwardBase;PassFlags=OnlyDirectional;True;2;0;;0;0;Standard;0;0;1;True;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;11;FLOAT;0;False;12;FLOAT3;0,0,0;False;13;FLOAT4;0,0,0,0;False;14;FLOAT3;0,0,0;False;0
WireConnection;88;0;5;0
WireConnection;88;1;89;0
WireConnection;235;0;234;0
WireConnection;86;0;88;0
WireConnection;280;0;36;0
WireConnection;280;1;5;0
WireConnection;280;2;38;0
WireConnection;169;0;280;0
WireConnection;78;0;86;0
WireConnection;76;0;86;0
WireConnection;74;0;86;0
WireConnection;244;0;235;0
WireConnection;77;0;72;0
WireConnection;77;1;78;0
WireConnection;238;0;244;0
WireConnection;75;0;72;0
WireConnection;75;1;76;0
WireConnection;73;0;72;0
WireConnection;73;1;74;0
WireConnection;245;0;193;0
WireConnection;245;1;181;0
WireConnection;245;2;246;0
WireConnection;104;0;169;0
WireConnection;104;1;99;0
WireConnection;240;0;238;0
WireConnection;240;1;75;1
WireConnection;241;0;238;1
WireConnection;241;1;77;1
WireConnection;239;0;73;1
WireConnection;239;1;238;2
WireConnection;106;0;104;0
WireConnection;206;0;245;0
WireConnection;109;0;106;0
WireConnection;156;0;239;0
WireConnection;156;1;240;0
WireConnection;156;2;241;0
WireConnection;157;0;156;0
WireConnection;210;0;209;0
WireConnection;97;0;109;0
WireConnection;242;0;157;0
WireConnection;211;0;97;0
WireConnection;211;1;210;0
WireConnection;125;0;211;0
WireConnection;125;1;242;0
WireConnection;127;0;159;0
WireConnection;127;1;74;0
WireConnection;127;5;266;0
WireConnection;160;0;159;0
WireConnection;160;1;76;0
WireConnection;160;5;266;0
WireConnection;166;0;125;0
WireConnection;161;0;159;0
WireConnection;161;1;78;0
WireConnection;161;5;266;0
WireConnection;300;0;298;0
WireConnection;300;2;299;0
WireConnection;142;0;170;0
WireConnection;162;0;127;0
WireConnection;162;1;160;0
WireConnection;162;2;161;0
WireConnection;173;0;300;0
WireConnection;126;0;73;1
WireConnection;126;1;47;0
WireConnection;311;1;313;0
WireConnection;311;5;312;0
WireConnection;132;0;173;0
WireConnection;132;1;133;0
WireConnection;132;2;167;0
WireConnection;143;0;142;0
WireConnection;130;0;126;0
WireConnection;130;1;47;0
WireConnection;130;2;47;4
WireConnection;316;0;310;0
WireConnection;316;1;315;0
WireConnection;163;0;162;0
WireConnection;172;0;163;0
WireConnection;314;0;80;0
WireConnection;314;1;311;0
WireConnection;289;0;143;0
WireConnection;263;0;64;0
WireConnection;263;1;264;0
WireConnection;263;2;316;0
WireConnection;227;0;167;0
WireConnection;171;0;130;0
WireConnection;136;0;132;0
WireConnection;129;0;172;0
WireConnection;129;1;314;0
WireConnection;129;2;167;0
WireConnection;214;0;210;0
WireConnection;189;0;187;0
WireConnection;189;1;193;0
WireConnection;219;0;194;0
WireConnection;179;0;193;0
WireConnection;57;0;171;0
WireConnection;57;1;263;0
WireConnection;57;2;227;0
WireConnection;213;0;215;0
WireConnection;213;1;242;0
WireConnection;194;0;230;0
WireConnection;190;0;189;0
WireConnection;43;0;42;0
WireConnection;49;0;42;0
WireConnection;202;0;195;0
WireConnection;279;0;202;0
WireConnection;297;0;136;1
WireConnection;297;1;289;0
WireConnection;188;0;179;0
WireConnection;31;0;38;0
WireConnection;31;1;5;0
WireConnection;31;2;36;0
WireConnection;215;0;214;0
WireConnection;195;3;219;0
WireConnection;187;0;181;0
WireConnection;187;1;188;0
WireConnection;228;0;195;0
WireConnection;228;1;219;0
WireConnection;50;0;42;0
WireConnection;230;0;213;0
WireConnection;96;0;169;0
WireConnection;96;1;73;1
WireConnection;281;0;57;0
WireConnection;281;1;129;0
WireConnection;281;3;136;0
WireConnection;281;4;136;2
WireConnection;281;8;297;0
WireConnection;281;9;297;0
WireConnection;281;12;301;0
WireConnection;281;13;304;0
ASEEND*/
//CHKSM=2E8B99654E60FC16DDE6E05482BBD97EA3F88D08