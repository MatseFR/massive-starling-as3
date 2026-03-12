package 
{
	import flash.filesystem.File;
	import massive.display.MassiveColorMode;
	import massive.display.MassiveDisplay;
	import massive.display.MassiveRenderMode;
	import massive.utils.LookUp;
	import massive.utils.MathUtils;
	import scene.ClassicClips;
	import scene.ClassicQuads;
	import scene.MassiveImages;
	import scene.MassiveQuads;
	import scene.Scene;
	import starling.assets.AssetManager;
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.Mesh;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.ResizeEvent;
	import starling.styles.MeshStyle;
	import starling.styles.MultiTextureStyle;
	import starling.text.BitmapFont;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.textures.ConcreteTexture;
	import starling.textures.RenderTexture;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	/**
	 * ...
	 * @author Matse
	 */
	public class MassiveDemo extends Sprite 
	{
		static public var assetManager:AssetManager;
		
		private var _sceneList:Vector.<Scene>;
		
		private var _allButtons:Vector.<Button> = new Vector.<Button>();
		private var _allTextFields:Vector.<TextField> = new Vector.<TextField>();
		
		private var menuSprite:Sprite;
		private var atlasSprite:Sprite;
		private var scaleSprite:Sprite;
		private var colorModeSprite:Sprite;
		private var renderModeSprite:Sprite;
		private var maxTextureSprite:Sprite;
		private var classicSprite:Sprite;
		private var massiveSprite:Sprite;
		
		private var demoMenuSprite:Sprite;
		private var movementButton:Button;
		private var animationButton:Button;
		private var autoUpdateBoundsButton:Button;
		
		private var atlasIDs:Vector.<String> = new Vector.<String>();
		private var atlases:Vector.<TextureAtlas> = new Vector.<TextureAtlas>();
		private var textures:Vector.<Vector.<Texture>> = new Vector.<Vector.<Texture>>();
		
		private var animation:Boolean = true;
		private var autoUpdateBounds:Boolean = false;
		private var colorMode:String;
		private var displayScale:Number = 1.0;
		private var frameDeltaBase:Number;
		private var frameDeltaVariance:Number;
		private var frameRateBase:int;
		private var frameRateVariance:int;
		private var movement:Boolean = true;
		private var multiTextureStyle:Boolean = false;
		private var numObjects:int;
		private var renderMode:String;
		private var useBlurFilter:Boolean = false;
		private var useRandomAlpha:Boolean = false;
		private var useRandomColor:Boolean = false;
		private var useRandomRotation:Boolean = true;
		private var useSprite3D:Boolean = false;
		
		private var buttonTextureON:RenderTexture;
		private var buttonTextureOFF:RenderTexture;
		private var menuButtonTextureON:RenderTexture;
		private var menuButtonTextureOFF:RenderTexture;
		private var mediumButtonTextureON:RenderTexture;
		private var mediumButtonTextureOFF:RenderTexture;
		private var miniButtonTextureON:RenderTexture;
		private var miniButtonTextureOFF:RenderTexture;
		
		private var atlasButtons:Vector.<Button> = new Vector.<Button>();
		private var scaleButtons:Vector.<Button> = new Vector.<Button>();
		private var colorModeButtons:Vector.<Button> = new Vector.<Button>();
		private var renderModeButtons:Vector.<Button> = new Vector.<Button>();
		private var maxTextureButtons:Vector.<Button> = new Vector.<Button>();
		private var classicClipsButtons:Vector.<Button> = new Vector.<Button>();
		
		private var numAtlases:int = 16;
		private var numClips:Vector.<int> = Vector.<int>([1000, 2000, 4000, 8000, 16000, 32000, 64000, 128000, 256000, 512000]);
		private var numQuads:Vector.<int> = Vector.<int>([8000, 16000, 32000, 64000, 128000, 256000, 512000]);
		private var scales:Vector.<Number> = Vector.<Number>([2.0, 1.0, 0.5, 0.2, 0.1]);
		
		private var maxClipsWithoutMultiTextureStyle:int = 2000;
		
		private var maxTextures:int;
		
		public function MassiveDemo() 
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			this.colorMode = MassiveDisplay.defaultColorMode;
			this.renderMode = MassiveDisplay.defaultRenderMode;
		}
		
		private function addedToStageHandler(evt:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			
			MassiveDisplay.init();
			this.maxTextures = MassiveDisplay.maxNumTextures;
			LookUp.init();
			
			this.stage.color = 0x333333;
			
			assetManager = new AssetManager();
			//assetManager.verbose = Capabilities.isDebugger;
			assetManager.enqueue(File.applicationDirectory.resolvePath("assets/img"));
			assetManager.loadQueue(assetsLoaded);
		}
		
		private function assetsLoaded():void
		{
			trace("assetsLoaded");
			
			this.multiTextureStyle = Mesh.defaultStyle == MultiTextureStyle;
			
			var btnHeight:Number = 19;
			
			var colorUP:int = 0xcccccc;
			var colorOVER:int = 0xffffff;
			var quad:Quad = new Quad(230, btnHeight);
			var menuQuad:Quad = new Quad(140, btnHeight);
			var mediumQuad:Quad = new Quad(90, btnHeight);
			var miniQuad:Quad = new Quad(36, btnHeight);
			
			quad.color = colorUP;
			this.buttonTextureOFF = new RenderTexture(int(quad.width), int(quad.height));
			this.buttonTextureOFF.draw(quad);
			this.buttonTextureOFF.root.onRestore = function(tex:ConcreteTexture):void
			{
				quad.color = colorUP;
				this.buttonTextureOFF.clear();
				this.buttonTextureOFF.draw(quad);
			}
			
			quad.color = colorOVER;
			this.buttonTextureON = new RenderTexture(int(quad.width), int(quad.height));
			this.buttonTextureON.draw(quad);
			this.buttonTextureON.root.onRestore = function(tex:ConcreteTexture):void
			{
				quad.color = colorOVER;
				this.buttonTextureON.clear();
				this.buttonTextureON.draw(quad);
			}
			
			menuQuad.color = colorUP;
			this.menuButtonTextureOFF = new RenderTexture(int(menuQuad.width), int(menuQuad.height));
			this.menuButtonTextureOFF.draw(menuQuad);
			this.menuButtonTextureOFF.root.onRestore = function(tex:ConcreteTexture):void
			{
				menuQuad.color = colorUP;
				this.menuButtonTextureOFF.clear();
				this.menuButtonTextureOFF.draw(menuQuad);
			}
			
			menuQuad.color = colorOVER;
			this.menuButtonTextureON = new RenderTexture(int(menuQuad.width), int(menuQuad.height));
			this.menuButtonTextureON.draw(menuQuad);
			this.menuButtonTextureON.root.onRestore = function(tex:ConcreteTexture):void
			{
				menuQuad.color = colorOVER;
				this.menuButtonTextureON.clear();
				this.menuButtonTextureON.draw(menuQuad);
			}
			
			mediumQuad.color = colorUP;
			this.mediumButtonTextureOFF = new RenderTexture(int(mediumQuad.width), int(mediumQuad.height));
			this.mediumButtonTextureOFF.draw(mediumQuad);
			this.mediumButtonTextureOFF.root.onRestore = function(tex:ConcreteTexture):void
			{
				mediumQuad.color = colorUP;
				this.mediumButtonTextureOFF.clear();
				this.mediumButtonTextureOFF.draw(mediumQuad);
			}
			
			mediumQuad.color = colorOVER;
			this.mediumButtonTextureON = new RenderTexture(int(mediumQuad.width), int(mediumQuad.height));
			this.mediumButtonTextureON.draw(mediumQuad);
			this.mediumButtonTextureON.root.onRestore = function(tex:ConcreteTexture):void
			{
				mediumQuad.color = colorOVER;
				this.mediumButtonTextureON.clear();
				this.mediumButtonTextureON.draw(mediumQuad);
			}
			
			miniQuad.color = colorUP;
			this.miniButtonTextureOFF = new RenderTexture(int(miniQuad.width), int(miniQuad.height));
			this.miniButtonTextureOFF.draw(miniQuad);
			this.miniButtonTextureOFF.root.onRestore = function(tex:ConcreteTexture):void
			{
				miniQuad.color = colorUP;
				this.miniButtonTextureOFF.clear();
				this.miniButtonTextureOFF.draw(miniQuad);
			}
			
			miniQuad.color = colorOVER;
			this.miniButtonTextureON = new RenderTexture(int(miniQuad.width), int(miniQuad.height));
			this.miniButtonTextureON.draw(miniQuad);
			this.miniButtonTextureON.root.onRestore = function(tex:ConcreteTexture):void
			{
				miniQuad.color = colorOVER;
				this.miniButtonTextureON.clear();
				this.miniButtonTextureON.draw(miniQuad);
			}
			
			var btn:Button = null;
			var tf:TextField;
			var gap:Number = 2;
			var tX:Number;
			var tY:Number = 0;
			var demoY:Number;
			var demoGap:Number = 64;
			
			this.menuSprite = new Sprite();
			
			tf = createTextField("Options");
			tf.y = tY;
			tf.x = (this.buttonTextureOFF.width - tf.width) / 2;
			this.menuSprite.addChild(tf);
			tY += tf.height + gap;
			
			this.atlasSprite = new Sprite();
			this.atlasSprite.y = tY;
			this.menuSprite.addChild(this.atlasSprite);
			tf = createTextField("atlas(es)");
			tf.y = (btnHeight * 2 + gap - tf.height) / 2;
			this.atlasSprite.addChild(tf);
			tX = tf.width + gap;
			tY = 0;
			
			var atlasID:String;
			for (i = 0; i < this.numAtlases; i++)
			{
				if (i == 8)
				{
					tX = tf.width + gap;
					tY += btnHeight + gap;
				}
				atlasID = "zombi" + i;
				btn = createButton(this.atlasIDs.indexOf(atlasID) != -1 ? this.mediumButtonTextureON : this.mediumButtonTextureOFF, atlasID, null, this.mediumButtonTextureON);
				btn.x = tX;
				btn.y = tY;
				btn.addEventListener(Event.TRIGGERED, toggleAtlas);
				this.atlasButtons.push(btn);
				this.atlasSprite.addChild(btn);
				tX += btn.width + gap;
			}
			
			this.atlasSprite.x = (this.buttonTextureOFF.width - this.atlasSprite.width) / 2;
			
			tY = this.atlasSprite.y + this.atlasSprite.height + gap;
			btn = createButton(this.useRandomAlpha ? this.buttonTextureON : this.buttonTextureOFF, "randomize alpha", null, this.buttonTextureON);
			btn.y = tY;
			btn.addEventListener(Event.TRIGGERED, toggleRandomAlpha);
			this.menuSprite.addChild(btn);
			
			tY += btnHeight + gap;
			btn = createButton(this.useRandomColor ? this.buttonTextureON : this.buttonTextureOFF, "randomize color", null, this.buttonTextureON);
			btn.y = tY;
			btn.addEventListener(Event.TRIGGERED, toggleRandomColor);
			this.menuSprite.addChild(btn);
			
			tY += btnHeight + gap;
			btn = createButton(this.useRandomRotation ? this.buttonTextureON : this.buttonTextureOFF, "randomize rotation", null, this.buttonTextureON);
			btn.y = tY;
			btn.addEventListener(Event.TRIGGERED, toggleRandomRotation);
			this.menuSprite.addChild(btn);
			
			tY += btnHeight + gap;
			this.scaleSprite = new Sprite();
			this.scaleSprite.y = tY;
			this.menuSprite.addChild(this.scaleSprite);
			tf = createTextField("scale");
			tf.y = (btnHeight - tf.height) / 2;
			this.scaleSprite.addChild(tf);
			tX = tf.width + gap;
			
			var scaleFactor:Number;
			for (i = 0; i < this.scales.length; i++)
			{
				scaleFactor = this.scales[i];
				
				btn = createButton(this.displayScale == scaleFactor ? this.miniButtonTextureON : this.miniButtonTextureOFF, scaleFactor.toString(), null, this.miniButtonTextureON);
				btn.x = tX;
				btn.y = tf.y + (tf.height - btnHeight) / 2;
				btn.addEventListener(Event.TRIGGERED, toggleDisplayScale);
				this.scaleButtons.push(btn);
				this.scaleSprite.addChild(btn);
				tX += btn.width + gap;
			}
			
			tY += btnHeight + gap;
			btn = createButton(this.useSprite3D ? this.buttonTextureON : this.buttonTextureOFF, "Sprite3D", null, this.buttonTextureON);
			btn.y = tY;
			btn.addEventListener(Event.TRIGGERED, toggleSprite3D);
			this.menuSprite.addChild(btn);
			
			tY += btnHeight + gap;
			btn = createButton(this.useBlurFilter ? this.buttonTextureON : this.buttonTextureOFF, "BlurFilter", null, this.buttonTextureON);
			btn.y = tY;
			btn.addEventListener(Event.TRIGGERED, toggleBlurFilter);
			this.menuSprite.addChild(btn);
			
			this.scaleSprite.x = (this.buttonTextureOFF.width - this.scaleSprite.width) / 2;
			
			tY += btnHeight + gap * 2;
			tf = createTextField("Massive options");
			tf.y = tY;
			tf.x = (this.buttonTextureOFF.width - tf.width) / 2;
			this.menuSprite.addChild(tf);
			tY += tf.height + gap;
			
			this.renderModeSprite = new Sprite();
			this.renderModeSprite.y = tY;
			this.menuSprite.addChild(this.renderModeSprite);
			tf = createTextField("renderMode");
			tf.y = (btnHeight - tf.height) / 2;
			this.renderModeSprite.addChild(tf);
			tX = tf.width + gap;
			
			btn = createButton(this.renderMode == MassiveRenderMode.BYTEARRAY ? this.buttonTextureON : this.buttonTextureOFF, "ByteArray", null, this.buttonTextureON);
			btn.x = tX;
			btn.y = tf.y + (tf.height - btnHeight) / 2;
			btn.addEventListener(Event.TRIGGERED, toggleRenderMode);
			this.renderModeButtons.push(btn);
			this.renderModeSprite.addChild(btn);
			
			tX += btn.width + gap;
			btn = createButton(this.renderMode == MassiveRenderMode.BYTEARRAY_DOMAIN_MEMORY ? this.buttonTextureON : this.buttonTextureOFF, "DomainMemoryByteArray", null, this.buttonTextureON);
			btn.x = tX;
			btn.y = tf.y + (tf.height - btnHeight) / 2;
			btn.addEventListener(Event.TRIGGERED, toggleRenderMode);
			this.renderModeButtons.push(btn);
			this.renderModeSprite.addChild(btn);
			
			tX += btn.width + gap;
			btn = createButton(this.renderMode == MassiveRenderMode.VECTOR ? this.buttonTextureON : this.buttonTextureOFF, "Vector", null, this.buttonTextureON);
			btn.x = tX;
			btn.y = tf.y + (tf.height - btnHeight) / 2;
			btn.addEventListener(Event.TRIGGERED, toggleRenderMode);
			this.renderModeButtons.push(btn);
			this.renderModeSprite.addChild(btn);
			
			this.renderModeSprite.x = (this.buttonTextureOFF.width - this.renderModeSprite.width) / 2;
			
			tY += btnHeight + gap;
			this.colorModeSprite = new Sprite();
			this.colorModeSprite.y = tY;
			this.menuSprite.addChild(this.colorModeSprite);
			tf = createTextField("colorMode");
			tf.y = (btnHeight - tf.height) / 2;
			this.colorModeSprite.addChild(tf);
			tX = tf.width + gap;
			
			btn = createButton(this.colorMode == MassiveColorMode.NONE ? this.mediumButtonTextureON : this.mediumButtonTextureOFF, "none", null, this.mediumButtonTextureON);
			btn.x = tX;
			btn.y = tf.y + (tf.height - btnHeight) / 2;
			btn.addEventListener(Event.TRIGGERED, toggleColorMode);
			this.colorModeButtons.push(btn);
			this.colorModeSprite.addChild(btn);
			
			tX += btn.width + gap;
			btn = createButton(this.colorMode == MassiveColorMode.REGULAR ? this.mediumButtonTextureON : this.mediumButtonTextureOFF, "regular", null, this.mediumButtonTextureON);
			btn.x = tX;
			btn.y = tf.y + (tf.height - btnHeight) / 2;
			btn.addEventListener(Event.TRIGGERED, toggleColorMode);
			this.colorModeButtons.push(btn);
			this.colorModeSprite.addChild(btn);
			
			tX += btn.width + gap;
			btn = createButton(this.colorMode == MassiveColorMode.EXTENDED ? this.mediumButtonTextureON : this.mediumButtonTextureOFF, "extended", null, this.mediumButtonTextureON);
			btn.x = tX;
			btn.y = tf.y + (tf.height - btnHeight) / 2;
			btn.addEventListener(Event.TRIGGERED, toggleColorMode);
			this.colorModeButtons.push(btn);
			this.colorModeSprite.addChild(btn);
			
			this.colorModeSprite.x = (this.buttonTextureOFF.width - this.colorModeSprite.width) / 2;
			
			tY += btnHeight + gap * 2;
			tf = createTextField("Starling options");
			tf.y = tY;
			tf.x = (this.buttonTextureOFF.width - tf.width) / 2;
			this.menuSprite.addChild(tf);
			tY += tf.height + gap;
			
			btn = createButton(this.multiTextureStyle ? this.buttonTextureON : this.buttonTextureOFF, "MultiTextureStyle", null, this.buttonTextureON);
			btn.y = tY;
			btn.addEventListener(Event.TRIGGERED, toggleMultiTextureStyle);
			this.menuSprite.addChild(btn);
			
			tY += btnHeight + gap;
			this.maxTextureSprite = new Sprite();
			this.maxTextureSprite.y = tY;
			this.menuSprite.addChild(this.maxTextureSprite);
			tf = createTextField("MultiTextureStyle max textures");
			tf.y = (btnHeight * 2 + gap - tf.height) / 2;
			this.maxTextureSprite.addChild(tf);
			tX = tf.width + gap;
			tY = 0;
			
			for (i = 1; i < 17; i++)
			{
				if (i == 9)
				{
					tX = tf.width + gap;
					tY += btnHeight + gap;
				}
				btn = createButton(i == MultiTextureStyle.maxTextures ? this.miniButtonTextureON : this.miniButtonTextureOFF, i.toString(), null, this.miniButtonTextureON);
				btn.enabled = i <= MultiTextureStyle.MAX_NUM_TEXTURES;
				btn.x = tX;
				btn.y = tY;
				btn.addEventListener(Event.TRIGGERED, toggleMultiTextureStyleMaxTexture);
				this.maxTextureSprite.addChild(btn);
				this.maxTextureButtons.push(btn);
				tX += btn.width + gap;
			}
			
			this.maxTextureSprite.x = (this.buttonTextureOFF.width - this.maxTextureSprite.width) / 2;
			tY = this.maxTextureSprite.y + this.maxTextureSprite.height + gap;
			
			demoY = tY + btnHeight + gap * 4;
			
			// CLASSIC STARLING
			this.classicSprite = new Sprite();
			this.classicSprite.y = demoY;
			this.classicSprite.x = -this.buttonTextureOFF.width / 2 - demoGap;
			this.menuSprite.addChild(this.classicSprite);
			tY = 0;
			
			tf = createTextField("Classic Starling");
			tf.y = tY;
			tf.x = (this.buttonTextureOFF.width - tf.width) / 2;
			this.classicSprite.addChild(tf);
			tY += tf.height + gap;
			
			for (i = 0; i < this.numClips.length; i++)
			{
				if (i != 0) tY += btnHeight + gap;
				btn = createButton(this.buttonTextureOFF, this.numClips[i] + " clips", null, this.buttonTextureON);
				btn.y = tY;
				btn.addEventListener(Event.TRIGGERED, classicClips);
				this.classicSprite.addChild(btn);
				this.classicClipsButtons.push(btn);
			}
			
			tY += btn.height + gap * 4;
			
			for (i = 0; i < this.numQuads.length; i++)
			{
				if (i != 0) tY += btnHeight + gap;
				btn = createButton(this.buttonTextureOFF, this.numQuads[i] + " quads", null, this.buttonTextureON);
				btn.y = tY;
				btn.addEventListener(Event.TRIGGERED, classicQuads);
				this.classicSprite.addChild(btn);
			}
			//\CLASSIC STARLING
			
			// MASSIVE STARLING
			this.massiveSprite = new Sprite();
			this.massiveSprite.y = demoY;
			this.massiveSprite.x = this.buttonTextureOFF.width / 2 + demoGap;
			this.menuSprite.addChild(this.massiveSprite);
			tY = 0;
			
			tf = createTextField("Massive Starling");
			tf.y = tY;
			tf.x = (this.buttonTextureOFF.width - tf.width) / 2;
			this.massiveSprite.addChild(tf);
			tY += tf.height + gap;
			
			for (i = 0; i < this.numClips.length; i++)
			{
				if (i != 0) tY += btnHeight + gap;
				btn = createButton(this.buttonTextureOFF, this.numClips[i] + " clips", null, this.buttonTextureON);
				btn.y = tY;
				btn.addEventListener(Event.TRIGGERED, massiveClips);
				this.massiveSprite.addChild(btn);
			}
			
			tY += btn.height + gap * 4;
			
			for (i = 0; i < this.numQuads.length; i++)
			{
				if (i != 0) tY += btnHeight + gap;
				btn = createButton(this.buttonTextureOFF, this.numQuads[i] + " quads", null, this.buttonTextureON);
				btn.y = tY;
				btn.addEventListener(Event.TRIGGERED, massiveQuads);
				this.massiveSprite.addChild(btn);
			}
			//\MASSIVE STARLING
			
			tY = this.massiveSprite.y + this.massiveSprite.height + gap * 4;
			tf = createTextField("zombi assets from www.kenney.nl");
			tf.y = tY;
			tf.x = (this.buttonTextureOFF.width - tf.width) / 2;
			this.menuSprite.addChild(tf);
			
			this.demoMenuSprite = new Sprite();
			
			tY = 0;
			btn = createButton(this.menuButtonTextureOFF, "Menu", null, this.menuButtonTextureON);
			btn.y = tY;
			btn.addEventListener(Event.TRIGGERED, backToMenu);
			this.demoMenuSprite.addChild(btn);
			
			tY += btnHeight + gap * 4;
			btn = createButton(this.movement ? this.menuButtonTextureON : this.menuButtonTextureOFF, "Movement", null, this.menuButtonTextureON);
			btn.y = tY;
			btn.addEventListener(Event.TRIGGERED, toggleMovement);
			this.demoMenuSprite.addChild(btn);
			this.movementButton = btn;
			
			tY += btnHeight + gap;
			btn = createButton(this.animation ? this.menuButtonTextureON : this.menuButtonTextureOFF, "Animation", null, this.menuButtonTextureON);
			btn.y = tY;
			btn.addEventListener(Event.TRIGGERED, toggleAnimation);
			this.demoMenuSprite.addChild(btn);
			this.animationButton = btn;
			
			tY += btnHeight + gap;
			btn = createButton(this.autoUpdateBounds ? this.menuButtonTextureON : this.menuButtonTextureOFF, "autoUpdateBounds", null, this.menuButtonTextureON);
			btn.y = tY;
			btn.addEventListener(Event.TRIGGERED, toggleAutoUpdateBounds);
			this.demoMenuSprite.addChild(btn);
			this.autoUpdateBoundsButton = btn;
			
			this.stage.addEventListener(Event.RESIZE, stageResizeHandler);
			
			var count:int = MathUtils.minInt(this.numAtlases, this.maxTextures);
			for (var i:int = 0; i < count; i++)
			{
				setAtlas("zombi" + i);
			}
			
			updateUIPositions();
			showMenu();
		}
		
		private function createButton(upState:Texture, text:String, downState:Texture, overState:Texture, disabledState:Texture = null):Button
		{
			var btn:Button = new Button(upState, text, downState, overState, disabledState);
			btn.textFormat.setTo("_sans", 12);
			this._allButtons[this._allButtons.length] = btn;
			return btn;
		}
		
		private function createTextField(text:String = ""):TextField
		{
			var tf:TextField = new TextField(0, 0, text);
			tf.format.setTo("_sans", 12, 0xffffff);
			tf.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			tf.batchable = true;
			tf.pixelSnapping = true;
			this._allTextFields[this._allTextFields.length] = tf;
			return tf;
		}
		
		private function stageResizeHandler(evt:ResizeEvent):void
		{
			updateViewPort(evt.width, evt.height);
			updateUIPositions();
			
			if (this._sceneList != null)
			{
				var count:int = this._sceneList.length;
				for (var i:int = 0; i < count; i++)
				{
					this._sceneList[i].updateBounds();
				}
			}
		}
		
		private function updateViewPort(width:int, height:int):void 
		{
			var current:Starling = Starling.current;
			var scale:Number = current.contentScaleFactor;
			
			this.stage.stageWidth  = int(width  / scale);
			this.stage.stageHeight = int(height / scale);
			
			current.viewPort.width  = this.stage.stageWidth  * scale;
			current.viewPort.height = this.stage.stageHeight * scale;
		}
		
		private function updateUIPositions():void
		{
			this.menuSprite.x = (this.stage.stageWidth - this.buttonTextureON.width) / 2;
			this.menuSprite.y = (this.stage.stageHeight - this.menuSprite.height) / 2;
			
			var spacing:Number = 8;
			this.demoMenuSprite.x = this.stage.stageWidth - this.demoMenuSprite.width - spacing;
			this.demoMenuSprite.y = spacing;
		}
		
		private function showMenu():void
		{
			addChild(this.menuSprite);
		}
		
		private function hideMenu():void
		{
			removeChild(this.menuSprite);
		}
		
		private function showSceneList(scenes:Vector.<Scene>):void
		{
			hideMenu();
			
			this._sceneList = scenes;
			for (var i:int; i < this._sceneList.length; i++)
			{
				addChild(this._sceneList[i]);
			}
			
			addChild(this.demoMenuSprite);
		}
		
		private function backToMenu(evt:Event):void
		{
			for (var i:int; i < this._sceneList.length; i++)
			{
				this._sceneList[i].removeFromParent(true);
			}
			this._sceneList = null;
			
			this.demoMenuSprite.removeFromParent();
			
			showMenu();
		}
		
		private function toggleAnimation(evt:Event):void
		{
			var btn:Button = evt.target as Button;
			this.animation = !this.animation;
			if (this._sceneList.length != 0)
			{
				this._sceneList[0].animation = this.animation;
			}
			if (this.animation)
			{
				btn.upState = this.menuButtonTextureON;
			}
			else
			{
				btn.upState = this.menuButtonTextureOFF;
			}
		}
		
		private function toggleAtlas(evt:Event):void
		{
			var btn:Button = evt.target as Button;
			var index:int = this.atlasIDs.indexOf(btn.text);
			if (index == -1)
			{
				if (this.atlases.length < this.maxTextures)
				{
					setAtlas(btn.text);
					//btn.upState = this.miniButtonTextureON;
				}
			}
			else if (this.atlasIDs.length > 1)
			{
				this.atlasIDs.splice(index, 1);
				this.atlases.splice(index, 1);
				this.textures.splice(index, 1);
				btn.upState = this.miniButtonTextureOFF;
				
				updateClassicStarling();
			}
		}
		
		private function setAtlas(id:String):void
		{
			this.atlasIDs.push(id);
			var atlas:TextureAtlas;
			
			switch (id)
			{
				case "bird" :
					atlas = assetManager.getTextureAtlas("starling_bird");
					this.atlases.push(atlas);
					this.textures.push(atlas.getTextures("0"));
					this.frameDeltaBase = 0.05;
					this.frameDeltaVariance = 0.25;
					this.frameRateBase = 3;
					this.frameRateVariance = 15;
					break;
				
				default :
					atlas = assetManager.getTextureAtlas(id);
					this.atlases.push(atlas);
					this.textures.push(atlas.getTextures("character"));
					this.frameDeltaBase = 0.05;
					this.frameDeltaVariance = 0.25;
					this.frameRateBase = 3;
					this.frameRateVariance = 15;
					break;
			}
			
			for (var i:int = 0; i < this.atlasButtons.length; i++)
			{
				if (this.atlasButtons[i].text == id)
				{
					this.atlasButtons[i].upState = this.miniButtonTextureON;
					break;
				}
			}
			
			updateClassicStarling();
		}
		
		private function toggleAutoUpdateBounds(evt:Event):void
		{
			var btn:Button = evt.target as Button;
			this.autoUpdateBounds = !this.autoUpdateBounds;
			if (this._sceneList.length != 0)
			{
				this._sceneList[0].autoUpdateBounds = this.autoUpdateBounds;
			}
			if (this.autoUpdateBounds)
			{
				btn.upState = this.menuButtonTextureON;
			}
			else
			{
				btn.upState = this.menuButtonTextureOFF;
			}
		}
		
		private function toggleBlurFilter(evt:Event):void
		{
			var btn:Button = evt.target as Button;
			this.useBlurFilter = !this.useBlurFilter;
			if (this.useBlurFilter)
			{
				btn.upState = this.buttonTextureON;
			}
			else
			{
				btn.upState = this.buttonTextureOFF;
			}
		}
		
		private function toggleColorMode(evt:Event):void
		{
			var btn:Button = evt.target as Button;
			for (var i:int = 0; i < this.colorModeButtons.length; i++)
			{
				if (this.colorModeButtons[i] == btn) continue;
				this.colorModeButtons[i].upState = this.mediumButtonTextureOFF;
			}
			
			switch (btn.text)
			{
				case "extended" :
					this.colorMode = MassiveColorMode.EXTENDED;
					break;
				
				case "none" :
					this.colorMode = MassiveColorMode.NONE;
					break;
				
				case "regular" :
					this.colorMode = MassiveColorMode.REGULAR;
					break;
			}
			btn.upState = this.mediumButtonTextureON;
		}
		
		private function toggleDisplayScale(evt:Event):void
		{
			var btn:Button = evt.target as Button;
			for (var i:int = 0; i < this.scaleButtons.length; i++)
			{
				if (this.scaleButtons[i] == btn) continue;
				this.scaleButtons[i].upState = this.miniButtonTextureOFF;
			}
			
			this.displayScale = parseFloat(btn.text);
			btn.upState = this.miniButtonTextureON;
		}
		
		private function toggleMovement(evt:Event):void
		{
			var btn:Button = evt.target as Button;
			this.movement = !this.movement;
			if (this._sceneList.length != 0)
			{
				this._sceneList[0].movement = this.movement;
			}
			if (this.movement)
			{
				btn.upState = this.menuButtonTextureON;
			}
			else
			{
				btn.upState = this.menuButtonTextureOFF;
			}
		}
		
		private function toggleMultiTextureStyle(evt:Event):void
		{
			var btn:Button = evt.target as Button;
			this.multiTextureStyle = !this.multiTextureStyle;
			if (this.multiTextureStyle)
			{
				Mesh.defaultStyle = MultiTextureStyle;
				btn.upState = this.buttonTextureON;
			}
			else
			{
				Mesh.defaultStyle = MeshStyle;
				btn.upState = this.buttonTextureOFF;
			}
			
			updateClassicStarling();
			updateMeshStyle();
		}
		
		private function toggleMultiTextureStyleMaxTexture(evt:Event):void
		{
			var btn:Button = evt.target as Button;
			for (var i:int = 0; i < this.maxTextureButtons.length; i++)
			{
				if (this.maxTextureButtons[i] == btn) continue;
				this.maxTextureButtons[i].upState = this.miniButtonTextureOFF;
			}
			
			MultiTextureStyle.maxTextures = parseInt(btn.text);
			btn.upState = this.miniButtonTextureON;
			
			updateMeshStyle();
		}
		
		private function toggleRandomAlpha(evt:Event):void
		{
			var btn:Button = evt.target as Button;
			this.useRandomAlpha = !this.useRandomAlpha;
			if (this.useRandomAlpha)
			{
				btn.upState = this.buttonTextureON;
			}
			else
			{
				btn.upState = this.buttonTextureOFF;
			}
		}
		
		private function toggleRandomColor(evt:Event):void
		{
			var btn:Button = evt.target as Button;
			this.useRandomColor = !this.useRandomColor;
			if (this.useRandomColor)
			{
				btn.upState = this.buttonTextureON;
			}
			else
			{
				btn.upState = this.buttonTextureOFF;
			}
		}
		
		private function toggleRandomRotation(evt:Event):void
		{
			var btn:Button = evt.target as Button;
			this.useRandomRotation = !this.useRandomRotation;
			if (this.useRandomRotation)
			{
				btn.upState = this.buttonTextureON;
			}
			else
			{
				btn.upState = this.buttonTextureOFF;
			}
		}
		
		private function toggleRenderMode(evt:Event):void
		{
			var btn:Button = evt.target as Button;
			for (var i:int = 0; i < this.renderModeButtons.length; i++)
			{
				if (this.renderModeButtons[i] == btn) continue;
				this.renderModeButtons[i].upState = this.buttonTextureOFF;
			}
			
			switch (btn.text)
			{
				case "ByteArray" :
					this.renderMode = MassiveRenderMode.BYTEARRAY;
					break;
				
				case "DomainMemoryByteArray" :
					this.renderMode = MassiveRenderMode.BYTEARRAY_DOMAIN_MEMORY;
					break;
				
				case "Vector" :
					this.renderMode = MassiveRenderMode.VECTOR;
					break;
			}
			btn.upState = this.buttonTextureON;
		}
		
		private function toggleSprite3D(evt:Event):void
		{
			var btn:Button = evt.target as Button;
			this.useSprite3D = !this.useSprite3D;
			if (this.useSprite3D)
			{
				btn.upState = this.buttonTextureON;
			}
			else
			{
				btn.upState = this.buttonTextureOFF;
			}
		}
		
		private function updateClassicStarling():void
		{
			var count:int = this.numClips.length;
			var i:int;
			var multiTexturing:Boolean = this.atlases.length > 1;
			if (multiTexturing && !this.multiTextureStyle)
			{
				for (i = 0; i < count; i++)
				{
					if (this.numClips[i] <= this.maxClipsWithoutMultiTextureStyle)
					{
						this.classicClipsButtons[i].enabled = true;
					}
					else
					{
						this.classicClipsButtons[i].enabled = false;
					}
				}
			}
			else
			{
				for (i = 0; i < count; i++)
				{
					this.classicClipsButtons[i].enabled = true;
				}
			}
		}
		
		private function updateMeshStyle():void
		{
			var count:int = this._allButtons.length;
			for (var i:int = 0; i < count; i++)
			{
				if (this.multiTextureStyle)
				{
					this._allButtons[i].style = new MultiTextureStyle();
					this._allButtons[i].textStyle = new MultiTextureStyle();
				}
				else
				{
					this._allButtons[i].style = new MeshStyle();
					this._allButtons[i].textStyle = new MeshStyle();
				}
			}
			
			count = this._allTextFields.length;
			for (i = 0; i < count; i++)
			{
				if (this.multiTextureStyle)
				{
					this._allTextFields[i].style = new MultiTextureStyle();
				}
				else
				{
					this._allTextFields[i].style = new MeshStyle();
				}
			}
		}
		
		private function startMassiveImages():void
		{
			this.movementButton.enabled = true;
			this.animationButton.enabled = true;
			this.autoUpdateBoundsButton.enabled = true;
			
			var massive:MassiveImages = new MassiveImages();
			massive.animation = this.animation;
			massive.movement = this.movement;
			massive.autoUpdateBounds = this.autoUpdateBounds;
			massive.addAtlases(this.atlases);
			massive.textures = this.textures;
			massive.imgScale = this.displayScale;
			massive.numObjects = this.numObjects;
			massive.colorMode = this.colorMode;
			massive.renderMode = this.renderMode;
			massive.useBlurFilter = this.useBlurFilter;
			massive.useRandomAlpha = this.useRandomAlpha;
			massive.useRandomColor = this.useRandomColor;
			massive.useRandomRotation = this.useRandomRotation;
			massive.useSprite3D = this.useSprite3D;
			
			showSceneList(Vector.<Scene>([massive]));
		}
		
		private function startMassiveQuads():void
		{
			this.movementButton.enabled = true;
			this.animationButton.enabled = false;
			this.autoUpdateBoundsButton.enabled = true;
			
			var massive:MassiveQuads = new MassiveQuads();
			massive.animation = this.animation;
			massive.movement = this.movement;
			massive.autoUpdateBounds = this.autoUpdateBounds;
			massive.displayScale = this.displayScale;
			massive.numObjects = this.numObjects;
			massive.colorMode = this.colorMode;
			massive.renderMode = this.renderMode;
			massive.useBlurFilter = this.useBlurFilter;
			massive.useRandomAlpha = this.useRandomAlpha;
			massive.useRandomColor = this.useRandomColor;
			massive.useRandomRotation = this.useRandomRotation;
			massive.useSprite3D = this.useSprite3D;
			
			showSceneList(Vector.<Scene>([massive]));
		}
		
		private function startClassicClips():void
		{
			this.movementButton.enabled = true;
			this.animationButton.enabled = true;
			this.autoUpdateBoundsButton.enabled = false;
			
			var clips:ClassicClips = new ClassicClips();
			clips.animation = this.animation;
			clips.movement = this.movement;
			clips.textures = this.textures;
			clips.multiTextureStyle = this.multiTextureStyle;
			clips.numClips = this.numObjects;
			clips.clipScale = this.displayScale;
			clips.useBlurFilter = this.useBlurFilter;
			clips.useRandomAlpha = this.useRandomAlpha;
			clips.useRandomColor = this.useRandomColor;
			clips.useRandomRotation = this.useRandomRotation;
			clips.useSprite3D = this.useSprite3D;
			showSceneList(Vector.<Scene>([clips]));
		}
		
		private function startClassicQuads():void
		{
			this.movementButton.enabled = true;
			this.animationButton.enabled = false;
			this.autoUpdateBoundsButton.enabled = false;
			
			var quads:ClassicQuads = new ClassicQuads();
			quads.animation = this.animation;
			quads.movement = this.movement;
			quads.numQuads = this.numObjects;
			quads.displayScale = this.displayScale;
			quads.useBlurFilter = this.useBlurFilter;
			quads.useRandomAlpha = this.useRandomAlpha;
			quads.useRandomColor = this.useRandomColor;
			quads.useRandomRotation = this.useRandomRotation;
			quads.useSprite3D = this.useSprite3D;
			showSceneList(Vector.<Scene>([quads]));
		}
		
		private function classicClips(evt:Event):void
		{
			var btn:Button = evt.target as Button;
			var index:int = btn.text.indexOf(" ");
			this.numObjects = parseInt(btn.text.substring(0, index));
			startClassicClips();
		}
		
		private function classicQuads(evt:Event):void
		{
			var btn:Button = evt.target as Button;
			var index:int = btn.text.indexOf(" ");
			this.numObjects = parseInt(btn.text.substring(0, index));
			startClassicQuads();
		}
		
		private function massiveClips(evt:Event):void
		{
			var btn:Button = evt.target as Button;
			var index:int = btn.text.indexOf(" ");
			this.numObjects = parseInt(btn.text.substring(0, index));
			startMassiveImages();
		}
		
		private function massiveQuads(evt:Event):void
		{
			var btn:Button = evt.target as Button;
			var index:int = btn.text.indexOf(" ");
			this.numObjects = parseInt(btn.text.substring(0, index));
			startMassiveQuads();
		}
		
	}

}