using System;
using UnityEngine;

namespace Chronos.Reflection
{
	[Serializable]
	public class UnityMember
	{
		[SerializeField]
		private UnityEngine.Object _target;
		[SerializeField]
		private string _component;
		[SerializeField]
		private string _name;
	}
}
