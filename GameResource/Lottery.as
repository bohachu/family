package GameResource {
	
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.net.SharedObject;
	import tw.cameo.LayoutManager;
	import tw.cameo.LayoutSettings;
	import tw.cameo.EventChannel;
	import tw.cameo.events.TitleBarEvent;
	import tw.cameo.ToastMessage;
	import tw.cameo.DeviceUniqueID;
	import GameResource.SendUserInfo;
	import GameResource.LotteryFlow;
	import GameResource.LotteryFlowType2;
	
	public class Lottery extends MovieClip {
		
		public static const FLOW_END_WIN:String = "Lottery.FLOW_END_WIN";
		private const strUserInfoUrl:String = CONFIG::WEB_SERVER_URL + CONFIG::WEB_PATH_PREFIX + "userInfo.php";
		
		private var eventChannel:EventChannel = null;
		private var intDefaultWidth:Number = LayoutSettings.intDefaultWidth;
		private var intDefaultHeight:Number = LayoutSettings.intDefaultHeight;
		private const intDefaultHeightForIphone5:Number = LayoutSettings.intDefaultHeightForIphone5;
		private var isIphone5Layout:Boolean = false;
		
		private var sharedObject:SharedObject = null;
		private var informationPannel:MovieClip = null;
		private var deviceUniqueId:DeviceUniqueID = null;
		private var uploading:MovieClip = null;
		
		private var strLotteryType:String = "Type1";
		private var lotteryFlow:MovieClip = null;

		public function Lottery(strLotteryTypeIn:String = "Type1") {
			// constructor code
			strLotteryType = strLotteryTypeIn;
			
			this.addEventListener(Event.ADDED_TO_STAGE, init);
			deviceUniqueId = new DeviceUniqueID();
		}

		private function init(e:Event) {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(Event.REMOVED_FROM_STAGE, destructor);
			
			eventChannel = EventChannel.getInstance();
			sharedObject = SharedObject.getLocal("UserInfo");
			
			isIphone5Layout = LayoutManager.useIphone5Layout();
			
			if (isIphone5Layout) {
				changeLayoutForIphone5();
			}
			
			initInformationPannel();
		}
		
		private function destructor(e:Event = null) {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destructor);
			removeLotteryFlow();
			removeEventChannelListener();
			removeUploading();
			deviceUniqueId = null;
			ToastMessage.dispose();
			removeInformationPannel();
			sharedObject = null;
			eventChannel = null;
		}
		
		private function removeEventChannelListener() {
			eventChannel.removeEventListener(SendUserInfo.SEND_SUCCESS, onSendUserInfoSuccess);
			eventChannel.removeEventListener(SendUserInfo.SEND_FAIL, onSendUserInfoFail);
			eventChannel.removeEventListener(SendUserInfo.UNKNOW_ERROR, onUnknowError);
		}
		
		private function changeLayoutForIphone5() {
		}
		
		private function initInformationPannel() {
			var date:Date = new Date();
			var intMonth:int = date.getMonth + 1;
			
			CAMEO::NO_ANE {
				intMonth = 5;
			}
			
			eventChannel.writeEvent(new TitleBarEvent(TitleBarEvent.SET_TITLE, -1, "資料填寫"));
			informationPannel = (isIphone5Layout) ? new InformationIphone5() : new InformationIphone4();
			
			var phoneNumberTextField:TextField = informationPannel.getChildByName("strPhoneNumber") as TextField;
			var emailTextField:TextField = informationPannel.getChildByName("strEmail") as TextField;
			var orderPost:MovieClip = informationPannel.getChildByName("OrderPost") as MovieClip;
			var checkIcon:MovieClip = orderPost.getChildByName("CheckIcon") as MovieClip;
		
			checkIcon.visible = false;
			orderPost.addEventListener(MouseEvent.CLICK, onOrderPostClick);
			var agreement:MovieClip = informationPannel.getChildByName("Agreement") as MovieClip;
			agreement.addEventListener(MouseEvent.CLICK, onAgreementClick);
			
			if (sharedObject.data.hasOwnProperty("dicInfo")) {
				phoneNumberTextField.text = sharedObject.data["dicInfo"]["Phone"];
				emailTextField.text = sharedObject.data["dicInfo"]["Email"];
				checkIcon.visible = sharedObject.data["dicInfo"]["isReceiveEpaper"];
			}
			
			if (intMonth == 5) {
				informationPannel.GoLotteryButton.x = 345;
				informationPannel.shareFbButton.addEventListener(MouseEvent.CLICK, onShareFbClick);
			} else {
				informationPannel.shareFbButton.visible = false;
			}
			
			this.addChild(informationPannel);
		}
		
		private function removeInformationPannel() {
			if (informationPannel) {
				var orderPost:MovieClip = informationPannel.getChildByName("OrderPost") as MovieClip;
				orderPost.removeEventListener(MouseEvent.CLICK, onOrderPostClick);
				var agreement:MovieClip = informationPannel.getChildByName("Agreement") as MovieClip;
				agreement.removeEventListener(MouseEvent.CLICK, onAgreementClick);
				var goLotteryButton:SimpleButton = informationPannel.getChildByName("GoLotteryButton") as SimpleButton;
				goLotteryButton.removeEventListener(MouseEvent.CLICK, onGoLotteryButtonClick);
				informationPannel.shareFbButton.removeEventListener(MouseEvent.CLICK, onShareFbClick);
				this.removeChild(informationPannel);
			}
			informationPannel = null;
		}
		
		private function onShareFbClick(e:MouseEvent) {
			trace("onShareFbClick");
		}
		
		private function onOrderPostClick(e:MouseEvent) {
			var orderPost:MovieClip = informationPannel.getChildByName("OrderPost") as MovieClip;
			var checkIcon:MovieClip = orderPost.getChildByName("CheckIcon") as MovieClip;
			if (checkIcon.visible) {
				checkIcon.visible = false;
			} else {
				checkIcon.visible = true;
			}
		}
		
		private function onAgreementClick(e:MouseEvent) {
			var agreement:MovieClip = informationPannel.getChildByName("Agreement") as MovieClip;
			var checkIcon:MovieClip = agreement.getChildByName("CheckIcon") as MovieClip;
			var goLotteryButton:SimpleButton = informationPannel.getChildByName("GoLotteryButton") as SimpleButton;
			if (checkIcon.visible) {
				checkIcon.visible = false;
				goLotteryButton.removeEventListener(MouseEvent.CLICK, onGoLotteryButtonClick);
				goLotteryButton.alpha = 0.3;
				goLotteryButton.enabled = false;
			} else {
				checkIcon.visible = true;
				goLotteryButton.addEventListener(MouseEvent.CLICK, onGoLotteryButtonClick);
				goLotteryButton.alpha = 1;
				goLotteryButton.enabled = true;
			}
		}
		
		private function onGoLotteryButtonClick(e:MouseEvent) {
			var phoneNumberTextField:TextField = informationPannel.getChildByName("strPhoneNumber") as TextField;
			var emailTextField:TextField = informationPannel.getChildByName("strEmail") as TextField;
			var orderPost:MovieClip = informationPannel.getChildByName("OrderPost") as MovieClip;
			var checkIcon:MovieClip = orderPost.getChildByName("CheckIcon") as MovieClip;
			
//			if (phoneNumberTextField.text == "") {
//				ToastMessage.showToastMessage(this, "請輸入手機號碼！");
//			} else if (emailTextField.text == "") {
//				ToastMessage.showToastMessage(this, "請輸入 Email！");
//			} else {
				showUploading();
				eventChannel.addEventListener(SendUserInfo.SEND_SUCCESS, onSendUserInfoSuccess);
				eventChannel.addEventListener(SendUserInfo.SEND_FAIL, onSendUserInfoFail);
				eventChannel.addEventListener(SendUserInfo.UNKNOW_ERROR, onUnknowError);
				var strPhoneNumber:String = phoneNumberTextField.text;
				var strEmail:String = emailTextField.text;
				var isReceiveEpaper:Boolean = checkIcon.visible;
				
				var strUniqueId:String = deviceUniqueId.getDeviceUniqueID();
				
				var dicInfo:Object = {
					"Phone":strPhoneNumber,
					"Email":strEmail,
					"isReceiveEpaper":isReceiveEpaper
				}
				sharedObject.setProperty("dicInfo", dicInfo);
				sharedObject.flush();
				
//				var date:Date = new Date();
//				strUniqueId = String(date.time);
//				trace(strUniqueId);
				
//				onSendUserInfoSuccess();
				SendUserInfo.sendInfo(strUserInfoUrl, strUniqueId, strPhoneNumber, strEmail, isReceiveEpaper);
//			}
		}
		
		private function showUploading() {
			uploading = new Uploading();
			this.addChild(uploading);
		}
		
		private function removeUploading() {
			if (uploading) this.removeChild(uploading);
			uploading = null;
		}
		
		private function onSendUserInfoSuccess(e:Event = null) {
			removeEventChannelListener();
			removeInformationPannel();
			removeUploading();
			goLotteryFLow();
		}
		
		private function onSendUserInfoFail(e:Event) {
			removeEventChannelListener();
			removeUploading();
			ToastMessage.showToastMessage(this, "資料上傳失敗！");
		}
		
		private function onUnknowError(e:Event = null) {
			removeEventChannelListener();
			removeUploading();
			ToastMessage.showToastMessage(this, "資料上傳失敗，\n請檢查網路是否開啟！");
		}
		
		private function goLotteryFLow() {
			eventChannel.writeEvent(new TitleBarEvent(TitleBarEvent.SET_TITLE, -1, "抽獎試手氣"));
			
			if (strLotteryType == "Type1") lotteryFlow = new LotteryFlow();
			if (strLotteryType == "Type2") lotteryFlow = new LotteryFlowType2();
			this.addChild(lotteryFlow);
		}
		
		private function removeLotteryFlow() {
			if (lotteryFlow) this.removeChild(lotteryFlow);
			lotteryFlow = null;
		}
	}
	
}
