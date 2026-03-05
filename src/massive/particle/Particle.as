package massive.particle 
{
	import massive.data.ImageData;
	
	/**
	 * ...
	 * @author Matse
	 */
	public class Particle extends ImageData 
	{
		static private var _POOL:Vector.<Particle> = new Vector.<Particle>();
		
		static public function fromPool():Particle
		{
			if (_POOL.length != 0) return _POOL.pop();
			return new Particle();
		}
		
		static public function fromPoolVector(numParticles:int, particles:Vector.<Particle> = null):Vector.<Particle>
		{
			if (particles == null) particles = new Vector.<Particle>();
			
			var i:int;
			var count:int = _POOL.length;
			var particleIndex:int = particles.length;
			var poolIndex:int = count - 1;
			if (count > numParticles) count = numParticles;
			
			for (i = 0; i < count; i++)
			{
				particles[particleIndex++] = _POOL[poolIndex--];
			}
			_POOL.length -= count;
			count = numParticles - count;
			for (i = 0; i < count; i++)
			{
				particles[particleIndex++] = new Particle();
			}
			
			return particles;
		}
		
		static public function toPoolVector(particles:Vector.<Particle>):void
		{
			var count:int = particles.length;
			for (var i:int = 0; i < count; i++)
			{
				particles[i].pool();
			}
		}
		
		public var timeCurrent:Number;
		public var timeTotal:Number;
		
		public var colorRedStart:Number;
		public var colorGreenStart:Number;
		public var colorBlueStart:Number;
		public var colorAlphaStart:Number;
		
		public var colorRedDelta:Number;
		public var colorGreenDelta:Number;
		public var colorBlueDelta:Number;
		public var colorAlphaDelta:Number;
		
		public var colorRedEnd:Number;
		public var colorGreenEnd:Number;
		public var colorBlueEnd:Number;
		public var colorAlphaEnd:Number;
		
		public var startX:Number;
		public var startY:Number;
		public var angle:Number;
		public var speed:Number;
		public var velocityX:Number;
		public var velocityY:Number;
		public var radialAcceleration:Number;
		public var tangentialAcceleration:Number;
		public var emitRadius:Number;
		public var emitRadiusDelta:Number;
		public var emitRotation:Number;
		public var emitRotationDelta:Number;
		public var rotationDelta:Number;
		
		public var scaleXStart:Number;
		public var scaleYStart:Number;
		public var scaleXEnd:Number;
		public var scaleYEnd:Number;
		public var scaleXDelta:Number;
		public var scaleYDelta:Number;
		
		// NEW
		public var isFadingIn:Boolean;
		public var xBase:Number;
		public var yBase:Number;
		public var rotationBase:Number;
		
		public var colorRedBase:Number;
		public var colorGreenBase:Number;
		public var colorBlueBase:Number;
		public var colorAlphaBase:Number;
		
		public var dragForce:Number;
		
		// oscillation position
		public var oscillationPositionAngle:Number;
		public var oscillationPositionRadius:Number;
		public var oscillationPositionStep:Number;
		public var oscillationPositionFrequency:Number;
		public var oscillationPositionX:Number;
		public var oscillationPositionY:Number;
		
		// oscillation position 2
		public var oscillationPosition2Angle:Number;
		public var oscillationPosition2Radius:Number;
		public var oscillationPosition2Step:Number;
		public var oscillationPosition2Frequency:Number;
		public var oscillationPosition2X:Number;
		public var oscillationPosition2Y:Number;
		
		// oscillation rotation
		public var oscillationRotationAngle:Number;
		public var oscillationRotationStep:Number;
		public var oscillationRotationFrequency:Number;
		public var oscillationRotation:Number;
		
		// oscillation scale
		public var oscillationScaleX:Number;
		public var oscillationScaleY:Number;
		public var oscillationScaleXStep:Number;
		public var oscillationScaleYStep:Number;
		public var oscillationScaleXFrequency:Number;
		public var oscillationScaleYFrequency:Number;
		public var scaleXOscillation:Number;
		public var scaleYOscillation:Number;
		
		// oscillation color
		public var oscillationColorRedFactor:Number;
		public var oscillationColorGreenFactor:Number;
		public var oscillationColorBlueFactor:Number;
		public var oscillationColorAlphaFactor:Number;
		public var oscillationColorStep:Number;
		public var oscillationColorFrequency:Number;
		
		public var oscillationColorRed:Number;
		public var oscillationColorGreen:Number;
		public var oscillationColorBlue:Number;
		public var oscillationColorAlpha:Number;
		
		public var scaleXBase:Number;
		public var scaleYBase:Number;
		
		public var scaleXVelocity:Number;
		public var scaleYVelocity:Number;
		//\NEW
		
		public var sizeXStart:Number;
		public var sizeYStart:Number;
		public var sizeXEnd:Number;
		public var sizeYEnd:Number;
		
		public var fadeInTime:Number;
		public var fadeOutTime:Number;
		public var fadeOutDuration:Number;
		
		// DEBUG
		public var updateCount:int;
		//\DEBUG
		
		public function Particle() 
		{
			super();
		}
		
		override public function pool():void
		{
			clear();
			_POOL[_POOL.length] = this;
		}
		
	}

}