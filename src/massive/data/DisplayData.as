package massive.data 
{
	import starling.errors.AbstractMethodError;
	/**
	 * Abstract base class for Massive display objects
	 * @author Matse
	 */
	public class DisplayData 
	{
		/**
		 * position on x-axis
		 * @default	0
		 */
		public var x:Number = 0;
		/**
		 * position on y-axis
		 * @default	0
		 */
		public var y:Number = 0;
		/**
		 * position offset on x-axis
		 * @default	0
		 */
		public var offsetX:Number = 0;
		/**
		 * position offset on y-axis
		 * @default	0
		 */
		public var offsetY:Number = 0;
		/**
		 * rotation in radians
		 * @default	0
		 */
		public var rotation:Number = 0;
		/**
		 * horizontal scale factor
		 * @default	1
		 */
		public var scaleX:Number = 1;
		/**
		 * vertical scale factor
		 * @default	1
		 */
		public var scaleY:Number = 1;
		/**
		 * Int color
		 * @default	0xffffff
		 */
		public function get color():int
		{
			var r:Number = this.red > 1.0 ? 1.0 : this.red < 0.0 ? 0.0 : this.red;
			var g:Number = this.green > 1.0 ? 1.0 : this.green < 0.0 ? 0.0 : this.green;
			var b:Number = this.blue > 1.0 ? 1.0 : this.blue < 0.0 ? 0.0 : this.blue;
			return int(r * 255) << 16 | int(g * 255) << 8 | int(b * 255);
		}
		public function set color(value:int):void
		{
			this.red = (int(value >> 16) & 0xFF) / 255.0;
			this.green = (int(value >> 8) & 0xFF) / 255.0;
			this.blue = (value & 0xFF) / 255.0;
		}
		/**
		 * Amount of red tinting, from -1.0 to 10.0
		 * @default	1
		 */
		public var red:Number = 1;
		/**
		 * Amount of green tinting, from -1.0 to 10.0
		 * @default	1
		 */
		public var green:Number = 1;
		/**
		 * Amount of blue tinting, from -1.0 to 10.0
		 * @default	1
		 */
		public var blue:Number = 1;
		/**
		 * Opacity, from 0.0 to 1.0
		 * @default	1
		 */
		public var alpha:Number = 1;
		/**
		 * Tells whether this object is visible or not
		 * @default	true
		 */
		public var visible:Boolean = true;
		
		public function DisplayData() 
		{
			
		}
		
		public function clear():void
		{
			this.x = this.y = this.offsetX = this.offsetY = this.rotation = 0;
			this.scaleX = this.scaleY = this.red = this.green = this.blue = this.alpha = 1;
			this.visible = true;
		}
		
		public function pool():void
		{
			throw new AbstractMethodError();
		}
		
	}

}