package massive.display 
{
	import avm2.intrinsics.memory.sf32;
	import avm2.intrinsics.memory.si32;
	import flash.utils.ByteArray;
	import massive.animation.Animator;
	import massive.data.Frame;
	import massive.data.ImageData;
	import massive.utils.LookUp;
	import massive.data.MassiveConstants;
	import massive.utils.MathUtils;
	
	/**
	 * A Massive layer that displays ImageData
	 * @author Matse
	 */
	public class ImageLayer extends MassiveLayer 
	{
		
		protected var _datas:Vector.<ImageData>;
		/**
		 * The Vector containing ImageData instances to draw
		 */
		public function get datas():Vector.<ImageData> { return this._datas; }
		public function set datas(value:Vector.<ImageData>):void
		{
			this._datas = value;
		}
		
		public var textureAnimation:Boolean = true;
		
		override public function get totalDatas():int { return this._datas == null ? 0 : this._datas.length; }
		
		protected var COS:Vector.<Number>;
		protected var SIN:Vector.<Number>;
		
		public function ImageLayer(datas:Vector.<ImageData> = null) 
		{
			super();
			
			this._datas = datas;
			if (this._datas == null) this._datas = new Vector.<ImageData>();
			this.animate = true;
			COS = LookUp.COS;
			SIN = LookUp.SIN;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose(poolData:Boolean = true):void 
		{
			if (poolData)
			{
				removeAllData(poolData);
			}
			this._datas = null;
		}
		
		/**
		 * Adds the specified ImageData to this layer
		 * @param	data
		 */
		public function addImage(data:ImageData):void
		{
			this._datas[this._datas.length] = data;
		}
		
		/**
		 * Adds the specified ImageData Vector to this layer
		 * @param	datas
		 */
		public function addImageVector(datas:Vector.<ImageData>):void
		{
			var count:int = datas.length;
			for (var i:int = 0; i < count; i++)
			{
				this._datas[this._datas.length] = datas[i];
			}
		}
		
		/**
		 * Removes the specified ImageData from this layer
		 * @param	data
		 */
		public function removeImage(data:ImageData):void
		{
			var index:int = this._datas.indexOf(data);
			if (index != -1) removeImageAt(index);
		}
		
		/**
		 * Removes ImageData at specified index
		 * @param	index
		 */
		public function removeImageAt(index:int):void
		{
			this._datas.removeAt(index);
		}
		
		/**
		 * Removes the specified ImageData Array from this layer
		 * @param	datas
		 */
		public function removeImageVector(datas:Vector.<ImageData>):void
		{
			var index:int;
			var count:int = datas.length;
			for (var i:int = 0; i < count; i++)
			{
				index = this._datas.indexOf(datas[i]);
				if (index != -1) removeImageAt(index);
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
			if (this.textureAnimation) Animator.animateImageDataList(this._datas, time);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function writeDataBytes(byteData:ByteArray, maxQuads:int, renderOffsetX:Number, renderOffsetY:Number, pma:Boolean, useColor:Boolean, simpleColor:Boolean, renderData:RenderData, boundsData:Vector.<Number> = null):Boolean
		{
			if (this._datas == null) return true;
			
			var multiTexturing:Boolean = renderData.multiTexturing;
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
			
			var frame:Frame;
			
			var u1:Number;
			var u2:Number;
			var v1:Number;
			var v2:Number;
			
			if (this.autoHandleNumDatas) this.numDatas = this._datas.length;
			
			var numQuads:int = MathUtils.minInt(this.numDatas - renderData.quadOffset, maxQuads);
			var totalQuads:int = renderData.quadOffset + numQuads;
			var storeBounds:Boolean = boundsData != null;
			var boundsIndex:int = storeBounds ? boundsData.length - 1 : -1;
			
			renderOffsetX += this.x;
			renderOffsetY += this.y;
			
			var data:ImageData;
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
				
				frame = data.frameList[data.frameIndex];
				if (data.invertX)
				{
					u1 = frame.u2;
					u2 = frame.u1;
				}
				else
				{
					u1 = frame.u1;
					u2 = frame.u2;
				}
				
				if (data.invertY)
				{
					v1 = frame.v2;
					v2 = frame.v1;
				}
				else
				{
					v1 = frame.v1;
					v2 = frame.v2;
				}
				
				leftOffset = frame.leftWidth * data.scaleX;
				rightOffset = frame.rightWidth * data.scaleX;
				topOffset = frame.topHeight * data.scaleY;
				bottomOffset = frame.bottomHeight * data.scaleY;
				
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
					byteData.writeFloat(u1);
					byteData.writeFloat(v1);
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
					if (multiTexturing)
					{
						byteData.writeFloat(data.textureIndexReal);
					}
					
					byteData.writeFloat(x + cosRight + sinTop);
					byteData.writeFloat(y + sinRight - cosTop);
					byteData.writeFloat(u2);
					byteData.writeFloat(v1);
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
					if (multiTexturing)
					{
						byteData.writeFloat(data.textureIndexReal);
					}
					
					byteData.writeFloat(x - cosLeft - sinBottom);
					byteData.writeFloat(y - sinLeft + cosBottom);
					byteData.writeFloat(u1);
					byteData.writeFloat(v2);
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
					if (multiTexturing)
					{
						byteData.writeFloat(data.textureIndexReal);
					}
					
					byteData.writeFloat(x + cosRight - sinBottom);
					byteData.writeFloat(y + sinRight + cosBottom);
					byteData.writeFloat(u2);
					byteData.writeFloat(v2);
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
					if (multiTexturing)
					{
						byteData.writeFloat(data.textureIndexReal);
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
					byteData.writeFloat(u1);
					byteData.writeFloat(v1);
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
					if (multiTexturing)
					{
						byteData.writeFloat(data.textureIndexReal);
					}
					
					byteData.writeFloat(x + rightOffset);
					byteData.writeFloat(y - topOffset);
					byteData.writeFloat(u2);
					byteData.writeFloat(v1);
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
					if (multiTexturing)
					{
						byteData.writeFloat(data.textureIndexReal);
					}
					
					byteData.writeFloat(x - leftOffset);
					byteData.writeFloat(y + bottomOffset);
					byteData.writeFloat(u1);
					byteData.writeFloat(v2);
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
					if (multiTexturing)
					{
						byteData.writeFloat(data.textureIndexReal);
					}
					
					byteData.writeFloat(x + rightOffset);
					byteData.writeFloat(y + bottomOffset);
					byteData.writeFloat(u2);
					byteData.writeFloat(v2);
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
					if (multiTexturing)
					{
						byteData.writeFloat(data.textureIndexReal);
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
		   @inheritDoc
		**/
		override public function writeDataBytesMemory(maxQuads:int, renderOffsetX:Number, renderOffsetY:Number, pma:Boolean, useColor:Boolean, simpleColor:Boolean, renderData:RenderData, boundsData:Vector.<Number> = null):Boolean
		{
			if (this._datas == null) return true;
			
			var position:int = renderData.position;
			var multiTexturing:Boolean = renderData.multiTexturing;
			
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
			
			var frame:Frame;
			
			var u1:Number;
			var u2:Number;
			var v1:Number;
			var v2:Number;
			
			if (this.autoHandleNumDatas) this.numDatas = this._datas.length;
			
			var numQuads:int = MathUtils.minInt(this.numDatas - renderData.quadOffset, maxQuads);
			var totalQuads:int = renderData.quadOffset + numQuads;
			var storeBounds:Boolean = boundsData != null;
			var boundsIndex:int = storeBounds ? boundsData.length - 1 : -1;
			
			renderOffsetX += this.x;
			renderOffsetY += this.y;
			
			var data:ImageData;
			
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
				
				frame = data.frameList[data.frameIndex];
				if (data.invertX)
				{
					u1 = frame.u2;
					u2 = frame.u1;
				}
				else
				{
					u1 = frame.u1;
					u2 = frame.u2;
				}
				
				if (data.invertY)
				{
					v1 = frame.v2;
					v2 = frame.v1;
				}
				else
				{
					v1 = frame.v1;
					v2 = frame.v2;
				}
				
				leftOffset = frame.leftWidth * data.scaleX;
				rightOffset = frame.rightWidth * data.scaleX;
				topOffset = frame.topHeight * data.scaleY;
				bottomOffset = frame.bottomHeight * data.scaleY;
				
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
					sf32(u1, position += 4);
					sf32(v1, position += 4);
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
					if (multiTexturing)
					{
						sf32(data.textureIndexReal, position += 4);
					}
					
					sf32(x + cosRight + sinTop, position += 4);
					sf32(y + sinRight - cosTop, position += 4);
					sf32(u2, position += 4);
					sf32(v1, position += 4);
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
					if (multiTexturing)
					{
						sf32(data.textureIndexReal, position += 4);
					}
					
					sf32(x - cosLeft - sinBottom, position += 4);
					sf32(y - sinLeft + cosBottom, position += 4);
					sf32(u1, position += 4);
					sf32(v2, position += 4);
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
					if (multiTexturing)
					{
						sf32(data.textureIndexReal, position += 4);
					}
					
					sf32(x + cosRight - sinBottom, position += 4);
					sf32(y + sinRight + cosBottom, position += 4);
					sf32(u2, position += 4);
					sf32(v2, position += 4);
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
					if (multiTexturing)
					{
						sf32(data.textureIndexReal, position += 4);
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
					sf32(u1, position += 4);
					sf32(v1, position += 4);
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
					if (multiTexturing)
					{
						sf32(data.textureIndexReal, position += 4);
					}
					
					sf32(x + rightOffset, position += 4);
					sf32(y - topOffset, position += 4);
					sf32(u2, position += 4);
					sf32(v1, position += 4);
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
					if (multiTexturing)
					{
						sf32(data.textureIndexReal, position += 4);
					}
					
					sf32(x - leftOffset, position += 4);
					sf32(y + bottomOffset, position += 4);
					sf32(u1, position += 4);
					sf32(v2, position += 4);
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
					if (multiTexturing)
					{
						sf32(data.textureIndexReal, position += 4);
					}
					
					sf32(x + rightOffset, position += 4);
					sf32(y + bottomOffset, position += 4);
					sf32(u2, position += 4);
					sf32(v2, position += 4);
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
					if (multiTexturing)
					{
						sf32(data.textureIndexReal, position += 4);
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
			if (this._datas == null) return 0;
			
			var position:int = renderData.position;
			var multiTexturing:Boolean = renderData.multiTexturing;
			
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
			
			var frame:Frame;
			
			var u1:Number;
			var u2:Number;
			var v1:Number;
			var v2:Number;
			
			if (this.autoHandleNumDatas) this.numDatas = this._datas.length;
			
			var numQuads:int = MathUtils.minInt(this.numDatas - renderData.quadOffset, maxQuads);
			var totalQuads:int = renderData.quadOffset + numQuads;
			var storeBounds:Boolean = boundsData != null;
			var boundsIndex:int = storeBounds ? boundsData.length - 1 : -1;
			
			renderOffsetX += this.x;
			renderOffsetY += this.y;
			
			var data:ImageData;
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
				
				frame = data.frameList[data.frameIndex];
				if (data.invertX)
				{
					u1 = frame.u2;
					u2 = frame.u1;
				}
				else
				{
					u1 = frame.u1;
					u2 = frame.u2;
				}
				
				if (data.invertY)
				{
					v1 = frame.v2;
					v2 = frame.v1;
				}
				else
				{
					v1 = frame.v1;
					v2 = frame.v2;
				}
				
				leftOffset = frame.leftWidth * data.scaleX;
				rightOffset = frame.rightWidth * data.scaleX;
				topOffset = frame.topHeight * data.scaleY;
				bottomOffset = frame.bottomHeight * data.scaleY;
				
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
					
					vectorData[position]   = x - cosLeft + sinTop;
					vectorData[++position] = y - sinLeft - cosTop;
					vectorData[++position] = u1;
					vectorData[++position] = v1;
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
					if (multiTexturing)
					{
						vectorData[++position] = data.textureIndexReal;
					}
					
					vectorData[++position] = x + cosRight + sinTop;
					vectorData[++position] = y + sinRight - cosTop;
					vectorData[++position] = u2;
					vectorData[++position] = v1;
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
					if (multiTexturing)
					{
						vectorData[++position] = data.textureIndexReal;
					}
					
					vectorData[++position] = x - cosLeft - sinBottom;
					vectorData[++position] = y - sinLeft + cosBottom;
					vectorData[++position] = u1;
					vectorData[++position] = v2;
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
					if (multiTexturing)
					{
						vectorData[++position] = data.textureIndexReal;
					}
					
					vectorData[++position] = x + cosRight - sinBottom;
					vectorData[++position] = y + sinRight + cosBottom;
					vectorData[++position] = u2;
					vectorData[++position] = v2;
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
					if (multiTexturing)
					{
						vectorData[++position] = data.textureIndexReal;
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
					vectorData[++position] = u1;
					vectorData[++position] = v1;
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
					if (multiTexturing)
					{
						vectorData[++position] = data.textureIndexReal;
					}
					
					vectorData[++position] = x + rightOffset;
					vectorData[++position] = y - topOffset;
					vectorData[++position] = u2;
					vectorData[++position] = v1;
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
					if (multiTexturing)
					{
						vectorData[++position] = data.textureIndexReal;
					}
					
					vectorData[++position] = x - leftOffset;
					vectorData[++position] = y + bottomOffset;
					vectorData[++position] = u1;
					vectorData[++position] = v2;
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
					if (multiTexturing)
					{
						vectorData[++position] = data.textureIndexReal;
					}
					
					vectorData[++position] = x + rightOffset;
					vectorData[++position] = y + bottomOffset;
					vectorData[++position] = u2;
					vectorData[++position] = v2;
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
					if (multiTexturing)
					{
						vectorData[++position] = data.textureIndexReal;
					}
				}
				position++;
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
			
			var frame:Frame;
			
			var position:int = boundsData.length;
			
			if (this.autoHandleNumDatas) this.numDatas = this._datas.length;
			
			renderOffsetX += this.x;
			renderOffsetY += this.y;
			
			var data:ImageData;
			for (var i:int = 0; i < this.numDatas; i++)
			{
				data = this._datas[i];
				if (!data.visible) continue;
				
				x = data.x + data.offsetX + renderOffsetX;
				y = data.y + data.offsetY + renderOffsetY;
				rotation = data.rotation;
				
				frame = data.frameList[data.frameIndex];
				
				leftOffset = frame.leftWidth * data.scaleX;
				rightOffset = frame.rightWidth * data.scaleX;
				topOffset = frame.topHeight * data.scaleY;
				bottomOffset = frame.bottomHeight * data.scaleY;
				
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
		}
		
	}

}