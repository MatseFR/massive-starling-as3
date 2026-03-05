package scene 
{
	import starling.display.Sprite;
	
	/**
	 * ...
	 * @author Matse
	 */
	public class Scene extends Sprite 
	{
		protected var _animation:Boolean;
		public function get animation():Boolean { return this._animation; }
		public function set animation(value:Boolean):void
		{
			this._animation = value;
		}
		
		protected var _autoUpdateBounds:Boolean;
		public function get autoUpdateBounds():Boolean { return this._autoUpdateBounds; }
		public function set autoUpdateBounds(value:Boolean):void
		{
			this._autoUpdateBounds = value;
		}
		
		protected var _movement:Boolean;
		public function get movement():Boolean { return this._movement; }
		public function set movement(value:Boolean):void
		{
			this._movement = value;
		}
		
		protected var _top:Number;
		protected var _bottom:Number;
		protected var _left:Number;
		protected var _right:Number;
		protected var _space:Number = 20;
		
		public function Scene() 
		{
			super();
		}
		
		public function updateBounds():void
		{
			var stageWidth:Number = stage.stageWidth;
			var stageHeight:Number = stage.stageHeight;
			
			this._top = -this._space;
			this._bottom = stageHeight + this._space;
			this._left = -this._space;
			this._right = stageWidth + this._space;
		}
		
	}

}