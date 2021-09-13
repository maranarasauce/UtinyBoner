// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SDK/Laser"
{
	Properties
	{
		_LaserVector3("_LaserVector3", Vector) = (0,0,1,0)
		_Tiling("Tiling", Float) = 1
		_Noise("Noise", 2D) = "gray" {}
		[HDR]_Color("Color", Color) = (0,1,0,0)
		_3dNoise("3dNoise", 3D) = "white" {}
		_uniformfog("uniformfog", Range( 0 , 1)) = 0
		_Intensity("Intensity", Float) = 0
		_OffsetFactor("Offset Factor", Int) = 0
		_OffsetUnits("Offset Units", Int) = 0
		_MinIntensitiy("Min Intensitiy", Range( 0 , 1)) = 0.1
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
			#define ASE_TEXTURE_PARAMS(textureName) textureName
			


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
				float4 ase_color : COLOR;
				float4 ase_texcoord2 : TEXCOORD2;
			};

			uniform int _OffsetFactor;
			uniform int _OffsetUnits;
			uniform float3 _LaserVector3;
			uniform float _MinIntensitiy;
			uniform float _Intensity;
			uniform float4 _Color;
			uniform sampler2D _Noise;
			uniform float _Tiling;
			uniform sampler3D _3dNoise;
			uniform float _uniformfog;
			inline float4 TriplanarSamplingSF( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
			{
				float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
				projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
				float3 nsign = sign( worldNormal );
				half4 xNorm; half4 yNorm; half4 zNorm;
				xNorm = ( tex2D( ASE_TEXTURE_PARAMS( topTexMap ), tiling * worldPos.zy * float2( nsign.x, 1.0 ) ) );
				yNorm = ( tex2D( ASE_TEXTURE_PARAMS( topTexMap ), tiling * worldPos.xz * float2( nsign.y, 1.0 ) ) );
				zNorm = ( tex2D( ASE_TEXTURE_PARAMS( topTexMap ), tiling * worldPos.xy * float2( -nsign.z, 1.0 ) ) );
				return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
			}
			
			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.ase_texcoord.xyz = ase_worldPos;
				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord2.xyz = ase_worldNormal;
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				o.ase_color = v.color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.w = 0;
				o.ase_texcoord1.zw = 0;
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
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				float3 ase_worldPos = i.ase_texcoord.xyz;
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(ase_worldPos);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float dotResult1 = dot( ase_worldViewDir , _LaserVector3 );
				float clampResult89 = clamp( ( ( dotResult1 + 1.0 ) * 0.5 ) , _MinIntensitiy , 1.0 );
				float2 uv0103 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float3 ase_worldNormal = i.ase_texcoord2.xyz;
				float4 triplanar19 = TriplanarSamplingSF( _Noise, ase_worldPos, ase_worldNormal, 0.0, _Tiling, 1.0, 0 );
				float4 temp_cast_1 = (1.0).xxxx;
				float4 lerpResult37 = lerp( ( tex3D( _3dNoise, ( ase_worldPos * float3( 0.03333,0.03333,0.03333 ) ) ) * tex3D( _3dNoise, ( ase_worldPos * float3( 0.1,0.1,0.1 ) ) ) ) , temp_cast_1 , _uniformfog);
				
				
				finalColor = max( ( clampResult89 * _Intensity * ( 1.0 - uv0103.y ) * i.ase_color * _Color * triplanar19 * lerpResult37 ) , float4( 0,0,0,0 ) );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=16900
247;593;1362;409;2158.772;106.7677;1;True;True
Node;AmplifyShaderEditor.Vector3Node;9;-765.0245,77.5334;Float;False;Property;_LaserVector3;_LaserVector3;0;0;Create;True;0;0;False;0;0,0,1;1,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;31;-190.0337,397.1747;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;2;-948.9164,-342.8629;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;1;-729.9703,-305.5392;Float;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;95.97842,573.3421;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0.1,0.1,0.1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;42.39294,370.058;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0.03333,0.03333,0.03333;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexturePropertyNode;33;-55.02156,164.3421;Float;True;Property;_3dNoise;3dNoise;5;0;Create;True;0;0;False;0;None;6b8eb3f2e6fc9e84ab5b30e166fbe3d6;False;white;LockedToTexture3D;Texture3D;0;1;SAMPLER3D;0
Node;AmplifyShaderEditor.SamplerNode;26;264.9662,277.1747;Float;True;Property;_VLB_NoiseTex3D;_VLB_NoiseTex3D;4;0;Create;True;0;0;False;0;None;None;True;1;False;white;LockedToTexture3D;False;Instance;-1;Auto;Texture3D;6;0;SAMPLER2D;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;85;-508.457,-465.3818;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;34;261.9786,495.3421;Float;True;Property;_TextureSample0;Texture Sample 0;4;0;Create;True;0;0;False;0;None;None;True;1;False;white;LockedToTexture3D;False;Instance;-1;Auto;Texture3D;6;0;SAMPLER2D;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;103;-1597.772,-42.76767;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;90;-4.755432,-572.984;Float;False;Property;_MinIntensitiy;Min Intensitiy;10;0;Create;True;0;0;False;0;0.1;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;20;-1409.024,223.5334;Float;True;Property;_Noise;Noise;2;0;Create;True;0;0;False;0;None;3014cb913a0834e4ea2428071a3b20e1;False;gray;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-2019.661,395.1832;Float;False;Property;_Tiling;Tiling;1;0;Create;True;0;0;False;0;1;9.96;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;104;-1346.772,-27.76767;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;86;-244.457,-467.3818;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;786.3932,583.058;Float;False;Constant;_Float0;Float 0;6;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;688.7901,228.2423;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;41;987.3932,501.058;Float;False;Property;_uniformfog;uniformfog;6;0;Create;True;0;0;False;0;0;0.13;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;97;-1410.073,125.6048;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TriplanarNode;19;-949.024,223.5334;Float;True;Spherical;World;False;Top Texture 0;_TopTexture0;gray;-1;None;Mid Texture 0;_MidTexture0;white;-1;None;Bot Texture 0;_BotTexture0;white;-1;None;Triplanar Sampler;False;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;45;560.0096,-50.04142;Float;False;Property;_Intensity;Intensity;7;0;Create;True;0;0;False;0;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;22;530.4923,-210.9589;Float;False;Property;_Color;Color;3;1;[HDR];Create;True;0;0;False;0;0,1,0,0;0,1,0,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;48;565.2511,41.31428;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;37;964.8276,226.9459;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;89;92.98236,-396.4216;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;975.9696,-43.11742;Float;True;7;7;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;FLOAT4;0,0,0,0;False;6;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-1727.448,538.7517;Float;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FractNode;64;-1438.407,604.4266;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.IntNode;49;1545.539,162.4031;Float;False;Property;_OffsetFactor;Offset Factor;8;0;Create;True;0;0;True;0;0;-2;0;1;INT;0
Node;AmplifyShaderEditor.PosFromTransformMatrix;93;-2172.11,95.77969;Float;False;1;0;FLOAT4x4;1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.MMatrixNode;98;-2336.583,24.22546;Float;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.VectorFromMatrixNode;101;-2138.085,-28.02408;Float;False;Row;3;1;0;FLOAT4x4;1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldToObjectMatrix;99;-2446.205,200.4091;Float;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.DistanceOpNode;91;195.7296,-44.93008;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;95;-1838.11,144.7797;Float;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ObjectToWorldMatrixNode;94;-2491.452,72.9053;Float;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.IntNode;50;1560.539,244.4031;Float;False;Property;_OffsetUnits;Offset Units;9;0;Create;True;0;0;True;0;0;-2;0;1;INT;0
Node;AmplifyShaderEditor.SamplerNode;52;-993.6301,562.3286;Float;True;Property;_TextureSample1;Texture Sample 1;10;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;40;698.3932,372.058;Float;False;Property;_Color0;Color 0;4;0;Create;True;0;0;False;0;1,1,1,0;0,0,0,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FractNode;96;-1592.11,108.7797;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;53;-2453.63,395.3286;Float;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;102;-1879.106,-20.05547;Float;False;Constant;_Vector0;Vector 0;11;0;Create;True;0;0;False;0;-1.39,1.89,-4.4;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMaxOpNode;46;1322.821,-46.4845;Float;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;47;1979.189,-117.194;Float;False;True;2;Float;ASEMaterialInspector;0;1;SLZ/Laser;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;4;1;False;-1;1;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;True;False;True;2;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;0;False;-1;True;True;0;True;49;0;True;50;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;0;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;0
WireConnection;1;0;2;0
WireConnection;1;1;9;0
WireConnection;35;0;31;0
WireConnection;43;0;31;0
WireConnection;26;0;33;0
WireConnection;26;1;43;0
WireConnection;85;0;1;0
WireConnection;34;0;33;0
WireConnection;34;1;35;0
WireConnection;104;0;103;2
WireConnection;86;0;85;0
WireConnection;38;0;26;0
WireConnection;38;1;34;0
WireConnection;97;0;104;0
WireConnection;19;0;20;0
WireConnection;19;3;21;0
WireConnection;37;0;38;0
WireConnection;37;1;42;0
WireConnection;37;2;41;0
WireConnection;89;0;86;0
WireConnection;89;1;90;0
WireConnection;23;0;89;0
WireConnection;23;1;45;0
WireConnection;23;2;97;0
WireConnection;23;3;48;0
WireConnection;23;4;22;0
WireConnection;23;5;19;0
WireConnection;23;6;37;0
WireConnection;54;0;53;0
WireConnection;54;1;21;0
WireConnection;64;0;54;0
WireConnection;93;0;99;0
WireConnection;101;0;98;0
WireConnection;95;0;102;0
WireConnection;95;1;53;0
WireConnection;52;0;20;0
WireConnection;96;0;95;0
WireConnection;46;0;23;0
WireConnection;47;0;46;0
ASEEND*/
//CHKSM=DA55E33404C7460F2A2578406FDEA19231610DD3