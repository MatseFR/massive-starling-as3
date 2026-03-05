package massive.particle 
{
	import flash.geom.Rectangle;
	import massive.animation.Animator;
	import massive.data.Frame;
	import massive.data.ImageData;
	import massive.data.MassiveConstants;
	import massive.display.ImageLayer;
	import massive.particle.Particle;
	import massive.particle.ParticleSystemOptions;
	import massive.utils.MassiveTint;
	import massive.utils.MathUtils;
	import starling.events.Event;
	
	/**
	 * ...
	 * @author Matse
	 */
	public class ParticleSystem extends ImageLayer 
	{
		public var autoClearOnComplete:Boolean = ParticleSystemDefaults.AUTO_CLEAR_ON_COMPLETE;
		public var randomSeed:int = ParticleSystemDefaults.RANDOM_SEED;
		
		/**
		 * function should be int->Vector.<Particle>->Vector.<Particle>
		 */
		public var particlesFromPoolFunction:Function;
		/**
		 * function should be Vector.<Particle>->void
		 */
		public var particlesToPoolFunction:Function;
		
		//##################################################
		// EMITTER
		//##################################################
		/**
		 * Possible values :
		 * - 0 for gravity
		 * - 1 for radial
		 * @default 0
		 */
		public var emitterType:int = EmitterType.GRAVITY;
		
		protected var _maxNumParticles:int = 1000;
		/**
		 * Maximum number of particles used by the system
		 * @default	1000
		 */
		public function get maxNumParticles():int { return this._maxNumParticles; }
		public function set maxNumParticles(value:int):void
		{
			if (this._maxNumParticles == value) return;
			returnParticlesToPool();
			this._maxNumParticles = value;
			if (this.particlesFromPoolFunction != null && this._frames.length != 0)
			{
				getParticlesFromPool();
			}
			else
			{
				this._isParticlePoolUpdatePending = true;
			}
			if (this._autoSetEmissionRate) updateEmissionRate();
		}
		
		/**
		 * The amount of particles this system can create over time, 0 = infinite
		 * @default	0
		 */
		public var particleAmount:int = 0;
		
		protected var _autoSetEmissionRate:Boolean = true;
		/**
		 * Tells whether the particle system should automatically set its emission rate or not
		 * @default	true
		 */
		public function get autoSetEmissionRate():Boolean { return this._autoSetEmissionRate; }
		public function set autoSetEmissionRate(value:Boolean):void
		{
			if (this._autoSetEmissionRate == value) return;
			this._autoSetEmissionRate = value;
			if (this._autoSetEmissionRate) updateEmissionRate();
		}
		
		protected var _emissionRate:Number = 100;
		/**
		 * How many particles are created per second
		 * @default	100
		 */
		public function get emissionRate():Number { return this._emissionRate; }
		public function set emissionRate(value:Number):void
		{
			this._emissionRate = value;
		}
		
		protected var _emissionRatio:Number = 1.0;
		/**
		 * Percentage of max particles to consider when automatically setting emission rate.
		 * @default	1.0
		 */
		public function get emissionRatio():Number { return this._emissionRatio; }
		public function set emissionRatio(value:Number):void
		{
			if (this._emissionRatio == value) return;
			this._emissionRatio = value;
			if (this._autoSetEmissionRate)
			{
				updateEmissionRate();
			}
		}
		
		/**
		 * Horizontal emitter position
		 * @default	0
		 */
		public var emitterX:Number = 0;
		
		/**
		 * Horizontal emitter position variance
		 * @default	0
		 */
		public var emitterXVariance:Number = 0;
		
		/**
		 * Vertical emitter position
		 * @default	0
		 */
		public var emitterY:Number = 0;
		
		/**
		 * Vertical emitter position variance
		 * @default	0
		 */
		public var emitterYVariance:Number = 0;
		
		protected var _useEmitterRadius:Boolean = false;
		
		protected var _emitterRadiusMax:Number = 0;
		/**
		 * @default	0
		 */
		public function get emitterRadiusMax():Number { return this._emitterRadiusMax; }
		public function set emitterRadiusMax(value:Number):void
		{
			this._emitterRadiusMax = value;
			this._useEmitterRadius = this._emitterRadiusMax != 0.0 || this._emitterRadiusMaxVariance != 0.0 || this._emitterRadiusMin != 0.0 || this._emitterRadiusMinVariance != 0.0;
		}
		
		protected var _emitterRadiusMaxVariance:Number = 0;
		/**
		 * @default	0
		 */
		public function get emitterRadiusMaxVariance():Number { return this._emitterRadiusMaxVariance; }
		public function set emitterRadiusMaxVariance(value:Number):void
		{
			this._emitterRadiusMaxVariance = value;
			this._useEmitterRadius = this._emitterRadiusMax != 0.0 || this._emitterRadiusMaxVariance != 0.0 || this._emitterRadiusMin != 0.0 || this._emitterRadiusMinVariance != 0.0;
		}
		
		protected var _emitterRadiusMin:Number = 0;
		/**
		 * @default	0
		 */
		public function get emitterRadiusMin():Number { return this._emitterRadiusMin; }
		public function set emitterRadiusMin(value:Number):void
		{
			this._emitterRadiusMin = value;
			this._useEmitterRadius = this._emitterRadiusMax != 0.0 || this._emitterRadiusMaxVariance != 0.0 || this._emitterRadiusMin != 0.0 || this._emitterRadiusMinVariance != 0.0;
		}
		
		protected var _emitterRadiusMinVariance:Number = 0;
		/**
		 * @default	0
		 */
		public function get emitterRadiusMinVariance():Number { return this._emitterRadiusMinVariance; }
		public function set emitterRadiusMinVariance(value:Number):void
		{
			this._emitterRadiusMinVariance = value;
			this._useEmitterRadius = this._emitterRadiusMax != 0.0 || this._emitterRadiusMaxVariance != 0.0 || this._emitterRadiusMin != 0.0 || this._emitterRadiusMinVariance != 0.0;
		}
		
		/**
		 * @default	0
		 */
		public var emitAngle:Number = 0;
		
		/**
		 * @default	Math.PI
		 */
		public var emitAngleVariance:Number = Math.PI;
		
		/**
		 * Aligns the particles to their emit angle at birth
		 * @default	false
		 */
		public var emitAngleAlignedRotation:Boolean = false;
		
		protected var _emissionTime:Number;
		protected var _emissionTimePredefined:Number = Number.MAX_VALUE;
		
		protected var _emitterObject:ParticleEmitter;
		/**
		 * @default	null
		 */
		public function get emitterObject():ParticleEmitter { return this._emitterObject; }
		public function set emitterObject(value:ParticleEmitter):void
		{
			this._emitterObject = value;
			this._updateEmitter = this._emitterObject != null;
		}
		
		/**
		 * @default	false
		 */
		public var useDisplayRect:Boolean = false;
		
		/**
		 * 
		 */
		public var displayRect:Rectangle = new Rectangle();
		//##################################################
		//\EMITTER
		//##################################################
		
		//##################################################
		// PARTICLE
		//##################################################
		protected var _useAnimationLifeSpan:Boolean = false;
		/**
		 * Limits particle life to texture animation duration (including loops)
		 * @default	false
		 */
		public function get useAnimationLifeSpan():Boolean { return this._useAnimationLifeSpan; }
		public function set useAnimationLifeSpan(value:Boolean):void
		{
			if (this._useAnimationLifeSpan == value) return;
			this._useAnimationLifeSpan = value;
			if (this._autoSetEmissionRate) updateEmissionRate();
		}
		
		protected var _lifeSpan:Number = 1;
		/**
		 * @default	1
		 */
		public function get lifeSpan():Number { return this._lifeSpan; }
		public function set lifeSpan(value:Number):void
		{
			this._lifeSpan = MathUtils.max(0.01, value);
			this._lifeSpanVariance = MathUtils.min(this._lifeSpan, this._lifeSpanVariance);
			if (this._autoSetEmissionRate)
			{
				updateEmissionRate();
			}
		}
		
		protected var _lifeSpanVariance:Number = 0;
		/**
		 * @default	0
		 */
		public function get lifeSpanVariance():Number { return this._lifeSpanVariance; }
		public function set lifeSpanVariance(value:Number):void
		{
			this._lifeSpanVariance = MathUtils.min(this._lifeSpan, value);
		}
		
		protected var _useFadeIn:Boolean = false;
		
		protected var _fadeInTime:Number = 0.0;
		/**
		 * if > 0 the particle alpha will be interpolated from 0 to starting alpha
		 * @default	0
		 */
		public function get fadeInTime():Number { return this._fadeInTime; }
		public function set fadeInTime(value:Number):void
		{
			this._fadeInTime = value;
			this._useFadeIn = this._fadeInTime > 0.0;
		}
		
		protected var _useFadeOut:Boolean = false;
		
		protected var _fadeOutTime:Number = 0.0;
		/**
		 * if > 0 the particle alpha will be interpolated from current value to end alpha
		 * @default	0
		 */
		public function get fadeOutTime():Number { return this._fadeOutTime; }
		public function set fadeOutTime(value:Number):void
		{
			this._fadeOutTime = value;
			this._useFadeOut = this._fadeOutTime != 0.0;
		}
		
		/**
		 * sets both sizeXStart and sizeYStart
		 */
		public function get sizeStart():Number { return this.sizeXStart; }
		public function set sizeStart(value:Number):void
		{
			this.sizeXStart = this.sizeYStart = value;
		}
		
		/**
		 * sets both sizeXStartVariance and sizeYStartVariance
		 */
		public function get sizeStartVariance():Number { return this.sizeXStartVariance; }
		public function set sizeStartVariance(value:Number):void
		{
			this.sizeXStartVariance = this.sizeYStartVariance = value;
		}
		
		/**
		 * @default	20
		 */
		public var sizeXStart:Number = 20;
		
		/**
		 * @default	0
		 */
		public var sizeXStartVariance:Number = 0;
		
		/**
		 * @default	20
		 */
		public var sizeYStart:Number = 20;
		
		/**
		 * @default	0
		 */
		public var sizeYStartVariance:Number = 0;
		
		/**
		 * sets both sizeXEnd and sizeYEnd
		 */
		public function get sizeEnd():Number { return this.sizeXEnd; }
		public function set sizeEnd(value:Number):void
		{
			this.sizeXEnd = this.sizeYEnd = value;
		}
		
		/**
		 * sets both sizeXEndVariance and sizeYEndVariance
		 */
		public function get sizeEndVariance():Number { return this.sizeXEndVariance; }
		public function set sizeEndVariance(value:Number):void
		{
			this.sizeXEndVariance = this.sizeYEndVariance = value;
		}
		
		/**
		 * @default	20
		 */
		public var sizeXEnd:Number = 20;
		
		/**
		 * @default	0
		 */
		public var sizeXEndVariance:Number = 0;
		
		/**
		 * @default	20
		 */
		public var sizeYEnd:Number = 20;
		
		/**
		 * @default	0
		 */
		public var sizeYEndVariance:Number = 0;
		
		/**
		 * @default	0
		 */
		public var rotationStart:Number = 0;
		
		/**
		 * @default	0
		 */
		public var rotationStartVariance:Number = 0;
		
		/**
		 * @default	0
		 */
		public var rotationEnd:Number = 0;
		
		/**
		 * @default	0
		 */
		public var rotationEndVariance:Number = 0;
		
		/**
		 * @default	false
		 */
		public var rotationEndRelativeToStart:Boolean = false;
		//##################################################
		//\PARTICLE
		//##################################################
		
		//##################################################
		// VELOCITY
		//##################################################
		protected var _useVelocityInheritanceX:Boolean = false;
		protected var _useVelocityInheritanceY:Boolean = false;
		
		protected var _velocityXInheritRatio:Number = 0.0;
		/**
		 * @default	0
		 */
		public function get velocityXInheritRatio():Number { return this._velocityXInheritRatio; }
		public function set velocityXInheritRatio(value:Number):void
		{
			this._velocityXInheritRatio = value;
			this._useVelocityInheritanceX = this._velocityXInheritRatio != 0.0 || this._velocityXInheritRatioVariance != 0.0;
		}
		
		protected var _velocityXInheritRatioVariance:Number = 0.0;
		/**
		 * @default	0
		 */
		public function get velocityXInheritRatioVariance():Number { return this._velocityXInheritRatioVariance; }
		public function set velocityXInheritRatioVariance(value:Number):void
		{
			this._velocityXInheritRatioVariance = value;
			this._useVelocityInheritanceX = this._velocityXInheritRatio != 0.0 || this._velocityXInheritRatioVariance != 0.0;
		}
		
		protected var _velocityYInheritRatio:Number = 0.0;
		/**
		 * @default	0
		 */
		public function get velocityYInheritRatio():Number { return this._velocityYInheritRatio; }
		public function set velocityYInheritRatio(value:Number):void
		{
			this._velocityYInheritRatio = value;
			this._useVelocityInheritanceY = this._velocityYInheritRatio != 0.0 || this._velocityYInheritRatioVariance != 0.0;
		}
		
		protected var _velocityYInheritRatioVariance:Number = 0.0;
		/**
		 * @default	0
		 */
		public function get velocityYInheritRatioVariance():Number { return this._velocityYInheritRatioVariance; }
		public function set velocityYInheritRatioVariance(value:Number):void
		{
			this._velocityYInheritRatioVariance = value;
			this._useVelocityInheritanceY = this._velocityYInheritRatio != 0.0 || this._velocityYInheritRatioVariance != 0.0;
		}
		
		/**
		 * @default	0
		 */
		public var velocityX:Number = 0.0;
		
		/**
		 * @default	0
		 */
		public var velocityY:Number = 0.0;
		
		protected var _useVelocityScale:Boolean = false;
		protected var _useVelocityScaleX:Boolean = false;
		protected var _useVelocityScaleY:Boolean = false;
		
		protected var _velocityScaleFactorX:Number = 0.0;
		/**
		 * @default	0
		 */
		public function get velocityScaleFactorX():Number { return this._velocityScaleFactorX; }
		public function set velocityScaleFactorX(value:Number):void
		{
			this._velocityScaleFactorX = value;
			this._useVelocityScaleX = this._velocityScaleFactorX != 0.0;
			this._useVelocityScale = this._useVelocityScaleX || this._useVelocityScaleY;
		}
		
		protected var _velocityScaleFactorY:Number = 0.0;
		/**
		 * @default	0
		 */
		public function get velocityScaleFactorY():Number { return this._velocityScaleFactorY; }
		public function set velocityScaleFactorY(value:Number):void
		{
			this._velocityScaleFactorY = value;
			this._useVelocityScaleY = this._velocityScaleFactorY != 0.0;
			this._useVelocityScale = this._useVelocityScaleX || this._useVelocityScaleY;
		}
		
		/**
		 * @default	false
		 */
		public var linkRotationToVelocity:Boolean = false;
		
		/**
		 * @default	0
		 */
		public var velocityRotationOffset:Number = 0.0;
		//##################################################
		//\VELOCITY
		//##################################################
		
		//##################################################
		// ANIMATION
		//##################################################
		protected var _frameDelta:Number = 1.0;
		/**
		 * @default	1.0
		 */
		public function get frameDelta():Number { return this._frameDelta; }
		public function set frameDelta(value:Number):void
		{
			if (this._frameDelta == value) return;
			this._frameDelta = value;
			if (this._useAnimationLifeSpan) updateEmissionRate();
		}
		
		/**
		 * @default	0.0
		 */
		public var frameDeltaVariance:Number = 0.0;
		
		protected var _loopAnimation:Boolean = false;
		/**
		 * Tells whether texture animation should loop or not
		 * @default	false
		 */
		public function get loopAnimation():Boolean { return this._loopAnimation; }
		public function set loopAnimation(value:Boolean):void
		{
			if (this._loopAnimation == value) return;
			this._loopAnimation = value;
			
			var count:int = this._particles.length;
			for (var i:int = 0; i < count; i++)
			{
				this._particles[i].loop = this._loopAnimation;
			}
		}
		
		protected var _animationLoops:int = 0;
		/**
		 * Number of loops if loopAnimation is true, 0 = infinite
		 * @default	0
		 */
		public function get animationLoops():int { return this._animationLoops; }
		public function set animationLoops(value:int):void
		{
			if (this._animationLoops == value) return;
			this._animationLoops = value;
			
			var count:int = this._particles.length;
			for (var i:int = 0; i < count; i++)
			{
				this._particles[i].numLoops = this._animationLoops;
			}
		}
		
		/**
		 * Tells  whether the initial frame should be chosen randomly
		 * @default	false
		 */
		public var randomStartFrame:Boolean = false;
		//##################################################
		//\ANIMATION
		//##################################################
		
		//##################################################
		// GRAVITY
		//##################################################
		/**
		 * Particle speed (pixels per second)
		 * @default	100
		 */
		public var speed:Number = 100;
		
		/**
		 * @default	0
		 */
		public var speedVariance:Number = 0;
		
		/**
		 * @default	false
		 */
		public var adjustLifeSpanToSpeed:Boolean = false;
		
		/**
		 * @default	0
		 */
		public var gravityX:Number = 0;
		
		/**
		 * @default	0
		 */
		public var gravityY:Number = 0;
		
		/**
		 * @default	0
		 */
		public var radialAcceleration:Number = 0;
		
		/**
		 * @default	0
		 */
		public var radialAccelerationVariance:Number = 0;
		
		/**
		 * @default	0
		 */
		public var tangentialAcceleration:Number = 0;
		
		/**
		 * @default	0
		 */
		public var tangentialAccelerationVariance:Number = 0;
		
		protected var _useDrag:Boolean = false;
		
		protected var _drag:Number = 0.0;
		/**
		 * @default	0
		 */
		public function get drag():Number { return this._drag; }
		public function set drag(value:Number):void
		{
			this._drag = value;
			this._useDrag = this._drag != 0.0 || this._dragVariance != 0.0;
		}
		
		protected var _dragVariance:Number = 0.0;
		/**
		 * @default	0
		 */
		public function get dragVariance():Number { return this._dragVariance; }
		public function set dragVariance(value:Number):void
		{
			this._dragVariance = value;
			this._useDrag = this._drag != 0.0 || this._dragVariance != 0.0;
		}
		
		protected var _useRepellentForce:Boolean = false;
		
		protected var _repellentForce:Number = 0.0;
		/**
		 * @default	0
		 */
		public function get repellentForce():Number { return this._repellentForce; }
		public function set repellentForce(value:Number):void
		{
			this._repellentForce = value;
			this._useRepellentForce = this._repellentForce != 0.0;
		}
		
		//##################################################
		//\GRAVITY
		//##################################################
		
		//##################################################
		// RADIAL
		//##################################################
		/**
		 * @default	50
		 */
		public var radiusMax:Number = 50;
		
		/**
		 * @default	0
		 */
		public var radiusMaxVariance:Number = 0;
		
		/**
		 * @default	0
		 */
		public var radiusMin:Number = 0;
		
		/**
		 * @default	0
		 */
		public var radiusMinVariance:Number = 0;
		
		/**
		 * @default	0
		 */
		public var rotatePerSecond:Number = 0;
		
		/**
		 * @default	0
		 */
		public var rotatePerSecondVariance:Number = 0;
		//##################################################
		//\RADIAL
		//##################################################
		
		//##################################################
		// COLOR
		//##################################################
		/**
		 * 
		 */
		public var colorStart:MassiveTint = new MassiveTint(1, 1, 1, 1);
		
		/**
		 * 
		 */
		public var colorStartVariance:MassiveTint = new MassiveTint(0, 0, 0, 0);
		
		/**
		 * 
		 */
		public var colorEnd:MassiveTint = new MassiveTint(1, 1, 1, 1);
		
		/**
		 * 
		 */
		public var colorEndVariance:MassiveTint = new MassiveTint(0, 0, 0, 0);
		
		/**
		 * @default	false
		 */
		public var colorEndRelativeToStart:Boolean = false;
		
		/**
		 * @default	false
		 */
		public var colorEndIsMultiplier:Boolean = false;
		//##################################################
		//\COLOR
		//##################################################
		
		//##################################################
		// OSCILLATION
		//##################################################
		protected var _useOscillationGlobalFrequency:Boolean = false;
		protected var _useOscillationUnifiedFrequencyVariance:Boolean = false;
		protected var _useOscillationUnifiedFrequencyStart:Boolean = false;
		protected var _oscillationGlobalStep:Number;
		protected var _oscillationGlobalValue:Number;
		protected var _oscillationGlobalValueInverted:Number;
		
		/**
		   @default	1
		**/
		public var oscillationGlobalFrequency:Number = 1.0;
		
		/**
		   @default 0
		**/
		public var oscillationUnifiedFrequencyVariance:Number = 0.0;
		
		// oscillation position
		protected var _oscillationPositionEnabled:Boolean = false;
		protected var _oscillationPositionGroupStep:Number;
		protected var _oscillationPositionGroupValue:Number;
		protected var _oscillationPositionGlobalFrequencyEnabled:Boolean = false;
		protected var _oscillationPositionGroupFrequencyEnabled:Boolean = false;
		protected var _oscillationPositionFrequencyStartRandomized:Boolean = false;
		protected var _oscillationPositionFrequencyStartUnified:Boolean = false;
		protected var _oscillationPositionAngleRelativeToRotation:Boolean = true;
		protected var _oscillationPositionAngleRelativeToVelocity:Boolean = false;
		
		protected var _oscillationPositionFrequencyMode:String = OscillationFrequencyMode.SINGLE;
		/**
		   see OscillationFrequencyMode for possible values
		   @default	OscillationFrequencyMode.SINGLE
		**/
		public function get oscillationPositionFrequencyMode():String { return this._oscillationPositionFrequencyMode; }
		public function set oscillationPositionFrequencyMode(value:String):void
		{
			if (this._oscillationPositionFrequencyMode == value) return;
			
			switch (value)
			{
				case OscillationFrequencyMode.GLOBAL :
					this._oscillationPositionGlobalFrequencyEnabled = true;
					this._oscillationPositionGroupFrequencyEnabled = false;
					break;
				
				case OscillationFrequencyMode.GROUP :
					this._oscillationPositionGlobalFrequencyEnabled = false;
					this._oscillationPositionGroupFrequencyEnabled = true;
					break;
				
				case OscillationFrequencyMode.SINGLE :
					this._oscillationPositionGlobalFrequencyEnabled = false;
					this._oscillationPositionGroupFrequencyEnabled = false;
					break;
				
				default :
					throw new Error("unknown OscillationFrequencyMode ::: " + value);
			}
			
			this._useOscillationGlobalFrequency = this._oscillationPositionGlobalFrequencyEnabled || this._oscillationPosition2GlobalFrequencyEnabled || this._oscillationRotationGlobalFrequencyEnabled ||
												  this._oscillationScaleXGlobalFrequencyEnabled || this._oscillationScaleYGlobalFrequencyEnabled || this._oscillationColorGlobalFrequencyEnabled;
			
			this._oscillationPositionFrequencyMode = value;
		}
		
		/**
		   @default 0
		**/
		public var oscillationPositionAngle:Number = 0.0;
		
		/**
		   @default 0
		**/
		public var oscillationPositionAngleVariance:Number = 0.0;
		
		protected var _oscillationPositionAngleRelativeTo:String = AngleRelativeTo.ROTATION;
		/**
		   see AngleRelativeTo for possible values
		   @default	AngleRelativeTo.ROTATION
		**/
		private function get oscillationPositionAngleRelativeTo():String { return this._oscillationPositionAngleRelativeTo; }
		private function set oscillationPositionAngleRelativeTo(value:String):void
		{
			if (this._oscillationPositionAngleRelativeTo == value) return;
			
			switch (value)
			{
				case AngleRelativeTo.ABSOLUTE :
					this._oscillationPositionAngleRelativeToRotation = false;
					this._oscillationPositionAngleRelativeToVelocity = false;
					break;
				
				case AngleRelativeTo.ROTATION :
					this._oscillationPositionAngleRelativeToRotation = true;
					this._oscillationPositionAngleRelativeToVelocity = false;
					break;
				
				case AngleRelativeTo.VELOCITY :
					this._oscillationPositionAngleRelativeToRotation = false;
					this._oscillationPositionAngleRelativeToVelocity = true;
					break;
				
				default :
					throw new Error("unknown AngleRelativeTo ::: " + value);
			}
			
			this._oscillationPositionAngleRelativeTo = value;
		}
		
		protected var _oscillationPositionRadius:Number = 0.0;
		/**
		   @default 0
		**/
		public function get oscillationPositionRadius():Number { return this._oscillationPositionRadius; }
		public function set oscillationPositionRadius(value:Number):void
		{
			this._oscillationPositionEnabled = value != 0.0 || this._oscillationPositionRadiusVariance != 0.0;
			this._oscillationPositionRadius = value;
		}
		
		private var _oscillationPositionRadiusVariance:Number = 0.0;
		/**
		   @default 0
		**/
		public function get oscillationPositionRadiusVariance():Number { return this._oscillationPositionRadiusVariance; }
		public function set oscillationPositionRadiusVariance(value:Number):void
		{
			this._oscillationPositionEnabled = value != 0.0 || this._oscillationPositionRadius != 0.0;
			this._oscillationPositionRadiusVariance = value;
		}
		
		/**
		   @default 0
		**/
		public var oscillationPositionFrequency:Number = 1.0;
		
		protected var _oscillationPositionUnifiedFrequencyVariance:Boolean = false;
		/**
		   @default	false
		**/
		public function get oscillationPositionUnifiedFrequencyVariance():Boolean { return this._oscillationPositionUnifiedFrequencyVariance; }
		public function set oscillationPositionUnifiedFrequencyVariance(value:Boolean):void
		{
			this._oscillationPositionUnifiedFrequencyVariance = value;
			this._useOscillationUnifiedFrequencyVariance = this._oscillationPositionUnifiedFrequencyVariance || this._oscillationPosition2UnifiedFrequencyVariance || this._oscillationRotationUnifiedFrequencyVariance ||
														   this._oscillationScaleXUnifiedFrequencyVariance || this._oscillationScaleYUnifiedFrequencyVariance || this._oscillationColorUnifiedFrequencyVariance;
		}
		
		/**
		   @default 0
		**/
		public var oscillationPositionFrequencyVariance:Number = 0.0;
		
		/**
		   @default	false
		**/
		public var oscillationPositionFrequencyInverted:Boolean = false;
		
		/**
		   see OscillationFrequencyStart for possible values
		   @default	OscillationFrequencyStart.ZERO
		**/
		protected var _oscillationPositionFrequencyStart:String = OscillationFrequencyStart.ZERO;
		public function get oscillationPositionFrequencyStart():String { return this._oscillationPositionFrequencyStart; }
		public function set oscillationPositionFrequencyStart(value:String):void
		{
			if (this._oscillationPositionFrequencyStart == value) return;
			
			switch (value)
			{
				case OscillationFrequencyStart.ZERO :
					this._oscillationPositionFrequencyStartRandomized = false;
					this._oscillationPositionFrequencyStartUnified = false;
					break;
				
				case OscillationFrequencyStart.RANDOM :
					this._oscillationPositionFrequencyStartRandomized = true;
					this._oscillationPositionFrequencyStartUnified = false;
					break;
				
				case OscillationFrequencyStart.UNIFIED_RANDOM :
					this._oscillationPositionFrequencyStartRandomized = false;
					this._oscillationPositionFrequencyStartUnified = true;
					break;
				
				default :
					throw new Error("unknown OscillationFrequencyStart ::: " + value);
			}
			
			this._useOscillationUnifiedFrequencyStart = this._oscillationPositionFrequencyStartUnified || this._oscillationPosition2FrequencyStartUnified || this._oscillationRotationFrequencyStartUnified ||
														this._oscillationScaleXFrequencyStartUnified || this._oscillationScaleYFrequencyStartUnified || this._oscillationColorFrequencyStartUnified;
			
			this._oscillationPositionFrequencyStart = value;
		}
		
		// oscillation position 2
		protected var _oscillationPosition2Enabled:Boolean = false;
		protected var _oscillationPosition2GroupStep:Number;
		protected var _oscillationPosition2GroupValue:Number;
		protected var _oscillationPosition2GlobalFrequencyEnabled:Boolean = false;
		protected var _oscillationPosition2GroupFrequencyEnabled:Boolean = false;
		protected var _oscillationPosition2FrequencyStartRandomized:Boolean = false;
		protected var _oscillationPosition2FrequencyStartUnified:Boolean = false;
		protected var _oscillationPosition2AngleRelativeToRotation:Boolean = true;
		protected var _oscillationPosition2AngleRelativeToVelocity:Boolean = false;
		
		protected var _oscillationPosition2FrequencyMode:String = OscillationFrequencyMode.SINGLE;
		/**
		   see OscillationFrequencyMode for possible values
		   @default	OscillationFrequencyMode.SINGLE
		**/
		public function get oscillationPosition2FrequencyMode():String { return this._oscillationPosition2FrequencyMode; }
		public function set oscillationPosition2FrequencyMode(value:String):void
		{
			if (this._oscillationPosition2FrequencyMode == value) return;
			
			switch (value)
			{
				case OscillationFrequencyMode.GLOBAL :
					this._oscillationPosition2GlobalFrequencyEnabled = true;
					this._oscillationPosition2GroupFrequencyEnabled = false;
					break;
				
				case OscillationFrequencyMode.GROUP :
					this._oscillationPosition2GlobalFrequencyEnabled = false;
					this._oscillationPosition2GroupFrequencyEnabled = true;
					break;
				
				case OscillationFrequencyMode.SINGLE :
					this._oscillationPosition2GlobalFrequencyEnabled = false;
					this._oscillationPosition2GroupFrequencyEnabled = false;
					break;
				
				default :
					throw new Error("unknown OscillationFrequencyMode ::: " + value);
			}
			
			this._useOscillationGlobalFrequency = this._oscillationPositionGlobalFrequencyEnabled || this._oscillationPosition2GlobalFrequencyEnabled || this._oscillationRotationGlobalFrequencyEnabled ||
												  this._oscillationScaleXGlobalFrequencyEnabled || this._oscillationScaleYGlobalFrequencyEnabled || this._oscillationColorGlobalFrequencyEnabled;
			
			this._oscillationPosition2FrequencyMode = value;
		}
		
		/**
		   @default 0
		**/
		public var oscillationPosition2Angle:Number = 0.0;
		
		/**
		   @default 0
		**/
		public var oscillationPosition2AngleVariance:Number = 0.0;
		
		protected var _oscillationPosition2AngleRelativeTo:String = AngleRelativeTo.ROTATION;
		/**
		   see AngleRelativeTo for possible values
		   @default	AngleRelativeTo.ROTATION
		**/
		public function get oscillationPosition2AngleRelativeTo():String { return this._oscillationPosition2AngleRelativeTo; }
		public function set oscillationPosition2AngleRelativeTo(value:String):void
		{
			if (this._oscillationPositionAngleRelativeTo == value) return;
			
			switch (value)
			{
				case AngleRelativeTo.ABSOLUTE :
					this._oscillationPosition2AngleRelativeToRotation = false;
					this._oscillationPosition2AngleRelativeToVelocity = false;
					break;
				
				case AngleRelativeTo.ROTATION :
					this._oscillationPosition2AngleRelativeToRotation = true;
					this._oscillationPosition2AngleRelativeToVelocity = false;
					break;
				
				case AngleRelativeTo.VELOCITY :
					this._oscillationPosition2AngleRelativeToRotation = false;
					this._oscillationPosition2AngleRelativeToVelocity = true;
					break;
				
				default :
					throw new Error("unknown AngleRelativeTo ::: " + value);
			}
			
			this._oscillationPosition2AngleRelativeTo = value;
		}
		
		protected var _oscillationPosition2Radius:Number = 0.0;
		/**
		   @default 0
		**/
		public function get oscillationPosition2Radius():Number { return this._oscillationPosition2Radius; }
		public function set oscillationPosition2Radius(value:Number):void
		{
			this._oscillationPosition2Enabled = value != 0.0 || this._oscillationPosition2RadiusVariance != 0.0;
			this._oscillationPosition2Radius = value;
		}
		
		protected var _oscillationPosition2RadiusVariance:Number = 0.0;
		/**
		   @default 0
		**/
		public function get oscillationPosition2RadiusVariance():Number { return this._oscillationPosition2RadiusVariance; }
		public function set oscillationPosition2RadiusVariance(value:Number):void
		{
			this._oscillationPosition2Enabled = value != 0.0 || this._oscillationPosition2Radius != 0.0;
			this._oscillationPosition2RadiusVariance = value;
		}
		
		/**
		   @default 1.0
		**/
		public var oscillationPosition2Frequency:Number = 1.0;
		
		protected var _oscillationPosition2UnifiedFrequencyVariance:Boolean = false;
		/**
		   @default	false
		**/
		public function get oscillationPosition2UnifiedFrequencyVariance():Boolean { return this._oscillationPosition2UnifiedFrequencyVariance; }
		public function set oscillationPosition2UnifiedFrequencyVariance(value:Boolean):void
		{
			this._oscillationPosition2UnifiedFrequencyVariance = value;
			this._useOscillationUnifiedFrequencyVariance = this._oscillationPositionUnifiedFrequencyVariance || this._oscillationPosition2UnifiedFrequencyVariance || this._oscillationRotationUnifiedFrequencyVariance ||
														   this._oscillationScaleXUnifiedFrequencyVariance || this._oscillationScaleYUnifiedFrequencyVariance || this._oscillationColorUnifiedFrequencyVariance;
		}
		
		/**
		   @default 0
		**/
		public var oscillationPosition2FrequencyVariance:Number = 0.0;
		
		/**
		   
		**/
		public var oscillationPosition2FrequencyInverted:Boolean = false;
		
		protected var _oscillationPosition2FrequencyStart:String = OscillationFrequencyStart.ZERO;
		/**
		   see OscillationFrequencyStart for possible values
		   @default	OscillationFrequencyStart.ZERO
		**/
		public function get oscillationPosition2FrequencyStart():String { return this._oscillationPosition2FrequencyStart; }
		public function set oscillationPosition2FrequencyStart(value:String):void
		{
			if (this._oscillationPosition2FrequencyStart == value) return;
			
			switch (value)
			{
				case OscillationFrequencyStart.ZERO :
					this._oscillationPosition2FrequencyStartRandomized = false;
					this._oscillationPosition2FrequencyStartUnified = false;
					break;
				
				case OscillationFrequencyStart.RANDOM :
					this._oscillationPosition2FrequencyStartRandomized = true;
					this._oscillationPosition2FrequencyStartUnified = false;
					break;
				
				case OscillationFrequencyStart.UNIFIED_RANDOM :
					this._oscillationPosition2FrequencyStartRandomized = false;
					this._oscillationPosition2FrequencyStartUnified = true;
					break;
				
				default :
					throw new Error("unknown OscillationFrequencyStart ::: " + value);
			}
			
			this._useOscillationUnifiedFrequencyStart = this._oscillationPositionFrequencyStartUnified || this._oscillationPosition2FrequencyStartUnified || this._oscillationRotationFrequencyStartUnified ||
														this._oscillationScaleXFrequencyStartUnified || this._oscillationScaleYFrequencyStartUnified || this._oscillationColorFrequencyStartUnified;
			
			this._oscillationPosition2FrequencyStart = value;
		}
		
		// oscillation rotation
		protected var _oscillationRotationEnabled:Boolean = false;
		protected var _oscillationRotationGroupStep:Number;
		protected var _oscillationRotationGroupValue:Number;
		protected var _oscillationRotationGlobalFrequencyEnabled:Boolean = false;
		protected var _oscillationRotationGroupFrequencyEnabled:Boolean = false;
		protected var _oscillationRotationFrequencyStartRandomized:Boolean = false;
		protected var _oscillationRotationFrequencyStartUnified:Boolean = false;
		
		protected var _oscillationRotationFrequencyMode:String = OscillationFrequencyMode.SINGLE;
		/**
		   see OscillationFrequencyMode for possible values
		   @default	OscillationFrequencyMode.SINGLE
		**/
		public function get oscillationRotationFrequencyMode():String { return this._oscillationRotationFrequencyMode; }
		public function set oscillationRotationFrequencyMode(value:String):void
		{
			if (this._oscillationRotationFrequencyMode == value) return;
			
			switch (value)
			{
				case OscillationFrequencyMode.GLOBAL :
					this._oscillationRotationGlobalFrequencyEnabled = true;
					this._oscillationRotationGroupFrequencyEnabled = false;
					break;
				
				case OscillationFrequencyMode.GROUP :
					this._oscillationRotationGlobalFrequencyEnabled = false;
					this._oscillationRotationGroupFrequencyEnabled = true;
					break;
				
				case OscillationFrequencyMode.SINGLE :
					this._oscillationRotationGlobalFrequencyEnabled = false;
					this._oscillationRotationGroupFrequencyEnabled = false;
					break;
				
				default :
					throw new Error("unknown OscillationFrequencyMode ::: " + value);
			}
			
			this._useOscillationGlobalFrequency = this._oscillationPositionGlobalFrequencyEnabled || this._oscillationPosition2GlobalFrequencyEnabled || this._oscillationRotationGlobalFrequencyEnabled ||
												  this._oscillationScaleXGlobalFrequencyEnabled || this._oscillationScaleYGlobalFrequencyEnabled || this._oscillationColorGlobalFrequencyEnabled;
			
			this._oscillationRotationFrequencyMode = value;
		}
		
		protected var _oscillationRotationAngle:Number = 0.0;
		/**
		   @default 0
		**/
		public function get oscillationRotationAngle():Number { return this._oscillationRotationAngle; }
		public function set oscillationRotationAngle(value:Number):void
		{
			this._oscillationRotationEnabled = value != 0.0 || this._oscillationRotationAngleVariance != 0.0;
			this._oscillationRotationAngle = value;
		}
		
		protected var _oscillationRotationAngleVariance:Number = 0.0;
		/**
		   @default 0
		**/
		public function get oscillationRotationAngleVariance():Number { return this._oscillationRotationAngleVariance; }
		public function set oscillationRotationAngleVariance(value:Number):void
		{
			this._oscillationRotationEnabled = value != 0.0 || this._oscillationRotationAngle != 0.0;
			this._oscillationRotationAngleVariance = value;
		}
		
		/**
		   @default	1
		**/
		public var oscillationRotationFrequency:Number = 1.0;
		
		protected var _oscillationRotationUnifiedFrequencyVariance:Boolean = false;
		/**
		   @default false
		**/
		public function get oscillationRotationUnifiedFrequencyVariance():Boolean { return this._oscillationRotationUnifiedFrequencyVariance; }
		public function set oscillationRotationUnifiedFrequencyVariance(value:Boolean):void
		{
			this._oscillationRotationUnifiedFrequencyVariance = value;
			this._useOscillationUnifiedFrequencyVariance = this._oscillationPositionUnifiedFrequencyVariance || this._oscillationPosition2UnifiedFrequencyVariance || this._oscillationRotationUnifiedFrequencyVariance ||
														   this._oscillationScaleXUnifiedFrequencyVariance || this._oscillationScaleYUnifiedFrequencyVariance || this._oscillationColorUnifiedFrequencyVariance;
		}
		
		/**
		   @default 0
		**/
		public var oscillationRotationFrequencyVariance:Number = 0.0;
		
		/**
		   @default	false
		**/
		public var oscillationRotationFrequencyInverted:Boolean = false;
		
		protected var _oscillationRotationFrequencyStart:String = OscillationFrequencyStart.ZERO;
		/**
		   see OscillationFrequencyStart for possible values
		   @default	OscillationFrequencyStart.ZERO
		**/
		public function get oscillationRotationFrequencyStart():String { return this._oscillationRotationFrequencyStart; }
		public function set oscillationRotationFrequencyStart(value:String):void
		{
			if (this._oscillationRotationFrequencyStart == value) return;
			
			switch (value)
			{
				case OscillationFrequencyStart.ZERO :
					this._oscillationRotationFrequencyStartRandomized = false;
					this._oscillationRotationFrequencyStartUnified = false;
					break;
				
				case OscillationFrequencyStart.RANDOM :
					this._oscillationRotationFrequencyStartRandomized = true;
					this._oscillationRotationFrequencyStartUnified = false;
					break;
				
				case OscillationFrequencyStart.UNIFIED_RANDOM :
					this._oscillationRotationFrequencyStartRandomized = false;
					this._oscillationRotationFrequencyStartUnified = true;
					break;
				
				default :
					throw new Error("unknown OscillationFrequencyStart ::: " + value);
			}
			
			this._useOscillationUnifiedFrequencyStart = this._oscillationPositionFrequencyStartUnified || this._oscillationPosition2FrequencyStartUnified || this._oscillationRotationFrequencyStartUnified ||
														this._oscillationScaleXFrequencyStartUnified || this._oscillationScaleYFrequencyStartUnified || this._oscillationColorFrequencyStartUnified;
			
			this._oscillationRotationFrequencyStart = value;
		}
		
		// oscillation scaleX
		protected var _oscillationScaleXEnabled:Boolean = false;
		protected var _oscillationScaleXGroupStep:Number;
		protected var _oscillationScaleXGroupValue:Number;
		protected var _oscillationScaleXGlobalFrequencyEnabled:Boolean = false;
		protected var _oscillationScaleXGroupFrequencyEnabled:Boolean = false;
		protected var _oscillationScaleXFrequencyStartRandomized:Boolean = false;
		protected var _oscillationScaleXFrequencyStartUnified:Boolean = false;
		
		protected var _oscillationScaleXFrequencyMode:String = OscillationFrequencyMode.SINGLE;
		/**
		   see OscillationFrequencyMode for possible values
		   @default	OscillationFrequencyMode.SINGLE
		**/
		public function get oscillationScaleXFrequencyMode():String { return this._oscillationScaleXFrequencyMode; }
		public function set oscillationScaleXFrequencyMode(value:String):void
		{
			if (this._oscillationScaleXFrequencyMode == value) return;
			
			switch (value)
			{
				case OscillationFrequencyMode.GLOBAL :
					this._oscillationScaleXGlobalFrequencyEnabled = true;
					this._oscillationScaleXGroupFrequencyEnabled = false;
					break;
				
				case OscillationFrequencyMode.GROUP :
					this._oscillationScaleXGlobalFrequencyEnabled = false;
					this._oscillationScaleXGroupFrequencyEnabled = true;
					break;
				
				case OscillationFrequencyMode.SINGLE :
					this._oscillationScaleXGlobalFrequencyEnabled = false;
					this._oscillationScaleXGroupFrequencyEnabled = false;
					break;
				
				default :
					throw new Error("unknown OscillationFrequencyMode ::: " + value);
			}
			
			this._useOscillationGlobalFrequency = this._oscillationPositionGlobalFrequencyEnabled || this._oscillationPosition2GlobalFrequencyEnabled || this._oscillationRotationGlobalFrequencyEnabled ||
												  this._oscillationScaleXGlobalFrequencyEnabled || this._oscillationScaleYGlobalFrequencyEnabled || this._oscillationColorGlobalFrequencyEnabled;
			
			this._oscillationScaleXFrequencyMode = value;
		}
		
		protected var _oscillationScaleX:Number = 0.0;
		/**
		   @default 0
		**/
		public function get oscillationScaleX():Number { return this._oscillationScaleX; }
		public function set oscillationScaleX(value:Number):void
		{
			this._oscillationScaleX = value;
			this._oscillationScaleXEnabled = this._oscillationScaleX != 0.0 || this._oscillationScaleXVariance != 0.0;
		}
		
		protected var _oscillationScaleXVariance:Number = 0.0;
		/**
		   @default 0
		**/
		public function get oscillationScaleXVariance():Number { return this._oscillationScaleXVariance; }
		public function set oscillationScaleXVariance(value:Number):void
		{
			this._oscillationScaleXVariance = value;
			this._oscillationScaleXEnabled = this._oscillationScaleX != 0.0 || this._oscillationScaleXVariance != 0.0;
		}
		
		/**
		   @default 1
		**/
		public var oscillationScaleXFrequency:Number = 1.0;
		
		protected var _oscillationScaleXUnifiedFrequencyVariance:Boolean = false;
		/**
		   @default	false
		**/
		public function get oscillationScaleXUnifiedFrequencyVariance():Boolean { return this._oscillationScaleXUnifiedFrequencyVariance; }
		public function set oscillationScaleXUnifiedFrequencyVariance(value:Boolean):void
		{
			this._oscillationScaleXUnifiedFrequencyVariance = value;
			this._useOscillationUnifiedFrequencyVariance = this._oscillationPositionUnifiedFrequencyVariance || this._oscillationPosition2UnifiedFrequencyVariance || this._oscillationRotationUnifiedFrequencyVariance ||
														   this._oscillationScaleXUnifiedFrequencyVariance || this._oscillationScaleYUnifiedFrequencyVariance || this._oscillationColorUnifiedFrequencyVariance;
		}
		
		/**
		   @default 0
		**/
		public var oscillationScaleXFrequencyVariance:Number = 0.0;
		
		/**
		   @default	false
		**/
		public var oscillationScaleXFrequencyInverted:Boolean = false;
		
		protected var _oscillationScaleXFrequencyStart:String = OscillationFrequencyStart.ZERO;
		/**
		   see OscillationFrequencyStart for possible values
		   @default	OscillationFrequencyStart.ZERO
		**/
		public function get oscillationScaleXFrequencyStart():String { return this._oscillationScaleXFrequencyStart; }
		public function set oscillationScaleXFrequencyStart(value:String):void
		{
			if (this._oscillationScaleXFrequencyStart == value) return;
			
			switch (value)
			{
				case OscillationFrequencyStart.ZERO :
					this._oscillationScaleXFrequencyStartRandomized = false;
					this._oscillationScaleXFrequencyStartUnified = false;
					break;
				
				case OscillationFrequencyStart.RANDOM :
					this._oscillationScaleXFrequencyStartRandomized = true;
					this._oscillationScaleXFrequencyStartUnified = false;
					break;
				
				case OscillationFrequencyStart.UNIFIED_RANDOM :
					this._oscillationScaleXFrequencyStartRandomized = false;
					this._oscillationScaleXFrequencyStartUnified = true;
					break;
				
				default :
					throw new Error("unknown OscillationFrequencyStart ::: " + value);
			}
			
			this._useOscillationUnifiedFrequencyStart = this._oscillationPositionFrequencyStartUnified || this._oscillationPosition2FrequencyStartUnified || this._oscillationRotationFrequencyStartUnified ||
														this._oscillationScaleXFrequencyStartUnified || this._oscillationScaleYFrequencyStartUnified || this._oscillationColorFrequencyStartUnified;
			
			this._oscillationScaleXFrequencyStart = value;
		}
		
		// oscillation scaleY
		protected var _oscillationScaleYEnabled:Boolean = false;
		protected var _oscillationScaleYGroupStep:Number;
		protected var _oscillationScaleYGroupValue:Number;
		protected var _oscillationScaleYGlobalFrequencyEnabled:Boolean = false;
		protected var _oscillationScaleYGroupFrequencyEnabled:Boolean = false;
		protected var _oscillationScaleYFrequencyStartRandomized:Boolean = false;
		protected var _oscillationScaleYFrequencyStartUnified:Boolean = false;
		
		protected var _oscillationScaleYFrequencyMode:String = OscillationFrequencyMode.SINGLE;
		/**
		   see OscillationFrequencyMode for possible values
		   @default	OscillationFrequencyMode.SINGLE
		**/
		public function get oscillationScaleYFrequencyMode():String { return this._oscillationScaleYFrequencyMode; }
		public function set oscillationScaleYFrequencyMode(value:String):void
		{
			if (this._oscillationScaleYFrequencyMode == value) return;
			
			switch (value)
			{
				case OscillationFrequencyMode.GLOBAL :
					this._oscillationScaleYGlobalFrequencyEnabled = true;
					this._oscillationScaleYGroupFrequencyEnabled = false;
					break;
				
				case OscillationFrequencyMode.GROUP :
					this._oscillationScaleYGlobalFrequencyEnabled = false;
					this._oscillationScaleYGroupFrequencyEnabled = true;
					break;
				
				case OscillationFrequencyMode.SINGLE :
					this._oscillationScaleYGlobalFrequencyEnabled = false;
					this._oscillationScaleYGroupFrequencyEnabled = false;
					break;
				
				default :
					throw new Error("unknown OscillationFrequencyMode ::: " + value);
			}
			
			this._useOscillationGlobalFrequency = this._oscillationPositionGlobalFrequencyEnabled || this._oscillationPosition2GlobalFrequencyEnabled || this._oscillationRotationGlobalFrequencyEnabled ||
												  this._oscillationScaleXGlobalFrequencyEnabled || this._oscillationScaleYGlobalFrequencyEnabled || this._oscillationColorGlobalFrequencyEnabled;
			
			this._oscillationScaleYFrequencyMode = value;
		}
		
		protected var _oscillationScaleY:Number = 0.0;
		/**
		   @default 0
		**/
		public function get oscillationScaleY():Number { return this._oscillationScaleY; }
		public function set oscillationScaleY(value:Number):void
		{
			this._oscillationScaleY = value;
			this._oscillationScaleYEnabled = this._oscillationScaleY != 0.0 || this._oscillationScaleYVariance != 0.0;
		}
		
		protected var _oscillationScaleYVariance:Number = 0.0;
		/**
		   @default 0
		**/
		public function get oscillationScaleYVariance():Number { return this._oscillationScaleYVariance; }
		public function set oscillationScaleYVariance(value:Number):void
		{
			this._oscillationScaleYVariance = value;
			this._oscillationScaleYEnabled = this._oscillationScaleY != 0.0 || this._oscillationScaleYVariance != 0.0;
		}
		
		/**
		   @default 1
		**/
		public var oscillationScaleYFrequency:Number = 1.0;
		
		protected var _oscillationScaleYUnifiedFrequencyVariance:Boolean = false;
		/**
		   @default	false
		**/
		public function get oscillationScaleYUnifiedFrequencyVariance():Boolean { return this._oscillationScaleYUnifiedFrequencyVariance; }
		public function set oscillationScaleYUnifiedFrequencyVariance(value:Boolean):void
		{
			this._oscillationScaleYUnifiedFrequencyVariance = value;
			this._useOscillationUnifiedFrequencyVariance = this._oscillationPositionUnifiedFrequencyVariance || this._oscillationPosition2UnifiedFrequencyVariance || this._oscillationRotationUnifiedFrequencyVariance ||
														   this._oscillationScaleXUnifiedFrequencyVariance || this._oscillationScaleYUnifiedFrequencyVariance || this._oscillationColorUnifiedFrequencyVariance;
		}
		
		/**
		   @default 0
		**/
		public var oscillationScaleYFrequencyVariance:Number = 0.0;
		
		/**
		   @default	false
		**/
		public var oscillationScaleYFrequencyInverted:Boolean = false;
		
		protected var _oscillationScaleYFrequencyStart:String = OscillationFrequencyStart.ZERO;
		/**
		   see OscillationFrequencyStart for possible values
		   @default	OscillationFrequencyStart.ZERO
		**/
		public function get oscillationScaleYFrequencyStart():String { return this._oscillationScaleYFrequencyStart; }
		public function set oscillationScaleYFrequencyStart(value:String):void
		{
			if (this._oscillationScaleYFrequencyStart == value) return;
			
			switch (value)
			{
				case OscillationFrequencyStart.ZERO :
					this._oscillationScaleYFrequencyStartRandomized = false;
					this._oscillationScaleYFrequencyStartUnified = false;
					break;
				
				case OscillationFrequencyStart.RANDOM :
					this._oscillationScaleYFrequencyStartRandomized = true;
					this._oscillationScaleYFrequencyStartUnified = false;
					break;
				
				case OscillationFrequencyStart.UNIFIED_RANDOM :
					this._oscillationScaleYFrequencyStartRandomized = false;
					this._oscillationScaleYFrequencyStartUnified = true;
					break;
				
				default :
					throw new Error("unknown OscillationFrequencyStart ::: " + value);
			}
			
			this._useOscillationUnifiedFrequencyStart = this._oscillationPositionFrequencyStartUnified || this._oscillationPosition2FrequencyStartUnified || this._oscillationRotationFrequencyStartUnified ||
														this._oscillationScaleXFrequencyStartUnified || this._oscillationScaleYFrequencyStartUnified || this._oscillationColorFrequencyStartUnified;
			
			this._oscillationScaleYFrequencyStart = value;
		}
		
		// oscillation color
		protected var _useOscillationColor:Boolean = false;
		protected var _oscillationColorGroupStep:Number;
		protected var _oscillationColorGroupValue:Number;
		protected var _oscillationColorGlobalFrequencyEnabled:Boolean = false;
		protected var _oscillationColorGroupFrequencyEnabled:Boolean = false;
		protected var _oscillationColorFrequencyStartRandomized:Boolean = false;
		protected var _oscillationColorFrequencyStartUnified:Boolean = false;
		
		protected var _oscillationColorFrequencyMode:String = OscillationFrequencyMode.SINGLE;
		/**
		   see OscillationFrequencyMode for possible values
		   @default	OscillationFrequencyMode.SINGLE
		**/
		public function get oscillationColorFrequencyMode():String { return this._oscillationColorFrequencyMode; }
		public function set oscillationColorFrequencyMode(value:String):void
		{
			if (this._oscillationColorFrequencyMode == value) return;
			
			switch (value)
			{
				case OscillationFrequencyMode.GLOBAL :
					this._oscillationColorGlobalFrequencyEnabled = true;
					this._oscillationColorGroupFrequencyEnabled = false;
					break;
				
				case OscillationFrequencyMode.GROUP :
					this._oscillationColorGlobalFrequencyEnabled = false;
					this._oscillationColorGroupFrequencyEnabled = true;
					break;
				
				case OscillationFrequencyMode.SINGLE :
					this._oscillationColorGlobalFrequencyEnabled = false;
					this._oscillationColorGroupFrequencyEnabled = false;
					break;
				
				default :
					throw new Error("unknown OscillationFrequencyMode ::: " + value);
			}
			
			this._useOscillationGlobalFrequency = this._oscillationPositionGlobalFrequencyEnabled || this._oscillationPosition2GlobalFrequencyEnabled || this._oscillationRotationGlobalFrequencyEnabled ||
												  this._oscillationScaleXGlobalFrequencyEnabled || this._oscillationScaleYGlobalFrequencyEnabled || this._oscillationColorGlobalFrequencyEnabled;
			
			this._oscillationColorFrequencyMode = value;
		}
		
		private var _oscillationColorRed:Number = 0.0;
		/**
		   @default 0
		**/
		public function get oscillationColorRed():Number { return this._oscillationColorRed; }
		public function set oscillationColorRed(value:Number):void
		{
			this._oscillationColorRed = value;
			this._useOscillationColor = this._oscillationColorRed != 0.0 || this._oscillationColorGreen != 0.0 || this._oscillationColorBlue != 0.0 || this._oscillationColorAlpha != 0.0 ||
										this._oscillationColorRedVariance != 0.0 || this._oscillationColorGreenVariance != 0.0 || this._oscillationColorBlueVariance != 0.0 || this._oscillationColorAlphaVariance != 0.0;
		}
		
		protected var _oscillationColorGreen:Number = 0.0;
		/**
		   @default 0
		**/
		public function get oscillationColorGreen():Number { return this._oscillationColorGreen; }
		public function set oscillationColorGreen(value:Number):void
		{
			this._oscillationColorGreen = value;
			this._useOscillationColor = this._oscillationColorRed != 0.0 || this._oscillationColorGreen != 0.0 || this._oscillationColorBlue != 0.0 || this._oscillationColorAlpha != 0.0 ||
										this._oscillationColorRedVariance != 0.0 || this._oscillationColorGreenVariance != 0.0 || this._oscillationColorBlueVariance != 0.0 || this._oscillationColorAlphaVariance != 0.0;
		}
		
		protected var _oscillationColorBlue:Number = 0.0;
		/**
		   @default 0
		**/
		public function get oscillationColorBlue():Number { return this._oscillationColorBlue; }
		public function set oscillationColorBlue(value:Number):void
		{
			this._oscillationColorBlue = value;
			this._useOscillationColor = this._oscillationColorRed != 0.0 || this._oscillationColorGreen != 0.0 || this._oscillationColorBlue != 0.0 || this._oscillationColorAlpha != 0.0 ||
										this._oscillationColorRedVariance != 0.0 || this._oscillationColorGreenVariance != 0.0 || this._oscillationColorBlueVariance != 0.0 || this._oscillationColorAlphaVariance != 0.0;
		}
		
		protected var _oscillationColorAlpha:Number = 0.0;
		/**
		   @default 0
		**/
		public function get oscillationColorAlpha():Number { return this._oscillationColorAlpha; }
		public function set oscillationColorAlpha(value:Number):void
		{
			this._oscillationColorAlpha = value;
			this._useOscillationColor = this._oscillationColorRed != 0.0 || this._oscillationColorGreen != 0.0 || this._oscillationColorBlue != 0.0 || this._oscillationColorAlpha != 0.0 ||
										this._oscillationColorRedVariance != 0.0 || this._oscillationColorGreenVariance != 0.0 || this._oscillationColorBlueVariance != 0.0 || this._oscillationColorAlphaVariance != 0.0;
		}
		
		protected var _oscillationColorRedVariance:Number = 0.0;
		/**
		   @default 0
		**/
		public function get oscillationColorRedVariance():Number { return this._oscillationColorRedVariance; }
		public function set oscillationColorRedVariance(value:Number):void
		{
			this._oscillationColorRedVariance = value;
			this._useOscillationColor = this._oscillationColorRed != 0.0 || this._oscillationColorGreen != 0.0 || this._oscillationColorBlue != 0.0 || this._oscillationColorAlpha != 0.0 ||
										this._oscillationColorRedVariance != 0.0 || this._oscillationColorGreenVariance != 0.0 || this._oscillationColorBlueVariance != 0.0 || this._oscillationColorAlphaVariance != 0.0;
		}
		
		protected var _oscillationColorGreenVariance:Number = 0.0;
		/**
		   @default 0
		**/
		public function get oscillationColorGreenVariance():Number { return this._oscillationColorGreenVariance; }
		public function set oscillationColorGreenVariance(value:Number):void
		{
			this._oscillationColorGreenVariance = value;
			this._useOscillationColor = this._oscillationColorRed != 0.0 || this._oscillationColorGreen != 0.0 || this._oscillationColorBlue != 0.0 || this._oscillationColorAlpha != 0.0 ||
										this._oscillationColorRedVariance != 0.0 || this._oscillationColorGreenVariance != 0.0 || this._oscillationColorBlueVariance != 0.0 || this._oscillationColorAlphaVariance != 0.0;
		}
		
		protected var _oscillationColorBlueVariance:Number = 0.0;
		/**
		   @default 0
		**/
		public function get oscillationColorBlueVariance():Number { return this._oscillationColorBlueVariance; }
		public function set oscillationColorBlueVariance(value:Number):void
		{
			this._oscillationColorBlueVariance = value;
			this._useOscillationColor = this._oscillationColorRed != 0.0 || this._oscillationColorGreen != 0.0 || this._oscillationColorBlue != 0.0 || this._oscillationColorAlpha != 0.0 ||
										this._oscillationColorRedVariance != 0.0 || this._oscillationColorGreenVariance != 0.0 || this._oscillationColorBlueVariance != 0.0 || this._oscillationColorAlphaVariance != 0.0;
		}
		
		protected var _oscillationColorAlphaVariance:Number = 0.0;
		/**
		   @default 0
		**/
		public function get oscillationColorAlphaVariance():Number { return this._oscillationColorAlphaVariance; }
		public function set oscillationColorAlphaVariance(value:Number):void
		{
			this._oscillationColorAlphaVariance = value;
			this._useOscillationColor = this._oscillationColorRed != 0.0 || this._oscillationColorGreen != 0.0 || this._oscillationColorBlue != 0.0 || this._oscillationColorAlpha != 0.0 ||
										this._oscillationColorRedVariance != 0.0 || this._oscillationColorGreenVariance != 0.0 || this._oscillationColorBlueVariance != 0.0 || this._oscillationColorAlphaVariance != 0.0;
		}
		
		/**
		   @default 1.0
		**/
		public var oscillationColorFrequency:Number = 1.0;
		
		protected var _oscillationColorUnifiedFrequencyVariance:Boolean = false;
		/**
		   @default	false
		**/
		public function get oscillationColorUnifiedFrequencyVariance():Boolean { return this._oscillationColorUnifiedFrequencyVariance; }
		public function set oscillationColorUnifiedFrequencyVariance(value:Boolean):void
		{
			this._oscillationColorUnifiedFrequencyVariance = value;
			this._useOscillationUnifiedFrequencyVariance = this._oscillationPositionUnifiedFrequencyVariance || this._oscillationPosition2UnifiedFrequencyVariance || this._oscillationRotationUnifiedFrequencyVariance ||
														   this._oscillationScaleXUnifiedFrequencyVariance || this._oscillationScaleYUnifiedFrequencyVariance || this._oscillationColorUnifiedFrequencyVariance;
		}
		
		/**
		   @default 0
		**/
		public var oscillationColorFrequencyVariance:Number = 0.0;
		
		/**
		   @default	false
		**/
		public var oscillationColorFrequencyInverted:Boolean = false;
		
		protected var _oscillationColorFrequencyStart:String = OscillationFrequencyStart.ZERO;
		/**
		   see OscillationFrequencyStart for possible values
		   @default	OscillationFrequencyStart.ZERO
		**/
		public function get oscillationColorFrequencyStart():String { return this._oscillationColorFrequencyStart; }
		public function set oscillationColorFrequencyStart(value:String):void
		{
			if (this._oscillationColorFrequencyStart == value) return;
			
			switch (value)
			{
				case OscillationFrequencyStart.ZERO :
					this._oscillationColorFrequencyStartRandomized = false;
					this._oscillationColorFrequencyStartUnified = false;
					break;
				
				case OscillationFrequencyStart.RANDOM :
					this._oscillationColorFrequencyStartRandomized = true;
					this._oscillationColorFrequencyStartUnified = false;
					break;
				
				case OscillationFrequencyStart.UNIFIED_RANDOM :
					this._oscillationColorFrequencyStartRandomized = false;
					this._oscillationColorFrequencyStartUnified = true;
					break;
				
				default :
					throw new Error("unknown OscillationFrequencyStart ::: " + value);
			}
			
			this._useOscillationUnifiedFrequencyStart = this._oscillationPositionFrequencyStartUnified || this._oscillationPosition2FrequencyStartUnified || this._oscillationRotationFrequencyStartUnified ||
														this._oscillationScaleXFrequencyStartUnified || this._oscillationScaleYFrequencyStartUnified || this._oscillationColorFrequencyStartUnified;
			
			this._oscillationColorFrequencyStart = value;
		}
		//##################################################
		//\OSCILLATION
		//##################################################
		/**
		 * @default	false
		 */
		public var forceSortFlag:Boolean = false;
		
		/**
		 * Vector.<Particle>->int->void
		 * @default	null
		 */
		public var customFunction:Function;
		
		protected var _isPlaying:Boolean = false;
		/**
		 * @default	false
		 */
		public function get isPlaying():Boolean { return this._isPlaying; }
		
		protected var _numParticles:int = 0;
		/**
		 * @default	0
		 */
		public function get numParticles():int { return this._numParticles; }
		
		protected var _sortFunction:Function;
		/**
		 * Particle->Particle->int
		 * @default	null
		 */
		public function get sortFunction():Function { return this._sortFunction; }
		public function set sortFunction(value:Function):void
		{
			this._sortFunction = value;
			this._regularSorting = this._sortFunction == null;
		}
		
		protected var _completed:Boolean = false;
		protected var _frameTime:Number = 0.0;
		protected var _particles:Vector.<Particle> = new Vector.<Particle>();
		protected var _particleTotal:int = 0;
		protected var _regularSorting:Boolean = true;
		protected var _updateEmitter:Boolean = false;
		
		protected var _frames:Vector.<Vector.<Frame>> = new Vector.<Vector.<Frame>>();
		protected var _frameTimings:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>();
		protected var _numFrameSets:int = 0;
		protected var _useMultipleFrameSets:Boolean = false;
		
		protected var _isParticlePoolUpdatePending:Boolean = false;
		
		public function ParticleSystem(options:ParticleSystemOptions = null) 
		{
			super();
			
			MathUtils.initSqrt();
			
			this.animate = true;
			this.autoHandleNumDatas = false;
			
			init();
			
			if (options != null)
			{
				readSystemOptions(options);
			}
		}
		
		public function clear():void
		{
			
		}
		
		protected function init():void
		{
			this._emissionRate = this._maxNumParticles / this._lifeSpan;
			this._emissionTime = 0.0;
			this._frameTime = 0.0;
		}
		
		public function addFrames(frames:Vector.<Frame>, timings:Vector.<Number> = null, refreshParticles:Boolean = true):void
		{
			if (timings == null) timings = Animator.generateTimings(frames);
			
			this._frames[this._frames.length] = frames;
			this._frameTimings[this._frameTimings.length] = timings;
			this._numFrameSets++;
			this._useMultipleFrameSets = this._numFrameSets > 1;
			
			if (refreshParticles)
			{
				returnParticlesToPool();
				if (this.particlesFromPoolFunction != null)
				{
					getParticlesFromPool();
				}
				else
				{
					this._isParticlePoolUpdatePending = true;
				}
			}
		}
		
		public function addFramesMultiple(frames:Vector.<Vector.<Frame>>, timings:Vector.<Vector.<Number>> = null, refreshParticles:Boolean = true):void
		{
			var count:int = frames.length;
			for (var i:int = 0; i < count; i++)
			{
				addFrames(frames[i], timings != null ? timings[i] : null, false);
			}
			
			if (refreshParticles)
			{
				returnParticlesToPool();
				if (this.particlesFromPoolFunction != null)
				{
					getParticlesFromPool();
				}
				else
				{
					this._isParticlePoolUpdatePending = true;
				}
			}
		}
		
		[Inline]
		final protected function getRandomRatio():Number
		{
			//return ((RANDOM_SEED = (RANDOM_SEED * 16807) & 0x7FFFFFFF) / 0x80000000) * 2.0 - 1.0;
			return (((this.randomSeed = (this.randomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
		}
		
		
		protected var __angle:Number;
		protected var __colorAlphaStart:Number;
		protected var __colorAlphaEnd:Number;
		protected var __colorBlueStart:Number;
		protected var __colorBlueEnd:Number;
		protected var __colorGreenStart:Number;
		protected var __colorGreenEnd:Number;
		protected var __colorRedStart:Number;
		protected var __colorRedEnd:Number;
		protected var __firstFrameWidth:Number;
		protected var __intAngle:int;
		protected var __lifeSpan:Number;
		protected var __nonFadeTime:Number;
		protected var __oscillationUnifiedFrequencyStart:Number;
		protected var __oscillationUnifiedFrequencyVariance:Number;
		protected var __radius:Number;
		protected var __radiusMax:Number;
		protected var __radiusMin:Number;
		protected var __random:Number;
		protected var __ratio:Number;
		protected var __rotationStart:Number;
		protected var __rotationEnd:Number;
		protected var __sizeXStart:Number;
		protected var __sizeYStart:Number;
		protected var __sizeXEnd:Number;
		protected var __sizeYEnd:Number;
		protected var __speed:Number;
		protected var __velocityXInheritRatio:Number;
		protected var __velocityYInheritRatio:Number;
		
		protected function initParticle(particle:Particle):void
		{
			particle.frameDelta = this._frameDelta + this.frameDeltaVariance * getRandomRatio();
			particle.frameTime = 0.0;
			particle.loopCount = 0;
			
			if (this.useAnimationLifeSpan)
			{
				if (this._loopAnimation)
				{
					if (this._animationLoops == 0)
					{
						this.__lifeSpan = Number.MAX_VALUE;
					}
					else
					{
						this.__lifeSpan = (particle.frameTimings[particle.frameTimings.length-1] / particle.frameDelta) * this._animationLoops;
					}
				}
				else
				{
					this.__lifeSpan = particle.frameTimings[particle.frameTimings.length-1] / particle.frameDelta;
				}
			}
			else
			{
				this.__lifeSpan = this._lifeSpan + this._lifeSpanVariance * getRandomRatio();
				if (this.__lifeSpan <= 0.0)
				{
					return;
				}
			}
			
			this.__speed = this.speed + this.speedVariance * getRandomRatio();
			if (this.adjustLifeSpanToSpeed)
			{
				this.__ratio = this.speed / this.__speed;
				this.__lifeSpan *= this.__ratio;
			}
			particle.speed = this.__speed;
			
			if (this._useFadeIn)
			{
				particle.fadeInTime = this._fadeInTime;
			}
			else
			{
				particle.fadeInTime = 0.0;
			}
			
			if (this._useFadeOut)
			{
				particle.fadeOutTime = this.__lifeSpan - this._fadeOutTime;
				particle.fadeOutDuration = this._fadeOutTime;
			}
			else
			{
				particle.fadeOutTime = this.__lifeSpan;
				particle.fadeOutDuration = 0.0;
			}
			
			this.__nonFadeTime = particle.fadeOutTime - particle.fadeInTime;
			
			particle.visible = true;
			particle.timeCurrent = 0.0;
			particle.timeTotal = this.__lifeSpan;
			
			if (this._useEmitterRadius)
			{
				this.__angle = MathUtils.random() * MathUtils.PI2;
				this.__intAngle = int(this.__angle * MassiveConstants.ANGLE_CONSTANT) & MassiveConstants.ANGLE_CONSTANT_2;
				this.__radiusMin = this._emitterRadiusMin + this._emitterRadiusMinVariance * getRandomRatio();
				this.__radiusMax = this._emitterRadiusMax + this._emitterRadiusMaxVariance * getRandomRatio();
				this.__radius = this.__radiusMin + MathUtils.random() * (this.__radiusMax - this.__radiusMin);
				
				particle.startX = particle.xBase = this.emitterX + this.emitterXVariance * getRandomRatio() + COS[this.__intAngle] * this.__radius;
				particle.startY = particle.yBase = this.emitterY + this.emitterYVariance * getRandomRatio() + SIN[this.__intAngle] * this.__radius;
			}
			else
			{
				particle.startX = particle.xBase = this.emitterX + this.emitterXVariance * getRandomRatio();
				particle.startY = particle.yBase = this.emitterY + this.emitterYVariance * getRandomRatio();
			}
			
			particle.angle = this.__angle = this.emitAngle + this.emitAngleVariance * getRandomRatio();
			this.__intAngle = int(this.__angle * MassiveConstants.ANGLE_CONSTANT) & MassiveConstants.ANGLE_CONSTANT_2;
			
			particle.velocityX = this.__speed * COS[this.__intAngle];
			particle.velocityY = this.__speed * SIN[this.__intAngle];
			
			if (this._useVelocityInheritanceX)
			{
				this.__velocityXInheritRatio = this._velocityXInheritRatio + this._velocityXInheritRatioVariance * getRandomRatio();
				particle.velocityX += this.velocityX * this.__velocityXInheritRatio;
			}
			
			if (this._useVelocityInheritanceY)
			{
				this.__velocityYInheritRatio = this._velocityYInheritRatio + this._velocityYInheritRatioVariance * getRandomRatio();
				particle.velocityY += this.velocityY * this.__velocityYInheritRatio;
			}
			
			if (this._useDrag)
			{
				particle.dragForce = this._drag + this._dragVariance * getRandomRatio();
			}
			
			particle.emitRadius = this.radiusMax + this.radiusMaxVariance * getRandomRatio();
			particle.emitRadiusDelta = (this.radiusMin + this.radiusMinVariance * getRandomRatio() - particle.emitRadius) / this.__lifeSpan;
			particle.emitRotation = this.emitAngle + this.emitAngleVariance * getRandomRatio();
			particle.emitRotationDelta = this.rotatePerSecond + this.rotatePerSecondVariance * getRandomRatio();
			particle.radialAcceleration = this.radialAcceleration + this.radialAccelerationVariance * getRandomRatio();
			particle.tangentialAcceleration = this.tangentialAcceleration + this.tangentialAccelerationVariance * getRandomRatio();
			
			particle.sizeXStart = this.__sizeXStart = this.sizeXStart + this.sizeXStartVariance * getRandomRatio();
			particle.sizeYStart = this.__sizeYStart = this.sizeYStart + this.sizeYStartVariance * getRandomRatio();
			particle.sizeXEnd = this.__sizeXEnd = this.sizeXEnd + this.sizeXEndVariance * getRandomRatio();
			particle.sizeYEnd = this.__sizeYEnd = this.sizeYEnd + this.sizeYEndVariance * getRandomRatio();
			
			this.__firstFrameWidth = particle.frameList[0].width;
			particle.scaleX = particle.scaleXBase = particle.scaleXStart = this.__sizeXStart / this.__firstFrameWidth;
			particle.scaleY = particle.scaleYBase = particle.scaleYStart = this.__sizeYStart / this.__firstFrameWidth;
			particle.scaleXEnd = this.__sizeXEnd / this.__firstFrameWidth;
			particle.scaleYEnd = this.__sizeYEnd / this.__firstFrameWidth;
			particle.scaleXDelta = (particle.scaleXEnd - particle.scaleXStart) / this.__lifeSpan;
			particle.scaleYDelta = (particle.scaleYEnd - particle.scaleYStart) / this.__lifeSpan;
			
			particle.scaleXVelocity = particle.scaleYVelocity = 1.0;
			
			// OSCILLATION
			if (this._useOscillationUnifiedFrequencyStart)
			{
				this.__oscillationUnifiedFrequencyStart = MathUtils.random() * MathUtils.PI2;
			}
			if (this._useOscillationUnifiedFrequencyVariance)
			{
				this.__oscillationUnifiedFrequencyVariance = this.oscillationUnifiedFrequencyVariance * getRandomRatio();
			}
			
			if (this._oscillationPositionEnabled)
			{
				particle.oscillationPositionAngle = this.oscillationPositionAngle + this.oscillationPositionAngleVariance * getRandomRatio();
				particle.oscillationPositionRadius = this._oscillationPositionRadius + this._oscillationPositionRadiusVariance * getRandomRatio();
				if (!this._oscillationPositionGlobalFrequencyEnabled && !this._oscillationPositionGroupFrequencyEnabled)
				{
					if (this._oscillationPositionUnifiedFrequencyVariance)
					{
						particle.oscillationPositionFrequency = this.oscillationPositionFrequency + this.__oscillationUnifiedFrequencyVariance;
					}
					else
					{
						particle.oscillationPositionFrequency = this.oscillationPositionFrequency + this.oscillationPositionFrequencyVariance * getRandomRatio();
					}
					
					if (this._oscillationPositionFrequencyStartRandomized)
					{
						particle.oscillationPositionStep = MathUtils.random() * MathUtils.PI2;
					}
					else if (this._oscillationPositionFrequencyStartUnified)
					{
						particle.oscillationPositionStep = this.__oscillationUnifiedFrequencyStart;
					}
					else
					{
						particle.oscillationPositionStep = 0.0;
					}
				}
			}
			else
			{
				particle.oscillationPositionX = particle.oscillationPositionY = 0.0;
			}
			
			if (this._oscillationPosition2Enabled)
			{
				particle.oscillationPosition2Angle = this.oscillationPosition2Angle + this.oscillationPosition2AngleVariance * getRandomRatio();
				particle.oscillationPosition2Radius = this._oscillationPosition2Radius + this._oscillationPosition2RadiusVariance * getRandomRatio();
				if (!this._oscillationPosition2GlobalFrequencyEnabled && !this._oscillationPosition2GroupFrequencyEnabled)
				{
					if (this._oscillationPosition2UnifiedFrequencyVariance)
					{
						particle.oscillationPosition2Frequency = this.oscillationPosition2Frequency + this.__oscillationUnifiedFrequencyVariance;
					}
					else
					{
						particle.oscillationPosition2Frequency = this.oscillationPosition2Frequency + this.oscillationPosition2FrequencyVariance * getRandomRatio();
					}
					
					if (this._oscillationPosition2FrequencyStartRandomized)
					{
						particle.oscillationPosition2Step = MathUtils.random() * MathUtils.PI2;
					}
					else if (this._oscillationPosition2FrequencyStartUnified)
					{
						particle.oscillationPosition2Step = this.__oscillationUnifiedFrequencyStart;
					}
					else
					{
						particle.oscillationPosition2Step = 0.0;
					}
				}
			}
			else
			{
				particle.oscillationPosition2X = particle.oscillationPosition2Y = 0.0;
			}
			
			if (this._oscillationRotationEnabled)
			{
				particle.oscillationRotationAngle = this._oscillationRotationAngle + this._oscillationRotationAngleVariance * getRandomRatio();
				if (!this._oscillationRotationGlobalFrequencyEnabled && !this._oscillationRotationGroupFrequencyEnabled)
				{
					if (this._oscillationRotationUnifiedFrequencyVariance)
					{
						particle.oscillationRotationFrequency = this.oscillationRotationFrequency + this.__oscillationUnifiedFrequencyVariance;
					}
					else
					{
						particle.oscillationRotationFrequency = this.oscillationRotationFrequency + this.oscillationRotationFrequencyVariance * getRandomRatio();
					}
					
					if (this._oscillationRotationFrequencyStartRandomized)
					{
						particle.oscillationRotationStep = MathUtils.random() * MathUtils.PI2;
					}
					else if (this._oscillationRotationFrequencyStartUnified)
					{
						particle.oscillationRotationStep = this.__oscillationUnifiedFrequencyStart;
					}
					else
					{
						particle.oscillationRotationStep = 0.0;
					}
				}
			}
			else
			{
				particle.oscillationRotation = 0.0;
			}
			
			if (this._oscillationScaleXEnabled)
			{
				particle.oscillationScaleX = this._oscillationScaleX + this._oscillationScaleXVariance * getRandomRatio();
				if (!this._oscillationScaleXGlobalFrequencyEnabled && !this._oscillationScaleXGroupFrequencyEnabled)
				{
					if (this._oscillationScaleXUnifiedFrequencyVariance)
					{
						particle.oscillationScaleXFrequency = this.oscillationScaleXFrequency + this.__oscillationUnifiedFrequencyVariance;
					}
					else
					{
						particle.oscillationScaleXFrequency = this.oscillationScaleXFrequency + this.oscillationScaleXFrequencyVariance * getRandomRatio();
					}
					
					if (this._oscillationScaleXFrequencyStartRandomized)
					{
						particle.oscillationScaleXStep = MathUtils.random() * MathUtils.PI2;
					}
					else if (this._oscillationScaleXFrequencyStartUnified)
					{
						particle.oscillationScaleXStep = this.__oscillationUnifiedFrequencyStart;
					}
					else
					{
						particle.oscillationScaleXStep = 0.0;
					}
				}
			}
			else
			{
				particle.scaleXOscillation = 1.0;
			}
			
			if (this._oscillationScaleYEnabled)
			{
				particle.oscillationScaleY = this._oscillationScaleY + this._oscillationScaleYVariance * getRandomRatio();
				if (!this._oscillationScaleYGlobalFrequencyEnabled && !this._oscillationScaleYGroupFrequencyEnabled)
				{
					if (this._oscillationScaleYUnifiedFrequencyVariance)
					{
						particle.oscillationScaleYFrequency = this.oscillationScaleYFrequency + this.__oscillationUnifiedFrequencyVariance;
					}
					else
					{
						particle.oscillationScaleYFrequency = this.oscillationScaleYFrequency + this.oscillationScaleYFrequencyVariance * getRandomRatio();
					}
					
					if (this._oscillationScaleYFrequencyStartRandomized)
					{
						particle.oscillationScaleYStep = MathUtils.random() * MathUtils.PI2;
					}
					else if (this._oscillationScaleYFrequencyStartUnified)
					{
						particle.oscillationScaleYStep = this.__oscillationUnifiedFrequencyStart;
					}
					else
					{
						particle.oscillationScaleYStep = 0.0;
					}
				}
			}
			else
			{
				particle.scaleYOscillation = 1.0;
			}
			
			if (this._useOscillationColor)
			{
				particle.oscillationColorRedFactor = this._oscillationColorRed + this._oscillationColorRedVariance * getRandomRatio();
				particle.oscillationColorGreenFactor = this._oscillationColorGreen + this._oscillationColorGreenVariance * getRandomRatio();
				particle.oscillationColorBlueFactor = this._oscillationColorBlue + this._oscillationColorBlueVariance * getRandomRatio();
				particle.oscillationColorAlphaFactor = this._oscillationColorAlpha + this._oscillationColorAlphaVariance * getRandomRatio();
				if (!this._oscillationColorGlobalFrequencyEnabled && !this._oscillationColorGroupFrequencyEnabled)
				{
					if (this._oscillationColorUnifiedFrequencyVariance)
					{
						particle.oscillationColorFrequency = this.oscillationColorFrequency + this.__oscillationUnifiedFrequencyVariance;
					}
					else
					{
						particle.oscillationColorFrequency = this.oscillationColorFrequency + this.oscillationColorFrequencyVariance * getRandomRatio();
					}
					
					if (this._oscillationColorFrequencyStartRandomized)
					{
						particle.oscillationColorStep = MathUtils.random() * MathUtils.PI2;
					}
					else if (this._oscillationColorFrequencyStartUnified)
					{
						particle.oscillationColorStep = this.__oscillationUnifiedFrequencyStart;
					}
					else
					{
						particle.oscillationColorStep = 0.0;
					}
				}
			}
			else
			{
				particle.oscillationColorRed = particle.oscillationColorGreen = particle.oscillationColorBlue = particle.oscillationColorAlpha = 0.0;
			}
			//\OSCILLATION
			
			// color
			this.__colorRedStart = this.colorStart.red + this.colorStartVariance.red * getRandomRatio();
			this.__colorGreenStart = this.colorStart.green + this.colorStartVariance.green * getRandomRatio();
			this.__colorBlueStart = this.colorStart.blue + this.colorStartVariance.blue * getRandomRatio();
			this.__colorAlphaStart = this.colorStart.alpha + this.colorStartVariance.alpha * getRandomRatio();
			
			if (this.colorEndRelativeToStart)
			{
				if (this.colorEndIsMultiplier)
				{
					this.__colorRedEnd = this.__colorRedStart * (this.colorEnd.red + this.colorEndVariance.red * getRandomRatio());
					this.__colorGreenEnd = this.__colorGreenStart * (this.colorEnd.green + this.colorEndVariance.green * getRandomRatio());
					this.__colorBlueEnd = this.__colorBlueStart * (this.colorEnd.blue + this.colorEndVariance.blue * getRandomRatio());
					this.__colorAlphaEnd = this.__colorAlphaStart * (this.colorEnd.alpha + this.colorEndVariance.alpha * getRandomRatio());
				}
				else
				{
					this.__colorRedEnd = this.__colorRedStart + this.colorEnd.red + this.colorEndVariance.red * getRandomRatio();
					this.__colorGreenEnd = this.__colorGreenStart + this.colorEnd.green + this.colorEndVariance.green * getRandomRatio();
					this.__colorBlueEnd = this.__colorBlueStart + this.colorEnd.blue + this.colorEndVariance.blue * getRandomRatio();
					this.__colorAlphaEnd = this.__colorAlphaStart + this.colorEnd.alpha + this.colorEndVariance.alpha * getRandomRatio();
				}
			}
			else
			{
				this.__colorRedEnd = this.colorEnd.red + this.colorEndVariance.red * getRandomRatio();
				this.__colorGreenEnd = this.colorEnd.green + this.colorEndVariance.green * getRandomRatio();
				this.__colorBlueEnd = this.colorEnd.blue + this.colorEndVariance.blue * getRandomRatio();
				this.__colorAlphaEnd = this.colorEnd.alpha + this.colorEndVariance.alpha * getRandomRatio();
			}
			
			particle.colorRedBase = this.__colorRedStart;
			particle.colorGreenBase = this.__colorGreenStart;
			particle.colorBlueBase = this.__colorBlueStart;
			particle.colorAlphaBase = this._useFadeIn ? 0.0 : this.__colorAlphaStart;
			
			particle.colorRedStart = this.__colorRedStart;
			particle.colorGreenStart = this.__colorGreenStart;
			particle.colorBlueStart = this.__colorBlueStart;
			particle.colorAlphaStart = this.__colorAlphaStart;
			
			particle.colorRedEnd = this.__colorRedEnd;
			particle.colorGreenEnd = this.__colorGreenEnd;
			particle.colorBlueEnd = this.__colorBlueEnd;
			particle.colorAlphaEnd = this.__colorAlphaEnd;
			
			particle.colorRedDelta = (this.__colorRedEnd - this.__colorRedStart) / this.__lifeSpan;
			particle.colorGreenDelta = (this.__colorGreenEnd - this.__colorGreenStart) / this.__lifeSpan;
			particle.colorBlueDelta = (this.__colorBlueEnd - this.__colorBlueStart) / this.__lifeSpan;
			particle.colorAlphaDelta = (this.__colorAlphaEnd - this.__colorAlphaStart) / this.__nonFadeTime; // we only interpolate alpha
			
			particle.isFadingIn = this._useFadeIn;
			
			if (this.emitAngleAlignedRotation)
			{
				this.__rotationStart = this.__angle + this.rotationStart + this.rotationStartVariance * getRandomRatio();
				if (this.rotationEndRelativeToStart)
				{
					this.__rotationEnd = this.__rotationStart + this.rotationEnd + this.rotationEndVariance * getRandomRatio();
				}
				else
				{
					this.__rotationEnd = this.__angle + this.rotationEnd + this.rotationEndVariance * getRandomRatio();
				}
			}
			else
			{
				this.__rotationStart = this.rotationStart + this.rotationStartVariance * getRandomRatio();
				if (this.rotationEndRelativeToStart)
				{
					this.__rotationEnd = this.__rotationStart + this.rotationEnd + this.rotationEndVariance * getRandomRatio();
				}
				else
				{
					this.__rotationEnd = this.rotationEnd + this.rotationEndVariance * getRandomRatio();
				}
			}
			
			particle.rotationBase = this.__rotationStart;
			particle.rotationDelta = (this.__rotationEnd - this.__rotationStart) / this.__lifeSpan;
			
			if (this.randomStartFrame)
			{
				this.__random = MathUtils.random() * particle.frameCount
				particle.frameIndex = MathUtils.floor(this.__random);
			}
			else
			{
				particle.frameIndex = 0;
			}
		}
		
		protected var __restTime:Number;
		protected var __distanceX:Number;
		protected var __distanceY:Number;
		protected var __distanceScalar:Number;
		protected var __dragX:Number;
		protected var __dragY:Number;
		protected var __newY:Number;
		protected var __radialX:Number;
		protected var __radialY:Number;
		protected var __refAngle:Number;
		protected var __repellentDistanceX:Number;
		protected var __repellentDistanceY:Number;
		protected var __repellentDistanceScalar:Number;
		protected var __repellentRadialX:Number;
		protected var __repellentRadialY:Number;
		protected var __step:Number;
		protected var __tangentialX:Number;
		protected var __tangentialY:Number;
		protected var __velocityAngle:Number;
		protected var __velocityAngleCalculated:Boolean;
		protected var __velocityScalar:Number;
		
		protected function advanceParticle(particle:Particle, passedTime:Number):void
		{
			this.__restTime = particle.timeTotal - particle.timeCurrent;
			passedTime = this.__restTime > passedTime ? passedTime : this.__restTime;
			particle.timeCurrent += passedTime;
			
			this.__velocityAngleCalculated = false;
			
			if (this.emitterType == EmitterType.RADIAL)
			{
				// RADIAL
				particle.emitRotation += particle.emitRotationDelta * passedTime;
				particle.emitRadius += particle.emitRadiusDelta * passedTime;
				this.__intAngle = int(particle.emitRotation * MassiveConstants.ANGLE_CONSTANT) & MassiveConstants.ANGLE_CONSTANT_2;
				particle.x = this.emitterX - COS[this.__intAngle] * particle.emitRadius;
				particle.y = this.emitterY - SIN[this.__intAngle] * particle.emitRadius;
			}
			else 
			{
				// GRAVITY
				if (particle.radialAcceleration != 0 || particle.tangentialAcceleration != 0)
				{
					this.__distanceX = particle.x - particle.startX;
					this.__distanceY = particle.y - particle.startY;
					
					// it's better to use invSqrt instead of sqrt here : we just need to multiply instead of divide
					this.__distanceScalar = MathUtils.invSqrt(this.__distanceX * this.__distanceX + this.__distanceY * this.__distanceY);
					this.__radialX = this.__distanceX * this.__distanceScalar;
					this.__radialY = this.__distanceY * this.__distanceScalar;
					
					this.__tangentialX = this.__radialX;
					this.__tangentialY = this.__radialY;
					
					this.__radialX *= particle.radialAcceleration;
					this.__radialY *= particle.radialAcceleration;
					
					this.__newY = this.__tangentialX;
					this.__tangentialX = -this.__tangentialY * particle.tangentialAcceleration;
					this.__tangentialY = this.__newY * particle.tangentialAcceleration;
					
					particle.velocityX += passedTime * (this.gravityX + this.__radialX + this.__tangentialX);
					particle.velocityY += passedTime * (this.gravityY + this.__radialY + this.__tangentialY);
				}
				else
				{
					particle.velocityX += passedTime * this.gravityX;
					particle.velocityY += passedTime * this.gravityY;
				}
				
				if (this._useRepellentForce)
				{
					this.__repellentDistanceX = particle.x - this.emitterX;
					this.__repellentDistanceY = particle.y - this.emitterY;
					
					// it's better to use invSqrt instead of sqrt here : we just need to multiply instead of divide
					this.__repellentDistanceScalar = MathUtils.invSqrt(this.__repellentDistanceX * this.__repellentDistanceX + this.__repellentDistanceY * this.__repellentDistanceY);
					this.__repellentRadialX = this.__repellentDistanceX * this.__repellentDistanceScalar * this._repellentForce;
					this.__repellentRadialY = this.__repellentDistanceY * this.__repellentDistanceScalar * this._repellentForce;
					
					particle.velocityX += passedTime * this.__repellentRadialX;
					particle.velocityY += passedTime * this.__repellentRadialY;
				}
				
				if (this._useDrag)
				{
					this.__dragX = particle.velocityX * particle.dragForce;
					this.__dragY = particle.velocityY * particle.dragForce;
					
					particle.velocityX -= passedTime * this.__dragX;
					particle.velocityY -= passedTime * this.__dragY;
				}
				
				particle.xBase += particle.velocityX * passedTime;
				particle.yBase += particle.velocityY * passedTime;
			}
			
			particle.x = particle.xBase;
			particle.y = particle.yBase;
			
			if (this.linkRotationToVelocity)
			{
				if (!this.__velocityAngleCalculated)
				{
					if (particle.velocityX == 0.0 && particle.velocityY == 0.0)
					{
						this.__velocityAngle = 0.0;
					}
					else
					{
						this.__velocityAngle = MathUtils.atan2(particle.velocityY, particle.velocityX);
					}
					this.__velocityAngleCalculated = true;
				}
				particle.rotationBase = this.__velocityAngle + this.velocityRotationOffset;
			}
			else
			{
				particle.rotationBase += particle.rotationDelta * passedTime;
			}
			
			// OSCILLATION
			if (this._oscillationRotationEnabled)
			{
				if (this._oscillationRotationGlobalFrequencyEnabled)
				{
					if (this.oscillationRotationFrequencyInverted)
					{
						particle.oscillationRotation = this._oscillationGlobalValueInverted * particle.oscillationRotationAngle;
					}
					else
					{
						particle.oscillationRotation = this._oscillationGlobalValue * particle.oscillationRotationAngle;
					}
				}
				else if (this._oscillationRotationGroupFrequencyEnabled)
				{
					particle.oscillationRotation = this._oscillationRotationGroupValue * particle.oscillationRotationAngle;
				}
				else
				{
					particle.oscillationRotationStep += particle.oscillationRotationFrequency * passedTime;
					this.__intAngle = int(particle.oscillationRotationStep * MassiveConstants.ANGLE_CONSTANT) & MassiveConstants.ANGLE_CONSTANT_2;
					if (this.oscillationRotationFrequencyInverted)
					{
						particle.oscillationRotation = SIN[this.__intAngle] * particle.oscillationRotationAngle;
					}
					else
					{
						particle.oscillationRotation = COS[this.__intAngle] * particle.oscillationRotationAngle;
					}
				}
				particle.rotation = particle.rotationBase + particle.oscillationRotation;
			}
			else
			{
				particle.rotation = particle.rotationBase;
			}
			
			if (this._oscillationPositionEnabled)
			{
				if (this._oscillationPositionAngleRelativeToRotation)
				{
					this.__refAngle = particle.rotation;
				}
				else if (this._oscillationPositionAngleRelativeToVelocity)
				{
					if (!this.__velocityAngleCalculated)
					{
						if (particle.velocityX == 0.0 && particle.velocityY == 0.0)
						{
							this.__velocityAngle = 0.0;
						}
						else
						{
							this.__velocityAngle = MathUtils.atan2(particle.velocityY, particle.velocityX);
						}
						this.__velocityAngleCalculated = true;
					}
					this.__refAngle = this.__velocityAngle;
				}
				else
				{
					this.__refAngle = 0.0;
				}
				
				if (this._oscillationPositionGlobalFrequencyEnabled)
				{
					if (this.oscillationPositionFrequencyInverted)
					{
						this.__radius = this._oscillationGlobalValueInverted * particle.oscillationPositionRadius;
					}
					else
					{
						this.__radius = this._oscillationGlobalValue * particle.oscillationPositionRadius;
					}
				}
				else if (this._oscillationPositionGroupFrequencyEnabled)
				{
					this.__radius = this._oscillationPositionGroupValue * particle.oscillationPositionRadius;
				}
				else
				{
					particle.oscillationPositionStep += particle.oscillationPositionFrequency * passedTime;
					this.__intAngle = int(particle.oscillationPositionStep * MassiveConstants.ANGLE_CONSTANT) & MassiveConstants.ANGLE_CONSTANT_2;
					if (this.oscillationPositionFrequencyInverted)
					{
						this.__radius = SIN[this.__intAngle] * particle.oscillationPositionRadius;
					}
					else
					{
						this.__radius = COS[this.__intAngle] * particle.oscillationPositionRadius;
					}
				}
				this.__angle = this.__refAngle + particle.oscillationPositionAngle;
				this.__intAngle = int(this.__angle * MassiveConstants.ANGLE_CONSTANT) & MassiveConstants.ANGLE_CONSTANT_2;
				particle.oscillationPositionX = COS[this.__intAngle] * this.__radius;
				particle.oscillationPositionY = SIN[this.__intAngle] * this.__radius;
				
				particle.x += particle.oscillationPositionX;
				particle.y += particle.oscillationPositionY;
			}
			
			if (this._oscillationPosition2Enabled)
			{
				if (this._oscillationPosition2AngleRelativeToRotation)
				{
					this.__refAngle = particle.rotation;
				}
				else if (this._oscillationPosition2AngleRelativeToVelocity)
				{
					if (!this.__velocityAngleCalculated)
					{
						if (particle.velocityX == 0.0 && particle.velocityY == 0.0)
						{
							this.__velocityAngle = 0.0;
						}
						else
						{
							this.__velocityAngle = MathUtils.atan2(particle.velocityY, particle.velocityX);
						}
						this.__velocityAngleCalculated = true;
					}
					this.__refAngle = this.__velocityAngle;
				}
				else
				{
					this.__refAngle = 0.0;
				}
				
				if (this._oscillationPosition2GlobalFrequencyEnabled)
				{
					if (this.oscillationPosition2FrequencyInverted)
					{
						this.__radius = this._oscillationGlobalValueInverted * particle.oscillationPosition2Radius;
					}
					else
					{
						this.__radius = this._oscillationGlobalValue * particle.oscillationPosition2Radius;
					}
				}
				else if (this._oscillationPosition2GroupFrequencyEnabled)
				{
					this.__radius = this._oscillationPosition2GroupValue * particle.oscillationPosition2Radius;
				}
				else
				{
					particle.oscillationPosition2Step += particle.oscillationPosition2Frequency * passedTime;
					this.__intAngle = int(particle.oscillationPosition2Step * MassiveConstants.ANGLE_CONSTANT) & MassiveConstants.ANGLE_CONSTANT_2;
					if (this.oscillationPosition2FrequencyInverted)
					{
						this.__radius = SIN[this.__intAngle] * particle.oscillationPosition2Radius;
					}
					else
					{
						this.__radius = COS[this.__intAngle] * particle.oscillationPosition2Radius;
					}
				}
				this.__angle = this.__refAngle + particle.oscillationPosition2Angle;
				this.__intAngle = int(this.__angle * MassiveConstants.ANGLE_CONSTANT) & MassiveConstants.ANGLE_CONSTANT_2;
				particle.oscillationPosition2X = COS[this.__intAngle] * this.__radius;
				particle.oscillationPosition2Y = SIN[this.__intAngle] * this.__radius;
				
				particle.x += particle.oscillationPosition2X;
				particle.y += particle.oscillationPosition2Y;
			}
			
			if (this._oscillationScaleXEnabled)
			{
				if (this._oscillationScaleXGlobalFrequencyEnabled)
				{
					if (this.oscillationScaleXFrequencyInverted)
					{
						particle.scaleXOscillation = 1.0 + this._oscillationGlobalValueInverted * particle.oscillationScaleX;
					}
					else
					{
						particle.scaleXOscillation = 1.0 + this._oscillationGlobalValue * particle.oscillationScaleX;
					}
				}
				else if (this._oscillationScaleXGroupFrequencyEnabled)
				{
					particle.scaleXOscillation = 1.0 + this._oscillationScaleXGroupValue * particle.oscillationScaleX;
				}
				else
				{
					particle.oscillationScaleXStep += particle.oscillationScaleXFrequency * passedTime;
					this.__intAngle = int(particle.oscillationScaleXStep * MassiveConstants.ANGLE_CONSTANT) & MassiveConstants.ANGLE_CONSTANT_2;
					if (this.oscillationScaleXFrequencyInverted)
					{
						particle.scaleXOscillation = 1.0 + SIN[this.__intAngle] * particle.oscillationScaleX;
					}
					else
					{
						particle.scaleXOscillation = 1.0 + COS[this.__intAngle] * particle.oscillationScaleX;
					}
				}
			}
			
			if (this._oscillationScaleYEnabled)
			{
				if (this._oscillationScaleYGlobalFrequencyEnabled)
				{
					if (this.oscillationScaleYFrequencyInverted)
					{
						particle.scaleYOscillation = 1.0 + this._oscillationGlobalValueInverted * particle.oscillationScaleY;
					}
					else
					{
						particle.scaleYOscillation = 1.0 + this._oscillationGlobalValue * particle.oscillationScaleY;
					}
				}
				else if (this._oscillationScaleYGroupFrequencyEnabled)
				{
					particle.scaleYOscillation = 1.0 + this._oscillationScaleYGroupValue * particle.oscillationScaleY;
				}
				else
				{
					particle.oscillationScaleYStep += particle.oscillationScaleYFrequency * passedTime;
					this.__intAngle = int(particle.oscillationScaleYStep * MassiveConstants.ANGLE_CONSTANT) & MassiveConstants.ANGLE_CONSTANT_2;
					if (this.oscillationScaleYFrequencyInverted)
					{
						particle.scaleYOscillation = 1.0 + SIN[this.__intAngle] * particle.oscillationScaleY;
					}
					else
					{
						particle.scaleYOscillation = 1.0 + COS[this.__intAngle] * particle.oscillationScaleY;
					}
				}
			}
			//\OSCILLATION
			
			if (this.useDisplayRect)
			{
				if (!this.displayRect.contains(particle.x, particle.y))
				{
					particle.timeCurrent = particle.timeTotal; // "destroy" particle
					particle.visible = false;
					return;
				}
			}
			
			if (this._useVelocityScale)
			{
				this.__velocityScalar = MathUtils.sqrt(particle.velocityX * particle.velocityX + particle.velocityY * particle.velocityY);
				
				if (this._useVelocityScaleX)
				{
					particle.scaleXVelocity = 1.0 + (this._velocityScaleFactorX * this.__velocityScalar);
				}
				
				if (this._useVelocityScaleY)
				{
					particle.scaleYVelocity = 1.0 + (this._velocityScaleFactorY * this.__velocityScalar);
				}
			}
			
			particle.scaleXBase += particle.scaleXDelta * passedTime;
			particle.scaleYBase += particle.scaleYDelta * passedTime;
			particle.scaleX = particle.scaleXBase * particle.scaleXVelocity * particle.scaleXOscillation;
			particle.scaleY = particle.scaleYBase * particle.scaleYVelocity * particle.scaleYOscillation;
			
			particle.colorRedBase += particle.colorRedDelta * passedTime;
			particle.colorGreenBase += particle.colorGreenDelta * passedTime;
			particle.colorBlueBase += particle.colorBlueDelta * passedTime;
			
			if (this._useFadeIn && particle.timeCurrent <= particle.fadeInTime)
			{
				particle.colorAlphaBase = particle.colorAlphaStart * (particle.timeCurrent / particle.fadeInTime);
			}
			else if (this._useFadeOut && particle.timeCurrent >= particle.fadeOutTime)
			{
				particle.colorAlphaBase = particle.colorAlphaEnd * (1.0 - (particle.timeCurrent - particle.fadeOutTime) / particle.fadeOutDuration);
			}
			else
			{
				if (particle.isFadingIn)
				{
					particle.colorAlphaBase = particle.colorAlphaStart;
					particle.isFadingIn = false;
				}
				particle.colorAlphaBase += particle.colorAlphaDelta * passedTime;
			}
			
			// OSCILLATION COLOR
			if (this._useOscillationColor)
			{
				if (this._oscillationColorGlobalFrequencyEnabled)
				{
					if (this.oscillationColorFrequencyInverted)
					{
						this.__step = this._oscillationGlobalValueInverted;
					}
					else
					{
						this.__step = this._oscillationGlobalValue;
					}
				}
				else if (this._oscillationColorGroupFrequencyEnabled)
				{
					this.__step = this._oscillationColorGroupValue;
				}
				else
				{
					particle.oscillationColorStep += particle.oscillationColorFrequency * passedTime;
					this.__intAngle = int(particle.oscillationColorStep * MassiveConstants.ANGLE_CONSTANT) & MassiveConstants.ANGLE_CONSTANT_2;
					if (this.oscillationColorFrequencyInverted)
					{
						this.__step = SIN[this.__intAngle];
					}
					else
					{
						this.__step = COS[this.__intAngle];
					}
				}
				
				particle.oscillationColorRed = particle.oscillationColorRedFactor * this.__step;
				particle.oscillationColorGreen = particle.oscillationColorGreenFactor * this.__step;
				particle.oscillationColorBlue = particle.oscillationColorBlueFactor * this.__step;
				particle.oscillationColorAlpha = particle.oscillationColorAlphaFactor * this.__step;
				
				particle.red = particle.colorRedBase + particle.oscillationColorRed;
				particle.green = particle.colorGreenBase + particle.oscillationColorGreen;
				particle.blue = particle.colorBlueBase + particle.oscillationColorBlue;
				particle.alpha = particle.colorAlphaBase + particle.oscillationColorAlpha;
			}
			else
			{
				particle.red = particle.colorRedBase;
				particle.green = particle.colorGreenBase;
				particle.blue = particle.colorBlueBase;
				particle.alpha = particle.colorAlphaBase;
			}
			//\OSCILLATION COLOR
		}
		
		override public function advanceTime(time:Number):void 
		{
			var sortFlag:Boolean = this.forceSortFlag;
			
			if (this._updateEmitter)
			{
				this._emitterObject.advanceSystem(this, time);
			}
			
			if (this._useOscillationGlobalFrequency)
			{
				this._oscillationGlobalStep += this.oscillationGlobalFrequency * time;
				this.__intAngle = int(this._oscillationGlobalStep * MassiveConstants.ANGLE_CONSTANT) & MassiveConstants.ANGLE_CONSTANT_2;
				this._oscillationGlobalValue = COS[this.__intAngle];
				this._oscillationGlobalValueInverted = SIN[this.__intAngle];
			}
			
			if (this._oscillationPositionEnabled && this._oscillationPositionGroupFrequencyEnabled)
			{
				this._oscillationPositionGroupStep += this.oscillationPositionFrequency * time;
				this.__intAngle = int(this._oscillationPositionGroupStep * MassiveConstants.ANGLE_CONSTANT) & MassiveConstants.ANGLE_CONSTANT_2;
				if (this.oscillationPositionFrequencyInverted)
				{
					this._oscillationPositionGroupValue = SIN[this.__intAngle];
				}
				else
				{
					this._oscillationPositionGroupValue = COS[this.__intAngle];
				}
			}
			
			if (this._oscillationPosition2Enabled && this._oscillationPosition2GroupFrequencyEnabled)
			{
				this._oscillationPosition2GroupStep += this.oscillationPosition2Frequency * time;
				this.__intAngle = int(this._oscillationPosition2GroupStep * MassiveConstants.ANGLE_CONSTANT) & MassiveConstants.ANGLE_CONSTANT_2;
				if (this.oscillationPosition2FrequencyInverted)
				{
					this._oscillationPosition2GroupValue = SIN[this.__intAngle];
				}
				else
				{
					this._oscillationPosition2GroupValue = COS[this.__intAngle];
				}
			}
			
			if (this._oscillationRotationEnabled && this._oscillationRotationGroupFrequencyEnabled)
			{
				this._oscillationRotationGroupStep += this.oscillationRotationFrequency * time;
				this.__intAngle = int(this._oscillationRotationGroupStep * MassiveConstants.ANGLE_CONSTANT) & MassiveConstants.ANGLE_CONSTANT_2;
				if (this.oscillationRotationFrequencyInverted)
				{
					this._oscillationRotationGroupValue = SIN[this.__intAngle];
				}
				else
				{
					this._oscillationRotationGroupValue = COS[this.__intAngle];
				}
			}
			
			if (this._oscillationScaleXEnabled && this._oscillationScaleXGroupFrequencyEnabled)
			{
				this._oscillationScaleXGroupStep += this.oscillationScaleXFrequency * time;
				this.__intAngle = int(this._oscillationScaleXGroupStep * MassiveConstants.ANGLE_CONSTANT) & MassiveConstants.ANGLE_CONSTANT_2;
				if (this.oscillationScaleXFrequencyInverted)
				{
					this._oscillationScaleXGroupValue = SIN[this.__intAngle];
				}
				else
				{
					this._oscillationScaleXGroupValue = COS[this.__intAngle];
				}
			}
			
			if (this._oscillationScaleYEnabled && this._oscillationScaleYGroupFrequencyEnabled)
			{
				this._oscillationScaleYGroupStep += this.oscillationScaleYFrequency * time;
				this.__intAngle = int(this._oscillationScaleYGroupStep * MassiveConstants.ANGLE_CONSTANT) & MassiveConstants.ANGLE_CONSTANT_2;
				if (this.oscillationScaleYFrequencyInverted)
				{
					this._oscillationScaleYGroupValue = SIN[this.__intAngle];
				}
				else
				{
					this._oscillationScaleYGroupValue = COS[this.__intAngle];
				}
			}
			
			if (this._useOscillationColor && this._oscillationColorGroupFrequencyEnabled)
			{
				this._oscillationColorGroupStep += this.oscillationColorFrequency * time;
				this.__intAngle = int(this._oscillationColorGroupStep * MassiveConstants.ANGLE_CONSTANT) & MassiveConstants.ANGLE_CONSTANT_2;
				if (this.oscillationColorFrequencyInverted)
				{
					this._oscillationColorGroupValue = SIN[this.__intAngle];
				}
				else
				{
					this._oscillationColorGroupValue = COS[this.__intAngle];
				}
			}
			
			var particleIndex:int = 0;
			var currentIndex:int = 0;
			var particle:Particle;
			// DEBUG
			//var allParticles:Vector.<Particle> = this._particles;
			//\DEBUG
			
			// advance existing particles
			if (this._regularSorting)
			{
				while (particleIndex < this._numParticles)
				{
					particle = this._particles[particleIndex];
					if (particle != null)
					{
						if (particle.timeCurrent < particle.timeTotal)
						{
							if (currentIndex != particleIndex)
							{
								this._particles[particleIndex] = this._datas[particleIndex] = null;
								this._particles[currentIndex] = this._datas[currentIndex] = particle;
							}
							
							advanceParticle(particle, time);
							++currentIndex;
						}
						else
						{
							particle.visible = false;
							this._particles[this._particles.length] = this._datas[this._datas.length] = particle;
							this._particles[particleIndex] = this._datas[particleIndex] = null;
						}
					}
					++particleIndex;
				}
				this._numParticles = currentIndex;
				
				if (particleIndex != currentIndex)
				{
					var count:int = this._particles.length;
					for (particleIndex; particleIndex < count; particleIndex++)
					{
						particle = this._particles[particleIndex];
						if (particle != null)
						{
							this._particles[particleIndex] = this._datas[particleIndex] = null;
							this._particles[currentIndex] = this._datas[currentIndex] = particle;
							++currentIndex;
						}
					}
					this._particles.length = this._datas.length = this._maxNumParticles;
				}
			}
			else
			{
				while (particleIndex < this._numParticles)
				{
					particle = this._particles[particleIndex];
					
					if (particle.timeCurrent < particle.timeTotal)
					{
						advanceParticle(particle, time);
						++particleIndex;
					}
					else
					{
						particle.visible = false;
						
						if (particleIndex != --this._numParticles)
						{
							var nextParticle:Particle = this._particles[this._numParticles];
							this._datas[this._numParticles] = this._particles[this._numParticles] = particle; // put dead particle at the end
							this._datas[particleIndex] = this._particles[particleIndex] = nextParticle;
							sortFlag = true;
						}
						
						if (this._numParticles == 0 && this._emissionTime < 0)
						{
							stop(this.autoClearOnComplete);
							complete();
							break;
						}
					}
				}
			}
			
			// create and advance new particles
			if ((this.particleAmount == 0 || this._particleTotal < this.particleAmount) && this._emissionTime > 0.0 && this._emissionRate > 0.0)
			{
				this._frameTime += time;
				var timeBetweenParticles:Number = 1.0 / this._emissionRate;
				var maxParticles:int = this.particleAmount == 0 ? this._maxNumParticles : this._numParticles + (this.particleAmount - this._particleTotal);
				
				while (this._frameTime > 0 && this._numParticles < maxParticles)//this._maxNumParticles) // && this._numParticles < this._maxCapacity // TODO : handle max capacity
				{
					particle = this._particles[this._numParticles];
					initParticle(particle);
					advanceParticle(particle, this._frameTime);
					
					++this._numParticles;
					++this._particleTotal;
					
					this._frameTime -= timeBetweenParticles;
				}
				
				if (this._emissionTime != Number.MAX_VALUE)
				{
					this._emissionTime = MathUtils.max(0.0, this._emissionTime - time);
				}
			}
			else if (!this._completed && this._numParticles == 0)
			{
				stop(this.autoClearOnComplete);
				complete();
				return;
			}
			
			this.numDatas = this._numParticles;
			
			if (this.customFunction != null)
			{
				customFunction(this._particles, this._numParticles);
			}
			
			if (sortFlag && this.sortFunction != null)
			{
				this._particles.sort(this.sortFunction);
			}
			
			super.advanceTime(time);
		}
		
		protected function updateEmissionRate():void
		{
			if (this._useAnimationLifeSpan)
			{
				var lifeSpan:Number = 0.0;
				var timingsCount:int = this._frameTimings.length;
				for (var i:int = 0; i < timingsCount; i++)
				{
					lifeSpan += this._frameTimings[i][this._frameTimings[i].length - 1] / this._frameDelta;
				}
				lifeSpan /= timingsCount;
				this._emissionRate = this._maxNumParticles * this._emissionRatio / lifeSpan;
			}
			else
			{
				this._emissionRate = this._maxNumParticles * this._emissionRatio / this._lifeSpan;
			}
		}
		
		public function start(duration:Number = 0):void
		{
			if (this._completed)
			{
				reset();
			}
			
			if (this._emissionRate != 0 && !this._completed)
			{
				if (this._isParticlePoolUpdatePending)
				{
					getParticlesFromPool();
				}
				
				if (duration == 0.0)
				{
					duration = this._emissionTimePredefined;
				}
				else if (duration < 0.0)
				{
					duration = Number.MAX_VALUE;
				}
				this._isPlaying = true;
				this._emissionTime = duration;
				this._frameTime = 0.0;
				this._oscillationGlobalStep = 0.0;
				this._oscillationPositionGroupStep = 0.0;
				this._oscillationPosition2GroupStep = 0.0;
				this._oscillationRotationGroupStep = 0.0;
				this._oscillationScaleXGroupStep = 0.0;
				this._oscillationScaleYGroupStep = 0.0;
				this._oscillationColorGroupStep = 0.0;
			}
		}
		
		public function stop(clear:Boolean = false):void
		{
			this._emissionTime = 0.0;
			
			if (clear)
			{
				for (var i:int = 0; i < this._numParticles; i++)
				{
					this._particles[i].visible = false;
				}
				this._numParticles = 0;
				this._isPlaying = false;
				dispatchEventWith(Event.CANCEL);
			}
		}
		
		public function resume():void
		{
			this._isPlaying = true;
		}
		
		public function reset():void
		{
			if (this._autoSetEmissionRate) 
			{
				updateEmissionRate();
			}
			this._frameTime = 0.0;
			this._isPlaying = false;
			
			this._completed = false;
			if (this._particles.length == 0)
			{
				getParticlesFromPool();
			}
		}
		
		protected function complete():void
		{
			if (!this._completed)
			{
				this._completed = true;
				dispatchEventWith(Event.COMPLETE);
			}
		}
		
		protected function getParticlesFromPool():void
		{
			if (this._particles.length != 0)
			{
				return;
			}
			
			if (this.particlesFromPoolFunction != null)
			{
				particlesFromPoolFunction(this._maxNumParticles, this._particles);
			}
			else
			{
				throw new Error("ParticleSystem.getParticlesFromPool ::: null particlesFromPoolFunction");
			}
			
			var i:int;
			if (this._useMultipleFrameSets)
			{
				var num:Number;
				var r:int;
				for (i = 0; i < this._maxNumParticles; i++)
				{
					num = MathUtils.random() * this._numFrameSets;
					r = MathUtils.floor(num);
					this._particles[i].setFrames(this._frames[r], this._frameTimings[r], this._loopAnimation, this._animationLoops);
					this._datas[i] = this._particles[i];
				}
			}
			else
			{
				for (i = 0; i < this._maxNumParticles; i++)
				{
					this._particles[i].setFrames(this._frames[0], this._frameTimings[0], this._loopAnimation, this._animationLoops);
					this._datas[i] = this._particles[i];
				}
			}
			
			this._isParticlePoolUpdatePending = false;
		}
		
		protected function returnParticlesToPool():void
		{
			this._numParticles = this.numDatas = 0;
			
			if (this._particles != null)
			{
				if (this.particlesToPoolFunction != null)
				{
					this.particlesToPoolFunction(this._particles);
				}
				else
				{
					var count:int = this._particles.length;
					for (var i:int = 0; i < count; i++)
					{
						this._particles[i].pool();
					}
				}
				this._particles.length = this._datas.length = 0;
			}
		}
		
		public function readSystemOptions(options:ParticleSystemOptions):void
		{
			// Emitter
			this.emitterType = options.emitterType;
			
			this._maxNumParticles = options.maxNumParticles;
			
			this.particleAmount = options.particleAmount;
			
			this._autoSetEmissionRate = options.autoSetEmissionRate;
			this._emissionRate = options.emissionRate;
			this._emissionRatio = options.emissionRatio;
			
			this.emitterX = options.emitterX;
			this.emitterY = options.emitterY;
			this.emitterXVariance = options.emitterXVariance;
			this.emitterYVariance = options.emitterYVariance;
			
			this.emitterRadiusMax = options.emitterRadiusMax;
			this.emitterRadiusMaxVariance = options.emitterRadiusMaxVariance;
			this.emitterRadiusMin = options.emitterRadiusMin;
			this.emitterRadiusMinVariance = options.emitterRadiusMinVariance;
			
			this.emitAngle = options.emitAngle;
			this.emitAngleVariance = options.emitAngleVariance;
			this.emitAngleAlignedRotation = options.emitAngleAlignedRotation;
			
			this._emissionTimePredefined = options.duration;
			this._emissionTimePredefined = this._emissionTimePredefined < 0 ? Number.MAX_VALUE : this._emissionTimePredefined;
			
			this.useDisplayRect = options.useDisplayRect;
			this.displayRect.copyFrom(options.displayRect);
			//\Emitter
			
			// Particle
			this.useAnimationLifeSpan = options.useAnimationLifeSpan;
			this._lifeSpan = options.lifeSpan;
			this.lifeSpanVariance = options.lifeSpanVariance;
			
			this.fadeInTime = options.fadeInTime;
			this.fadeOutTime = options.fadeOutTime;
			
			this.sizeXStart = options.sizeXStart;
			this.sizeYStart = options.sizeYStart;
			this.sizeXStartVariance = options.sizeXStartVariance;
			this.sizeYStartVariance = options.sizeYStartVariance;
			
			this.sizeXEnd = options.sizeXEnd;
			this.sizeYEnd = options.sizeYEnd;
			this.sizeXEndVariance = options.sizeXEndVariance;
			this.sizeYEndVariance = options.sizeYEndVariance;
			
			this.rotationStart = options.rotationStart;
			this.rotationStartVariance = options.rotationStartVariance;
			this.rotationEnd = options.rotationEnd;
			this.rotationEndVariance = options.rotationEndVariance;
			this.rotationEndRelativeToStart = options.rotationEndRelativeToStart;
			//\Particle
			
			// Velocity
			this.velocityXInheritRatio = options.velocityXInheritRatio;
			this.velocityXInheritRatioVariance = options.velocityXInheritRatioVariance;
			this.velocityYInheritRatio = options.velocityYInheritRatio;
			this.velocityYInheritRatioVariance = options.velocityYInheritRatioVariance;
			
			this.velocityScaleFactorX = options.velocityScaleFactorX;
			this.velocityScaleFactorY = options.velocityScaleFactorY;
			
			this.linkRotationToVelocity = options.linkRotationToVelocity;
			this.velocityRotationOffset = options.velocityRotationOffset;
			//\Velocity
			
			// Animation
			this.textureAnimation = options.textureAnimation;
			this.frameDelta = options.frameDelta;
			this.frameDeltaVariance = options.frameDeltaVariance;
			this.loopAnimation = options.loopAnimation;
			this.animationLoops = options.animationLoops;
			this.randomStartFrame = options.randomStartFrame;
			//\Animation
			
			// Gravity
			this.speed = options.speed;
			this.speedVariance = options.speedVariance;
			this.adjustLifeSpanToSpeed = options.adjustLifeSpanToSpeed;
			
			this.gravityX = options.gravityX;
			this.gravityY = options.gravityY;
			
			this.radialAcceleration = options.radialAcceleration;
			this.radialAccelerationVariance = options.radialAccelerationVariance;
			
			this.tangentialAcceleration = options.tangentialAcceleration;
			this.tangentialAccelerationVariance = options.tangentialAccelerationVariance;
			
			this.drag = options.drag;
			this.dragVariance = options.dragVariance;
			
			this.repellentForce = options.repellentForce;
			//\Gravity
			
			// Radial
			this.radiusMax = options.radiusMax;
			this.radiusMaxVariance = options.radiusMaxVariance;
			
			this.radiusMin = options.radiusMin;
			this.radiusMinVariance = options.radiusMinVariance;
			
			this.rotatePerSecond = options.rotatePerSecond;
			this.rotatePerSecondVariance = options.rotatePerSecondVariance;
			//\Radial
			
			// Color
			this.colorStart.copyFrom(options.colorStart);
			this.colorStartVariance.copyFrom(options.colorStartVariance);
			this.colorEnd.copyFrom(options.colorEnd);
			this.colorEndVariance.copyFrom(options.colorEndVariance);
			this.colorEndRelativeToStart = options.colorEndRelativeToStart;
			this.colorEndIsMultiplier = options.colorEndIsMultiplier;
			//\Color
			
			// Oscillation
			this.oscillationGlobalFrequency = options.oscillationGlobalFrequency;
			this.oscillationUnifiedFrequencyVariance = options.oscillationUnifiedFrequencyVariance;
			
			this.oscillationPositionFrequencyMode = options.oscillationPositionFrequencyMode;
			this.oscillationPositionAngle = options.oscillationPositionAngle;
			this.oscillationPositionAngleVariance = options.oscillationPositionAngleVariance;
			this.oscillationPositionAngleRelativeTo = options.oscillationPositionAngleRelativeTo;
			this.oscillationPositionRadius = options.oscillationPositionRadius;
			this.oscillationPositionRadiusVariance = options.oscillationPositionRadiusVariance;
			this.oscillationPositionFrequency = options.oscillationPositionFrequency;
			this.oscillationPositionUnifiedFrequencyVariance = options.oscillationPositionUnifiedFrequencyVariance;
			this.oscillationPositionFrequencyVariance = options.oscillationPositionFrequencyVariance;
			this.oscillationPositionFrequencyInverted = options.oscillationPositionFrequencyInverted;
			this.oscillationPositionFrequencyStart = options.oscillationPositionFrequencyStart;
			
			this.oscillationPosition2FrequencyMode = options.oscillationPosition2FrequencyMode;
			this.oscillationPosition2Angle = options.oscillationPosition2Angle;
			this.oscillationPosition2AngleVariance = options.oscillationPosition2AngleVariance;
			this.oscillationPosition2AngleRelativeTo = options.oscillationPosition2AngleRelativeTo;
			this.oscillationPosition2Radius = options.oscillationPosition2Radius;
			this.oscillationPosition2RadiusVariance = options.oscillationPosition2RadiusVariance;
			this.oscillationPosition2Frequency = options.oscillationPosition2Frequency;
			this.oscillationPosition2UnifiedFrequencyVariance = options.oscillationPosition2UnifiedFrequencyVariance;
			this.oscillationPosition2FrequencyVariance = options.oscillationPosition2FrequencyVariance;
			this.oscillationPosition2FrequencyInverted = options.oscillationPosition2FrequencyInverted;
			this.oscillationPosition2FrequencyStart = options.oscillationPosition2FrequencyStart;
			
			this.oscillationRotationFrequencyMode = options.oscillationRotationFrequencyMode;
			this.oscillationRotationAngle = options.oscillationRotationAngle;
			this.oscillationRotationAngleVariance = options.oscillationRotationAngleVariance;
			this.oscillationRotationFrequency = options.oscillationRotationFrequency;
			this.oscillationRotationUnifiedFrequencyVariance = options.oscillationRotationUnifiedFrequencyVariance;
			this.oscillationRotationFrequencyVariance = options.oscillationRotationFrequencyVariance;
			this.oscillationRotationFrequencyInverted = options.oscillationRotationFrequencyInverted;
			this.oscillationRotationFrequencyStart = options.oscillationRotationFrequencyStart;
			
			this.oscillationScaleXFrequencyMode = options.oscillationScaleXFrequencyMode;
			this.oscillationScaleX = options.oscillationScaleX;
			this.oscillationScaleXVariance = options.oscillationScaleXVariance;
			this.oscillationScaleXFrequency = options.oscillationScaleXFrequency;
			this.oscillationScaleXUnifiedFrequencyVariance = options.oscillationScaleXUnifiedFrequencyVariance;
			this.oscillationScaleXFrequencyVariance = options.oscillationScaleXFrequencyVariance;
			this.oscillationScaleXFrequencyInverted = options.oscillationScaleXFrequencyInverted;
			this.oscillationScaleXFrequencyStart = options.oscillationScaleXFrequencyStart;
			
			this.oscillationScaleYFrequencyMode = options.oscillationScaleYFrequencyMode;
			this.oscillationScaleY = options.oscillationScaleY;
			this.oscillationScaleYVariance = options.oscillationScaleYVariance;
			this.oscillationScaleYFrequency = options.oscillationScaleYFrequency;
			this.oscillationScaleYUnifiedFrequencyVariance = options.oscillationScaleYUnifiedFrequencyVariance;
			this.oscillationScaleYFrequencyVariance = options.oscillationScaleYFrequencyVariance;
			this.oscillationScaleYFrequencyInverted = options.oscillationScaleYFrequencyInverted;
			this.oscillationScaleYFrequencyStart = options.oscillationScaleYFrequencyStart;
			
			this.oscillationColorFrequencyMode = options.oscillationColorFrequencyMode;
			this.oscillationColorRed = options.oscillationColorRed;
			this.oscillationColorGreen = options.oscillationColorGreen;
			this.oscillationColorBlue = options.oscillationColorBlue;
			this.oscillationColorAlpha = options.oscillationColorAlpha;
			this.oscillationColorRedVariance = options.oscillationColorRedVariance;
			this.oscillationColorGreenVariance = options.oscillationColorGreenVariance;
			this.oscillationColorBlueVariance = options.oscillationColorBlueVariance;
			this.oscillationColorAlphaVariance = options.oscillationColorAlphaVariance;
			this.oscillationColorFrequency = options.oscillationColorFrequency;
			this.oscillationColorUnifiedFrequencyVariance = options.oscillationColorUnifiedFrequencyVariance;
			this.oscillationColorFrequencyVariance = options.oscillationColorFrequencyVariance;
			this.oscillationColorFrequencyInverted = options.oscillationColorFrequencyInverted;
			this.oscillationColorFrequencyStart = options.oscillationColorFrequencyStart;
			//\Oscillation
			
			if (this._autoSetEmissionRate)
			{
				updateEmissionRate();
			}
			returnParticlesToPool();
			if (this.particlesFromPoolFunction != null && this._frames.length != 0)
			{
				getParticlesFromPool();
			}
			else
			{
				this._isParticlePoolUpdatePending = true;
			}
		}
		
		public function writeSystemOptions(options:ParticleSystemOptions = null):ParticleSystemOptions
		{
			if (options == null) options = ParticleSystemOptions.fromPool();
			
			// Emitter
			options.emitterType = this.emitterType;
			
			options.maxNumParticles = this._maxNumParticles;
			
			options.particleAmount = this.particleAmount;
			
			options.autoSetEmissionRate = this._autoSetEmissionRate;
			options.emissionRate = this._emissionRate;
			options.emissionRatio = this._emissionRatio;
			
			options.emitterX = this.emitterX;
			options.emitterY = this.emitterY;
			options.emitterXVariance = this.emitterXVariance;
			options.emitterYVariance = this.emitterYVariance;
			
			options.emitterRadiusMax = this.emitterRadiusMax;
			options.emitterRadiusMaxVariance = this.emitterRadiusMaxVariance;
			options.emitterRadiusMin = this.emitterRadiusMin;
			options.emitterRadiusMinVariance = this.emitterRadiusMinVariance;
			
			options.emitAngle = this.emitAngle;
			options.emitAngleVariance = this.emitAngleVariance;
			options.emitAngleAlignedRotation = this.emitAngleAlignedRotation;
			
			options.duration = this._emissionTimePredefined == Number.MAX_VALUE ? -1 : this._emissionTimePredefined;
			
			options.useDisplayRect = this.useDisplayRect;
			options.displayRect.copyFrom(this.displayRect);
			//\Emitter
			
			// Particle
			options.useAnimationLifeSpan = this._useAnimationLifeSpan;
			options.lifeSpan = this._lifeSpan;
			options.lifeSpanVariance = this.lifeSpanVariance;
			
			options.fadeInTime = this._fadeInTime;
			options.fadeOutTime = this._fadeOutTime;
			
			options.sizeXStart = this.sizeXStart;
			options.sizeYStart = this.sizeYStart;
			options.sizeXStartVariance = this.sizeXStartVariance;
			options.sizeYStartVariance = this.sizeYStartVariance;
			
			options.sizeXEnd = this.sizeXEnd;
			options.sizeYEnd = this.sizeYEnd;
			options.sizeXEndVariance = this.sizeXEndVariance;
			options.sizeYEndVariance = this.sizeYEndVariance;
			
			options.rotationStart = this.rotationStart;
			options.rotationStartVariance = this.rotationStartVariance;
			options.rotationEnd = this.rotationEnd;
			options.rotationEndVariance = this.rotationEndVariance;
			options.rotationEndRelativeToStart = this.rotationEndRelativeToStart;
			//\Particle
			
			// Velocity
			options.velocityXInheritRatio = this.velocityXInheritRatio;
			options.velocityXInheritRatioVariance = this.velocityXInheritRatioVariance;
			options.velocityYInheritRatio = this.velocityYInheritRatio;
			options.velocityYInheritRatioVariance = this.velocityYInheritRatioVariance;
			
			options.velocityScaleFactorX = this._velocityScaleFactorX;
			options.velocityScaleFactorY = this._velocityScaleFactorY;
			
			options.linkRotationToVelocity = this.linkRotationToVelocity;
			options.velocityRotationOffset = this.velocityRotationOffset;
			//\Velocity
			
			// Animation
			options.textureAnimation = this.textureAnimation;
			options.frameDelta = this._frameDelta;
			options.frameDeltaVariance = this.frameDeltaVariance;
			options.loopAnimation = this._loopAnimation;
			options.animationLoops = this._animationLoops;
			options.randomStartFrame = this.randomStartFrame;
			//\Animation
			
			// Gravity
			options.speed = this.speed;
			options.speedVariance = this.speedVariance;
			
			options.adjustLifeSpanToSpeed = this.adjustLifeSpanToSpeed;
			
			options.gravityX = this.gravityX;
			options.gravityY = this.gravityY;
			
			options.radialAcceleration = this.radialAcceleration;
			options.radialAccelerationVariance = this.radialAccelerationVariance;
			
			options.tangentialAcceleration = this.tangentialAcceleration;
			options.tangentialAccelerationVariance = this.tangentialAccelerationVariance;
			
			options.drag = this._drag;
			
			options.repellentForce = this._repellentForce;
			//\Gravity
			
			// Radial
			options.radiusMax = this.radiusMax;
			options.radiusMaxVariance = this.radiusMaxVariance;
			
			options.radiusMin = this.radiusMin;
			options.radiusMinVariance = this.radiusMinVariance;
			
			options.rotatePerSecond = this.rotatePerSecond;
			options.rotatePerSecondVariance = this.rotatePerSecondVariance;
			//\Radial
			
			// Color
			options.colorStart.copyFrom(this.colorStart);
			options.colorStartVariance.copyFrom(this.colorStartVariance);
			options.colorEnd.copyFrom(this.colorEnd);
			options.colorEndVariance.copyFrom(this.colorEndVariance);
			options.colorEndRelativeToStart = this.colorEndRelativeToStart;
			options.colorEndIsMultiplier = this.colorEndIsMultiplier;
			//\Color
			
			// Oscillation
			options.oscillationGlobalFrequency = this.oscillationGlobalFrequency;
			options.oscillationUnifiedFrequencyVariance = this.oscillationUnifiedFrequencyVariance;
			
			options.oscillationPositionFrequencyMode = this._oscillationPositionFrequencyMode;
			options.oscillationPositionAngle = this.oscillationPositionAngle;
			options.oscillationPositionAngleVariance = this.oscillationPositionAngleVariance;
			options.oscillationPositionAngleRelativeTo = this._oscillationPositionAngleRelativeTo;
			options.oscillationPositionRadius = this._oscillationPositionRadius;
			options.oscillationPositionRadiusVariance = this._oscillationPositionRadiusVariance;
			options.oscillationPositionFrequency = this.oscillationPositionFrequency;
			options.oscillationPositionUnifiedFrequencyVariance = this._oscillationPositionUnifiedFrequencyVariance;
			options.oscillationPositionFrequencyVariance = this.oscillationPositionFrequencyVariance;
			options.oscillationPositionFrequencyInverted = this.oscillationPositionFrequencyInverted;
			options.oscillationPositionFrequencyStart = this._oscillationPositionFrequencyStart;
			
			options.oscillationPosition2FrequencyMode = this._oscillationPosition2FrequencyMode;
			options.oscillationPosition2Angle = this.oscillationPosition2Angle;
			options.oscillationPosition2AngleVariance = this.oscillationPosition2AngleVariance;
			options.oscillationPosition2AngleRelativeTo = this.oscillationPosition2AngleRelativeTo;
			options.oscillationPosition2Radius = this._oscillationPosition2Radius;
			options.oscillationPosition2RadiusVariance = this._oscillationPosition2RadiusVariance;
			options.oscillationPosition2Frequency = this.oscillationPosition2Frequency;
			options.oscillationPosition2UnifiedFrequencyVariance = this._oscillationPosition2UnifiedFrequencyVariance;
			options.oscillationPosition2FrequencyVariance = this.oscillationPosition2FrequencyVariance;
			options.oscillationPosition2FrequencyInverted = this.oscillationPosition2FrequencyInverted;
			options.oscillationPosition2FrequencyStart = this._oscillationPosition2FrequencyStart;
			
			options.oscillationRotationFrequencyMode = this._oscillationRotationFrequencyMode;
			options.oscillationRotationAngle = this._oscillationRotationAngle;
			options.oscillationRotationAngleVariance = this._oscillationRotationAngleVariance;
			options.oscillationRotationFrequency = this.oscillationRotationFrequency;
			options.oscillationRotationUnifiedFrequencyVariance = this._oscillationRotationUnifiedFrequencyVariance;
			options.oscillationRotationFrequencyVariance = this.oscillationRotationFrequencyVariance;
			options.oscillationRotationFrequencyInverted = this.oscillationRotationFrequencyInverted;
			options.oscillationRotationFrequencyStart = this._oscillationRotationFrequencyStart;
			
			options.oscillationScaleXFrequencyMode = this._oscillationScaleXFrequencyMode;
			options.oscillationScaleX = this.oscillationScaleX;
			options.oscillationScaleXVariance = this.oscillationScaleXVariance;
			options.oscillationScaleXFrequency = this.oscillationScaleXFrequency;
			options.oscillationScaleXUnifiedFrequencyVariance = this._oscillationScaleXUnifiedFrequencyVariance;
			options.oscillationScaleXFrequencyVariance = this.oscillationScaleXFrequencyVariance;
			options.oscillationScaleXFrequencyInverted = this.oscillationScaleXFrequencyInverted;
			options.oscillationScaleXFrequencyStart = this._oscillationScaleXFrequencyStart;
			
			options.oscillationScaleYFrequencyMode = this._oscillationScaleYFrequencyMode;
			options.oscillationScaleY = this.oscillationScaleY;
			options.oscillationScaleYVariance = this.oscillationScaleYVariance;
			options.oscillationScaleYFrequency = this.oscillationScaleYFrequency;
			options.oscillationScaleYUnifiedFrequencyVariance = this._oscillationScaleYUnifiedFrequencyVariance;
			options.oscillationScaleYFrequencyVariance = this.oscillationScaleYFrequencyVariance;
			options.oscillationScaleYFrequencyInverted = this.oscillationScaleYFrequencyInverted;
			options.oscillationScaleYFrequencyStart = this._oscillationScaleYFrequencyStart;
			
			options.oscillationColorFrequencyMode = this._oscillationColorFrequencyMode;
			options.oscillationColorRed = this._oscillationColorRed;
			options.oscillationColorGreen = this._oscillationColorGreen;
			options.oscillationColorBlue = this._oscillationColorBlue;
			options.oscillationColorAlpha = this._oscillationColorAlpha;
			options.oscillationColorRedVariance = this._oscillationColorRedVariance;
			options.oscillationColorGreenVariance = this._oscillationColorGreenVariance;
			options.oscillationColorBlueVariance = this._oscillationColorBlueVariance;
			options.oscillationColorAlphaVariance = this._oscillationColorAlphaVariance;
			options.oscillationColorFrequency = this.oscillationColorFrequency;
			options.oscillationColorUnifiedFrequencyVariance = this._oscillationColorUnifiedFrequencyVariance;
			options.oscillationColorFrequencyVariance = this.oscillationColorFrequencyVariance;
			options.oscillationColorFrequencyInverted = this.oscillationColorFrequencyInverted;
			options.oscillationColorFrequencyStart = this._oscillationColorFrequencyStart;
			//\Oscillation
			
			return options;
		}
		
	}

}