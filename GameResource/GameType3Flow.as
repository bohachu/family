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
	import tw.cameo.events.GameMakerEvent;
	import tw.cameo.ToastMessage;
	
	import GameResource.PuzzleGame;

	public class GameType3Flow extends MovieClip {
		
		private var eventChannel:EventChannel = EventChannel.getInstance();
		private var gameSharedObject:SharedObject = SharedObject.getLocal("GameData");
		private var intDefaultHeight:Number = LayoutSettings.intDefaultHeight;
		private const intDefaultHeightForIphone5:int = LayoutSettings.intDefaultHeightForIphone5;

		private var _container:DisplayObjectContainer = null;
		private var gameHint:MovieClip = null;
		private var puzzleOriginalPicture:Sprite = null;
		private var lstPuzzles:Array = null;
		private var puzzleGame:PuzzleGame = null;
		
		public function GameType3Flow(
			_containerIn:DisplayObjectContainer = null, 
			gameHintIn:MovieClip = null,
			puzzleOriginalPictureIn:Sprite = null,
			lstPuzzlesIn:Array = null) {
				
			// constructor code
			_container = _containerIn;
			gameHint = gameHintIn;
			puzzleOriginalPicture = puzzleOriginalPictureIn;
			lstPuzzles = lstPuzzlesIn;
			
			if (LayoutManager.useIphone5Layout()) {
				changeLayoutForIphone5();
			}
			
			if (_container && gameHint) {
				showHint();
			}
		}
		
		private function changeLayoutForIphone5() {
			intDefaultHeight = intDefaultHeightForIphone5;
		}

		public function dispose() {
			removePuzzleGame();
			removeHint();
			gameSharedObject = null;
			eventChannel.removeEventListener(ToastMessage.CLOSE_MESSAGE, onCloseMessage);
			eventChannel = null;
		}
		
		private function showHint() {
			var nextButton:SimpleButton = gameHint.getChildByName("NextButton") as SimpleButton;
			nextButton.addEventListener(MouseEvent.CLICK, onNextButtonClick);
			_container.addChild(gameHint);
		}
		
		private function removeHint() {
			if (gameHint) {
				var nextButton:SimpleButton = gameHint.getChildByName("NextButton") as SimpleButton;
				nextButton.removeEventListener(MouseEvent.CLICK, onNextButtonClick);
				_container.removeChild(gameHint);
			}
			gameHint = null;
		}
		
		private function onNextButtonClick(e:MouseEvent) {
			removeHint();
			playPuzzle();
		}
		
		private function playPuzzle() {
			puzzleGame = new PuzzleGame(puzzleOriginalPicture, lstPuzzles);
			puzzleGame.addEventListener(PuzzleGame.PUZZLE_COMPLETE, onPuzzleComplete);
			_container.addChild(puzzleGame);
		}
		
		private function removePuzzleGame() {
			if (puzzleGame) {
				puzzleGame.removeEventListener(PuzzleGame.PUZZLE_COMPLETE, onPuzzleComplete);
				_container.removeChild(puzzleGame);
			}
			puzzleGame = null;
		}
		
		private function onPuzzleComplete(e:Event) {
			ToastMessage.showToastMessage(_container, "完成拼圖！");
			eventChannel.addEventListener(ToastMessage.CLOSE_MESSAGE, onCloseMessage);
		}
		
		private function onCloseMessage(e:Event) {
			this.dispatchEvent(new Event(GameMakerEvent.MAKE_GAMEMOVIE_FINISH));
		}
	}
	
}
