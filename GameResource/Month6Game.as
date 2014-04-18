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
	
	import GameResource.Month6QuestionList;
	import GameResource.Lottery;
	import GameTitleInfo;
	
	public class Month6Game extends MovieClip {

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
		
		public function Month6Game(... args) {
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
			gameHint = (isIphone5Layout) ? new Month6HintIphone5() : new Month6HintIphone4();
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
			questionList = new Month6QuestionList();
			questionList.addEventListener(Month6QuestionList.ALL_ANSWER_CORRECT, onAllAnswerCorrect);
			questionList.addEventListener(Month6QuestionList.WRONG_ANSWER, onWrongAnswer);
			this.addChild(questionList);
			
			dragAndSlide = new DragAndSlide(questionList, intDefaultHeight-70, "Vertical");
		}
		
		private function removeQuestionList() {
			if (questionList) {
				dragAndSlide.dispose();
				questionList.removeEventListener(Month6QuestionList.ALL_ANSWER_CORRECT, onAllAnswerCorrect);
				questionList.removeEventListener(Month6QuestionList.WRONG_ANSWER, onWrongAnswer);
				this.removeChild(questionList);
			}
			
			dragAndSlide = null;
			questionList = null;
		}
		
		private function onAllAnswerCorrect(e:Event) {
			eventChannel.addEventListener(ToastMessage.CLOSE_MESSAGE, onCloseMessage);
			ToastMessage.showToastMessage(this, "恭喜全部答對！");
		}
		
		private function onWrongAnswer(e:Event) {
			ToastMessage.showToastMessage(this, "答案不正確，再想想看！");
		}
		
		private function onCloseMessage(e:Event) {
			eventChannel.removeEventListener(ToastMessage.CLOSE_MESSAGE, onCloseMessage);
			removeQuestionList();
			nextStep();
		}
		
		private function nextStep() {
			trace("Month6Game.as / nextStep.");
			var intMonth:int = date.month + 1;
			
			CAMEO::Debug {
				intMonth = 6;
			}
			
			if (intMonth != 6) {
				eventChannel.writeEvent(new Event(GameMakerEvent.EXPORT_MOVIE_FINISH));
			}
			
			if (intMonth == 6) {
				if (sharedObject.data.hasOwnProperty("isMonth6GameWinned")) {
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
