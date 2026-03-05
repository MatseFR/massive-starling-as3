package massive.animation 
{
	import massive.data.Frame;
	import massive.data.ImageData;
	
	/**
	 * Animates textures and generates timings
	 * @author Matse
	 */
	public class Animator 
	{
		/**
		 * Animates textures of the specified ImageData list
		 * @param	datas
		 * @param	time
		 */
		static public function animateImageDataList(datas:Vector.<ImageData>, time:Number):void
		{
			var data:ImageData;
			var count:int = datas.length
			for (var i:int = 0; i < count; i++)
			{
				data = datas[i];
				if (!data.animate) continue;
				
				data.frameTime += time * data.frameDelta;
				if (data.frameTime >= data.frameTimings[data.frameIndex])
				{
					if (data.frameIndex < data.frameCount)
					{
						data.frameIndex++;
					}
					else if (data.loop && (data.numLoops == 0 || data.loopCount < data.numLoops))
					{
						data.frameTime -= data.frameTimings[data.frameIndex];
						data.frameIndex = 0;
						data.loopCount++;
					}
				}
			}
			
		}
		
		/**
		 * Generates timings for the specified frameList, with the specified frameRate
		 * @param	frames
		 * @param	frameRate
		 * @param	timings
		 * @return
		 */
		static public function generateTimings(frames:Vector.<Frame>, frameRate:Number = 60, timings:Vector.<Number> = null):Vector.<Number>
		{
			if (timings == null) timings = new Vector.<Number>();
			
			var frameTime:Number = 1.0 / frameRate;
			var total:Number = 0;
			var count:int = frames.length;
			
			for (var i:int; i < count; i++)
			{
				total += frameTime;
				timings[i] = total;
			}
			
			return timings;
		}
		
	}

}