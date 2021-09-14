// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SDK/VoidBleed"
{
	Properties
	{
		[Gamma]_MainTex("Main Tex", 2D) = "white" {}
		_Min("Min", Range( 0 , 1)) = 0
		_Multiplier("Multiplier", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Custom" "Queue" = "AlphaTest"  }
		LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend Off
		AlphaToMask On
		Cull Back
		ColorMask RGBA
		ZWrite Off
		ZTest LEqual
		Offset -1 , -1
		
		
		
		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="ForwardBase" "RenderType"="TransparentCutout" }
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
				float4 ase_texcoord : TEXCOORD0;
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				float4 ase_texcoord : TEXCOORD0;
			};

			uniform float _Min;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float _Multiplier;
			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.ase_texcoord.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;
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
				fixed4 finalColor;
				float2 uv_MainTex = i.ase_texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float temp_output_6_0 = ( (_Min + (sin( _Time.y ) - -1.0) * (1.0 - _Min) / (1.0 - -1.0)) * tex2D( _MainTex, uv_MainTex ).a );
				float temp_output_19_0 = pow( temp_output_6_0 , _Multiplier );
				float4 appendResult12 = (float4(0.0 , 0.0 , 0.0 , temp_output_19_0));
				
				
				finalColor = appendResult12;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	Fallback "False"
}
/*ASEBEGIN
Version=16900
1982;91;1369;947;693.3322;619.3971;1.196339;True;True
Node;AmplifyShaderEditor.SimpleTimeNode;4;-1107.717,-442.5524;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;3;-941.7174,-373.5524;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-1048.647,-283.47;Float;False;Property;_Min;Min;1;0;Create;True;0;0;False;0;0;0.472;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;9;-699.6475,-410.4699;Float;True;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-1197,-58;Float;True;Property;_MainTex;Main Tex;0;1;[Gamma];Create;True;0;0;False;0;None;be4732c766ebff641bde7dbcc873e796;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;6;-846,-58;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-989.1447,-175.2739;Float;False;Property;_Multiplier;Multiplier;2;0;Create;True;0;0;False;0;1;0.91;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;19;-563.2256,-132.8238;Float;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-349.6475,-245.47;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;1.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;11;-115.7264,-243.899;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;17;69.11346,-242.2736;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RoundOpNode;16;-258.6475,19.53003;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;12;306.3937,-93.42477;Float;True;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;635.7543,-73.21445;Float;False;True;2;Float;ASEMaterialInspector;0;1;SLZ/VoidBleed;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;0;2;False;-1;0;False;-1;0;1;False;-1;1;False;-1;True;0;False;-1;0;False;-1;True;True;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;True;-1;False;-1;-1;False;-1;True;1;RenderType=TransparentCutout=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;True;2;LightMode=ForwardBase;RenderType=Custom=RenderType;False;0;False;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;0
WireConnection;3;0;4;0
WireConnection;9;0;3;0
WireConnection;9;3;10;0
WireConnection;6;0;9;0
WireConnection;6;1;2;4
WireConnection;19;0;6;0
WireConnection;19;1;18;0
WireConnection;15;0;19;0
WireConnection;11;0;15;0
WireConnection;17;0;11;0
WireConnection;16;0;6;0
WireConnection;12;3;19;0
WireConnection;1;0;12;0
ASEEND*/
//CHKSM=1DA20CBF5C9020B725A32367033A3AFEBB288076