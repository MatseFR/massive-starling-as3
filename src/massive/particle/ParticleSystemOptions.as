package massive.particle 
{
	import flash.display3D.Context3DBlendFactor;
	import flash.geom.Rectangle;
	import massive.utils.MassiveTint;
	import massive.utils.MathUtils;
	
	/**
	 * ...
	 * @author Matse
	 */
	public class ParticleSystemOptions
	{
		static private var _POOL:Vector.<ParticleSystemOptions> = new Vector.<ParticleSystemOptions>();
		
		static public function fromPool():ParticleSystemOptions
		{
			if (_POOL.length != 0) return _POOL.pop();
			return new ParticleSystemOptions();
		}
		
		//##################################################
		// EMITTER
		//##################################################
		/**
		 * Possible values :
		 * - 0 for gravity
		 * - 1 for radial
		 * @default	0
		 */
		public var emitterType:int = 0;
		/**
		 * Maximum number of particles used by the system
		 * @default	1000
		 */
		public var maxNumParticles:int = 1000;
		/**
		 * The amount of particles this system can create over time, 0 = infinite
		 * @default	0
		 */
		public var particleAmount:int = 0;
		/**
		 * Tells whether the particle system should automatically set its emission rate or not
		 * @default	true
		 */
		public var autoSetEmissionRate:Boolean = true;
		/**
		 * How many particles are created per second
		 * @default	100
		 */
		public var emissionRate:Number = 100;
		/**
		 * Percentage of max particles to consider when automatically setting emission rate
		 * @default	1.0
		 */
		public var emissionRatio:Number = 1.0;
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
		/**
		 * @default	0
		 */
		public var emitterRadiusMax:Number = 0;
		/**
		 * @default	0
		 */
		public var emitterRadiusMaxVariance:Number = 0;
		/**
		 * @default	0
		 */
		public var emitterRadiusMin:Number = 0;
		/**
		 * @default	0
		 */
		public var emitterRadiusMinVariance:Number = 0;
		/**
		 * @default	0
		 */
		public var emitAngle:Number = 0;
		/**
		 * @default	Math.PI
		 */
		public var emitAngleVariance:Number = Math.PI;
		/**
		 * Aligns the particles to their emit angle at birth.
		 * @see angle
		 */
		public var emitAngleAlignedRotation:Boolean = false;
		/**
		 * The emission time span. Set to -1 for infinite.
		 */
		public var duration:Number = -1;
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
		/**
		 * Limits particle life to texture animation duration (including loops)
		 * @default	false
		 */
		public var useAnimationLifeSpan:Boolean = false;
		/**
		 * @default	1
		 */
		public var lifeSpan:Number = 1;
		/**
		 * @default	0
		 */
		public var lifeSpanVariance:Number = 0;
		/**
		 * if > 0 the particle alpha will be interpolated from 0 to starting alpha
		 * @default	0
		 */
		public var fadeInTime:Number = 0.0;
		/**
		 * if > 0 the particle alpha will be interpolated from current value to end alpha
		 * @default	0
		 */
		public var fadeOutTime:Number = 0.0;
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
		/**
		 * @default	0
		 */
		public var velocityXInheritRatio:Number = 0;
		/**
		 * @default	0
		 */
		public var velocityXInheritRatioVariance:Number = 0;
		/**
		 * @default	0
		 */
		public var velocityYInheritRatio:Number = 0;
		/**
		 * @default	0
		 */
		public var velocityYInheritRatioVariance:Number = 0;
		/**
		 * @default	0
		 */
		public var velocityScaleFactorX:Number = 0.0;
		/**
		 * @default	0
		 */
		public var velocityScaleFactorY:Number = 0.0;
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
		/**
		 * Tells whether textures should be animated or not
		 */
		public var textureAnimation:Boolean = true;
		/**
		 * texture animation play speed ratio
		 * @default	1
		 */
		public var frameDelta:Number = 1.0;
		/**
		 * texture animation play speed ratio variance
		 * @default	0
		 */
		public var frameDeltaVariance:Number = 0.0;
		/**
		 * Tells whether texture animation should loop or not.
		 * @default	false
		 */
		public var loopAnimation:Boolean = true;
		/**
		 * Number of loops if textureAnimation is on, 0 = infinite
		 * @default	0
		 */
		public var animationLoops:uint = 0;
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
		 * @default	20
		 */
		public var speedVariance:Number = 20;
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
		/**
		 * @default	0
		 */
		public var drag:Number = 0.0;
		/**
		 * @default	0
		 */
		public var dragVariance:Number = 0.0;
		/**
		 * @default	0
		 */
		public var repellentForce:Number = 0.0;
		//##################################################
		//\GRAVITY
		//##################################################
		
		//##################################################
		// RADIAL
		//##################################################
		/**
		 * @default	300
		 */
		public var radiusMax:Number = 300;
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
		/**
		 * @default	1
		 */
		public var oscillationGlobalFrequency:Number = 1.0;
		/**
		 * @default	0
		 */
		public var oscillationUnifiedFrequencyVariance:Number = 0.0;
		
		// Position
		/**
		 * see OscillationFrequencyMode for possible values
		 * @default	OscillationFrequencyMode.SINGLE
		 */
		public var oscillationPositionFrequencyMode:String = OscillationFrequencyMode.SINGLE;
		/**
		 * @default	0
		 */
		public var oscillationPositionAngle:Number = 0.0;
		/**
		 * @default	0
		 */
		public var oscillationPositionAngleVariance:Number = 0.0;
		/**
		 * see AngleRelativeTo for possible values
		 * @default	AngleRelativeTo.ROTATION
		 */
		public var oscillationPositionAngleRelativeTo:String = AngleRelativeTo.ROTATION;
		/**
		 * @default	0
		 */
		public var oscillationPositionRadius:Number = 0.0;
		/**
		 * @default	0
		 */
		public var oscillationPositionRadiusVariance:Number = 0.0;
		/**
		 * @default	1
		 */
		public var oscillationPositionFrequency:Number = 1.0;
		/**
		 * @default	false
		 */
		public var oscillationPositionUnifiedFrequencyVariance:Boolean = false;
		/**
		 * @default	0
		 */
		public var oscillationPositionFrequencyVariance:Number = 0.0;
		/**
		 * @default	false
		 */
		public var oscillationPositionFrequencyInverted:Boolean = false;
		/**
		 * see OscillationFrequencyStart for possible values
		 * @default	OscillationFrequencyStart.ZERO
		 */
		public var oscillationPositionFrequencyStart:String = OscillationFrequencyStart.ZERO;
		
		// Position2
		/**
		 * see OscillationFrequencyMode for possible values
		 * @default	OscillationFrequencyMode.SINGLE
		 */
		public var oscillationPosition2FrequencyMode:String = OscillationFrequencyMode.SINGLE;
		/**
		 * @default	0
		 */
		public var oscillationPosition2Angle:Number = 0.0;
		/**
		 * @default	0
		 */
		public var oscillationPosition2AngleVariance:Number = 0.0;
		/**
		 * see AngleRelativeTo for possible values
		 * @default	AngleRelativeTo.ROTATION
		 */
		public var oscillationPosition2AngleRelativeTo:String = AngleRelativeTo.ROTATION;
		/**
		 * @default	0
		 */
		public var oscillationPosition2Radius:Number = 0.0;
		/**
		 * @default	0
		 */
		public var oscillationPosition2RadiusVariance:Number = 0.0;
		/**
		 * @default	1
		 */
		public var oscillationPosition2Frequency:Number = 1.0;
		/**
		 * @default	false
		 */
		public var oscillationPosition2UnifiedFrequencyVariance:Boolean = false;
		/**
		 * @default	0
		 */
		public var oscillationPosition2FrequencyVariance:Number = 0.0;
		/**
		 * @default	false
		 */
		public var oscillationPosition2FrequencyInverted:Boolean = false;
		/**
		 * see OscillationFrequencyStart for possible values
		 * @default	OscillationFrequencyStart.ZERO
		 */
		public var oscillationPosition2FrequencyStart:String = OscillationFrequencyStart.ZERO;
		
		// Rotation
		/**
		 * see OscillationFrequencyMode for possible values
		 * @default	OscillationFrequencyMode.SINGLE
		 */
		public var oscillationRotationFrequencyMode:String = OscillationFrequencyMode.SINGLE;
		/**
		 * @default	0
		 */
		public var oscillationRotationAngle:Number = 0.0;
		/**
		 * @default	0
		 */
		public var oscillationRotationAngleVariance:Number = 0.0;
		/**
		 * @default	1
		 */
		public var oscillationRotationFrequency:Number = 1.0;
		/**
		 * @default	false
		 */
		public var oscillationRotationUnifiedFrequencyVariance:Boolean = false;
		/**
		   @default 0
		**/
		public var oscillationRotationFrequencyVariance:Number = 0.0;
		/**
		 * @default	false
		 */
		public var oscillationRotationFrequencyInverted:Boolean = false;
		/**
		 * see OscillationFrequencyStart for possible values
		 * @default	OscillationFrequencyStart.ZERO
		 */
		public var oscillationRotationFrequencyStart:String = OscillationFrequencyStart.ZERO;
		
		// ScaleX
		/**
		 * see OscillationFrequencyMode for possible values
		 * @default	OscillationFrequencyMode.SINGLE
		 */
		public var oscillationScaleXFrequencyMode:String = OscillationFrequencyMode.SINGLE;
		/**
		 * @default	0
		 */
		public var oscillationScaleX:Number = 0.0;
		/**
		 * @default	0
		 */
		public var oscillationScaleXVariance:Number = 0.0;
		/**
		 * @default	1
		 */
		public var oscillationScaleXFrequency:Number = 1.0;
		/**
		 * @default	false
		 */
		public var oscillationScaleXUnifiedFrequencyVariance:Boolean = false;
		/**
		 * @default	0
		 */
		public var oscillationScaleXFrequencyVariance:Number = 0.0;
		/**
		 * @default	false
		 */
		public var oscillationScaleXFrequencyInverted:Boolean = false;
		/**
		 * see OscillationFrequencyStart for possible values
		 * @default	OscillationFrequencyStart.ZERO
		 */
		public var oscillationScaleXFrequencyStart:String = OscillationFrequencyStart.ZERO;
		
		// ScaleY
		/**
		 * see OscillationFrequencyMode for possible values
		 * @default	OscillationFrequencyMode.SINGLE
		 */
		public var oscillationScaleYFrequencyMode:String = OscillationFrequencyMode.SINGLE;
		/**
		 * @default	0
		 */
		public var oscillationScaleY:Number = 0.0;
		/**
		 * @default	0
		 */
		public var oscillationScaleYVariance:Number = 0.0;
		/**
		 * @default	1
		 */
		public var oscillationScaleYFrequency:Number = 1.0;
		/**
		 * @default	false
		 */
		public var oscillationScaleYUnifiedFrequencyVariance:Boolean = false;
		/**
		 * @default	0
		 */
		public var oscillationScaleYFrequencyVariance:Number = 0.0;
		/**
		   @default	false
		**/
		public var oscillationScaleYFrequencyInverted:Boolean = false;
		/**
		 * see OscillationFrequencyStart for possible values
		 * @default	OscillationFrequencyStart.ZERO
		 */
		public var oscillationScaleYFrequencyStart:String = OscillationFrequencyStart.ZERO;
		
		// Color
		/**
		 * see OscillationFrequencyMode for possible values
		 * @default	OscillationFrequencyMode.SINGLE
		 */
		public var oscillationColorFrequencyMode:String = OscillationFrequencyMode.SINGLE;
		/**
		 * @default	0
		 */
		public var oscillationColorRed:Number = 0.0;
		/**
		 * @default	0
		 */
		public var oscillationColorGreen:Number = 0.0;
		/**
		 * @default	0
		 */
		public var oscillationColorBlue:Number = 0.0;
		/**
		 * @default	0
		 */
		public var oscillationColorAlpha:Number = 0.0;
		/**
		 * @default	0
		 */
		public var oscillationColorRedVariance:Number = 0.0;
		/**
		 * @default	0
		 */
		public var oscillationColorGreenVariance:Number = 0.0;
		/**
		 * @default	0
		 */
		public var oscillationColorBlueVariance:Number = 0.0;
		/**
		 * @default	0
		 */
		public var oscillationColorAlphaVariance:Number = 0.0;
		/**
		 * @default	1
		 */
		public var oscillationColorFrequency:Number = 1.0;
		/**
		 * @default	false
		 */
		public var oscillationColorUnifiedFrequencyVariance:Boolean = false;
		/**
		 * @default	0
		 */
		public var oscillationColorFrequencyVariance:Number = 0.0;
		/**
		 * @default	false
		 */
		public var oscillationColorFrequencyInverted:Boolean = false;
		/**
		 * see OscillationFrequencyStart for possible values
		 * @default	OscillationFrequencyStart.ZERO
		 */
		public var oscillationColorFrequencyStart:String = OscillationFrequencyStart.ZERO;
		//##################################################
		//\OSCILLATION
		//##################################################
		
		/**
		 * Vector.<Particle>->int->void
		 * @default	null
		 */
		public var customFunction:Function;
		/**
		 * Particle->Particle->void
		 * @default	null
		 */
		public var sortFunction:Function;
		public var forceSortFlag:Boolean = false;
		/**
		 * Tells whether the particle system should calculate its exact bounds or return stage dimensions
		 */
		public var exactBounds:Boolean = false;
		
		public function ParticleSystemOptions() 
		{
			
		}
		
		public function clear():void
		{
			// EMITTER
			this.emitterType = 0;
			
			this.maxNumParticles = 1000;
			
			this.particleAmount = 0;
			
			this.autoSetEmissionRate = true;
			this.emissionRate = 100.0;
			this.emissionRatio = 1.0;
			
			this.emitterX = 0;
			this.emitterY = 0;
			this.emitterXVariance = 0;
			this.emitterYVariance = 0;
			
			this.emitterRadiusMax = 0;
			this.emitterRadiusMaxVariance = 0;
			this.emitterRadiusMin = 0;
			this.emitterRadiusMinVariance = 0;
			
			this.emitAngle = 0;
			this.emitAngleVariance = Math.PI;
			
			this.emitAngleAlignedRotation = false;
			
			this.duration = -1;
			
			this.useDisplayRect = false;
			this.displayRect.setEmpty();
			//\EMITTER
			
			// PARTICLE
			this.useAnimationLifeSpan = false;
			this.lifeSpan = 1;
			this.lifeSpanVariance = 0;
			
			this.fadeInTime = 0.0;
			this.fadeOutTime = 0.0;
			
			this.sizeXStart = 20;
			this.sizeXStartVariance = 0;
			this.sizeYStart = 20;
			this.sizeYStartVariance = 0;
			
			this.sizeXEnd = 20;
			this.sizeXEndVariance = 0;
			this.sizeYEnd = 20;
			this.sizeYEndVariance = 0;
			
			this.rotationStart = 0;
			this.rotationStartVariance = 0;
			this.rotationEnd = 0;
			this.rotationEndVariance = 0;
			this.rotationEndRelativeToStart = false;
			//\PARTICLE
			
			// VELOCITY
			this.velocityXInheritRatio = 0;
			this.velocityXInheritRatioVariance = 0;
			this.velocityYInheritRatio = 0;
			this.velocityYInheritRatioVariance = 0;
			
			this.velocityScaleFactorX = 0.0;
			this.velocityScaleFactorY = 0.0;
			
			this.linkRotationToVelocity = false;
			this.velocityRotationOffset = 0.0;
			//\VELOCITY
			
			// ANIMATION
			this.textureAnimation = true;
			this.frameDelta = 1.0;
			this.frameDeltaVariance = 0.0;
			this.loopAnimation = false;
			this.animationLoops = 0;
			this.randomStartFrame = false;
			//\ANIMATION
			
			// GRAVITY
			this.speed = 100.0;
			this.speedVariance = 20.0;
			this.adjustLifeSpanToSpeed = false;
			
			this.gravityX = 0.0;
			this.gravityY = 0.0;
			
			this.radialAcceleration = 0.0;
			this.radialAccelerationVariance = 0.0;
			
			this.tangentialAcceleration = 0.0;
			this.tangentialAccelerationVariance = 0.0;
			
			this.drag = 0.0;
			this.dragVariance = 0.0;
			
			this.repellentForce = 0.0;
			//\GRAVITY
			
			// RADIAL
			this.radiusMax = 300.0;
			this.radiusMaxVariance = 0.0;
			
			this.radiusMin = 0.0;
			this.radiusMinVariance = 0.0;
			
			this.rotatePerSecond = 0.0;
			this.rotatePerSecondVariance = 0.0;
			//\RADIAL
			
			// COLOR
			this.colorStart.red = this.colorStart.green = this.colorStart.blue = this.colorStart.alpha = 1.0;
			this.colorStartVariance.red = this.colorStartVariance.green = this.colorStartVariance.blue = this.colorStartVariance.alpha = 0.0;
			
			this.colorEnd.red = this.colorEnd.green = this.colorEnd.blue = this.colorEnd.alpha = 1.0;
			this.colorEndVariance.red = this.colorEndVariance.green = this.colorEndVariance.blue = this.colorEndVariance.alpha = 0.0;
			
			this.colorEndRelativeToStart = false;
			this.colorEndIsMultiplier = false;
			//\COLOR
			
			// OSCILLATION
			this.oscillationGlobalFrequency = 1.0;
			this.oscillationUnifiedFrequencyVariance = 0.0;
			
			// position
			this.oscillationPositionFrequencyMode = OscillationFrequencyMode.SINGLE;
			this.oscillationPositionAngle = 0.0;
			this.oscillationPositionAngleVariance = 0.0;
			this.oscillationPositionAngleRelativeTo = AngleRelativeTo.ROTATION;
			this.oscillationPositionRadius = 0.0;
			this.oscillationPositionRadiusVariance = 0.0;
			this.oscillationPositionFrequency = 1.0;
			this.oscillationPositionUnifiedFrequencyVariance = false;
			this.oscillationPositionFrequencyVariance = 0.0;
			this.oscillationPositionFrequencyInverted = false;
			this.oscillationPositionFrequencyStart = OscillationFrequencyStart.ZERO;
			
			// position2
			this.oscillationPosition2FrequencyMode = OscillationFrequencyMode.SINGLE;
			this.oscillationPosition2Angle = 0.0;
			this.oscillationPosition2AngleVariance = 0.0;
			this.oscillationPosition2AngleRelativeTo = AngleRelativeTo.ROTATION;
			this.oscillationPosition2Radius = 0.0;
			this.oscillationPosition2RadiusVariance = 0.0;
			this.oscillationPosition2Frequency = 1.0;
			this.oscillationPosition2UnifiedFrequencyVariance = false;
			this.oscillationPosition2FrequencyVariance = 0.0;
			this.oscillationPosition2FrequencyInverted = false;
			this.oscillationPosition2FrequencyStart = OscillationFrequencyStart.ZERO;
			
			// rotation
			this.oscillationRotationFrequencyMode = OscillationFrequencyMode.SINGLE;
			this.oscillationRotationAngle = 0.0;
			this.oscillationRotationAngleVariance = 0.0;
			this.oscillationRotationFrequency = 1.0;
			this.oscillationRotationUnifiedFrequencyVariance = false;
			this.oscillationRotationFrequencyVariance = 0.0;
			this.oscillationRotationFrequencyInverted = false;
			this.oscillationRotationFrequencyStart = OscillationFrequencyStart.ZERO;
			
			// scaleX
			this.oscillationScaleXFrequencyMode = OscillationFrequencyMode.SINGLE;
			this.oscillationScaleX = 0.0;
			this.oscillationScaleXVariance = 0.0;
			this.oscillationScaleXFrequency = 1.0;
			this.oscillationScaleXUnifiedFrequencyVariance = false;
			this.oscillationScaleXFrequencyVariance = 0.0;
			this.oscillationScaleXFrequencyInverted = false;
			this.oscillationScaleXFrequencyStart = OscillationFrequencyStart.ZERO;
			
			// scaleY
			this.oscillationScaleYFrequencyMode = OscillationFrequencyMode.SINGLE;
			this.oscillationScaleY = 0.0;
			this.oscillationScaleYVariance = 0.0;
			this.oscillationScaleYFrequency = 1.0;
			this.oscillationScaleYUnifiedFrequencyVariance = false;
			this.oscillationScaleYFrequencyVariance = 0.0;
			this.oscillationScaleYFrequencyInverted = false;
			this.oscillationScaleYFrequencyStart = OscillationFrequencyStart.ZERO;
			
			// color
			this.oscillationColorFrequencyMode = OscillationFrequencyMode.SINGLE;
			this.oscillationColorRed = 0.0;
			this.oscillationColorGreen = 0.0;
			this.oscillationColorBlue = 0.0;
			this.oscillationColorAlpha = 0.0;
			this.oscillationColorRedVariance = 0.0;
			this.oscillationColorGreenVariance = 0.0;
			this.oscillationColorBlueVariance = 0.0;
			this.oscillationColorAlphaVariance = 0.0;
			this.oscillationColorFrequency = 1.0;
			this.oscillationColorUnifiedFrequencyVariance = false;
			this.oscillationColorFrequencyVariance = 0.0;
			this.oscillationColorFrequencyInverted = false;
			this.oscillationColorFrequencyStart = OscillationFrequencyStart.ZERO;
			//\OSCILLATION
			
			this.customFunction = null;
			this.sortFunction = null;
			this.forceSortFlag = false;
			
			this.exactBounds = false;
		}
		
		public function pool():void
		{
			clear();
			_POOL[_POOL.length] = this;
		}
		
		/**
		 * Returns a copy of the ParticleSystemOptions.
		 * @param	target A ParticleSystemOptions object (optionnal)
		 * @return	A new SystemOptions instance with given parameters
		 */
		public function clone(target:ParticleSystemOptions = null):ParticleSystemOptions
		{
			if (target == null) target = fromPool();
			
			// EMITTER
			target.emitterType = this.emitterType;
			
			target.maxNumParticles = this.maxNumParticles;
			
			target.particleAmount = this.particleAmount;
			
			target.autoSetEmissionRate = this.autoSetEmissionRate;
			target.emissionRate = this.emissionRate;
			target.emissionRatio = this.emissionRatio;
			
			target.emitterX = this.emitterX;
			target.emitterY = this.emitterY;
			target.emitterXVariance = this.emitterXVariance;
			target.emitterYVariance = this.emitterYVariance;
			
			target.emitterRadiusMax = this.emitterRadiusMax;
			target.emitterRadiusMaxVariance = this.emitterRadiusMaxVariance;
			target.emitterRadiusMin = this.emitterRadiusMin;
			target.emitterRadiusMinVariance = this.emitterRadiusMinVariance;
			
			target.emitAngle = this.emitAngle;
			target.emitAngleVariance = this.emitAngleVariance;
			target.emitAngleAlignedRotation = this.emitAngleAlignedRotation;
			
			target.duration = this.duration;
			
			target.useDisplayRect = this.useDisplayRect;
			target.displayRect.copyFrom(this.displayRect);
			//\EMITTER
			
			// PARTICLE
			target.useAnimationLifeSpan = this.useAnimationLifeSpan;
			target.lifeSpan = this.lifeSpan;
			target.lifeSpanVariance = this.lifeSpanVariance;
			
			target.fadeInTime = this.fadeInTime;
			target.fadeOutTime = this.fadeOutTime;
			
			target.sizeXStart = this.sizeXStart;
			target.sizeXStartVariance = this.sizeXStartVariance;
			target.sizeYStart = this.sizeYStart;
			target.sizeYStartVariance = this.sizeYStartVariance;
			
			target.sizeXEnd = this.sizeXEnd;
			target.sizeXEndVariance = this.sizeXEndVariance;
			target.sizeYEnd = this.sizeYEnd;
			target.sizeYEndVariance = this.sizeYEndVariance;
			
			target.rotationStart = this.rotationStart;
			target.rotationStartVariance = this.rotationStartVariance;
			target.rotationEnd = this.rotationEnd;
			target.rotationEndVariance = this.rotationEndVariance;
			target.rotationEndRelativeToStart = this.rotationEndRelativeToStart;
			//\PARTICLE
			
			// VELOCITY
			target.velocityXInheritRatio = this.velocityXInheritRatio;
			target.velocityXInheritRatioVariance = this.velocityXInheritRatioVariance;
			target.velocityYInheritRatio = this.velocityYInheritRatio;
			target.velocityYInheritRatioVariance = this.velocityYInheritRatioVariance;
			
			target.velocityScaleFactorX = this.velocityScaleFactorX;
			target.velocityScaleFactorY = this.velocityScaleFactorY;
			
			target.linkRotationToVelocity = this.linkRotationToVelocity;
			target.velocityRotationOffset = this.velocityRotationOffset;
			//\VELOCITY
			
			// ANIMATION
			target.textureAnimation = this.textureAnimation;
			target.frameDelta = this.frameDelta;
			target.frameDeltaVariance = this.frameDeltaVariance;
			target.loopAnimation = this.loopAnimation;
			target.animationLoops = this.animationLoops;
			target.randomStartFrame = this.randomStartFrame;
			//\ANIMATION
			
			// GRAVITY
			target.speed = this.speed;
			target.speedVariance = this.speedVariance;
			
			target.adjustLifeSpanToSpeed = this.adjustLifeSpanToSpeed;
			
			target.gravityX = this.gravityX;
			target.gravityY = this.gravityY;
			
			target.radialAcceleration = this.radialAcceleration;
			target.radialAccelerationVariance = this.radialAccelerationVariance;
			
			target.tangentialAcceleration = this.tangentialAcceleration;
			target.tangentialAccelerationVariance = this.tangentialAccelerationVariance;
			
			target.drag = this.drag;
			target.dragVariance = this.dragVariance;
			
			target.repellentForce = this.repellentForce;
			//\GRAVITY
			
			// RADIAL
			target.radiusMax = this.radiusMax;
			target.radiusMaxVariance = this.radiusMaxVariance;
			
			target.radiusMin = this.radiusMin;
			target.radiusMinVariance = this.radiusMinVariance;
			
			target.rotatePerSecond = this.rotatePerSecond;
			target.rotatePerSecondVariance = this.rotatePerSecondVariance;
			//\RADIAL
			
			// COLOR
			target.colorStart.copyFrom(this.colorStart);
			target.colorStartVariance.copyFrom(this.colorStartVariance);
			
			target.colorEnd.copyFrom(this.colorEnd);
			target.colorEndVariance.copyFrom(this.colorEndVariance);
			target.colorEndRelativeToStart = this.colorEndRelativeToStart;
			target.colorEndIsMultiplier = this.colorEndIsMultiplier;
			//\COLOR
			
			// OSCILLATION
			target.oscillationGlobalFrequency = this.oscillationGlobalFrequency;
			target.oscillationUnifiedFrequencyVariance = this.oscillationUnifiedFrequencyVariance;
			
			target.oscillationPositionFrequencyMode = this.oscillationPositionFrequencyMode;
			target.oscillationPositionAngle = this.oscillationPositionAngle;
			target.oscillationPositionAngleVariance = this.oscillationPositionAngleVariance;
			target.oscillationPositionAngleRelativeTo = this.oscillationPositionAngleRelativeTo;
			target.oscillationPositionRadius = this.oscillationPositionRadius;
			target.oscillationPositionRadiusVariance = this.oscillationPositionRadiusVariance;
			target.oscillationPositionFrequency = this.oscillationPositionFrequency;
			target.oscillationPositionUnifiedFrequencyVariance = this.oscillationPositionUnifiedFrequencyVariance;
			target.oscillationPositionFrequencyVariance = this.oscillationPositionFrequencyVariance;
			target.oscillationPositionFrequencyInverted = this.oscillationPositionFrequencyInverted;
			target.oscillationPositionFrequencyStart = this.oscillationPositionFrequencyStart;
			
			target.oscillationPosition2FrequencyMode = this.oscillationPosition2FrequencyMode;
			target.oscillationPosition2Angle = this.oscillationPosition2Angle;
			target.oscillationPosition2AngleVariance = this.oscillationPosition2AngleVariance;
			target.oscillationPosition2AngleRelativeTo = this.oscillationPosition2AngleRelativeTo;
			target.oscillationPosition2Radius = this.oscillationPosition2Radius;
			target.oscillationPosition2RadiusVariance = this.oscillationPosition2RadiusVariance;
			target.oscillationPosition2Frequency = this.oscillationPosition2Frequency;
			target.oscillationPosition2UnifiedFrequencyVariance = this.oscillationPosition2UnifiedFrequencyVariance;
			target.oscillationPosition2FrequencyVariance = this.oscillationPosition2FrequencyVariance;
			target.oscillationPosition2FrequencyInverted = this.oscillationPosition2FrequencyInverted;
			target.oscillationPosition2FrequencyStart = this.oscillationPosition2FrequencyStart;
			
			target.oscillationRotationFrequencyMode = this.oscillationRotationFrequencyMode;
			target.oscillationRotationAngle = this.oscillationRotationAngle;
			target.oscillationRotationAngleVariance = this.oscillationRotationAngleVariance;
			target.oscillationRotationFrequency = this.oscillationRotationFrequency;
			target.oscillationRotationUnifiedFrequencyVariance = this.oscillationRotationUnifiedFrequencyVariance;
			target.oscillationRotationFrequencyVariance = this.oscillationRotationFrequencyVariance;
			target.oscillationRotationFrequencyInverted = this.oscillationRotationFrequencyInverted;
			target.oscillationRotationFrequencyStart = this.oscillationRotationFrequencyStart;
			
			target.oscillationScaleXFrequencyMode = this.oscillationScaleXFrequencyMode;
			target.oscillationScaleX = this.oscillationScaleX;
			target.oscillationScaleXVariance = this.oscillationScaleXVariance;
			target.oscillationScaleXFrequency = this.oscillationScaleXFrequency;
			target.oscillationScaleXUnifiedFrequencyVariance = this.oscillationScaleXUnifiedFrequencyVariance;
			target.oscillationScaleXFrequencyVariance = this.oscillationScaleXFrequencyVariance;
			target.oscillationScaleXFrequencyInverted = this.oscillationScaleXFrequencyInverted;
			target.oscillationScaleXFrequencyStart = this.oscillationScaleXFrequencyStart;
			
			target.oscillationScaleYFrequencyMode = this.oscillationScaleYFrequencyMode;
			target.oscillationScaleY = this.oscillationScaleY;
			target.oscillationScaleYVariance = this.oscillationScaleYVariance;
			target.oscillationScaleYFrequency = this.oscillationScaleYFrequency;
			target.oscillationScaleYUnifiedFrequencyVariance = this.oscillationScaleYUnifiedFrequencyVariance;
			target.oscillationScaleYFrequencyVariance = this.oscillationScaleYFrequencyVariance;
			target.oscillationScaleYFrequencyInverted = this.oscillationScaleYFrequencyInverted;
			target.oscillationScaleYFrequencyStart = this.oscillationScaleYFrequencyStart;
			
			target.oscillationColorFrequencyMode = this.oscillationColorFrequencyMode;
			target.oscillationColorRed = this.oscillationColorRed;
			target.oscillationColorGreen = this.oscillationColorGreen;
			target.oscillationColorBlue = this.oscillationColorBlue;
			target.oscillationColorAlpha = this.oscillationColorAlpha;
			target.oscillationColorRedVariance = this.oscillationColorRedVariance;
			target.oscillationColorGreenVariance = this.oscillationColorGreenVariance;
			target.oscillationColorBlueVariance = this.oscillationColorBlueVariance;
			target.oscillationColorAlphaVariance = this.oscillationColorAlphaVariance;
			target.oscillationColorFrequency = this.oscillationColorFrequency;
			target.oscillationColorUnifiedFrequencyVariance = this.oscillationColorUnifiedFrequencyVariance;
			target.oscillationColorFrequencyVariance = this.oscillationColorFrequencyVariance;
			target.oscillationColorFrequencyInverted = this.oscillationColorFrequencyInverted;
			target.oscillationColorFrequencyStart = this.oscillationColorFrequencyStart;
			//\OSCILLATION
			
			target.exactBounds = this.exactBounds;
			
			target.customFunction = this.customFunction;
			target.sortFunction = this.sortFunction;
			target.forceSortFlag = this.forceSortFlag;
			
			return target;
		}
		
		public function fromJSON(json:Object):void
		{
			// EMITTER
			this.emitterType = json.emitterType;
			
			this.maxNumParticles = json.maxNumParticles;
			
			this.particleAmount = json.particleAmount;
			
			this.autoSetEmissionRate = json.autoSetEmissionRate;
			this.emissionRate = json.emissionRate;
			this.emissionRatio = json.emissionRatio;
			
			this.emitterX = json.emitterX;
			this.emitterY = json.emitterY;
			this.emitterXVariance = json.emitterXVariance;
			this.emitterYVariance = json.emitterYVariance;
			
			this.emitterRadiusMax = json.emitterRadiusMax;
			this.emitterRadiusMaxVariance = json.emitterRadiusMaxVariance;
			this.emitterRadiusMin = json.emitterRadiusMin;
			this.emitterRadiusMinVariance = json.emitterRadiusMinVariance;
			
			this.emitAngle = json.emitAngle;
			this.emitAngleVariance = json.emitAngleVariance;
			this.emitAngleAlignedRotation = json.emitAngleAlignedRotation;
			
			this.duration = json.duration;
			
			this.useDisplayRect = json.useDisplayRect;
			if (json.displayRect != null)
			{
				this.displayRect.setTo(json.displayRect.x, json.displayRect.y, json.displayRect.w, json.displayRect.h);
			}
			else
			{
				this.displayRect.setEmpty();
			}
			//\EMITTER
			
			// PARTICLE
			this.useAnimationLifeSpan = json.useAnimationLifeSpan;
			this.lifeSpan = json.lifeSpan;
			this.lifeSpanVariance = json.lifeSpanVariance;
			
			this.fadeInTime = json.fadeInTime;
			this.fadeOutTime = json.fadeOutTime;
			
			this.sizeXStart = json.sizeXStart;
			this.sizeXStartVariance = json.sizeXStartVariance;
			this.sizeYStart = json.sizeYStart;
			this.sizeYStartVariance = json.sizeYStartVariance;
			
			this.sizeXEnd = json.sizeXEnd;
			this.sizeXEndVariance = json.sizeXEndVariance;
			this.sizeYEnd = json.sizeYEnd;
			this.sizeYEndVariance = json.sizeYEndVariance;
			
			this.rotationStart = json.rotationStart;
			this.rotationStartVariance = json.rotationStartVariance;
			this.rotationEnd = json.rotationEnd;
			this.rotationEndVariance = json.rotationEndVariance;
			this.rotationEndRelativeToStart = json.rotationEndRelativeToStart;
			//\PARTICLE
			
			// VELOCITY
			this.velocityXInheritRatio = json.velocityXInheritRatio;
			this.velocityXInheritRatioVariance = json.velocityXInheritRatioVariance;
			this.velocityYInheritRatio = json.velocityYInheritRatio;
			this.velocityYInheritRatioVariance = json.velocityYInheritRatioVariance;
			
			this.velocityScaleFactorX = json.velocityScaleFactorX;
			this.velocityScaleFactorY = json.velocityScaleFactorY;
			
			this.linkRotationToVelocity = json.linkRotationToVelocity;
			this.velocityRotationOffset = json.velocityRotationOffset;
			//\VELOCITY
			
			// ANIMATION
			this.textureAnimation = json.textureAnimation;
			this.frameDelta = json.frameDelta;
			this.frameDeltaVariance = json.frameDeltaVariance;
			this.loopAnimation = json.loopAnimation;
			this.animationLoops = json.animationLoops;
			this.randomStartFrame = json.randomStartFrame;
			//\ANIMATION
			
			// GRAVITY
			this.speed = json.speed;
			this.speedVariance = json.speedVariance;
			
			this.adjustLifeSpanToSpeed = json.adjustLifeSpanToSpeed;
			
			this.gravityX = json.gravityX;
			this.gravityY = json.gravityY;
			
			this.radialAcceleration = json.radialAcceleration;
			this.radialAccelerationVariance = json.radialAccelerationVariance;
			
			this.tangentialAcceleration = json.tangentialAcceleration;
			this.tangentialAccelerationVariance = json.tangentialAccelerationVariance;
			
			this.drag = json.drag;
			this.dragVariance = json.dragVariance;
			
			this.repellentForce = json.repellentForce;
			//\GRAVITY
			
			// RADIAL
			this.radiusMax = json.radiusMax;
			this.radiusMaxVariance = json.radiusMaxVariance;
			
			this.radiusMin = json.radiusMin;
			this.radiusMinVariance = json.radiusMinVariance;
			
			this.rotatePerSecond = json.rotatePerSecond;
			this.rotatePerSecondVariance = json.rotatePerSecondVariance;
			//\RADIAL
			
			// COLOR
			colorFromJSON(this.colorStart, json.colorStart);
			colorFromJSON(this.colorStartVariance, json.colorStartVariance);
			colorFromJSON(this.colorEnd, json.colorEnd);
			colorFromJSON(this.colorEndVariance, json.colorEndVariance);
			this.colorEndRelativeToStart = json.colorEndRelativeToStart;
			this.colorEndIsMultiplier = json.colorEndIsMultiplier;
			//\COLOR
			
			// OSCILLATION
			this.oscillationGlobalFrequency = json.oscillationGlobalFrequency;
			this.oscillationUnifiedFrequencyVariance = json.oscillationUnifiedFrequencyVariance;
			
			// position
			this.oscillationPositionFrequencyMode = json.oscillationPositionFrequencyMode;
			this.oscillationPositionAngle = json.oscillationPositionAngle;
			this.oscillationPositionAngleVariance = json.oscillationPositionAngleVariance;
			this.oscillationPositionAngleRelativeTo = json.oscillationPositionAngleRelativeTo;
			this.oscillationPositionRadius = json.oscillationPositionRadius;
			this.oscillationPositionRadiusVariance = json.oscillationPositionRadiusVariance;
			this.oscillationPositionFrequency = json.oscillationPositionFrequency;
			this.oscillationPositionUnifiedFrequencyVariance = json.oscillationPositionUnifiedFrequencyVariance;
			this.oscillationPositionFrequencyVariance = json.oscillationPositionFrequencyVariance;
			this.oscillationPositionFrequencyInverted = json.oscillationPositionFrequencyInverted;
			this.oscillationPositionFrequencyStart = json.oscillationPositionFrequencyStart;
			
			// position2
			this.oscillationPosition2FrequencyMode = json.oscillationPosition2FrequencyMode;
			this.oscillationPosition2Angle = json.oscillationPosition2Angle;
			this.oscillationPosition2AngleVariance = json.oscillationPosition2AngleVariance;
			this.oscillationPosition2AngleRelativeTo = json.oscillationPosition2AngleRelativeTo;
			this.oscillationPosition2Radius = json.oscillationPosition2Radius;
			this.oscillationPosition2RadiusVariance = json.oscillationPosition2RadiusVariance;
			this.oscillationPosition2Frequency = json.oscillationPosition2Frequency;
			this.oscillationPosition2UnifiedFrequencyVariance = json.oscillationPosition2UnifiedFrequencyVariance;
			this.oscillationPosition2FrequencyVariance = json.oscillationPosition2FrequencyVariance;
			this.oscillationPosition2FrequencyInverted = json.oscillationPosition2FrequencyInverted;
			this.oscillationPosition2FrequencyStart = json.oscillationPosition2FrequencyStart;
			
			// rotation
			this.oscillationRotationFrequencyMode = json.oscillationRotationFrequencyMode;
			this.oscillationRotationAngle = json.oscillationRotationAngle;
			this.oscillationRotationAngleVariance = json.oscillationRotationAngleVariance;
			this.oscillationRotationFrequency = json.oscillationRotationFrequency;
			this.oscillationRotationUnifiedFrequencyVariance = json.oscillationRotationUnifiedFrequencyVariance;
			this.oscillationRotationFrequencyVariance = json.oscillationRotationFrequencyVariance;
			this.oscillationRotationFrequencyInverted = json.oscillationRotationFrequencyInverted;
			this.oscillationRotationFrequencyStart = json.oscillationRotationFrequencyStart;
			
			// scaleX
			this.oscillationScaleXFrequencyMode = json.oscillationScaleXFrequencyMode;
			this.oscillationScaleX = json.oscillationScaleX;
			this.oscillationScaleXVariance = json.oscillationScaleXVariance;
			this.oscillationScaleXFrequency = json.oscillationScaleXFrequency;
			this.oscillationScaleXUnifiedFrequencyVariance = json.oscillationScaleXUnifiedFrequencyVariance;
			this.oscillationScaleXFrequencyVariance = json.oscillationScaleXFrequencyVariance;
			this.oscillationScaleXFrequencyInverted = json.oscillationScaleXFrequencyInverted;
			this.oscillationScaleXFrequencyStart = json.oscillationScaleXFrequencyStart;
			
			// scaleY
			this.oscillationScaleYFrequencyMode = json.oscillationScaleYFrequencyMode;
			this.oscillationScaleY = json.oscillationScaleY;
			this.oscillationScaleYVariance = json.oscillationScaleYVariance;
			this.oscillationScaleYFrequency = json.oscillationScaleYFrequency;
			this.oscillationScaleYUnifiedFrequencyVariance = json.oscillationScaleYUnifiedFrequencyVariance;
			this.oscillationScaleYFrequencyVariance = json.oscillationScaleYFrequencyVariance;
			this.oscillationScaleYFrequencyInverted = json.oscillationScaleYFrequencyInverted;
			this.oscillationScaleYFrequencyStart = json.oscillationScaleYFrequencyStart;
			
			// color
			this.oscillationColorFrequencyMode = json.oscillationColorFrequencyMode;
			this.oscillationColorRed = json.oscillationColorRed;
			this.oscillationColorGreen = json.oscillationColorGreen;
			this.oscillationColorBlue = json.oscillationColorBlue;
			this.oscillationColorAlpha = json.oscillationColorAlpha;
			this.oscillationColorRedVariance = json.oscillationColorRedVariance;
			this.oscillationColorGreenVariance = json.oscillationColorGreenVariance;
			this.oscillationColorBlueVariance = json.oscillationColorBlueVariance;
			this.oscillationColorAlphaVariance = json.oscillationColorAlphaVariance;
			this.oscillationColorFrequency = json.oscillationColorFrequency;
			this.oscillationColorUnifiedFrequencyVariance = json.oscillationColorUnifiedFrequencyVariance;
			this.oscillationColorFrequencyVariance = json.oscillationColorFrequencyVariance;
			this.oscillationColorFrequencyInverted = json.oscillationColorFrequencyInverted;
			this.oscillationColorFrequencyStart = json.oscillationColorFrequencyStart;
			//\OSCILLATION
			
			this.exactBounds = json.exactBounds;
			
			this.forceSortFlag = json.forceSortFlag;
		}
		
		public function toJSON(json:Object = null):Object
		{
			if (json == null) json = {};
			
			// EMITTER
			json.emitterType = this.emitterType;
			
			json.maxNumParticles = this.maxNumParticles;
			
			json.particleAmount = this.particleAmount;
			
			json.autoSetEmissionRate = this.autoSetEmissionRate;
			json.emissionRate = this.emissionRate;
			json.emissionRatio = this.emissionRatio;
			
			json.emitterX = this.emitterX;
			json.emitterY = this.emitterY;
			json.emitterXVariance = this.emitterXVariance;
			json.emitterYVariance = this.emitterYVariance;
			
			json.emitterRadiusMax = this.emitterRadiusMax;
			json.emitterRadiusMaxVariance = this.emitterRadiusMaxVariance;
			json.emitterRadiusMin = this.emitterRadiusMin;
			json.emitterRadiusMinVariance = this.emitterRadiusMinVariance;
			
			json.emitAngle = this.emitAngle;
			json.emitAngleVariance = this.emitAngleVariance;
			json.emitAngleAlignedRotation = this.emitAngleAlignedRotation;
			
			json.duration = this.duration;
			
			json.useDisplayRect = this.useDisplayRect;
			if (!this.displayRect.isEmpty())
			{
				json.displayRect = {x:this.displayRect.x, y:this.displayRect.y, w:this.displayRect.width, h:this.displayRect.height};
			}
			//\EMITTER
			
			// PARTICLE
			json.useAnimationLifeSpan = this.useAnimationLifeSpan;
			json.lifeSpan = this.lifeSpan;
			json.lifeSpanVariance = this.lifeSpanVariance;
			
			json.fadeInTime = this.fadeInTime;
			json.fadeOutTime = this.fadeOutTime;
			
			json.sizeXStart = this.sizeXStart;
			json.sizeXStartVariance = this.sizeXStartVariance;
			json.sizeYStart = this.sizeYStart;
			json.sizeYStartVariance = this.sizeYStartVariance;
			
			json.sizeXEnd = this.sizeXEnd;
			json.sizeXEndVariance = this.sizeXEndVariance;
			json.sizeYEnd = this.sizeYEnd;
			json.sizeYEndVariance = this.sizeYEndVariance;
			
			json.rotationStart = this.rotationStart;
			json.rotationStartVariance = this.rotationStartVariance;
			json.rotationEnd = this.rotationEnd;
			json.rotationEndVariance = this.rotationEndVariance;
			json.rotationEndRelativeToStart = this.rotationEndRelativeToStart;
			//\PARTICLE
			
			// VELOCITY
			json.velocityXInheritRatio = this.velocityXInheritRatio;
			json.velocityXInheritRatioVariance = this.velocityXInheritRatioVariance;
			json.velocityYInheritRatio = this.velocityYInheritRatio;
			json.velocityYInheritRatioVariance = this.velocityYInheritRatioVariance;
			
			json.velocityScaleFactorX = this.velocityScaleFactorX;
			json.velocityScaleFactorY = this.velocityScaleFactorY;
			
			json.linkRotationToVelocity = this.linkRotationToVelocity;
			json.velocityRotationOffset = this.velocityRotationOffset;
			//\VELOCITY
			
			// ANIMATION
			json.textureAnimation = this.textureAnimation;
			json.frameDelta = this.frameDelta;
			json.frameDeltaVariance = this.frameDeltaVariance;
			json.loopAnimation = this.loopAnimation;
			json.animationLoops = this.animationLoops;
			json.randomStartFrame = this.randomStartFrame;
			//\ANIMATION
			
			// GRAVITY
			json.speed = this.speed;
			json.speedVariance = this.speedVariance;
			json.adjustLifeSpanToSpeed = this.adjustLifeSpanToSpeed;
			
			json.gravityX = this.gravityX;
			json.gravityY = this.gravityY;
			
			json.radialAcceleration = this.radialAcceleration;
			json.radialAccelerationVariance = this.radialAccelerationVariance;
			
			json.tangentialAcceleration = this.tangentialAcceleration;
			json.tangentialAccelerationVariance = this.tangentialAccelerationVariance;
			
			json.drag = this.drag;
			json.dragVariance = this.dragVariance;
			
			json.repellentForce = this.repellentForce;
			//\GRAVITY
			
			// RADIAL
			json.radiusMax = this.radiusMax;
			json.radiusMaxVariance = this.radiusMaxVariance;
			
			json.radiusMin = this.radiusMin;
			json.radiusMinVariance = this.radiusMinVariance;
			
			json.rotatePerSecond = this.rotatePerSecond;
			json.rotatePerSecondVariance = this.rotatePerSecondVariance;
			//\RADIAL
			
			// COLOR
			json.colorStart = colorToJSON(this.colorStart);
			json.colorStartVariance = colorToJSON(this.colorStartVariance);
			
			json.colorEnd = colorToJSON(this.colorEnd);
			json.colorEndVariance = colorToJSON(this.colorEndVariance);
			json.colorEndRelativeToStart = this.colorEndRelativeToStart;
			json.colorEndIsMultiplier = this.colorEndIsMultiplier;
			//\COLOR
			
			// OSCILLATION
			json.oscillationGlobalFrequency = this.oscillationGlobalFrequency;
			json.oscillationUnifiedFrequencyVariance = this.oscillationUnifiedFrequencyVariance;
			
			json.oscillationPositionFrequencyMode = this.oscillationPositionFrequencyMode;
			json.oscillationPositionAngle = this.oscillationPositionAngle;
			json.oscillationPositionAngleVariance = this.oscillationPositionAngleVariance;
			json.oscillationPositionAngleRelativeTo = this.oscillationPositionAngleRelativeTo;
			json.oscillationPositionRadius = this.oscillationPositionRadius;
			json.oscillationPositionRadiusVariance = this.oscillationPositionRadiusVariance;
			json.oscillationPositionFrequency = this.oscillationPositionFrequency;
			json.oscillationPositionUnifiedFrequencyVariance = this.oscillationPositionUnifiedFrequencyVariance;
			json.oscillationPositionFrequencyVariance = this.oscillationPositionFrequencyVariance;
			json.oscillationPositionFrequencyInverted = this.oscillationPositionFrequencyInverted;
			json.oscillationPositionFrequencyStart = this.oscillationPositionFrequencyStart;
			
			json.oscillationPosition2FrequencyMode = this.oscillationPosition2FrequencyMode;
			json.oscillationPosition2Angle = this.oscillationPosition2Angle;
			json.oscillationPosition2AngleVariance = this.oscillationPosition2AngleVariance;
			json.oscillationPosition2AngleRelativeTo = this.oscillationPosition2AngleRelativeTo;
			json.oscillationPosition2Radius = this.oscillationPosition2Radius;
			json.oscillationPosition2RadiusVariance = this.oscillationPosition2RadiusVariance;
			json.oscillationPosition2Frequency = this.oscillationPosition2Frequency;
			json.oscillationPosition2UnifiedFrequencyVariance = this.oscillationPosition2UnifiedFrequencyVariance;
			json.oscillationPosition2FrequencyVariance = this.oscillationPosition2FrequencyVariance;
			json.oscillationPosition2FrequencyInverted = this.oscillationPosition2FrequencyInverted;
			json.oscillationPosition2FrequencyStart = this.oscillationPosition2FrequencyStart;
			
			json.oscillationRotationFrequencyMode = this.oscillationRotationFrequencyMode;
			json.oscillationRotationAngle = this.oscillationRotationAngle;
			json.oscillationRotationAngleVariance = this.oscillationRotationAngleVariance;
			json.oscillationRotationFrequency = this.oscillationRotationFrequency;
			json.oscillationRotationUnifiedFrequencyVariance = this.oscillationRotationUnifiedFrequencyVariance;
			json.oscillationRotationFrequencyVariance = this.oscillationRotationFrequencyVariance;
			json.oscillationRotationFrequencyInverted = this.oscillationRotationFrequencyInverted;
			json.oscillationRotationFrequencyStart = this.oscillationRotationFrequencyStart;
			
			json.oscillationScaleXFrequencyMode = this.oscillationScaleXFrequencyMode;
			json.oscillationScaleX = this.oscillationScaleX;
			json.oscillationScaleXVariance = this.oscillationScaleXVariance;
			json.oscillationScaleXFrequency = this.oscillationScaleXFrequency;
			json.oscillationScaleXUnifiedFrequencyVariance = this.oscillationScaleXUnifiedFrequencyVariance;
			json.oscillationScaleXFrequencyVariance = this.oscillationScaleXFrequencyVariance;
			json.oscillationScaleXFrequencyInverted = this.oscillationScaleXFrequencyInverted;
			json.oscillationScaleXFrequencyStart = this.oscillationScaleXFrequencyStart;
			
			json.oscillationScaleYFrequencyMode = this.oscillationScaleYFrequencyMode;
			json.oscillationScaleY = this.oscillationScaleY;
			json.oscillationScaleYVariance = this.oscillationScaleYVariance;
			json.oscillationScaleYFrequency = this.oscillationScaleYFrequency;
			json.oscillationScaleYUnifiedFrequencyVariance = this.oscillationScaleYUnifiedFrequencyVariance;
			json.oscillationScaleYFrequencyVariance = this.oscillationScaleYFrequencyVariance;
			json.oscillationScaleYFrequencyInverted = this.oscillationScaleYFrequencyInverted;
			json.oscillationScaleYFrequencyStart = this.oscillationScaleYFrequencyStart;
			
			json.oscillationColorFrequencyMode = this.oscillationColorFrequencyMode;
			json.oscillationColorRed = this.oscillationColorRed;
			json.oscillationColorGreen = this.oscillationColorGreen;
			json.oscillationColorBlue = this.oscillationColorBlue;
			json.oscillationColorAlpha = this.oscillationColorAlpha;
			json.oscillationColorRedVariance = this.oscillationColorRedVariance;
			json.oscillationColorGreenVariance = this.oscillationColorGreenVariance;
			json.oscillationColorBlueVariance = this.oscillationColorBlueVariance;
			json.oscillationColorAlphaVariance = this.oscillationColorAlphaVariance;
			json.oscillationColorFrequency = this.oscillationColorFrequency;
			json.oscillationColorUnifiedFrequencyVariance = this.oscillationColorUnifiedFrequencyVariance;
			json.oscillationColorFrequencyVariance = this.oscillationColorFrequencyVariance;
			json.oscillationColorFrequencyInverted = this.oscillationColorFrequencyInverted;
			json.oscillationColorFrequencyStart = this.oscillationColorFrequencyStart;
			//\OSCILLATION
			
			json.exactBounds = this.exactBounds;
			
			json.forceSortFlag = this.forceSortFlag;
			
			return json;
		}
		
		public static function colorFromJSON(color:MassiveTint, json:Object):void
		{
			color.red = json.red;
			color.green = json.green;
			color.blue = json.blue;
			color.alpha = json.alpha;
		}
		
		public static function colorToJSON(color:MassiveTint, json:Object = null):Object
		{
			if (json == null) json = {};
			
			json.red = color.red;
			json.green = color.green;
			json.blue = color.blue;
			json.alpha = color.alpha;
			
			return json;
		}
		
		public function fromXml(config:XML):void
		{
			var DEG2RAD:Number = 1 / 180 * Math.PI;
			
			this.emitterX = parseFloat(config.sourcePosition.attribute("x"));
			this.emitterY = parseFloat(config.sourcePosition.attribute("y"));
			this.emitterXVariance = parseFloat(config.sourcePositionVariance.attribute("x"));
			this.emitterYVariance = parseFloat(config.sourcePositionVariance.attribute("y"));
			this.gravityX = parseFloat(config.gravity.attribute("x"));
			this.gravityY = parseFloat(config.gravity.attribute("y"));
			this.emitterType = getIntValue(config.emitterType);
			this.maxNumParticles = getIntValue(config.maxParticles);
			this.lifeSpan = MathUtils.max(0.01, getFloatValue(config.particleLifeSpan));
			this.lifeSpanVariance = getFloatValue(config.particleLifespanVariance);
			this.sizeXStart = this.sizeYStart = getFloatValue(config.startParticleSize);
			this.sizeXStartVariance = this.sizeYStartVariance = getFloatValue(config.startParticleSizeVariance);
			this.sizeXEnd = this.sizeYEnd = getFloatValue(config.finishParticleSize);
			this.sizeXEndVariance = this.sizeYEndVariance = getFloatValue(config.finishParticleSizeVariance);
			this.emitAngle = getFloatValue(config.angle) * DEG2RAD;
			this.emitAngleVariance = getFloatValue(config.angleVariance) * DEG2RAD;
			this.rotationStart = getFloatValue(config.rotationStart) * DEG2RAD;
			this.rotationStartVariance = getFloatValue(config.rotationStartVariance) * DEG2RAD;
			this.rotationEnd = getFloatValue(config.rotationEnd) * DEG2RAD;
			this.rotationEndVariance = getFloatValue(config.rotationEndVariance) * DEG2RAD;
			this.emitAngleAlignedRotation = getBooleanValue(config.emitAngleAlignedRotation);
			this.speed = getFloatValue(config.speed);
			this.speedVariance = getFloatValue(config.speedVariance);
			this.radialAcceleration = getFloatValue(config.radialAcceleration);
			this.radialAccelerationVariance = getFloatValue(config.radialAccelVariance);
			this.tangentialAcceleration = getFloatValue(config.tangentialAcceleration);
			this.tangentialAccelerationVariance = getFloatValue(config.tangentialAccelVariance);
			this.radiusMax = getFloatValue(config.maxRadius);
			this.radiusMaxVariance = getFloatValue(config.maxRadiusVariance);
			this.radiusMin = getFloatValue(config.minRadius);
			this.radiusMinVariance = getFloatValue(config.minRadiusVariance);
			this.rotatePerSecond = getFloatValue(config.rotatePerSecond) * DEG2RAD;
			this.rotatePerSecondVariance = getFloatValue(config.rotatePerSecondVariance) * DEG2RAD;

			getColor(config.startColor, this.colorStart);
			getColor(config.startColorVariance, this.colorStartVariance);
			getColor(config.finishColor, this.colorEnd);
			getColor(config.finishColorVariance, this.colorEndVariance);

			//this.blendFuncSource = getBlendFunc(config.blendFuncSource);
			//this.blendFuncDestination = getBlendFunc(config.blendFuncDestination);
			this.duration = getFloatValue(config.duration);
			
			if (this.sizeEndVariance != this.sizeEndVariance)
				this.sizeEndVariance = getFloatValue(config.FinishParticleSizeVariance);
			if (this.lifeSpan != this.lifeSpan)
				this.lifeSpan = MathUtils.max(0.01, getFloatValue(config.particleLifespan));
			if (this.lifeSpanVariance != this.lifeSpanVariance)
				this.lifeSpanVariance = getFloatValue(config.particleLifeSpanVariance);
			
			// new introduced properties //
			if (config.animation.length())
			{
				//var atlasName:String = config.animation.atlas.@name // not used ... just some info to identify the actual textureAtlas.xml file name, and debugging
				
				var node:XMLList = config.animation.isAnimated;
				
				if (node.length())
					this.textureAnimation = getBooleanValue(node);// && atlasXML;
				
				node = config.animation.loops;
				if (node.length())
					this.animationLoops = getFloatValue(node);
				
				node = config.animation.randomStartFrames;
				if (node.length())
					this.randomStartFrame = getBooleanValue(node);
			}
			
			node = config.fadeInTime;
			if (node.length())
				this.fadeInTime = getFloatValue(node);
			node = config.fadeOutTime;
			if (node.length())
				this.fadeOutTime = getFloatValue(node);
			node = config.exactBounds;
			if (node.length())
				this.exactBounds = getBooleanValue(node);
			// end of new properties // 
		}
		
		private static function getBooleanValue(element:XMLList):Boolean
		{
			if (element[0])
			{
				var valueStr:String = (element.attribute("value")).toLowerCase();
				var valueInt:int = parseInt(element.attribute("value"));
				var result:Boolean = valueStr == "true" || valueInt > 0;
				return result;
			}
			return false;
		}
		
		private static function getIntValue(element:XMLList):int
		{
			var result:int = parseInt(element.attribute("value"));
			return isNaN(result) ? 0 : result;
		}
		
		private static function getFloatValue(element:XMLList):Number
		{
			var result:Number = parseFloat(element.attribute("value"));
			return isNaN(result) ? 0 : result;
		}
		
		private static function getColor(element:XMLList, color:MassiveTint = null):MassiveTint
		{
			if (!color)
				color = new MassiveTint();
			
			var val:Number;
			val = parseFloat(element.attribute("red"));
			if (!isNaN(val))
				color.red = val;
			val = parseFloat(element.attribute("green"));
			if (!isNaN(val))
				color.green = val;
			val = parseFloat(element.attribute("blue"));
			if (!isNaN(val))
				color.blue = val;
			val = parseFloat(element.attribute("alpha"));
			if (!isNaN(val))
				color.alpha = val;
			return color;
		}
		
		private static function getBlendFunc(element:XMLList):String
		{
			var str:String = element.attribute("value");
			if (isNaN(Number(str)) && Context3DBlendFactor[str] !== undefined)
			{
				return Context3DBlendFactor[str];
			}
			var value:int = getIntValue(element);
			switch (value)
			{
				case 0: 
					return Context3DBlendFactor.ZERO;
					break;
				case 1: 
					return Context3DBlendFactor.ONE;
					break;
				case 0x300: 
					return Context3DBlendFactor.SOURCE_COLOR;
					break;
				case 0x301: 
					return Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR;
					break;
				case 0x302: 
					return Context3DBlendFactor.SOURCE_ALPHA;
					break;
				case 0x303: 
					return Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
					break;
				case 0x304: 
					return Context3DBlendFactor.DESTINATION_ALPHA;
					break;
				case 0x305: 
					return Context3DBlendFactor.ONE_MINUS_DESTINATION_ALPHA;
					break;
				case 0x306: 
					return Context3DBlendFactor.DESTINATION_COLOR;
					break;
				case 0x307: 
					return Context3DBlendFactor.ONE_MINUS_DESTINATION_COLOR;
					break;
				default: 
					throw new ArgumentError("unsupported blending function: " + value);
			}
		}
		
	}

}