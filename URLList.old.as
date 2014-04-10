package  {
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageOrientation;
	import flash.display.StageScaleMode;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.events.StageOrientationEvent;
	import flash.events.ErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.net.NetworkInfo;
	import flash.net.NetworkInterface;
	import flash.globalization.DateTimeFormatter;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	import tw.cameo.NavigateTool;
	import tw.cameo.LayoutSettings;
	import tw.cameo.LayoutManager;
	import tw.cameo.InternetStatus;
	import com.thanksmister.touchlist.renderers.TouchListItemRenderer;
	import com.thanksmister.touchlist.events.ListItemEvent;
	import com.thanksmister.touchlist.controls.TouchList;
	import flash.sensors.Geolocation;
	import flash.events.GeolocationEvent;
	
	import FamilyCenterInfo;
	
	public class URLList extends MovieClip {
		private var intDefaultWidth:Number =  LayoutSettings.intDefaultWidth;
		private var intDefaultHeight:Number = LayoutSettings.intDefaultHeight;
		private const intDefaultHeightForIphone5:int = LayoutSettings.intDefaultHeightForIphone5;
		private var isIphone5Layout:Boolean = false;
		
		private var intItemHeight:Number = 100;
		//Need to add config string in fla Actionscript setting->Config constants tab : CONFIG::WEB_SERVER_URL
		private var strWebServerIP:String = CONFIG::WEB_SERVER_URL+"/taisugar/wp-content/plugins/CameoCoupon/taisugar_coupon_result.php";
		
		private var strUserid:String = "roy";
		private var intCatBelongto:int = 1;
		
		private var movieClipBoxYesNo:MovieClip = null;
		private var movieClipServerError:MovieClip = null;
		private var movieClipServerOK:MovieClip = null;
		private var movieclipServerInternetError:MovieClip = null;
		private var intSelectedCouponIndex:int = -1;
		private var arrCouponDesc:Array = new Array();
		private var couponDB:Array = new Array();
		
		private var touchList:TouchList;
		private var textOutput:TextField;
		private var stageOrientation:String = StageOrientation.DEFAULT;
		private var itemSelected:TouchListItemRenderer = null;
		
		private var internetStatus:InternetStatus;
		
		private var movieClipCenterInfo:MovieClip = null;
		private var movieClipCenterInfoBG:MovieClip = new MovieClipListBG();
		private var textField:TextField;
		private var textField2:TextField;
		
		private var _geo:Geolocation = null;
		
		public function URLList(...args) {
			// constructor code
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function init(e:Event) {
			
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			
			this.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
			this.addEventListener(Event.RESIZE, handleResize);
			
			LayoutManager.setLayout(this);
			isIphone5Layout = LayoutManager.useIphone5Layout();
			
			if (isIphone5Layout) {
				changeLayoutForIphone5();
			}
			
			// add our list and listener
			touchList = new TouchList(intDefaultWidth, intDefaultHeight);
			touchList.addEventListener(ListItemEvent.ITEM_SELECTED, handlelistItemSelected);
			this.addChild(touchList);
						
			// Fill our list with item rendreres that extend ITouchListRenderer.
			showCouponList();
		}
		
		private function changeLayoutForIphone5() {
			intDefaultHeight = intDefaultHeightForIphone5;
		}

		public function showCouponList(){
			var intNumCatCoupon:int = 0;
			var dateCurrentDate:Date = new Date(); //Get current date
			
			//closeAllPopupWindows();
			
			/*
			// No coupon data
			if(arrCouponDesc.length<=0){
				//showNoCouponActivity();
				return;
			}
			*/
			touchList.removeListItems();
			
			//Set touch list
			///for(var i:int = 0; i < arrCouponDesc.length; i++) {
			for(var i:int = 0; i < FamilyCenterInfo.lstCenterData.length; i++) {
					
					//if(arrCouponDesc[i].intBelongto != intCatBelongto) continue; 					
					//if(arrCouponDesc[i].dateEnd.time < dateCurrentDate.time) continue; // Coupon Outdated
					
					intNumCatCoupon = intNumCatCoupon +1;
					
					var item:TouchListItemRenderer = new TouchListItemRenderer(0x000000, 80);
					var movieclipMyCoupon:MovieClip = null;
					
					item.index = i;
					item.data = FamilyCenterInfo.lstCenterData[i].name; //arrCouponDesc[i].strTitle; //the textfield
					item.setMoviecliptype(4);
					//item.setTextColor(0x000000);
					movieclipMyCoupon = new MovieclipCouponBar();
					item.movieclipBG = movieclipMyCoupon;
					item.itemHeight = intItemHeight;
					item.itemWidth = intDefaultWidth;
			
					touchList.addListItem(item);
			}
			//Roy: Add an empty box to prevent last item unvisible
			if(arrCouponDesc.length > 0){
					var itemEmpty:TouchListItemRenderer = new TouchListItemRenderer();
					itemEmpty.index = arrCouponDesc.length;
					itemEmpty.data = "  "; //the textfield
					itemEmpty.itemHeight = intItemHeight;
					itemEmpty.itemWidth = intDefaultWidth;
					itemEmpty.setMoviecliptype(3);
					touchList.addListItem(itemEmpty);
			}
		}
		
		private function showCenterInfo(){
			if(movieClipCenterInfo) removeMovieClipCenterInfo();
			
			movieClipCenterInfo = new MovieClipCenterInfo();
			movieClipCenterInfo.x = intDefaultWidth/2;
			movieClipCenterInfo.y = intDefaultHeight/2;
			
			movieClipCenterInfo.centerName.text = FamilyCenterInfo.lstCenterData[intSelectedCouponIndex].name;
			movieClipCenterInfo.telNumber.text = FamilyCenterInfo.lstCenterData[intSelectedCouponIndex].tel;
			movieClipCenterInfo.faxNumber.text = FamilyCenterInfo.lstCenterData[intSelectedCouponIndex].fax;
			movieClipCenterInfo.address.text = FamilyCenterInfo.lstCenterData[intSelectedCouponIndex].address;
			
			movieClipCenterInfo.btnNo.addEventListener(MouseEvent.MOUSE_DOWN, handleClosemovieClipCenterInfo);
			movieClipCenterInfo.btnMap.addEventListener(MouseEvent.MOUSE_DOWN, handleOpenMap);
			movieClipCenterInfo.telNumber.addEventListener(MouseEvent.MOUSE_DOWN, handleCallPhone);
			this.addChild(movieClipCenterInfo);
		}		
		
		private function handleOpenMap(e:MouseEvent){
			trace("URLList.as / handleOpenMap");
			_geo = new Geolocation();
			_geo.addEventListener(GeolocationEvent.UPDATE, updateHandler);
		}

		private function updateHandler(e:GeolocationEvent){
			_geo.removeEventListener(GeolocationEvent.UPDATE, updateHandler);
			var _strGeoLocation = e.latitude.toString() + "," + e.longitude.toString();
			_geo = null;
			NavigateTool.openRouteMapApp(_strGeoLocation,FamilyCenterInfo.lstCenterData[intSelectedCouponIndex].address);
		}
		
		private function handleCallPhone(e:MouseEvent){
			trace("URLList.as / handleCallPhone");
			NavigateTool.callPhone(FamilyCenterInfo.lstCenterData[intSelectedCouponIndex].tel);
		}
		
		private function handleClosemovieClipCenterInfo(e:MouseEvent){
			removeMovieClipCenterInfo();
		}
		
		private function removeMovieClipCenterInfo(){
			movieClipCenterInfo.btnNo.removeEventListener(MouseEvent.MOUSE_DOWN, handleClosemovieClipCenterInfo);
			movieClipCenterInfo.btnMap.removeEventListener(MouseEvent.MOUSE_DOWN, handleOpenMap);
			movieClipCenterInfo.telNumber.removeEventListener(MouseEvent.MOUSE_DOWN, handleCallPhone);
			this.removeChild(movieClipCenterInfo);
			movieClipCenterInfo = null;
		}
		
		/**
		 * Handle list item seleced.
		 * */
		private function handlelistItemSelected(e:ListItemEvent):void
		{
			trace("List item selected: " + e.renderer.index);
			itemSelected = e.renderer as TouchListItemRenderer;
			
			intSelectedCouponIndex =  e.renderer.index;
			
			showCenterInfo();
		}
		
		/**
		 * Handle stage orientation by calling the list resize method.
		 * */
		private function handleOrientationChange(e:StageOrientationEvent):void
		{
			switch (e.afterOrientation) { 
				case StageOrientation.DEFAULT: 
				case StageOrientation.UNKNOWN: 
					//touchList.resize(stage.stageWidth, stage.stageHeight);
					break; 
				case StageOrientation.ROTATED_RIGHT: 
				case StageOrientation.ROTATED_LEFT: 
					//touchList.resize(stage.stageHeight, stage.stageWidth);
					break; 
			} 
		}
		
		private function handleResize(e:Event = null):void
		{
			touchList.resize(stage.stageWidth, stage.stageHeight);
		}
		
		private function handleActivate(event:Event):void
		{
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;
		}
		
		private function handleDeactivate(event:Event):void
		{
			NativeApplication.nativeApplication.exit();
		}
		
		/**
		 * Handle keyboard events for menu, back, and seach buttons.
		 * */
		private function handleKeyDown(e:KeyboardEvent):void
		{
			if(e.keyCode == Keyboard.BACK) {
				e.preventDefault();
				NativeApplication.nativeApplication.exit();
			} else if(e.keyCode == Keyboard.MENU){
				e.preventDefault();
			} else if(e.keyCode == Keyboard.SEARCH){
				e.preventDefault();
			}
		}
		
		
	}
	
}