// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SLZ/VR_Triplanar"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		g_flFresnelFalloff("Fresnel Falloff Scaler", Range( 0 , 2)) = 1
		[HideInInspector]g_flCubeMapScalar("Cubemap Scalar", Range( 0 , 2)) = 1
		_BumpMap("BumpMap", 2D) = "bump" {}
		[Toggle(S_RECEIVE_SHADOWS)] _Keyword0("Receive Shadows", Float) = 1
		_NormalScale("Normal Scale", Float) = 0
		_WorldScale("World Scale", Float) = 1
		_Blend("Blend", Range( 0 , 0.98)) = 0.5
		_Roughness("Roughness", Range( 0 , 1)) = 0
		_Metallic("Metallic", Range( 0 , 1)) = 0
		_Color("Color", Color) = (1,1,1,1)
	}
	
	SubShader
	{
		Tags { "RenderType"="Opaque" "LightMode"="ForwardBase" }
		LOD 100
		CGINCLUDE
		#pragma target 3.5
		ENDCG
		Blend Off
		Cull Back
		ColorMask RGBA
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
		
		

		Pass
		{
			Name "Unlit"
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "vr_utils.cginc"
			#include "UnityStandardUtils.cginc"
			#include "vr_StandardInput.cginc"
			#include "vr_lighting.cginc"
			#include "vr_fog.cginc"
			#pragma multi_compile _ D_VALVE_SHADOWING_POINT_LIGHTS
			#pragma shader_feature D_CASTSHADOW
			#pragma shader_feature S_RECEIVE_SHADOWS
			#include "vr_matrix_palette_skinning.cginc"
			#pragma multi_compile_fwdbase
			#pragma multi_compile _ D_VALVE_FOG
			#include "vr_zAO.cginc"
			#pragma multi_compile _ Z_SHAPEAO


			struct appdata
			{
				float4 vertex : POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				UNITY_VERTEX_OUTPUT_STEREO
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
			};

			uniform sampler2D _Albedo;
			uniform float _WorldScale;
			uniform float _Blend;
			uniform sampler2D _Normal;
			uniform float _NormalScale;
			uniform float _Roughness;
			inline float4 TriplanarSamplingSF( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float tilling, float3 normalScale, float3 index )
			{
				float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
				projNormal /= projNormal.x + projNormal.y + projNormal.z;
				float3 nsign = sign( worldNormal );
				half4 xNorm; half4 yNorm; half4 zNorm;
				xNorm = ( tex2D( topTexMap, tilling * worldPos.zy * float2( nsign.x, 1.0 ) ) );
				yNorm = ( tex2D( topTexMap, tilling * worldPos.xz * float2( nsign.y, 1.0 ) ) );
				zNorm = ( tex2D( topTexMap, tilling * worldPos.xy * float2( -nsign.z, 1.0 ) ) );
				return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
			}
			
			inline float3 TriplanarSamplingSNF( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float tilling, float3 normalScale, float3 index )
			{
				float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
				projNormal /= projNormal.x + projNormal.y + projNormal.z;
				float3 nsign = sign( worldNormal );
				half4 xNorm; half4 yNorm; half4 zNorm;
				xNorm = ( tex2D( topTexMap, tilling * worldPos.zy * float2( nsign.x, 1.0 ) ) );
				yNorm = ( tex2D( topTexMap, tilling * worldPos.xz * float2( nsign.y, 1.0 ) ) );
				zNorm = ( tex2D( topTexMap, tilling * worldPos.xy * float2( -nsign.z, 1.0 ) ) );
				xNorm.xyz = half3( UnpackScaleNormal( xNorm, normalScale.y ).xy * float2( nsign.x, 1.0 ) + worldNormal.zy, worldNormal.x ).zyx;
				yNorm.xyz = half3( UnpackScaleNormal( yNorm, normalScale.x ).xy * float2( nsign.y, 1.0 ) + worldNormal.xz, worldNormal.y ).xzy;
				zNorm.xyz = half3( UnpackScaleNormal( zNorm, normalScale.y ).xy * float2( -nsign.z, 1.0 ) + worldNormal.xy, worldNormal.z ).xyz;
				return normalize( xNorm.xyz * projNormal.x + yNorm.xyz * projNormal.y + zNorm.xyz * projNormal.z );
			}
			
			float4x4 ZeroLighting( float3 vPositionWs , float3 vNormalWs , float3 vTangentUWs , float3 vTangentVWs , float3 vRoughness , float3 vReflectance , float g_flFresnelExponent , float4 vLightmapUV , float Dotfresnel , float CubeMapScalar , float g_flFresnelFalloff )
			{
				float4x4 packlighting;
				LightingTerms_t o;
				o.vDiffuse = float4( 0.0, 0.0, 0.0 , 0.0);
				o.vSpecular = float3( 0.0, 0.0, 0.0 );
				o.vIndirectDiffuse = float3( 0.0, 0.0, 0.0 );
				o.vIndirectSpecular = float3( 0.0, 0.0, 0.0 );
				o.vTransmissiveSunlight = float3( 0.0, 0.0, 0.0 );
				o = ComputeLighting(vPositionWs.xyz, vNormalWs.xyz, vTangentUWs.xyz, vTangentVWs.xyz, vRoughness.xyz, vReflectance.rgb, g_flFresnelExponent, vLightmapUV.xyzw, Dotfresnel);
				packlighting = float4x4(o.vDiffuse.rgba, o.vSpecular.rgb, o.vIndirectDiffuse.rgb, o.vIndirectSpecular.rgb, o.vTransmissiveSunlight.rgb);
				return packlighting;
			}
			
			float AO( float3 posWs , float3 vNormalWs )
			{
				return CalculateShapeAO(posWs,vNormalWs);
			}
			
			float3 MyCustomExpression1_g249( float3 RGBin , float FogMultiplier , float3 PositionWs )
			{
				#if ( D_VALVE_FOG )
				float2 vFogCoords = CalculateFogCoords( PositionWs );
				return ApplyFog( RGBin, vFogCoords.xy, FogMultiplier );
				#else
				return RGBin;
				#endif
			}
			
			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				float3 ase_worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.ase_texcoord.xyz = ase_worldPos;
				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord1.xyz = ase_worldNormal;
				float3 ase_worldTangent = UnityObjectToWorldDir(v.ase_tangent);
				o.ase_texcoord2.xyz = ase_worldTangent;
				float ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord3.xyz = ase_worldBitangent;
				
				o.ase_texcoord4.xy = v.ase_texcoord1.xy;
				o.ase_texcoord4.zw = v.ase_texcoord2.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.w = 0;
				o.ase_texcoord1.w = 0;
				o.ase_texcoord2.w = 0;
				o.ase_texcoord3.w = 0;
				
				v.vertex.xyz +=  float3(0,0,0) ;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				fixed4 finalColor;
				float temp_output_80_0 = ( 1.0 / _WorldScale );
				float temp_output_84_0 = ( ( 1.0 - pow( _Blend , 0.2 ) ) * 100.0 );
				float3 ase_worldPos = i.ase_texcoord.xyz;
				float3 ase_worldNormal = i.ase_texcoord1.xyz;
				float4 triplanar71 = TriplanarSamplingSF( _MainTex, ase_worldPos, ase_worldNormal, temp_output_84_0, temp_output_80_0, 1.0, 0 );
				float3 vPositionWs13_g250 = ase_worldPos;
				float3 ase_worldTangent = i.ase_texcoord2.xyz;
				float3 ase_worldBitangent = i.ase_texcoord3.xyz;
				float3x3 ase_worldToTangent = float3x3( ase_worldTangent, ase_worldBitangent, ase_worldNormal );
				float3 triplanar74 = TriplanarSamplingSNF( _BumpMap, ase_worldPos, ase_worldNormal, temp_output_84_0, temp_output_80_0, _NormalScale, 0 );
				float3 tanTriplanarNormal74 = mul( ase_worldToTangent, triplanar74 );
				float3 temp_output_15_0_g250 = tanTriplanarNormal74;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 tanNormal11_g250 = temp_output_15_0_g250;
				float3 worldNormal11_g250 = normalize( float3(dot(tanToWorld0,tanNormal11_g250), dot(tanToWorld1,tanNormal11_g250), dot(tanToWorld2,tanNormal11_g250)) );
				float3 vNormalWs13_g250 = worldNormal11_g250;
				float3 vTangentUWs13_g250 = ase_worldTangent;
				float3 vTangentVWs13_g250 = ase_worldBitangent;
				float3 appendResult27_g250 = (float3(_Roughness , 0.0 , 0.0));
				float3 vRoughness13_g250 = appendResult27_g250;
				float3 temp_cast_1 = (_Metallic).xxx;
				float3 vReflectance13_g250 = temp_cast_1;
				float g_flFresnelExponent13_g250 = 5.0;
				float2 uv8_g250 = i.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float2 uv78_g250 = i.ase_texcoord4.zw * float2( 1,1 ) + float2( 0,0 );
				float4 appendResult55_g250 = (float4(( ( uv8_g250 * (unity_LightmapST).xy ) + (unity_LightmapST).zw ) , ( ( uv78_g250 * (unity_DynamicLightmapST).xy ) + (unity_DynamicLightmapST).zw )));
				float4 vLightmapUV13_g250 = appendResult55_g250;
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(ase_worldPos);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float dotResult57_g250 = dot( worldNormal11_g250 , ase_worldViewDir );
				float Dotfresnel13_g250 = dotResult57_g250;
				float CubeMapScalar13_g250 = g_flCubeMapScalar;
				float g_flFresnelFalloff13_g250 = g_flFresnelFalloff;
				float4x4 localZeroLighting13_g250 = ZeroLighting( vPositionWs13_g250 , vNormalWs13_g250 , vTangentUWs13_g250 , vTangentVWs13_g250 , vRoughness13_g250 , vReflectance13_g250 , g_flFresnelExponent13_g250 , vLightmapUV13_g250 , Dotfresnel13_g250 , CubeMapScalar13_g250 , g_flFresnelFalloff13_g250 );
				float4x4 break19_g250 = localZeroLighting13_g250;
				float3 appendResult21_g250 = (float3(break19_g250[ 0 ][ 0 ] , break19_g250[ 0 ][ 1 ] , break19_g250[ 0 ][ 2 ]));
				float3 appendResult22_g250 = (float3(break19_g250[ 1 ][ 0 ] , break19_g250[ 1 ][ 1 ] , break19_g250[ 1 ][ 2 ]));
				float3 appendResult23_g250 = (float3(break19_g250[ 1 ][ 3 ] , break19_g250[ 2 ][ 0 ] , break19_g250[ 2 ][ 1 ]));
				float3 appendResult24_g250 = (float3(break19_g250[ 2 ][ 2 ] , break19_g250[ 2 ][ 3 ] , break19_g250[ 3 ][ 0 ]));
				float3 appendResult25_g250 = (float3(break19_g250[ 3 ][ 1 ] , break19_g250[ 3 ][ 2 ] , break19_g250[ 3 ][ 3 ]));
				float3 temp_output_26_0_g250 = ( appendResult21_g250 + appendResult22_g250 + max( appendResult23_g250 , float3( 0,0,0 ) ) + max( appendResult24_g250 , float3( 0,0,0 ) ) + max( appendResult25_g250 , float3( 0,0,0 ) ) );
				float3 posWs1_g251 = ase_worldPos;
				float3 tanNormal3_g251 = temp_output_15_0_g250;
				float3 worldNormal3_g251 = float3(dot(tanToWorld0,tanNormal3_g251), dot(tanToWorld1,tanNormal3_g251), dot(tanToWorld2,tanNormal3_g251));
				float3 vNormalWs1_g251 = worldNormal3_g251;
				float localAO1_g251 = AO( posWs1_g251 , vNormalWs1_g251 );
				#ifdef S_RECEIVE_SHADOWS
				float3 staticSwitch81_g250 = ( temp_output_26_0_g250 * localAO1_g251 );
				#else
				float3 staticSwitch81_g250 = temp_output_26_0_g250;
				#endif
				float3 RGBin1_g249 = ( (( _Color * triplanar71 )).rgb * staticSwitch81_g250 );
				float FogMultiplier1_g249 = 1.0;
				float3 PositionWs1_g249 = ase_worldPos;
				float3 localMyCustomExpression1_g249 = MyCustomExpression1_g249( RGBin1_g249 , FogMultiplier1_g249 , PositionWs1_g249 );
				float4 appendResult203 = (float4(localMyCustomExpression1_g249 , 1.0));
				
				
				finalColor = appendResult203;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	Fallback "Valve/vr_standard"
}
/*ASEBEGIN
Version=15406
14;370;1906;1044;529.5088;133.7869;1;True;False
Node;AmplifyShaderEditor.RangedFloatNode;81;-1567.14,496.7822;Float;False;Property;_Blend;Blend;5;0;Create;True;0;0;False;0;0.5;0.625;0;0.98;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;85;-1254.681,502.3393;Float;False;2;0;FLOAT;0;False;1;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;79;-1016.889,180.709;Float;False;Property;_WorldScale;World Scale;4;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;83;-1064.12,503.1776;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;80;-820.8889,162.709;Float;False;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;84;-882.1165,503.6458;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;100;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;72;-1206.367,-21.41104;Float;True;Property;_Albedo;Albedo;0;0;Create;True;0;0;False;0;None;a9f953c7353804247b8c3ed6e1c46a2e;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TriplanarNode;71;-492.2122,-15.36322;Float;True;Spherical;World;False;Top Texture 0;_TopTexture0;white;-1;None;Mid Texture 0;_MidTexture0;white;-1;None;Bot Texture 0;_BotTexture0;white;-1;None;Triplanar Sampler;False;9;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;8;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;205;-377.7298,-183.8554;Float;False;Property;_Color;Color;8;0;Fetch;True;0;0;False;0;1,1,1,1;1,1,1,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;76;-885.8028,330.2464;Float;False;Property;_NormalScale;Normal Scale;3;0;Create;True;0;0;False;0;0;2.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;73;-1249.58,261.9078;Float;True;Property;_Normal;Normal;2;0;Create;True;0;0;False;0;None;8f57c003a40aa234d976f44be0cb79ec;True;bump;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TriplanarNode;74;-479.2117,266.9075;Float;True;Spherical;World;True;Top Texture 1;_TopTexture1;white;-1;None;Mid Texture 1;_MidTexture1;white;-1;None;Bot Texture 1;_BotTexture1;white;-1;None;Triplanar Sampler;False;9;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;8;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;107;-414.5548,456.3875;Float;False;Property;_Metallic;Metallic;7;0;Fetch;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;206;-70.92983,-27.85542;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;96;-439.9411,181.0934;Float;False;Property;_Roughness;Roughness;6;0;Create;True;0;0;False;0;0;0.822;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;251;-34.03172,223.1592;Float;False;VRStandardLighting;1;;250;50d6ab72cc2255a42a87b96dcb19e402;0;4;16;FLOAT;0.5;False;17;FLOAT3;0,0,0;False;15;FLOAT3;0,0,1;False;29;FLOAT;5;False;2;FLOAT3;20;FLOAT;79
Node;AmplifyShaderEditor.SwizzleNode;150;95.11405,55.02449;Float;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;325.3791,132.8012;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;1,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;183;654.8911,234.9032;Float;False;Constant;_Float0;Float 0;8;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;202;497.0604,152.9919;Float;False;VRFog;-1;;249;0f36de526ee9ad84d846f9bb0b9b14fe;0;1;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CustomExpressionNode;221;-794.253,-88.4523;Float;False;_MainTex@;1;True;0;My Custom Expression;False;False;0;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;203;815.67,133.3447;Float;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;187;1040.468,135.3327;Float;False;True;2;Float;ASEMaterialInspector;0;1;SLZ/VR_Triplanar;0770190933193b94aaa3065e307002fa;0;0;Unlit;2;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;2;RenderType=Opaque;LightMode=ForwardBase;True;3;0;False;False;False;False;False;False;False;False;False;False;0;Valve/vr_standard;0;0;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;0
WireConnection;85;0;81;0
WireConnection;83;0;85;0
WireConnection;80;1;79;0
WireConnection;84;0;83;0
WireConnection;71;0;72;0
WireConnection;71;3;80;0
WireConnection;71;4;84;0
WireConnection;74;0;73;0
WireConnection;74;8;76;0
WireConnection;74;3;80;0
WireConnection;74;4;84;0
WireConnection;206;0;205;0
WireConnection;206;1;71;0
WireConnection;251;16;96;0
WireConnection;251;17;107;0
WireConnection;251;15;74;0
WireConnection;150;0;206;0
WireConnection;45;0;150;0
WireConnection;45;1;251;20
WireConnection;202;3;45;0
WireConnection;203;0;202;0
WireConnection;203;3;183;0
WireConnection;187;0;203;0
ASEEND*/
//CHKSM=2D098AF2A4E5C19ADF9D9257DFBEB420CB2D2DAF