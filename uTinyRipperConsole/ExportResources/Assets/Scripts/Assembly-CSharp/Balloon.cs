using UnityEngine;
using StressLevelZero.Props;
using StressLevelZero.SFX;

public class Balloon : MonoBehaviour
{
	public StressLevelZero.Props.Balloon.BalloonColor startColor;
	public GameObject popPrefab;
	public float maxVelocity;
	public float lifetime;
	public bool burstOnLifetimeEnd;
	public GameObject lifetimeEndParticlePrefab;
	public SoundPlayOneshot lifetimeEndSound;
	public SoundPlayOneshot collisionSound;
	[SerializeField]
	private Rigidbody balloonRigidbody;
}
