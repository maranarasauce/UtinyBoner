// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SLZ/VR Terrain"
{
	Properties
	{
		g_flFresnelFalloff("Fresnel Falloff Scaler", Range( 0 , 2)) = 1
		[HideInInspector]g_flCubeMapScalar("Cubemap Scalar", Range( 0 , 2)) = 1
		_Color("Color", Color) = (0,0,0,0)
		_Control("Control", 2D) = "white" {}
		_Splat3("Splat3", 2D) = "white" {}
		_Splat2("Splat2", 2D) = "white" {}
		_Splat1("Splat1", 2D) = "white" {}
		_Splat0("Splat0", 2D) = "white" {}
		_Normal0("Normal0", 2D) = "white" {}
		_Normal1("Normal1", 2D) = "white" {}
		_Normal2("Normal2", 2D) = "white" {}
		_Normal3("Normal3", 2D) = "white" {}
		[Toggle(S_RECEIVE_SHADOWS)] _Keyword0("Receive Shadows", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
	}
	
	SubShader
	{
		Tags { "RenderType"="Opaque" "SplatCount"="4" }
		LOD 100
		CGINCLUDE
		#pragma target 5.0
		ENDCG
		Blend Off
		Cull Back
		ColorMask RGBA
		ZWrite On
		ZTest LEqual
		
		

		Pass
		{
			Name "Main"
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
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
				float3 ase_normal : NORMAL;
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
				float4 ase_texcoord5 : TEXCOORD5;
			};

			uniform sampler2D _Control;
			uniform float4 _Control_ST;
			uniform sampler2D _Splat0;
			uniform float4 _Splat0_ST;
			uniform sampler2D _Splat1;
			uniform float4 _Splat1_ST;
			uniform sampler2D _Splat2;
			uniform float4 _Splat2_ST;
			uniform sampler2D _Splat3;
			uniform float4 _Splat3_ST;
			uniform sampler2D _Normal0;
			uniform sampler2D _Normal1;
			uniform sampler2D _Normal2;
			uniform sampler2D _Normal3;
			float4 MainTex2DSampler120( float2 UV )
			{
				  return tex2D(_MainTex, UV);
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
			
			float3 MyCustomExpression1_g125( float3 RGBin , float FogMultiplier , float3 PositionWs )
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
				o.ase_texcoord1.xyz = ase_worldPos;
				float3 ase_worldTangent = UnityObjectToWorldDir(v.ase_tangent);
				o.ase_texcoord2.xyz = ase_worldTangent;
				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord3.xyz = ase_worldNormal;
				float ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord4.xyz = ase_worldBitangent;
				
				o.ase_texcoord.xy = v.ase_texcoord.xy;
				o.ase_texcoord.zw = v.ase_texcoord1.xy;
				o.ase_texcoord5.xy = v.ase_texcoord2.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.w = 0;
				o.ase_texcoord2.w = 0;
				o.ase_texcoord3.w = 0;
				o.ase_texcoord4.w = 0;
				o.ase_texcoord5.zw = 0;
				
				v.vertex.xyz +=  float3(0,0,0) ;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				fixed4 finalColor;
				float2 uv_Control = i.ase_texcoord.xy * _Control_ST.xy + _Control_ST.zw;
				float4 tex2DNode1 = tex2D( _Control, uv_Control );
				float2 uv_Splat0 = i.ase_texcoord.xy * _Splat0_ST.xy + _Splat0_ST.zw;
				float2 uv_Splat1 = i.ase_texcoord.xy * _Splat1_ST.xy + _Splat1_ST.zw;
				float2 uv_Splat2 = i.ase_texcoord.xy * _Splat2_ST.xy + _Splat2_ST.zw;
				float2 uv_Splat3 = i.ase_texcoord.xy * _Splat3_ST.xy + _Splat3_ST.zw;
				float4 weightedBlendVar10 = tex2DNode1;
				float4 weightedBlend10 = ( weightedBlendVar10.x*tex2D( _Splat0, uv_Splat0 ) + weightedBlendVar10.y*tex2D( _Splat1, uv_Splat1 ) + weightedBlendVar10.z*tex2D( _Splat2, uv_Splat2 ) + weightedBlendVar10.w*tex2D( _Splat3, uv_Splat3 ) );
				float2 uv121 = i.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 UV120 = uv121;
				float4 localMainTex2DSampler120 = MainTex2DSampler120( UV120 );
				float4 lerpResult14 = lerp( localMainTex2DSampler120 , _Color , 0.0);
				float4 lerpResult16 = lerp( weightedBlend10 , lerpResult14 , 0.0);
				float3 ase_worldPos = i.ase_texcoord1.xyz;
				float3 vPositionWs13_g126 = ase_worldPos;
				float4 weightedBlendVar11 = tex2DNode1;
				float4 weightedBlend11 = ( weightedBlendVar11.x*tex2D( _Normal0, uv_Splat0 ) + weightedBlendVar11.y*tex2D( _Normal1, uv_Splat1 ) + weightedBlendVar11.z*tex2D( _Normal2, uv_Splat2 ) + weightedBlendVar11.w*tex2D( _Normal3, uv_Splat3 ) );
				float3 temp_output_15_0_g126 = UnpackNormal( weightedBlend11 );
				float3 ase_worldTangent = i.ase_texcoord2.xyz;
				float3 ase_worldNormal = i.ase_texcoord3.xyz;
				float3 ase_worldBitangent = i.ase_texcoord4.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 tanNormal11_g126 = temp_output_15_0_g126;
				float3 worldNormal11_g126 = normalize( float3(dot(tanToWorld0,tanNormal11_g126), dot(tanToWorld1,tanNormal11_g126), dot(tanToWorld2,tanNormal11_g126)) );
				float3 vNormalWs13_g126 = worldNormal11_g126;
				float3 vTangentUWs13_g126 = ase_worldTangent;
				float3 vTangentVWs13_g126 = ase_worldBitangent;
				float3 appendResult27_g126 = (float3(0.5 , 0.0 , 0.0));
				float3 vRoughness13_g126 = appendResult27_g126;
				float3 vReflectance13_g126 = float3( 0,0,0 );
				float g_flFresnelExponent13_g126 = 5.0;
				float2 uv8_g126 = i.ase_texcoord.zw * float2( 1,1 ) + float2( 0,0 );
				float2 uv78_g126 = i.ase_texcoord5.xy * float2( 1,1 ) + float2( 0,0 );
				float4 appendResult55_g126 = (float4(( ( uv8_g126 * (unity_LightmapST).xy ) + (unity_LightmapST).zw ) , ( ( uv78_g126 * (unity_DynamicLightmapST).xy ) + (unity_DynamicLightmapST).zw )));
				float4 vLightmapUV13_g126 = appendResult55_g126;
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(ase_worldPos);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float dotResult57_g126 = dot( worldNormal11_g126 , ase_worldViewDir );
				float Dotfresnel13_g126 = dotResult57_g126;
				float CubeMapScalar13_g126 = g_flCubeMapScalar;
				float g_flFresnelFalloff13_g126 = g_flFresnelFalloff;
				float4x4 localZeroLighting13_g126 = ZeroLighting( vPositionWs13_g126 , vNormalWs13_g126 , vTangentUWs13_g126 , vTangentVWs13_g126 , vRoughness13_g126 , vReflectance13_g126 , g_flFresnelExponent13_g126 , vLightmapUV13_g126 , Dotfresnel13_g126 , CubeMapScalar13_g126 , g_flFresnelFalloff13_g126 );
				float4x4 break19_g126 = localZeroLighting13_g126;
				float3 appendResult21_g126 = (float3(break19_g126[ 0 ][ 0 ] , break19_g126[ 0 ][ 1 ] , break19_g126[ 0 ][ 2 ]));
				float3 appendResult22_g126 = (float3(break19_g126[ 1 ][ 0 ] , break19_g126[ 1 ][ 1 ] , break19_g126[ 1 ][ 2 ]));
				float3 appendResult23_g126 = (float3(break19_g126[ 1 ][ 3 ] , break19_g126[ 2 ][ 0 ] , break19_g126[ 2 ][ 1 ]));
				float3 appendResult24_g126 = (float3(break19_g126[ 2 ][ 2 ] , break19_g126[ 2 ][ 3 ] , break19_g126[ 3 ][ 0 ]));
				float3 appendResult25_g126 = (float3(break19_g126[ 3 ][ 1 ] , break19_g126[ 3 ][ 2 ] , break19_g126[ 3 ][ 3 ]));
				float3 temp_output_26_0_g126 = ( appendResult21_g126 + appendResult22_g126 + max( appendResult23_g126 , float3( 0,0,0 ) ) + max( appendResult24_g126 , float3( 0,0,0 ) ) + max( appendResult25_g126 , float3( 0,0,0 ) ) );
				float3 posWs1_g127 = ase_worldPos;
				float3 tanNormal3_g127 = temp_output_15_0_g126;
				float3 worldNormal3_g127 = float3(dot(tanToWorld0,tanNormal3_g127), dot(tanToWorld1,tanNormal3_g127), dot(tanToWorld2,tanNormal3_g127));
				float3 vNormalWs1_g127 = worldNormal3_g127;
				float localAO1_g127 = AO( posWs1_g127 , vNormalWs1_g127 );
				#ifdef S_RECEIVE_SHADOWS
				float3 staticSwitch81_g126 = ( temp_output_26_0_g126 * localAO1_g127 );
				#else
				float3 staticSwitch81_g126 = temp_output_26_0_g126;
				#endif
				float3 RGBin1_g125 = ( lerpResult16 * float4( staticSwitch81_g126 , 0.0 ) ).rgb;
				float FogMultiplier1_g125 = 1.0;
				float3 PositionWs1_g125 = ase_worldPos;
				float3 localMyCustomExpression1_g125 = MyCustomExpression1_g125( RGBin1_g125 , FogMultiplier1_g125 , PositionWs1_g125 );
				
				
				finalColor = float4( localMyCustomExpression1_g125 , 0.0 );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=15406
2057;-93;1524;1164;-934.8146;1718.863;1.540049;False;False
Node;AmplifyShaderEditor.TextureCoordinatesNode;76;-880,336;Float;False;0;5;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;78;-851,761;Float;False;0;3;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;79;-880,992;Float;False;0;2;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;77;-865,523;Float;False;0;4;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;121;-669.8597,-1648.829;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;6;-594.937,302.1464;Float;True;Property;_Normal0;Normal0;17;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;8;-604.761,730.0314;Float;True;Property;_Normal2;Normal2;19;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-663.939,-774.7358;Float;True;Property;_Control;Control;12;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;9;-607.751,954.6912;Float;True;Property;_Normal3;Normal3;20;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;7;-599.87,516.3218;Float;True;Property;_Normal1;Normal1;18;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;-613.83,54.96295;Float;True;Property;_Splat3;Splat3;13;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;3;-634.5041,-150.3657;Float;True;Property;_Splat2;Splat2;14;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;15;-116.3495,-1276.721;Float;False;Constant;_Float0;Float 0;11;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;5;-663.126,-550.462;Float;True;Property;_Splat0;Splat0;16;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CustomExpressionNode;120;-355.1305,-1648.682;Float;False;  return tex2D(_MainTex, UV)@;4;False;1;True;UV;FLOAT2;0,0;In;;MainTex 2DSampler;True;False;0;1;0;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;4;-648.222,-351.1321;Float;True;Property;_Splat1;Splat1;15;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;13;-367.242,-1463.333;Float;False;Property;_Color;Color;11;0;Fetch;True;0;0;False;0;0,0,0,0;1,1,1,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SummedBlendNode;11;30.6221,133.4914;Float;False;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;14;67.63457,-1432.156;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.UnpackScaleNormalNode;19;296.6526,152.313;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SummedBlendNode;10;59.80904,-310.4797;Float;False;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;148;2100.727,-413.4214;Float;False;VRStandardLighting;0;;126;50d6ab72cc2255a42a87b96dcb19e402;0;4;16;FLOAT;0.5;False;17;FLOAT3;0,0,0;False;15;FLOAT3;0,0,1;False;29;FLOAT;5;False;2;FLOAT3;20;FLOAT;79
Node;AmplifyShaderEditor.LerpOp;16;315.6208,-1187.193;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;75;1071.507,367.4314;Float;False;1454.748;552.0461;Simple Snow Coverage Effect;9;60;61;62;63;68;64;65;72;74;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;143;2519.151,-535.0112;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;59;-2714.191,-1485.26;Float;False;1968.271;500.7608;Distance Control;9;27;37;29;31;30;33;34;35;56;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;69;2168.335,216.5218;Float;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;27;-2657.929,-1421.025;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;63;1677.112,583.9039;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PowerNode;34;-1645.099,-1347.889;Float;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;42;1162.343,-149.7701;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;21;2021.292,82.18499;Float;False;Property;_Metallic;Metallic;10;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;37;-2664.191,-1246.405;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ClampOpNode;35;-1310.849,-1350.903;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;58;668.1784,494.7191;Float;False;56;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-1901.146,-1116.486;Float;False;Property;_TransitionFalloff;Transition Falloff;4;0;Create;True;0;0;False;0;0;0.91;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;41;989.9506,51.0748;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;20;1712.766,206.2787;Float;False;Property;_Smoothness;Smoothness;9;0;Create;True;0;0;False;0;0;0.168;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;64;1837.112,583.9039;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-2282.559,-1099.499;Float;False;Property;_TransitionDistance;Transition Distance;3;0;Create;True;0;0;False;0;0;18.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;67;2050.389,-1129.824;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;24;861.015,-846.214;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;73;1894.68,-1029.368;Float;False;72;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;18;2466.024,72.33138;Float;False;v.tangent.xyz = cross ( v.normal, float3( 0, 0, 1 ) )@$v.tangent.w = -1@;1;True;0;CalculateTangents;True;False;0;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;56;-988.9198,-1435.259;Float;False;Distance;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;60;1145.249,417.4314;Float;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;62;1517.111,583.9039;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;98;2694.128,-1013.467;Float;False;Constant;_Color0;Color 0;24;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DistanceOpNode;29;-2360.201,-1347.89;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;68;1356.331,804.4778;Float;False;Property;_SnowCoverageFalloff;Snow Coverage Falloff;8;0;Create;True;0;0;False;0;0;0.156;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;65;2011.061,581.8517;Float;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.FunctionNode;134;2759.118,-482.8684;Float;False;VRFog;-1;;125;0f36de526ee9ad84d846f9bb0b9b14fe;0;1;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;66;1576.535,-1118.921;Float;True;Property;_TextureSample0;Texture Sample 0;21;0;Create;True;0;0;False;0;None;4112a019314dad94f9ffc2f8481f31bc;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;72;2283.255,594.3326;Float;False;SnowMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;39;1126.349,-799.3761;Float;False;Property;_CoverageFade;Coverage Fade;1;0;Create;True;0;0;False;0;0;0;1;True;;Toggle;2;Key0;Key1;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;44;212.8771,406.9246;Float;False;Property;_CoverageNormalIntensity;Coverage Normal Intensity;6;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;88;2257.097,-120.987;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;30;-2014.701,-1346.282;Float;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;45;1330.188,-420.1055;Float;False;Property;_CoverageFade;Coverage Fade;1;0;Create;True;0;0;False;0;0;0;1;True;;Toggle;2;Key0;Key1;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;57;489.4643,-754.7751;Float;False;56;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;61;1121.506,695.0643;Float;False;Property;_SnowCoverageAmount;Snow Coverage Amount;7;0;Create;True;0;0;False;0;0;-1;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;43;592.1921,245.3864;Float;True;Property;_CoverageNormal;Coverage Normal;5;0;Create;True;0;0;False;0;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;23;376.1109,-952.9803;Float;True;Property;_CoverageAlbedo;Coverage Albedo;2;0;Create;True;0;0;False;0;None;138df4511c079324cabae1f7f865c1c1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;74;1899.984,373.9212;Float;False;72;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;80;3246.497,-520.8497;Float;False;True;2;Float;ASEMaterialInspector;0;1;SLZ/VR Terrain;0770190933193b94aaa3065e307002fa;0;0;Main;2;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;0;False;-1;True;3;False;-1;True;False;0;False;-1;0;False;-1;True;2;RenderType=Opaque;SplatCount=4;True;7;0;False;False;False;False;False;False;False;False;False;False;0;;0;0;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;0
WireConnection;6;1;76;0
WireConnection;8;1;78;0
WireConnection;9;1;79;0
WireConnection;7;1;77;0
WireConnection;120;0;121;0
WireConnection;11;0;1;0
WireConnection;11;1;6;0
WireConnection;11;2;7;0
WireConnection;11;3;8;0
WireConnection;11;4;9;0
WireConnection;14;0;120;0
WireConnection;14;1;13;0
WireConnection;14;2;15;0
WireConnection;19;0;11;0
WireConnection;10;0;1;0
WireConnection;10;1;5;0
WireConnection;10;2;4;0
WireConnection;10;3;3;0
WireConnection;10;4;2;0
WireConnection;148;15;19;0
WireConnection;16;0;10;0
WireConnection;16;1;14;0
WireConnection;16;2;15;0
WireConnection;143;0;16;0
WireConnection;143;1;148;20
WireConnection;69;0;20;0
WireConnection;69;2;74;0
WireConnection;63;0;62;0
WireConnection;34;0;30;0
WireConnection;34;1;33;0
WireConnection;42;0;41;0
WireConnection;35;0;34;0
WireConnection;41;0;19;0
WireConnection;41;1;43;0
WireConnection;41;2;58;0
WireConnection;64;0;63;0
WireConnection;64;1;68;0
WireConnection;67;0;16;0
WireConnection;67;1;66;0
WireConnection;67;2;73;0
WireConnection;24;0;16;0
WireConnection;24;1;23;0
WireConnection;24;2;57;0
WireConnection;56;0;35;0
WireConnection;60;0;43;0
WireConnection;62;0;60;0
WireConnection;62;1;61;0
WireConnection;29;0;27;0
WireConnection;29;1;37;0
WireConnection;65;0;64;0
WireConnection;134;3;143;0
WireConnection;72;0;65;1
WireConnection;39;1;16;0
WireConnection;39;0;24;0
WireConnection;88;0;16;0
WireConnection;30;0;29;0
WireConnection;30;1;31;0
WireConnection;45;1;19;0
WireConnection;45;0;42;0
WireConnection;43;5;44;0
WireConnection;80;0;134;0
ASEEND*/
//CHKSM=8F608E546BB0CE4EFBC1149767A2F4248DDB8FB3