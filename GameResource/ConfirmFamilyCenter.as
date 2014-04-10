package GameResource {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.SimpleButton;
	import flash.utils.getDefinitionByName;
	import flash.utils.Timer;
	import flash.text.TextField;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import tw.cameo.LayoutManager;
	import tw.cameo.LayoutSettings;
	import tw.cameo.EventChannel;
	import tw.cameo.ToastMessage;
	import tw.cameo.DeviceUniqueID;
	import tw.cameo.events.GameMakerEvent;
	
	import GameResource.SetTarget;
	import FamilyCenterInfo;
	
	public class ConfirmFamilyCenter extends MovieClip {
		
		public static const SET_CENTER_COMPLETE:String = "ConfirmFamilyCenter.SET_CENTER_COMPLETE";
		private const strSetTargetUrl:String = CONFIG::WEB_SERVER_URL + CONFIG::WEB_PATH_PREFIX + "setTarget.php";
		private var eventChannel:EventChannel = null;
		
		private var intDefaultWidth:Number = LayoutSettings.intDefaultWidth;
		private var intDefaultHeight:Number = LayoutSettings.intDefaultHeight;
		private const intDefaultHeightForIphone5:Number = LayoutSettings.intDefaultHeightForIphone5;
		private var isIphone5Layout:Boolean = false;
		private var bg:Sprite = null;
		
		private var intCenterId:int = 0;
		private var confirmPannel:MovieClip = null;
		private var strCenterName:String = "";
		private var deviceUniqueId:DeviceUniqueID = null;
		private var uploading:MovieClip = null;
		
		public function ConfirmFamilyCenter(... args) {
			// constructor code
			this.addEventListener(Event.ADDED_TO_STAGE, init);
			intCenterId = (args) ? args[2] : 0;
			
			strCenterName = FamilyCenterInfo.lstCenterData[intCenterId]["name"];
			deviceUniqueId = new DeviceUniqueID();
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
			initConfirmation();
		}
		
		private function destructor(e:Event = null) {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destructor);
			removeUploading();
			removeConfirmation();
			deviceUniqueId = null;
			removeEventChannelListener();
			eventChannel.removeEventListener(ToastMessage.CLOSE_MESSAGE, onCloseMessage);
			eventChannel = null;
		}
		
		private function changeLayoutForIphone5() {
		}
		
		private function initConfirmation() {
			confirmPannel = (isIphone5Layout) ? new ConfirmFamilyCenterPannelIphone5() : new ConfirmFamilyCenterPannelIphone4();
			var centerNameTextField:TextField = confirmPannel.getChildByName("CenterName") as TextField;
			centerNameTextField.text = FamilyCenterInfo.lstCenterData[intCenterId]["name"];
			var addressTextField:TextField = confirmPannel.getChildByName("Address") as TextField;
			addressTextField.text = FamilyCenterInfo.lstCenterData[intCenterId]["address"];
			var phoneTextField:TextField = confirmPannel.getChildByName("PhoneNumber") as TextField;
			phoneTextField.text = FamilyCenterInfo.lstCenterData[intCenterId]["tel"];
			
			var date:Date = new Date();
			var intNowMonth:int = date.month + 1;
			var intNowYear:int = date.fullYear - 1911;
			
//			intNowMonth = 2;
			
			var intBeginYear:int = ((intNowMonth+1) > 12) ? 104 : 103;
			var intBeginMonth:int = ((intNowMonth+1) > 12) ? 1 : (intNowMonth+1);
			var intEndYear:int = ((intNowMonth+2) > 12) ? 104 : 103;
			var intEndMonth:int = ((intNowMonth+3) > 12) ? (intNowMonth+3-12) : (intNowMonth+3);
			
			var strDateArea:String = String(intBeginYear) + "/" + String(intBeginMonth) + "/10~" + String(intEndYear) + "/" + String(intEndMonth) + "/10";
			
			var dateAreaField:TextField = confirmPannel.getChildByName("DateArea") as TextField;
			dateAreaField.text = strDateArea;
			
			var confirmButton:SimpleButton = confirmPannel.getChildByName("ConfirmButton") as SimpleButton;
			confirmButton.addEventListener(MouseEvent.CLICK, onConfirmHandler);
			
			this.addChild(confirmPannel);
		}
		
		private function removeConfirmation() {
			if (confirmPannel) {
				var confirmButton:SimpleButton = confirmPannel.getChildByName("ConfirmButton") as SimpleButton;
				confirmButton.removeEventListener(MouseEvent.CLICK, onConfirmHandler);
				this.removeChild(confirmPannel);
			}
			confirmPannel = null;
		}
		
		private function onConfirmHandler(e:MouseEvent) {
			eventChannel.addEventListener(SetTarget.SEND_SUCCESS, onSetTargetSuccess);
			eventChannel.addEventListener(SetTarget.SEND_FAIL, onSetTargetFail);
			eventChannel.addEventListener(SetTarget.UNKNOW_ERROR, onUnknowError);
			
			showUploading();
			
//			var timer:Timer = new Timer(2000, 1);
//			timer.addEventListener(TimerEvent.TIMER, onTimer);
//			timer.start();
			
			var strUniqueId:String = deviceUniqueId.getDeviceUniqueID();
			SetTarget.setTarget(strSetTargetUrl, strUniqueId, strCenterName);
		}
		
		private function onTimer(e:TimerEvent) {
			e.target.stop();
//			onSetTargetSuccess();
//			onSetTargetFail();
//			onUnknowError();
		}
		
		private function showUploading() {
			uploading = new Uploading();
			this.addChild(uploading);
		}
		
		private function removeUploading() {
			if (uploading) this.removeChild(uploading);
			uploading = null;
		}
		
		private function removeEventChannelListener() {
			eventChannel.removeEventListener(SetTarget.SEND_SUCCESS, onSetTargetSuccess);
			eventChannel.removeEventListener(SetTarget.SEND_FAIL, onSetTargetFail);
			eventChannel.removeEventListener(SetTarget.UNKNOW_ERROR, onUnknowError);
		}
		
		private function onSetTargetSuccess(e:Event = null) {
			removeEventChannelListener();
			removeUploading();
			eventChannel.addEventListener(ToastMessage.CLOSE_MESSAGE, onCloseMessage);
			ToastMessage.showToastMessage(this, "請記得以所填寫之「手機號碼」到" + strCenterName + "領取您的贈品。");
		}
		
		private function onSetTargetFail(e:Event = null) {
			removeEventChannelListener();
			removeUploading();
			ToastMessage.showToastMessage(this, "資料設定失敗！");
		}
		
		private function onUnknowError(e:Event = null) {
			removeEventChannelListener();
			removeUploading();
			ToastMessage.showToastMessage(this, "資料設定失敗，\n請檢查網路是否開啟！");
		}
		
		private function onCloseMessage(e:Event) {
			eventChannel.removeEventListener(ToastMessage.CLOSE_MESSAGE, onCloseMessage);
			eventChannel.writeEvent(new Event(ConfirmFamilyCenter.SET_CENTER_COMPLETE));
		}
	}
	
}
