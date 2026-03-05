package massive.utils 
{
	import avm2.intrinsics.memory.lf32;
	import avm2.intrinsics.memory.li32;
	import avm2.intrinsics.memory.sf32;
	import avm2.intrinsics.memory.si32;
	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;
	/**
	 * CAUTION : for best performance you have to use Air SDK (not Flex SDK) and enable inlining
	 * otherwise most functions will still be a bit faster than their regular counterpart, but far from the indicated numbers
	 * 
	 * This is heavily based on Jackson Dunstan's articles 
	 * https://www.jacksondunstan.com
	 * @author Matse
	 */
	public class MathUtils 
	{
		static public const DEG2RAD:Number = 0.01745329251994329576923690768489;
		static public const HALF_PI:Number = 1.5707963267948966192313216916398;
		static public const PI2:Number = 6.283185307179586476925286766559;
		static public const RAD2DEG:Number = 57.295779513082320876798154814105;
		static public var RANDOM_SEED:uint = 1;
		
		static private var __bytes:ByteArray;
		static private var __sqrtInitDone:Boolean = false;
		
		static public function initSqrt():void
		{
			if (__sqrtInitDone) return;
			__bytes = new ByteArray();
			__bytes.length = 1024;
			ApplicationDomain.currentDomain.domainMemory = __bytes;
			__sqrtInitDone = true;
		}
		
		[Inline]
		/**
		 * 6-7 times faster than Math.abs when inline is enabled
		 * @param	val
		 * @return
		 */
		static public function abs(val:Number):Number
		{
			return val < 0.0 ? -val : val;
		}
		
		[Inline]
		/**
		 * About 10-20% faster than MathUtils.abs for integers
		 * @param	val
		 * @return
		 */
		static public function absInt(val:int):int
		{
			return (val ^ (val >> 31)) - (val >> 31);
		}
		
		[Inline]
		/**
		 * WARNING : will return NaN if x and y are 0.0
		 * 10 times faster than Math.atan2 when inline is enabled
		 * average accuracy 0.0014
		 * lowest accuracy 0.07
		 * @param	y
		 * @param	x
		 * @return
		 */
		static public function atan2(y:Number, x:Number):Number
		{
			if (y > 0.0)
			{
				if (x >= 0.0) 
					return 0.78539816339744830961566084581988 - 0.78539816339744830961566084581988 * (x - y) / (x + y);
				else
					return 2.3561944901923449288469825374596 - 0.78539816339744830961566084581988 * (x + y) / (y - x);
			}
			else
			{
				if (x >= 0.0) 
					return -0.78539816339744830961566084581988 + 0.78539816339744830961566084581988 * (x + y) / (x - y);            
			}
			return -2.3561944901923449288469825374596 - 0.78539816339744830961566084581988 * (x - y) / (y + x);
		}
		
		[Inline]
		/**
		 * 2.5-3 times faster than Math.ceil when inline is enabled
		 * @param	val
		 * @return
		 */
		static public function ceil(val:Number):int
		{
			return val == int(val) ? val : val >= 0 ? int(val+1) : int(val);
		}
		
		[Inline]
		/**
		 * 2.5-3 times faster than Math.floor when inline is enabled
		 * @param	val
		 * @return
		 */
		static public function floor(val:Number):int
		{
			return val == int(val) ? val : val < 0 ? int(val-1) : int(val);
		}
		
		[Inline]
		/**
		 * This is based on John Carmack's hack
		 * 3.5-4 times faster than Math.sqrt
		 * average accuracy 0.16
		 * lowest accuracy 0.36
		 * @param	val
		 * @return
		 */
		static public function invSqrt(val:Number):Number
		{
			var half:Number = val * 0.5;
			sf32(val, 0);
			var i:int = li32(0);
			i = 0x5f3759df - (i>>1);
			si32(i, 0);
			val = lf32(0);
			val = val * (1.5 - half * val * val);
			return val;
		}
		
		[Inline]
		/**
		 * 35-40 times faster than isNaN when inline is enabled
		 * @param	val
		 * @return
		 */
		static public function isNaN(val:Number):Boolean
		{
			return val != val;
		}
		
		[Inline]
		/**
		 * 7 times faster than Math.max when inline is enabled
		 * @param	val1
		 * @param	val2
		 * @return
		 */
		static public function max(val1:Number, val2:Number):Number
		{
			return val1 > val2 ? val1 : val2;
		}
		
		[Inline]
		/**
		 * About 2 times faster than MathUtils.max for integers
		 * @param	val1
		 * @param	val2
		 * @return
		 */
		static public function maxInt(val1:int, val2:int):int
		{
			return val1 > val2 ? val1 : val2;
		}
		
		[Inline]
		/**
		 * 7 times faster than Math.min when inline is enabled
		 * @param	val1
		 * @param	val2
		 * @return
		 */
		static public function min(val1:Number, val2:Number):Number
		{
			return val1 < val2 ? val1 : val2;
		}
		
		[Inline]
		/**
		 * About 2 times faster than MathUtils.min for integers
		 * @param	val1
		 * @param	val2
		 * @return
		 */
		static public function minInt(val1:int, val2:int):int
		{
			return val1 < val2 ? val1 : val2;
		}
		
		[Inline]
		/**
		 * 5 times faster than Math.random when inline is enabled
		 * @return
		 */
		static public function random():Number
		{
			return ((RANDOM_SEED = (RANDOM_SEED * 16807) & 0x7FFFFFFF) / 0x80000000);
		}
		
		[Inline]
		/**
		 * Lets you use a seed of your own, consider calling <code>seedUpdate</seed> afterwards
		 * @param	seed
		 * @return
		 */
		static public function randomWithSeed(seed:uint):Number
		{
			return ((seed * 16807) & 0x7FFFFFFF) / 0x80000000;
		}
		
		[Inline]
		/**
		 * Returns updated seed, typically after a <code>randomWithSeed</code> call
		 * @param	seed
		 * @return
		 */
		static public function seedUpdate(seed:uint):uint
		{
			return (seed * 16807) & 0x7FFFFFFF;
		}
		
		[Inline]
		/**
		 * 7 times faster than starling's deg2rad when inline is enabled
		 * @param	deg
		 * @return
		 */
		static public function deg2rad(deg:Number):Number
		{
			return deg * DEG2RAD;
		}
		
		[Inline]
		/**
		 * 7 times faster than starling's rad2deg when inline is enabled
		 * @param	rad
		 * @return
		 */
		static public function rad2deg(rad:Number):Number
		{
			return rad * RAD2DEG;
		}
		
		[Inline]
		/**
		 * This is based on John Carmack's hack
		 * 3-3.5 times faster than Math.sqrt
		 * average accuracy 0.16
		 * lowest accuracy 0.36
		 * @param	val
		 * @return
		 */
		static public function sqrt(val:Number):Number
		{
			var half:Number = val * 0.5;
			sf32(val, 0);
			var i:int = li32(0);
			i = 0x5f3759df - (i>>1);
			si32(i, 0);
			val = lf32(0);
			val = val * (1.5 - half * val * val);
			return 1 / val;
		}
		
		[Inline]
		/**
		 * if rad is bigger than PI the performance drops about 10% below Math.cos : 
		 * only use if you know your angle is somewhere between -PI and PI
		 * 6-7 times faster than Math.cos when inline is enabled
		 * average accuracy 0.0005
		 * lowest accuracy 0.001
		 * @param	rad
		 * @return
		 */
		static public function fastCos(rad:Number):Number
		{
			//return fastSin(rad + HALF_PI);
			rad += HALF_PI;
			
			rad *= 0.3183098862; // divide by pi to normalize
			
			// bound between -1 and 1
			if (rad > 1)
			{
				rad -= (Math.ceil(rad) >> 1) << 1;
			}
			else if (rad < -1)
			{
				rad += (Math.ceil(-rad) >> 1) << 1;
			}
			
			// this approx only works for -pi <= rads <= pi, but it's quite accurate in this region
			if (rad > 0)
			{
				return rad * (3.1 + rad * (0.5 + rad * (-7.2 + rad * 3.6)));
			}
			else
			{
				return rad * (3.1 - rad * (0.5 + rad * (7.2 + rad * 3.6)));
			}
		}
		
		[Inline]
		/**
		 * if rad is bigger than PI the performance drops about 10% below Math.sin : 
		 * only use if you know your angle is somewhere between -PI and PI
		 * 6-7 times faster than Math.sin when inline is enabled
		 * average accuracy 0.0005
		 * lowest accuracy 0.001
		 * @param	rad
		 * @return
		 */
		static public function fastSin(rad:Number):Number
		{
			rad *= 0.3183098862; // divide by pi to normalize
			
			// bound between -1 and 1
			if (rad > 1)
			{
				rad -= (Math.ceil(rad) >> 1) << 1;
			}
			else if (rad < -1)
			{
				rad += (Math.ceil(-rad) >> 1) << 1;
			}
			
			// this approx only works for -pi <= rads <= pi, but it's quite accurate in this region
			if (rad > 0)
			{
				return rad * (3.1 + rad * (0.5 + rad * (-7.2 + rad * 3.6)));
			}
			else
			{
				return rad * (3.1 - rad * (0.5 + rad * (7.2 + rad * 3.6)));
			}
		}
		
		[Inline]
		/**
		 * 7-8 times faster than Math.cos when inline is enabled
		 * average accuracy 0.03
		 * lowest accuracy 0.056
		 * @param	rad
		 * @return
		 */
		static public function fasterCos(rad:Number):Number
		{
			//return fasterSin(rad + HALF_PI);
			rad += HALF_PI;
			
			//always wrap input angle to -PI..PI
			if (rad < -3.14159265)
				rad += 6.28318531;
			else if (rad >  3.14159265)
				rad -= 6.28318531;
			
			//compute sine
			if (rad < 0)
				return 1.27323954 * rad + .405284735 * rad * rad;
			else
				return 1.27323954 * rad - 0.405284735 * rad * rad;
		}
		
		[Inline]
		/**
		 * 7-8 times faster than Math.sin when inline is enabled
		 * average accuracy 0.03
		 * lowest accuracy 0.056
		 * @param	rad
		 * @return
		 */
		static public function fasterSin(rad:Number):Number
		{
			//always wrap input angle to -PI..PI
			if (rad < -3.14159265)
				rad += 6.28318531;
			else if (rad >  3.14159265)
				rad -= 6.28318531;
			
			//compute sine
			if (rad < 0)
				return 1.27323954 * rad + .405284735 * rad * rad;
			else
				return 1.27323954 * rad - 0.405284735 * rad * rad;
		}
	}
}