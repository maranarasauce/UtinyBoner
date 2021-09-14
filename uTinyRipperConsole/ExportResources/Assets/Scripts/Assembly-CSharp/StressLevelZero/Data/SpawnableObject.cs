using System;
using UnityEngine;
using StressLevelZero.Pool;

namespace StressLevelZero.Data
{
	[Serializable]
	[CreateAssetMenu]
	public class SpawnableObject : ScriptableObject
	{
		[SerializeField]
		private string _uuid;
		public string title;
		public string description;
		public GameObject prefab;
		public CategoryFilters category;
		public int pooledAmount;
		public int warmupAmount;
		public PoolMode mode;
		public float spawnFrequency;
		public float spawnDistance;
		public float spawnStackDistance;
		public int spawnStackCount;
		public bool isHidden;
	}
}
