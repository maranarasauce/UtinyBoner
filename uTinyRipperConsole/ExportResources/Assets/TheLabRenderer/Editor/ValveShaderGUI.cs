// Copyright (c) Valve Corporation, All rights reserved. ======================================================================================================

#if ( UNITY_EDITOR )

using System;
using System.Collections.Generic;
using UnityEngine;

namespace UnityEditor
{
internal class ValveShaderGUI : ShaderGUI
{
	public enum BlendMode
	{
		Opaque,
		AlphaTest,
		AlphaBlend,
		Glass,
		Additive,
        Mod2x,
        Multiply
            // TODO: MaskedGlass that will require an additional grayscale texture to act as a standard alpha blend mask
        }

	public enum SpecularMode
	{
		None,
		BlinnPhong,
		Metallic,
		Anisotropic,
        Retroreflective
	}

    public enum VertexMode
    {

        None,
        Tint

    }

    public enum TexturePackingMode
    {
        None,      
        MAES,
        RMA,
        MAS
    }

    public enum DetailBlendMode
        {
            Multiply2x,
            Multiply,
            Add,
            Lerp
        }


	private static class Styles
	{
		public static GUIStyle optionsButton = "PaneOptions";
		public static GUIContent uvSetLabel = new GUIContent("UV Set");
		public static GUIContent[] uvSetOptions = new GUIContent[] { new GUIContent("UV channel 0"), new GUIContent("UV channel 1") };

		public static GUIContent unlitText = new GUIContent( "Unlit", "" );

		public static string emptyTootip = "";
		public static GUIContent albedoText = new GUIContent("Albedo", "Albedo (RGB) and Transparency (A)");
        public static GUIContent BRDFMapText = new GUIContent("BRDF LUT", "Remaps shading to color ramp. Compared to the normal, X is direction to the light, Y is direction from camera.");
        public static GUIContent colorMaskText = new GUIContent("Color Mask", "Multiplys albedo per color channel");
		public static GUIContent alphaCutoffText = new GUIContent("Alpha Cutoff", "Threshold for alpha cutoff");
        public static GUIContent FluorescenceText = new GUIContent("Fluorescence", "Fluorescence. Absorbs light and re-emits at a longer wavelength. MAX color value of this and albedo");
        public static GUIContent AbsorbanceText = new GUIContent("Absorbance Color", "Absorbance Color");
		public static GUIContent specularMapText = new GUIContent("Specular", "Reflectance (RGB) and Gloss (A)");
		public static GUIContent reflectanceMinText = new GUIContent( "Reflectance Min", "" );
		public static GUIContent reflectanceMaxText = new GUIContent( "Reflectance Max", "" );
        public static GUIContent metallicMapText = new GUIContent("Metallic", "Metallic (R), Gloss (A) ");
        public static GUIContent specularModText = new GUIContent("Smoothness Scaler", "Smoothness Multiplier");
        public static GUIContent anisotropicRatioText = new GUIContent("Anisotropic Ratio", "");
        public static GUIContent anisotropicRotationText = new GUIContent("Anisotropic Rotation", "");
        public static GUIContent smoothnessText = new GUIContent("Gloss", "");
        public static GUIContent normalMapText = new GUIContent("Normal", "Normal Map");
		public static GUIContent heightMapText = new GUIContent("Parallax Map", "Parallax Map (R), Float controls depth");
        public static GUIContent heightIterationsText = new GUIContent("Iterations", "More iterations reduces artifacts but makes material heavier. Use with care.");
        public static GUIContent heightOffsetText = new GUIContent("Zero Plane Offset","");
        public static GUIContent fresnelfallofftext = new GUIContent("Fresnel Falloff Scalar", "Added Fresnel falloff contribution");
        public static GUIContent fresnelExponentText = new GUIContent("Fresnel Exponent", "");
		public static GUIContent cubeMapScalarText = new GUIContent( "Cube Map Scalar", "Multiplier for overall reflections" );
        public static GUIContent NormalToOcclusionText = new GUIContent("Normal to Occlusion", "Add normal map to Occlusion");
		public static GUIContent occlusionText = new GUIContent("Occlusion", "Occlusion (G)");
		public static GUIContent occlusionStrengthDirectDiffuseText = new GUIContent( "Direct Diffuse", "" );
		public static GUIContent occlusionStrengthDirectSpecularText = new GUIContent( "Direct Specular", "" );
		public static GUIContent occlusionStrengthIndirectDiffuseText = new GUIContent( "Indirect Diffuse", "" );
		public static GUIContent occlusionStrengthIndirectSpecularText = new GUIContent( "Indirect Specular", "" );
		public static GUIContent emissionText = new GUIContent( "Emission", "Emission (RGB)" );
        public static GUIContent emissionFalloffText = new GUIContent("Falloff", "Emission Falloff");
		public static GUIContent detailMaskText = new GUIContent("Detail Mask", "Mask for Secondary Maps (A)");
		public static GUIContent detailAlbedoText = new GUIContent("Detail Albedo", "Detail Albedo (RGB) multiplied by 2");
		public static GUIContent detailNormalMapText = new GUIContent("Detail Normal", "Detail Normal Map");
        public static GUIContent castShadowsText = new GUIContent("Cast shadows", "");
		public static GUIContent receiveShadowsText = new GUIContent( "Receive Shadows", "" );
		public static GUIContent renderBackfacesText = new GUIContent( "Render Backfaces", "" );
        public static GUIContent emissiveMode = new GUIContent("Multiply Albedo", "Multiply emissive color with albedo");
		public static GUIContent overrideLightmapText = new GUIContent( "Override Lightmap", "Requires ValveOverrideLightmap.cs scrip on object" );
		public static GUIContent worldAlignedTextureText = new GUIContent( "World Aligned Texture", "" );
		public static GUIContent worldAlignedTextureSizeText = new GUIContent( "Size", "" );
		public static GUIContent worldAlignedTextureNormalText = new GUIContent( "Normal", "" );
		public static GUIContent worldAlignedTexturePositionText = new GUIContent( "World Position", "" );

		public static string whiteSpaceString = " ";
		public static string primaryMapsText = "Main Maps";
		public static string secondaryMapsText = "Secondary Maps";
        public static string OverridesMapsText = "Override Settings";
		public static string renderingMode = "Rendering Mode";
		public static string specularModeText = "Specular Workflow";
        public static string VertexModeText = "Vertex Mode";
        public static string PackingModeText = "Packing Mode";
        public static string DetailModeText = "Detail Blend Mode";
		public static GUIContent emissiveWarning = new GUIContent( "Emissive value is animated but the material has not been configured to support emissive. Please make sure the material itself has some amount of emissive." );
		public static GUIContent emissiveColorWarning = new GUIContent ("Ensure emissive color is non-black for emission to have effect.");
		public static readonly string[] blendNames = Enum.GetNames (typeof (BlendMode));
		public static readonly string[] specularNames = Enum.GetNames( typeof( SpecularMode ) );
        public static readonly string[] vertexNames = Enum.GetNames(typeof(VertexMode));
        public static readonly string[] PackingNames = Enum.GetNames(typeof(TexturePackingMode));
        public static readonly string[] detailNames = Enum.GetNames(typeof(DetailBlendMode));


	}

	MaterialProperty unlit = null;
	MaterialProperty blendMode = null;
    MaterialProperty emissiveMode = null;
	MaterialProperty specularMode = null;
    MaterialProperty vertexMode = null;
    MaterialProperty PackingMode = null;
    MaterialProperty DetailMode = null;
    MaterialProperty albedoMap = null;
    MaterialProperty BRDFMap = null;
    MaterialProperty colorMask = null;
	MaterialProperty albedoColor = null;
    MaterialProperty colorShift1 = null;
    MaterialProperty colorShift2 = null;
    MaterialProperty colorShift3 = null;
	MaterialProperty alphaCutoff = null;
	MaterialProperty specularMap = null;
	MaterialProperty specularColor = null;
	MaterialProperty reflectanceMin = null;
	MaterialProperty reflectanceMax = null;
	MaterialProperty metallicMap = null;
	MaterialProperty metallic = null;
    MaterialProperty SpecularMod = null;
	MaterialProperty smoothness = null;
    MaterialProperty AnisotropicRotation = null;
    MaterialProperty AnisotropicRatio = null;    
	MaterialProperty bumpScale = null;
	MaterialProperty bumpMap = null;
    MaterialProperty FresnelFalloffScalar = null;
    MaterialProperty FresnelExponent = null;
    MaterialProperty NormalToOcclusion = null;
	MaterialProperty cubeMapScalar = null;
	MaterialProperty occlusionStrength = null;
	MaterialProperty occlusionMap = null;
	MaterialProperty occlusionStrengthDirectDiffuse = null;
	MaterialProperty occlusionStrengthDirectSpecular = null;
	MaterialProperty occlusionStrengthIndirectDiffuse = null;
	MaterialProperty occlusionStrengthIndirectSpecular = null;
	MaterialProperty heigtMapScale = null;
	MaterialProperty heightMap = null;
    MaterialProperty heightIterations = null;
    MaterialProperty heightOffset = null;
    MaterialProperty emissionColorForRendering = null;
	MaterialProperty emissionMap = null;
    MaterialProperty emissionFalloff = null;
    MaterialProperty fluorescenceMap = null;
    MaterialProperty fluorescenceColor = null;
    MaterialProperty AbsorbanceColor = null;
    MaterialProperty detailMask = null;
	MaterialProperty detailAlbedoMap = null;
	MaterialProperty detailNormalMapScale = null;
	MaterialProperty detailNormalMap = null;
	MaterialProperty uvSetSecondary = null;
    MaterialProperty castShadows = null;
	MaterialProperty receiveShadows = null;
	MaterialProperty renderBackfaces = null;
	MaterialProperty overrideLightmap = null;
	MaterialProperty worldAlignedTexture = null;
	MaterialProperty worldAlignedTextureSize = null;
	MaterialProperty worldAlignedTextureNormal = null;
	MaterialProperty worldAlignedTexturePosition = null;
    MaterialProperty offsetFactor = null;
    MaterialProperty offsetUnits = null;

	MaterialEditor m_MaterialEditor;
	ColorPickerHDRConfig m_ColorPickerHDRConfig = new ColorPickerHDRConfig(0f, 99f, 1/99f, 3f);

	bool m_FirstTimeApply = true;

 


	public void FindProperties (MaterialProperty[] props)
	{
		unlit = FindProperty( "g_bUnlit", props );
		blendMode = FindProperty( "_Mode", props );
        emissiveMode = FindProperty("_EmissiveMode", props); 
		specularMode = FindProperty( "_SpecularMode", props );
        vertexMode = FindProperty("_VertexMode", props);
        PackingMode = FindProperty("_PackingMode", props);
        DetailMode = FindProperty("_DetailMode", props);
		albedoMap = FindProperty( "_MainTex", props );
        BRDFMap = FindProperty("g_tBRDFMap", props);
        colorMask = FindProperty("_ColorMask", props);
		albedoColor = FindProperty ("_Color", props);
        colorShift1 = FindProperty("_ColorShift1", props);
        colorShift2 = FindProperty("_ColorShift2", props);
        colorShift3 = FindProperty("_ColorShift3", props);
		alphaCutoff = FindProperty ("_Cutoff", props);
		specularMap = FindProperty ("_SpecGlossMap", props, false);
		specularColor = FindProperty ("_SpecColor", props, false);
		reflectanceMin = FindProperty( "g_flReflectanceMin", props );
		reflectanceMax = FindProperty( "g_flReflectanceMax", props );
		metallicMap = FindProperty ("_MetallicGlossMap", props, false);
		metallic = FindProperty ("_Metallic", props, false);
		smoothness = FindProperty ("_Glossiness", props);
        AnisotropicRatio = FindProperty("_AnisotropicRatio", props);
        AnisotropicRotation = FindProperty("_AnisotropicRotation", props);
        SpecularMod = FindProperty("_SpecMod", props);
		bumpScale = FindProperty ("_BumpScale", props);
		bumpMap = FindProperty ("_BumpMap", props);
		heigtMapScale = FindProperty ("_Parallax", props);
		heightMap = FindProperty("_ParallaxMap", props);
        heightIterations = FindProperty("_ParallaxIterations", props);  
        heightOffset = FindProperty("_ParallaxOffset", props);  
        FresnelFalloffScalar = FindProperty("g_flFresnelFalloff", props);
        FresnelExponent = FindProperty("g_flFresnelExponent", props);
        NormalToOcclusion = FindProperty("_NormalToOcclusion", props);
		cubeMapScalar = FindProperty( "g_flCubeMapScalar", props );
		occlusionStrength = FindProperty ("_OcclusionStrength", props);
		occlusionStrengthDirectDiffuse = FindProperty( "_OcclusionStrengthDirectDiffuse", props );
		occlusionStrengthDirectSpecular = FindProperty( "_OcclusionStrengthDirectSpecular", props );
		occlusionStrengthIndirectDiffuse = FindProperty( "_OcclusionStrengthIndirectDiffuse", props );
		occlusionStrengthIndirectSpecular = FindProperty( "_OcclusionStrengthIndirectSpecular", props );
		occlusionMap = FindProperty ("_OcclusionMap", props);
		emissionColorForRendering = FindProperty ("_EmissionColor", props);
		emissionMap = FindProperty ("_EmissionMap", props);
        emissionFalloff = FindProperty("_EmissionFalloff", props);
        fluorescenceMap = FindProperty ("_FluorescenceMap", props);
        fluorescenceColor = FindProperty ("_FluorescenceColor", props);
        AbsorbanceColor = FindProperty("_Absorbance", props);
        detailMask = FindProperty ("_DetailMask", props);
		detailAlbedoMap = FindProperty ("_DetailAlbedoMap", props);
		detailNormalMapScale = FindProperty ("_DetailNormalMapScale", props);
		detailNormalMap = FindProperty ("_DetailNormalMap", props);
		uvSetSecondary = FindProperty ("_UVSec", props);
        castShadows = FindProperty("g_bCastShadows", props);
		receiveShadows = FindProperty( "g_bReceiveShadows", props );
		renderBackfaces = FindProperty( "g_bRenderBackfaces", props );
		overrideLightmap = FindProperty( "g_tOverrideLightmap", props );
		worldAlignedTexture = FindProperty( "g_bWorldAlignedTexture", props, false );
		worldAlignedTextureSize = FindProperty( "g_vWorldAlignedTextureSize", props, worldAlignedTexture != null );
		worldAlignedTextureNormal = FindProperty( "g_vWorldAlignedTextureNormal", props, worldAlignedTexture != null );
		worldAlignedTexturePosition = FindProperty( "g_vWorldAlignedTexturePosition", props, worldAlignedTexture != null );
        offsetFactor = FindProperty("_OffsetFactor", props);
        offsetUnits = FindProperty("_OffsetUnits", props);
        
	}

	public override void OnGUI (MaterialEditor materialEditor, MaterialProperty[] props)
	{
                 
        FindProperties (props); // MaterialProperties can be animated so we do not cache them but fetch them every event to ensure animated values are updated correctly
		m_MaterialEditor = materialEditor;
		Material material = materialEditor.target as Material;

		ShaderPropertiesGUI (material);
        base.OnGUI(m_MaterialEditor, props);  //Default GUI, hid redundent properties shader side

            // Make sure that needed keywords are set up if we're switching some existing
            // material to a standard shader.
            if (m_FirstTimeApply)
		{
			SetMaterialKeywords (material);
			m_FirstTimeApply = false;
		}
	}

	public void Vector3GUI( GUIContent label, MaterialProperty materialProperty )
	{
		Vector4 v4 = materialProperty.vectorValue;
		Vector3 v3 = EditorGUILayout.Vector3Field( label, new Vector3( v4.x, v4.y, v4.z ) );
		materialProperty.vectorValue = new Vector4( v3.x, v3.y, v3.z, 0.0f );
	}

	public void ShaderPropertiesGUI (Material material)
	{
		// Use default labelWidth
		EditorGUIUtility.labelWidth = 0f;

		// Detect any changes to the material
		EditorGUI.BeginChangeCheck();
		{
			m_MaterialEditor.ShaderProperty( unlit, Styles.unlitText.text );
			bool bUnlit = ( unlit.floatValue != 0.0f );

			BlendModePopup();

            VertexModePopup();



                if (!bUnlit)
                {
                    SpecularModePopup();

                    if ((SpecularMode)material.GetInt("_SpecularMode") == SpecularMode.Metallic)
                    {
                        TexturePackingPopup();
                    }
                    else
                    {
                        material.SetInt("_PackingMode", (int)TexturePackingMode.None) ;
                    }
            }

            

            m_MaterialEditor.ShaderProperty(castShadows, Styles.castShadowsText.text);
            bool bCastShadows = (castShadows.floatValue != 0.0f);

			if ( !bUnlit )
			{
				m_MaterialEditor.ShaderProperty( receiveShadows, Styles.receiveShadowsText.text );
			}

			m_MaterialEditor.ShaderProperty( renderBackfaces, Styles.renderBackfacesText.text );

			EditorGUILayout.Space();

			GUILayout.Label( Styles.primaryMapsText, EditorStyles.boldLabel );
			DoAlbedoArea( material );


            
			if ( !bUnlit )
			{
                DoFluorescenceArea(material);
                DoSpecularMetallicArea(material);
                m_MaterialEditor.ShaderProperty(FresnelFalloffScalar, Styles.fresnelfallofftext.text, 0);
                m_MaterialEditor.ShaderProperty(FresnelExponent, Styles.fresnelExponentText.text, 0);
				m_MaterialEditor.TexturePropertySingleLine( Styles.normalMapText, bumpMap, bumpMap.textureValue != null ? bumpScale : null );
                if (bumpMap.textureValue != null)  m_MaterialEditor.ShaderProperty(NormalToOcclusion, Styles.NormalToOcclusionText.text, 1);

                if ((TexturePackingMode)material.GetInt("_PackingMode") == TexturePackingMode.None)
                {
                    m_MaterialEditor.TexturePropertySingleLine(Styles.occlusionText, occlusionMap, occlusionMap.textureValue != null ? occlusionStrength : null);

                }
                else
                {
                    m_MaterialEditor.RangeProperty(occlusionStrength, "Occlusion");
                }

                if (occlusionMap.textureValue != null || NormalToOcclusion.floatValue > 0 || (TexturePackingMode)material.GetInt("_PackingMode") != TexturePackingMode.MAES)
				{
					m_MaterialEditor.ShaderProperty( occlusionStrengthDirectDiffuse, Styles.occlusionStrengthDirectDiffuseText.text, 2 );
					m_MaterialEditor.ShaderProperty( occlusionStrengthDirectSpecular, Styles.occlusionStrengthDirectSpecularText.text, 2 );
					m_MaterialEditor.ShaderProperty( occlusionStrengthIndirectDiffuse, Styles.occlusionStrengthIndirectDiffuseText.text, 2 );
					m_MaterialEditor.ShaderProperty( occlusionStrengthIndirectSpecular, Styles.occlusionStrengthIndirectSpecularText.text, 2 );
				}

	
			}

            DoEmissionArea(material);


                m_MaterialEditor.TexturePropertySingleLine(Styles.heightMapText, heightMap, heightMap.textureValue != null ? heigtMapScale : null);

                if (heightMap.textureValue != null)
                {
 
                    float ParaIte = (material.GetFloat("_ParallaxIterations"));
                    if ((ParaIte % 1) != 0) ParaIte -= ParaIte % 1;
                    material.SetFloat("_ParallaxIterations", ParaIte);              
                    m_MaterialEditor.ShaderProperty(heightIterations, Styles.heightIterationsText, 2);
                   // m_MaterialEditor.ShaderProperty(heightOffset, Styles.heightOffsetText, 2);


                }


                EditorGUI.BeginChangeCheck(); // !!! AV - This is from Unity's script. Can these Begin/End calls be nested like this?

            		
			m_MaterialEditor.TextureScaleOffsetProperty( albedoMap );
			if ( EditorGUI.EndChangeCheck() )
			{
				emissionMap.textureScaleAndOffset = albedoMap.textureScaleAndOffset; // Apply the main texture scale and offset to the emission texture as well, for Enlighten's sake
			}




			// Secondary properties
			GUILayout.Label( Styles.secondaryMapsText, EditorStyles.boldLabel );

                DoBRDFArea(material);
                DoColorShiftArea(material);

                EditorGUILayout.Space();


        

            DetailModePopup();

                m_MaterialEditor.TexturePropertySingleLine(Styles.detailMaskText, detailMask);

                m_MaterialEditor.TexturePropertySingleLine( Styles.detailAlbedoText, detailAlbedoMap );
			if ( !bUnlit )
			{
				m_MaterialEditor.TexturePropertySingleLine( Styles.detailNormalMapText, detailNormalMap, detailNormalMapScale );
			}
			m_MaterialEditor.TextureScaleOffsetProperty( detailAlbedoMap );
			m_MaterialEditor.ShaderProperty( uvSetSecondary, Styles.uvSetLabel.text );

                //Advanced Options


                //overriding settings
                GUILayout.Label(Styles.OverridesMapsText, EditorStyles.boldLabel);

                if (!bUnlit)
                {
                    m_MaterialEditor.TexturePropertySingleLine(Styles.overrideLightmapText, overrideLightmap);
                    m_MaterialEditor.ShaderProperty(SpecularMod, Styles.specularModText);
                    m_MaterialEditor.ShaderProperty(cubeMapScalar, Styles.cubeMapScalarText.text, 0);
                }


                if (worldAlignedTexture != null)
                {
                    m_MaterialEditor.ShaderProperty(worldAlignedTexture, Styles.worldAlignedTextureText.text);

                    if (worldAlignedTexture.floatValue != 0.0f)
                    {
                        EditorGUI.indentLevel = 2;
                        Vector3GUI(Styles.worldAlignedTextureSizeText, worldAlignedTextureSize);
                        Vector3GUI(Styles.worldAlignedTextureNormalText, worldAlignedTextureNormal);
                        Vector3GUI(Styles.worldAlignedTexturePositionText, worldAlignedTexturePosition);
                        EditorGUI.indentLevel = 0;
                    }
                }

                //  EditorGUILayout.BeginHorizontal();
                m_MaterialEditor.ShaderProperty(offsetFactor, "Offset Factor");
                m_MaterialEditor.ShaderProperty(offsetUnits, "Offset Units");
                //  EditorGUILayout.EndHorizontal();

                EditorGUILayout.Space();

                //  EditorGUILayout.Toggle


          








            }
		if ( EditorGUI.EndChangeCheck() )
		{
			foreach ( var obj in blendMode.targets )
			{
				MaterialChanged( ( Material )obj );
			}

			foreach ( var obj in specularMode.targets )
			{
				MaterialChanged( ( Material )obj );
			}


            foreach ( var obj in vertexMode.targets  )
            {

                MaterialChanged( ( Material )obj );
            }

		}
	}

	public override void AssignNewShaderToMaterial (Material material, Shader oldShader, Shader newShader)
	{
		base.AssignNewShaderToMaterial( material, oldShader, newShader );

		if ( oldShader == null )
			return;

		// Convert to vr_standard
		if ( newShader.name.Equals( "Valve/vr_standard" ) )
		{
			List<string> unknownShaders = new List<string>();
			ValveMenuTools.StandardToValveSingleMaterial( material, oldShader, newShader, false, unknownShaders );
		}

		// Legacy shaders
		if ( !oldShader.name.Contains( "Legacy Shaders/" ) )
			return;

		BlendMode blendMode = BlendMode.Opaque;
		if (oldShader.name.Contains("/Transparent/Cutout/"))
		{
			blendMode = BlendMode.AlphaTest;
		}
		else if (oldShader.name.Contains("/Transparent/"))
		{
			// NOTE: legacy shaders did not provide physically based transparency
			// therefore Fade mode
			blendMode = BlendMode.AlphaBlend;
		}
		material.SetFloat("_Mode", (float)blendMode);

		MaterialChanged(material);
	}

	void BlendModePopup()
	{
		EditorGUI.showMixedValue = blendMode.hasMixedValue;
		var mode = (BlendMode)blendMode.floatValue;

		EditorGUI.BeginChangeCheck();
		mode = (BlendMode)EditorGUILayout.Popup(Styles.renderingMode, (int)mode, Styles.blendNames);
		if (EditorGUI.EndChangeCheck())
		{
			m_MaterialEditor.RegisterPropertyChangeUndo("Rendering Mode");
			blendMode.floatValue = (float)mode;
		}

		EditorGUI.showMixedValue = false;
	}



	void SpecularModePopup()
	{
		EditorGUI.showMixedValue = specularMode.hasMixedValue;
		var mode = ( SpecularMode )specularMode.floatValue;

		EditorGUI.BeginChangeCheck();
		mode = ( SpecularMode )EditorGUILayout.Popup( Styles.specularModeText, ( int )mode, Styles.specularNames );
		if ( EditorGUI.EndChangeCheck() )
		{
			m_MaterialEditor.RegisterPropertyChangeUndo( "Specular Mode" );
			specularMode.floatValue = ( float )mode;
		}

		EditorGUI.showMixedValue = false;
	}


    void VertexModePopup()
    {
        EditorGUI.showMixedValue = vertexMode.hasMixedValue;
        var mode = (VertexMode)vertexMode.floatValue;

        EditorGUI.BeginChangeCheck();
        mode = (VertexMode)EditorGUILayout.Popup(Styles.VertexModeText, (int)mode, Styles.vertexNames);
        if (EditorGUI.EndChangeCheck())
        {
            m_MaterialEditor.RegisterPropertyChangeUndo("Vertex Mode");
            vertexMode.floatValue = (float)mode;
        }

        EditorGUI.showMixedValue = false;
    }

    void TexturePackingPopup()
    {
       

        EditorGUI.showMixedValue = PackingMode.hasMixedValue;
        var mode = (TexturePackingMode)PackingMode.floatValue;

        EditorGUI.BeginChangeCheck();            
        mode = (TexturePackingMode)EditorGUILayout.Popup(Styles.PackingModeText, (int)mode, Styles.PackingNames);
        if (EditorGUI.EndChangeCheck())
        {
            m_MaterialEditor.RegisterPropertyChangeUndo("Packing Mode");
            PackingMode.floatValue = (float)mode;
        }

        EditorGUI.showMixedValue = false;
    }

    void DetailModePopup()
    {

        EditorGUI.showMixedValue = DetailMode.hasMixedValue;
        var mode = (DetailBlendMode)DetailMode.floatValue;

        EditorGUI.BeginChangeCheck();
        mode = (DetailBlendMode)EditorGUILayout.Popup(Styles.DetailModeText, (int)mode, Styles.detailNames);
        if (EditorGUI.EndChangeCheck())
        {
            m_MaterialEditor.RegisterPropertyChangeUndo("Detail Mode");
            DetailMode.floatValue = (float)mode;
        }

        EditorGUI.showMixedValue = false;

        }

        void DoAlbedoArea(Material material)
	{
		m_MaterialEditor.TexturePropertySingleLine(Styles.albedoText, albedoMap, albedoColor);
        if (((BlendMode)material.GetFloat("_Mode") == BlendMode.AlphaTest || (BlendMode)material.GetFloat("_Mode") == BlendMode.AlphaBlend || (BlendMode)material.GetFloat("_Mode") == BlendMode.Glass))
		{
                if ((BlendMode)material.GetFloat("_Mode") == BlendMode.AlphaTest)
                {
                    m_MaterialEditor.ShaderProperty(alphaCutoff, Styles.alphaCutoffText.text, MaterialEditor.kMiniTextureFieldLabelIndentLevel + 1);
                }
                else
                {
                    m_MaterialEditor.ShaderProperty(alphaCutoff, "Alpha Falloff", MaterialEditor.kMiniTextureFieldLabelIndentLevel + 1);
                }
            }
	}

    void DoBRDFArea(Material material)
    {
        m_MaterialEditor.TexturePropertySingleLine(Styles.BRDFMapText, BRDFMap);
    }

    void DoFluorescenceArea(Material material)
    {
            if (fluorescenceMap.textureValue != null || (material.GetColor("_FluorescenceColor")).maxColorComponent > 0 ) {
                m_MaterialEditor.TexturePropertyTwoLines(Styles.FluorescenceText, fluorescenceMap, fluorescenceColor, Styles.AbsorbanceText, AbsorbanceColor);
            }
            else
            {
                m_MaterialEditor.TexturePropertySingleLine(Styles.FluorescenceText, fluorescenceMap, fluorescenceColor);
            }

        }


    void DoColorShiftArea(Material material)
    {

        m_MaterialEditor.TexturePropertySingleLine(Styles.colorMaskText, colorMask);
       
        // If texture was assigned and color was black set color to white
        if (colorMask.textureValue != null)
        {
             
            m_MaterialEditor.ColorProperty(colorShift1, "Color Tint 1");
            m_MaterialEditor.ColorProperty(colorShift2, "Color Tint 2");
            m_MaterialEditor.ColorProperty(colorShift3, "Color Tint 3");

         
        }
    }



	void DoEmissionArea(Material material)
	{
		float brightness = emissionColorForRendering.colorValue.maxColorComponent;
		bool showHelpBox = !HasValidEmissiveKeyword(material);
		bool showEmissionColorAndGIControls = brightness > 0.0f;
		
		bool hadEmissionTexture = emissionMap.textureValue != null;
        
		// Texture and HDR color controls
        if ((TexturePackingMode)material.GetInt("_PackingMode") != TexturePackingMode.MAES){
		m_MaterialEditor.TexturePropertyWithHDRColor(Styles.emissionText, emissionMap, emissionColorForRendering, m_ColorPickerHDRConfig, false);}
        else{
          //  GUILayout.BeginHorizontal();              
            m_MaterialEditor.ColorProperty(emissionColorForRendering, "Emissive Color");
         //   GUILayout.EndHorizontal();
        
        }

		// If texture was assigned and color was black set color to white
		if (emissionMap.textureValue != null && !hadEmissionTexture && brightness <= 0f)
			emissionColorForRendering.colorValue = Color.white;
            

		// Dynamic Lightmapping mode
		if (showEmissionColorAndGIControls)
		{
			bool shouldEmissionBeEnabled = ShouldEmissionBeEnabled(emissionColorForRendering.colorValue);
			using ( new EditorGUI.DisabledScope( !shouldEmissionBeEnabled ) )
			{
               if (unlit.floatValue == 0) m_MaterialEditor.ShaderProperty(emissionFalloff, Styles.emissionFalloffText.text, 2);
                m_MaterialEditor.ShaderProperty(emissiveMode, Styles.emissiveMode.text, 2);
				m_MaterialEditor.LightmapEmissionProperty( MaterialEditor.kMiniTextureFieldLabelIndentLevel );

			}
		}

		if (showHelpBox)
		{
			EditorGUILayout.HelpBox(Styles.emissiveWarning.text, MessageType.Warning);
		}
	}

	void DoSpecularMetallicArea( Material material )
	{
            GUIContent MetallicDis;

            SpecularMode specularMode = (SpecularMode)material.GetInt("_SpecularMode");


            if ((TexturePackingMode)material.GetInt("_PackingMode") == TexturePackingMode.None)
            {
                MetallicDis = Styles.metallicMapText;
            }
            else if ((TexturePackingMode)material.GetInt("_PackingMode") == TexturePackingMode.RMA)
            {
                MetallicDis = new GUIContent("RMA Metallic", "Roughness (R), Metallic (G), AO (B) ");
            }
            else if ((TexturePackingMode)material.GetInt("_PackingMode") == TexturePackingMode.MAES)
            {
                MetallicDis = new GUIContent("MAES Metallic", "Metallic (R), AO (G), Gray Emission (B) Gloss (A) ");
            }
            else if ((TexturePackingMode)material.GetInt("_PackingMode") == TexturePackingMode.MAS)
            {
                MetallicDis = new GUIContent("MAS Metallic", "Metallic (R), AO (G), Gloss (B) ");
            }

            else {
                MetallicDis = Styles.metallicMapText;
            }





          
		if ( specularMode == SpecularMode.BlinnPhong )
		{
			if (specularMap.textureValue == null)
			{
				m_MaterialEditor.TexturePropertyTwoLines( Styles.specularMapText, specularMap, specularColor, Styles.smoothnessText, smoothness );
			}
			else
			{
				m_MaterialEditor.TexturePropertySingleLine( Styles.specularMapText, specularMap );
			}
			m_MaterialEditor.ShaderProperty( reflectanceMin, Styles.reflectanceMinText.text, 2 );
			m_MaterialEditor.ShaderProperty( reflectanceMax, Styles.reflectanceMaxText.text, 2 );
		}
		else if ( specularMode == SpecularMode.Metallic )
		{
			if (metallicMap.textureValue == null)
				m_MaterialEditor.TexturePropertyTwoLines(MetallicDis, metallicMap, metallic, Styles.smoothnessText, smoothness);
			else
				m_MaterialEditor.TexturePropertySingleLine(MetallicDis, metallicMap);
		}

        else if (specularMode == SpecularMode.Anisotropic)
        {
                MetallicDis = new GUIContent("Anisotropic Metallic", "Metallic (R), Rotation (G), Ratio(B), Gloss (A) ");

                if (metallicMap.textureValue == null)
            {
                m_MaterialEditor.TexturePropertyTwoLines(MetallicDis, metallicMap, metallic, Styles.smoothnessText, smoothness);

                    m_MaterialEditor.ShaderProperty(AnisotropicRatio , Styles.anisotropicRatioText, 1 );
                   // m_MaterialEditor.ShaderProperty(AnisotropicRotation, Styles.anisotropicRotationText);
           //     m_MaterialEditor.ShaderProperty(smoothness2, Styles.smoothnessText2,3);
            }
            else
                m_MaterialEditor.TexturePropertySingleLine(MetallicDis, metallicMap);
                m_MaterialEditor.ShaderProperty(AnisotropicRotation, Styles.anisotropicRotationText, 1 );
            }
        else if (specularMode == SpecularMode.Retroreflective)

        {
            if (metallicMap.textureValue == null)
                m_MaterialEditor.TexturePropertyTwoLines(MetallicDis, metallicMap, metallic, Styles.smoothnessText, smoothness);
            else
                m_MaterialEditor.TexturePropertySingleLine(MetallicDis, metallicMap);
        }



        if (((TexturePackingMode)material.GetInt("_PackingMode") == TexturePackingMode.RMA) && metallicMap.textureValue != null )
        {
            GUILayout.BeginHorizontal();
            EditorGUILayout.HelpBox("RMA Texture likely needs sRGB disabled", MessageType.Info);
            //GUILayout.Button("Fix it!");
            GUILayout.EndHorizontal();
        }


	}

	public static void SetupMaterialWithBlendMode(Material material, BlendMode blendMode)
	{
		switch (blendMode)
		{
			case BlendMode.Opaque:
				material.SetOverrideTag("RenderType", "");
				material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
				material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
				material.SetInt("_ZWrite", 1);
				material.SetFloat( "_FogMultiplier", 1.0f );
				material.DisableKeyword("_ALPHATEST_ON");
				material.DisableKeyword("_ALPHABLEND_ON");
				material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                material.DisableKeyword("_ALPHAMULTIPLY_ON");
                material.DisableKeyword("_ALPHAMOD2X_ON");
				material.renderQueue = -1;
                material.SetInt("_Test", 0);
				break;
			case BlendMode.AlphaTest:
				material.SetOverrideTag("RenderType", "TransparentCutout");
				material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
				material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
				material.SetInt("_ZWrite", 1); 
				material.SetFloat( "_FogMultiplier", 1.0f );
				material.EnableKeyword("_ALPHATEST_ON");
				material.DisableKeyword("_ALPHABLEND_ON");
				material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                material.DisableKeyword("_ALPHAMULTIPLY_ON");
                material.DisableKeyword("_ALPHAMOD2X_ON");
				material.renderQueue = 2450;
                material.SetInt("_Test", 1);

				break;
			case BlendMode.AlphaBlend:
                material.SetOverrideTag("RenderType", "ValveTransparent");
				material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
				material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
				material.SetInt("_ZWrite", 0);
				material.SetFloat( "_FogMultiplier", 1.0f );
				material.DisableKeyword("_ALPHATEST_ON");
				material.EnableKeyword("_ALPHABLEND_ON");
				material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                material.DisableKeyword("_ALPHAMULTIPLY_ON");
                material.DisableKeyword("_ALPHAMOD2X_ON");
				material.renderQueue = 3000;
                material.SetInt("_Test", 0);

				break;
			case BlendMode.Glass:
                material.SetOverrideTag("RenderType", "ValveTransparent");
				material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
				material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
				material.SetInt("_ZWrite", 0);
				material.SetFloat( "_FogMultiplier", 1.0f );
				material.DisableKeyword("_ALPHATEST_ON");
				material.DisableKeyword("_ALPHABLEND_ON");
				material.EnableKeyword("_ALPHAPREMULTIPLY_ON");
                material.DisableKeyword("_ALPHAMULTIPLY_ON");
                material.DisableKeyword("_ALPHAMOD2X_ON");
                material.SetFloat("_ColorMultiplier", 0);
				material.renderQueue = 3000;
                material.SetInt("_Test", 0);
                if (material.GetInt("g_bUnlit") == 1)
                {
                   material.SetInt("g_bUnlit", 0);
                   Debug.Log("Disabling Unlit option on glass " + material + ". Unsupported");
                } 

                break;
			case BlendMode.Additive:
				material.SetOverrideTag( "RenderType", "ValveTransparent" );
				material.SetInt( "_SrcBlend", ( int )UnityEngine.Rendering.BlendMode.One );
				material.SetInt( "_DstBlend", ( int )UnityEngine.Rendering.BlendMode.One );
				material.SetInt( "_ZWrite", 0 );
				material.SetFloat( "_FogMultiplier", 0.0f );
				material.DisableKeyword( "_ALPHATEST_ON" );
				material.DisableKeyword( "_ALPHABLEND_ON" );
				material.DisableKeyword( "_ALPHAPREMULTIPLY_ON" );
                material.DisableKeyword("_ALPHAMULTIPLY_ON");
                material.DisableKeyword("_ALPHAMOD2X_ON");
				material.renderQueue = 3000;
                material.SetInt("_Test", 0);
				break;
           case BlendMode.Mod2x:
                material.SetOverrideTag("RenderType", "ValveTransparent");
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.DstColor);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.SrcColor);
                material.SetInt("_ZWrite", 0);
                material.SetFloat("_FogMultiplier", 0.5f);
                material.DisableKeyword("_ALPHATEST_ON");
                material.EnableKeyword("_ALPHABLEND_ON");
                material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                material.DisableKeyword("_ALPHAMULTIPLY_ON");
                material.EnableKeyword("_ALPHAMOD2X_ON");
                material.SetFloat("_ColorMultiplier",  0.5f );
                material.renderQueue = 3000;
                material.SetInt("_Test", 0);

                break;

            case BlendMode.Multiply:
                material.SetOverrideTag("RenderType", "ValveTransparent");
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.DstColor);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                material.SetInt("_ZWrite", 0);
                material.SetFloat("_FogMultiplier", 1.0f);
                material.DisableKeyword("_ALPHATEST_ON");
                material.DisableKeyword("_ALPHABLEND_ON");
                material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                material.EnableKeyword("_ALPHAMULTIPLY_ON");
                material.DisableKeyword("_ALPHAMOD2X_ON");
                material.SetFloat("_ColorMultiplier", 1);
                material.renderQueue = 3000;
                material.SetInt("_Test", 0);
                break;
            }
	}

    public static void SetupTexturePackingMode(Material material, TexturePackingMode packingMode)
    {
        switch (packingMode)
        {
            case TexturePackingMode.None:
                material.DisableKeyword("S_PACKING_MAES");
                material.DisableKeyword("S_PACKING_RMA");
                material.DisableKeyword("S_PACKING_MAS");
                    break;
            case TexturePackingMode.RMA:
                material.DisableKeyword("S_PACKING_MAES");
                material.EnableKeyword("S_PACKING_RMA");
                material.DisableKeyword("S_PACKING_MAS");
                    break;
            case TexturePackingMode.MAES:
                material.EnableKeyword("S_PACKING_MAES");
                material.DisableKeyword("S_PACKING_RMA");
                material.DisableKeyword("S_PACKING_MAS");
                    break;
            case TexturePackingMode.MAS:
                material.DisableKeyword("S_PACKING_MAES");
                material.DisableKeyword("S_PACKING_RMA");
                material.EnableKeyword("S_PACKING_MAS");
                    break;

            }
    }

        public static void SetupDetailBlendMode(Material material, DetailBlendMode detailMode)
        {
            switch (detailMode)
            {
               case DetailBlendMode.Multiply2x:
                    material.EnableKeyword("_DETAIL_MULX2");
                    material.DisableKeyword("_DETAIL_MUL");
                    material.DisableKeyword("_DETAIL_ADD");
                    material.DisableKeyword("_DETAIL_LERP");
               break;
               case DetailBlendMode.Multiply:
                    material.DisableKeyword("_DETAIL_MULX2");
                    material.EnableKeyword("_DETAIL_MUL");
                    material.DisableKeyword("_DETAIL_ADD");
                    material.DisableKeyword("_DETAIL_LERP");
               break;
               case DetailBlendMode.Add:
                    material.DisableKeyword("_DETAIL_MULX2");
                    material.DisableKeyword("_DETAIL_MUL");
                    material.EnableKeyword("_DETAIL_ADD");
                    material.DisableKeyword("_DETAIL_LERP");
                break;
                case DetailBlendMode.Lerp:
                    material.DisableKeyword("_DETAIL_MULX2");
                    material.DisableKeyword("_DETAIL_MUL");
                    material.DisableKeyword("_DETAIL_ADD");
                    material.EnableKeyword("_DETAIL_LERP");
                break;
            }


        }



	static bool ShouldEmissionBeEnabled (Color color)
	{
		return color.maxColorComponent > (0.1f / 255.0f);
	}



	static void SetMaterialKeywords(Material material)
	{
		// Note: keywords must be based on Material value not on MaterialProperty due to multi-edit & material animation
		// (MaterialProperty value might come from renderer material property block)
		SetKeyword (material, "_NORMALMAP", material.GetTexture ("_BumpMap") || material.GetTexture ("_DetailNormalMap"));

		SpecularMode specularMode = ( SpecularMode )material.GetInt( "_SpecularMode" );
        VertexMode vertexMode = (VertexMode)material.GetInt("_VertexMode");

		if ( specularMode == SpecularMode.BlinnPhong )
		{
			SetKeyword( material, "_SPECGLOSSMAP", material.GetTexture( "_SpecGlossMap" ) );
		}
		else if ( specularMode == SpecularMode.Metallic )
		{
			SetKeyword( material, "_METALLICGLOSSMAP", material.GetTexture( "_MetallicGlossMap" ) );
		}
        else if (specularMode == SpecularMode.Anisotropic)
        {  
            SetKeyword(material, "_METALLICGLOSSMAP", material.GetTexture( "_MetallicGlossMap" ));
        }
        else if (specularMode == SpecularMode.Retroreflective)
        {
            SetKeyword(material, "_METALLICGLOSSMAP", material.GetTexture("_MetallicGlossMap"));
        }
      


		SetKeyword( material, "S_SPECULAR_NONE", specularMode == SpecularMode.None );
		SetKeyword( material, "S_SPECULAR_BLINNPHONG", specularMode == SpecularMode.BlinnPhong );
		SetKeyword( material, "S_SPECULAR_METALLIC", specularMode == SpecularMode.Metallic );
        SetKeyword( material, "S_ANISOTROPIC_GLOSS", specularMode == SpecularMode.Anisotropic);
        SetKeyword( material, "S_RETROREFLECTIVE", specularMode == SpecularMode.Retroreflective);
        if (material.GetTexture("_OcclusionMap") || (TexturePackingMode)material.GetInt("_PackingMode") != TexturePackingMode.None)
        {
            SetKeyword(material, "S_OCCLUSION", true);
        }
        SetKeyword( material, "_VERTEXTINT", vertexMode == VertexMode.Tint);

		SetKeyword( material, "_PARALLAXMAP", material.GetTexture("_ParallaxMap"));
            //SetKeyword( material, "_DETAIL_MULX2", material.GetTexture("_DetailAlbedoMap") || material.GetTexture("_DetailNormalMap"));
        


        SetKeyword( material, "S_OVERRIDE_LIGHTMAP", material.GetTexture( "g_tOverrideLightmap" ) );
		
		SetKeyword( material, "S_UNLIT", material.GetInt( "g_bUnlit" ) == 1 );
		SetKeyword( material, "S_RECEIVE_SHADOWS", material.GetInt( "g_bReceiveShadows" ) == 1 );
		SetKeyword( material, "S_WORLD_ALIGNED_TEXTURE", material.GetInt( "g_bWorldAlignedTexture" ) == 1 );
        //SetKeyword( material, "_FLUORESCENCEMAP", material.GetTexture("_FluorescenceMap"));


        if ((material.GetTexture("g_tBRDFMap")) != null)
        {
            SetKeyword(material, "_BRDFMAP", true);
        }
        else
        {
            SetKeyword(material, "_BRDFMAP", false);
        }



        if ((material.GetTexture("_ColorMask")) != null)
        {
            SetKeyword(material, "_COLORSHIFT", true);
        }  else  {
            SetKeyword(material, "_COLORSHIFT", false);
        }

			if ((material.GetColor ("_FluorescenceColor")).maxColorComponent < (0.1f / 255.0f) ) {
				SetKeyword (material, "_FLUORESCENCEMAP", false);
			} else {
				SetKeyword (material, "_FLUORESCENCEMAP", true);
			}


		bool shouldEmissionBeEnabled = ShouldEmissionBeEnabled (material.GetColor("_EmissionColor"));
		SetKeyword (material, "_EMISSION", shouldEmissionBeEnabled);

		if ( material.IsKeywordEnabled( "S_RENDER_BACKFACES" ) )
		{
			material.SetInt( "_Cull", ( int )UnityEngine.Rendering.CullMode.Off );
		}
		else
		{
			material.SetInt( "_Cull", ( int )UnityEngine.Rendering.CullMode.Back );
		}

		// Setup lightmap emissive flags
		MaterialGlobalIlluminationFlags flags = material.globalIlluminationFlags;
		if ((flags & (MaterialGlobalIlluminationFlags.BakedEmissive | MaterialGlobalIlluminationFlags.RealtimeEmissive)) != 0)
		{
			flags &= ~MaterialGlobalIlluminationFlags.EmissiveIsBlack;
			if (!shouldEmissionBeEnabled)
				flags |= MaterialGlobalIlluminationFlags.EmissiveIsBlack;

			material.globalIlluminationFlags = flags;                  
             
        }

		// Reflectance constants
		float flReflectanceMin = material.GetFloat( "g_flReflectanceMin" );
		float flReflectanceMax = material.GetFloat( "g_flReflectanceMax" );
		material.SetFloat( "g_flReflectanceScale", Mathf.Max( flReflectanceMin, flReflectanceMax ) - flReflectanceMin );
		material.SetFloat( "g_flReflectanceBias", flReflectanceMin );

		// World aligned texture constants
		Vector4 worldAlignedTextureNormal = material.GetVector( "g_vWorldAlignedTextureNormal" );
		Vector3 normal = new Vector3( worldAlignedTextureNormal.x, worldAlignedTextureNormal.y, worldAlignedTextureNormal.z );
		normal = ( normal.sqrMagnitude > 0.0f ) ? normal : Vector3.up;
		Vector3 tangentU = Vector3.zero, tangentV = Vector3.zero;
		Vector3.OrthoNormalize( ref normal, ref tangentU, ref tangentV );
		material.SetVector( "g_vWorldAlignedNormalTangentU", new Vector4( tangentU.x, tangentU.y, tangentU.z, 0.0f ) );
		material.SetVector( "g_vWorldAlignedNormalTangentV", new Vector4( tangentV.x, tangentV.y, tangentV.z, 0.0f ) );

		// Static combo skips
		if ( material.GetInt( "g_bUnlit" ) == 1 )
		{
			material.DisableKeyword( "_NORMALMAP" );
			material.EnableKeyword( "S_SPECULAR_NONE" );
			material.DisableKeyword( "S_SPECULAR_BLINNPHONG" );
			material.DisableKeyword( "S_SPECULAR_METALLIC" );
			material.DisableKeyword( "_METALLICGLOSSMAP" );
			material.DisableKeyword( "_SPECGLOSSMAP" );
			material.DisableKeyword( "S_OVERRIDE_LIGHTMAP" );
			material.DisableKeyword( "S_RECEIVE_SHADOWS" );
		}
	}

	bool HasValidEmissiveKeyword (Material material)
	{
		// Material animation might be out of sync with the material keyword.
		// So if the emission support is disabled on the material, but the property blocks have a value that requires it, then we need to show a warning.
		// (note: (Renderer MaterialPropertyBlock applies its values to emissionColorForRendering))
		bool hasEmissionKeyword = material.IsKeywordEnabled ("_EMISSION");
		if (!hasEmissionKeyword && ShouldEmissionBeEnabled (emissionColorForRendering.colorValue))
			return false;
		else
			return true;
	}

	static void MaterialChanged(Material material)
	{
		SetupMaterialWithBlendMode(material, (BlendMode)material.GetFloat("_Mode"));
        SetupTexturePackingMode(material, (TexturePackingMode)material.GetFloat("_PackingMode"));
        SetupDetailBlendMode(material, (DetailBlendMode)material.GetFloat("_DetailMode"));
		SetMaterialKeywords(material);
        if (material.GetFloat("g_bCastShadows") == 0.0f)
            material.SetOverrideTag("RenderType", "DO_NOT_RENDER");
	}

	static void SetKeyword(Material m, string keyword, bool state)
	{
		if (state)
			m.EnableKeyword (keyword);
		else
			m.DisableKeyword (keyword);
	}
}

} // namespace UnityEditor

#endif
