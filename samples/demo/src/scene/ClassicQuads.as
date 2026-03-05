package scene 
{
	import massive.utils.LookUp;
	import massive.utils.MathUtils;
	import starling.animation.IAnimatable;
	import starling.core.Starling;
	import starling.display.Sprite3D;
	import starling.events.Event;
	import starling.filters.BlurFilter;
	import starling.utils.Color;
	/**
	 * ...
	 * @author Matse
	 */
	public class ClassicQuads extends Scene implements IAnimatable
	{
		public var displayScale:Number;
		public var numQuads:int = 2000;
		public var useBlurFilter:Boolean;
		public var useRandomAlpha:Boolean = false;
		public var useRandomColor:Boolean;
		public var useRandomRotation:Boolean;
		public var useSprite3D:Boolean;
		
		private var _quads:Vector.<MovingQuad>;
		private var _quadWidth:Number = 100;
		private var _quadHeight:Number = 100;
		private var _velocityBase:Number = 30;
		private var _velocityRange:Number = 150;
		
		private var _sprite3D:Sprite3D;
		
		public function ClassicQuads() 
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
			
			this._quads = new Vector.<MovingQuad>();
			
			var quad:MovingQuad;
			var velocity:Number;
			for (var i:int = 0; i < this.numQuads; i++)
			{
				quad = new MovingQuad(this._quadWidth, this._quadHeight);
				quad.scale = this.displayScale;
				if (this.useRandomAlpha) quad.alpha = MathUtils.random();
				if (this.useRandomColor) quad.color = Color.rgb(MathUtils.floor(MathUtils.random() * 256), MathUtils.floor(MathUtils.random() * 256), MathUtils.floor(MathUtils.random() * 256));
				quad.touchable = false;
				quad.alignPivot();
				
				quad.x = MathUtils.random() * stageWidth;
				quad.y = MathUtils.random() * stageHeight;
				if (this.useRandomRotation) quad.rotation = MathUtils.random() * MathUtils.PI2;
				
				velocity = this._velocityBase + MathUtils.random() * this._velocityRange;
				quad.velocityX = LookUp.cos(quad.rotation) * velocity;
				quad.velocityY = LookUp.sin(quad.rotation) * velocity;
				
				this._quads[i] = quad;
				if (this.useSprite3D)
				{
					this._sprite3D.addChild(quad);
				}
				else
				{
					addChild(quad);
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
			
			if (!this.useRandomRotation && this._quads != null)
			{
				var stageHeight:Number = this.stage.stageHeight;
				
				for (var i:int = 0; i < this.numQuads; i++)
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
			
			var quad:MovingQuad;
			for (var i:int = 0; i < this.numQuads; i++)
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

import starling.display.Quad;

class MovingQuad extends Quad
{
	public var velocityX:Number;
	public var velocityY:Number;
	
	public function MovingQuad(width:Number, height:Number, color:uint = 0xffffff)
	{
		super(width, height, color);
	}
}