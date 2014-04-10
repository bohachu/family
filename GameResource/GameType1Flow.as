package GameResource {
	
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.display.Bitmap;
	import tw.cameo.LayoutManager;
	import tw.cameo.LayoutSettings;
	import tw.cameo.EventChannel;
	import tw.cameo.game.ChosePicturePannel;
	import tw.cameo.MovieChangePhotoAndObjectPropertyModify;
	import tw.cameo.ObjectControler;
	import tw.cameo.events.MovieEvents;
	import GameResource.MakeMovieAndUpload;
	
	import com.greensock.TweenLite;
	import com.greensock.easing.*;

	public class GameType1Flow extends MovieClip {
		
		private var eventChannel:EventChannel = EventChannel.getInstance();
		private var intDefaultHeight:Number = LayoutSettings.intDefaultHeight;
		private const intDefaultHeightForIphone5:int = LayoutSettings.intDefaultHeightForIphone5;

		private var _container:DisplayObjectContainer = null;
		private var gameHint:MovieClip = null;
		private var chosePicturePannel:ChosePicturePannel = null;
		private var pictureBitmap:Bitmap = null;
		private var movieClass:Class = null;
		private var strSoundFileName:String = "";
		private var strJpgFileName:String = "";
		private var gameMovie:MovieChangePhotoAndObjectPropertyModify = null;
		private var controlPannel:MovieClip = null;
		private var intControlPannelY:int = 800;
		private const intControlPannelYIphone5:int = 976;
		private var objectControler:ObjectControler = null;
		private var makeMovieAndUpload:MakeMovieAndUpload = null;

		public function GameType1Flow(
			_containerIn:DisplayObjectContainer = null, 
			gameHintIn:MovieClip = null,
			movieClassIn:Class = null,
			strSoundFileNameIn:String = "",
			strJpgFileNameIn:String = "Family.jpg") {
				
			// constructor code
			_container = _containerIn;
			gameHint = gameHintIn;
			movieClass = movieClassIn;
			strSoundFileName = strSoundFileNameIn;
			strJpgFileName = strJpgFileNameIn;
			
			if (LayoutManager.useIphone5Layout()) {
				changeLayoutForIphone5();
			}
			
			if (_container && gameHint) {
				showHint();
			}
		}
		
		private function changeLayoutForIphone5() {
			intDefaultHeight = intDefaultHeightForIphone5;
			intControlPannelY = intControlPannelYIphone5;
		}

		public function dispose() {
			removeGameMovie();
			removeChosePicturePannel();
			removeHint();
			eventChannel = null;
		}
		
		private function showHint() {
			var argeement:MovieClip = gameHint.getChildByName("Agreement") as MovieClip;
			var nextButton:SimpleButton = gameHint.getChildByName("NextButton") as SimpleButton;
			argeement.addEventListener(MouseEvent.CLICK, onAgreementClick);
			_container.addChild(gameHint);
		}
		
		private function removeHint() {
			if (gameHint) {
				var argeement:MovieClip = gameHint.getChildByName("Agreement") as MovieClip;
				var nextButton:SimpleButton = gameHint.getChildByName("NextButton") as SimpleButton;
				argeement.removeEventListener(MouseEvent.CLICK, onAgreementClick);
				nextButton.removeEventListener(MouseEvent.CLICK, onNextButtonClick);
				_container.removeChild(gameHint);
			}
			gameHint = null;
		}
		
		private function onAgreementClick(e:MouseEvent) {
			var argeement:MovieClip = gameHint.getChildByName("Agreement") as MovieClip;
			var checkIcon:MovieClip = argeement.getChildByName("CheckIcon") as MovieClip;
			var nextButton:SimpleButton = gameHint.getChildByName("NextButton") as SimpleButton;
			if (checkIcon.visible) {
				checkIcon.visible = false;
				nextButton.alpha = 0.3;
				nextButton.enabled = false;
				nextButton.removeEventListener(MouseEvent.CLICK, onNextButtonClick);
			} else {
				checkIcon.visible = true;
				nextButton.alpha = 1;
				nextButton.enabled = true;
				nextButton.addEventListener(MouseEvent.CLICK, onNextButtonClick);
			}
		}
		
		private function onNextButtonClick(e:MouseEvent) {
			removeHint();
			CAMEO::ANE {
				chosePicture();
			}
			CAMEO::NO_ANE {
				pictureBitmap = new Bitmap(new TestPhoto());
				preview();
			}
		}
		
		private function chosePicture() {
			chosePicturePannel = new ChosePicturePannel();
			chosePicturePannel.addEventListener(ChosePicturePannel.PICTURE_LOADED, onPictureLoaded);
			_container.addChild(chosePicturePannel);
		}
		
		private function removeChosePicturePannel() {
			if (chosePicturePannel) {
				chosePicturePannel.removeEventListener(ChosePicturePannel.PICTURE_LOADED, onPictureLoaded);
				_container.removeChild(chosePicturePannel);
			}
			chosePicturePannel = null;
		}
		
		private function onPictureLoaded(e:Event) {
			pictureBitmap = chosePicturePannel.getBitmap();
			removeChosePicturePannel();
			preview();
		}
		
		private function preview() {
			gameMovie = new movieClass(new Bitmap(pictureBitmap.bitmapData), true, false);
			gameMovie.clearObjectProperty();
			gameMovie.addEventListener(MovieEvents.MOVIE_READY, onMovieReady);
			_container.addChild(gameMovie);
			
			addControlPannel();
		}
		
		private function removeGameMovie() {
			removeControlFromMovie();
			if (gameMovie) {
				gameMovie.removeEventListener(MovieEvents.MOVIE_READY, onMovieReady);
				_container.removeChild(gameMovie);
			}
			gameMovie = null;
		}
		
		private function onMovieReady(e:MovieEvents) {
			gameMovie.gotoAndStopAtEnd();
			objectControler = new ObjectControler(gameMovie.getControlObjectList());
		}
		
		private function removeControlFromMovie() {
			if (objectControler) {
				objectControler.dispose();
			}
			objectControler = null;
		}
		
		private function addControlPannel() {
			controlPannel = new ControlPannel();
			controlPannel.y = intControlPannelY;
			var previewButton:SimpleButton = controlPannel.getChildByName("PreviewButton") as SimpleButton;
			previewButton.addEventListener(MouseEvent.CLICK, onPreviewClick);
			var nextButton:SimpleButton = controlPannel.getChildByName("NextButton") as SimpleButton;
			nextButton.addEventListener(MouseEvent.CLICK, onControlPannelNextButtonClick);
			_container.addChild(controlPannel);
		}
		
		private function removeControlPannel() {
			if (controlPannel) {
				var previewButton:SimpleButton = controlPannel.getChildByName("PreviewButton") as SimpleButton;
				previewButton.removeEventListener(MouseEvent.CLICK, onPreviewClick);
				var nextButton:SimpleButton = controlPannel.getChildByName("NextButton") as SimpleButton;
				nextButton.removeEventListener(MouseEvent.CLICK, onControlPannelNextButtonClick);
				_container.removeChild(controlPannel);
			}
			controlPannel = null;
		}
		
		private function onPreviewClick(e:MouseEvent) {
			hideControlPannel();
			gameMovie.playMovie();
			gameMovie.addEventListener(MovieEvents.MOVIE_PLAY_END, onMoviePlayEnd);
		}
		
		private function hideControlPannel() {
			TweenLite.to(controlPannel, 1, {y:intDefaultHeight, ease:Strong.easeOut});
		}
		
		private function onMoviePlayEnd(e:Event) {
			gameMovie.removeEventListener(MovieEvents.MOVIE_PLAY_END, onMoviePlayEnd);
			showControlPannel();
		}
		
		private function showControlPannel() {
			TweenLite.to(controlPannel, 1, {y:intControlPannelY, ease:Strong.easeOut});
		}
		
		private function onControlPannelNextButtonClick(e:MouseEvent) {
			gameMovie.saveObjectProperty();
			removeGameMovie();
			removeControlPannel();
			goMakeMovieAndUpload();
		}
		
		private function goMakeMovieAndUpload() {
			var gameMovieToRecord = new movieClass(new Bitmap(pictureBitmap.bitmapData), false, false);
			makeMovieAndUpload = new MakeMovieAndUpload(gameMovieToRecord, strSoundFileName);
			_container.addChild(makeMovieAndUpload);
		}
	}
	
}
