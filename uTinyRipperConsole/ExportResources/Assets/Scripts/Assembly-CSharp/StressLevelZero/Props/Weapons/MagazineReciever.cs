using StressLevelZero.Interaction;
using StressLevelZero.Rig;
using UnityEngine;

namespace StressLevelZero.Props.Weapons
{
	public class MagazineReciever : InteractionReciever
	{
		public float priority;
		public Rig.Rig parentRig;
		public AudioClip[] grabClips;
	}
}
