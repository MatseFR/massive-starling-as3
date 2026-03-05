package massive.particle 
{
	/**
	 * ...
	 * @author Matse
	 */
	public class OscillationFrequencyStart 
	{
		public static const ZERO:String = "zero";
		public static const RANDOM:String = "random";
		public static const UNIFIED_RANDOM:String = "unified_random";
		
		public static function getValues():Array
		{
			return [ZERO, RANDOM, UNIFIED_RANDOM];
		}
	}

}