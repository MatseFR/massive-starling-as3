package massive.display 
{
	import flash.utils.ByteArray;
	import starling.errors.AbstractMethodError;
	import starling.events.EventDispatcher;
	/**
	 * Abstract base class for Massive layers
	 * @author Matse
	 */
	public class MassiveLayer extends EventDispatcher
	{
		/**
		   Tells whether the MassiveDisplay instance this layer is added to should call the advanceTime function or not
		**/
		public var animate:Boolean;
		/**
		   Tells whether the layer should count how many datas it has when requested to write it or not.
		   For example ParticleSystem turns this off and sets numDatas directly, according to how many particles are alive.
		   @default true
		**/
		public var autoHandleNumDatas:Boolean = true;
		/**
		   The MassiveDisplay instance this layer is added to, if any.
		**/
		public var display:MassiveDisplay;
		/**
		   Name of the layer, only useful if you want to be able to retrieve layers by their name
		**/
		public var name:String;
		/**
		   How many quads this layer should write data for when requested.
		**/
		public var numDatas:int = 0;
		/**
		   How many quads this layer has in total.
		**/
		public function get totalDatas():int { throw new AbstractMethodError(); }
		public function set totalDatas(value:int):void { throw new AbstractMethodError(); }
		/**
		   Tells whether this layer is visible or not.
		   @default true
		**/
		public var visible:Boolean = true;
		/**
		   The layer's position on x axis, relative to the MassiveDisplay it belongs to
		   @default 0
		**/
		public var x:Number = 0.0;
		/**
		   The layer's position on y axis, relative to the MassiveDisplay it belongs to
		   @default 0
		**/
		public var y:Number = 0.0;
		
		public function MassiveLayer() 
		{
			super();
		}
		
		/**
		 * Disposes the layer, optionally pooling its data
		 * @param	poolData
		 */
		public function dispose(poolData:Boolean = true):void
		{
			throw new AbstractMethodError();
		}
		
		/**
		 * Removes all data in the layer, optionally pooling it
		 * @param	pool
		 */
		public function removeAllData(pool:Boolean = true):void
		{
			throw new AbstractMethodError();
		}
		
		/**
		 * Writes the layer's quads data to the specified ByteArray
		 * @param	byteData
		 * @param	maxQuads
		 * @param	renderOffsetX
		 * @param	renderOffsetY
		 * @param	pma
		 * @param	useColor
		 * @param	simpleColor
		 * @param	renderData
		 * @param	boundsData
		 * @return
		 */
		public function writeDataBytes(byteData:ByteArray, maxQuads:int, renderOffsetX:Number, renderOffsetY:Number, pma:Boolean, useColor:Boolean, simpleColor:Boolean, renderData:RenderData, boundsData:Vector.<Number> = null):Boolean
		{
			throw new AbstractMethodError();
		}
		
		/**
		 * Writes the layer's quads data to the domain memory ByteArray
		 * @param	maxQuads
		 * @param	renderOffsetX
		 * @param	renderOffsetY
		 * @param	pma
		 * @param	useColor
		 * @param	simpleColor
		 * @param	renderData
		 * @param	boundsData
		 * @return
		 */
		public function writeDataBytesMemory(maxQuads:int, renderOffsetX:Number, renderOffsetY:Number, pma:Boolean, useColor:Boolean, simpleColor:Boolean, renderData:RenderData, boundsData:Vector.<Number> = null):Boolean
		{
			throw new AbstractMethodError();
		}
		
		/**
		 * Writes the layer's quads data to the specified Vector
		 * @param	vectorData
		 * @param	maxQuads
		 * @param	renderOffsetX
		 * @param	renderOffsetY
		 * @param	pma
		 * @param	useColor
		 * @param	simpleColor
		 * @param	renderData
		 * @param	boundsData
		 * @return
		 */
		public function writeDataVector(vectorData:Vector.<Number>, maxQuads:int, renderOffsetX:Number, renderOffsetY:Number, pma:Boolean, useColor:Boolean, simpleColor:Boolean, renderData:RenderData, boundsData:Vector.<Number> = null):Boolean
		{
			throw new AbstractMethodError();
		}
		
		/**
		   Writes the layer's quads bounds to the specified Vector (flash target) or Array (other targets)
		   @param	boundsData
		   @param	renderData
		   @param	renderOffsetX
		   @param	renderOffsetY
		**/
		public function writeBoundsData(boundsData:Vector.<Number>, renderData:RenderData, renderOffsetX:Number, renderOffsetY:Number):void
		{
			throw new AbstractMethodError();
		}
		
		/**
		 * Advances time for the layer, controlled by the MassiveDisplay instance this layer was added to
		 * @param	time
		 */
		public function advanceTime(time:Number):void
		{
			throw new AbstractMethodError();
		}
		
	}

}