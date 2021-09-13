
			// #pragma vertex vert
			// #pragma fragment frag
			#include "UnityCG.cginc"
			

			// struct appdata
			// {
			// 	float4 vertex : POSITION;
			// 	float4 color : COLOR;
			// 	UNITY_VERTEX_INPUT_INSTANCE_ID
			// 	float3 ase_normal : NORMAL;
			// };
			
			// struct v2f
			// {
			// 	float4 vertex : SV_POSITION;
			// 	UNITY_VERTEX_INPUT_INSTANCE_ID
			// 	UNITY_VERTEX_OUTPUT_STEREO
			// 	float4 ase_texcoord : TEXCOORD0;
			// 	float3 ase_normal : NORMAL;
			// 	float4 ase_texcoord1 : TEXCOORD1;
			// };

			// uniform float3 _OffsetDistance;
			// uniform samplerCUBE _Texture0;
			// uniform float _CloneTransparency;
			
			// v2f vert ( appdata v )
			// {
			// 	v2f o;
			// 	UNITY_SETUP_INSTANCE_ID(v);
			// 	UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
			// 	UNITY_TRANSFER_INSTANCE_ID(v, o);

			// 	float3 ase_worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
			// 	o.ase_texcoord.xyz = ase_worldPos;
			// 	float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
			// 	o.ase_texcoord1.xyz = ase_worldNormal;
				
			// 	o.ase_normal = v.ase_normal;
				
			// 	//setting value to unused interpolator channels and avoid initialization warnings
			// 	o.ase_texcoord.w = 0;
			// 	o.ase_texcoord1.w = 0;
			// 	float3 vertexValue = _OffsetDistance * DIR_MULTIPLIER;
			// 	// #if ASE_ABSOLUTE_VERTEX_POS
			// 	// v.vertex.xyz = vertexValue;
			// 	// #else
			// 	 //v.vertex.xyz += vertexValue;
			// 	v.vertex.xyz += mul(unity_WorldToObject ,vertexValue.xyz);
			// 	//v.vertex.xyz = mul(unity_WorldToObject ,ase_worldPos.xyz + vertexValue).xyz;
			// 	//v.vertex.xyz = ase_worldPos + vertexValue;
			// 	//#endif
			// 	o.vertex = UnityObjectToClipPos(v.vertex);
			// 	return o;
            // };

			// 	fixed4 frag (v2f i ) : SV_Target
			// {
			// 	UNITY_SETUP_INSTANCE_ID(i);
			// 	fixed4 finalColor;
			// 	float3 ase_worldPos = i.ase_texcoord.xyz;
			// 	float3 ase_worldViewDir = UnityWorldSpaceViewDir(ase_worldPos);
			// 	ase_worldViewDir = normalize(ase_worldViewDir);
			// 	float3 temp_output_99_0 = ( -ase_worldViewDir - i.ase_normal );
			// 	float3 ase_worldNormal = i.ase_texcoord1.xyz;
			// 	float fresnelNdotV72 = dot( ase_worldNormal, ase_worldViewDir );
			// 	float fresnelNode72 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV72, 1.0 ) );
				
				
			// 	finalColor = ( texCUBE( _Texture0, ( temp_output_99_0 + i.ase_normal ) ) * ( 1.0 - fresnelNode72 ) );
			// 	return finalColor * ( 1 - abs(DIR_MULTIPLIER.x + DIR_MULTIPLIER.y + DIR_MULTIPLIER.z) * _CloneTransparency );
			// 	return finalColor;

			// };

////////////////////////////////

			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float3 ase_normal : NORMAL;
			};

			uniform float3 _OffsetDistance;
			uniform float _CloneTransparency;
			uniform float _CloneTransparencyStart;
			uniform float4 _EmissionColor;
			uniform sampler2D _Emission;
			uniform float4 _Emission_ST;
			uniform sampler2D _Distortion;
			uniform float4 _Distortion_ST;
			uniform float _DistortEmission;
			uniform sampler2D _BackgroundTexture;
			uniform float _DistortBackground;
			uniform float _TextureScaling;
			uniform sampler2D _BRDFLUT;
			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);


				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord1.xyz = ase_worldNormal;
				float3 ase_worldTangent = UnityObjectToWorldDir(v.ase_tangent);
				o.ase_texcoord3.xyz = ase_worldTangent;
				float ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord4.xyz = ase_worldBitangent;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				o.ase_normal = v.ase_normal;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.w = 0;
				o.ase_texcoord1.w = 0;
				o.ase_texcoord2.zw = 0;
				o.ase_texcoord3.w = 0;
				o.ase_texcoord4.w = 0;
				float3 vertexValue = _OffsetDistance * DIR_MULTIPLIER;
				// #if ASE_ABSOLUTE_VERTEX_POS
				// v.vertex.xyz = vertexValue;
				// #else
				// v.vertex.xyz += vertexValue;
				// #endif
				v.vertex.xyz += mul(unity_WorldToObject ,vertexValue.xyz);
				float3 ase_worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.ase_texcoord.xyz = ase_worldPos;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				fixed4 finalColor;
				float3 ase_worldPos = i.ase_texcoord.xyz;
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(ase_worldPos);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = i.ase_texcoord1.xyz;
				float fresnelNdotV179 = dot( ase_worldNormal, ase_worldViewDir );
			//	float fresnelNode179 = max( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV179, 1.0 ), 0 );
				float temp_output_180_0 =1- max(1-fresnelNdotV179,0);
			//	float2 uv_Emission = i.ase_texcoord2.xy * _Emission_ST.xy + _Emission_ST.zw;
				float2 uv_Emission = (ase_worldPos.xy / ase_worldPos.z) * (_Emission_ST.xy) + _Emission_ST.zw;
			//	float2 uv_Distortion = i.ase_texcoord2.xy * _Distortion_ST.xy + _Distortion_ST.zw;
				float2 uv_Distortion = ase_worldViewDir.xy / ase_worldViewDir.z + _Distortion_ST.zw;
				float4 tex2DNode140 = tex2D( _Distortion, uv_Distortion );
				float3 ase_worldTangent = i.ase_texcoord3.xyz;
				float3 ase_worldBitangent = i.ase_texcoord4.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 ase_tanViewDir =  tanToWorld0 * ase_worldViewDir.x + tanToWorld1 * ase_worldViewDir.y  + tanToWorld2 * ase_worldViewDir.z;
				ase_tanViewDir = normalize(ase_tanViewDir);
				float2 Offset148 = ( ( tex2DNode140.g - 1 ) * ( ase_tanViewDir.xy / ase_tanViewDir.z ) * _DistortEmission ) + uv_Emission;
				float2 paralaxOffset139 = ParallaxOffset( tex2DNode140.r , _DistortBackground , -ase_worldViewDir );
				float3 worldparallax =  -ase_worldViewDir + float3( paralaxOffset139 ,  0.0 ) ;
				float4 Emission = ( float4(pow( temp_output_180_0 , 2.99 ).xxx,1 ) * _EmissionColor ) * tex2D( _Emission, Offset148 );
				float4 temp_output_141_0 = ( Emission * pow(Emission.aaaa,3) * ( ( tex2D( _BackgroundTexture, ( worldparallax.xy / worldparallax.z  * _TextureScaling ) ) + tex2D( _BackgroundTexture, ( ( worldparallax.yz / worldparallax.x ) * _TextureScaling ) ) + tex2D( _BackgroundTexture, ( ( worldparallax.zx / worldparallax.y ) * _TextureScaling ) ) ) * 0.33333 ) );
				float3 _Vector0 = float3(0,1,1);
				float cos173 = cos( 1.0 * _Time.y );
				float sin173 = sin( 1.0 * _Time.y );
				float2 rotator173 = mul( (_Vector0).xy - float2( 0,0 ) , float2x2( cos173 , -sin173 , sin173 , cos173 )) + float2( 0,0 );
				float temp_output_184_0 = (rotator173).x;
				float2 appendResult183 = (float2(temp_output_184_0 , _Vector0.z));
				float cos181 = cos( 0.87 * _Time.y );
				float sin181 = sin( 0.87 * _Time.y );
				float2 rotator181 = mul( appendResult183 - float2( 0,0 ) , float2x2( cos181 , -sin181 , sin181 , cos181 )) + float2( 0,0 );
				float3 appendResult185 = (float3(temp_output_184_0 , rotator181));
				float dotResult167 = dot( i.ase_normal , appendResult185 );
				float2 appendResult172 = (float2(dotResult167 , fresnelNdotV179));
				float4 appendResult107 = (float4((( temp_output_141_0 + ( tex2D( _BRDFLUT, appendResult172 ) * temp_output_141_0 ) )).rgb , max(0,temp_output_180_0) ));			
				
				finalColor = appendResult107;

				#if _Opaque
				return float4 (clamp( finalColor * ( 1 - abs(DIR_MULTIPLIER.x + DIR_MULTIPLIER.y + DIR_MULTIPLIER.z) * _CloneTransparency ), 0 , 1).rgb , 1) ;
				#else				
				return clamp( finalColor * ( 1 - abs(DIR_MULTIPLIER.x + DIR_MULTIPLIER.y + DIR_MULTIPLIER.z) * _CloneTransparency ) * float4(1,1,1,_CloneTransparencyStart), 0,1) ;
				#endif
			//return float4(1,0,0,1);
			}


            
