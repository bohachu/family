package GameResource {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.text.TextField;
	import tw.cameo.IAddRemoveListener;
	import FamilyCenterInfo;
	import FamilyEvent.FamilyCenterListEvent;
	import tw.cameo.EventChannel;
	
	public class FamilyCenterList extends MovieClip implements IAddRemoveListener {
		
		private var eventChannel:EventChannel = null;
		
		private const intItemHeight:int = 85;
		private var lstItem:Array = new Array();
		private var lstCenter:Array = new Array();
		
		public function FamilyCenterList() {
			// constructor code
			this.addEventListener(Event.ADDED_TO_STAGE, init);
			createList();
			addEventListenerFunc();
		}

		private function init(e:Event) {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(Event.REMOVED_FROM_STAGE, destructor);
			
			eventChannel = EventChannel.getInstance();
		}
		
		private function destructor(e:Event = null) {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destructor);
			removeEventListenerFunc();
			removeList();
		}
		
		private function createList() {
			lstCenter = FamilyCenterInfo.lstCenterData;
			for (var i=0; i<lstCenter.length; i++) {
				var item:MovieClip = new ItemElement();
				item.name = String(i);
				
				var labelTextField:TextField = item.getChildByName("ItemLabel") as TextField;
				labelTextField.text = lstCenter[i]["name"];
				item.y = i*intItemHeight;
				lstItem.push(item);
				this.addChild(item);
			}
		}
		
		private function removeList() {
			for (var i=0; i<lstItem.length; i++) {
				var item:MovieClip = lstItem[i] as MovieClip;
				this.removeChild(item);
				item = null;
			}
		}
		
		public function addEventListenerFunc():void {
			for (var i=0; i<lstItem.length; i++) {
				(lstItem[i] as MovieClip).addEventListener(MouseEvent.CLICK, onItemClick);
			}
		}
		
		public function removeEventListenerFunc():void {
			for (var i=0; i<lstItem.length; i++) {
				(lstItem[i] as MovieClip).removeEventListener(MouseEvent.CLICK, onItemClick);
			}
		}
		
		private function onItemClick(e:MouseEvent) {
			var intCenterId:int = int(e.target.parent.name);
			eventChannel.writeEvent(new FamilyCenterListEvent(FamilyCenterListEvent.CLICK_CENTER, intCenterId));
		}
	}
	
}
