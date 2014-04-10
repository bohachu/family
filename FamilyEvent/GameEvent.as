package FamilyEvent {
	
	import flash.events.Event;
	
	public class GameEvent extends Event {
		
		static public const CLICK_GAME:String = "GameEvent.CLICK_GAME";
		public var intSelectMonth:int = 2;

		public function GameEvent(strEvent:String, intSelectMonthIn:int = 2) {
			// constructor code
			super(strEvent, true, false);
			intSelectMonth = intSelectMonthIn;
		}

	}
	
}
