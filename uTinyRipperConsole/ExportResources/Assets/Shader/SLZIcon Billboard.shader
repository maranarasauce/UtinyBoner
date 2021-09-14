// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SDK/IconBillboard"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		[HDR]_Color("Color", Color) = (8,8,8,1)
		[PerRendererData]_MainTex("MainTex", 2DArray ) = "" {}
		[PerRendererData]_IconSelection("IconSelection", Int) = 0
		[PerRendererData]_IconSize("IconSize", float) = 0.1

		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Overlay+0" "IgnoreProjector" = "True" "ForceNoShadowCasting" = "True" "IsEmissive" = "true"  }
		Cull Off
		ZWrite Off
		ZTest Always
		Blend DstColor SrcColor
		
		AlphaToMask On
		CGPROGRAM
		#pragma target 3.5
		#pragma multi_compile_instancing
		#pragma surface surf Unlit keepalpha noshadow noambient novertexlights nolightmap  nodynlightmap nodirlightmap nofog nometa noforwardadd vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float4 _Color;
		uniform UNITY_DECLARE_TEX2DARRAY( _MainTex );
		uniform float4 _MainTex_ST;
		//uniform int _IconSelection;
		uniform float _Cutoff = 0.5;

		UNITY_INSTANCING_BUFFER_START(InstanceProperties)
			UNITY_DEFINE_INSTANCED_PROP(int, _IconSelection)
			UNITY_DEFINE_INSTANCED_PROP(float, _IconSize)
		UNITY_INSTANCING_BUFFER_END(InstanceProperties)

		#define IconSelection UNITY_ACCESS_INSTANCED_PROP(InstanceProperties, _IconSelection)
		#define IconSize UNITY_ACCESS_INSTANCED_PROP(InstanceProperties, _IconSize)



		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			//Calculate new billboard vertex position and normal;
			float3 upCamVec = normalize ( UNITY_MATRIX_V._m10_m11_m12 );
			float3 forwardCamVec = -normalize ( UNITY_MATRIX_V._m20_m21_m22 );
			float3 rightCamVec = normalize( UNITY_MATRIX_V._m00_m01_m02 );
			float4x4 rotationCamMatrix = float4x4( rightCamVec, 0, upCamVec, 0, forwardCamVec, 0, 0, 0, 0, 1 );
			v.normal = normalize( mul( float4( v.normal , 0 ), rotationCamMatrix ));
			// v.vertex.x *= length( unity_ObjectToWorld._m00_m10_m20 );
			// v.vertex.y *= length( unity_ObjectToWorld._m01_m11_m21 );
			// v.vertex.z *= length( unity_ObjectToWorld._m02_m12_m22 );
			v.vertex = mul( v.vertex, rotationCamMatrix );
			v.vertex.xyz += unity_ObjectToWorld._m03_m13_m23;
			//Need to nullify rotation inserted by generated surface shader;
			v.vertex = mul( unity_WorldToObject, v.vertex ) * IconSize;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 texArray7 = UNITY_SAMPLE_TEX2DARRAY(_MainTex, float3(uv_MainTex, IconSelection)  );
			o.Emission = ( _Color * texArray7 ).rgb;
			float temp_output_7_4 = texArray7.a;
			o.Alpha = temp_output_7_4;
			clip( temp_output_7_4 - _Cutoff );
		}

		ENDCG
	}
	//CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15800
1989;1949;1524;1164;1313.73;450.561;1;True;False
Node;AmplifyShaderEditor.IntNode;8;-839.73,208.439;Float;False;Property;_IconSelection;IconSelection;3;1;[PerRendererData];Create;True;0;0;False;0;0;0;0;1;INT;0
Node;AmplifyShaderEditor.TextureArrayNode;7;-622.73,111.439;Float;True;Property;_MainTex;MainTex;2;1;[PerRendererData];Create;True;0;0;False;0;Assets/__HandRigDevelopment_FINAL/Resources/IconTextureArray.asset;0;Object;-1;Auto;False;7;6;SAMPLER2D;;False;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;5;-700.23,-182.561;Float;False;Property;_Color;Color;1;1;[HDR];Create;True;0;0;True;0;8,8,8,1;8,8,8,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;6;-304.23,-50.561;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;1,1,1,1;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;4;-17,-6;Float;False;True;3;Float;ASEMaterialInspector;0;0;Unlit;SLZ/Icon Billboard;False;False;False;False;True;True;True;True;True;True;True;True;False;False;True;True;True;False;False;False;Back;2;False;-1;7;False;-1;False;-10;False;-1;-10;False;-1;False;0;Custom;0.5;True;False;0;True;TransparentCutout;;Overlay;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;7;2;False;-1;3;False;-1;0;1;False;-1;1;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;True;Spherical;True;Relative;0;;0;-1;-1;-1;0;True;0;0;False;-1;-1;0;False;-1;0;0;0;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;7;1;8;0
WireConnection;6;0;5;0
WireConnection;6;1;7;0
WireConnection;4;2;6;0
WireConnection;4;9;7;4
WireConnection;4;10;7;4
ASEEND*/
//CHKSM=4A4E0C74367DBDD2F8AADEABB9E79224ED959DE3