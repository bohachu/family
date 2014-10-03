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
	import GameResource.GameType3Flow;
	import GameResource.Lottery;
	import flash.text.TextFormat;
	
	public class Month10Game extends MovieClip {

		private var eventChannel:EventChannel = null;
		private var sharedObject:SharedObject = null;
		
		private var date:Date = new Date();
		private var dateBeginVerify:Date = new Date(2014, 9, 1);
		private var dateEndVerify:Date = new Date(2014, 10, 1);
		
		private var intDefaultWidth:Number = LayoutSettings.intDefaultWidth;
		private var intDefaultHeight:Number = LayoutSettings.intDefaultHeight;
		private const intDefaultHeightForIphone5:Number = LayoutSettings.intDefaultHeightForIphone5;
		private var isIphone5Layout:Boolean = false;
		private var bg:Sprite = null;
		
		private var gameFlow:GameType3Flow = null;
		private var gameHint:MovieClip = null;
		private var lottery:Lottery = null;
		
		public function Month10Game(... args) {
			// constructor code
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}

		private function init(e:Event) {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(Event.REMOVED_FROM_STAGE, destructor);
			
			sharedObject = SharedObject.getLocal("GameRecord");
			
			eventChannel = EventChannel.getInstance();
			eventChannel.writeEvent(new TitleBarEvent(TitleBarEvent.SET_TITLE, -1, "守護愛情，拼出幸福藍圖"));
		
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
			gameHint = (isIphone5Layout) ? new Month10HintIphone5() : new Month10HintIphone4();
			var intMonth:int = date.month + 1;
			
			CAMEO::Debug {
				intMonth = 10;
			}
			
			if (intMonth != 10) {
				if (gameHint.hasOwnProperty("datePeriod")) {
					gameHint.datePeriod.text = "活動已結束";
					var textFormat:TextFormat = gameHint.datePeriod.getTextFormat();
					textFormat.color = 0xFF0000;
					gameHint.datePeriod.setTextFormat(textFormat);
				}
			}
		}
		
		private function initFlow() {
			var puzzleOriginalPicture:Sprite = new Month10PuzzleOriginal();
			var lstPuzzles:Array = [
				new Month10Puzzle1(),
				new Month10Puzzle2(),
				new Month10Puzzle3(),
				new Month10Puzzle4(),
				new Month10Puzzle5(),
				new Month10Puzzle6(),
				new Month10Puzzle7(),
				new Month10Puzzle8(),
				new Month10Puzzle9()
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
			trace("Month10Game.as / onGameFlowFinish.");
			
			if (date < dateBeginVerify || date >= dateEndVerify) {
				eventChannel.writeEvent(new Event(GameMakerEvent.EXPORT_MOVIE_FINISH));
				return;
			}
			
			if (sharedObject.data.hasOwnProperty("isMonth9GameWinned")) {
				eventChannel.writeEvent(new Event(GameMakerEvent.EXPORT_MOVIE_FINISH));
			} else {
				lottery = new Lottery("Type2");
				this.addChild(lottery);
			}
		}
		
		private function removeLottery() {
			if (lottery) this.removeChild(lottery);
			lottery = null;
		}
	}
	
}
