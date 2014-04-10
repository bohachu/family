package GameResource {
	
	import flash.events.Event;
	import flash.display.Bitmap;
	import tw.cameo.MovieChangePhotoAndObjectPropertyModify;
	
	public class Month2 extends MovieChangePhotoAndObjectPropertyModify {
		
		private const intPhotoWidth:int = 640;
		private const intPhotoHeight:int = 960;
		
		public function Month2(photoBitmapIn:Bitmap = null, isSoundEnableIn:Boolean = true, isPlayOnAddedIn:Boolean = false) {
			// constructor code
			super(photoBitmapIn, isSoundEnableIn, isPlayOnAddedIn);
			
			if (photoBitmap == null) {
				photoBitmap = new Bitmap(new TestBitmapData());
			}
			
			if (photoBitmap) {
				setBitmap();
				stageMovie = new Month2GameMovie();
				strPhotoContainerName = "PhotoContainer";
				initMovie();
				this.addEventListener(Event.ADDED_TO_STAGE, init);
			}
		}
		
		override public function setBitmap():void {
			if (photoBitmap.width/photoBitmap.height > intPhotoWidth/intPhotoHeight) {
				photoBitmap.width *= intPhotoHeight/photoBitmap.height;
				photoBitmap.height = intPhotoHeight;
			} else {
				photoBitmap.height *= intPhotoWidth/photoBitmap.width;
				photoBitmap.width = intPhotoWidth;
			}
			photoBitmap.x = (intPhotoWidth - photoBitmap.width) / 2;
			photoBitmap.y = (intPhotoHeight - photoBitmap.height) / 2;
		}
	}
	
}
