package massive.particle 
{
	/**
	 * ...
	 * @author Matse
	 */
	public class ParticleSystemDefaults 
	{
		public static const AUTO_CLEAR_ON_COMPLETE:Boolean = true;
		public static const RANDOM_SEED:int = 1;
		
		public static function create(options:ParticleSystemOptions = null):ParticleSystem
		{
			var ps:ParticleSystem = new ParticleSystem(options);
			ps.particlesFromPoolFunction = Particle.fromPoolVector;
			ps.particlesToPoolFunction = Particle.toPoolVector;
			return ps;
		}
	}

}