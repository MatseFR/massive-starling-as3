package scene 
{
	import massive.animation.Animator;
	import massive.data.Frame;
	import massive.display.ImageLayer;
	import massive.display.MassiveDisplay;
	import massive.utils.LookUp;
	import massive.utils.MathUtils;
	import starling.animation.IAnimatable;
	import starling.core.Starling;
	import starling.display.Sprite3D;
	import starling.events.Event;
	import starling.filters.BlurFilter;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	import starling.utils.Align;
	/**
	 * ...
	 * @author Matse
	 */
	public class MassiveImages extends Scene implements IAnimatable
	{
		public var colorMode:String;
		public var frameDeltaBase:Number = 0.1;
		public var frameDeltaVariance:Number = 0.5;
		public var numObjects:int = 1000;
		public var renderMode:String;
		public var useBlurFilter:Boolean;
		public var useRandomAlpha:Boolean;
		public var useRandomColor:Boolean;
		public var useRandomRotation:Boolean;
		public var useSprite3D:Boolean;
		public var imgScale:Number = 1;
		public var atlasTextures:Vector.<Texture> = new Vector.<Texture>();
		public var textures:Vector.<Vector.<Texture>>;
		
		override public function set animation(value:Boolean):void 
		{
			if (this._display != null)
			{
				this._display.animate = value;
			}
			super.animation = value;
		}
		
		override public function set autoUpdateBounds(value:Boolean):void 
		{
			if (this._display != null)
			{
				this._display.autoUpdateBounds = value;
			}
			super.autoUpdateBounds = value;
		}
		
		private var _display:MassiveDisplay;
		private var _frames:Vector.<Vector.<Frame>> = new Vector.<Vector.<Frame>>();
		private var _timings:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>();
		
		private var _imgList:Vector.<MassiveImage>;
		private var _velocityBase:Number = 30;
		private var _velocityRange:Number = 150;
		
		private var _sprite3D:Sprite3D;
		
		public function MassiveImages() 
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		public function addAtlases(atlases:Vector.<TextureAtlas>):void
		{
			for (var i:int = 0; i < atlases.length; i++ )
			{
				this.atlasTextures.push(atlases[i].texture);
			}
		}
		
		private function addedToStageHandler(evt:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			
			var numTextures:int = this.atlasTextures.length;
			
			var frames:Vector.<Frame>;
			var timings:Vector.<Number>;
			
			for (var i:int = 0; i < numTextures; i++)
			{
				frames = Frame.fromTextureVectorWithAlign(this.textures[i], Align.CENTER, Align.CENTER);
				this._frames.push(frames);
				timings = Animator.generateTimings(frames);
				this._timings.push(timings);
			}
			
			var stageWidth:Number = this.stage.stageWidth;
			var stageHeight:Number = this.stage.stageHeight;
			
			updateBounds();
			
			if (this.useSprite3D)
			{
				this._sprite3D = new Sprite3D();
				this._sprite3D.pivotX = this.stage.stageWidth / 2;
				this._sprite3D.pivotY = this.stage.stageHeight / 2;
				this._sprite3D.x = this._sprite3D.pivotX;
				this._sprite3D.y = this._sprite3D.pivotY;
				addChild(this._sprite3D);
			}
			
			var layer:ImageLayer;
			this._imgList = new Vector.<MassiveImage>();
			var img:MassiveImage;
			var speedVariance:Number;
			var variant:int;
			var velocity:Number;
			
			this._display = new MassiveDisplay(this.atlasTextures, this.renderMode, this.colorMode, this.numObjects);
			this._display.animate = this._animation;
			this._display.autoUpdateBounds = this._autoUpdateBounds;
			
			layer = new ImageLayer();
			this._display.addLayer(layer);
			
			for (i = 0; i < this.numObjects; i++)
			{
				variant = MathUtils.floor(MathUtils.random() * numTextures);
				
				img = new MassiveImage();
				img.textureIndex = variant;
				//img.textureIndex = 0;
				img.setFrames(this._frames[variant], this._timings[variant], true, 0, MathUtils.floor(MathUtils.random() * this._frames[variant].length));
				img.x = MathUtils.random() * stageWidth;
				img.y = MathUtils.random() * stageHeight;
				img.scaleX = img.scaleY = this.imgScale;
				if (this.useRandomRotation) img.rotation = MathUtils.random() * MathUtils.PI2;
				
				if (this.useRandomAlpha) img.alpha = MathUtils.random();
				if (this.useRandomColor)
				{
					img.red = MathUtils.random();
					img.green = MathUtils.random();
					img.blue = MathUtils.random();
				}
				
				speedVariance = MathUtils.random();
				img.frameDelta = this.frameDeltaBase + speedVariance * this.frameDeltaVariance;
				
				velocity = this._velocityBase + speedVariance * this._velocityRange;
				img.velocityX = LookUp.cos(img.rotation) * velocity;
				img.velocityY = LookUp.sin(img.rotation) * velocity;
				
				this._imgList[this._imgList.length] = img;
				layer.addImage(img);
			}
			
			if (this.useSprite3D)
			{
				this._sprite3D.addChild(this._display);
			}
			else
			{
				addChild(this._display);
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
			
			if (!this.useRandomRotation && this._imgList != null)
			{
				var stageHeight:Number = this.stage.stageHeight;
				
				for (var i:int = 0; i < this.numObjects; i++)
				{
					this._imgList[i].y = MathUtils.random() * stageHeight;
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
			
			var img:MassiveImage;
			for (var i:int = 0; i < this.numObjects; i++)
			{
				img = this._imgList[i];
				if (this._movement)
				{
					img.x += img.velocityX * time;
					img.y += img.velocityY * time;
					
					if (img.x < this._left)
					{
						img.x = this._right;
					}
					else if (img.x > this._right)
					{
						img.x = this._left;
					}
					
					if (img.y < this._top)
					{
						img.y = this._bottom;
					}
					else if (img.y > this._bottom)
					{
						img.y = this._top;
					}
				}
			}
		}
		
	}

}

import massive.data.ImageData;

class MassiveImage extends ImageData
{
	public var velocityX:Number;
	public var velocityY:Number;
	
	public function MassiveImage()
	{
		super();
	}
}