package GameResource {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.DisplayObjectContainer;
	
	import tw.cameo.IAddRemoveListener;
	import tw.cameo.ToastMessage;
	import tw.cameo.EventChannel;
	
	public class Month7QuestionList extends MovieClip implements IAddRemoveListener {
		
		public static const QUESTION_FINISH:String = "Month7QuestionList.QUESTION_FINISH";
		
		private var eventChannel:EventChannel = EventChannel.getInstance();
		private var _container:DisplayObjectContainer = null;
		private var question:MovieClip = null;
		private var lstType:Array = [1, 2, 0, 5, 4, 3, 1, 2, 5, 4, 3, 0, 2, 0, 5, 4, 3, 1];
		private var lstTypeCount:Array = [0, 0, 0, 0, 0, 0];
		private var lstTypeContent:Array = [
			"「A.友伴關係之愛」", "「B.羅曼蒂克之愛」", "「C.遊戲人間之愛」", "「D.犧牲奉獻之愛」", "「E.狂戀依附之愛」", "「F.理性現實之愛」"
		];
		private var lstFinalType:Array = null;

		public function Month7QuestionList(_containerIn:DisplayObjectContainer) {
			// constructor code
			_container = _containerIn;
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event) {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(Event.REMOVED_FROM_STAGE, destructor);
			createList();
			addEventListenerFunc();
		}
		
		private function destructor(e:Event) {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destructor);
			eventChannel.removeEventListener(ToastMessage.CLOSE_MESSAGE, onCloseMessage);
			removeEventListenerFunc();
			removeAllListener();
			_container = null;
			lstFinalType = null;
			lstType = null;
			lstTypeCount = null;
			lstTypeContent = null;
		}
		
		private function createList() {
			question = new Month7Question();
			this.addChild(question);
		}
		
		private function onDoneClick(e:MouseEvent) {
			lstFinalType = new Array();
			var intCount:int = 0;
			var strMessage:String = "你屬於";
			
			for (var i:int = 0; i<lstTypeCount.length; i++) {
				if (lstTypeCount[i] > intCount) intCount = lstTypeCount[i];
			}
			
			if (intCount == 0) {
				ToastMessage.showToastMessage(_container, "請勾選項目！");
			}
			
			if (intCount > 0) {
				for (var j:int = 0; j<lstTypeCount.length; j++) {
					if (lstTypeCount[j] == intCount) lstFinalType.push(j);
				}
				
				for (var k:int = 0; k<lstFinalType.length; k++) {
					strMessage += lstTypeContent[lstFinalType[k]];
				}
				ToastMessage.showToastMessage(_container, strMessage);
				eventChannel.addEventListener(ToastMessage.CLOSE_MESSAGE, onCloseMessage);
			}
		}
		
		private function onCloseMessage(e:Event) {
			eventChannel.removeEventListener(ToastMessage.CLOSE_MESSAGE, onCloseMessage);
			this.dispatchEvent(new Event(Month7QuestionList.QUESTION_FINISH));
		}
		
		private function onAnswerClick(e:MouseEvent) {
			var strAnswerName:String = e.target.name;
			
			var intQuestionNumber:int = int(strAnswerName.slice(1));
			
			if (e.target.CheckIcon.visible) {
				e.target.CheckIcon.visible = false;
				lstTypeCount[lstType[intQuestionNumber-1]]--;
			} else {
				e.target.CheckIcon.visible = true;
				lstTypeCount[lstType[intQuestionNumber-1]]++;
			}
		}
		
		public function addEventListenerFunc():void {
			question.doneButton.addEventListener(MouseEvent.CLICK, onDoneClick);
			question.q1.addEventListener(MouseEvent.MOUSE_DOWN, addMouseUpListener);
			question.q2.addEventListener(MouseEvent.MOUSE_DOWN, addMouseUpListener);
			question.q3.addEventListener(MouseEvent.MOUSE_DOWN, addMouseUpListener);
			question.q4.addEventListener(MouseEvent.MOUSE_DOWN, addMouseUpListener);
			question.q5.addEventListener(MouseEvent.MOUSE_DOWN, addMouseUpListener);
			question.q6.addEventListener(MouseEvent.MOUSE_DOWN, addMouseUpListener);
			question.q7.addEventListener(MouseEvent.MOUSE_DOWN, addMouseUpListener);
			question.q8.addEventListener(MouseEvent.MOUSE_DOWN, addMouseUpListener);
			question.q9.addEventListener(MouseEvent.MOUSE_DOWN, addMouseUpListener);
			question.q10.addEventListener(MouseEvent.MOUSE_DOWN, addMouseUpListener);
			question.q11.addEventListener(MouseEvent.MOUSE_DOWN, addMouseUpListener);
			question.q12.addEventListener(MouseEvent.MOUSE_DOWN, addMouseUpListener);
			question.q13.addEventListener(MouseEvent.MOUSE_DOWN, addMouseUpListener);
			question.q14.addEventListener(MouseEvent.MOUSE_DOWN, addMouseUpListener);
			question.q15.addEventListener(MouseEvent.MOUSE_DOWN, addMouseUpListener);
			question.q16.addEventListener(MouseEvent.MOUSE_DOWN, addMouseUpListener);
			question.q17.addEventListener(MouseEvent.MOUSE_DOWN, addMouseUpListener);
			question.q18.addEventListener(MouseEvent.MOUSE_DOWN, addMouseUpListener);
		}
		
		private function addMouseUpListener(e:MouseEvent) {
			e.target.addEventListener(MouseEvent.MOUSE_UP, onAnswerClick);
		}
		
		public function removeAllListener():void {
			question.doneButton.removeEventListener(MouseEvent.CLICK, onDoneClick);
			question.q1.removeEventListener(MouseEvent.MOUSE_DOWN, addMouseUpListener);
			question.q2.removeEventListener(MouseEvent.MOUSE_DOWN, addMouseUpListener);
			question.q3.removeEventListener(MouseEvent.MOUSE_DOWN, addMouseUpListener);
			question.q4.removeEventListener(MouseEvent.MOUSE_DOWN, addMouseUpListener);
			question.q5.removeEventListener(MouseEvent.MOUSE_DOWN, addMouseUpListener);
			question.q6.removeEventListener(MouseEvent.MOUSE_DOWN, addMouseUpListener);
			question.q7.removeEventListener(MouseEvent.MOUSE_DOWN, addMouseUpListener);
			question.q8.removeEventListener(MouseEvent.MOUSE_DOWN, addMouseUpListener);
			question.q9.removeEventListener(MouseEvent.MOUSE_DOWN, addMouseUpListener);
			question.q10.removeEventListener(MouseEvent.MOUSE_DOWN, addMouseUpListener);
			question.q11.removeEventListener(MouseEvent.MOUSE_DOWN, addMouseUpListener);
			question.q12.removeEventListener(MouseEvent.MOUSE_DOWN, addMouseUpListener);
			question.q13.removeEventListener(MouseEvent.MOUSE_DOWN, addMouseUpListener);
			question.q14.removeEventListener(MouseEvent.MOUSE_DOWN, addMouseUpListener);
			question.q15.removeEventListener(MouseEvent.MOUSE_DOWN, addMouseUpListener);
			question.q16.removeEventListener(MouseEvent.MOUSE_DOWN, addMouseUpListener);
			question.q17.removeEventListener(MouseEvent.MOUSE_DOWN, addMouseUpListener);
			question.q18.removeEventListener(MouseEvent.MOUSE_DOWN, addMouseUpListener);
		}
		
		public function removeEventListenerFunc():void {
			question.q1.removeEventListener(MouseEvent.MOUSE_UP, onAnswerClick);
			question.q2.removeEventListener(MouseEvent.MOUSE_UP, onAnswerClick);
			question.q3.removeEventListener(MouseEvent.MOUSE_UP, onAnswerClick);
			question.q4.removeEventListener(MouseEvent.MOUSE_UP, onAnswerClick);
			question.q5.removeEventListener(MouseEvent.MOUSE_UP, onAnswerClick);
			question.q6.removeEventListener(MouseEvent.MOUSE_UP, onAnswerClick);
			question.q7.removeEventListener(MouseEvent.MOUSE_UP, onAnswerClick);
			question.q8.removeEventListener(MouseEvent.MOUSE_UP, onAnswerClick);
			question.q9.removeEventListener(MouseEvent.MOUSE_UP, onAnswerClick);
			question.q10.removeEventListener(MouseEvent.MOUSE_UP, onAnswerClick);
			question.q11.removeEventListener(MouseEvent.MOUSE_UP, onAnswerClick);
			question.q12.removeEventListener(MouseEvent.MOUSE_UP, onAnswerClick);
			question.q13.removeEventListener(MouseEvent.MOUSE_UP, onAnswerClick);
			question.q14.removeEventListener(MouseEvent.MOUSE_UP, onAnswerClick);
			question.q15.removeEventListener(MouseEvent.MOUSE_UP, onAnswerClick);
			question.q16.removeEventListener(MouseEvent.MOUSE_UP, onAnswerClick);
			question.q17.removeEventListener(MouseEvent.MOUSE_UP, onAnswerClick);
			question.q18.removeEventListener(MouseEvent.MOUSE_UP, onAnswerClick);
		}
	}
	
}
