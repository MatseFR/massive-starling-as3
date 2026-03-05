package massive.display 
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DBufferUsage;
	import flash.display3D.Context3DProfile;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import massive.data.ImageData;
	import massive.data.MassiveConstants;
	import massive.utils.MathUtils;
	import starling.animation.IAnimatable;
	import starling.animation.Juggler;
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.DisplayObject;
	import starling.errors.MissingContextError;
	import starling.events.Event;
	import starling.rendering.Painter;
	import starling.rendering.Program;
	import starling.textures.Texture;
	import starling.textures.TextureSmoothing;
	import starling.utils.MatrixUtil;
	import starling.utils.RenderUtil;
	
	/**
	 * MassiveDisplay is a starling DisplayObject
	 * in order to display anything you need to add at least a layer to it, and then add data to that layer
	 * @author Matse
	 */
	public class MassiveDisplay extends DisplayObject implements IAnimatable
	{
		/**
		 * Call this to initialize Massive
		 * if you don't, it will be called by the first MassiveDisplay instance you create
		 */
		static public function init():void
		{
			if (_initDone) return;
			
			if (Starling.current == null)
			{
				throw new Error("MassiveDisplay.init should be called after Starling is started");
			}
			
			_isBaseline = Starling.current.profile == Context3DProfile.BASELINE ||
						  Starling.current.profile == Context3DProfile.BASELINE_CONSTRAINED ||
						  Starling.current.profile == Context3DProfile.BASELINE_EXTENDED;
			
			if (_isBaseline)
			{
				_maxNumTextures = 5;
				ImageData.TEXTURE_INDEX_MULTIPLIER = 0.25;
			}
			else
			{
				_maxNumTextures = 16; // TODO : find a way to detect max simultaneous textures on flash/air target
				ImageData.TEXTURE_INDEX_MULTIPLIER = 1.0;
			}
			
			_initDone = true;
		}
		
		static private var _POOL:Vector.<MassiveDisplay> = new Vector.<MassiveDisplay>();
		
		static public function fromPool(textureOrTextures:Object = null, renderMode:String = null, colorMode:String = null, maxQuads:int = MassiveConstants.MAX_QUADS):MassiveDisplay
		{
			if (_POOL.length != 0) return _POOL.pop().setFromPool(textureOrTextures, renderMode, colorMode, maxQuads);
			return new MassiveDisplay(textureOrTextures, renderMode, colorMode, maxQuads);
		}
		
		/**
		 * The default Juggler instance to use for all MassiveDisplay objects when their juggler property is null.
		 * If left null it will default to Starling.currentJuggler
		 */
		static public var defaultJuggler:Juggler;
		
		/**
		 * Default colorMode, used when colorMode parameter is null.
		 */
		static public var defaultColorMode:String = MassiveColorMode.EXTENDED;
		
		/**
		 * Default renderMode, used when renderMode parameter is null.
		 */
		static public var defaultRenderMode:String = MassiveRenderMode.BYTEARRAY_DOMAIN_MEMORY;
		
		/**
		 * Default texture smoothing
		 */
		static public var defaultTextureSmoothing:String = TextureSmoothing.BILINEAR;
		
		static protected var _maxNumTextures:int;
		/**
		 * Maximum number of textures for a single MassiveDisplay instance.
		 */
		static public function get maxNumTextures():int { return _maxNumTextures; }
		
		/**
		 * Default program used when `useColor` is `true` and `texture` is `null`
		 */
		static public var programColorNoTexture:Program;
		/**
		 * Default program used when `useColor` is `true`, `texture`'s `premultipliedAlpha` is `false` and `texture`'s format is `Context3DTextureFormat.COMPRESSED`
		 */
		static public var programColorTextureCompressed:Program;
		/**
		 * Default program used when `useColor` is `true`, `texture`'s `premultipliedAlpha` is `true` and `texture`'s format is `Context3DTextureFormat.COMPRESSED`
		 */
		static public var programColorTextureCompressedPMA:Program;
		/**
		 * Default program used when `useColor` is `true`, `texture`'s `premultipliedAlpha` is `false` and `texture`'s format is `Context3DTextureFormat.COMPRESSED_ALPHA`
		 */
		static public var programColorTextureCompressedAlpha:Program;
		/**
		 * Default program used when `useColor` is `true`, `texture`'s `premultipliedAlpha` is `true` and `texture`'s format is `Context3DTextureFormat.COMPRESSED_ALPHA`
		 */
		static public var programColorTextureCompressedAlphaPMA:Program;
		/**
		 * Default program used when `useColor` is `true`, `texture`'s `premultipliedAlpha` is `false` and `texture`'s format is neither `Context3DTextureFormat.COMPRESSED` or `Context3DTextureFormat.COMPRESSED_ALPHA`
		 */
		static public var programColorTextureDefault:Program;
		/**
		 * Default program used when `useColor` is `true`, `texture`'s `premultipliedAlpha` is `true` and `texture`'s format is neither `Context3DTextureFormat.COMPRESSED` or `Context3DTextureFormat.COMPRESSED_ALPHA`
		 */
		static public var programColorTextureDefaultPMA:Program;
		/**
		 * Default program used when `useColor` is `false` and `texture` is `null`
		 */
		static public var programNoColorNoTexture:Program;
		/**
		 *  Default program used when `useColor` is `false`, `texture`'s `premultipliedAlpha` is `false` and `texture`'s format is `Context3DTextureFormat.COMPRESSED`
		 */
		static public var programNoColorTextureCompressed:Program;
		/**
		 * Default program used when `useColor` is `false`, `texture`'s `premultipliedAlpha` is `true` and `texture`'s format is `Context3DTextureFormat.COMPRESSED`
		 */
		static public var programNoColorTextureCompressedPMA:Program;
		/**
		 * Default program used when `useColor` is `false`, `texture`'s `premultipliedAlpha` is `false` and `texture`'s format is `Context3DTextureFormat.COMPRESSED_ALPHA`
		 */
		static public var programNoColorTextureCompressedAlpha:Program;
		/**
		 * Default program used when `useColor` is `false`, `texture`'s `premultipliedAlpha` is `true` and `texture`'s format is `Context3DTextureFormat.COMPRESSED_ALPHA`
		 */
		static public var programNoColorTextureCompressedAlphaPMA:Program;		
		/**
		 * Default program used when `useColor` is `false`, `texture`'s `premultipliedAlpha` is `false` and `texture`'s format is neither `Context3DTextureFormat.COMPRESSED` or `Context3DTextureFormat.COMPRESSED_ALPHA`
		 */
		static public var programNoColorTextureDefault:Program;
		/**
		 * Default program used when `useColor` is `false`, `texture`'s `premultipliedAlpha` is `true` and `texture`'s format is neither `Context3DTextureFormat.COMPRESSED` or `Context3DTextureFormat.COMPRESSED_ALPHA`
		 */
		static public var programNoColorTextureDefaultPMA:Program;
		
		static protected var _initDone:Boolean = false;
		static protected var _isBaseline:Boolean;
		static protected var _byteIndices:ByteArray;
		static protected var _helperMatrix:Matrix = new Matrix();
		static protected var _helperPoint:Point = new Point();
		static protected var _baselineMultiTextureIndices:Vector.<Number> = Vector.<Number>([0.125, 0.375, 0.625, 0.875, 1, 0, 0, 0]);
		
		/**
		 * Tells whether to animate layers
		 * @default	true
		 */
		public var animate:Boolean = true;
		
		protected var _autoHandleJuggler:Boolean = true;
		/**
		 * If set to true, the MassiveDisplay instance will automatically add itself to the juggler 
		 * when added to stage and remove itself when removed from stage. Default is true.
		 * @default true
		 */
		public function get autoHandleJuggler():Boolean { return this._autoHandleJuggler; }
		public function set autoHandleJuggler(value:Boolean):void
		{
			this._autoHandleJuggler = value;
		}
		
		protected var _autoUpdateBounds:Boolean = false;
		/**
		 * Tells whether exact bounds should be updated every frame.
		 * Caution : this can be very expensive with tens of thousands of quads.
		 * @default	false
		 */
		public function get autoUpdateBounds():Boolean { return this._autoUpdateBounds; }
		public function set autoUpdateBounds(value:Boolean):void
		{
			this._autoUpdateBounds = value;
		}
		
		/**
		 * By default a MassiveDisplay instance will use stage bounds, set this if you need different bounds.
		 * @default	null
		 */
		public var boundsRect:Rectangle;
		
		/**
		 * Color as int
		 */
		public function get color():int
		{
			var r:Number = this._red > 1.0 ? 1.0 : this._red < 0.0 ? 0.0 : this._red;
			var g:Number = this._green > 1.0 ? 1.0 : this._green < 0.0 ? 0.0 : this._green;
			var b:Number = this._blue > 1.0 ? 1.0 : this._blue < 0.0 ? 0.0 : this._blue;
			return int(r * 255) << 16 | int(g * 255) << 8 | int(b * 255);
		}
		public function set color(value:int):void
		{
			this._red = (int(value >> 16) & 0xFF) / 255.0;
			this._green = (int(value >> 8) & 0xFF) / 255.0;
			this._blue = (value & 0xFF) / 255.0;
			updateColor();
		}
		
		protected var _colorMode:String;
		/**
		 * Tells how to handle color, see massive.display.MassiveColorMode for possible values and details about them.
		 */
		public function get colorMode():String { return this._colorMode; }
		public function set colorMode(value:String):void
		{
			if (this._colorMode == value) return;
			
			switch (value)
			{
				case MassiveColorMode.EXTENDED :
					this._useColor = true;
					this._simpleColorMode = false;
					break;
				
				case MassiveColorMode.REGULAR :
					this._useColor = true;
					this._simpleColorMode = true;
					break;
				
				case MassiveColorMode.NONE :
					this._useColor = false;
					this._simpleColorMode = false;
					break;
			}
			
			updateElements();
			if (this._buffersCreated)
			{
				updateBuffers();
			}
			if (this._program != null)
			{
				updateProgram();
			}
			updateData();
			
			this._colorMode = value;
		}
		
		protected var _blue:Number = 1;
		/**
		 * Amount of blue tinting applied to the whole MassiveDisplay instance, from -1 to 10.
		 * This has no effect when useColor is turned off.
		 * @default	1
		 */
		public function get blue():Number { return this._blue; }
		public function set blue(value:Number):void
		{
			if (!this._pma)
			{
				this._byteColor.position = 8;
				this._byteColor.writeFloat(value);
			}
			this._blue = value;
		}
		
		protected var _green:Number = 1;
		/**
		 * Amount of green tinting applied to the whole MassiveDisplay instance, from -1 to 10.
		 * This has no effect when useColor is turned off.
		 * @default	1
		 */
		public function get green():Number { return this._green; }
		public function set green(value:Number):void
		{
			if (!this._pma)
			{
				this._byteColor.position = 4;
				this._byteColor.writeFloat(value);
			}
			this._green = value;
		}
		
		protected var _red:Number = 1;
		/**
		 * Amount of red tinting applied to the whole MassiveDisplay instance, from -1 to 10.
		 * This has no effect when useColor is turned off.
		 * @default	1
		 */
		public function get red():Number { return this._red; }
		public function set red(value:Number):void
		{
			if (!this._pma)
			{
				this._byteColor.position = 0;
				this._byteColor.writeFloat(value);
			}
			this._red = value;
		}
		
		protected var _elementsPerQuad:int;
		/**
		 * How many 32bit values per quad
		 */
		public function get elementsPerQuad():int { return this._elementsPerQuad; }
		
		protected var _elementsPerVertex:int;
		/**
		 * How many 32bit values per vertex
		 */
		public function get elementsPerVertex():int { return this._elementsPerVertex; }
		
		protected var _juggler:Juggler;
		/**
		 * The Juggler instance that this MassiveDisplay instance will use if autoHandleJuggler is true.
		 * If null, MassiveDisplay.defaultJuggler will be used.
		 */
		public function get juggler():Juggler { return this._juggler; }
		public function set juggler(value:Juggler):void
		{
			this._juggler = value;
		}
		
		protected var _maxQuads:int;
		/**
		 * The maximum number of quads that can be rendered simultaneously.
		 * This determines the vertex buffer(s) size and how many are needed.
		 * For best performance, one vertex buffer is created for 16383 quads.
		 */
		public function get maxQuads():int { return this._maxQuads; }
		public function set maxQuads(value:int):void
		{
			if (this._maxQuads == value) return;
			var prevBufferSize:int = this._bufferSize;
			this._bufferSize = MathUtils.minInt(value, MassiveConstants.MAX_QUADS);
			var prevNumBuffers:int = this._numBuffers;
			this._numBuffers = MathUtils.ceil(value / MassiveConstants.MAX_QUADS);
			if (this._bufferSize != prevBufferSize || this._numBuffers != prevNumBuffers)
			{
				if (this._buffersCreated)
				{
					updateBuffers();
				}
				updateData();
			}
			this._maxQuads = value;
		}
		
		/**
		 * Tells how many layers this MassiveDisplay instance currently has.
		 */
		public function get numLayers():int { return this._layers.length; }
		
		protected var _numQuads:int = 0;
		/**
		 * Tells how many quads were rendered on the last render call
		 */
		public function get numQuads():int { return this._numQuads; }
		
		/**
		 * Tells how many textures have been added
		 */
		public function get numTextures():int { return this._textures.length; }
		
		protected var _pma:Boolean = true;
		
		protected var _program:Program;
		/**
		 * The shader used by this MassiveDisplay instance
		 */
		public function get program():Program { return this._program; }
		public function set program(value:Program):void
		{
			this._isUserProgram = value != null;
			this._program = value;
		}
		
		protected var _renderMode:String;
		/**
		 * Tells how to render, see massive.display.MassiveRenderMode for possible values and details about them.
		 */
		public function get renderMode():String { return this._renderMode; }
		public function set renderMode(value:String):void
		{
			if (this._renderMode == value) return;
			
			switch (value)
			{
				case MassiveRenderMode.BYTEARRAY :
					this._useByteArray = true;
					this._useByteArrayDomainMemory = false;
					if (this._byteData == null)
					{
						this._byteData = new ByteArray();
						this._byteData.length = this._bufferSize * this._elementsPerQuad * 4;
						this._byteData.endian = Endian.LITTLE_ENDIAN;
					}
					else
					{
						this._byteData.length = this._bufferSize * this._elementsPerQuad * 4;
					}
					this._vectorData = null;
					break;
				
				case MassiveRenderMode.BYTEARRAY_DOMAIN_MEMORY :
					this._useByteArray = true;
					this._useByteArrayDomainMemory = true;
					if (this._byteData == null)
					{
						this._byteData = new ByteArray();
						this._byteData.length = this._bufferSize * this._elementsPerQuad * 4 + 1024; // for some reason if we don't add 1024 to the byte array's length it will fail on release mode
						this._byteData.endian = Endian.LITTLE_ENDIAN;
					}
					else
					{
						this._byteData.length = this._bufferSize * this._elementsPerQuad * 4 + 1024; // for some reason if we don't add 1024 to the byte array's length it will fail on release mode
					}
					this._vectorData = null;
					break;
				
				case MassiveRenderMode.VECTOR :
					this._vectorData = new Vector.<Number>();
					this._useByteArray = false;
					this._useByteArrayDomainMemory = false;
					this._byteData = null;
					break;
			}
			
			this._renderMode = value;
		}
		
		/**
		 * Offsets all layers by the specified amount on x axis when rendering
		 */
		public var renderOffsetX:Number = 0.0;
		
		/**
		 * Offsets all layers by the specified amount on y axis when rendering
		 */
		public var renderOffsetY:Number = 0.0;
		
		public function get texture():Texture { return this._textures.length == 0 ? null : this._textures[0]; }
		public function set texture(value:Texture):void
		{
			if (this._textures.length != 0 && this._textures[0] == value) return;
			if (value == null)
			{
				if (this._textures.length != 0)
				{
					removeTextureAt(0);
				}
			}
			else
			{
				this._textures[0] = value;
				updateTextures();
			}
		}
		
		protected var _textureRepeat:Boolean = false;
		/**
		 * Tells whether texture should repeat or not
		 * @default	false
		 */
		public function get textureRepeat():Boolean { return this._textureRepeat; }
		public function set textureRepeat(value:Boolean):void
		{
			this._textureRepeat = value;
		}
		
		protected var _textureSmoothing:String = TextureSmoothing.BILINEAR;
		/**
		 * Tells which texture smoothing value to use
		 * @default TextureSmoothing.BILINEAR
		 */
		public function get textureSmoothing():String { return this._textureSmoothing; }
		public function set textureSmoothing(value:String):void
		{
			this._textureSmoothing = value;
		}
		
		override public function set touchable(value:Boolean):void 
		{
			if (value)
			{
				throw new Error("MassiveDisplay cannot be touchable");
			}
			super.touchable = value;
		}
		
		protected var _simpleColorMode:Boolean;
		/**
		 * Tells whether to have color data for tinting/colorizing, this results in bigger vertex data and more complex shader so disabling it is a good idea if you don't need it
		 */
		protected var _useColor:Boolean;
		/**
		 * Tells the MassiveDisplay instance to use a ByteArray to store and upload vertex data. This seems to result in faster upload on flash/air target, but at a higher cpu cost.
		 */
		protected var _useByteArray:Boolean;
		/**
		 * If useByteArray is set to true, this makes the MassiveDisplay instance to write vertex data using domain memory, which is a lot faster than calling ByteArray functions.
		 * This seems to be the best setting for flash/air target.
		 */
		protected var _useByteArrayDomainMemory:Boolean;
		
		protected var _layers:Vector.<MassiveLayer> = new Vector.<MassiveLayer>();
		protected var _numLayers:int;
		
		protected var _buffersCreated:Boolean = false;
		protected var _bufferSize:int;
		protected var _numBuffers:int;
		
		protected var _indexBuffer:IndexBuffer3D;
		protected var _vertexBuffer:VertexBuffer3D;
		protected var _vertexBufferIndex:int = -1;
		protected var _vertexBuffers:Vector.<VertexBuffer3D>;
		
		protected var _boundsData:Vector.<Number> = new Vector.<Number>();
		protected var _byteColor:ByteArray;
		protected var _vectorData:Vector.<Number>;
		protected var _byteData:ByteArray;
		
		protected var _isUserProgram:Boolean;
		
		protected var _positionOffset:int = 0;
		protected var _colorOffset:int;
		protected var _uvOffset:int;
		protected var _textureOffset:int;
		
		protected var _zeroBytes:ByteArray = new ByteArray();;
		
		protected var _contextBufferIndex:int;
		protected var _renderData:RenderData = new RenderData();
		
		protected var _textures:Vector.<Texture> = new Vector.<Texture>();
		protected var _numTextures:int;
		protected var _multiTexturing:Boolean = false;
		protected var _isMultiTexturingProgram:Boolean = false;
		protected var _multiTexturingConstants:Vector.<Number>;
		
		public function MassiveDisplay(textureOrTextures:Object = null, renderMode:String = null, colorMode:String = null, maxQuads:int = MassiveConstants.MAX_QUADS) 
		{
			super();
			
			if (_isBaseline)
			{
				this._multiTexturingConstants = _baselineMultiTextureIndices;
			}
			else
			{
				this._multiTexturingConstants = new Vector.<Number>();
			}
			
			if (textureOrTextures != null)
			{
				if (textureOrTextures is Texture)
				{
					addTexture(textureOrTextures as Texture);
				}
				else
				{
					addTextures(textureOrTextures as Vector.<Texture>);
				}
			}
			this.maxQuads = maxQuads;
			
			if (colorMode == null) colorMode = defaultColorMode;
			if (colorMode == null) colorMode = MassiveColorMode.EXTENDED;
			this.colorMode = colorMode;
			
			if (renderMode == null) renderMode = defaultRenderMode;
			if (renderMode == null) renderMode = MassiveRenderMode.BYTEARRAY_DOMAIN_MEMORY;
			this.renderMode = renderMode;
			
			this.blendMode = BlendMode.NORMAL;
			this.touchable = false;
			this.addEventListener(Event.ADDED_TO_STAGE, addedToStage);
			
			this._byteColor = new ByteArray();
			this._byteColor.length = 16;
			this._byteColor.endian = Endian.LITTLE_ENDIAN;
			this._byteColor.writeFloat(this._red);
			this._byteColor.writeFloat(this._green);
			this._byteColor.writeFloat(this._blue);
			this._byteColor.writeFloat(this.alpha);
			
			if (defaultJuggler == null) defaultJuggler = Starling.juggler;
			if (this._juggler == null) this._juggler = defaultJuggler;
		}
		
		protected function setFromPool(textureOrTextures:Object, renderMode:String, colorMode:String, maxQuads:int):MassiveDisplay
		{
			if (textureOrTextures != null)
			{
				if (textureOrTextures is Texture)
				{
					addTexture(textureOrTextures as Texture);
				}
				else
				{
					addTextures(textureOrTextures as Vector.<Texture>);
				}
			}
			this.maxQuads = maxQuads;
			
			if (colorMode == null) colorMode = defaultColorMode;
			if (colorMode == null) colorMode = MassiveColorMode.EXTENDED;
			this.colorMode = colorMode;
			
			if (renderMode == null) renderMode = defaultRenderMode;
			if (renderMode == null) renderMode = MassiveRenderMode.BYTEARRAY_DOMAIN_MEMORY;
			this.renderMode = renderMode;
			return this;
		}
		
		override public function dispose():void 
		{
			disposeBuffers();
			if (!this._isUserProgram && this._isMultiTexturingProgram && this._program != null)
			{
				this._program.dispose();
			}
			this._program = null;
			removeAllLayers(true, false);
			this._textures = null;
			
			super.dispose();
		}
		
		public function clear(disposeLayers:Boolean = true, poolDatas:Boolean = true):void
		{
			disposeBuffers();
			if (!this._isUserProgram && this._isMultiTexturingProgram && this._program != null)
			{
				this._program.dispose();
			}
			this._program = null;
			removeAllLayers(disposeLayers, poolDatas);
			this._textures.length = 0;
			
			this.animate = true;
			this._autoHandleJuggler = true;
			this._autoUpdateBounds = false;
			this.blendMode = BlendMode.NORMAL;
			this.boundsRect = null;
			this.alpha = this.blue = this.green = this.red = 1.0;
			this._juggler = defaultJuggler;
			this.renderOffsetX = this.renderOffsetY = 0.0;
			this._textureRepeat = false;
			this._textureSmoothing = defaultTextureSmoothing;
		}
		
		public function pool():void
		{
			clear();
			_POOL[_POOL.length] = this;
		}
		
		private function addedToStage(evt:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			this.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
			
			Starling.current.addEventListener(Event.CONTEXT3D_CREATE, contextCreated);
			
			if (!this._buffersCreated) updateBuffers();
			if (this._program == null) updateProgram();
			if (this._autoHandleJuggler) this._juggler.add(this);
		}
		
		private function removedFromStage(evt:Event):void
		{
			this.removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
			this.addEventListener(Event.ADDED_TO_STAGE, addedToStage);
			
			Starling.current.removeEventListener(Event.CONTEXT3D_CREATE, contextCreated);
			
			if (this._autoHandleJuggler) this._juggler.remove(this);
		}
		
		private function contextCreated(evt:Event):void
		{
			updateBuffers();
		}
		
		public function addTexture(texture:Texture):void
		{
			this._textures[this._textures.length] = texture;
			updateTextures();
		}
		
		public function addTextureAt(texture:Texture, index:int):void
		{
			this._textures.insertAt(index, texture);
			updateTextures();
		}
		
		public function addTextures(textures:Vector.<Texture>):void
		{
			for (var i:int = 0; i < textures.length; i++)
			{
				this._textures[this._textures.length] = textures[i];
			}
			updateTextures();
		}
		
		public function addTexturesAt(textures:Vector.<Texture>, index:int):void
		{
			for (var i:int = 0; i < textures.length; i++)
			{
				this._textures.insertAt(index + i, textures[i]);
			}
			updateTextures();
		}
		
		public function clearTextures():void
		{
			this._textures.length = 0;
			updateTextures();
		}
		
		public function getTextureAt(index:int):Texture
		{
			return this._textures[index];
		}
		
		public function removeTexture(texture:Texture):void
		{
			var index:int = this._textures.indexOf(texture);
			if (index != -1)
			{
				this._textures.removeAt(index);
				updateTextures();
			}
		}
		
		public function removeTextureAt(index:int):void
		{
			this._textures.removeAt(index);
			updateTextures();
		}
		
		public function removeTextures(textures:Vector.<Texture>):void
		{
			var index:int;
			for (var i:int = 0; i < textures.length; i++)
			{
				index = this._textures.indexOf(textures[i]);
				if (index != -1) this._textures.removeAt(index);
			}
			updateTextures();
		}
		
		public function setTextureAt(texture:Texture, index:int):void
		{
			this._textures[index] = texture;
			updateTextures();
		}
		
		public function setTextures(textures:Vector.<Texture>):void
		{
			this._textures.length = 0;
			addTextures(textures);
		}
		
		public function setTexturesAt(textures:Vector.<Texture>, index:int):void
		{
			for (var i:int = 0; i < textures.length; i++)
			{
				this._textures[index + i] = textures[i];
			}
			updateTextures();
		}
		
		public function updateBuffers():void
		{
			disposeBuffers();
			
			var context:Context3D = Starling.context;
			if (context == null)
			{
				throw new MissingContextError();
			}
			
			if (this._vertexBuffers == null)
			{
				this._vertexBuffers = new Vector.<VertexBuffer3D>();
			}
			
			this._vertexBufferIndex = -1;
			
			this._zeroBytes.length = this._bufferSize * MassiveConstants.VERTICES_PER_QUAD * this._elementsPerQuad;
			
			for (var i:int = 0; i < this._numBuffers; i++)
			{
				this._vertexBuffers[i] = context.createVertexBuffer(this._bufferSize * MassiveConstants.VERTICES_PER_QUAD, this._elementsPerVertex, Context3DBufferUsage.DYNAMIC_DRAW);
				this._vertexBuffers[i].uploadFromByteArray(this._zeroBytes, 0, 0, this._bufferSize * MassiveConstants.VERTICES_PER_QUAD);
			}
			
			this._indexBuffer = context.createIndexBuffer(this._bufferSize * 6);
			
			if (_byteIndices == null)
			{
				var numVertices:int = 0;
				_byteIndices = new ByteArray();
				_byteIndices.endian = Endian.LITTLE_ENDIAN;
				
				for (i = 0; i < MassiveConstants.MAX_QUADS; i++)
				{
					_byteIndices.writeShort(numVertices);
					_byteIndices.writeShort(numVertices + 1);
					_byteIndices.writeShort(numVertices + 2);
					_byteIndices.writeShort(numVertices + 1);
					_byteIndices.writeShort(numVertices + 2);
					_byteIndices.writeShort(numVertices + 3);
					
					numVertices += MassiveConstants.VERTICES_PER_QUAD;
				}
			}
			this._indexBuffer.uploadFromByteArray(_byteIndices, 0, 0, this._bufferSize * 6);
			
			this._buffersCreated = true;
		}
		
		public function disposeBuffers():void
		{
			if (this._indexBuffer != null)
			{
				this._indexBuffer.dispose();
				this._indexBuffer = null;
			}
			
			if (this._vertexBuffers != null)
			{
				for (var i:int = 0; i < this._vertexBuffers.length; i++)
				{
					this._vertexBuffers[i].dispose();
				}
				this._vertexBuffers.length = 0;
			}
			
			this._buffersCreated = false;
		}
		
		protected function updateColor():void
		{
			if (this._pma) return;
			
			this._byteColor.position = 0;
			this._byteColor.writeFloat(this._red);
			this._byteColor.writeFloat(this._green);
			this._byteColor.writeFloat(this._blue);
		}
		
		protected function updateData():void
		{
			if (this._useByteArray && this._byteData != null)
			{
				if (this._useByteArrayDomainMemory)
				{
					this._byteData.length = this._bufferSize * this._elementsPerQuad * 4 + 1024; // for some reason if we don't add 1024 to the byte array's length it will fail on release mode
				}
				else
				{
					this._byteData.length = this._bufferSize * this._elementsPerQuad * 4;
				}
			}
		}
		
		protected function updateElements():void
		{
			// x/y position is not optionnal
			var offset:int = 2;
			this._elementsPerVertex = 2;
			if (this._numTextures > 0) 
			{
				this._elementsPerVertex += 2;
				this._uvOffset = offset;
				offset += 2;
			}
			else
			{
				this._uvOffset = 0;
			}
			if (this._useColor) 
			{
				this._colorOffset = offset;
				if (this._simpleColorMode)
				{
					this._elementsPerVertex += 1;
					offset += 1;
				}
				else
				{
					this._elementsPerVertex += 4;
					offset += 4;
				}
			}
			else
			{
				this._colorOffset = 0;
			}
			
			if (this._numTextures > 1)
			{
				this._elementsPerVertex += 1;
				this._textureOffset = offset;
				offset += 1;
			}
			
			this._elementsPerQuad = MassiveConstants.VERTICES_PER_QUAD * this._elementsPerVertex;
		}
		
		protected function updateProgram():void
		{
			if (this._isUserProgram) return;
			
			if (this._isMultiTexturingProgram)
			{
				this._program.dispose();
				this._isMultiTexturingProgram = false;
				if (!_isBaseline) this._multiTexturingConstants.length = 0;
			}
			
			var texture:Texture;
			if (this._numTextures == 1)
			{
				texture = this._textures[0];
				if (this._useColor)
				{
					if (texture.format == Context3DTextureFormat.COMPRESSED)
					{
						if (texture.premultipliedAlpha)
						{
							if (programColorTextureCompressedPMA == null)
							{
								programColorTextureCompressedPMA = createProgramWithTexture(this._useColor, texture);
							}
							this._program = programColorTextureCompressedPMA;
						}
						else
						{
							if (programColorTextureCompressed == null)
							{
								programColorTextureCompressed = createProgramWithTexture(this._useColor, texture);
							}
							this._program = programColorTextureCompressed;
						}
					}
					else if (texture.format == Context3DTextureFormat.COMPRESSED_ALPHA)
					{
						if (texture.premultipliedAlpha)
						{
							if (programColorTextureCompressedAlphaPMA == null)
							{
								programColorTextureCompressedAlphaPMA = createProgramWithTexture(this._useColor, texture);
							}
							this._program = programColorTextureCompressedAlphaPMA;
						}
						else
						{
							if (programColorTextureCompressedAlpha == null)
							{
								programColorTextureCompressedAlpha = createProgramWithTexture(this._useColor, texture);
							}
							this._program = programColorTextureCompressedAlpha;
						}
					}
					else
					{
						if (texture.premultipliedAlpha)
						{
							if (programColorTextureDefaultPMA == null)
							{
								programColorTextureDefaultPMA = createProgramWithTexture(this._useColor, texture);
							}
							this._program = programColorTextureDefaultPMA;
						}
						else
						{
							if (programColorTextureDefault == null)
							{
								programColorTextureDefault = createProgramWithTexture(this._useColor, texture);
							}
							this._program = programColorTextureDefault;
						}
					}
				}
				else
				{
					if (texture.format == Context3DTextureFormat.COMPRESSED)
					{
						if (texture.premultipliedAlpha)
						{
							if (programNoColorTextureCompressedPMA == null)
							{
								programNoColorTextureCompressedPMA = createProgramWithTexture(this._useColor, texture);
							}
							this._program = programNoColorTextureCompressedPMA;
						}
						else
						{
							if (programNoColorTextureCompressed == null)
							{
								programNoColorTextureCompressed = createProgramWithTexture(this._useColor, texture);
							}
							this._program = programNoColorTextureCompressed;
						}
					}
					else if (texture.format == Context3DTextureFormat.COMPRESSED_ALPHA)
					{
						if (texture.premultipliedAlpha)
						{
							if (programNoColorTextureCompressedAlphaPMA == null)
							{
								programNoColorTextureCompressedAlphaPMA = createProgramWithTexture(this._useColor, texture);
							}
							this._program = programNoColorTextureCompressedAlphaPMA;
						}
						else
						{
							if (programNoColorTextureCompressedAlpha == null)
							{
								programNoColorTextureCompressedAlpha = createProgramWithTexture(this._useColor, texture);
							}
							this._program = programNoColorTextureCompressedAlpha;
						}
					}
					else
					{
						if (texture.premultipliedAlpha)
						{
							if (programNoColorTextureDefaultPMA == null)
							{
								programNoColorTextureDefaultPMA = createProgramWithTexture(this._useColor, texture);
							}
							this._program = programNoColorTextureDefaultPMA;
						}
						else
						{
							if (programNoColorTextureDefault == null)
							{
								programNoColorTextureDefault = createProgramWithTexture(this._useColor, texture);
							}
							this._program = programNoColorTextureDefault;
						}
					}
				}
			}
			else if (this._numTextures > 1)
			{
				this._program = createProgramWithMultiTexture(this._useColor, this._textures);
				this._isMultiTexturingProgram = true;
				
				if (!_isBaseline)
				{
					//fc0
					this._multiTexturingConstants[0] = 0.5;
					this._multiTexturingConstants[1] = 1.5;
					this._multiTexturingConstants[2] = 2.5;
					this._multiTexturingConstants[3] = 3.5;
					if (this._numTextures > 4)
					{
						//fc1
						this._multiTexturingConstants[4] = 4.5;
						this._multiTexturingConstants[5] = 5.5;
						this._multiTexturingConstants[6] = 6.5;
						this._multiTexturingConstants[7] = 7.5;
						if (this._numTextures > 8)
						{
							//fc2
							this._multiTexturingConstants[8] = 8.5;
							this._multiTexturingConstants[9] = 9.5;
							this._multiTexturingConstants[10] = 10.5;
							this._multiTexturingConstants[11] = 11.5;
							if (this._numTextures > 12)
							{
								//fc3
								this._multiTexturingConstants[12] = 12.5;
								this._multiTexturingConstants[13] = 13.5;
								this._multiTexturingConstants[14] = 14.5;
								this._multiTexturingConstants[15] = 15.5;
							}
						}
					}
				}
			}
			else
			{
				if (this._useColor)
				{
					if (programColorNoTexture == null)
					{
						programColorNoTexture = createProgramWithoutTexture(this._useColor);
					}
					this._program = programColorNoTexture;
				}
				else
				{
					if (programNoColorNoTexture == null)
					{
						programNoColorNoTexture = createProgramWithoutTexture(this._useColor);
					}
					this._program = programNoColorNoTexture;
				}
			}
		}
		
		protected function createProgramWithTexture(useColor:Boolean, texture:Texture):Program
		{
			var vertexShader:String;
			var fragmentShader:String;
			
			if (useColor)
			{
				vertexShader = 
				"m44 op, va0, vc0 \n" + // 4x4 matrix transform to output clip-space
				"mov v0, va1      \n" + // pass texture coordinates to fragment program
				"mul v1, va2, vc4 \n";  // multiply alpha (vc4) with color (va2), pass to fp
				fragmentShader = RenderUtil.createAGALTexOperation("ft0", "v0", 0, texture) ; // read texel color
				fragmentShader += "mul oc, ft0, v1  \n";  // multiply color with texel color
			}
			else
			{
				vertexShader = 
				"m44 op, va0, vc0 \n" + // 4x4 matrix transform to output clip-space
				"mov v0, va1      \n" ; // pass texture coordinates to fragment program
				fragmentShader = RenderUtil.createAGALTexOperation("oc", "v0", 0, texture); // output color is texel color
			}
			
			return Program.fromSource(vertexShader, fragmentShader, 2);
		}
		
		protected function createProgramWithMultiTexture(useColor:Boolean, textures:Vector.<Texture>):Program
		{
			var numTextures:int = textures.length;
			var fragmentShader:Vector.<String> = new Vector.<String>();
			var vertexShader:String;
			
			if (useColor)
			{
				vertexShader = 
					"m44 op, va0, vc0\n" +	// 4x4 matrix transform to output clip-space
					"mov v0, va1\n" +		// pass texture coordinates to fragment program
					"mul v1, va2, vc4\n" +	// multiply alpha (vc4) with color (va2), pass to fp
					"mov v2, va3";			// pass texture sampler index to fp
			}
			else
			{
				vertexShader = 
					"m44 op, va0, vc0\n" +	// 4x4 matrix transform to output clip-space
					"mov v0, va1\n" +		// pass texture coordinates to fragment program
					"mov v1, va2";			// pass texture sampler index to fp
			}
			
			if (_isBaseline)
			{
				if (useColor) {
					fragmentShader[fragmentShader.length] = "slt ft4, v2.xxxx, fc0";
				} else {
					fragmentShader[fragmentShader.length] = "slt ft4, v1.xxxx, fc0";
				}
				fragmentShader[fragmentShader.length] = RenderUtil.createAGALTexOperation("ft0", "v0", 0, textures[0]);
				fragmentShader[fragmentShader.length] = "min ft5, ft4.xxxx, ft0";
				
				fragmentShader[fragmentShader.length] = "sub ft6, fc1.xxxx, ft4";
				fragmentShader[fragmentShader.length] = RenderUtil.createAGALTexOperation("ft1", "v0", 1, textures[1]);
				
				if (numTextures > 2)
				{
					fragmentShader[fragmentShader.length] = "min ft6.xyz, ft6.xyz, ft4.yzw";
					fragmentShader[fragmentShader.length] = "min ft0, ft6.xxxx, ft1";
					fragmentShader[fragmentShader.length] = "add ft5, ft5, ft0";
					fragmentShader[fragmentShader.length] = RenderUtil.createAGALTexOperation("ft2", "v0", 2, textures[2]);
					fragmentShader[fragmentShader.length] = "min ft0, ft6.yyyy, ft2";
					
					if (numTextures > 3)
					{
						fragmentShader[fragmentShader.length] = "add ft5, ft5, ft0";
						fragmentShader[fragmentShader.length] = RenderUtil.createAGALTexOperation("ft3", "v0", 3, textures[3]);
						fragmentShader[fragmentShader.length] = "min ft0, ft6.zzzz, ft3";
						
						if (numTextures > 4)
						{
							fragmentShader[fragmentShader.length] = "add ft5, ft5, ft0";
							fragmentShader[fragmentShader.length] = RenderUtil.createAGALTexOperation("ft4", "v0", 4, textures[4]);
							fragmentShader[fragmentShader.length] = "min ft0, ft6.wwww, ft4";
						}
					}
				}
				else
				{
					fragmentShader[fragmentShader.length] = "min ft0, ft6.xxxx, ft1";
				}
				fragmentShader[fragmentShader.length] = "add ft5, ft5, ft0";
				
				if (useColor) {
				fragmentShader[fragmentShader.length] = "mul oc, ft5, v1";	// multiply color with texel color
				} else {
					fragmentShader[fragmentShader.length] = "mov oc, ft5";
				}
			}
			else
			{
				multiTexturing(textures, "ft0", useColor ? "v2.x" : "v1.x", 0, fragmentShader);
				
				if (useColor) {
					fragmentShader[fragmentShader.length] = "mul oc, ft0, v1";	// multiply color with texel color
				} else {
					fragmentShader[fragmentShader.length] = "mov oc, ft0";
				}
			}
			
			return Program.fromSource(vertexShader, fragmentShader.join("\n"), _isBaseline ? 1 : 2);
		}
		
		protected function multiTexturing(textures:Vector.<Texture>, textureRegister:String = "ft0", textureIndexSource:String = "v2.x", constantsStartIndex:int = 0, fragmentShader:Vector.<String> = null):Vector.<String>
		{
			if (fragmentShader == null) fragmentShader = new Vector.<String>();
			multiTex(fragmentShader, textures, textures.length, 0, textureRegister, textureIndexSource, constantsStartIndex);
			return fragmentShader;
		}
		
		protected function multiTex(data:Vector.<String>, textures:Vector.<Texture>, numTextures:int, textureOffset:int, textureRegister:String, textureIndexSource:String, constantsStartIndex:int):void
		{
			if (numTextures <= 2)
			{
				if (numTextures == 2)
				{
					checkTexIndex(data, textureOffset, textureIndexSource, constantsStartIndex);
					data[data.length] = RenderUtil.createAGALTexOperation(textureRegister, "v0", textureOffset, textures[textureOffset]);
					data[data.length] = "els";
					data[data.length] = RenderUtil.createAGALTexOperation(textureRegister, "v0", textureOffset + 1, textures[textureOffset + 1]);
					data[data.length] = "eif";
				}
				else
				{
					data[data.length] = RenderUtil.createAGALTexOperation(textureRegister, "v0", textureOffset, textures[textureOffset]);
				}
			}
			else
			{
				var halfNumTextures:int = MathUtils.ceil(numTextures / 2);
				var remainingTextures:int = numTextures - halfNumTextures;
				
				checkTexIndex(data, textureOffset + halfNumTextures - 1, textureIndexSource, constantsStartIndex);
				multiTex(data, textures, halfNumTextures, textureOffset, textureRegister, textureIndexSource, constantsStartIndex);
				data[data.length] = "els";
				multiTex(data, textures, remainingTextures, textureOffset + halfNumTextures, textureRegister, textureIndexSource, constantsStartIndex);
				data[data.length] = "eif";
			}
		}
		
		protected function checkTexIndex(data:Vector.<String>, textureNum:int, textureIndexSource:String, constantsStartIndex:int):void
		{
			var constantIndex:int = constantsStartIndex + MathUtils.floor(textureNum / 4);
			var constantSubIndex:int = textureNum % 4;
			var constant:String;
			
			switch (constantSubIndex)
			{
				case 0 :
					constant = " fc" + constantIndex + ".x";
					break;
				
				case 1 :
					constant = " fc" + constantIndex + ".y";
					break;
				
				case 2 :
					constant = " fc" + constantIndex + ".z";
					break;
				
				case 3 :
					constant = " fc" + constantIndex + ".w";
					break;
				
				default :
					throw new Error("incorrect constant sub index");
			}
			
			data[data.length] = "ifl " + textureIndexSource + constant;
		}
		
		protected function createProgramWithoutTexture(useColor:Boolean):Program
		{
			var vertexShader:String;
			var fragmentShader:String;
			
			if (useColor)
			{
				vertexShader = 
				"m44 op, va0, vc0 \n" + // 4x4 matrix transform to output clip-space
				"mul v0, va1, vc4 \n";  // multiply alpha (vc4) with color (va1)
				fragmentShader =
				"mov oc, v0";       // output color
			}
			else
			{
				vertexShader = 
				"m44 op, va0, vc0 \n" + // 4x4 matrix transform to output clip-space
				"sge v0, va0, va0" ; // this is a hack that always produces "1"
				fragmentShader =
				"mov oc, v0";       // output color
			}
			
			return Program.fromSource(vertexShader, fragmentShader);
		}
		
		protected function updateTextures():void
		{
			this._numTextures = this._textures.length;
			this._multiTexturing = this._numTextures > 1;
			this._renderData.multiTexturing = this._multiTexturing;
			
			updateElements();
			if (this._buffersCreated) updateBuffers();
			updateData();
			if (this._program != null) updateProgram();
		}
		
		/**
		 * Adds specified layer on top of other existing layers
		 * @param	layer
		 */
		public function addLayer(layer:MassiveLayer):void
		{
			layer.display = this;
			this._layers.push(layer);
		}
		
		/**
		 * Adds specified layer at specified index
		 * @param	layer
		 * @param	index
		 */
		public function addLayerAt(layer:MassiveLayer, index:int):void
		{
			layer.display = this;
			this._layers.insertAt(index, layer);
		}
		
		/**
		 * Returns layer with specified name, or null if no layer with that name is found
		 * @param	name
		 * @return
		 */
		public function getLayer(name:String):MassiveLayer
		{
			this._numLayers = this._layers.length;
			for (var i:int = 0; i < this._numLayers; i++)
			{
				if (this._layers[i].name == name) return this._layers[i];
			}
			return null;
		}
		
		/**
		 * Returns layer at specified index
		 * @param	index
		 * @return
		 */
		public function getLayerAt(index:int):MassiveLayer
		{
			return this._layers[index];
		}
		
		/**
		 * Removes all layers, optionally disposing them and/or pooling their data
		 * @param	dispose
		 * @param	poolDatas
		 */
		public function removeAllLayers(dispose:Boolean = true, poolDatas:Boolean = true):void
		{
			this._numLayers = this._layers.length;
			for (var i:int = 0; i < this._numLayers; i++)
			{
				this._layers[i].display = null;
				if (dispose)
				{
					this._layers[i].dispose(poolDatas);
				}
				else if (poolDatas)
				{
					this._layers[i].removeAllData(poolDatas);
				}
			}
			this._layers.length = 0;
		}
		
		/**
		 * Removes specified layer, optionnally disposing it
		 * @param	layer
		 * @param	dispose
		 * @return
		 */
		public function removeLayer(layer:MassiveLayer, dispose:Boolean = false):MassiveLayer
		{
			this._layers.removeAt(this._layers.indexOf(layer))
			layer.display = null;
			if (dispose) layer.dispose();
			return layer;
		}
		
		public function removeLayerAt(index:int, dispose:Boolean = false):MassiveLayer
		{
			var layer:MassiveLayer = this._layers[index];
			this._layers.removeAt(index);
			layer.display = null;
			if (dispose) layer.dispose();
			return layer;
		}
		
		public function removeLayerWithName(name:String, dispose:Boolean = false):MassiveLayer
		{
			var layer:MassiveLayer;
			this._numLayers = this._layers.length;
			for (var i:int = 0; i < this._numLayers; i++)
			{
				if (this._layers[i].name == name)
				{
					return removeLayerAt(i, dispose);
				}
			}
			return null;
		}
		
		public function advanceTime(time:Number):void
		{
			if (this.animate)
			{
				this._numLayers = this._layers.length;
				for (var i:int = 0; i < this._numLayers; i++)
				{
					if (this._layers[i].animate) this._layers[i].advanceTime(time);
				}
			}
			
			setRequiresRedraw();
		}
		
		override public function render(painter:Painter):void 
		{
			this._numLayers = this._layers.length;
			if (this._numLayers == 0) return;
			
			painter.excludeFromCache(this);
			
			var context:Context3D = Starling.context;
			if (context == null)
			{
				throw new MissingContextError();
			}
			
			var i:int;
			
			painter.finishMeshBatch();
			
			painter.setupContextDefaults();
			painter.state.blendMode = this.blendMode;
			painter.prepareToDraw();
			
			var alpha:Number = painter.state.alpha * this.alpha;
			if (this._useColor)
			{
				if (this._pma)
				{
					this._byteColor.position = 0;
					this._byteColor.writeFloat(this._red * alpha);
					this._byteColor.writeFloat(this._green * alpha);
					this._byteColor.writeFloat(this._blue * alpha);
					this._byteColor.writeFloat(alpha);
				}
				else
				{
					this._byteColor.position = 12;
					this._byteColor.writeFloat(alpha);
				}
				context.setProgramConstantsFromByteArray(Context3DProgramType.VERTEX, this._colorOffset, 1, this._byteColor, 0);
			}
			
			this._program.activate(context);
			for (i = 0; i < this._numTextures; i++)
			{
				context.setTextureAt(i, this._textures[i].base);
				RenderUtil.setSamplerStateAt(0, this._textures[i].mipMapping, this._textureSmoothing, this._textureRepeat);
			}
			
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, painter.state.mvpMatrix3D, true);
			
			if (this._multiTexturing)
			{
				context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _multiTexturingConstants, -1);
			}
			
			var forceBuffer:Boolean = true;
			var boundsData:Vector.<Number> = this._autoUpdateBounds ? this._boundsData : null;
			if (boundsData != null) boundsData.length = 0;
			
			var layerDone:Boolean;
			var layerIndex:int = 0;
			this._renderData.clear();
			
			if (this._useByteArray)
			{
				if (this._useByteArrayDomainMemory)
				{
					var prevByteArray:ByteArray = ApplicationDomain.currentDomain.domainMemory;
					ApplicationDomain.currentDomain.domainMemory = this._byteData;
					while (layerIndex < this._numLayers)
					{
						if (!this._layers[layerIndex].visible) continue;
						layerDone = this._layers[layerIndex].writeDataBytesMemory(this._bufferSize - this._renderData.numQuads, this.renderOffsetX, this.renderOffsetY, this._pma, this._useColor, this._simpleColorMode, this._renderData, boundsData);
						if (this._renderData.numQuads == this._bufferSize)
						{
							nextBuffer(context, forceBuffer);
							forceBuffer = false;
							this._vertexBuffer.uploadFromByteArray(this._byteData, 0, 0, this._renderData.numQuads * MassiveConstants.VERTICES_PER_QUAD);
							context.drawTriangles(this._indexBuffer, 0, this._renderData.numQuads * 2);
							this._renderData.render();
							++painter.drawCount;
						}
						if (layerDone) ++layerIndex;
					}
					if (this._renderData.numQuads != 0)
					{
						nextBuffer(context, forceBuffer);
						forceBuffer = false;
						this._vertexBuffer.uploadFromByteArray(this._byteData, 0, 0, this._renderData.numQuads * MassiveConstants.VERTICES_PER_QUAD);
						context.drawTriangles(this._indexBuffer, 0, this._renderData.numQuads * 2);
						this._renderData.render();
						++painter.drawCount;
					}
					ApplicationDomain.currentDomain.domainMemory = prevByteArray;
				}
				else
				{
					this._byteData.position = 0;
					while (layerIndex < this._numLayers)
					{
						if (!this._layers[layerIndex].visible) continue;
						layerDone = this._layers[layerIndex].writeDataBytes(this._byteData, this._bufferSize - this._renderData.numQuads, this.renderOffsetX, this.renderOffsetY, this._pma, this._useColor, this._simpleColorMode, this._renderData, boundsData);
						if (this._renderData.numQuads == this._bufferSize)
						{
							nextBuffer(context, forceBuffer);
							forceBuffer = false;
							this._vertexBuffer.uploadFromByteArray(this._byteData, 0, 0, this._renderData.numQuads * MassiveConstants.VERTICES_PER_QUAD);
							context.drawTriangles(this._indexBuffer, 0, this._renderData.numQuads * 2);
							this._renderData.render();
							++painter.drawCount;
						}
						if (layerDone) ++layerIndex;
					}
					if (this._renderData.numQuads != 0)
					{
						nextBuffer(context, forceBuffer);
						forceBuffer = false;
						this._vertexBuffer.uploadFromByteArray(this._byteData, 0, 0, this._renderData.numQuads * MassiveConstants.VERTICES_PER_QUAD);
						context.drawTriangles(this._indexBuffer, 0, this._renderData.numQuads * 2);
						this._renderData.render();
						++painter.drawCount;
					}
				}
			}
			else
			{
				while (layerIndex < this._numLayers)
				{
					if (!this._layers[layerIndex].visible) continue;
					layerDone = this._layers[layerIndex].writeDataVector(this._vectorData, this._bufferSize - this._renderData.numQuads, this.renderOffsetX, this.renderOffsetY, this._pma, this._useColor, this._simpleColorMode, this._renderData, boundsData);
					if (this._renderData.numQuads == this._bufferSize)
					{
						nextBuffer(context, forceBuffer);
						forceBuffer = false;
						this._vertexBuffer.uploadFromVector(this._vectorData, 0, this._renderData.numQuads * MassiveConstants.VERTICES_PER_QUAD);
						context.drawTriangles(this._indexBuffer, 0, this._renderData.numQuads * 2);
						this._renderData.render();
						++painter.drawCount;
					}
					if (layerDone) ++layerIndex;
				}
				if (this._renderData.numQuads != 0)
				{
					nextBuffer(context, forceBuffer);
					forceBuffer = false;
					this._vertexBuffer.uploadFromVector(this._vectorData, 0, this._renderData.numQuads * MassiveConstants.VERTICES_PER_QUAD);
					context.drawTriangles(this._indexBuffer, 0, this._renderData.numQuads * 2);
					this._renderData.render();
					++painter.drawCount;
				}
			}
			
			this._numQuads = this._renderData.totalQuads;
			if (this._autoUpdateBounds) updateExactBounds();
			
			//for (i = this._contextBufferIndex - 1; i > -1; i--)
			for (i = this._contextBufferIndex; i > -1; i--)
			{
				context.setVertexBufferAt(i, null);
			}
			
			for (i = 0; i < this._numTextures; i++)
			{
				context.setTextureAt(i, null);
			}
		}
		
		protected function nextBuffer(context:Context3D, forced:Boolean = false):void
		{
			var prevBuffer:VertexBuffer3D = this._vertexBuffer;
			this._vertexBufferIndex = ++this._vertexBufferIndex % this._numBuffers;
			this._vertexBuffer = this._vertexBuffers[this._vertexBufferIndex];
			
			if (forced || this._vertexBuffer != prevBuffer)
			{
				this._contextBufferIndex = -1;
				context.setVertexBufferAt(++this._contextBufferIndex, this._vertexBuffer, this._positionOffset, Context3DVertexBufferFormat.FLOAT_2);
				if (this._numTextures > 0)
				{
					context.setVertexBufferAt(++this._contextBufferIndex, this._vertexBuffer, this._uvOffset, Context3DVertexBufferFormat.FLOAT_2);
				}
				
				if (this._useColor)
				{
					if (this._simpleColorMode)
					{
						context.setVertexBufferAt(++this._contextBufferIndex, this._vertexBuffer, this._colorOffset, Context3DVertexBufferFormat.BYTES_4);
					}
					else
					{
						context.setVertexBufferAt(++this._contextBufferIndex, this._vertexBuffer, this._colorOffset, Context3DVertexBufferFormat.FLOAT_4);
					}
				}
				
				if (this._multiTexturing)
				{
					context.setVertexBufferAt(++this._contextBufferIndex, this._vertexBuffer, this._textureOffset, Context3DVertexBufferFormat.FLOAT_1);
				}
			}
		}
		
		override public function getBounds(targetSpace:DisplayObject, out:Rectangle = null):Rectangle 
		{
			if (targetSpace == this || targetSpace == null)
			{
				if (this.boundsRect != null)
				{
					if (out == null)
					{
						return this.boundsRect;
					}
					else
					{
						out.copyFrom(this.boundsRect);
						return out;
					}
				}
				else if (this.stage != null)
				{
					// return full stage size to support filters ... may be expensive, but we have no other options, do we?
					if (out == null) out = new Rectangle();
					out.setTo(0, 0, this.stage.stageWidth, this.stage.stageHeight);
					return out;
				}
				else
				{
					getTransformationMatrix(targetSpace, _helperMatrix);
					MatrixUtil.transformCoords(_helperMatrix, 0, 0, _helperPoint);
					if (out == null) out = new Rectangle();
					out.setTo(_helperPoint.x, _helperPoint.y, 0, 0);
					return out;
				}
			}
			else if (targetSpace != null)
			{
				if (out == null) out = new Rectangle();
				
				if (this.boundsRect != null)
				{
					getTransformationMatrix(targetSpace, _helperMatrix);
					MatrixUtil.transformCoords(_helperMatrix, this.boundsRect.x, this.boundsRect.y, _helperPoint);
					out.x = _helperPoint.x;
					out.y = _helperPoint.y;
					MatrixUtil.transformCoords(_helperMatrix, this.boundsRect.width, this.boundsRect.height, _helperPoint);
					out.width = _helperPoint.x;
					out.height = _helperPoint.y;
				}
				else if (this.stage != null)
				{
					// return full stage size to support filters ... may be pretty expensive
					out.setTo(0, 0, stage.stageWidth, stage.stageHeight);
				}
				else
				{
					getTransformationMatrix(targetSpace, _helperMatrix);
					MatrixUtil.transformCoords(_helperMatrix, 0, 0, _helperPoint);
					out.setTo(_helperPoint.x, _helperPoint.y, 0, 0);
				}
				
				return out;
			}
			else
			{
				return out == null ? new Rectangle() : out;
			}
		}
		
		/**
		 * call this before calling updateExactBounds if needed. This does *NOT* render anything
		 */
		public function writeBoundsData():void
		{
			this._boundsData.length = 0;
			this._renderData.clear();
			this._numLayers = this._layers.length;
			
			for (var i:int = 0; i < this._numLayers; i++)
			{
				if (!this._layers[i].visible) continue;
				this._layers[i].writeBoundsData(this._boundsData, this._renderData, this.renderOffsetX, this.renderOffsetY);
			}
			
			this._numQuads = this._renderData.totalQuads;
		}
		
		/**
		 * Calculates exact bounds for this MassiveDisplay instance and stores it in boundsRect
		 * Caution : this can be really expensive !
		 */
		public function updateExactBounds():void
		{
			if (this.boundsRect == null) this.boundsRect = new Rectangle();
			
			if (this._numQuads == 0)
			{
				this.boundsRect.x = this.x;
				this.boundsRect.y = this.y;
				this.boundsRect.width = 0;
				this.boundsRect.height = 0;
				return;
			}
			
			var pos:int = -1;
			
			var minX:Number = Number.MAX_VALUE;
			var maxX:Number = Number.MIN_VALUE;
			var minY:Number = Number.MAX_VALUE;
			var maxY:Number = Number.MIN_VALUE;
			
			var tX:Number;
			var tY:Number;
			
			for (var i:int = 0; i < this._numQuads; i++)
			{
				for (var j:int = 0; j < this._numQuads; j++)
				{
					tX = this._boundsData[++pos];
					tY = this._boundsData[++pos];
					
					if (minX > tX) minX = tX;
					if (maxX < tX) maxX = tX;
					if (minY > tY) minY = tY;
					if (maxY < tY) maxY = tY;
				}
			}
			
			this.boundsRect.setTo(this.x + minX - this.renderOffsetX, this.y + minY - this.renderOffsetY, maxX - minX, maxY - minY);
		}
		
	}

}