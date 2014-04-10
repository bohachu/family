package GameResource {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.getDefinitionByName;
	import flash.utils.Timer;
	import flash.text.TextField;
	import flash.geom.Matrix;
	import flash.filesystem.File;
	
	import tw.cameo.LayoutSettings;
	import tw.cameo.LayoutManager;
	import tw.cameo.EventChannel;
	import tw.cameo.IMoviePlayer;
	
	import com.greensock.TweenLite;
	
	CAMEO::ANE {
		import ane.lib.VideoNativeExtension;
		import ane.lib.VideoNativeExtensionEvents;
	}
	
	public class MakeMovieAndUpload extends MovieClip {

		private var eventChannel:EventChannel = EventChannel.getInstance();
		
		private const intVideoWidth:Number = 640;
		private const intVideoHeight:Number = 960;
		private var intGameMovieWidth:Number = 640;
		private var intGameMovieHeight:Number = 960;
		
		private var intDefaultWidth:Number = LayoutSettings.intDefaultWidth;
		private var intDefaultHeight:Number = LayoutSettings.intDefaultHeight;
		private const intDefaultHeightForIphone5:int = LayoutSettings.intDefaultHeightForIphone5;
		private var bg:Sprite;
		
		// Preview
		private const intPreviewWidth:Number = 320;
		private const intPreviewHeight:Number = 480;
		private var intPreviewX:Number = 160;
		private var intPreviewY:Number = 240;
		private var intPreviewYForInPhone5:Number = 328;
		private var intMessageX:Number = 320;
		private var intMessageY:Number = 180;
		private var intMessageYForIphone5:Number = 260;
		private var intProgressBarX:Number = 320;
		private var intProgressBarY:Number = 755;
		private var intProgressBarYForIphone5:Number = 855;
		private var moviePreview:Sprite = null;
		private var messageText:MovieClip = null;
		private var progressBar:MovieClip = null;
		
		// Make Movie
		private var movieToRecord:MovieClip = null;
		private var strSoundFileName:String = "";
		private var endingMovie:MovieClip = null;
		private var intTotalFrames:int = 0;
		private var intMovieFrames:int = 0;
		private var movieScaleMatrix:Matrix = null;
		private var intMakeMovieProgress:int = 90;
		private var intCount:int = 1;
		private var strMovieSavePath:String = "";
		private var movieSaveFinishMessage:MovieClip = null;
		private var removeMessageTimer:Timer = null;
		
		// Save JPG
		private var bitmapToSave:Bitmap = null;
		private var strJpeFileName:String = "";
		private var strJpgSavePath:String = "";
		
		private var delayTimer:Timer = null;

		CAMEO::ANE {
			private var ext:VideoNativeExtension;
		}
		
		public function MakeMovieAndUpload(movieToRecordIn:MovieClip = null,
										   strSoundFileNameIn:String = "",
										   strJpeFileNameIn:String = "") {
				
			// constructor code
			CAMEO::ANE {
				ext = new VideoNativeExtension();
			}
			
			movieToRecord = movieToRecordIn;
			strSoundFileName = strSoundFileNameIn;
			strJpeFileName = strJpeFileNameIn;
			
			if (movieToRecord) {
				intTotalFrames = intMovieFrames = (movieToRecord as IMoviePlayer).getTotalFrameNumber();
				movieScaleMatrix = new Matrix(intVideoWidth/intGameMovieWidth, 0, 0, intVideoHeight/intGameMovieHeight);
			
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
			setPreview();
			
			delayTimer = new Timer(500, 1);
			delayTimer.addEventListener(TimerEvent.TIMER, goSavePictureAndCreatMovie);
			delayTimer.start();
		}

		private function destructor(e:Event) {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destructor);
			removeSaveFinishMessage();
			removeMovieSaveFinishMessageTimer();
			removePreview();
			removeDelayTimer();
			removeBackground();
			movieScaleMatrix = null;
		}
		
		private function changeLayoutForIphone5() {
			intDefaultHeight = intDefaultHeightForIphone5;
			intPreviewY = intPreviewYForInPhone5;
			intMessageY = intMessageYForIphone5;
			intProgressBarY = intProgressBarYForIphone5;
		}
		
		private function createBackground() {
			try {
				var bgClass:Class = getDefinitionByName("MakeGameMovieBackground") as Class;
				bg = new bgClass();
			} catch (error:Error) {
				bg = new Sprite();
				bg.graphics.beginFill(0x666666);
				bg.graphics.drawRect(0, 0, intDefaultWidth, intDefaultHeight);
				bg.graphics.endFill();
			}
			this.addChild(bg);
		}
		
		private function removeBackground() {
			if (bg) this.removeChild(bg);
			bg = null;
		}
		
		private function setPreview() {
			moviePreview = new Sprite();
			moviePreview.x = intPreviewX;
			moviePreview.y = intPreviewY;
			this.addChild(moviePreview);
			
			var movieMask:Sprite = new Sprite();
			movieMask.graphics.beginFill(0x000000);
			movieMask.graphics.drawRoundRect(0, 0, intVideoWidth, intVideoHeight, 20, 20);
			movieMask.x = moviePreview.x;
			movieMask.y = moviePreview.y;
			this.addChild(movieMask);
			moviePreview.mask = movieMask;
			
			messageText = new ExportingStickerMovieText();
			messageText.x = intMessageX;
			messageText.y = intMessageY;
			this.addChild(messageText);
			
			progressBar = new MakeMovieProgressBar();
			progressBar.stop();
			progressBar.x = intProgressBarX;
			progressBar.y = intProgressBarY;
			this.addChild(progressBar);
		}
		
		private function removePreview() {
			if (moviePreview) {
				moviePreview.removeChildren();
				this.removeChild(moviePreview);
				this.removeChild(messageText);
				this.removeChild(progressBar);
			}
			moviePreview = null;
			messageText = null;
			progressBar = null;
		}
		
		private function removeDelayTimer() {
			if (delayTimer) {
				delayTimer.stop();
				delayTimer.removeEventListener(TimerEvent.TIMER, goSavePictureAndCreatMovie);
			}
			delayTimer = null;
		}
		
		private function goSavePictureAndCreatMovie(e:TimerEvent) {
			removeDelayTimer();
			(movieToRecord as IMoviePlayer).playMovie();
			
			CAMEO::ANE {
				ext.startSession(intVideoWidth, intVideoHeight, strSoundFileName);
			}
			
			movieToRecord.addEventListener(Event.ENTER_FRAME, onFrameForward);
		}
		
		private function onFrameForward(e:Event) {
			trace("MakeMovieAndUpload.as/onFrameForward: i/total frames " + intCount + "/" + intTotalFrames);
			trace("MakeMovieAndUpload.as/onFrameForward: " + Math.round(intCount*intMakeMovieProgress/intTotalFrames));
			progressBar.gotoAndStop(Math.round(intCount*intMakeMovieProgress/intTotalFrames));
			var bitmapData:BitmapData = new BitmapData(intVideoWidth, intVideoHeight);
			bitmapData.draw(movieToRecord, movieScaleMatrix);
			
			CAMEO::ANE {
				ext.writeConsole("MakeMovieAndUpload.as/onFrameForward: i/total frames " + intCount + "/" + intTotalFrames);
				ext.addFrame(bitmapData, this.stage.frameRate);
			}
			
			moviePreview.removeChildren();
			var bitmap:Bitmap = new Bitmap(bitmapData);
			bitmap.width = intPreviewWidth;
			bitmap.height = intPreviewHeight;
			moviePreview.addChild(bitmap);
			intCount++;
			
			if (intCount > intMovieFrames && endingMovie) {
				bitmapToSave = bitmap;
				if (!movieToRecord.contains(endingMovie)) {
					movieToRecord.addChild(endingMovie);
					endingMovie.play();
				}
			}
			
			if (intCount > intTotalFrames) {
				if (endingMovie == null) {
					bitmapToSave = bitmap;
				}
				if (endingMovie) endingMovie.stop();
				movieToRecord.removeEventListener(Event.ENTER_FRAME, onFrameForward);
				saveMovie();
			}
		}
		
		private function saveMovie() {
			trace("MakeMovieAndUpload.as / saveMovie.");
			CAMEO::NO_ANE {
				var messageTextField:TextField = messageText.getChildByName("strLabel") as TextField;
				messageTextField.text = "儲存影片...";
				onMovieSaved();
			}
			
			CAMEO::ANE {
				var messageTextField:TextField = messageText.getChildByName("strLabel") as TextField;
				messageTextField.text = "儲存影片...";
				ext.writeConsole("MakeMovieAndUpload.as / saveMovie.");
				ext.endSessionAndSaveMovie();
				ext.addEventListener(VideoNativeExtensionEvents.MOVIE_SAVED, onMovieSaved);
			}
		}
		
		private function onMovieSaved(e:Event = null) {
			CAMEO::ANE {
				ext.writeConsole("MakeMovieAndUpload.as/onMovieSaved.");
			}
			
			progressBar.gotoAndStop(95);
			
			showMovieSavedMessage();
			
			CAMEO::ANE {
				strMovieSavePath = ext.getVideoPath();
				ext.removeEventListener(VideoNativeExtensionEvents.MOVIE_SAVED, onMovieSaved);			
			}
			
			strJpgSavePath = File.applicationStorageDirectory.resolvePath(strJpeFileName).nativePath;
			CAMEO::NO_ANE {
				onJpgSaved();
			}
			CAMEO::ANE {
				ext.addEventListener(VideoNativeExtensionEvents.IMAGE_TO_JPEG_SAVED, onJpgSaved);
				ext.saveToJpeg(bitmapToSave.bitmapData, strJpgSavePath);
			}
		}
		
		private function showMovieSavedMessage() {
			movieSaveFinishMessage = new MovieMakeFinishToastMessage();
			movieSaveFinishMessage.alpha = 0;
			movieSaveFinishMessage.x = intDefaultWidth/2;
			movieSaveFinishMessage.y = intDefaultHeight/2;
			this.addChild(movieSaveFinishMessage);
			TweenLite.to(movieSaveFinishMessage, 1, {alpha:1});
			removeMessageTimer = new Timer(2000, 1);
			removeMessageTimer.addEventListener(TimerEvent.TIMER, onRemoveMessageTimer);
			removeMessageTimer.start();
		}
		
		private function onRemoveMessageTimer(e:TimerEvent) {
			removeMovieSaveFinishMessageTimer();
			TweenLite.to(movieSaveFinishMessage, 1, {alpha:0, onComplete:removeSaveFinishMessage});
		}
		
		private function removeSaveFinishMessage() {
			if (movieSaveFinishMessage) this.removeChild(movieSaveFinishMessage);
			movieSaveFinishMessage = null;
		}
		
		private function removeMovieSaveFinishMessageTimer() {
			if (removeMessageTimer) {
				removeMessageTimer.stop();
				removeMessageTimer.removeEventListener(TimerEvent.TIMER, onRemoveMessageTimer);
			}
			removeMessageTimer = null;
		}
		
		private function onJpgSaved(e:Event = null) {
			trace("MakeMovieAndUpload.as / onJpgSaved.");
			CAMEO::ANE {
				ext.writeConsole("MakeMovieAndUpload.as/onJpgSaved.");
				ext.removeEventListener(VideoNativeExtensionEvents.IMAGE_TO_JPEG_SAVED, onJpgSaved);
			}
			progressBar.gotoAndStop(100);
			var messageTextField:TextField = messageText.getChildByName("strLabel") as TextField;
			messageTextField.text = "上傳影片...";
			uploadMovieAndJpg();
		}
		
		private function uploadMovieAndJpg() {
			
		}
	}
	
}
