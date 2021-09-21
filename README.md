# uTinyBoner (uTinyRipper Fork made for BONEWORKS)

uTinyRipper is a tool for extracting assets from serialized files (*CAB-*\*, *\*.assets*, *\*.sharedAssets*, etc.) and assets bundles (*\*.unity3d*, *\*.assetbundle*, etc.) and conveting them into native Engine format.

Supported version: 2018.4.10f1

## Export features
* Scenes
* Prefabs (GameObjects with transform components)
* AnimationClips (legacy, generic, humanoid)
* Meshes
* Shaders (native listing)
* Textures
* Audio
* Fonts
* Movie textures
* Materials
* AnimatorControllers
* Avatars
* Terrains
* TextAssets
* Components:
  * Joints
  * MeshRenderer
  * SkinnedMeshRenderer
  * Animation
  * Animator
  * Canvas
  * Light
  * ParticleSystem
  * Colliders
  * Rigidbody
  * AudioSource
  * Camera
  * MonoBehaviour (Mono only)
  * MonoScript (Mono only)
* Fixed BONEWORKS Scripts
* Fixed BONEWORKS Shaders
* TheLabRenderer
* Working TextMeshPro (Not visible in editor atm)

## Structure

* *uTinyRipperCore*

   Core library. It's designed as an single module without any third party dependencies.
   Any time you make changes to this make sure to build it in order to update the references.
   
* *uTinyRipperConsole* and *uTinyRipperConsoleNETCore*

   Sample console application which is designed to test Core library functionality.   
   It is command line console application. Drag and drop resource file(s) or/and folder(s) onto .exe to retrive assets. It will automaticly try to find resource dependencies, create 'Ripped' folder and extract all supported assets into created directory.
   This has much faster export time than GUI, so GUI has been deprecated.


### Requirements:

If you want to build a solution, you need:

 \- .NET Framework 4.7.2 + .NET Core 2.0 SDK

 \- Compiler with C# 7.3 syntax support (Visual Studio 2017)


If you want to run binary files, you need to install:

 \- [.NET Framework 4.7.2](https://support.microsoft.com/en-us/help/4054530/microsoft-net-framework-4-7-2-offline-installer-for-windows)
 
 \- [Microsoft Visual C++ 2015](https://www.microsoft.com/en-us/download/details.aspx?id=53840) Redistributables

 \- [Unity 2017.3.0f3 or greater](https://unity3d.com/get-unity/download/archive) (NOTE: editor version must be no less than game version)
 
