package massive.utils 
{
	/**
	 * ...
	 * @author Matse
	 */
	public class MassiveTint 
	{
		private static var _POOL:Vector.<MassiveTint> = new Vector.<MassiveTint>();
		
		public static function fromPool(red:Number = 0, green:Number = 0, blue:Number = 0, alpha:Number = 0):MassiveTint
		{
			if (_POOL.length != 0) return _POOL.pop().setFromPool(red, green, blue, alpha);
			return new MassiveTint(red, green, blue, alpha);
		}
		
		/**
		 * amount of red tinting, from -1.0 to 1.0
		 */
		public var red:Number;
		
		/**
		 * amount of green tinting, from -1.0 to 1.0
		 */
		public var green:Number;
		
		/**
		 * amount of blue tinting, from -1.0 to 1.0
		 */
		public var blue:Number;
		
		/**
		 * transparency, from 0.0 to 1.0
		 */
		public var alpha:Number;
		
		public function MassiveTint(red:Number = 0, green:Number = 0, blue:Number = 0, alpha:Number = 0) 
		{
			this.red = red;
			this.green = green;
			this.blue = blue;
			this.alpha = alpha;
		}
		
		public function clear():void
		{
			this.red = this.green = this.blue = this.alpha = 0.0;
		}
		
		public function pool():void
		{
			_POOL[_POOL.length] = this;
		}
		
		public function setTo(red:Number, green:Number, blue:Number, alpha:Number):void
		{
			this.red = red;
			this.green = green;
			this.blue = blue;
			this.alpha = alpha;
		}
		
		private function setFromPool(red:Number, green:Number, blue:Number, alpha:Number):MassiveTint
		{
			setTo(red, green, blue, alpha);
			return this;
		}
		
		public function copyFrom(tint:MassiveTint):void
		{
			this.red = tint.red;
			this.green = tint.green;
			this.blue = tint.blue;
			this.alpha = tint.alpha;
		}
		
	}

}