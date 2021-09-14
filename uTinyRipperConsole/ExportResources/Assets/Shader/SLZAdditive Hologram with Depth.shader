Shader "SLZ/Additive Hologram with Depth"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [HDR]_Color("Color", Color) = (1,1,1,1)
        _DepthOffset("Depth Blend", float) = 0
        [NoScaleOffset]_ScanlinesTex ("Scanlines texture", 2D) = "grey" {}
        _Scanrate("Scanrate", float ) = 0.1
        _ScanLineDepthMultiplier("Depth Scanlines", vector) = (1,1,1,1)
        [Toggle(_AlphaMultiplyEmission)] AlphaMultiply ("Alpha Map Multiply", Int) = 0

    }
    SubShader
    {
        Tags { "RenderType"="No_shadows" "Queue" = "Transparent"}
        LOD 100

        Pass
        {
			CGINCLUDE
			#pragma target 3.0
			ENDCG
			Blend One One
			ColorMask RGBA
			ZWrite Off
			ZTest LEqual
			Offset 0 , 0
			
			Cull Off
	


            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            // make fog work
          //  #pragma multi_compile_fog
            #pragma shader_feature _AlphaMultiplyEmission
            #include "UnityCG.cginc"
            



            struct appdata
            {
                UNITY_VERTEX_INPUT_INSTANCE_ID
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 worldPos : TEXCOORD2; // DEPTH WRITE TWEAK (added .w component to encode eyeDepth)
                fixed4 color : COLOR;		

            };

            struct v2f
            {
                UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
                float2 uv : TEXCOORD0;
                float4 worldPos : TEXCOORD2;
           //     UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR;		
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _ScanlinesTex;
            float _DepthOffset;
            float _Scanrate;
            float4 _ScanLineDepthMultiplier;
            //Color _Color;

            UNITY_INSTANCING_BUFFER_START(InstanceProperties)
                UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
            UNITY_INSTANCING_BUFFER_END(InstanceProperties)

            #define TheColor UNITY_ACCESS_INSTANCED_PROP(InstanceProperties,_Color);

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_INITIALIZE_OUTPUT(v2f,o);
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v,o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color = v.color;
            //    UNITY_TRANSFER_FOG(o,o.vertex);

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldPos.xyz = worldPos; // DEPTH WRITE TWEAK (set .xyz channels)
                COMPUTE_EYEDEPTH(o.worldPos.w); // DEPTH WRITE TWEAK

                return o;
            }

            fixed4 frag (v2f i, out float outDepth : SV_Depth) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);

                float3 worldPos = i.worldPos.xyz; // DEPTH WRITE TWEAK (take actual worldPos part explicitly using xyz swizzling mask)

                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv) * i.color * TheColor;
                #if _AlphaMultiplyEmission
                col.rgb *= col.a;
                #endif

                float scanlines = tex2D (_ScanlinesTex, i.uv * _ScanLineDepthMultiplier.zw + float2(0,frac(_Time.g * _Scanrate) ) );
    
                col.rgb *= scanlines;
                // apply fog
            //    UNITY_APPLY_FOG(i.fogCoord, col);

                float d = (tex2D(_ScanlinesTex, i.uv * _ScanLineDepthMultiplier.xy).r - 0.5 ) * 2;

                float depthWithOffset = i.worldPos.w + (_DepthOffset * d);

                outDepth = (1.0 - depthWithOffset * _ZBufferParams.w) / (depthWithOffset * _ZBufferParams.z) ;

                return col;
            }
            ENDCG
        }
    }
}
