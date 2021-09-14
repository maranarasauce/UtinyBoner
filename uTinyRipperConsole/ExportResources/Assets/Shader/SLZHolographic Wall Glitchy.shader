Shader "SDK/HolographicWallGlitchy" { // SLZ/Holographic Wall Glitchy
	Properties {
		_MainTex ("MainTex", 2D) = "white" {}
		[NoScaleOffset] _CubeBG3 ("CubeBG3", Cube) = "black" {}
		[NoScaleOffset] _CubeBG2 ("CubeBG2", Cube) = "black" {}
		[NoScaleOffset] _CubeBG ("CubeBG", Cube) = "black" {}
		_Color ("Color", Vector) = (0,0,0,0)
		[HDR] _ScreenColor ("ScreenColor", Vector) = (1,1,1,1)
		_BumpMap ("BumpMap", 2D) = "bump" {}
		_NormalScale ("NormalScale", Float) = 1
		_EmissionMask ("Emission Mask", 2D) = "white" {}
		_Smoothness ("Smoothness", Range(0, 1)) = 0
		_Metallic ("Metallic", Range(0, 1)) = 0
		_FresnelBlur ("FresnelBlur", Range(0, 10)) = 0
		_Pos ("Pos", Vector) = (0,0,0,0)
		_Pos2 ("Pos2", Vector) = (0,0,0,0)
		_Boxscale ("Box scale", Vector) = (0,0,0,0)
		_ScreenTimeGlitch ("Screen Time Glitch", Float) = 0.1
		_PixelCount ("PixelCount", Float) = 128
		_PlenopticEffect ("Plenoptic Effect", Float) = 0
		_NoiseIntensity ("Noise Intensity", Float) = 0
		_NoiseSize ("Noise Size", Vector) = (0.01,3,0,0)
		[Gamma] _Masking ("Masking", 2D) = "gray" {}
		_Screen1 ("Screen 1", Range(0, 1)) = 1
		_Screen2 ("Screen 2", Range(0, 1)) = 1
		_Screen3 ("Screen 3", Range(0, 1)) = 1
		_ScreenBrightness ("Screen Brightness", Range(0, 1)) = 1
		[HideInInspector] _texcoord ("", 2D) = "white" {}
		[Space(20)] [Header(General Properties)] [KeywordEnum( Specular_Metallic, Anisotropic_Gloss, Retroreflective )] S ("Specular mode", Float) = 0
		g_flFresnelFalloff ("Fresnel Falloff Scalar", Range(0, 10)) = 1
		g_flFresnelExponent ("Fresnel Exponent", Range(0.5, 10)) = 5
		[Space(5)] [Toggle( _BRDFMAP )] EnableBRDFMAP ("Enable BRDF remap", Float) = 0
		[NoScaleOffset] g_tBRDFMap ("BRDF LUT", 2D) = "grey" {}
		[Space(10)] [Header(Override Properties)] g_flCubeMapScalar ("Cube Map Scalar", Range(0, 2)) = 1
		[Toggle( S_RECEIVE_SHADOWS )] ReceiveShadows ("Receive Shadows", Float) = 1
		[Toggle( _FLUORESCENCEMAP )] Fluorescence ("Enable Fluorescence", Float) = 0
	}
	SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
	CustomEditor "ASEMaterialInspector"
}