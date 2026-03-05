package massive.data 
{
	/**
	 * Image display object with optionnal texture animation
	 * @author Matse
	 */
	public class ImageData extends DisplayData 
	{
		static public var TEXTURE_INDEX_MULTIPLIER:Number;
		
		static private var _POOL:Vector.<ImageData> = new Vector.<ImageData>();
		
		/**
		 * Returns an ImageData from pool if there's at least one in pool, or a new one otherwise
		 * @return
		 */
		static public function fromPool():ImageData
		{
			if (_POOL.length != 0) return _POOL.pop();
			return new ImageData();
		}
		
		/**
		 * Returns a Vector of ImageData, taken from pool if possible and created otherwise
		 * @param	numImages
		 * @param	images
		 * @return
		 */
		static public function fromPoolVector(numImages:int, images:Vector.<ImageData> = null):Vector.<ImageData>
		{
			if (images == null) images = new Vector.<ImageData>();
			
			while (numImages != 0)
			{
				if (_POOL.length == 0) break;
				images[images.length] = _POOL.pop();
				numImages--;
			}
			
			while (numImages != 0)
			{
				images[images.length] = new ImageData();
				numImages--;
			}
			
			return images;
		}
		
		/**
		 * Equivalent to calling ImageData's pool function
		 * @param	img
		 */
		static public function toPool(img:ImageData):void
		{
			img.clear();
			_POOL[_POOL.length] = img;
		}
		
		/**
		 * Pools all ImageData objects in the specified Vector
		 * @param	images
		 */
		static public function toPoolVector(images:Vector.<ImageData>):void
		{
			var count:int = images.length;
			for (var i:int = 0; i < count; i++)
			{
				images[i].pool();
			}
		}
		
		/**
		 * tells whether the ImageData is animated (if it has frames) or not
		 * @default	false
		 */
		public var animate:Boolean = false;
		/**
		 * How many frames
		 * @default	0
		 */
		public var frameCount:int = 0;
		/**
		 * Current Frame, if any (null otherwise)
		 */
		public function get frameCurrent():Frame { return (this.frameList == null || this.frameList.length == 0) ? null : this.frameList[this.frameIndex]; }
		/**
		 * Playback speed
		 * @default	1
		 */
		public var frameDelta:Number = 1.0;
		/**
		 * Index of the current frame
		 * @default	0
		 */
		public var frameIndex:int = 0;
		/**
		 * Lists all frames
		 * @default	null
		 */
		public var frameList:Vector.<Frame>;
		/**
		 * Time elapsed on current frame
		 * @default	0
		 */
		public var frameTime:Number = 0.0;
		/**
		 * Duration of each frame
		 * @default	null
		 */
		public var frameTimings:Vector.<Number>;
		/**
		 * Current frame's height, if any, multiplied by scaleY (0 otherwise)
		 */
		public function get height():Number { return (this.frameList == null || this.frameList.length == 0) ? 0.0 : this.frameList[this.frameIndex].height * this.scaleY; }
		public function set height(value:Number):void
		{
			if (this.frameList == null || this.frameList.length == 0) return;
			this.scaleY = value / this.frameList[this.frameIndex].height;
		}
		/**
		 * Tells whether to invert display on horizontal axis or not
		 * @default	false
		 */
		public var invertX:Boolean = false;
		/**
		 * Tells whether to invert display on vertical axis or not
		 * @default	false
		 */
		public var invertY:Boolean = false;
		/**
		 * Tells whether to loop frames
		 * @default	true
		 */
		public var loop:Boolean = true;
		/**
		 * Tells how many loops have been done
		 * @default	0
		 */
		public var loopCount:int = 0;
		/**
		 * How many loops, 0 == infinite
		 */
		public var numLoops:int = 0;
		/**
		 * Texture index when using multitexturing
		 * @default	0
		 */
		public function get textureIndex():Number { return this.textureIndexReal / TEXTURE_INDEX_MULTIPLIER; }
		public function set textureIndex(value:Number):void
		{
			this.textureIndexReal = value * TEXTURE_INDEX_MULTIPLIER;
		}
		/**
		 * Texture index used for rendering, if the profile is baseline it will differ from textureIndex
		 * @default	0
		 */
		public var textureIndexReal:Number = 0.0;
		/**
		 * Current frame's width, if any, multiplied by scaleX (0 otherwise)
		 */
		public function get width():Number { return (this.frameList == null || this.frameList.length == 0) ? 0.0 : this.frameList[this.frameIndex].width * this.scaleX; }
		public function set width(value:Number):void
		{
			if (this.frameList == null || this.frameList.length == 0) return;
			this.scaleX = value / this.frameList[this.frameIndex].width;
		}
		
		/**
		 * Constructor
		 */
		public function ImageData() 
		{
			super();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function clear():void 
		{
			this.invertX = this.invertY = this.animate = false;
			this.frameDelta = 1.0;
			this.frameTime = this.textureIndexReal = 0.0;
			this.loop = true;
			this.loopCount = this.numLoops = 0;
			
			clearFrames();
			
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
		 * Clears all stored Frame objects and associated timings
		 */
		public function clearFrames():void
		{
			this.frameList = null;
			this.frameTimings = null;
			this.frameCount = 0;
		}
		
		/**
		 * Sets the current animation properties : Frame objects, associated timings + playing options
		 * @param	frames
		 * @param	timings
		 * @param	loop
		 * @param	numLoops
		 * @param	frameIndex
		 * @param	animate
		 */
		public function setFrames(frames:Vector.<Frame>, timings:Vector.<Number> = null, loop:Boolean = true, numLoops:int = 0, frameIndex:int = 0, animate:Boolean = true):void
		{
			this.frameList = frames;
			this.frameTimings = timings;
			this.frameCount = this.frameTimings == null ? this.frameList != null ? this.frameList.length - 1 : 0 : this.frameTimings.length - 1;
			this.loop = loop;
			this.numLoops = numLoops;
			this.frameIndex = frameIndex;
			this.animate = animate;
			
			if (this.animate)
			{
				if (this.frameCount == 0)
				{
					this.animate = false;
				}
				else
				{
					if (this.frameIndex == 0)
					{
						this.frameTime = 0;
					}
					else
					{
						this.frameTime = this.frameTimings[this.frameIndex - 1];
					}
				}
			}
		}
		
		/**
		 * Set the timings associated to the current Frame objects
		 * @param	timings
		 */
		public function setFrameTimings(timings:Vector.<Number>):void
		{
			this.frameTimings = timings;
			this.frameCount = this.frameTimings == null ? this.frameList.length - 1 : this.frameTimings.length - 1;
		}
		
	}

}