// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SDK/Flowmap Additive"
{
	Properties
	{
		[NoScaleOffset][Header(Motion Vectors)]_MotionVectors("Motion Vectors", 2D) = "white" {}
		_UVMotionMultiplier("UV Motion Multiplier", Float) = 0
		_Speed("Speed", Float) = 1
		[Header(Main Properties)]_MainTex("Main Texture", 2D) = "white" {}
		[HDR]_Color("Color", Color) = (1,1,1,1)
		_Min("Min", Range( 0 , 1)) = 1
		_Max("Max", Range( 0 , 1)) = 0
		_Pow("Pow", Float) = 1
		_MinClamp("MinClamp", Range( 0 , 1)) = 0
		[HDR]_Color2("Color 2", Color) = (0,0,0,0)
		_SecondaryTexture("Secondary Texture", 2D) = "black" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
		LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend One One
		Cull Off
		ColorMask RGBA
		ZWrite Off
		ZTest LEqual
		
		
		
		Pass
		{
			Name "Unlit"
			
			CGPROGRAM
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
				float4 ase_texcoord : TEXCOORD0;
				float3 ase_normal : NORMAL;
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
			};

			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform sampler2D _MotionVectors;
			uniform float _Speed;
			uniform float _UVMotionMultiplier;
			uniform float4 _Color;
			uniform float _Pow;
			uniform float _Min;
			uniform float _Max;
			uniform float _MinClamp;
			uniform sampler2D _SecondaryTexture;
			uniform float4 _SecondaryTexture_ST;
			uniform float4 _Color2;
			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord1.xyz = ase_worldNormal;
				float3 ase_worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.ase_texcoord2.xyz = ase_worldPos;
				
				o.ase_texcoord.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;
				o.ase_texcoord1.w = 0;
				o.ase_texcoord2.w = 0;
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
				fixed4 finalColor;
				float2 uv0_MainTex = i.ase_texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 temp_output_63_0 = (tex2D( _MotionVectors, uv0_MainTex )).rg;
				float2 temp_cast_0 = (0.5).xx;
				float mulTime32 = _Time.y * _Speed;
				float2 temp_output_21_0 = ( uv0_MainTex + ( ( temp_output_63_0 - temp_cast_0 ) * frac( mulTime32 ) * -_UVMotionMultiplier ) );
				float2 temp_cast_1 = (0.5).xx;
				float temp_output_14_0 = ( 1.0 - frac( mulTime32 ) );
				float2 temp_output_20_0 = ( uv0_MainTex + ( ( temp_output_63_0 - temp_cast_1 ) * temp_output_14_0 * -1.0 * -_UVMotionMultiplier ) );
				float4 lerpResult24 = lerp( tex2D( _MainTex, temp_output_21_0 ) , tex2D( _MainTex, temp_output_20_0 ) , frac( mulTime32 ));
				float3 ase_worldNormal = i.ase_texcoord1.xyz;
				float3 ase_worldPos = i.ase_texcoord2.xyz;
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(ase_worldPos);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float dotResult70 = dot( ase_worldNormal , ase_worldViewDir );
				float clampResult86 = clamp( (0.0 + (pow( abs( dotResult70 ) , _Pow ) - _Min) * (1.0 - 0.0) / (_Max - _Min)) , 0.0 , 1.0 );
				float clampResult85 = clamp( ( clampResult86 + _MinClamp ) , 0.0 , 1.0 );
				float2 uv_SecondaryTexture = i.ase_texcoord.xy * _SecondaryTexture_ST.xy + _SecondaryTexture_ST.zw;
				
				
				finalColor = ( ( lerpResult24 * _Color * clampResult85 ) + ( tex2D( _SecondaryTexture, uv_SecondaryTexture ) * _Color2 ) );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=16600
16;135;1417;916;844.4804;1150.578;1.3;True;True
Node;AmplifyShaderEditor.CommentaryNode;3;-3209.867,279.5115;Float;False;1541.69;636.4142;Motion Vector interpolation;16;14;20;21;18;17;11;13;15;12;10;8;9;7;5;31;63;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-3236.938,-104.6966;Float;False;Property;_Speed;Speed;2;0;Create;True;0;0;False;0;1;0.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;72;-586.8558,-900.799;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TexturePropertyNode;5;-3159.867,492.3456;Float;True;Property;_MotionVectors;Motion Vectors;0;1;[NoScaleOffset];Create;True;0;0;False;1;Header(Motion Vectors);None;0f3c3ec49a6dc184488cc4a5f4dec515;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.WorldNormalVector;71;-623.4852,-1082.353;Float;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleTimeNode;32;-3036.967,-83.42313;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;31;-3173.88,337.8394;Float;False;0;19;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;7;-2822.412,367.0664;Float;True;Property;_TextureSample2;Texture Sample 2;3;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DotProductOpNode;70;-362.3018,-980.4282;Float;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;37;-2801.675,-26.52748;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;82;-233.4255,-620.152;Float;False;Property;_Pow;Pow;9;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;35;-2156.69,-69.69698;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;63;-2516.88,415.0787;Float;False;FLOAT2;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-2406.758,502.5175;Float;False;Constant;_5;.5;3;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-2765.948,821.1539;Float;False;Property;_UVMotionMultiplier;UV Motion Multiplier;1;0;Create;True;0;0;False;0;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;91;-65.78046,-1011.479;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;13;-2264.157,590.0854;Float;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;80;-174.5167,-477.3039;Float;False;Property;_Max;Max;8;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-2261.969,752.2297;Float;False;Constant;_Float0;Float 0;3;0;Create;True;0;0;False;0;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;81;-64.83981,-874.0548;Float;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;79;-174.7667,-542.8538;Float;False;Property;_Min;Min;7;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;14;-2112.407,573.3732;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;12;-2472.52,789.7024;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;15;-2274.2,393.4151;Float;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;-2080.022,390.2114;Float;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-2088.98,719.7828;Float;False;4;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;16;-1424.072,-240.9597;Float;False;1091.596;477.5999;Main Texture frame blend;4;24;23;22;19;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TFHCRemapNode;78;221.8305,-572.2285;Float;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;20;-1879.434,563.1824;Float;True;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ClampOpNode;86;555.5175,-470.1975;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;83;-192.5759,-383.6541;Float;False;Property;_MinClamp;MinClamp;10;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;19;-1381.9,-85.73202;Float;True;Property;_MainTex;Main Texture;3;0;Create;False;0;0;False;1;Header(Main Properties);None;cf6a5d2d708565a4d8cb229049f2fa4e;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleAddOpNode;21;-1869.644,326.1999;Float;True;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;23;-924.6756,-190.9597;Float;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;84;142.1204,-357.5042;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;22;-925.9753,6.640089;Float;True;Property;_TextureSample1;Texture Sample 1;0;0;Create;True;0;0;False;0;None;None;True;1;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;87;78.16296,174.513;Float;True;Property;_SecondaryTexture;Secondary Texture;12;0;Create;True;0;0;False;0;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;89;164.3196,362.6213;Float;False;Property;_Color2;Color 2;11;1;[HDR];Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;85;347.8683,-340.3293;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;24;-569.0896,-99.81689;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;25;-271.5463,-289.6646;Float;False;Property;_Color;Color;4;1;[HDR];Create;True;0;0;False;0;1,1,1,1;33.21063,60.7405,83.46356,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;48;-1463.429,349.438;Float;False;1195.681;483.853;Main Texture frame blend;7;55;59;57;49;50;51;56;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;90;432.1195,304.1213;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;562.1988,-94.69473;Float;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;2;-2383.116,-883.1053;Float;False;624.7802;563.0769;Vertex inputs;5;30;29;28;6;4;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;8;-2830.752,565.9059;Float;True;Property;_TextureSample3;Texture Sample 3;3;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwizzleNode;4;-2021.421,-824.0052;Float;False;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;49;-1433.035,400.8514;Float;True;Property;_Texture0;Bump Map;5;1;[NoScaleOffset];Create;False;0;0;False;0;None;None;True;bump;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleAddOpNode;88;703.8195,50.62122;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SwizzleNode;6;-2020.121,-701.8049;Float;False;FLOAT2;2;3;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.VertexColorNode;30;-2309.801,-503.8096;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;62;-1625.386,-4.305231;Float;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;51;-964.0329,399.438;Float;True;Property;_TextureSample5;Texture Sample 5;0;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;29;-2323.657,-651.9739;Float;False;1;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-1854.062,-166.9863;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-1434.16,639.3347;Float;False;Property;_BumpScale;Bump Scale;6;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;-1232.726,583.8216;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendNormalsNode;55;-568.6594,503.434;Float;True;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;28;-2330.82,-833.1053;Float;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;-1233.45,687.5551;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;50;-965.3325,597.0377;Float;True;Property;_TextureSample4;Texture Sample 4;0;0;Create;True;0;0;False;0;None;None;True;1;False;white;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SinOpNode;36;-2805.051,-136.5555;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;61;-1691.324,-157.6475;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;66;925.4324,-103.7774;Float;False;True;2;Float;ASEMaterialInspector;0;1;SLZ/Flowmap Additive;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;4;1;False;-1;1;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;True;False;True;2;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;False;0;False;-1;0;False;-1;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;0;False;False;False;False;False;False;False;False;False;True;0;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;0
WireConnection;32;0;33;0
WireConnection;7;0;5;0
WireConnection;7;1;31;0
WireConnection;70;0;71;0
WireConnection;70;1;72;0
WireConnection;37;0;32;0
WireConnection;35;0;37;0
WireConnection;63;0;7;0
WireConnection;91;0;70;0
WireConnection;13;0;63;0
WireConnection;13;1;9;0
WireConnection;81;0;91;0
WireConnection;81;1;82;0
WireConnection;14;0;35;0
WireConnection;12;0;10;0
WireConnection;15;0;63;0
WireConnection;15;1;9;0
WireConnection;17;0;15;0
WireConnection;17;1;35;0
WireConnection;17;2;12;0
WireConnection;18;0;13;0
WireConnection;18;1;14;0
WireConnection;18;2;11;0
WireConnection;18;3;12;0
WireConnection;78;0;81;0
WireConnection;78;1;79;0
WireConnection;78;2;80;0
WireConnection;20;0;31;0
WireConnection;20;1;18;0
WireConnection;86;0;78;0
WireConnection;21;0;31;0
WireConnection;21;1;17;0
WireConnection;23;0;19;0
WireConnection;23;1;21;0
WireConnection;84;0;86;0
WireConnection;84;1;83;0
WireConnection;22;0;19;0
WireConnection;22;1;20;0
WireConnection;85;0;84;0
WireConnection;24;0;23;0
WireConnection;24;1;22;0
WireConnection;24;2;35;0
WireConnection;90;0;87;0
WireConnection;90;1;89;0
WireConnection;26;0;24;0
WireConnection;26;1;25;0
WireConnection;26;2;85;0
WireConnection;8;0;5;0
WireConnection;8;1;31;0
WireConnection;4;0;28;0
WireConnection;88;0;26;0
WireConnection;88;1;90;0
WireConnection;6;0;28;0
WireConnection;62;0;61;0
WireConnection;51;0;49;0
WireConnection;51;1;21;0
WireConnection;51;5;59;0
WireConnection;60;0;35;0
WireConnection;60;1;35;0
WireConnection;57;0;56;0
WireConnection;57;1;35;0
WireConnection;55;0;51;0
WireConnection;55;1;50;0
WireConnection;59;0;56;0
WireConnection;59;1;14;0
WireConnection;50;0;49;0
WireConnection;50;1;20;0
WireConnection;50;5;57;0
WireConnection;36;0;32;0
WireConnection;61;0;60;0
WireConnection;61;1;60;0
WireConnection;66;0;88;0
ASEEND*/
//CHKSM=D1F2C86649904F66ED5EA5A7BBD3078BBDCD51C4