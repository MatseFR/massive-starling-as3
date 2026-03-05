package massive.display 
{
	/**
	 * ...
	 * @author Matse
	 */
	public class MassiveRenderMode 
	{
		
		/**
		   Use a `ByteArray` to store and upload vertex data. This seems to result in faster upload on flash/air target, but at a higher cpu cost.
		   This is the slowest option on all targets and should be avoided : I keep it to demonstrate how slow `ByteArray` is.
		**/
		static public const BYTEARRAY:String = "ByteArray";
		
		/**
		   Use a `ByteArray` with domain memory to store and upload vertex data. This changes everything and makes `ByteArray` the fastest option.
		   This is the default setting on Flash/Air target.
		**/
		static public const BYTEARRAY_DOMAIN_MEMORY:String = "DomainMemoryByteArray";
		
		/**
		   Use a `Vector<Float>` to store and upload vertex data. This is a very good option on Flash/Air target (slightly slower than `BYTEARRAY_DOMAIN_MEMORY`).
		   On other targets, `VertexBuffer3D` copies values to a Float32Array for upload, which limits performance.
		**/
		static public const VECTOR:String = "Vector";
		
		static public function getValues():Array
		{
			return [BYTEARRAY, BYTEARRAY_DOMAIN_MEMORY, VECTOR];
		}
		
	}

}