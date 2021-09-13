// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SDK/Mod2x"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "gray" {}
		[HDR]_Color("Color", Color) = (1,1,1,0)
		_OffsetUnits("OffsetUnits", Int) = -2
		_OffsetFactor("OffsetFactor", Int) = -2
		_Multiplier("Multiplier", Float) = 1
		[Toggle(_ALPHA_ON)] _alpha("alpha", Float) = 0
		[Toggle(_VERTEXCOLORS_ON)] _VertexColors("VertexColors", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Custom"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		ZWrite Off
		Offset  [_OffsetFactor] , [_OffsetUnits]
		Blend DstColor SrcColor
		
		CGPROGRAM
		#pragma target 3.0
		#pragma shader_feature _ALPHA_ON
		#pragma shader_feature _VERTEXCOLORS_ON
		#pragma surface surf Unlit keepalpha noshadow noambient novertexlights nolightmap  nodynlightmap nodirlightmap nofog nometa noforwardadd 
		struct Input
		{
			float2 uv_texcoord;
			float4 vertexColor : COLOR;
		};

		uniform int _OffsetUnits;
		uniform int _OffsetFactor;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float4 _Color;
		uniform float _Multiplier;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 temp_cast_0 = (1.0).xxxx;
			#ifdef _VERTEXCOLORS_ON
				float4 staticSwitch38 = i.vertexColor;
			#else
				float4 staticSwitch38 = temp_cast_0;
			#endif
			float4 temp_output_16_0 = ( tex2D( _MainTex, uv_MainTex ) * _Color * staticSwitch38 );
			float4 temp_cast_1 = (0.5).xxxx;
			float4 temp_output_26_0 = ( ( ( temp_output_16_0 - temp_cast_1 ) * _Multiplier ) + 0.5 );
			float4 temp_cast_2 = (0.5).xxxx;
			float4 temp_cast_3 = (0.5).xxxx;
			float4 lerpResult30 = lerp( temp_cast_2 , temp_output_26_0 , (temp_output_16_0).a);
			#ifdef _ALPHA_ON
				float4 staticSwitch28 = lerpResult30;
			#else
				float4 staticSwitch28 = temp_output_26_0;
			#endif
			o.Emission = staticSwitch28.rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16900
65;155;1262;877;465.8424;538.3979;1.501575;True;True
Node;AmplifyShaderEditor.TexturePropertyNode;9;-1470,-303;Float;True;Property;_MainTex;MainTex;1;0;Create;True;0;0;False;0;None;None;False;gray;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;39;193.349,485.6761;Float;False;Constant;_Float2;Float 2;10;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;36;-45.40157,267.9482;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;15;-91.00143,92.52959;Float;False;Property;_Color;Color;2;1;[HDR];Create;True;0;0;False;0;1,1,1,0;4,4,4,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;38;190.3458,296.4778;Float;False;Property;_VertexColors;VertexColors;9;0;Create;True;0;0;False;0;0;1;1;True;;Toggle;2;Key0;Key1;Create;False;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;10;-181.0179,-125.4856;Float;True;Property;_TextureSample1;Texture Sample 1;3;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;278.5282,1.515851;Float;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;24;303.6783,164.7443;Float;False;Constant;_Float0;Float 0;8;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;23;481.6185,66.22382;Float;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;22;548.2173,349.4277;Float;False;Property;_Multiplier;Multiplier;7;0;Create;True;0;0;False;0;1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;637.6185,131.2238;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SwizzleNode;37;685.8656,-83.42053;Float;False;FLOAT;3;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;26;893.6185,74.22382;Float;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;31;854.6781,-262.3637;Float;False;Constant;_Float1;Float 1;9;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;30;1053.464,-141.6288;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorSpaceDouble;35;146.5294,-257.5435;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;7;-940.5902,307.8667;Float;False;Property;_Depth;Depth;4;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-1208,-177;Float;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;11;-1514,261;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ToggleSwitchNode;17;-412.2653,73.80711;Float;False;Property;_Parallaxing;Parallaxing;3;0;Create;True;0;0;False;0;0;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.IntNode;21;-186.3815,487.2238;Float;False;Property;_OffsetUnits;OffsetUnits;5;0;Create;True;0;0;True;0;-2;-1;0;1;INT;0
Node;AmplifyShaderEditor.ParallaxMappingNode;6;-744,16;Float;False;Planar;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;13;-994,49;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;20;-186.3815,403.2238;Float;False;Property;_OffsetFactor;OffsetFactor;6;0;Create;True;0;0;True;0;-2;-1;0;1;INT;0
Node;AmplifyShaderEditor.StaticSwitch;28;1301.032,-69.67551;Float;False;Property;_alpha;alpha;8;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;8;-1203,383;Float;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;19;1532.52,9.024076;Float;False;True;2;Float;ASEMaterialInspector;0;0;Unlit;SLZ/Mod2x;False;False;False;False;True;True;True;True;True;True;True;True;False;False;True;False;False;False;False;False;False;Back;2;False;-1;0;False;-1;True;-1;True;20;-1;True;21;False;0;Custom;0;True;False;0;True;Custom;;Transparent;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;7;2;False;-1;3;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;38;1;39;0
WireConnection;38;0;36;0
WireConnection;10;0;9;0
WireConnection;16;0;10;0
WireConnection;16;1;15;0
WireConnection;16;2;38;0
WireConnection;23;0;16;0
WireConnection;23;1;24;0
WireConnection;25;0;23;0
WireConnection;25;1;22;0
WireConnection;37;0;16;0
WireConnection;26;0;25;0
WireConnection;26;1;24;0
WireConnection;30;0;31;0
WireConnection;30;1;26;0
WireConnection;30;2;37;0
WireConnection;1;0;9;0
WireConnection;17;0;11;0
WireConnection;17;1;6;0
WireConnection;6;0;11;0
WireConnection;6;1;13;0
WireConnection;6;2;7;0
WireConnection;6;3;8;0
WireConnection;13;0;1;4
WireConnection;28;1;26;0
WireConnection;28;0;30;0
WireConnection;19;2;28;0
ASEEND*/
//CHKSM=A301665AA938408BD728B9B517646BA57442E03E