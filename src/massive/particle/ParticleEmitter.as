package massive.particle 
{
	/**
	 * ...
	 * @author Matse
	 */
	public class ParticleEmitter 
	{
		static private var _POOL:Vector.<ParticleEmitter> = new Vector.<ParticleEmitter>();
		
		static public function fromPool():ParticleEmitter
		{
			if (_POOL.length != 0) return _POOL.pop();
			return new ParticleEmitter();
		}
		
		public var x:Number = 0.0;
		public var y:Number = 0.0;
		public var velocityX:Number = 0.0;
		public var velocityY:Number = 0.0;
		
		public function ParticleEmitter() 
		{
			
		}
		
		public function clear():void
		{
			this.x = this.y = this.velocityX = this.velocityY = 0.0;
		}
		
		public function pool():void
		{
			clear();
			_POOL[_POOL.length] = this;
		}
		
		public function advanceSystem(system:ParticleSystem, passedTime:Number):void
		{
			system.emitterX = this.x;
			system.emitterY = this.y;
			system.velocityX = this.velocityX;
			system.velocityY = this.velocityY;
		}
		
	}

}