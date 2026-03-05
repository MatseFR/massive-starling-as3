package massive.particle 
{
	/**
	 * ...
	 * @author Matse
	 */
	public class OscillationFrequencyMode 
	{
		public static const GLOBAL:String = "global";
		public static const GROUP:String = "group";
		public static const SINGLE:String = "single";
		
		public static function getValues():Array
		{
			return [GLOBAL, GROUP, SINGLE];
		}
	}

}