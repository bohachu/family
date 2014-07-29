﻿package GameResource {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.utils.getDefinitionByName;
	import flash.net.SharedObject;
	import tw.cameo.LayoutManager;
	import tw.cameo.LayoutSettings;
	import tw.cameo.EventChannel;
	import tw.cameo.events.GameMakerEvent;
	import tw.cameo.events.TitleBarEvent;
	import tw.cameo.ToastMessage;
	
	import GameResource.Month9PuzzleGame;
	import GameResource.Lottery;
	import GameTitleInfo;
	
	public class Month9Game extends MovieClip {

		private var eventChannel:EventChannel = null;
		private var sharedObject:SharedObject = null;
		
		private var date:Date = new Date();
		
		private var intDefaultWidth:Number = LayoutSettings.intDefaultWidth;
		private var intDefaultHeight:Number = LayoutSettings.intDefaultHeight;
		private const intDefaultHeightForIphone5:Number = LayoutSettings.intDefaultHeightForIphone5;
		private var isIphone5Layout:Boolean = false;
		private var bg:Sprite = null;
		
		private var gameHint:MovieClip = null;
		private var puzzleGame:Month9PuzzleGame = null;
		private var lottery:Lottery = null;
		
		public function Month9Game(... args) {
			// constructor code
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}

		private function init(e:Event) {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(Event.REMOVED_FROM_STAGE, destructor);
			
			sharedObject = SharedObject.getLocal("GameRecord");
			
			eventChannel = EventChannel.getInstance();
			eventChannel.writeEvent(new TitleBarEvent(TitleBarEvent.SET_TITLE, -1, GameTitleInfo.lstStrTitle[7]));
		
			LayoutManager.setLayout(this);
			isIphone5Layout = LayoutManager.useIphone5Layout();
			
			if (isIphone5Layout) {
				changeLayoutForIphone5();
			}
			createBackground();
			showHint();
		}
		
		private function destructor(e:Event = null) {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destructor);
			removeLottery();
			removeGame();
			removeHint();
			removeBackground();
			sharedObject = null;
		}

		private function changeLayoutForIphone5() {
			intDefaultHeight = intDefaultHeightForIphone5;
		}
		
		private function createBackground() {
			bg = new GameBackground();
			this.addChild(bg);
		}
		
		private function removeBackground() {
			this.removeChild(bg);
			bg = null;
		}
		
		private function showHint() {
			gameHint = (isIphone5Layout) ? new Month9HintIphone5() : new Month9HintIphone4();
			gameHint.NextButton.addEventListener(MouseEvent.CLICK, onNextButtonClick);
			this.addChild(gameHint);
		}
		
		private function removeHint() {
			if (gameHint) {
				gameHint.NextButton.removeEventListener(MouseEvent.CLICK, onNextButtonClick);
				this.removeChild(gameHint);
			}
			gameHint = null;
		}
		
		private function onNextButtonClick(e:MouseEvent) {
			removeHint();
			initGame();
		}
		
		private function initGame() {
			puzzleGame = new Month9PuzzleGame();
			puzzleGame.addEventListener(Month9PuzzleGame.PUZZLE_COMPLETE, onPuzzleFinish);
			this.addChild(puzzleGame);
		}
		
		private function removeGame() {
			if (puzzleGame) {
				puzzleGame.removeEventListener(Month9PuzzleGame.PUZZLE_COMPLETE, onPuzzleFinish);
				this.removeChild(puzzleGame);
			}
			
			puzzleGame = null;
		}
		
		private function onPuzzleFinish(e:Event) {
			ToastMessage.showToastMessage(this, "完成遊戲！");
			eventChannel.addEventListener(ToastMessage.CLOSE_MESSAGE, onCloseMessage);
		}
		
		private function onCloseMessage(e:Event) {
			eventChannel.removeEventListener(ToastMessage.CLOSE_MESSAGE, onCloseMessage);
			nextStep();
		}
		
		private function nextStep() {
			trace("Month9Game.as / nextStep.");
			var intMonth:int = date.month + 1;
			
			CAMEO::Debug {
				intMonth = 9;
			}
			
			if (intMonth != 9) {
				eventChannel.writeEvent(new Event(GameMakerEvent.EXPORT_MOVIE_FINISH));
			}
			
			if (intMonth == 9) {
				if (sharedObject.data.hasOwnProperty("isMonth9GameWinned")) {
					eventChannel.writeEvent(new Event(GameMakerEvent.EXPORT_MOVIE_FINISH));
				} else {
					lottery = new Lottery("Type2");
					removeGame();
					this.addChild(lottery);
				}
			}
		}
		
		private function removeLottery() {
			if (lottery) this.removeChild(lottery);
			lottery = null;
		}
	}
	
}