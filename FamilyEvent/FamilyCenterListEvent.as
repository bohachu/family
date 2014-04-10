package FamilyEvent {
	
	import flash.events.Event;
	
	public class FamilyCenterListEvent extends Event {
		
		static public const CLICK_CENTER:String = "FamilyCenterListEvent.CLICK_CENTER";
		public var intCenterId:int = 0;

		public function FamilyCenterListEvent(strEvent:String, intCenterIdIn:int = 0) {
			// constructor code
			super(strEvent, true, false);
			intCenterId = intCenterIdIn;
		}

	}
	
}
