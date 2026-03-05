package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	import massive.data.MassiveConstants;
	import massive.utils.LookUp;
	import massive.utils.MathUtils;
	import starling.utils.deg2rad;
	import starling.utils.rad2deg;
	
	/**
	 * This is to make sure that MathUtils functions are faster
	 * and to check how much accuracy we lose by using them
	 * @author Matse
	 */
	public class Main extends Sprite 
	{
		private var _tf:TextField;
		private var _format:TextFormat;
		
		public function Main() 
		{
			this._tf = new TextField();
			this._tf.width = this.stage.stageWidth;
			this._tf.height = this.stage.stageHeight;
			addChild(this._tf);
			
			this._format = new TextFormat("_sans");
			
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.addEventListener(Event.RESIZE, onStageResize);
			
			LookUp.init();
			MathUtils.initSqrt();
			
			atan2_accuracy();
			cos_accuracy();
			sin_accuracy();
			sqrt_accuracy();
			cos();
			sin();
			cos_and_sin();
			abs();
			absInt();
			atan2();
			ceil();
			floor();
			invSqrt();
			sqrt();
			checkNaN();
			max();
			maxInt();
			min();
			minInt();
			random();
			deg_2_rad();
			rad_2_deg();
		}
		
		private function onStageResize(evt:Event):void
		{
			this._tf.x = this._tf.y = 0;
			this._tf.width = this.stage.stageWidth;
			this._tf.height = this.stage.stageHeight;
		}
		
		private function log(str:String):void
		{
			this._tf.appendText(str + "\n");
		}
		
		private function logResults(test1:String, time1:Number, test2:String, time2:Number):void
		{
			var percent:Number;
			var percentStr:String;
			var index:int;
			var str:String;
			if (time1 > time2)
			{
				percent = time1 / time2 * 100 - 100;
				percentStr = percent.toFixed(1);
				str = test1 + " slower than " + test2 + " by " + percentStr + "% (" + time1 + " vs " + time2 + ")";
				this._format.color = 0x880000;
			}
			else if (time2 > time1)
			{
				percent = time2 / time1 * 100 - 100;
				percentStr = percent.toFixed(1);
				str = test1 + " faster than " + test2 + " by " + percentStr + "% (" + time1 + " vs " + time2 + ")";
				this._format.color = 0x006600;
			}
			else
			{
				str = test1 + " equals " + test2 + " (" + time1 + " vs " + time2 + ")";
				this._format.color = 0x000000;
			}
			this._tf.defaultTextFormat = this._format;
			log(str);
		}
		
		private function timeStamp():int
		{
			return getTimer();
		}
		
		private function atan2_accuracy():void
		{
			var diff:Number;
			var totalDiff:Number;
			var highDiff:Number;
			var lowDiff:Number;
			var ref:Number;
			var refList:Vector.<Number> = new Vector.<Number>();
			var value:Number;
			var range:Number = 500;
			var iterations:int = 1000000;
			var step:Number = range / iterations;
			
			var x:Number;
			var y:Number;
			
			var i:int;
			
			log("### ATAN2 ACCURACY");
			
			x = -range / 2 + 0.5; // avoid x==0 & y==0
			y = range / 2;
			
			for (i = 0; i < iterations; i++)
			{
				refList[i] = Math.atan2(y, x);
				x += step;
				y -= step;
			}
			
			x = -range / 2 + 0.5; // avoid x==0 & y==0
			y = range / 2;
			totalDiff = 0.0;
			highDiff = 0;
			lowDiff = Number.MAX_VALUE;
			for (i = 0; i < iterations; i++)
			{
				ref = refList[i];
				value = MathUtils.atan2(y, x);
				
				diff = MathUtils.abs(ref - value);
				totalDiff += diff;
				if (diff > highDiff) highDiff = diff;
				if (diff < lowDiff) lowDiff = diff;
				
				x += step;
				y -= step;
			}
			
			log("MathUtils.atan2 avg diff " + (totalDiff / iterations) + " highest " + highDiff + " lowest " + lowDiff);
			log("");
		}
		
		private function cos_accuracy():void
		{
			var diff:Number;
			var totalDiff:Number;
			var highDiff:Number;
			var lowDiff:Number;
			var refCos:Number;
			var refCosList:Vector.<Number> = new Vector.<Number>();
			var cos:Number;
			
			var angle:Number;
			var angleStart:Number = -Math.PI;
			var iterations:int = 10000;
			var step:Number = MathUtils.PI2 / iterations;
			
			var i:int;
			
			log("### COS ACCURACY");
			
			angle = angleStart;
			for (i = 0; i < iterations; i++)
			{
				refCosList[i] = Math.cos(angle);
				angle += step;
			}
			
			totalDiff = 0.0;
			highDiff = Number.MIN_VALUE;
			lowDiff = Number.MAX_VALUE;
			angle = angleStart;
			for (i = 0; i < iterations; i++)
			{
				refCos = refCosList[i];
				cos = LookUp.cos(angle);
				
				diff = MathUtils.abs(refCos - cos);
				totalDiff += diff;
				if (diff > highDiff) highDiff = diff;
				if (diff < lowDiff) lowDiff = diff;
				
				angle += step;
			}
			
			log("LookUp avg diff " + (totalDiff / iterations) + " highest " + highDiff + " lowest " + lowDiff);
			
			totalDiff = 0.0;
			highDiff = Number.MIN_VALUE;
			lowDiff = Number.MAX_VALUE;
			angle = angleStart;
			for (i = 0; i < iterations; i++)
			{
				refCos = refCosList[i];
				cos = MathUtils.fastCos(angle);
				
				diff = MathUtils.abs(refCos - cos);
				totalDiff += diff;
				if (diff > highDiff) highDiff = diff;
				if (diff < lowDiff) lowDiff = diff;
				
				angle += step;
			}
			
			log("MathUtils.fastCos avg diff " + (totalDiff / iterations) + " highest " + highDiff + " lowest " + lowDiff);
			
			totalDiff = 0.0;
			highDiff = Number.MIN_VALUE;
			lowDiff = Number.MAX_VALUE;
			angle = angleStart;
			for (i = 0; i < iterations; i++)
			{
				refCos = refCosList[i];
				cos = MathUtils.fasterCos(angle);
				
				diff = MathUtils.abs(refCos - cos);
				totalDiff += diff;
				if (diff > highDiff) highDiff = diff;
				if (diff < lowDiff) lowDiff = diff;
				
				angle += step;
			}
			
			log("MathUtils.fasterCos avg diff " + (totalDiff / iterations) + " highest " + highDiff + " lowest " + lowDiff);
			log("");
		}
		
		private function sin_accuracy():void
		{
			var diff:Number;
			var totalDiff:Number;
			var highDiff:Number;
			var lowDiff:Number;
			var refSin:Number;
			var refSinList:Vector.<Number> = new Vector.<Number>();
			var sin:Number;
			
			var angle:Number;
			var angleStart:Number = -Math.PI;
			var iterations:int = 10000;
			var step:Number = MathUtils.PI2 / iterations;
			
			var i:int;
			
			log("### SIN ACCURACY");
			
			angle = angleStart;
			for (i = 0; i < iterations; i++)
			{
				refSinList[i] = Math.sin(angle);
				angle += step;
			}
			
			totalDiff = 0.0;
			highDiff = Number.MIN_VALUE;
			lowDiff = Number.MAX_VALUE;
			angle = angleStart;
			for (i = 0; i < iterations; i++)
			{
				refSin = refSinList[i];
				sin = LookUp.sin(angle);
				
				diff = MathUtils.abs(refSin - sin);
				totalDiff += diff;
				if (diff > highDiff) highDiff = diff;
				if (diff < lowDiff) lowDiff = diff;
				
				angle += step;
			}
			
			log("LookUp avg diff " + (totalDiff / iterations) + " highest " + highDiff + " lowest " + lowDiff);
			
			totalDiff = 0.0;
			highDiff = Number.MIN_VALUE;
			lowDiff = Number.MAX_VALUE;
			angle = angleStart;
			for (i = 0; i < iterations; i++)
			{
				refSin = refSinList[i];
				sin = MathUtils.fastSin(angle);
				
				diff = MathUtils.abs(refSin - sin);
				totalDiff += diff;
				if (diff > highDiff) highDiff = diff;
				if (diff < lowDiff) lowDiff = diff;
				
				angle += step;
			}
			
			log("MathUtils.fastSin avg diff " + (totalDiff / iterations) + " highest " + highDiff + " lowest " + lowDiff);
			
			totalDiff = 0.0;
			highDiff = Number.MIN_VALUE;
			lowDiff = Number.MAX_VALUE;
			angle = angleStart;
			for (i = 0; i < iterations; i++)
			{
				refSin = refSinList[i];
				sin = MathUtils.fasterSin(angle);
				
				diff = MathUtils.abs(refSin - sin);
				totalDiff += diff;
				if (diff > highDiff) highDiff = diff;
				if (diff < lowDiff) lowDiff = diff;
				
				angle += step;
			}
			
			log("MathUtils.fasterSin avg diff " + (totalDiff / iterations) + " highest " + highDiff + " lowest " + lowDiff);
			log("");
		}
		
		private function sqrt_accuracy():void
		{
			var diff:Number;
			var totalDiff:Number;
			var highDiff:Number;
			var lowDiff:Number;
			var ref:Number;
			var refList:Vector.<Number> = new Vector.<Number>();
			var value:Number;
			var range:Number = 50000;
			var iterations:int = 10000000;
			var step:Number = range / iterations;
			var result:Number;
			
			var i:int;
			
			log("### SQRT ACCURACY");
			
			value = 0.0;
			for (i = 0; i < iterations; i++)
			{
				refList[i] = Math.sqrt(value);
				value += step;
			}
			
			value = 0.0
			totalDiff = 0.0;
			highDiff = 0;
			lowDiff = Number.MAX_VALUE;
			for (i = 0; i < iterations; i++)
			{
				ref = refList[i];
				result = MathUtils.sqrt(value);
				
				diff = MathUtils.abs(ref - result);
				totalDiff += diff;
				if (diff > highDiff) highDiff = diff;
				if (diff < lowDiff) lowDiff = diff;
				
				value += step;
			}
			
			log("MathUtils.sqrt avg diff " + (totalDiff / iterations) + " highest " + highDiff + " lowest " + lowDiff);
			log("");
		}
		
		private function cos():void
		{
			var t1:int;
			var t2:int;
			var time1:int;
			var time2:int;
			var iterations:int = 10000000;
			var result:Number;
			var angle:Number = -1.57;
			var COS:Vector.<Number> = LookUp.COS;
			
			var i:int;
			
			log("### COS")
			
			t1 = timeStamp();
			for (i = 0; i < iterations; i++)
			{
				result = Math.cos(angle);
			}
			t2 = timeStamp();
			time1 = t2 - t1;
			
			t1 = timeStamp();
			for (i = 0; i < iterations; i++)
			{
				result = LookUp.cos(angle);
			}
			t2 = timeStamp();
			time2 = t2 - t1;
			
			logResults("LookUp.cos", time2, "Math.cos", time1);
			
			t1 = timeStamp();
			for (i = 0; i < iterations; i++)
			{
				result = COS[LookUp.getAngle(angle)];
			}
			t2 = timeStamp();
			time2 = t2 - t1;
			
			logResults("cached LookUp.COS + LookUp.getAngle", time2, "Math.cos", time1);
			
			t1 = timeStamp();
			for (i = 0; i < iterations; i++)
			{
				result = COS[int(angle * MassiveConstants.ANGLE_CONSTANT) & MassiveConstants.ANGLE_CONSTANT_2];
			}
			t2 = timeStamp();
			time2 = t2 - t1;
			
			logResults("cached LookUp.COS + inlined angle", time2, "Math.cos", time1);
			
			t1 = timeStamp();
			for (i = 0; i < iterations; i++)
			{
				result = MathUtils.fastCos(angle);
			}
			t2 = timeStamp();
			time2 = t2 - t1;
			
			logResults("MathUtils.fastCos", time2, "Math.cos", time1);
			
			t1 = timeStamp();
			for (i = 0; i < iterations; i++)
			{
				result = MathUtils.fasterCos(angle);
			}
			t2 = timeStamp();
			time2 = t2 - t1;
			
			logResults("MathUtils.fasterCos", time2, "Math.cos", time1);
			log("");
		}
		
		private function sin():void
		{
			var t1:int;
			var t2:int;
			var time1:int;
			var time2:int;
			var iterations:int = 10000000;
			var result:Number;
			var angle:Number = 1.57;
			var SIN:Vector.<Number> = LookUp.SIN;
			
			var i:int;
			
			log("### SIN");
			
			t1 = timeStamp();
			for (i = 0; i < iterations; i++)
			{
				result = Math.sin(angle);
			}
			t2 = timeStamp();
			time1 = t2 - t1;
			
			t1 = timeStamp();
			for (i = 0; i < iterations; i++)
			{
				result = LookUp.sin(angle);
			}
			t2 = timeStamp();
			time2 = t2 - t1;
			
			logResults("LookUp.sin", time2, "Math.sin", time1);
			
			t1 = timeStamp();
			for (i = 0; i < iterations; i++)
			{
				result = SIN[LookUp.getAngle(angle)];
			}
			t2 = timeStamp();
			time2 = t2 - t1;
			
			logResults("cached LookUp.SIN + LookUp.getAngle", time2, "Math.sin", time1);
			
			t1 = timeStamp();
			for (i = 0; i < iterations; i++)
			{
				result = SIN[int(angle * MassiveConstants.ANGLE_CONSTANT) & MassiveConstants.ANGLE_CONSTANT_2];
			}
			t2 = timeStamp();
			time2 = t2 - t1;
			
			logResults("cached LookUp.SIN + inlined angle", time2, "Math.sin", time1);
			
			t1 = timeStamp();
			for (i = 0; i < iterations; i++)
			{
				result = MathUtils.fastSin(angle);
			}
			t2 = timeStamp();
			time2 = t2 - t1;
			
			logResults("MathUtils.fastSin", time2, "Math.sin", time1);
			
			t1 = timeStamp();
			for (i = 0; i < iterations; i++)
			{
				result = MathUtils.fasterSin(angle);
			}
			t2 = timeStamp();
			time2 = t2 - t1;
			
			logResults("MathUtils.fasterSin", time2, "Math.sin", time1);
			log("");
		}
		
		private function cos_and_sin():void
		{
			var t1:int;
			var t2:int;
			var time1:int;
			var time2:int;
			var iterations:int = 10000000;
			var result:Number;
			var angle:Number = 1.57;
			var intAngle:int;
			var COS:Vector.<Number> = LookUp.COS;
			var SIN:Vector.<Number> = LookUp.SIN;
			
			var i:int;
			
			log("### COS+SIN");
			
			t1 = timeStamp();
			for (i = 0; i < iterations; i++)
			{
				result = Math.cos(angle);
				result = Math.sin(angle);
			}
			t2 = timeStamp();
			time1 = t2 - t1;
			
			t1 = timeStamp();
			for (i = 0; i < iterations; i++)
			{
				intAngle = int(angle * MassiveConstants.ANGLE_CONSTANT) & MassiveConstants.ANGLE_CONSTANT_2;
				result = COS[intAngle];
				result = SIN[intAngle];
			}
			t2 = timeStamp();
			time2 = t2 - t1;
			
			logResults("cached LookUp COS+SIN + inlined angle", time2, "Math.cos+Math.sin", time1);
			log("");
		}
		
		private function abs():void
		{
			var t1:int;
			var t2:int;
			var time1:int;
			var time2:int;
			var iterations:int = 10000000;
			var result:Number;
			var value:Number = -42;
			
			var i:int;
			
			log("### ABS");
			
			t1 = timeStamp();
			for (i = 0; i < iterations; i++)
			{
				result = Math.abs(value);
			}
			t2 = timeStamp();
			time1 = t2 - t1;
			
			t1 = timeStamp();
			for (i = 0; i < iterations; i++)
			{
				result = MathUtils.abs(value);
			}
			t2 = timeStamp();
			time2 = t2 - t1;
			
			logResults("MathUtils.abs", time2, "Math.abs", time1);
			log("");
		}
		
		private function absInt():void
		{
			var t1:int;
			var t2:int;
			var time1:int;
			var time2:int;
			var iterations:int = 10000000;
			var result:int;
			var value:int = -42;
			
			var i:int;
			
			log("### ABS INT");
			
			t1 = timeStamp();
			for (i = 0; i < iterations; i++)
			{
				result = Math.abs(value);
			}
			t2 = timeStamp();
			time1 = t2 - t1;
			
			t1 = timeStamp();
			for (i = 0; i < iterations; i++)
			{
				result = MathUtils.absInt(value);
			}
			t2 = timeStamp();
			time2 = t2 - t1;
			
			logResults("MathUtils.absInt", time2, "Math.abs", time1);
			log("");
		}
		
		private function atan2():void
		{
			var t1:int;
			var t2:int;
			var time1:int;
			var time2:int;
			var iterations:int = 10000000;
			var result:Number;
			var x:Number;
			var y:Number;
			var range:Number = 500;
			var step:Number = range / iterations;
			
			var i:int;
			
			log("### ATAN2");
			
			x = -range / 2 + 0.5; // avoid x==0 & y==0
			y = range / 2;
			
			t1 = timeStamp();
			for (i = 0; i < iterations; i++)
			{
				result = Math.atan2(y, x);
				x += step;
				y -= step;
			}
			t2 = timeStamp();
			time1 = t2 - t1;
			
			x = -range / 2 + 0.5; // avoid x==0 & y==0
			y = range / 2;
			
			t1 = timeStamp();
			for (i = 0; i < iterations; i++)
			{
				result = MathUtils.atan2(y, x);
				x += step;
				y -= step;
			}
			t2 = timeStamp();
			time2 = t2 - t1;
			
			logResults("MathUtils.atan2", time2, "Math.atan2", time1);
			log("");
		}
		
		private function ceil():void
		{
			var t1:int;
			var t2:int;
			var time1:int;
			var time2:int;
			var iterations:int = 10000000;
			var result:int;
			var value:Number = 3.1415927;
			
			var i:int;
			
			log("### CEIL");
			
			t1 = timeStamp();
			for (i = 0; i < iterations; i++)
			{
				result = Math.ceil(value);
			}
			t2 = timeStamp();
			time1 = t2 - t1;
			
			t1 = timeStamp();
			for (i = 0; i < iterations; i++)
			{
				result = MathUtils.ceil(value);
			}
			t2 = timeStamp();
			time2 = t2 - t1;
			
			logResults("MathUtils.ceil", time2, "Math.ceil", time1);
			log("");
		}
		
		private function floor():void
		{
			var t1:int;
			var t2:int;
			var time1:int;
			var time2:int;
			var iterations:int = 10000000;
			var result:int;
			var value:Number = 3.1415927;
			
			var i:int;
			
			log("### FLOOR");
			
			t1 = timeStamp();
			for (i = 0; i < iterations; i++)
			{
				result = Math.floor(value);
			}
			t2 = timeStamp();
			time1 = t2 - t1;
			
			t1 = timeStamp();
			for (i = 0; i < iterations; i++)
			{
				result = MathUtils.floor(value);
			}
			t2 = timeStamp();
			time2 = t2 - t1;
			
			logResults("MathUtils.floor", time2, "Math.floor", time1);
			log("");
		}
		
		private function invSqrt():void
		{
			var t1:int;
			var t2:int;
			var time1:int;
			var time2:int;
			var iterations:int = 10000000;
			var result:Number;
			var value:Number = 12500;
			
			var i:int;
			
			log("### INVSQRT");
			
			t1 = timeStamp();
			for (i = 0; i < iterations; i++)
			{
				result = Math.sqrt(value);
				//trace(result);
			}
			t2 = timeStamp();
			time1 = t2 - t1;
			
			t1 = timeStamp();
			for (i = 0; i < iterations; i++)
			{
				result = MathUtils.invSqrt(value);
				//trace(result);
			}
			t2 = timeStamp();
			time2 = t2 - t1;
			
			logResults("MathUtils.invSqrt", time2, "Math.sqrt", time1);
			log("");
		}
		
		private function sqrt():void
		{
			var t1:int;
			var t2:int;
			var time1:int;
			var time2:int;
			var iterations:int = 10000000;
			var result:Number;
			var value:Number = 12500;
			
			var i:int;
			
			log("### SQRT");
			
			t1 = timeStamp();
			for (i = 0; i < iterations; i++)
			{
				result = Math.sqrt(value);
				//trace(result);
			}
			t2 = timeStamp();
			time1 = t2 - t1;
			
			t1 = timeStamp();
			for (i = 0; i < iterations; i++)
			{
				result = MathUtils.sqrt(value);
				//trace(result);
			}
			t2 = timeStamp();
			time2 = t2 - t1;
			
			logResults("MathUtils.sqrt", time2, "Math.sqrt", time1);
			log("");
		}
		
		private function checkNaN():void
		{
			var t1:int;
			var t2:int;
			var time1:int;
			var time2:int;
			var iterations:int = 10000000;
			var result:Boolean;
			var value:Number = NaN;
			
			var i:int;
			
			log("### isNaN");
			
			t1 = timeStamp();
			for (i = 0; i < iterations; i++)
			{
				result = isNaN(value);
			}
			t2 = timeStamp();
			time1 = t2 - t1;
			
			t1 = timeStamp();
			for (i = 0; i < iterations; i++)
			{
				result = MathUtils.isNaN(value);
			}
			t2 = timeStamp();
			time2 = t2 - t1;
			
			logResults("MathUtils.isNaN", time2, "isNaN", time1);
			log("");
		}
		
		private function max():void
		{
			var t1:int;
			var t2:int;
			var time1:int;
			var time2:int;
			var iterations:int = 10000000;
			var result:Number;
			var num1:Number = 123.456;
			var num2:Number = 123.789;
			
			var i:int;
			
			log("### MAX");
			
			t1 = timeStamp();
			for (i = 0; i < iterations; i++)
			{
				result = Math.max(num1, num2);
			}
			t2 = timeStamp();
			time1 = t2 - t1;
			
			t1 = timeStamp();
			for (i = 0; i < iterations; i++)
			{
				result = MathUtils.max(num1, num2);
			}
			t2 = timeStamp();
			time2 = t2 - t1;
			
			logResults("MathUtils.max", time2, "Math.max", time1);
			log("");
		}
		
		private function maxInt():void
		{
			var t1:int;
			var t2:int;
			var time1:int;
			var time2:int;
			var iterations:int = 10000000;
			var result:int;
			var int1:int = 123;
			var int2:int = 124;
			
			var i:int;
			
			log("### MAX INT");
			
			t1 = timeStamp();
			for (i = 0; i < iterations; i++)
			{
				result = Math.max(int1, int2);
			}
			t2 = timeStamp();
			time1 = t2 - t1;
			
			t1 = timeStamp();
			for (i = 0; i < iterations; i++)
			{
				result = MathUtils.maxInt(int1, int2);
			}
			t2 = timeStamp();
			time2 = t2 - t1;
			
			logResults("MathUtils.maxInt", time2, "Math.max", time1);
			
			t1 = timeStamp();
			for (i = 0; i < iterations; i++)
			{
				result = MathUtils.max(int1, int2);
			}
			t2 = timeStamp();
			time1 = t2 - t1;
			
			logResults("MathUtils.maxInt", time2, "MathUtils.max", time1);
			log("");
		}
		
		private function min():void
		{
			var t1:int;
			var t2:int;
			var time1:int;
			var time2:int;
			var iterations:int = 10000000;
			var result:Number;
			var num1:Number = 123.456;
			var num2:Number = 123.789;
			
			var i:int;
			
			log("### MIN");
			
			t1 = timeStamp();
			for (i = 0; i < iterations; i++)
			{
				result = Math.min(num1, num2);
			}
			t2 = timeStamp();
			time1 = t2 - t1;
			
			t1 = timeStamp();
			for (i = 0; i < iterations; i++)
			{
				result = MathUtils.min(num1, num2);
			}
			t2 = timeStamp();
			time2 = t2 - t1;
			
			logResults("MathUtils.min", time2, "Math.min", time1);
			log("");
		}
		
		private function minInt():void
		{
			var t1:int;
			var t2:int;
			var time1:int;
			var time2:int;
			var iterations:int = 10000000;
			var result:int;
			var int1:int = 123;
			var int2:int = 124;
			
			var i:int;
			
			log("### MIN INT");
			
			t1 = timeStamp();
			for (i = 0; i < iterations; i++)
			{
				result = Math.min(int1, int2);
			}
			t2 = timeStamp();
			time1 = t2 - t1;
			
			t1 = timeStamp();
			for (i = 0; i < iterations; i++)
			{
				result = MathUtils.minInt(int1, int2);
			}
			t2 = timeStamp();
			time2 = t2 - t1;
			
			logResults("MathUtils.minInt", time2, "Math.min", time1);
			
			t1 = timeStamp();
			for (i = 0; i < iterations; i++)
			{
				result = MathUtils.min(int1, int2);
			}
			t2 = timeStamp();
			time1 = t2 - t1;
			
			logResults("MathUtils.minInt", time2, "MathUtils.min", time1);
			log("");
		}
		
		private function random():void
		{
			var t1:int;
			var t2:int;
			var time1:int;
			var time2:int;
			var iterations:int = 10000000;
			var result:Number;
			
			var i:int;
			
			log("### RANDOM");
			
			t1 = timeStamp();
			for (i = 0; i < iterations; i++)
			{
				result = Math.random();
			}
			t2 = timeStamp();
			time1 = t2 - t1;
			
			t1 = timeStamp();
			for (i = 0; i < iterations; i++)
			{
				result = MathUtils.random();
			}
			t2 = timeStamp();
			time2 = t2 - t1;
			
			logResults("MathUtils.random", time2, "Math.random", time1);
			log("");
		}
		
		private function deg_2_rad():void
		{
			var t1:int;
			var t2:int;
			var time1:int;
			var time2:int;
			var iterations:int = 10000000;
			var result:Number;
			var value:Number = 157.0;
			
			var i:int;
			
			log("### DEG2RAD");
			
			t1 = timeStamp();
			for (i = 0; i < iterations; i++)
			{
				result = deg2rad(value);
			}
			t2 = timeStamp();
			time1 = t2 - t1;
			
			t1 = timeStamp();
			for (i = 0; i < iterations; i++)
			{
				result = MathUtils.deg2rad(value);
			}
			t2 = timeStamp();
			time2 = t2 - t1;
			
			logResults("MathUtils.deg2rad", time2, "starling deg2rad", time1);
			log("");
		}
		
		private function rad_2_deg():void
		{
			var t1:int;
			var t2:int;
			var time1:int;
			var time2:int;
			var iterations:int = 10000000;
			var result:Number;
			var value:Number = 0.157;
			
			var i:int;
			
			log("### RAD2DEG");
			
			t1 = timeStamp();
			for (i = 0; i < iterations; i++)
			{
				result = rad2deg(value);
			}
			t2 = timeStamp();
			time1 = t2 - t1;
			
			t1 = timeStamp();
			for (i = 0; i < iterations; i++)
			{
				result = MathUtils.rad2deg(value);
			}
			t2 = timeStamp();
			time2 = t2 - t1;
			
			logResults("MathUtils.rad2deg", time2, "starling rad2deg", time1);
			log("");
		}
		
	}
	
}