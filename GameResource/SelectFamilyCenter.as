package GameResource {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.utils.getDefinitionByName;
	import flash.text.TextField;
	import tw.cameo.LayoutManager;
	import tw.cameo.LayoutSettings;
	import tw.cameo.EventChannel;
	import GameResource.FamilyCenterList;
	import tw.cameo.DragAndSlide;
	
	public class SelectFamilyCenter extends MovieClip {

		private var eventChannel:EventChannel = null;
		
		private var intDefaultWidth:Number = LayoutSettings.intDefaultWidth;
		private var intDefaultHeight:Number = LayoutSettings.intDefaultHeight;
		private const intDefaultHeightForIphone5:Number = LayoutSettings.intDefaultHeightForIphone5;
		private var isIphone5Layout:Boolean = false;
		private var bg:Sprite = null;
		
		private var familyCenterList:FamilyCenterList = null;
		private var dragAndSlide:DragAndSlide = null;
		
		public function SelectFamilyCenter(... args) {
			// constructor code
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}

		private function init(e:Event) {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(Event.REMOVED_FROM_STAGE, destructor);
			
			eventChannel = EventChannel.getInstance();
			
			LayoutManager.setLayout(this);
			isIphone5Layout = LayoutManager.useIphone5Layout();
			
			if (isIphone5Layout) {
				changeLayoutForIphone5();
			}
			createBackground();
			initFamilyCenterList();
			initDragAndSlide();
		}
		
		private function destructor(e:Event = null) {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destructor);
			
			dragAndSlide.dispose();
			dragAndSlide = null;
			
			removeBackground();
			eventChannel = null;
		}
		
		private function changeLayoutForIphone5() {
			intDefaultHeight = intDefaultHeightForIphone5;
		}
		
		private function createBackground() {
			bg = new ListBackground();
			this.addChild(bg);
		}
		
		private function removeBackground() {
			if (bg) this.removeChild(bg);
			bg = null;
		}
		
		private function initFamilyCenterList() {
			familyCenterList = new FamilyCenterList();
			familyCenterList.x = 60;
			this.addChild(familyCenterList);
		}
		
		private function removeFamilyCenterList() {
			if (familyCenterList) this.removeChild(familyCenterList);
			familyCenterList = null;
		}
		
		private function initDragAndSlide() {
			dragAndSlide = new DragAndSlide(familyCenterList, intDefaultHeight-90, "Vertical", false, 0x000000, true);
		}
	}
	
}
