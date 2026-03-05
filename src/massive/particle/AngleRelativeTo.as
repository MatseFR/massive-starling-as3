package massive.particle 
{
	/**
	 * ...
	 * @author Matse
	 */
	public class AngleRelativeTo 
	{
		public static const ABSOLUTE:String = "absolute";
		public static const ROTATION:String = "rotation";
		public static const VELOCITY:String = "velocity";
		
		public static function getValues():Array
		{
			return [ABSOLUTE, ROTATION, VELOCITY];
		}
	}

}