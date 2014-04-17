package  {
	
	import flash.display.MovieClip;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.events.Event;
	import flash.filesystem.File;
	import ane.lib.VideoNativeExtension;
	import ane.lib.VideoNativeExtensionEvents;
		
	public class testSharePhoto extends MovieClip {
		
		private var ext:VideoNativeExtension;
		
		public function testSharePhoto() {
			//constructor code
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event) {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			ext = new VideoNativeExtension();
			
			var fileSource:File = File.applicationDirectory.resolvePath("Resource/" + "test_photo.JPG");
			var fileImage:File = File.applicationStorageDirectory.resolvePath("test_photo.JPG");
//			fileSource.copyTo(fileImage, true);
			
			ext.showToast("Photo Share Start " + fileImage.nativePath);
			ext.shareImage(fileImage.nativePath, "test");
			ext.showToast("Photo Share Complete");
			
			//fileImage.deleteFile();
			
		}
	}
	
}
