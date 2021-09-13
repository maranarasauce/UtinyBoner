Shader "SDK/StylizedFXShield" { // Stylized FX/Shield
	Properties {
		_DistortTexture ("Distort Texture", 2D) = "bump" {}
		[DistortSettingsProperty(Mesh)] _DistortSettings ("Settings", Vector) = (10,0,1,1)
		_MainTex ("Main Tex (Triplanar)", 2D) = "white" {}
		_MainTexScale ("Main Tex Scale", Float) = 0
		_MainTexScroll ("Main Tex Scroll", Float) = 0
		_MainTexStep ("Main Tex Step", Range(2, 64)) = 4
		[HDR] _NoiseColor1 ("Noise Color 1", Vector) = (0.5,0.5,0.5,0.5)
		[HDR] _NoiseColor2 ("Noise Color 2", Vector) = (0.5,0.5,0.5,0.5)
		_NoiseScale ("Noise Scale", Float) = 1
		_NoiseTimeScale ("Noise Time Scale", Range(0, 10)) = 0.25
		_NoiseStep ("Noise Step", Range(2, 64)) = 4
		[HDR] _IntersectColor ("Intersect Color", Vector) = (0.5,0.5,0.5,0.5)
		_IntersectPower ("Intersect Power", Range(0.1, 10)) = 1
		_IntersectStep ("Intersect Step", Range(2, 64)) = 4
		[HDR] _RimColor ("Rim Color", Vector) = (0.5,0.5,0.5,0.5)
		_RimPower ("Rim Power", Range(0.01, 10)) = 1
		_RimStep ("Rim Step", Range(2, 64)) = 4
		_FadeStrength ("Fade Strength", Range(-0.2, 0.2)) = 0
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
}