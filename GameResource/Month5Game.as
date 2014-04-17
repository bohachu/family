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
	import GameResource.Month5;
	import GameResource.Lottery;
	import GameTitleInfo;
	import flash.net.SharedObject;
	import flash.text.TextFormat;
	import flash.filesystem.File;
	
	public class Month5Game extends MovieClip {

		private var eventChannel:EventChannel = null;
		private var sharedObject:SharedObject = null;
		
		private var date:Date = new Date();
		
		private var intDefaultWidth:Number = LayoutSettings.intDefaultWidth;
		private var intDefaultHeight:Number = LayoutSettings.intDefaultHeight;
		private const intDefaultHeightForIphone5:Number = LayoutSettings.intDefaultHeightForIphone5;
		private var isIphone5Layout:Boolean = false;
		private var bg:Sprite = null;
		
		private const strJpgFileName:String = "May.jpg";
		private var gameFlow:GameType2Flow = null;
		private var gameHint:MovieClip = null;
		private var lottery:Lottery = null;
		
		public function Month5Game(... args) {
			// constructor code
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}

		private function init(e:Event) {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(Event.REMOVED_FROM_STAGE, destructor);
			
			eventChannel = EventChannel.getInstance();
			eventChannel.writeEvent(new TitleBarEvent(TitleBarEvent.SET_TITLE, -1, GameTitleInfo.lstStrTitle[4]));
		
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
			gameHint = (isIphone5Layout) ? new Month5HintIphone5() : new Month5HintIphone4();
			var intMonth:int = date.month + 1;
			if (intMonth > 5) {
				if (gameHint.hasOwnProperty("datePeriod")) {
					gameHint.datePeriod.text = "活動已結束";
					var textFormat:TextFormat = gameHint.datePeriod.getTextFormat();
					textFormat.color = 0xFF0000;
					gameHint.datePeriod.setTextFormat(textFormat);
				}
			}
		}
		
		private function initFlow() {
			gameFlow = new GameType2Flow(this, gameHint, Month5, strJpgFileName, "5 月份活動");
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
			trace("Month5Game.as / onGameFlowFinish.");
			removeGameFlow();
			var intMonth:int = date.month + 1;
			
			CAMEO::Debug {
				intMonth = 5;
			}
			
			sharedObject = SharedObject.getLocal("GameRecord");
			CAMEO::NO_ANE {
				delete(sharedObject.data["isMonth5GameWinned"]);
				sharedObject.flush();
			}
			
			if (intMonth != 5) {
				eventChannel.writeEvent(new Event(GameMakerEvent.EXPORT_MOVIE_FINISH));
			}
			
			if (intMonth == 5) {
				if (sharedObject.data.hasOwnProperty("isMonth5GameWinned")) {
					eventChannel.writeEvent(new Event(GameMakerEvent.EXPORT_MOVIE_FINISH));
				} else {
					var jpgFile:File = File.applicationStorageDirectory.resolvePath(strJpgFileName);
					var strJpgSavePath:String = jpgFile.nativePath;
					lottery = new Lottery("Type2", true, strJpgSavePath);
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
