package GameResource {
	
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
	import GameResource.GameType2Flow;
	import GameResource.Lottery;
	import flash.text.TextFormat;
	
	public class Month4Game extends MovieClip {

		private var eventChannel:EventChannel = null;
		private var sharedObject:SharedObject = null;
		
		private var date:Date = new Date();
		private var dateBeginVerify:Date = new Date(2014, 3, 1);
		private var dateEndVerify:Date = new Date(2014, 4, 1);
		
		private var intDefaultWidth:Number = LayoutSettings.intDefaultWidth;
		private var intDefaultHeight:Number = LayoutSettings.intDefaultHeight;
		private const intDefaultHeightForIphone5:Number = LayoutSettings.intDefaultHeightForIphone5;
		private var isIphone5Layout:Boolean = false;
		private var bg:Sprite = null;
		
		private var gameFlow:GameType3Flow = null;
		private var gameHint:MovieClip = null;
		private var lottery:Lottery = null;
		
		public function Month4Game(... args) {
			// constructor code
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}

		private function init(e:Event) {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(Event.REMOVED_FROM_STAGE, destructor);
			
			sharedObject = SharedObject.getLocal("GameRecord");
			
			eventChannel = EventChannel.getInstance();
			eventChannel.writeEvent(new TitleBarEvent(TitleBarEvent.SET_TITLE, -1, "幸福好幫手"));
		
			LayoutManager.setLayout(this);
			isIphone5Layout = LayoutManager.useIphone5Layout();
			
			if (isIphone5Layout) {
				changeLayoutForIphone5();
			}
			createBackground();
			initElement();
			initFlow();
		}
		
		private function destructor(e:Event = null) {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destructor);
			removeLottery();
			removeGameFlow();
			removeBackground();
			sharedObject = null;
			eventChannel = null;
		}

		private function changeLayoutForIphone5() {
		}
		
		private function createBackground() {
			bg = new GameBackground();
			this.addChild(bg);
		}
		
		private function removeBackground() {
			this.removeChild(bg);
			bg = null;
		}
		
		private function initElement() {
			gameHint = (isIphone5Layout) ? new Month4HintIphone5() : new Month4HintIphone4();
			var intMonth:int = date.month + 1;
			if (intMonth != 4) {
				if (gameHint.hasOwnProperty("datePeriod")) {
					gameHint.datePeriod.text = "活動已結束";
					var textFormat:TextFormat = gameHint.datePeriod.getTextFormat();
					textFormat.color = 0xFF0000;
					gameHint.datePeriod.setTextFormat(textFormat);
				}
			}
		}
		
		private function initFlow() {
			var puzzleOriginalPicture:Sprite = new Month4PuzzleOriginal();
			var lstPuzzles:Array = [
				new Month4Puzzle1(),
				new Month4Puzzle2(),
				new Month4Puzzle3(),
				new Month4Puzzle4(),
				new Month4Puzzle5(),
				new Month4Puzzle6(),
				new Month4Puzzle7(),
				new Month4Puzzle8(),
				new Month4Puzzle9()
			];
			gameFlow = new GameType3Flow(this, gameHint, puzzleOriginalPicture, lstPuzzles);
			gameFlow.addEventListener(GameMakerEvent.MAKE_GAMEMOVIE_FINISH, onGameFlowFinish);
		}
		
		private function removeGameFlow() {
			if (gameFlow) {
				gameFlow.removeEventListener(GameMakerEvent.MAKE_GAMEMOVIE_FINISH, onGameFlowFinish);
				gameFlow.dispose();
			}
			gameFlow = null;
		}
		
		private function onGameFlowFinish(e:Event) {
			trace("Month4Game.as / onGameFlowFinish.");
			sharedObject = SharedObject.getLocal("GameRecord");
			removeGameFlow();
			
			if (date < dateBeginVerify || date >= dateEndVerify) {
				eventChannel.writeEvent(new Event(GameMakerEvent.EXPORT_MOVIE_FINISH));
				return;
			}
			
			if (sharedObject.data.hasOwnProperty("isMonth4GameWinned")) {
				eventChannel.writeEvent(new Event(GameMakerEvent.EXPORT_MOVIE_FINISH));
			} else {
				lottery = new Lottery();
				this.addChild(lottery);
			}
		}
		
		private function removeLottery() {
			if (lottery) this.removeChild(lottery);
			lottery = null;
		}
	}
	
}
