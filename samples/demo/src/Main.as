package
{
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3DProfile;
	import flash.display3D.Context3DRenderMode;
	import flash.events.Event;
	import starling.core.Starling;
	
	/**
	 * ...
	 * @author Matse
	 */
	public class Main extends Sprite 
	{
		private var _starling:Starling;
		
		public function Main() 
		{
			if (this.stage != null) start();
			else addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(evt:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			start();
		}
		
		private function start():void
		{
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			
			this._starling = new Starling(MassiveDemo, this.stage, null, null, Context3DRenderMode.AUTO, "auto");
			//this._starling = new Starling(MassiveDemo, this.stage, null, null, Context3DRenderMode.AUTO, Context3DProfile.BASELINE); // use this to force baseline profile
			//this._starling.enableErrorChecking = true;
			this._starling.showStats = true;
			this._starling.skipUnchangedFrames = true;
			this._starling.supportBrowserZoom = true;
			this._starling.supportHighResolutions = false;
			this._starling.simulateMultitouch = false;
			
			this._starling.start();
		}
		
	}
	
}