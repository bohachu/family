package  {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.utils.getDefinitionByName;
	import flash.text.TextField;
	import flash.net.SharedObject;
	import tw.cameo.LayoutManager;
	import tw.cameo.LayoutSettings;
	import tw.cameo.EventChannel;
	import tw.cameo.RandomRotateObject;
	import FamilyCenterInfo;
	import FamilyEvent.GameEvent;
	import GameResource.Month2Game;
	import GameResource.Month3Game;
	import GameResource.Month4Game;
	import GameResource.Month5Game;
	import GameResource.Month6Game;
	import GameResource.Month7Game;
	
	import tw.cameo.ToastMessage;

	public class Game extends MovieClip {

		private var eventChannel:EventChannel = null;
		
		private var intDefaultWidth:Number = LayoutSettings.intDefaultWidth;
		private var intDefaultHeight:Number = LayoutSettings.intDefaultHeight;
		private const intDefaultHeightForIphone5:Number = LayoutSettings.intDefaultHeightForIphone5;
		private var isIphone5Layout:Boolean = false;
		private var bg:Sprite = null;
		
		private var gameSharedObject:SharedObject = null;
		private var date:Date = new Date();
		private var intNowMonth:int = date.month + 1;
		private var lstButtons:Array = new Array();
		private var intSelectMonth:int = 2;
		private var intIconInitY:int = 120;
		private const intIconInitYIphone5:int = 165;
		private var intIconYThreshold:int = 220;
		private const intIconYThresholdIphone5:int = 245;
		
		private var noGiftMessage:MovieClip = null;
		
		public function Game(... args) {
			// constructor code
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}

		private function init(e:Event) {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(Event.REMOVED_FROM_STAGE, destructor);
			
			eventChannel = EventChannel.getInstance();
			gameSharedObject = SharedObject.getLocal("GameData");
			
			LayoutManager.setLayout(this);
			isIphone5Layout = LayoutManager.useIphone5Layout();
			
			if (isIphone5Layout) {
				changeLayoutForIphone5();
			}
			createBackground();
			initGameIcon();
			
			CAMEO::IOS {
				if (!gameSharedObject.data.hasOwnProperty("alreadyShowActivityGiftHint")) {
					gameSharedObject.data["alreadyShowActivityGiftHint"] = true;
					gameSharedObject.flush();
					ToastMessage.showToastMessage(this, "所有活動贈品皆由各縣市家庭教育中心提供，與蘋果官方無任何關係。");
				}
			}
		}
		
		private function destructor(e:Event = null) {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destructor);
			removeNoGiftMessage();
			removeButtonListener();
			removeAllChildren();
			bg = null;
			gameSharedObject = null;
			ToastMessage.dispose();
			eventChannel.removeEventListener(ToastMessage.CLICK_OK, onClickOk);
			eventChannel = null;
		}
		
		private function changeLayoutForIphone5() {
			intIconInitY = intIconInitYIphone5;
			intIconYThreshold = intIconYThresholdIphone5;
		}
		
		private function createBackground() {
			bg = new GameBackground();
			this.addChild(bg);
		}
		
		private function initGameIcon() {
			CAMEO::Debug {
				intNowMonth = 7;
			}
			
			for (var i=0; i<11; i++) {
				var gameIconClass:Class;
				try {
					if (i+2 <= intNowMonth) {
						gameIconClass = getDefinitionByName("Month" + String(i+2) + "Button") as Class;
						var gameButton:SimpleButton = new gameIconClass();
						gameButton.name = String(i+2);
						if (i+2 < intNowMonth) {
							gameButton.x = (i%3)*200 + 120;
							gameButton.y = Math.floor(i/3)*intIconYThreshold + intIconInitY;
							gameButton.addEventListener(MouseEvent.CLICK, onGameButtonClick);
							this.addChild(gameButton);
							lstButtons.push(gameButton);
						}
						if (i+2 == intNowMonth) {
							var gameButtonMovieClip:MovieClip = new RandomRotateObject(gameButton);
							gameButtonMovieClip.x = (i%3)*200 + 120;
							gameButtonMovieClip.y = Math.floor(i/3)*intIconYThreshold + intIconInitY;
							gameButtonMovieClip.scaleX = gameButtonMovieClip.scaleY = 1.2;
							gameButtonMovieClip.addEventListener(MouseEvent.CLICK, onGameButtonClick);
							this.addChild(gameButtonMovieClip);
							lstButtons.push(gameButtonMovieClip);
						}
					}
				} catch (e:Error) {
					var gameIcon:MovieClip = new CommingSoonIcon();
					gameIcon.monthTextField.text = getChineseMonth(i+2);
					gameIcon.x = (i%3)*200 + 120;
					gameIcon.y = Math.floor(i/3)*intIconYThreshold + intIconInitY;
					this.addChild(gameIcon);
				}
				if (i+2 > intNowMonth) {
					var gameIcon:MovieClip = new CommingSoonIcon();
					gameIcon.monthTextField.text = getChineseMonth(i+2);
					gameIcon.x = (i%3)*200 + 120;
					gameIcon.y = Math.floor(i/3)*intIconYThreshold + intIconInitY;
					this.addChild(gameIcon);
				}
			}
		}
		
		private function removeButtonListener() {
			for (var i=0; i<lstButtons.length; i++) {
				lstButtons[i].removeEventListener(MouseEvent.CLICK, onGameButtonClick);
			}
			lstButtons.length = 0;
			lstButtons = null;
		}
		
		private function removeAllChildren() {
			while(this.numChildren) {
				var obj = this.getChildAt(0);
				this.removeChild(obj);
				obj = null;
			}
		}
		
		private function onGameButtonClick(e:MouseEvent) {
			intSelectMonth = int(e.target.name);
			
			if (intSelectMonth == intNowMonth) {
				eventChannel.writeEvent(new GameEvent(GameEvent.CLICK_GAME, intSelectMonth));
			} else {
				showNoGiftMessage();
			}
		}
		
		private function showNoGiftMessage() {
			ToastMessage.showConfrim(this, String(intSelectMonth) + " 月贈獎活動已結束！", "玩遊戲", "取消");
			eventChannel.addEventListener(ToastMessage.CLICK_OK, onClickOk);
		}
		
		private function onClickOk(e:Event) {
			eventChannel.removeEventListener(ToastMessage.CLICK_OK, onClickOk);
			eventChannel.writeEvent(new GameEvent(GameEvent.CLICK_GAME, intSelectMonth));
		}
		
		private function removeNoGiftMessage() {
			if (noGiftMessage) {
				noGiftMessage.removeEventListener(MouseEvent.CLICK, onCancelButtonClick);
				var goPlayButton:SimpleButton = noGiftMessage.getChildByName("PlayButton") as SimpleButton;
				goPlayButton.removeEventListener(MouseEvent.CLICK, onGoPlayButtonClick);
				var cancelButton:SimpleButton = noGiftMessage.getChildByName("CancelButton") as SimpleButton;
				cancelButton.removeEventListener(MouseEvent.CLICK, onCancelButtonClick);
				this.removeChild(noGiftMessage);
			}
			noGiftMessage = null;
		}
		
		private function onGoPlayButtonClick(e:MouseEvent) {
			e.stopImmediatePropagation();
			e.preventDefault();
			removeNoGiftMessage();
			eventChannel.writeEvent(new GameEvent(GameEvent.CLICK_GAME, intSelectMonth));
		}
		
		private function onCancelButtonClick(e:MouseEvent) {
			removeNoGiftMessage();
		}
		
		private function getChineseMonth(intMonth:int):String {
			switch (intMonth) {
				case 1: return "一月";
				case 2: return "二月";
				case 3: return "三月";
				case 4: return "四月";
				case 5: return "五月";
				case 6: return "六月";
				case 7: return "七月";
				case 8: return "八月";
				case 9: return "九月";
				case 10: return "十月";
				case 11: return "十一月";
				case 12: return "十二月";
			}
			return "二月";
		}
		
		private function dummyFunctionForDynamicCreate() {
			var month2Button:Month2Button = null;
			var month3Button:Month3Button = null;
			var month4Button:Month4Button = null;
			var month5Button:Month5Button = null;
			var month6Button:Month6Button = null;
			var month7Button:Month7Button = null;
			var month8Button:Month8Button = null;
			var month9Button:Month9Button = null;
			var month10Button:Month10Button = null;
			var month11Button:Month11Button = null;
			var month12Button:Month12Button = null;
			
			var month2Game:Month2Game = null;
			var month3Game:Month3Game = null;
			var month4Game:Month4Game = null;
			var month5Game:Month5Game = null;
			var month6Game:Month6Game = null;
			var month7Game:Month7Game = null;
		}
	}
	
}
