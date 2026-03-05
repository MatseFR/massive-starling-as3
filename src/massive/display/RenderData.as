package massive.display 
{
	/**
	 * ...
	 * @author Matse
	 */
	public class RenderData 
	{
		public var multiTexturing:Boolean;
		public var numQuads:int;
		public var position:int;
		public var quadOffset:int;
		public var totalQuads:int;
		
		public function RenderData() 
		{
			
		}
		
		public function clear():void
		{
			this.numQuads = this.position = this.quadOffset = this.totalQuads = 0;
		}
		
		public function render():void
		{
			this.numQuads = this.position = 0;
		}
			
		}

}