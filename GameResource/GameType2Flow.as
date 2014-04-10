package GameResource {
	
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.SimpleButton;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.net.SharedObject;
	import tw.cameo.LayoutManager;
	import tw.cameo.LayoutSettings;
	import tw.cameo.EventChannel;
	import tw.cameo.game.ChosePicturePannelWithCameraUI;
	import tw.cameo.MovieChangePhotoAndObjectPropertyModify;
	import tw.cameo.ObjectControler;
	import tw.cameo.events.MovieEvents;
	import tw.cameo.events.GameMakerEvent;
	import GameResource.MakePictureAndUpload;
	import com.greensock.TweenLite;
	import com.greensock.easing.*;

	public class GameType2Flow extends MovieClip {
		
		private var eventChannel:EventChannel = EventChannel.getInstance();
		private var gameSharedObject:SharedObject = SharedObject.getLocal("GameData");
		private var intDefaultHeight:Number = LayoutSettings.intDefaultHeight;
		private const intDefaultHeightForIphone5:int = LayoutSettings.intDefaultHeightForIphone5;

		private var _container:DisplayObjectContainer = null;
		private var gameHint:MovieClip = null;
		private var chosePicturePannel:ChosePicturePannelWithCameraUI = null;
		private var pictureBitmap:Bitmap = null;
		private var movieClass:Class = null;
		private var strJpgFileName:String = "";
		private var strUploadComment:String = "";
		private var gameMovie:MovieChangePhotoAndObjectPropertyModify = null;
		private var controlPannel:MovieClip = null;
		private var intControlPannelY:int = 800;
		private const intControlPannelYIphone5:int = 976;
		private var objectControler:ObjectControler = null;
		private var makePictureAndUpload:MakePictureAndUpload = null;
		
		// Control Hint
		private var controlHint:MovieClip = null;

		public function GameType2Flow(
			_containerIn:DisplayObjectContainer = null, 
			gameHintIn:MovieClip = null,
			movieClassIn:Class = null,
			strJpgFileNameIn:String = "Family.jpg",
			strUploadCommentIn:String = "") {
				
			// constructor code
			_container = _containerIn;
			gameHint = gameHintIn;
			movieClass = movieClassIn;
			strJpgFileName = strJpgFileNameIn;
			strUploadComment = strUploadCommentIn;
			
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
			removeMakePictureAndUpload();
			removeGameMovie();
			removeControlHint();
			removeChosePicturePannel();
			removeHint();
			movieClass = null;
			pictureBitmap = null;
			gameSharedObject = null;
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
//				chosePicture();
				pictureBitmap = new Bitmap(new TestPhoto());
				preview();
			}
		}
		
		private function chosePicture() {
			chosePicturePannel = new ChosePicturePannelWithCameraUI("請從相簿挑選或拍攝照片。");
			chosePicturePannel.addEventListener(ChosePicturePannelWithCameraUI.PICTURE_LOADED, onPictureLoaded);
			_container.addChild(chosePicturePannel);
		}
		
		private function removeChosePicturePannel() {
			if (chosePicturePannel) {
				chosePicturePannel.removeEventListener(ChosePicturePannelWithCameraUI.PICTURE_LOADED, onPictureLoaded);
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
			
			if (!gameSharedObject.data.hasOwnProperty("alreadyShowControlHint")) {
				gameSharedObject.data["alreadyShowControlHint"] = true;
				gameSharedObject.flush();
				showControlHint();
			}
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
			controlPannel = new MakePictureControlPannel();
			controlPannel.y = intControlPannelY;
			var nextButton:SimpleButton = controlPannel.getChildByName("NextButton") as SimpleButton;
			nextButton.addEventListener(MouseEvent.CLICK, onControlPannelNextButtonClick);
			_container.addChild(controlPannel);
		}
		
		private function removeControlPannel() {
			if (controlPannel) {
				var nextButton:SimpleButton = controlPannel.getChildByName("NextButton") as SimpleButton;
				nextButton.removeEventListener(MouseEvent.CLICK, onControlPannelNextButtonClick);
				_container.removeChild(controlPannel);
			}
			controlPannel = null;
		}
			
		private function showControlHint() {
			controlHint = (LayoutManager.useIphone5Layout()) ? new ControlHintIphone5() : new ControlHintIphone4();
			controlHint.y = intDefaultHeight;
			controlHint.addEventListener(MouseEvent.CLICK, hideControlHint);
			_container.addChild(controlHint);
			TweenLite.to(controlHint, 1, {y:0, ease:Strong.easeOut});
		}
		
		private function hideControlHint(e:MouseEvent) {
			TweenLite.to(controlHint, 1, {y:intDefaultHeight, ease:Strong.easeOut, onComplete:removeControlHint});
		}
		
		private function removeControlHint() {
			if (controlHint) {
				controlHint.removeEventListener(MouseEvent.CLICK, hideControlHint);
				_container.removeChild(controlHint);
			}
			controlHint = null;
		}
		
		private function onControlPannelNextButtonClick(e:MouseEvent) {
//			removeControlPannel();
			goMakePictureAndUpload();
		}
		
		private function goMakePictureAndUpload() {
			var bitmapData:BitmapData = new BitmapData(640, 960);
			bitmapData.draw(gameMovie);
			var bitmapToSave:Bitmap = new Bitmap(bitmapData);
			makePictureAndUpload = new MakePictureAndUpload(bitmapToSave, strJpgFileName);
			makePictureAndUpload.addEventListener(MakePictureAndUpload.UPLOAD_PICTURE_SUCCESS, onUploadPictureSuccess);
			makePictureAndUpload.addEventListener(MakePictureAndUpload.UPLOAD_PICTURE_FAIL, onUploadPictureFail);
			_container.addChild(makePictureAndUpload);
		}
		
		private function removeMakePictureAndUpload() {
			if (makePictureAndUpload) {
				makePictureAndUpload.removeEventListener(MakePictureAndUpload.UPLOAD_PICTURE_SUCCESS, onUploadPictureSuccess);
				makePictureAndUpload.removeEventListener(MakePictureAndUpload.UPLOAD_PICTURE_FAIL, onUploadPictureFail);
				_container.removeChild(makePictureAndUpload);
			}
			makePictureAndUpload = null;
		}
		
		private function onUploadPictureSuccess(e:Event) {
			this.dispatchEvent(new Event(GameMakerEvent.MAKE_GAMEMOVIE_FINISH));
		}
		
		private function onUploadPictureFail(e:Event) {
			removeMakePictureAndUpload();
		}
	}
	
}
