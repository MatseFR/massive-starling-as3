package massive.utils 
{
	import massive.data.MassiveConstants;
	/**
	 * LookUp class for COS and SIN
	 * Note that the absolute fastest way to get COS and/or SIN values is to reference LookUp.COS and/or LookUp.SIN and inline the int angle calculation
	 * <code>var cos:Number = COS[angle * MassiveConstants.ANGLE_CONSTANT) & MassiveConstants.ANGLE_CONSTANT_2];</code>
	 * <code>var sin:Number = SIN[angle * MassiveConstants.ANGLE_CONSTANT) & MassiveConstants.ANGLE_CONSTANT_2];</code>
	 * this way is about 10-12 times faster than Math.cos(angle) / Math.sin(angle)
	 * if you need both COS and SIN, this way is about 18 times faster than Math.cos(angle) + Math.sin(angle) because we only need to calculate the int angle once
	 * average accuracy 0.001
	 * lowest accuracy 0.003
	 * @author Matse
	 */
	public class LookUp 
	{
		static private var _initDone:Boolean = false;
		static public function get initDone():Boolean { return _initDone; }
		
		static private var _COS:Vector.<Number>;
		static public function get COS():Vector.<Number>
		{
			if (!_initDone) init();
			return _COS;
		}
		
		static private var _SIN:Vector.<Number>;
		static public function get SIN():Vector.<Number>
		{
			if (!_initDone) init();
			return _SIN;
		}
		
		static private const COSINUS_CONSTANT:Number = 0.00306796157577128245943617517898;
		static private const SINUS_CONSTANT:Number = 0.00306796157577128245943617517898;
		
		static public function init():void
		{
			if (_initDone) return;
			
			_COS = new Vector.<Number>();
			_SIN = new Vector.<Number>();
			
			for (var i:int = 0; i < 0x800; i++)
			{
				_COS[i & 0x7FF] = Math.cos(i * COSINUS_CONSTANT);
				_SIN[i & 0x7FF] = Math.sin(i * SINUS_CONSTANT);
			}
			
			_initDone = true;
		}
		
		[Inline]
		static public function getAngle(angle:Number):int
		{
			return int(angle * MassiveConstants.ANGLE_CONSTANT) & MassiveConstants.ANGLE_CONSTANT_2;
		}
		
		[Inline]
		/**
		 * About 7 times faster than Math.cos when inline is enabled
		 * @param	angle
		 * @return
		 */
		static public function cos(angle:Number):Number
		{
			return _COS[int(angle * MassiveConstants.ANGLE_CONSTANT) & MassiveConstants.ANGLE_CONSTANT_2];
		}
		
		[Inline]
		/**
		 * About 7 times faster than Math.sin when inline is enabled
		 * @param	angle
		 * @return
		 */
		static public function sin(angle:Number):Number
		{
			return _SIN[int(angle * MassiveConstants.ANGLE_CONSTANT) & MassiveConstants.ANGLE_CONSTANT_2];
		}
		
	}

}