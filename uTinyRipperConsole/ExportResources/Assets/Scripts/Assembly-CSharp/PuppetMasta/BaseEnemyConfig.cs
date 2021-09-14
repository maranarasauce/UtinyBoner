using UnityEngine;
using System;

namespace PuppetMasta
{
	[CreateAssetMenu]
	public class BaseEnemyConfig : ScriptableObject
	{
		[Serializable]
		public class SensorSettings
		{
			public LayerMask blockVisionRaycast;
			public float visionFov;
		}

		[Serializable]
		public class HealthSettings
		{
			public float maxHitPoints;
			public float maxAppendageHp;
			public float stunRecovery;
			public float maxStunSeconds;
			public float minHeadImpact;
			public float minSpineImpact;
			public float minLimbImpact;
			public float aggression;
			public float irritability;
			public float placability;
			public float vengefulness;
		}

		public PuppetMaster.State puppetState;
		public float restingRange;
		public bool freezeWhileResting;
		public bool homeIsPost;
		public float activeRange;
		public float roamSpeed;
		public Vector2 roamRange;
		public float roamAngSpeed;
		public float roamFrequency;
		public bool roamWanders;
		public float investigateRange;
		public float breakAgroTargetDistance;
		public float breakAgroHomeDistance;
		public float agroedSpeed;
		public float agroedAngSpeed;
		public LayerMask meleeAttackMask;
		public bool enableThrowAttack;
		public float throwMaxRange;
		public float throwMinRange;
		public float throwCooldown;
		public float throwVelocity;
		public float gunRange;
		public float gunCooldown;
		public float accuracy;
		public float reloadTime;
		public int clipSize;
		public int burstSize;
		public float desiredGunDistance;
		public Color baseColor;
		public Color agroColor;
		public SensorSettings sensorSettings;
		public HealthSettings healthSettings;
		public SubBehaviourHealth.UsageSettings restingUsage;
		public SubBehaviourHealth.UsageSettings roamUsage;
		public SubBehaviourHealth.UsageSettings investigateUsage;
		public SubBehaviourHealth.UsageSettings engagedUsage;
		public SubBehaviourHealth.UsageSettings agroedUsage;
		public BehaviourBaseNav.MentalState mentalState;
		public BehaviourBaseNav.LocoState locoState;
	}
}
