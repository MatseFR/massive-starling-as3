package 
{
	import flash.filesystem.File;
	import massive.data.Frame;
	import massive.display.MassiveDisplay;
	import massive.particle.ParticleSystem;
	import massive.particle.ParticleSystemDefaults;
	import massive.particle.ParticleSystemOptions;
	import massive.utils.MathUtils;
	import starling.assets.AssetManager;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	import starling.utils.Align;
	
	/**
	 * ...
	 * @author Matse
	 */
	public class ParticleEditor extends Sprite 
	{
		private var _assetManager:AssetManager;
		
		private var _massive:MassiveDisplay;
		private var _ps:ParticleSystem;
		
		public function ParticleEditor() 
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(evt:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			this.stage.color = 0x333333;
			
			this._assetManager = new AssetManager();
			this._assetManager.enqueue([
				File.applicationDirectory.resolvePath("assets")
			]);
			this._assetManager.loadQueue(assetsLoaded);
		}
		
		private function assetsLoaded():void
		{
			var atlas:TextureAtlas;
			var texture:Texture;
			var frame:Frame;
			var frames:Vector.<Frame>;
			var timings:Vector.<Number>;
			
			texture = this._assetManager.getTexture("heart");
			frame = Frame.fromTextureWithAlign(texture, Align.CENTER, Align.CENTER);
			frames = Vector.<Frame>([frame]);
			
			var options:ParticleSystemOptions;
			var json:Object;
			var str:String;
			
			//json = this._assetManager.getObject("love_cloud");
			json = this._assetManager.getObject("space_worms");
			options = new ParticleSystemOptions();
			options.fromJSON(json);
			
			this._massive = new MassiveDisplay(texture);
			addChild(this._massive);
			
			this._ps = ParticleSystemDefaults.create(options);
			this._ps.maxNumParticles = 50000;
			this._ps.addFrames(frames);
			this._massive.addLayer(this._ps);
			
			this._ps.emitterX = this.stage.stageWidth / 2;
			this._ps.emitterY = this.stage.stageHeight / 2;
			this._ps.start();
			
			//var seed:uint = 1;
			//for (var i:int = 0; i < 100; i++)
			//{
				//trace(MathUtils.randomWithSeed(seed));
				//seed = MathUtils.seedUpdate(seed);
				//trace(MathUtils.random());
			//}
		}
		
	}

}