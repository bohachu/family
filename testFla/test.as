package  {
	
	import flash.display.MovieClip;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.events.Event;
	import GameResource.ConfirmFamilyCenter;

	public class test extends MovieClip {
		
		public function test() {
			// constructor code
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event) {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			var testObject:ConfirmFamilyCenter = new ConfirmFamilyCenter(0, 0, 3);
			this.addChild(testObject);
		}
	}
	
}
