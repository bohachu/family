package GameResource {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.utils.getDefinitionByName;
	import tw.cameo.LayoutManager;
	import tw.cameo.LayoutSettings;
	import tw.cameo.EventChannel;
	import tw.cameo.events.GameMakerEvent;
	import tw.cameo.events.TitleBarEvent;
	import GameResource.GameType2Flow;
	import GameResource.Month12;
	import GameResource.Lottery;
	import flash.net.SharedObject;
	
	public class Month12Game extends MovieClip {

		private var eventChannel:EventChannel = null;
		private var sharedObject:SharedObject = null;
		
		private var date:Date = new Date();
		
		private var intDefaultWidth:Number = LayoutSettings.intDefaultWidth;
		private var intDefaultHeight:Number = LayoutSettings.intDefaultHeight;
		private const intDefaultHeightForIphone5:Number = LayoutSettings.intDefaultHeightForIphone5;
		private var isIphone5Layout:Boolean = false;
		private var bg:Sprite = null;
		
		private var gameFlow:GameType2Flow = null;
		private var gameHint:MovieClip = null;
		private var lottery:Lottery = null;
		
		public function Month12Game(... args) {
			// constructor code
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}

		private function init(e:Event) {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(Event.REMOVED_FROM_STAGE, destructor);
			
			eventChannel = EventChannel.getInstance();
			eventChannel.writeEvent(new TitleBarEvent(TitleBarEvent.SET_TITLE, -1, GameTitleInfo.lstStrTitle[11]));
		
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
			gameHint = (isIphone5Layout) ? new Month12HintIphone5() : new Month12HintIphone4();
		}
		
		private function initFlow() {
			gameFlow = new GameType2Flow(this, gameHint, Month12, "December.jpg", "12 月份活動");
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
			trace("Month12Game.as / onGameFlowFinish.");
			removeGameFlow();
			var intMonth:int = date.month + 1;
			
			sharedObject = SharedObject.getLocal("GameRecord");
			
			CAMEO::Debug {
				intMonth = 12;
			}
			
			CAMEO::NO_ANE {
				delete(sharedObject.data["isMonth12GameWinned"]);
				sharedObject.flush();
			}
			
			if (intMonth != 12) {
				eventChannel.writeEvent(new Event(GameMakerEvent.EXPORT_MOVIE_FINISH));
			}
			
			if (intMonth == 12) {
				if (sharedObject.data.hasOwnProperty("isMonth12GameWinned")) {
					eventChannel.writeEvent(new Event(GameMakerEvent.EXPORT_MOVIE_FINISH));
				} else {
					lottery = new Lottery("Type2");
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
