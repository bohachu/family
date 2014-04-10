package GameResource {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	import flash.utils.getDefinitionByName;
	import flash.utils.ByteArray;
	import flash.text.TextField;
	import flash.events.Event;
	import flash.media.CameraRoll;
	
	import tw.cameo.LayoutSettings;
	import tw.cameo.LayoutManager;
	import tw.cameo.EventChannel;
	import tw.cameo.UploadFile;
	import tw.cameo.DeviceUniqueID;
	import tw.cameo.ToastMessage;
	import flash.events.ErrorEvent;
	
	CAMEO::ANE {
		import ane.lib.VideoNativeExtension;
		import ane.lib.VideoNativeExtensionEvents;
	}
	
	public class MakePictureAndUpload extends MovieClip {

		public static const UPLOAD_PICTURE_SUCCESS:String = "MakePictureAndUpload.UPLOAD_PICTURE_SUCCESS";
		public static const UPLOAD_PICTURE_FAIL:String = "MakePictureAndUpload.UPLOAD_PICTURE_FAIL";
		
		private var eventChannel:EventChannel = EventChannel.getInstance();
		private const strFileUploadPostUrl:String = CONFIG::WEB_SERVER_URL + CONFIG::WEB_PATH_PREFIX + "uploadFile.php";
		
		private var intDefaultWidth:Number = LayoutSettings.intDefaultWidth;
		private var intDefaultHeight:Number = LayoutSettings.intDefaultHeight;
		private const intDefaultHeightForIphone5:int = LayoutSettings.intDefaultHeightForIphone5;
		private var bg:Sprite;
		
		// Preview
		private var uploading:MovieClip = null;
		private const intPreviewWidth:Number = 320;
		private const intPreviewHeight:Number = 480;
		private var intPreviewX:Number = 160;
		private var intPreviewY:Number = 240;
		private var intPreviewYForInPhone5:Number = 328;
		private var intMessageX:Number = 320;
		private var intMessageY:Number = 180;
		private var intMessageYForIphone5:Number = 260;
		private var moviePreview:Sprite = null;
		private var messageText:MovieClip = null;
		
		// Save JPG
		private var cameraRoll:CameraRoll = null;
		private var bitmapToSave:Bitmap = null;
		private var strJpeFileName:String = "";
		private var strJpgSavePath:String = "";
		private var strUploadComment:String = "";
		private var jpgFile:File = null;
		private var fileStream:FileStream = null;
		
		private var deviceUniqueId:DeviceUniqueID = null;
		private var strUniqueId:String = "ThisIsTestId";
		
		CAMEO::ANE {
			private var ext:VideoNativeExtension;
		}
		
		public function MakePictureAndUpload(bitmapToSaveIn:Bitmap = null,
										     strJpeFileNameIn:String = "",
											 strUploadCommentIn:String = "") {
				
			// constructor code
			CAMEO::ANE {
				ext = new VideoNativeExtension();
			}
			
			bitmapToSave = bitmapToSaveIn;
			strJpeFileName = strJpeFileNameIn;
			strUploadComment = strUploadCommentIn;
			
			if (bitmapToSave) {
				this.addEventListener(Event.ADDED_TO_STAGE, init);
			}
		}
		
		private function init(e:Event) {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(Event.REMOVED_FROM_STAGE, destructor);
			
			if (LayoutManager.useIphone5Layout()) {
				changeLayoutForIphone5();
			}
			
			createBackground();
			setUploadingAnimation();
			saveBitmapToCameraRoll();
			//saveBitmapToJpg();
		}

		private function destructor(e:Event) {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destructor);
			removeEventChannelListener();
			eventChannel.removeEventListener(ToastMessage.CLOSE_MESSAGE, onCloseMessage);
			eventChannel = null;
			
			deviceUniqueId = null;
			fileStream = null;
			jpgFile = null;
			bitmapToSave = null;
			
			removeCameraRoll();
			removeUploadingAnimation();
			removeBackground();
			
			CAMEO::ANE {
				if (ext) ext.dispose();
				ext = null;
			}
		}
		
		private function removeEventChannelListener() {
			eventChannel.removeEventListener(UploadFile.UPLOAD_SUCCESS, onUploadFileSuccess);
			eventChannel.removeEventListener(UploadFile.UPLOAD_FAIL, onUploadFileFail);
			eventChannel.removeEventListener(UploadFile.UNKNOW_ERROR, onUnknowError);
		}
		
		private function changeLayoutForIphone5() {
			intDefaultHeight = intDefaultHeightForIphone5;
		}
		
		private function createBackground() {
			bg = new Sprite();
			bg.graphics.beginFill(0x666666, 0);
			bg.graphics.drawRect(0, 0, intDefaultWidth, intDefaultHeight);
			bg.graphics.endFill();
			this.addChild(bg);
		}
		
		private function removeBackground() {
			if (bg) this.removeChild(bg);
			bg = null;
		}
		
		private function setUploadingAnimation() {
			uploading = new Uploading();
			this.addChild(uploading);
		}
		
		private function removeUploadingAnimation() {
			if (uploading) this.removeChild(uploading);
			uploading = null;
		}
		
		private function saveBitmapToCameraRoll() {
			CAMEO::ANE {
				cameraRoll = new CameraRoll();
				cameraRoll.addEventListener(Event.COMPLETE, onSaveToCameraRollComplete);
				cameraRoll.addEventListener(ErrorEvent.ERROR, onSaveToCameraRollFail);
				cameraRoll.addBitmapData(bitmapToSave.bitmapData);
			}
			CAMEO::NO_ANE {
				onSaveToCameraRollComplete(null);
			}
		}
		
		private function removeCameraRoll() {
			if (cameraRoll) {
				cameraRoll.removeEventListener(Event.COMPLETE, onSaveToCameraRollComplete);
				cameraRoll.removeEventListener(ErrorEvent.ERROR, onSaveToCameraRollFail);
				cameraRoll = null;
			}
		}
		
		private function onSaveToCameraRollComplete(e:Event = null) {
			CAMEO::ANE {
				ext.showToast("圖片已儲存到手機圖庫裡！");
			}
			saveBitmapToJpg();
		}
		
		private function onSaveToCameraRollFail(e:ErrorEvent) {
			ToastMessage.showToastMessage(this, "圖片儲存到手機圖庫失敗！");
		}
		
		private function saveBitmapToJpg(e:Event = null) {
			trace("MakePictureAndUpload.as/saveBitmapToJpg.");
			CAMEO::ANE {
				ext.writeConsole("MakePictureAndUpload.as/saveBitmapToJpg.");
			}
			
			jpgFile = File.applicationStorageDirectory.resolvePath(strJpeFileName);
			strJpgSavePath = jpgFile.nativePath;
			CAMEO::NO_ANE {
				onJpgSaved();
			}
			CAMEO::ANE {
				ext.addEventListener(VideoNativeExtensionEvents.IMAGE_TO_JPEG_SAVED, onJpgSaved);
				ext.saveToJpeg(bitmapToSave.bitmapData, strJpgSavePath);
			}
		}
		
		private function onJpgSaved(e:Event = null) {
			trace("MakePictureAndUpload.as / onJpgSaved.");
			CAMEO::ANE {
				ext.writeConsole("MakeMovieAndUpload.as/onJpgSaved.");
				ext.removeEventListener(VideoNativeExtensionEvents.IMAGE_TO_JPEG_SAVED, onJpgSaved);
			}
			uploadMovieAndJpg();
		}
		
		private function uploadMovieAndJpg() {
			eventChannel.addEventListener(UploadFile.UPLOAD_SUCCESS, onUploadFileSuccess);
			eventChannel.addEventListener(UploadFile.UPLOAD_FAIL, onUploadFileFail);
			eventChannel.addEventListener(UploadFile.UNKNOW_ERROR, onUnknowError);
			
			fileStream = new FileStream();
			fileStream.open(jpgFile, FileMode.READ);
			fileStream.position = 0;
			
			var jpgByteArray:ByteArray = new ByteArray();
			fileStream.readBytes(jpgByteArray);
			
			deviceUniqueId = new DeviceUniqueID();
			strUniqueId = deviceUniqueId.getDeviceUniqueID();
			UploadFile.upload(strFileUploadPostUrl, strUniqueId, jpgByteArray, strJpeFileName, strUploadComment);
		}
		
		private function onUploadFileSuccess(e:Event) {
			removeEventChannelListener();
			CAMEO::ANE {
				ext.showToast("圖片上傳成功");
			}
			this.dispatchEvent(new Event(MakePictureAndUpload.UPLOAD_PICTURE_SUCCESS));
		}
		
		private function onUploadFileFail(e:Event) {
			removeEventChannelListener();
			eventChannel.addEventListener(ToastMessage.CLOSE_MESSAGE, onCloseMessage);
			ToastMessage.showToastMessage(this, "圖片上傳失敗！");
		}
		
		private function onUnknowError(e:Event) {
			removeEventChannelListener();
			eventChannel.addEventListener(ToastMessage.CLOSE_MESSAGE, onCloseMessage);
			ToastMessage.showToastMessage(this, "圖片上傳失敗，\n請檢查網路是否開啟！");
		}
		
		private function onCloseMessage(e:Event) {
			this.dispatchEvent(new Event(MakePictureAndUpload.UPLOAD_PICTURE_FAIL));
		}
	}
	
}
