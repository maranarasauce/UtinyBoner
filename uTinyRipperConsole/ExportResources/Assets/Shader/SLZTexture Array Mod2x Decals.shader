// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SDK/TextureArrayMod2xDecals"
{
	Properties
	{
		_TextureArray("Texture Array", 2DArray ) = "" {}
		[PerRendererData]_TexArraySelection("TexArraySelection", Float) = 0
		_OffsetUnits("Offset Units", Int) = -1
		_OffsetFactor("Offset Factor", Int) = -1
		[PerRendererData]_Color("Color", Color) = (1,1,1,1)
	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
		LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend DstColor SrcColor
		Cull Back
		ColorMask RGBA
		ZWrite Off
		ZTest LEqual
		Offset [_OffsetFactor] , [_OffsetUnits]
		
		
		
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

			uniform int _OffsetUnits;
			uniform int _OffsetFactor;
			uniform UNITY_DECLARE_TEX2DARRAY( _TextureArray );
			uniform float4 _TextureArray_ST;
		//	uniform float _TexArraySelection;
		//	uniform float4 _Color;


		UNITY_INSTANCING_BUFFER_START(InstanceProperties)
			UNITY_DEFINE_INSTANCED_PROP(int, _TexArraySelection)
			UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
		UNITY_INSTANCING_BUFFER_END(InstanceProperties)

			
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
				float2 uv_TextureArray = i.ase_texcoord.xy * _TextureArray_ST.xy + _TextureArray_ST.zw;
				float4 texArray2 = UNITY_SAMPLE_TEX2DARRAY(_TextureArray, float3(uv_TextureArray, UNITY_ACCESS_INSTANCED_PROP(InstanceProperties, _TexArraySelection) )  );
				
				
				finalColor = ( texArray2 * UNITY_ACCESS_INSTANCED_PROP(InstanceProperties, _Color) );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=16900
65;185;1262;847;853.1209;342.2884;1.203153;True;True
Node;AmplifyShaderEditor.RangedFloatNode;3;-729,56;Float;False;Property;_TexArraySelection;TexArraySelection;1;1;[PerRendererData];Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureArrayNode;2;-408,-50;Float;True;Property;_TextureArray;Texture Array;0;0;Create;True;0;0;False;0;None;0;Object;-1;Auto;False;7;6;SAMPLER2D;;False;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;4;-304,210.7968;Float;False;Property;_Color;Color;4;1;[PerRendererData];Create;True;0;0;False;0;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;-2,-18;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.IntNode;6;-566.4074,406.4159;Float;False;Property;_OffsetUnits;Offset Units;2;0;Create;True;0;0;True;0;-1;-2;0;1;INT;0
Node;AmplifyShaderEditor.IntNode;7;-576.1314,330.1728;Float;False;Property;_OffsetFactor;Offset Factor;3;0;Create;True;0;0;True;0;-1;-2;0;1;INT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;204,-41;Float;False;True;2;Float;ASEMaterialInspector;0;1;SLZ/Texture Array Mod2x Decals;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;7;2;False;-1;3;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;True;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;True;0;True;7;0;True;6;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;0;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;0
WireConnection;2;1;3;0
WireConnection;5;0;2;0
WireConnection;5;1;4;0
WireConnection;1;0;5;0
ASEEND*/
//CHKSM=4392AE72ED3111C7B9EC5FE5B392F80CD694251F