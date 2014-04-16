package GameResource {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import tw.cameo.IAddRemoveListener;
	
	public class Month6QuestionList extends MovieClip implements IAddRemoveListener {
		
		public static const ALL_ANSWER_CORRECT:String = "Month6QuestionList.ALL_ANSWER_CORRECT";
		public static const WRONG_ANSWER:String = "Month6QuestionList.WRONG_ANSWER";
		
		private var question:MovieClip = null;
		private var lstAnswer:Array = [1, 1, 1, 1];
		private var lstCorrectAnswer:Array = [2, 1, 2, 3];
		private var isAllAnswerCorrect:Boolean = true;

		public function Month6QuestionList() {
			// constructor code
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
			removeEventListenerFunc();
		}
		
		private function createList() {
			question = new Month6Question();
			this.addChild(question);
		}
		
		private function onDoneClick(e:MouseEvent) {
			isAllAnswerCorrect = true;
			for (var i:int=0; i<lstAnswer.length; i++) {
				if (lstAnswer[i] != lstCorrectAnswer[i]) isAllAnswerCorrect = false; 
			}
			if (!isAllAnswerCorrect) this.dispatchEvent(new Event(Month6QuestionList.WRONG_ANSWER));
			if (isAllAnswerCorrect) this.dispatchEvent(new Event(Month6QuestionList.ALL_ANSWER_CORRECT));
		}
		
		private function onAnswerClick(e:MouseEvent) {
			var strAnswerName:String = e.target.parent.name;
			var intQuestionNumber:int = int(strAnswerName.charAt(1));
			var intAnswerNumber:int = int(strAnswerName.charAt(3));
			trace(intQuestionNumber, intAnswerNumber);
			
			for(var i:int=1; i<4; i++) {
				if (i == intAnswerNumber) {
					question["a" + String(intQuestionNumber) + "_" + String(i)].selectIcon.visible = true;
				} else {
					question["a" + String(intQuestionNumber) + "_" + String(i)].selectIcon.visible = false;
				}
			}
			
			lstAnswer[intQuestionNumber-1] = intAnswerNumber;
		}
		
		public function addEventListenerFunc():void {
			question.doneButton.addEventListener(MouseEvent.CLICK, onDoneClick);
			question.a1_1.addEventListener(MouseEvent.CLICK, onAnswerClick);
			question.a1_2.addEventListener(MouseEvent.CLICK, onAnswerClick);
			question.a1_3.addEventListener(MouseEvent.CLICK, onAnswerClick);
			question.a2_1.addEventListener(MouseEvent.CLICK, onAnswerClick);
			question.a2_2.addEventListener(MouseEvent.CLICK, onAnswerClick);
			question.a2_3.addEventListener(MouseEvent.CLICK, onAnswerClick);
			question.a3_1.addEventListener(MouseEvent.CLICK, onAnswerClick);
			question.a3_2.addEventListener(MouseEvent.CLICK, onAnswerClick);
			question.a3_3.addEventListener(MouseEvent.CLICK, onAnswerClick);
			question.a4_1.addEventListener(MouseEvent.CLICK, onAnswerClick);
			question.a4_2.addEventListener(MouseEvent.CLICK, onAnswerClick);
			question.a4_3.addEventListener(MouseEvent.CLICK, onAnswerClick);
		}
		
		public function removeEventListenerFunc():void {
			question.doneButton.removeEventListener(MouseEvent.CLICK, onDoneClick);
			question.a1_1.removeEventListener(MouseEvent.CLICK, onAnswerClick);
			question.a1_2.removeEventListener(MouseEvent.CLICK, onAnswerClick);
			question.a1_3.removeEventListener(MouseEvent.CLICK, onAnswerClick);
			question.a2_1.removeEventListener(MouseEvent.CLICK, onAnswerClick);
			question.a2_2.removeEventListener(MouseEvent.CLICK, onAnswerClick);
			question.a2_3.removeEventListener(MouseEvent.CLICK, onAnswerClick);
			question.a3_1.removeEventListener(MouseEvent.CLICK, onAnswerClick);
			question.a3_2.removeEventListener(MouseEvent.CLICK, onAnswerClick);
			question.a3_3.removeEventListener(MouseEvent.CLICK, onAnswerClick);
			question.a4_1.removeEventListener(MouseEvent.CLICK, onAnswerClick);
			question.a4_2.removeEventListener(MouseEvent.CLICK, onAnswerClick);
			question.a4_3.removeEventListener(MouseEvent.CLICK, onAnswerClick);
		}
	}
	
}
