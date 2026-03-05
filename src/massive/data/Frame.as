package massive.data 
{
	import starling.textures.SubTexture;
	import starling.textures.Texture;
	import starling.utils.Align;
	/**
	 * ...
	 * @author Matse
	 */
	public class Frame 
	{
		static public function fromTexture(texture:Texture):Frame
		{
			var frame:Frame;
			
			if (texture is SubTexture)
			{
				var subTexture:SubTexture = texture as SubTexture;
				frame = new Frame(texture.root.nativeWidth, texture.root.nativeHeight, subTexture.region.x,
								  subTexture.region.y, subTexture.region.width, subTexture.region.height,
								  subTexture.rotated);
			}
			else
			{
				frame = new Frame(texture.width, texture.height, 0, 0, texture.width, texture.height, false);
			}
			
			return frame;
		}
		
		static public function fromTextureWithAlign(texture:Texture, horizontalAlign:String, verticalAlign:String):Frame
		{
			var frame:Frame = fromTexture(texture);
			frame.alignPivot(horizontalAlign, verticalAlign);
			return frame;
		}
		
		static public function fromTextureWithPivot(texture:Texture, pivotX:Number, pivotY:Number):Frame
		{
			var frame:Frame = fromTexture(texture);
			frame.setPivot(pivotX, pivotY);
			return frame;
		}
		
		static public function fromTextureVector(textures:Vector.<Texture>, frames:Vector.<Frame> = null):Vector.<Frame>
		{
			if (textures == null || textures.length == 0) return null;
			if (frames == null) frames = new Vector.<Frame>();
			
			var frame:Frame;
			
			for (var i:int = 0; i < textures.length; i++)
			{
				frame = fromTexture(textures[i]);
				frames[frames.length] = frame;
			}
			
			return frames;
		}
		
		static public function fromTextureVectorWithAlign(textures:Vector.<Texture>, horizontalAlign:String,
														  verticalAlign:String, frames:Vector.<Frame> = null):Vector.<Frame>
		{
			if (textures == null || textures.length == 0) return null;
			if (frames == null) frames = new Vector.<Frame>();
			
			var frame:Frame;
			
			for (var i:int = 0; i < textures.length; i++)
			{
				frame = fromTextureWithAlign(textures[i], horizontalAlign, verticalAlign);
				frames[frames.length] = frame;
			}
			
			return frames;
		}
		
		static public function fromTextureVectorWithPivot(textures:Vector.<Texture>, pivotX:Number, pivotY:Number, frames:Vector.<Frame> = null):Vector.<Frame>
		{
			if (textures == null || textures.length == 0) return null;
			if (frames == null) frames = new Vector.<Frame>();
			
			var frame:Frame;
			
			for (var i:int = 0; i < textures.length; i++)
			{
				frame = fromTextureWithPivot(textures[i], pivotX, pivotY);
				frames[frames.length] = frame;
			}
			
			return frames;
		}
		
		/**
		 * Left texture coordinate
		 */
		public var u1:Number;
		/**
		 * Top texture coordinate
		 */
		public var v1:Number;
		/**
		 * Right texture coordinate
		 */
		public var u2:Number;
		/**
		 * Bottom texture coordinate
		 */
		public var v2:Number;
		/**
		 * Tells whether the texture is rotated or not
		 */
		public var rotated:Boolean;
		/**
		 * Width of the texture in pixels
		 */
		public var width:Number;
		/**
		 * Height of the texture in pixels
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
		 * How many pixels from 0 to pivotX
		 */
		public var leftWidth:Number;
		/**
		 * How many pixels from pivotX to width
		 */
		public var rightWidth:Number;
		/**
		 * How many pixels from 0 to pivotY
		 */
		public var topHeight:Number;
		/**
		 * How many pixels from pivotY to height
		 */
		public var bottomHeight:Number;
		
		/**
		 * Constructor
		 * @param	nativeTextureWidth
		 * @param	nativeTextureHeight
		 * @param	x
		 * @param	y
		 * @param	width
		 * @param	height
		 * @param	rotated
		 */
		public function Frame(nativeTextureWidth:Number, nativeTextureHeight:Number, x:Number, y:Number,
							  width:Number, height:Number, rotated:Boolean) 
		{
			this.u1 = x / nativeTextureWidth;
			this.v1 = y / nativeTextureHeight;
			this.u2 = (x + width) / nativeTextureWidth;
			this.v2 = (y + height) / nativeTextureHeight;
			
			this.width = width;
			this.height = height;
			
			this.rotated = rotated;
			
			this.setPivot(0, 0);
		}
		
		/**
		 * Sets pivotX and pivotY based on specified Align values and calls pivotUpdate
		 * @param	horizontalAlign
		 * @param	verticalAlign
		 */
		public function alignPivot(horizontalAlign:String, verticalAlign:String):void 
		{
			if (horizontalAlign == Align.LEFT) this.pivotX = 0;
			else if (horizontalAlign == Align.CENTER) this.pivotX = width / 2;
			else if (horizontalAlign == Align.RIGHT) this.pivotX = width;
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
		 * updates pivot-related values
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