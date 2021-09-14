using System;
using UnityEngine;

namespace StressLevelZero.Data
{
	[Serializable]
	[CreateAssetMenu]
	public class LootTableData : ScriptableObject
	{
		[SerializeField]
		public LootItem[] items;
	}
}
