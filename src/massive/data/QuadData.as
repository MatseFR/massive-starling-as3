package massive.data 
{
	import starling.utils.Align;
	
	/**
	 * Quad display object
	 * @author Matse
	 */
	public class QuadData extends DisplayData 
	{
		static private var _POOL:Vector.<QuadData> = new Vector.<QuadData>();
		
		/**
		 * Returns a QuadData from pool if there's at least one in pool, or a new one otherwise
		 * @return
		 */
		static public function fromPool():QuadData
		{
			if (_POOL.length != 0) return _POOL.pop();
			return new QuadData();
		}
		
		/**
		 * Returns a Vector of QuadData, taken from pool if possible and created otherwise
		 * @param	numQuads
		 * @param	quads
		 * @return
		 */
		static public function fromPoolVector(numQuads:int, quads:Vector.<QuadData> = null):Vector.<QuadData>
		{
			if (quads == null) quads = new Vector.<QuadData>();
			
			while (numQuads != 0)
			{
				if (_POOL.length == 0) break;
				quads[quads.length] = _POOL.pop();
				numQuads--;
			}
			
			while (numQuads != 0)
			{
				quads[quads.length] = new QuadData();
				numQuads--;
			}
			
			return quads;
		}
		
		/**
		 * Equivalent to calling QuadData's pool function
		 * @param	quad
		 */
		static public function toPool(quad:QuadData):void
		{
			quad.clear();
			_POOL[_POOL.length] = quad;
		}
		
		/**
		 * Pools all QuadData objects in the specified Vector
		 * @param	quads
		 */
		static public function toPoolVector(quads:Vector.<QuadData>):void
		{
			var count:int = quads.length;
			for (var i:int = 0; i < count; i++)
			{
				quads[i].pool();
			}
		}
		
		/**
		 * Size from left border to pivotX
		 */
		public var leftWidth:Number;
		/**
		 * Size from pivotX to right border
		 */
		public var rightWidth:Number;
		/**
		 * Size from top border to pivotY
		 */
		public var topHeight:Number;
		/**
		 * Size from pivotY to bottom border
		 */
		public var bottomHeight:Number;
		/**
		 * Base width
		 */
		public var width:Number;
		/**
		 * Base height
		 */
		public var height:Number;
		/**
		 * Pivot location on x-axis
		 * If you set this value directly you should call pivotUpdate afterwards
		 */
		public var pivotX:Number;
		/**
		 * Pivot location on y-axis
		 * If you set this value directly you should call pivotUpdate afterwards
		 */
		public var pivotY:Number;
		
		/**
		 * Constructor
		 */
		public function QuadData() 
		{
			super();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function clear():void 
		{
			super.clear();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function pool():void 
		{
			clear();
			_POOL[_POOL.length] = this;
		}
		
		/**
		 * Sets pivotX and pivotY based on specified Align values and calls pivotUpdate
		 * @param	horizontalAlign
		 * @param	verticalAlign
		 */
		public function alignPivot(horizontalAlign:String, verticalAlign:String):void 
		{
			if (horizontalAlign == Align.LEFT) this.pivotX = 0;
			else if (horizontalAlign == Align.CENTER) this.pivotX = this.width / 2;
			else if (horizontalAlign == Align.RIGHT) this.pivotX = this.width;
			else throw new ArgumentError("Invalid horizontal alignment : " + horizontalAlign);
			
			if (verticalAlign == Align.TOP) this.pivotY = 0;
			else if (verticalAlign == Align.CENTER) this.pivotY = height / 2;
			else if (verticalAlign == Align.BOTTOM) this.pivotY = height;
			else throw new ArgumentError("Invalid vertical alignment : " + verticalAlign);
			
			pivotUpdate();
		}
		
		/**
		 * Sets pivotX and pivotY values and calls pivotUpdate
		 * @param	pivotX
		 * @param	pivotY
		 */
		public function setPivot(pivotX:Number, pivotY:Number):void 
		{
			this.pivotX = pivotX;
			this.pivotY = pivotY;
			
			pivotUpdate();
		}
		
		/**
		 * Updates pivot-related values
		 */
		public function pivotUpdate():void
		{
			this.leftWidth = this.pivotX;
			this.rightWidth = this.width - this.pivotX;
			this.topHeight = this.pivotY;
			this.bottomHeight = this.height - this.pivotY;
		}
		
	}

}