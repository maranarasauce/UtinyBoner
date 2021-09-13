// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SDK/Highlighter"
{
	Properties
	{
		[HDR]_Color("Color", Color) = (0.6792453,0.60807,0.2851548,0)
		_EdgeFalloff("Edge Falloff", Range( 0.1 , 7)) = 0
		_Dither("Dither", Range( 0 , 1)) = 0.5
		_Highlight("Highlight", Range( 0 , 1)) = 1
	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Custom" "Queue"="AlphaTest" }
		LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend Off
		AlphaToMask On
		Cull Back
		ColorMask RGBA
		ZWrite On
		ZTest LEqual
		Offset -1 , -1
		
		
		
		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM



#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
		//only defining to not throw compilation error over Unity 5.5
		#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				half3 ase_normal : NORMAL;
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				float4 ase_texcoord2 : TEXCOORD2;
			};

		//	uniform half4 _Color;
			uniform half _EdgeFalloff;
		//	uniform half _Highlight;
		//	uniform half _Dither;

			UNITY_INSTANCING_BUFFER_START(InstanceProperties)
				UNITY_DEFINE_INSTANCED_PROP(half, _Highlight)
				UNITY_DEFINE_INSTANCED_PROP(half4, _Color)
				UNITY_DEFINE_INSTANCED_PROP(half, _Dither)
			UNITY_INSTANCING_BUFFER_END(InstanceProperties)


			inline float Dither4x4Bayer( int x, int y )
			{
				const float dither[ 16 ] = {
			 1,  9,  3, 11,
			13,  5, 15,  7,
			 4, 12,  2, 10,
			16,  8, 14,  6 };
				int r = y * 4 + x;
				return dither[r] / 16; // same # of instructions as pre-dividing due to compiler magic
			}
			
			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord.xyz = ase_worldNormal;
				float3 ase_worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.ase_texcoord1.xyz = ase_worldPos;
				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord2 = screenPos;
				
				o.ase_color = v.color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.w = 0;
				o.ase_texcoord1.w = 0;
				float3 vertexValue =  float3(0,0,0) ;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

				half4 Color = UNITY_ACCESS_INSTANCED_PROP(InstanceProperties,_Color);
				half Highlight = UNITY_ACCESS_INSTANCED_PROP(InstanceProperties,_Highlight);

				fixed4 finalColor;
				float3 ase_worldNormal = i.ase_texcoord.xyz;
				float3 ase_worldPos = i.ase_texcoord1.xyz;
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(ase_worldPos);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float dotResult13 = dot( ase_worldNormal , ase_worldViewDir );
				float clampResult23 = clamp( ( 1.0 - dotResult13 ) , 0.0 , 1.0 );
				float4 lerpResult22 = lerp( ( Color * pow( clampResult23 , _EdgeFalloff ) * i.ase_color ) , Color , Color.a);
				float4 clampResult24 = clamp( ( lerpResult22 * Highlight ) , float4( 0,0,0,0 ) , float4( 1,1,1,1 ) );
				float4 screenPos = i.ase_texcoord2;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 clipScreen27 = ase_screenPosNorm.xy * _ScreenParams.xy;
				float dither27 = Dither4x4Bayer( fmod(clipScreen27.x, 4), fmod(clipScreen27.y, 4) );
				dither27 = step( dither27, ( UNITY_ACCESS_INSTANCED_PROP(InstanceProperties,_Dither) * Highlight ) );
				float4 appendResult34 = (half4((clampResult24).rgb , dither27));
				
				
				finalColor = appendResult34;
				return finalColor;
			}
			ENDCG
		}
	}
	//CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=16900
667;59;1263;1044;-1688.833;650.3051;1.3;True;True
Node;AmplifyShaderEditor.WorldNormalVector;3;180.8606,-49.17888;Float;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;12;195.5682,139.5426;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;13;523.168,22.54257;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;14;698.6676,4.342547;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;511.4673,174.7427;Float;False;Property;_EdgeFalloff;Edge Falloff;2;0;Create;True;0;0;False;0;0;1;0.1;7;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;23;940.4684,16.14284;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;32;1242.283,-335.7063;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;20;1219.968,64.24242;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;16;1203.068,-167.1575;Float;False;Property;_Color;Color;1;2;[HDR];[PerRendererData];Create;True;0;0;False;0;0.6792453,0.60807,0.2851548,0;1.323529,1.055065,0.3503461,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;1561.865,22.54251;Float;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;22;1879.068,40.84259;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;29;1357.979,280.4946;Float;False;Property;_Highlight;Highlight;4;2;[HideInInspector];[PerRendererData];Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;1410.868,150.7432;Float;False;Property;_Dither;Dither;3;1;[PerRendererData];Create;True;0;0;False;0;0.5;0.113;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;2066.481,56.89426;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;1755.782,315.5947;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;24;2236.869,57.74297;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,1;False;1;COLOR;0
Node;AmplifyShaderEditor.DitheringNode;27;2063.97,237.143;Float;False;0;False;3;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;35;2424.633,-6.805676;Float;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;34;2515.633,98.49379;Float;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;33;2823.399,114.5;Float;False;True;2;Float;ASEMaterialInspector;0;1;SLZ/Highlighter;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;True;True;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;-1;False;-1;-1;False;-1;True;2;RenderType=TransparentCutout=RenderType;Queue=AlphaTest=Queue=0;True;2;0;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;0
WireConnection;13;0;3;0
WireConnection;13;1;12;0
WireConnection;14;0;13;0
WireConnection;23;0;14;0
WireConnection;20;0;23;0
WireConnection;20;1;21;0
WireConnection;17;0;16;0
WireConnection;17;1;20;0
WireConnection;17;2;32;0
WireConnection;22;0;17;0
WireConnection;22;1;16;0
WireConnection;22;2;16;4
WireConnection;31;0;22;0
WireConnection;31;1;29;0
WireConnection;30;0;28;0
WireConnection;30;1;29;0
WireConnection;24;0;31;0
WireConnection;27;0;30;0
WireConnection;35;0;24;0
WireConnection;34;0;35;0
WireConnection;34;3;27;0
WireConnection;33;0;34;0
ASEEND*/
//CHKSM=ABEEB700E32D47F3928AF9D5B7378FC056DA7543