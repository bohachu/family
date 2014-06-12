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
	import tw.cameo.DragAndSlide;
	import tw.cameo.ToastMessage;
	
	import GameResource.Month7QuestionList;
	import GameResource.Lottery;
	import GameTitleInfo;
	
	public class Month7Game extends MovieClip {

		private var eventChannel:EventChannel = null;
		private var sharedObject:SharedObject = null;
		
		private var date:Date = new Date();
		
		private var intDefaultWidth:Number = LayoutSettings.intDefaultWidth;
		private var intDefaultHeight:Number = LayoutSettings.intDefaultHeight;
		private const intDefaultHeightForIphone5:Number = LayoutSettings.intDefaultHeightForIphone5;
		private var isIphone5Layout:Boolean = false;
		private var bg:Sprite = null;
		
		private var gameHint:MovieClip = null;
		private var questionList:MovieClip = null;
		private var dragAndSlide:DragAndSlide = null;
		private var lottery:Lottery = null;
		
		public function Month7Game(... args) {
			// constructor code
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}

		private function init(e:Event) {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(Event.REMOVED_FROM_STAGE, destructor);
			
			sharedObject = SharedObject.getLocal("GameRecord");
			
			eventChannel = EventChannel.getInstance();
			eventChannel.writeEvent(new TitleBarEvent(TitleBarEvent.SET_TITLE, -1, GameTitleInfo.lstStrTitle[5]));
		
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
			removeQuestionList();
			removeHint();
			removeBackground();
			sharedObject = null;
		}

		private function changeLayoutForIphone5() {
			intDefaultHeight = intDefaultHeightForIphone5;
		}
		
		private function createBackground() {
			bg = new ListBackground();
			this.addChild(bg);
		}
		
		private function removeBackground() {
			this.removeChild(bg);
			bg = null;
		}
		
		private function showHint() {
			gameHint = (isIphone5Layout) ? new Month7HintIphone5() : new Month7HintIphone4();
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
			initQuestionList();
		}
		
		private function initQuestionList() {
			questionList = new Month7QuestionList(this);
			questionList.addEventListener(Month7QuestionList.QUESTION_FINISH, onQuestionFinish);
			this.addChild(questionList);
			
			dragAndSlide = new DragAndSlide(questionList, intDefaultHeight-70, "Vertical", true, 0, true);
		}
		
		private function removeQuestionList() {
			if (questionList) {
				dragAndSlide.dispose();
				questionList.removeEventListener(Month7QuestionList.QUESTION_FINISH, onQuestionFinish);
				this.removeChild(questionList);
			}
			
			dragAndSlide = null;
			questionList = null;
		}
		
		private function onQuestionFinish(e:Event) {
			questionList.removeEventListener(Month7QuestionList.QUESTION_FINISH, onQuestionFinish);
			removeQuestionList();
			nextStep();
		}
		
		private function nextStep() {
			trace("Month7Game.as / nextStep.");
			var intMonth:int = date.month + 1;
			
			CAMEO::Debug {
				intMonth = 7;
			}
			
			if (intMonth != 7) {
				eventChannel.writeEvent(new Event(GameMakerEvent.EXPORT_MOVIE_FINISH));
			}
			
			if (intMonth == 7) {
				if (sharedObject.data.hasOwnProperty("isMonth7GameWinned")) {
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
