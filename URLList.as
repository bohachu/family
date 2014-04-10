package {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.utils.getDefinitionByName;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.sensors.Geolocation;
	import flash.events.GeolocationEvent;
	import tw.cameo.net.HttpLink;
	import tw.cameo.NavigateTool;
	import tw.cameo.LayoutManager;
	import tw.cameo.LayoutSettings;
	import tw.cameo.EventChannel;
	import tw.cameo.DragAndSlide;
	import FamilyCenterInfo;
	import GameResource.FamilyCenterList;
	import FamilyEvent.FamilyCenterListEvent;
	
	public class URLList extends MovieClip {

		private var eventChannel:EventChannel = null;
		
		private var intDefaultWidth:Number = LayoutSettings.intDefaultWidth;
		private var intDefaultHeight:Number = LayoutSettings.intDefaultHeight;
		private const intDefaultHeightForIphone5:Number = LayoutSettings.intDefaultHeightForIphone5;
		private var isIphone5Layout:Boolean = false;
		private var bg:Sprite = null;
		
		private var familyCenterList:FamilyCenterList = null;
		private var dragAndSlide:DragAndSlide = null;
		private var intSelectCenterId:int = 0;
		
		private var movieClipCenterInfo:MovieClip = null;
		
		private var _geo:Geolocation = null;
		
		public function URLList(... args) {
			// constructor code
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}

		private function init(e:Event) {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(Event.REMOVED_FROM_STAGE, destructor);
			
			eventChannel = EventChannel.getInstance();
			eventChannel.addEventListener(FamilyCenterListEvent.CLICK_CENTER, onCenterClick);
			
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
			
			if (_geo) _geo.removeEventListener(GeolocationEvent.UPDATE, updateHandler);
			_geo = null;
			
			removeMovieClipCenterInfo();
			
			dragAndSlide.dispose();
			dragAndSlide = null;
			
			removeBackground();
			eventChannel.removeEventListener(FamilyCenterListEvent.CLICK_CENTER, onCenterClick);
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
		
		private function onCenterClick(e:FamilyCenterListEvent) {
			intSelectCenterId = e.intCenterId;
			showCenterInfo();
		}
		
		private function showCenterInfo(){
			if(movieClipCenterInfo) removeMovieClipCenterInfo();
			
			movieClipCenterInfo = new MovieClipCenterInfo();
//			movieClipCenterInfo.x = intDefaultWidth/2;
//			movieClipCenterInfo.y = intDefaultHeight/2;
			
			var textFormat:TextFormat = null;
			movieClipCenterInfo.centerName.text = FamilyCenterInfo.lstCenterData[intSelectCenterId].name;
			textFormat = movieClipCenterInfo.centerName.getTextFormat();
			textFormat.underline = true;
			movieClipCenterInfo.centerName.setTextFormat(textFormat);
			
			movieClipCenterInfo.telNumber.text = FamilyCenterInfo.lstCenterData[intSelectCenterId].tel;
			textFormat = movieClipCenterInfo.telNumber.getTextFormat();
			textFormat.underline = true;
			movieClipCenterInfo.telNumber.setTextFormat(textFormat);
			
			movieClipCenterInfo.faxNumber.text = FamilyCenterInfo.lstCenterData[intSelectCenterId].fax;
			movieClipCenterInfo.address.text = FamilyCenterInfo.lstCenterData[intSelectCenterId].address;
			
			movieClipCenterInfo.centerName.addEventListener(MouseEvent.CLICK, handleOpenUrl);
			movieClipCenterInfo.btnMap.addEventListener(MouseEvent.CLICK, handleOpenMap);
			movieClipCenterInfo.telNumber.addEventListener(MouseEvent.CLICK, handleCallPhone);
			movieClipCenterInfo.addEventListener(MouseEvent.CLICK, handleClosemovieClipCenterInfo);
			this.addChild(movieClipCenterInfo);
		}		
		
		private function removeMovieClipCenterInfo() {
			if (movieClipCenterInfo) {
				movieClipCenterInfo.centerName.removeEventListener(MouseEvent.CLICK, handleOpenUrl);
				movieClipCenterInfo.btnMap.removeEventListener(MouseEvent.CLICK, handleOpenMap);
				movieClipCenterInfo.telNumber.removeEventListener(MouseEvent.CLICK, handleCallPhone);
				movieClipCenterInfo.removeEventListener(MouseEvent.CLICK, handleClosemovieClipCenterInfo);
				this.removeChild(movieClipCenterInfo);
			}
			movieClipCenterInfo = null;
		}
		
		private function handleClosemovieClipCenterInfo(e:MouseEvent){
			removeMovieClipCenterInfo();
		}
		
		private function handleOpenUrl(e:MouseEvent) {
			trace("URLList.as / handleOpenUrl");
			e.stopImmediatePropagation();
			e.preventDefault();
			HttpLink.openUrl(FamilyCenterInfo.lstCenterData[intSelectCenterId].url);
		}
		
		private function handleOpenMap(e:MouseEvent){
			trace("URLList.as / handleOpenMap");
			e.stopImmediatePropagation();
			e.preventDefault();
			_geo = new Geolocation();
			_geo.addEventListener(GeolocationEvent.UPDATE, updateHandler);
		}
		
		private function updateHandler(e:GeolocationEvent){
			_geo.removeEventListener(GeolocationEvent.UPDATE, updateHandler);
			var _strGeoLocation = e.latitude.toString() + "," + e.longitude.toString();
			_geo = null;
			NavigateTool.openRouteMapApp(_strGeoLocation,FamilyCenterInfo.lstCenterData[intSelectCenterId].address);
		}
		
		private function handleCallPhone(e:MouseEvent){
			trace("URLList.as / handleCallPhone");
			e.stopImmediatePropagation();
			e.preventDefault();
			NavigateTool.callPhone(FamilyCenterInfo.lstCenterData[intSelectCenterId].tel);
		}
	}
	
}
