package scene 
{
	import massive.utils.LookUp;
	import massive.utils.MathUtils;
	import starling.animation.IAnimatable;
	import starling.core.Starling;
	import starling.display.Mesh;
	import starling.display.Sprite3D;
	import starling.events.Event;
	import starling.filters.BlurFilter;
	import starling.styles.MeshStyle;
	import starling.styles.MultiTextureStyle;
	import starling.textures.Texture;
	import starling.utils.Color;
	/**
	 * ...
	 * @author Matse
	 */
	public class ClassicClips extends Scene implements IAnimatable
	{
		public var frameRateBase:int = 6;
		public var frameRateVariance:int = 30;
		public var multiTextureStyle:Boolean;
		public var numClips:int = 1000;
		public var textures:Vector.<Vector.<Texture>>;
		public var clipScale:Number = 1;
		public var useBlurFilter:Boolean;
		public var useRandomAlpha:Boolean;
		public var useRandomColor:Boolean;
		public var useRandomRotation:Boolean;
		public var useSprite3D:Boolean;
		
		private var _clips:Vector.<MovingClip>;
		private var _velocityBase:Number = 30;
		private var _velocityRange:Number = 150;
		
		private var _sprite3D:Sprite3D;
		
		public function ClassicClips() 
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		private function addedToStageHandler(evt:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			
			var numTextures:int = this.textures.length;
			var stageWidth:Number = this.stage.stageWidth;
			var stageHeight:Number = this.stage.stageHeight;
			
			updateBounds();
			
			if (this.multiTextureStyle)
			{
				MultiTextureStyle.maxTextures = numTextures;
				Mesh.defaultStyle = MultiTextureStyle;
			}
			else
			{
				Mesh.defaultStyle = MeshStyle;
			}
			
			if (this.useSprite3D)
			{
				this._sprite3D = new Sprite3D();
				this._sprite3D.pivotX = this.stage.stageWidth / 2;
				this._sprite3D.pivotY = this.stage.stageHeight / 2;
				this._sprite3D.x = this._sprite3D.pivotX;
				this._sprite3D.y = this._sprite3D.pivotY;
				addChild(this._sprite3D);
			}
			
			this._clips = new Vector.<MovingClip>();
			
			var clip:MovingClip;
			var speedVariance:Number;
			var variant:int;
			var velocity:Number;
			
			for (var i:int = 0; i < this.numClips; i++)
			{
				variant = MathUtils.floor(MathUtils.random() * numTextures);
				
				speedVariance = MathUtils.random();
				clip = new MovingClip(this.textures[variant], this.frameRateBase + int(this.frameRateVariance * speedVariance));
				clip.currentFrame = MathUtils.floor(MathUtils.random() * this.textures[variant].length);
				clip.touchable = false;
				clip.alignPivot();
				if (this.useRandomAlpha) clip.alpha = MathUtils.random();
				if (this.useRandomColor) clip.color = Color.rgb(MathUtils.floor(MathUtils.random() * 256), MathUtils.floor(MathUtils.random() * 256), MathUtils.floor(MathUtils.random() * 256));
				clip.x = MathUtils.random() * stageWidth;
				clip.y = MathUtils.random() * stageHeight;
				clip.scaleX = clip.scaleY = this.clipScale;
				if (this.useRandomRotation)	clip.rotation = MathUtils.random() * MathUtils.PI2;
				
				velocity = this._velocityBase + speedVariance * this._velocityRange;
				clip.velocityX = LookUp.cos(clip.rotation) * velocity;
				clip.velocityY = LookUp.sin(clip.rotation) * velocity;
				
				this._clips[i] = clip;
				if (this.useSprite3D)
				{
					this._sprite3D.addChild(clip);
				}
				else
				{
					addChild(clip);
				}
			}
			
			if (this.useBlurFilter)
			{
				this.filter = new BlurFilter();
			}
			
			Starling.juggler.add(this);
		}
		
		override public function updateBounds():void 
		{
			super.updateBounds();
			
			if (this._sprite3D != null)
			{
				this._sprite3D.pivotX = this.stage.stageWidth / 2;
				this._sprite3D.pivotY = this.stage.stageHeight / 2;
				this._sprite3D.x = this._sprite3D.pivotX;
				this._sprite3D.y = this._sprite3D.pivotY;
			}
			
			if (!this.useRandomRotation && this._clips != null)
			{
				var stageHeight:Number = this.stage.stageHeight;
				
				for (var i:int = 0; i < this.numClips; i++)
				{
					this._clips[i].y = MathUtils.random() * stageHeight;
				}
			}
		}
		
		override public function dispose():void 
		{
			Starling.juggler.remove(this);
			
			super.dispose();
		}
		
		public function advanceTime(time:Number):void
		{
			if (this.useSprite3D)
			{
				this._sprite3D.rotationY += 0.01;
			}
			
			var clip:MovingClip;
			for (var i:int = 0; i < this.numClips; i++)
			{
				clip = this._clips[i];
				if (this._movement)
				{
					clip.x += clip.velocityX * time;
					clip.y += clip.velocityY * time;
					
					if (clip.x < this._left)
					{
						clip.x = this._right;
					}
					else if (clip.x > this._right)
					{
						clip.x = this._left;
					}
					
					if (clip.y < this._top)
					{
						clip.y = this._bottom;
					}
					else if (clip.y > this._bottom)
					{
						clip.y = this._top;
					}
				}
				if (this._animation) clip.advanceTime(time);
			}
		}
		
	}

}

import starling.display.MovieClip;
import starling.textures.Texture;

class MovingClip extends MovieClip
{
	public var velocityX:Number;
	public var velocityY:Number;
	
	public function MovingClip(textures:Vector.<Texture>, fps:int = 24)
	{
		super(textures, fps);
	}
}