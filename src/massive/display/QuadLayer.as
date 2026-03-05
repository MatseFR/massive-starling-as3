package massive.display 
{
	import avm2.intrinsics.memory.sf32;
	import avm2.intrinsics.memory.si32;
	import flash.utils.ByteArray;
	import massive.utils.LookUp;
	import massive.data.MassiveConstants;
	import massive.data.QuadData;
	import massive.utils.MathUtils;
	
	/**
	 * A Massive layer that displays QuadData
	 * @author Matse
	 */
	public class QuadLayer extends MassiveLayer 
	{
		protected var _datas:Vector.<QuadData>;
		/**
		 * The Vector containing QuadData instances to draw
		 */
		public function get datas():Vector.<QuadData> { return this._datas; }
		public function set datas(value:Vector.<QuadData>):void
		{
			this._datas = value;
		}
		
		override public function get totalDatas():int { return this._datas == null ? 0 : this._datas.length; }
		
		protected var COS:Vector.<Number>;
		protected var SIN:Vector.<Number>;
		
		public function QuadLayer(datas:Vector.<QuadData> = null) 
		{
			super();
			
			this._datas = datas;
			if (this._datas == null) this._datas = new Vector.<QuadData>();
			this.animate = false;
			COS = LookUp.COS;
			SIN = LookUp.SIN;
		}
		
		override public function dispose(poolData:Boolean = true):void
		{
			if (poolData)
			{
				removeAllData(poolData);
			}
			this._datas = null;
		}
		
		/**
		 * Adds the specified QuadData to this layer
		 * @param	data
		 */
		public function addQuad(data:QuadData):void
		{
			this._datas[this._datas.length] = data;
		}
		
		/**
		 * Adds the specified QuadData Vector to this layer
		 * @param	datas
		 */
		public function addQuadVector(datas:Vector.<QuadData>):void
		{
			var count:int = datas.length;
			for (var i:int = 0; i < count; i++)
			{
				this._datas[this._datas.length] = datas[i];
			}
		}
		
		/**
		 * Removes the specified QuadData from this layer
		 * @param	data
		 */
		public function removeQuad(data:QuadData):void
		{
			var index:int = this._datas.indexOf(data);
			if (index != -1) removeQuadAt(index);
		}
		
		/**
		 * Removes QuadData at specified index
		 * @param	index
		 */
		public function removeQuadAt(index:int):void
		{
			this._datas.removeAt(index);
		}
		
		/**
		 * Removes the specified QuadData Vector from this layer
		 * @param	datas
		 */
		public function removeQuadVector(datas:Vector.<QuadData>):void
		{
			var index:int;
			var count:int = datas.length;
			for (var i:int = 0; i < count; i++)
			{
				index = this._datas.indexOf(datas[i]);
				if (index != -1) removeQuadAt(index);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function removeAllData(pool:Boolean = true):void
		{
			if (pool)
			{
				var count:int = this._datas.length;
				for (var i:int = 0; i < count; i++)
				{
					this._datas[i].pool();
				}
			}
			this._datas.length = 0;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function advanceTime(time:Number):void 
		{
			// nothing
		}
		
		/**
		 * @inheritDoc
		 */
		override public function writeDataBytes(byteData:ByteArray, maxQuads:int, renderOffsetX:Number, renderOffsetY:Number, pma:Boolean, useColor:Boolean, simpleColor:Boolean, renderData:RenderData, boundsData:Vector.<Number> = null):Boolean
		{
			if (this._datas == null) return true;
			
			var quadsWritten:int = 0;
			
			var x:Number, y:Number;
			var leftOffset:Number, rightOffset:Number, topOffset:Number, bottomOffset:Number;
			var rotation:Number;
			
			var red:Number = 0.0;
			var green:Number = 0.0;
			var blue:Number = 0.0;
			var alpha:Number = 0.0;
			var color:int = 0;
			
			var angle:int;
			var cos:Number;
			var sin:Number;
			
			var cosLeft:Number;
			var cosRight:Number;
			var cosTop:Number;
			var cosBottom:Number;
			var sinLeft:Number;
			var sinRight:Number;
			var sinTop:Number;
			var sinBottom:Number;
			
			if (this.autoHandleNumDatas) this.numDatas = this._datas.length;
			
			var numQuads:int = MathUtils.minInt(this.numDatas - renderData.quadOffset, maxQuads);
			var totalQuads:int = renderData.quadOffset + numQuads;
			var storeBounds:Boolean = boundsData != null;
			var boundsIndex:int = storeBounds ? boundsData.length - 1 : -1;
			
			renderOffsetX += this.x;
			renderOffsetY += this.y;
			
			var data:QuadData;
			for (var i:int = renderData.quadOffset; i < totalQuads; i++)
			{
				data = this._datas[i];
				if (!data.visible) continue;
				
				++quadsWritten;
				
				x = data.x + data.offsetX + renderOffsetX;
				y = data.y + data.offsetY + renderOffsetY;
				rotation = data.rotation;
				
				if (useColor)
				{
					if (pma)
					{
						if (simpleColor)
						{
							alpha = data.alpha;
							alpha = alpha < 0.0 ? 0.0 : alpha > 1.0 ? 1.0 : alpha;
							red = data.red;
							red = red < 0.0 ? 0.0 : red > 1.0 ? 1.0 : red;
							green = data.green;
							green = green < 0.0 ? 0.0 : green > 1.0 ? 1.0 : green;
							blue = data.blue;
							blue = blue < 0.0 ? 0.0 : blue > 1.0 ? 1.0 : blue;
							alpha = data.alpha;
							color = int(red * alpha * 255) | int(green * alpha * 255) << 8 | int(blue * alpha * 255) << 16 | int(alpha * 255) << 24;
						}
						else
						{
							alpha = data.alpha;
							red = data.red * alpha;
							green = data.green * alpha;
							blue = data.blue * alpha;
						}
					}
					else
					{
						if (simpleColor)
						{
							alpha = data.alpha;
							alpha = alpha < 0.0 ? 0.0 : alpha > 1.0 ? 1.0 : alpha;
							red = data.red;
							red = red < 0.0 ? 0.0 : red > 1.0 ? 1.0 : red;
							green = data.green;
							green = green < 0.0 ? 0.0 : green > 1.0 ? 1.0 : green;
							blue = data.blue;
							blue = blue < 0.0 ? 0.0 : blue > 1.0 ? 1.0 : blue;
							color = int(red * 255) | int(green * 255) << 8 | int(blue * 255) << 16 | int(alpha * 255) << 24;
						}
						else
						{
							red = data.red;
							green = data.green;
							blue = data.blue;
							alpha = data.alpha;
						}
					}
				}
				
				leftOffset = data.leftWidth * data.scaleX;
				rightOffset = data.rightWidth * data.scaleX;
				topOffset = data.topHeight * data.scaleY;
				bottomOffset = data.bottomHeight * data.scaleY;
				
				if (rotation != 0.0)
				{
					angle = int(rotation * MassiveConstants.ANGLE_CONSTANT) & MassiveConstants.ANGLE_CONSTANT_2;
					cos = COS[angle];
					sin = SIN[angle];
					
					cosLeft = cos * leftOffset;
					cosRight = cos * rightOffset;
					cosTop = cos * topOffset;
					cosBottom = cos * bottomOffset;
					sinLeft = sin * leftOffset;
					sinRight = sin * rightOffset;
					sinTop = sin * topOffset;
					sinBottom = sin * bottomOffset;
					
					if (storeBounds)
					{
						boundsData[++boundsIndex] = x - cosLeft + sinTop;
						boundsData[++boundsIndex] = y - sinLeft - cosTop;
						boundsData[++boundsIndex] = x + cosRight + sinTop;
						boundsData[++boundsIndex] = y + sinRight - cosTop;
						boundsData[++boundsIndex] = x - cosLeft - sinBottom;
						boundsData[++boundsIndex] = y - sinLeft + cosBottom;
						boundsData[++boundsIndex] = x + cosRight - sinBottom;
						boundsData[++boundsIndex] = y + sinRight + cosBottom;
					}
					
					byteData.writeFloat(x - cosLeft + sinTop);
					byteData.writeFloat(y - sinLeft - cosTop);
					if (useColor)
					{
						if (simpleColor)
						{
							byteData.writeInt(color);
						}
						else
						{
							byteData.writeFloat(red);
							byteData.writeFloat(green);
							byteData.writeFloat(blue);
							byteData.writeFloat(alpha);
						}
					}
					
					byteData.writeFloat(x + cosRight + sinTop);
					byteData.writeFloat(y + sinRight - cosTop);
					if (useColor)
					{
						if (simpleColor)
						{
							byteData.writeInt(color);
						}
						else
						{
							byteData.writeFloat(red);
							byteData.writeFloat(green);
							byteData.writeFloat(blue);
							byteData.writeFloat(alpha);
						}
					}
					
					byteData.writeFloat(x - cosLeft - sinBottom);
					byteData.writeFloat(y - sinLeft + cosBottom);
					if (useColor)
					{
						if (simpleColor)
						{
							byteData.writeInt(color);
						}
						else
						{
							byteData.writeFloat(red);
							byteData.writeFloat(green);
							byteData.writeFloat(blue);
							byteData.writeFloat(alpha);
						}
					}
					
					byteData.writeFloat(x + cosRight - sinBottom);
					byteData.writeFloat(y + sinRight + cosBottom);
					if (useColor)
					{
						if (simpleColor)
						{
							byteData.writeInt(color);
						}
						else
						{
							byteData.writeFloat(red);
							byteData.writeFloat(green);
							byteData.writeFloat(blue);
							byteData.writeFloat(alpha);
						}
					}
				}
				else
				{
					if (storeBounds)
					{
						boundsData[++boundsIndex] = x - leftOffset;
						boundsData[++boundsIndex] = y - topOffset;
						boundsData[++boundsIndex] = x + rightOffset;
						boundsData[++boundsIndex] = y - topOffset;
						boundsData[++boundsIndex] = x - leftOffset;
						boundsData[++boundsIndex] = y + bottomOffset;
						boundsData[++boundsIndex] = x + rightOffset;
						boundsData[++boundsIndex] = y + bottomOffset;
					}
					
					byteData.writeFloat(x - leftOffset);
					byteData.writeFloat(y - topOffset);
					if (useColor)
					{
						if (simpleColor)
						{
							byteData.writeInt(color);
						}
						else
						{
							byteData.writeFloat(red);
							byteData.writeFloat(green);
							byteData.writeFloat(blue);
							byteData.writeFloat(alpha);
						}
					}
					
					byteData.writeFloat(x + rightOffset);
					byteData.writeFloat(y - topOffset);
					if (useColor)
					{
						if (simpleColor)
						{
							byteData.writeInt(color);
						}
						else
						{
							byteData.writeFloat(red);
							byteData.writeFloat(green);
							byteData.writeFloat(blue);
							byteData.writeFloat(alpha);
						}
					}
					
					byteData.writeFloat(x - leftOffset);
					byteData.writeFloat(y + bottomOffset);
					if (useColor)
					{
						if (simpleColor)
						{
							byteData.writeInt(color);
						}
						else
						{
							byteData.writeFloat(red);
							byteData.writeFloat(green);
							byteData.writeFloat(blue);
							byteData.writeFloat(alpha);
						}
					}
					
					byteData.writeFloat(x + rightOffset);
					byteData.writeFloat(y + bottomOffset);
					if (useColor)
					{
						if (simpleColor)
						{
							byteData.writeInt(color);
						}
						else
						{
							byteData.writeFloat(red);
							byteData.writeFloat(green);
							byteData.writeFloat(blue);
							byteData.writeFloat(alpha);
						}
					}
				}
			}
			
			renderData.numQuads += quadsWritten;
			renderData.totalQuads += quadsWritten;
			
			if (this.numDatas == totalQuads)
			{
				renderData.quadOffset = 0;
				return true;
			}
			else
			{
				renderData.quadOffset += numQuads;
				return false;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function writeDataBytesMemory(maxQuads:int, renderOffsetX:Number, renderOffsetY:Number, pma:Boolean, useColor:Boolean, simpleColor:Boolean, renderData:RenderData, boundsData:Vector.<Number> = null):Boolean
		{
			if (this._datas == null) return true;
			
			var position:int = renderData.position;
			
			var quadsWritten:int = 0;
			
			var x:Number, y:Number;
			var leftOffset:Number, rightOffset:Number, topOffset:Number, bottomOffset:Number;
			var rotation:Number;
			
			var red:Number = 0.0;
			var green:Number = 0.0;
			var blue:Number = 0.0;
			var alpha:Number = 0.0;
			var color:int = 0;
			
			var angle:int;
			var cos:Number;
			var sin:Number;
			
			var cosLeft:Number;
			var cosRight:Number;
			var cosTop:Number;
			var cosBottom:Number;
			var sinLeft:Number;
			var sinRight:Number;
			var sinTop:Number;
			var sinBottom:Number;
			
			if (this.autoHandleNumDatas) this.numDatas = this._datas.length;
			
			var numQuads:int = MathUtils.minInt(this.numDatas - renderData.quadOffset, maxQuads);
			var totalQuads:int = renderData.quadOffset + numQuads;
			var storeBounds:Boolean = boundsData != null;
			var boundsIndex:int = storeBounds ? boundsData.length - 1 : -1;
			
			renderOffsetX += this.x;
			renderOffsetY += this.y;
			
			var data:QuadData;
			for (var i:int = renderData.quadOffset; i < totalQuads; i++)
			{
				data = this._datas[i];
				if (!data.visible) continue;
				
				++quadsWritten;
				
				x = data.x + data.offsetX + renderOffsetX;
				y = data.y + data.offsetY + renderOffsetY;
				rotation = data.rotation;
				
				if (useColor)
				{
					if (pma)
					{
						if (simpleColor)
						{
							alpha = data.alpha;
							alpha = alpha < 0.0 ? 0.0 : alpha > 1.0 ? 1.0 : alpha;
							red = data.red;
							red = red < 0.0 ? 0.0 : red > 1.0 ? 1.0 : red;
							green = data.green;
							green = green < 0.0 ? 0.0 : green > 1.0 ? 1.0 : green;
							blue = data.blue;
							blue = blue < 0.0 ? 0.0 : blue > 1.0 ? 1.0 : blue;
							color = int(red * alpha * 255) | int(green * alpha * 255) << 8 | int(blue * alpha * 255) << 16 | int(alpha * 255) << 24;
						}
						else
						{
							alpha = data.alpha;
							red = data.red * alpha;
							green = data.green * alpha;
							blue = data.blue * alpha;
						}
					}
					else
					{
						if (simpleColor)
						{
							alpha = data.alpha;
							alpha = alpha < 0.0 ? 0.0 : alpha > 1.0 ? 1.0 : alpha;
							red = data.red;
							red = red < 0.0 ? 0.0 : red > 1.0 ? 1.0 : red;
							green = data.green;
							green = green < 0.0 ? 0.0 : green > 1.0 ? 1.0 : green;
							blue = data.blue;
							blue = blue < 0.0 ? 0.0 : blue > 1.0 ? 1.0 : blue;
							color = int(red * 255) | int(green * 255) << 8 | int(blue * 255) << 16 | int(alpha * 255) << 24;
						}
						else
						{
							red = data.red;
							green = data.green;
							blue = data.blue;
							alpha = data.alpha;
						}
					}
				}
				
				leftOffset = data.leftWidth * data.scaleX;
				rightOffset = data.rightWidth * data.scaleX;
				topOffset = data.topHeight * data.scaleY;
				bottomOffset = data.bottomHeight * data.scaleY;
				
				if (rotation != 0.0)
				{
					angle = int(rotation * MassiveConstants.ANGLE_CONSTANT) & MassiveConstants.ANGLE_CONSTANT_2;
					cos = COS[angle];
					sin = SIN[angle];
					//cos = Math.cos(rotation);
					//sin = Math.sin(rotation);
					
					cosLeft = cos * leftOffset;
					cosRight = cos * rightOffset;
					cosTop = cos * topOffset;
					cosBottom = cos * bottomOffset;
					sinLeft = sin * leftOffset;
					sinRight = sin * rightOffset;
					sinTop = sin * topOffset;
					sinBottom = sin * bottomOffset;
					
					if (storeBounds)
					{
						boundsData[++boundsIndex] = x - cosLeft + sinTop;
						boundsData[++boundsIndex] = y - sinLeft - cosTop;
						boundsData[++boundsIndex] = x + cosRight + sinTop;
						boundsData[++boundsIndex] = y + sinRight - cosTop;
						boundsData[++boundsIndex] = x - cosLeft - sinBottom;
						boundsData[++boundsIndex] = y - sinLeft + cosBottom;
						boundsData[++boundsIndex] = x + cosRight - sinBottom;
						boundsData[++boundsIndex] = y + sinRight + cosBottom;
					}
					
					sf32(x - cosLeft + sinTop, position);
					sf32(y - sinLeft - cosTop, position += 4);
					if (useColor)
					{
						if (simpleColor)
						{
							si32(color, position += 4);
						}
						else
						{
							sf32(red, position += 4);
							sf32(green, position += 4);
							sf32(blue, position += 4);
							sf32(alpha, position += 4);
						}
					}
					
					sf32(x + cosRight + sinTop, position += 4);
					sf32(y + sinRight - cosTop, position += 4);
					if (useColor)
					{
						if (simpleColor)
						{
							si32(color, position += 4);
						}
						else
						{
							sf32(red, position += 4);
							sf32(green, position += 4);
							sf32(blue, position += 4);
							sf32(alpha, position += 4);
						}
					}
					
					sf32(x - cosLeft - sinBottom, position += 4);
					sf32(y - sinLeft + cosBottom, position += 4);
					if (useColor)
					{
						if (simpleColor)
						{
							si32(color, position += 4);
						}
						else
						{
							sf32(red, position += 4);
							sf32(green, position += 4);
							sf32(blue, position += 4);
							sf32(alpha, position += 4);
						}
					}
					
					sf32(x + cosRight - sinBottom, position += 4);
					sf32(y + sinRight + cosBottom, position += 4);
					if (useColor)
					{
						if (simpleColor)
						{
							si32(color, position += 4);
						}
						else
						{
							sf32(red, position += 4);
							sf32(green, position += 4);
							sf32(blue, position += 4);
							sf32(alpha, position += 4);
						}
					}
				}
				else
				{
					if (storeBounds)
					{
						boundsData[++boundsIndex] = x - leftOffset;
						boundsData[++boundsIndex] = y - topOffset;
						boundsData[++boundsIndex] = x + rightOffset;
						boundsData[++boundsIndex] = y - topOffset;
						boundsData[++boundsIndex] = x - leftOffset;
						boundsData[++boundsIndex] = y + bottomOffset;
						boundsData[++boundsIndex] = x + rightOffset;
						boundsData[++boundsIndex] = y + bottomOffset;
					}
					
					sf32(x - leftOffset, position);
					sf32(y - topOffset, position += 4);
					if (useColor)
					{
						if (simpleColor)
						{
							si32(color, position += 4);
						}
						else
						{
							sf32(red, position += 4);
							sf32(green, position += 4);
							sf32(blue, position += 4);
							sf32(alpha, position += 4);
						}
					}
					
					sf32(x + rightOffset, position += 4);
					sf32(y - topOffset, position += 4);
					if (useColor)
					{
						if (simpleColor)
						{
							si32(color, position += 4);
						}
						else
						{
							sf32(red, position += 4);
							sf32(green, position += 4);
							sf32(blue, position += 4);
							sf32(alpha, position += 4);
						}
					}
					
					sf32(x - leftOffset, position += 4);
					sf32(y + bottomOffset, position += 4);
					if (useColor)
					{
						if (simpleColor)
						{
							si32(color, position += 4);
						}
						else
						{
							sf32(red, position += 4);
							sf32(green, position += 4);
							sf32(blue, position += 4);
							sf32(alpha, position += 4);
						}
					}
					
					sf32(x + rightOffset, position += 4);
					sf32(y + bottomOffset, position += 4);
					if (useColor)
					{
						if (simpleColor)
						{
							si32(color, position += 4);
						}
						else
						{
							sf32(red, position += 4);
							sf32(green, position += 4);
							sf32(blue, position += 4);
							sf32(alpha, position += 4);
						}
					}
				}
				position += 4;
			}
			
			renderData.numQuads += quadsWritten;
			renderData.position = position;
			renderData.totalQuads += quadsWritten;
			
			if (this.numDatas == totalQuads)
			{
				renderData.quadOffset = 0;
				return true;
			}
			else
			{
				renderData.quadOffset += numQuads;
				return false;
			}
			
		}
		
		/**
		 * @inheritDoc
		 */
		override public function writeDataVector(vectorData:Vector.<Number>, maxQuads:int, renderOffsetX:Number, renderOffsetY:Number, pma:Boolean, useColor:Boolean, simpleColor:Boolean, renderData:RenderData, boundsData:Vector.<Number> = null):Boolean
		{
			if (this._datas == null) return true;
			
			var position:int = renderData.position;
			
			var quadsWritten:int = 0;
			
			var x:Number, y:Number;
			var leftOffset:Number, rightOffset:Number, topOffset:Number, bottomOffset:Number;
			var rotation:Number;
			
			var red:Number = 0.0;
			var green:Number = 0.0;
			var blue:Number = 0.0;
			var alpha:Number = 0.0;
			var color:Number = 0.0;
			
			var angle:int;
			var cos:Number;
			var sin:Number;
			
			var cosLeft:Number;
			var cosRight:Number;
			var cosTop:Number;
			var cosBottom:Number;
			var sinLeft:Number;
			var sinRight:Number;
			var sinTop:Number;
			var sinBottom:Number;
			
			if (this.autoHandleNumDatas) this.numDatas = this._datas.length;
			
			var numQuads:int = MathUtils.minInt(this.numDatas - renderData.quadOffset, maxQuads);
			var totalQuads:int = renderData.quadOffset + numQuads;
			var storeBounds:Boolean = boundsData != null;
			var boundsIndex:int = storeBounds ? boundsData.length - 1 : -1;
			
			renderOffsetX += this.x;
			renderOffsetY += this.y;
			
			var data:QuadData;
			for (var i:int = renderData.quadOffset; i < totalQuads; i++)
			{
				data = this._datas[i];
				if (!data.visible) continue;
				
				++quadsWritten;
				
				x = data.x + data.offsetX + renderOffsetX;
				y = data.y + data.offsetY + renderOffsetY;
				rotation = data.rotation;
				
				if (useColor)
				{
					if (pma)
					{
						if (simpleColor)
						{
							alpha = data.alpha;
							alpha = alpha < 0.0 ? 0.0 : alpha > 1.0 ? 1.0 : alpha;
							red = data.red;
							red = red < 0.0 ? 0.0 : red > 1.0 ? 1.0 : red;
							green = data.green;
							green = green < 0.0 ? 0.0 : green > 1.0 ? 1.0 : green;
							blue = data.blue;
							blue = blue < 0.0 ? 0.0 : blue > 1.0 ? 1.0 : blue;
							// TODO : int to float
							color = int(red * alpha * 255) | int(green * alpha * 255) << 8 | int(blue * alpha * 255) << 16 | int(alpha * 255) << 24;
						}
						else
						{
							alpha = data.alpha;
							red = data.red * alpha;
							green = data.green * alpha;
							blue = data.blue * alpha;
						}
					}
					else
					{
						if (simpleColor)
						{
							alpha = data.alpha;
							alpha = alpha < 0.0 ? 0.0 : alpha > 1.0 ? 1.0 : alpha;
							red = data.red;
							red = red < 0.0 ? 0.0 : red > 1.0 ? 1.0 : red;
							green = data.green;
							green = green < 0.0 ? 0.0 : green > 1.0 ? 1.0 : green;
							blue = data.blue;
							blue = blue < 0.0 ? 0.0 : blue > 1.0 ? 1.0 : blue;
							// TODO : int to float
							color = int(red * 255) | int(green * 255) << 8 | int(blue * 255) << 16 | int(alpha * 255) << 24;
						}
						else
						{
							red = data.red;
							green = data.green;
							blue = data.blue;
							alpha = data.alpha;
						}
					}
				}
				
				leftOffset = data.leftWidth * data.scaleX;
				rightOffset = data.rightWidth * data.scaleX;
				topOffset = data.topHeight * data.scaleY;
				bottomOffset = data.bottomHeight * data.scaleY;
				
				if (rotation != 0)
				{
					angle = int(rotation * MassiveConstants.ANGLE_CONSTANT) & MassiveConstants.ANGLE_CONSTANT_2;
					cos = COS[angle];
					sin = SIN[angle];
					
					cosLeft = cos * leftOffset;
					cosRight = cos * rightOffset;
					cosTop = cos * topOffset;
					cosBottom = cos * bottomOffset;
					sinLeft = sin * leftOffset;
					sinRight = sin * rightOffset;
					sinTop = sin * topOffset;
					sinBottom = sin * bottomOffset;
					
					if (storeBounds)
					{
						boundsData[++boundsIndex] = x - cosLeft + sinTop;
						boundsData[++boundsIndex] = y - sinLeft - cosTop;
						boundsData[++boundsIndex] = x + cosRight + sinTop;
						boundsData[++boundsIndex] = y + sinRight - cosTop;
						boundsData[++boundsIndex] = x - cosLeft - sinBottom;
						boundsData[++boundsIndex] = y - sinLeft + cosBottom;
						boundsData[++boundsIndex] = x + cosRight - sinBottom;
						boundsData[++boundsIndex] = y + sinRight + cosBottom;
					}
					
					vectorData[position]   = x - cosLeft + sinTop;
					vectorData[++position] = y - sinLeft - cosTop;
					if (useColor)
					{
						if (simpleColor)
						{
							vectorData[++position] = color;
						}
						else
						{
							vectorData[++position] = red;
							vectorData[++position] = green;
							vectorData[++position] = blue;
							vectorData[++position] = alpha;
						}
					}
					
					vectorData[++position] = x + cosRight + sinTop;
					vectorData[++position] = y + sinRight - cosTop;
					if (useColor)
					{
						if (simpleColor)
						{
							vectorData[++position] = color;
						}
						else
						{
							vectorData[++position] = red;
							vectorData[++position] = green;
							vectorData[++position] = blue;
							vectorData[++position] = alpha;
						}
					}
					
					vectorData[++position] = x - cosLeft - sinBottom;
					vectorData[++position] = y - sinLeft + cosBottom;
					if (useColor)
					{
						if (simpleColor)
						{
							vectorData[++position] = color;
						}
						else
						{
							vectorData[++position] = red;
							vectorData[++position] = green;
							vectorData[++position] = blue;
							vectorData[++position] = alpha;
						}
					}
					
					vectorData[++position] = x + cosRight - sinBottom;
					vectorData[++position] = y + sinRight + cosBottom;
					if (useColor)
					{
						if (simpleColor)
						{
							vectorData[++position] = color;
						}
						else
						{
							vectorData[++position] = red;
							vectorData[++position] = green;
							vectorData[++position] = blue;
							vectorData[++position] = alpha;
						}
					}
				}
				else
				{
					if (storeBounds)
					{
						boundsData[++boundsIndex] = x - leftOffset;
						boundsData[++boundsIndex] = y - topOffset;
						boundsData[++boundsIndex] = x + rightOffset;
						boundsData[++boundsIndex] = y - topOffset;
						boundsData[++boundsIndex] = x - leftOffset;
						boundsData[++boundsIndex] = y + bottomOffset;
						boundsData[++boundsIndex] = x + rightOffset;
						boundsData[++boundsIndex] = y + bottomOffset;
					}
					
					vectorData[position]   = x - leftOffset;
					vectorData[++position] = y - topOffset;
					if (useColor)
					{
						if (simpleColor)
						{
							vectorData[++position] = color;
						}
						else
						{
							vectorData[++position] = red;
							vectorData[++position] = green;
							vectorData[++position] = blue;
							vectorData[++position] = alpha;
						}
					}
					
					vectorData[++position] = x + rightOffset;
					vectorData[++position] = y - topOffset;
					if (useColor)
					{
						if (simpleColor)
						{
							vectorData[++position] = color;
						}
						else
						{
							vectorData[++position] = red;
							vectorData[++position] = green;
							vectorData[++position] = blue;
							vectorData[++position] = alpha;
						}
					}
					
					vectorData[++position] = x - leftOffset;
					vectorData[++position] = y + bottomOffset;
					if (useColor)
					{
						if (simpleColor)
						{
							vectorData[++position] = color;
						}
						else
						{
							vectorData[++position] = red;
							vectorData[++position] = green;
							vectorData[++position] = blue;
							vectorData[++position] = alpha;
						}
					}
					
					vectorData[++position] = x + rightOffset;
					vectorData[++position] = y + bottomOffset;
					if (useColor)
					{
						if (simpleColor)
						{
							vectorData[++position] = color;
						}
						else
						{
							vectorData[++position] = red;
							vectorData[++position] = green;
							vectorData[++position] = blue;
							vectorData[++position] = alpha;
						}
					}
				}
				++position;
			}
			
			renderData.numQuads += quadsWritten;
			renderData.position = position;
			renderData.totalQuads += quadsWritten;
			
			if (this.numDatas == totalQuads)
			{
				renderData.quadOffset = 0;
				return true;
			}
			else
			{
				renderData.quadOffset += numQuads;
				return false;
			}
		}
		
		override public function writeBoundsData(boundsData:Vector.<Number>, renderData:RenderData, renderOffsetX:Number, renderOffsetY:Number):void
		{
			var x:Number, y:Number;
			var leftOffset:Number, rightOffset:Number, topOffset:Number, bottomOffset:Number;
			var rotation:Number;
			
			var angle:int;
			var cos:Number;
			var sin:Number;
			
			var cosLeft:Number;
			var cosRight:Number;
			var cosTop:Number;
			var cosBottom:Number;
			var sinLeft:Number;
			var sinRight:Number;
			var sinTop:Number;
			var sinBottom:Number;
			
			var position:int = boundsData.length;
			var quadsWritten:int = 0;
			
			if (this.autoHandleNumDatas) this.numDatas = this._datas.length;
			
			renderOffsetX += this.x;
			renderOffsetY += this.y;
			
			var data:QuadData;
			for (var i:int = 0; i < this.numDatas; i++)
			{
				data = this._datas[i];
				if (!data.visible) continue;
				
				++quadsWritten;
				
				x = data.x + data.offsetX + renderOffsetX;
				y = data.y + data.offsetY + renderOffsetY;
				rotation = data.rotation;
				
				leftOffset = data.leftWidth * data.scaleX;
				rightOffset = data.rightWidth * data.scaleX;
				topOffset = data.topHeight * data.scaleY;
				bottomOffset = data.bottomHeight * data.scaleY;
				
				if (rotation != 0.0)
				{
					angle = angle = int(rotation * MassiveConstants.ANGLE_CONSTANT) & MassiveConstants.ANGLE_CONSTANT_2;
					cos = COS[angle];
					sin = SIN[angle];
					//cos = Math.cos(rotation);
					//sin = Math.sin(rotation);
					
					cosLeft = cos * leftOffset;
					cosRight = cos * rightOffset;
					cosTop = cos * topOffset;
					cosBottom = cos * bottomOffset;
					sinLeft = sin * leftOffset;
					sinRight = sin * rightOffset;
					sinTop = sin * topOffset;
					sinBottom = sin * bottomOffset;
					
					boundsData[position]   = x - cosLeft + sinTop;
					boundsData[++position] = y - sinLeft - cosTop;
					
					boundsData[++position] = x + cosRight + sinTop;
					boundsData[++position] = y + sinRight - cosTop;
					
					boundsData[++position] = x - cosLeft - sinBottom;
					boundsData[++position] = y - sinLeft + cosBottom;
					
					boundsData[++position] = x + cosRight - sinBottom;
					boundsData[++position] = y + sinRight + cosBottom;
					
				}
				else
				{
					boundsData[position]   = x - leftOffset;
					boundsData[++position] = y - topOffset;
					
					boundsData[++position] = x + rightOffset;
					boundsData[++position] = y - topOffset;
					
					boundsData[++position] = x - leftOffset;
					boundsData[++position] = y + bottomOffset;
					
					boundsData[++position] = x + rightOffset;
					boundsData[++position] = y + bottomOffset;
				}
				
				++position;
			}
			
			renderData.totalQuads += quadsWritten;
		}
		
	}

}