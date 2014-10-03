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
	
	public class Month3Game extends MovieClip {

		private var eventChannel:EventChannel = null;
		private var sharedObject:SharedObject = null;
		
		private var date:Date = new Date();
		private var dateBeginVerify:Date = new Date(2014, 2, 1);
		private var dateEndVerify:Date = new Date(2014, 3, 1);
		
		private var intDefaultWidth:Number = LayoutSettings.intDefaultWidth;
		private var intDefaultHeight:Number = LayoutSettings.intDefaultHeight;
		private const intDefaultHeightForIphone5:Number = LayoutSettings.intDefaultHeightForIphone5;
		private var isIphone5Layout:Boolean = false;
		private var bg:Sprite = null;
		
		private var gameFlow:GameType3Flow = null;
		private var gameHint:MovieClip = null;
		private var lottery:Lottery = null;
		
		public function Month3Game(... args) {
			// constructor code
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}

		private function init(e:Event) {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(Event.REMOVED_FROM_STAGE, destructor);
			
			sharedObject = SharedObject.getLocal("GameRecord");
			
			eventChannel = EventChannel.getInstance();
			eventChannel.writeEvent(new TitleBarEvent(TitleBarEvent.SET_TITLE, -1, "親子共讀"));
		
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
			gameHint = (isIphone5Layout) ? new Month3HintIphone5() : new Month3HintIphone4();
		}
		
		private function initFlow() {
			var puzzleOriginalPicture:Sprite = new Month3PuzzleOriginal();
			var lstPuzzles:Array = [
				new Month3Puzzle1(),
				new Month3Puzzle2(),
				new Month3Puzzle3(),
				new Month3Puzzle4(),
				new Month3Puzzle5(),
				new Month3Puzzle6(),
				new Month3Puzzle7(),
				new Month3Puzzle8(),
				new Month3Puzzle9()
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
			trace("Month3Game.as / onGameFlowFinish.");
			sharedObject = SharedObject.getLocal("GameRecord");
			removeGameFlow();
			
			if (date < dateBeginVerify || date >= dateEndVerify) {
				eventChannel.writeEvent(new Event(GameMakerEvent.EXPORT_MOVIE_FINISH));
				return;
			}
			
			if (sharedObject.data.hasOwnProperty("isMonth3GameWinned")) {
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
