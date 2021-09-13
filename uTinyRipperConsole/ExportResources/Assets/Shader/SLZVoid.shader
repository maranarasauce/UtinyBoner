// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SDK/Void"
{
	Properties
	{
		_OffsetDistance("Offset Distance", Vector) = (1,0,0,0)
		_TextureScaling("Texture Scaling", Float) = 1
		[NoScaleOffset]_BackgroundTexture("Background Texture", 2D) = "white" {}
		_DistortBackground("Distort Background", Float) = 0.1
		_DistortEmission("Distort Emission", Float) = 0.1
		_Emission("Emission", 2D) = "white" {}
		[HDR]_EmissionColor("EmissionColor", Color) = (0,0,0,0)
		_Distortion("Distortion", 2D) = "white" {}
		_BRDFLUT("BRDFLUT", 2D) = "white" {}
		        _CloneTransparency("Cloned Transparency", Range(0,1))= 0.5
				_CloneTransparencyStart("Start Transparency", Range(0,1))= 1.0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
	}
	
	SubShader
	{
		
		
        Tags {"RenderType"="TransparentCutout" "Queue"="Transparent"}
		LOD 100

		CGINCLUDE
		 #pragma target 3.0
		 ENDCG
		Blend Off
		Cull Off
		ColorMask RGBA
		ZWrite On
		ZTest LEqual
		Offset 0 , 0

        	Pass
		{
            Tags { "RenderType"="Opaque" }
            //Blend SrcAlpha OneMinusSrcAlpha
           // ZWrite Off
            Cull Off

			Name "Main"
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#pragma multi_compile _Opaque
            #define DIR_MULTIPLIER float3(0,0,0)
			#include "Voidpass.cginc"
			 
			ENDCG
		}
		
		
	///UP	
		Pass
		{
            Tags { "RenderType"="Transparent" }
            Blend SrcAlpha OneMinusSrcAlpha, OneMinusDstColor one
            ZWrite Off
            Cull Back

			Name "Up 0"
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
            #define DIR_MULTIPLIER float3(0,0.3333,0)
			#include "Voidpass.cginc"
			ENDCG
		}

        		Pass
		{
            Tags { "RenderType"="Transparent" }
            Blend SrcAlpha OneMinusSrcAlpha, OneMinusDstColor one
            ZWrite Off
            Cull Back
			Name "Up 1"
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
            #define DIR_MULTIPLIER float3(0,0.6666,0)
			#include "Voidpass.cginc"
			ENDCG
		}

        // Pass
        // {
        //     Tags { "RenderType"="Transparent" }
        //     Blend SrcAlpha OneMinusSrcAlpha
        //     ZWrite Off
        //      Cull Back           
		// 	Name "Up 2"
			
		// 	CGPROGRAM
		// 	#pragma vertex vert
		// 	#pragma fragment frag
		// 	#pragma multi_compile_instancing
        //     #define DIR_MULTIPLIER float3(0,1.0,0)
		// 	#include "Voidpass.cginc"
		// 	ENDCG
		// }
        ///DOWN
        		Pass
		{
            Tags { "RenderType"="Transparent" }
            Blend SrcAlpha OneMinusSrcAlpha, OneMinusDstColor one
            ZWrite Off
             Cull Back           
			Name "Down 0"
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
            #define DIR_MULTIPLIER float3(0,-0.3333,0)
			#include "Voidpass.cginc"
			ENDCG
		}

        		Pass
		{
            Tags { "RenderType"="Transparent" }
            Blend SrcAlpha OneMinusSrcAlpha, OneMinusDstColor one
            ZWrite Off
             Cull Back           
			Name "Down 1"
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
            #define DIR_MULTIPLIER float3(0,-0.6666,0)
			#include "Voidpass.cginc"
			ENDCG
		}
        // 		Pass
		// {
        //     Tags { "RenderType"="Transparent" }
        //     Blend SrcAlpha OneMinusSrcAlpha
        //     ZWrite Off
        //      Cull Back           
		// 	Name "Down 2"
			
		// 	CGPROGRAM
		// 	#pragma vertex vert
		// 	#pragma fragment frag
		// 	#pragma multi_compile_instancing
        //     #define DIR_MULTIPLIER float3(0,-1.0,0)
		// 	#include "Voidpass.cginc"
		// 	ENDCG
		// }
        ///FORWARD
                		Pass
		{
            Tags { "RenderType"="Transparent" }
            Blend SrcAlpha OneMinusSrcAlpha, OneMinusDstColor one
            ZWrite Off
             Cull Back           
			Name "Fwd 0"
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
            #define DIR_MULTIPLIER float3(0,0,0.3333)
			#include "Voidpass.cginc"
			ENDCG
		}
        Pass
		{
            Tags { "RenderType"="Transparent" }
            Blend SrcAlpha OneMinusSrcAlpha, OneMinusDstColor one
            ZWrite Off
             Cull Back           
			Name "Fwd 1"
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
            #define DIR_MULTIPLIER float3(0,0,0.6666)
			#include "Voidpass.cginc"
			ENDCG
		}
        // Pass
		// {
        //     Tags { "RenderType"="Transparent" }
        //     Blend SrcAlpha OneMinusSrcAlpha
        //     ZWrite Off
        //      Cull Back           
		// 	Name "Fwd 1"
			
		// 	CGPROGRAM
		// 	#pragma vertex vert
		// 	#pragma fragment frag
		// 	#pragma multi_compile_instancing
        //     #define DIR_MULTIPLIER float3(0,0,1)
		// 	#include "Voidpass.cginc"
		// 	ENDCG
		// }

        ///BACKWARD
                		Pass
		{
            Tags { "RenderType"="Transparent" }
            Blend SrcAlpha OneMinusSrcAlpha, OneMinusDstColor one
            ZWrite Off
             Cull Back           
			Name "Back 0"
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
            #define DIR_MULTIPLIER float3(0,0,-0.3333)
			#include "Voidpass.cginc"
			ENDCG
		}
        Pass
		{
            Tags { "RenderType"="Transparent" }
            Blend SrcAlpha OneMinusSrcAlpha, OneMinusDstColor one
            ZWrite Off
             Cull Back           
			Name "Back 1"
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
            #define DIR_MULTIPLIER float3(0,0,-0.6666)
			#include "Voidpass.cginc"
			ENDCG
		}
        // Pass
		// {
        //     Tags { "RenderType"="Transparent" }
        //     Blend SrcAlpha OneMinusSrcAlpha
        //     ZWrite Off
        //      Cull Back           
		// 	Name "Back 1"
			
		// 	CGPROGRAM
		// 	#pragma vertex vert
		// 	#pragma fragment frag
		// 	#pragma multi_compile_instancing
        //     #define DIR_MULTIPLIER float3(0,0,-1)
		// 	#include "Voidpass.cginc"
		// 	ENDCG
		// }
        ///RIGHT

                        		Pass
		{
            Tags { "RenderType"="Transparent" }
            Blend SrcAlpha OneMinusSrcAlpha, OneMinusDstColor one
            ZWrite Off
             Cull Back           
			Name "Right 0"
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
            #define DIR_MULTIPLIER float3(-0.3333,0,0)
			#include "Voidpass.cginc"
			ENDCG
		}
        Pass
		{
            Tags { "RenderType"="Transparent" }
            Blend SrcAlpha OneMinusSrcAlpha, OneMinusDstColor one
            ZWrite Off
             Cull Back           
			Name "Right 1"
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
            #define DIR_MULTIPLIER float3(-0.6666,0,0)
			#include "Voidpass.cginc"
			ENDCG
		}
        // Pass
		// {
        //     Tags { "RenderType"="Transparent" }
        //     Blend SrcAlpha OneMinusSrcAlpha
        //     ZWrite Off
        //      Cull Back           
		// 	Name "Right 1"
			
		// 	CGPROGRAM
		// 	#pragma vertex vert
		// 	#pragma fragment frag
		// 	#pragma multi_compile_instancing
        //     #define DIR_MULTIPLIER float3(-1,0,0)
		// 	#include "Voidpass.cginc"
		// 	ENDCG
		// }
        
        ////LEFT

         	Pass
		{
            Tags { "RenderType"="Transparent" }
            Blend SrcAlpha OneMinusSrcAlpha, OneMinusDstColor one
            ZWrite Off
             Cull Back           
			Name "Left 0"
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
            #define DIR_MULTIPLIER float3(0.3333,0,0)
			#include "Voidpass.cginc"
			ENDCG
		}
        Pass
		{
            Tags { "RenderType"="Transparent" }
            Blend SrcAlpha OneMinusSrcAlpha, OneMinusDstColor One
            ZWrite Off
             Cull Back           
			Name "Left 1"
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
            #define DIR_MULTIPLIER float3(0.6666,0,0)
			#include "Voidpass.cginc"
			ENDCG
		}
        // Pass
		// {
        //     Tags { "RenderType"="Transparent" }
        //     Blend SrcAlpha OneMinusSrcAlpha
        //     ZWrite Off
        //      Cull Back           
		// 	Name "Left 1"
			
		// 	CGPROGRAM
		// 	#pragma vertex vert
		// 	#pragma fragment frag
		// 	#pragma multi_compile_instancing
        //     #define DIR_MULTIPLIER float3(1,0,0)
		// 	#include "Voidpass.cginc"
		// 	ENDCG
		// }



	}

	
}
