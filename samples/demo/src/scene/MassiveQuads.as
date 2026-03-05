package scene 
{
	import massive.display.MassiveDisplay;
	import massive.display.QuadLayer;
	import massive.utils.LookUp;
	import massive.utils.MathUtils;
	import starling.animation.IAnimatable;
	import starling.core.Starling;
	import starling.display.Sprite3D;
	import starling.events.Event;
	import starling.filters.BlurFilter;
	import starling.utils.Align;
	/**
	 * ...
	 * @author Matse
	 */
	public class MassiveQuads extends Scene implements IAnimatable
	{
		public var colorMode:String;
		public var displayScale:Number;
		public var numObjects:int = 2000;
		public var renderMode:String;
		public var useBlurFilter:Boolean;
		public var useRandomAlpha:Boolean = false;
		public var useRandomColor:Boolean;
		public var useRandomRotation:Boolean;
		public var useSprite3D:Boolean;
		
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
		
		private var _quads:Vector.<MassiveQuad>;
		private var _quadWidth:Number = 100;
		private var _quadHeight:Number = 100;
		private var _velocityBase:Number = 30;
		private var _velocityRange:Number = 150;
		
		private var _sprite3D:Sprite3D;
		
		public function MassiveQuads() 
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		private function addedToStageHandler(evt:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			
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
			
			var layer:QuadLayer;
			this._quads = new Vector.<MassiveQuad>();
			
			var quad:MassiveQuad;
			var speedVariance:Number;
			var velocity:Number;
			
			this._display = new MassiveDisplay(null, this.renderMode, this.colorMode, this.numObjects);
			this._display.autoUpdateBounds = this.autoUpdateBounds;
			
			layer = new QuadLayer();
			this._display.addLayer(layer);
			
			for (var i:int = 0; i < this.numObjects; i++)
			{
				quad = new MassiveQuad();
				quad.x = MathUtils.random() * stageWidth;
				quad.y = MathUtils.random() * stageHeight;
				quad.width = this._quadWidth;
				quad.height = this._quadHeight;
				quad.scaleX = quad.scaleY = this.displayScale;
				if (this.useRandomRotation) quad.rotation = MathUtils.random() * MathUtils.PI2;
				
				if (this.useRandomAlpha) quad.alpha = MathUtils.random();
				if (this.useRandomColor)
				{
					quad.red = MathUtils.random();
					quad.green = MathUtils.random();
					quad.blue = MathUtils.random();
				}
				
				speedVariance = MathUtils.random();
				velocity = this._velocityBase + speedVariance * this._velocityRange;
				quad.velocityX = LookUp.cos(quad.rotation) * velocity;
				quad.velocityY = LookUp.sin(quad.rotation) * velocity;
				
				quad.alignPivot(Align.CENTER, Align.CENTER);
				
				this._quads[this._quads.length] = quad;
				layer.addQuad(quad);
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
			
			if (!this.useRandomRotation && this._quads != null)
			{
				var stageHeight:Number = this.stage.stageHeight;
				
				for (var i:int = 0; i < this.numObjects; i++)
				{
					this._quads[i].y = MathUtils.random() * stageHeight;
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
			
			var quad:MassiveQuad;
			for (var i:int = 0; i < this.numObjects; i++)
			{
				quad = this._quads[i];
				if (this._movement)
				{
					quad.x += quad.velocityX * time;
					quad.y += quad.velocityY * time;
					
					if (quad.x < this._left)
					{
						quad.x = this._right;
					}
					else if (quad.x > this._right)
					{
						quad.x = this._left;
					}
					
					if (quad.y < this._top)
					{
						quad.y = this._bottom;
					}
					else if (quad.y > this._bottom)
					{
						quad.y = this._top;
					}
				}
			}
		}
		
	}

}

import massive.data.QuadData;

class MassiveQuad extends QuadData
{
	public var velocityX:Number;
	public var velocityY:Number;
	
	public function MassiveQuad()
	{
		super();
	}
}