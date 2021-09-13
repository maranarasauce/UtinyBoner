using UnityEngine;
using System;
using StressLevelZero.Combat;
using StressLevelZero.Rig;
using StressLevelZero.Interaction;
using TMPro;

namespace StressLevelZero.Props.Weapons
{
	public class AmmoPouch : MonoBehaviour
	{
		[Serializable]
		public struct MagazineArt
		{
			public MagazineData data;
			public GameObject[] objects;
		}

		public AudioClip[] grabClips;
		public Platform defaultPlatform;
		public MagazineArt[] magazineArt;
		public Rig.Rig parentRig;
		public SpawnGrip spawnGrip;
		public Transform uiTransform;
		public TextMeshPro mediumAmmoText;
		public TextMeshPro lightAmmoText;
		public TextMeshPro heavyAmmoText;
	}
}
