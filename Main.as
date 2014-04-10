package  {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.events.Event;
	import flash.net.SharedObject;
	import flash.media.SoundMixer;
	import flash.system.System;
	import tw.cameo.TitleBarAndSideMenu;
	import tw.cameo.EventChannel;
	import tw.cameo.LayoutManager;
	import tw.cameo.LayoutSettings;
	import tw.cameo.events.TitleBarEvent;
	import tw.cameo.WebViewLog;
	import tw.cameo.CheckAppVersion;
	import tw.cameo.ToastMessage;
	
	// for Android Splash Screen
	import flash.system.Capabilities;
	import tw.cameo.SplashScreenForAndroid;
	
	// Cache
	import tw.cameo.net.FileCache;
	import tw.cameo.net.FileCacheManager;
	
	// content
	import Home;
	import Game;
	import GameTitleInfo;
	import GameResource.Lottery;
	import GameResource.SelectFamilyCenter;
	import GameResource.ConfirmFamilyCenter;
	import URLList;
	import tw.cameo.UI.PageMapComplete;
	//import tw.cameo.UI.PageSubjectView;
	import tw.cameo.UI.PageArticleList;
	import tw.cameo.UI.PagePhotoWithTitleAndText;
	import tw.cameo.UI.LoadingIndicator;
	import tw.cameo.LocationDistance;
	import flash.globalization.DateTimeFormatter;
	import flash.globalization.LocaleID;
	import tw.cameo.ToastMessage;
	
	// event
	import tw.cameo.events.GameMakerEvent;
	import FamilyEvent.GameEvent;
	import FamilyEvent.FamilyCenterListEvent;
	
	// BACK KEY
	import flash.desktop.NativeApplication;
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	
	// add by mark
	import flash.sensors.Geolocation;
	import flash.events.GeolocationEvent;
	
	CAMEO::ANE {
	import tw.cameo.lib.WebViewNativeExtension;
	import tw.cameo.lib.WebViewNativeExtensionEvent;
	}
	
	// Push Notification	
	import flash.notifications.NotificationStyle; 
    import flash.notifications.RemoteNotifier; 
    import flash.notifications.RemoteNotifierSubscribeOptions; 
    import flash.events.RemoteNotificationEvent; 
    import flash.events.StatusEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	CAMEO::ANDROID {
		import tw.cameo.pushnotification.PushNotification;
	}
	
	import tw.cameo.ActionLog;
	
	public class Main extends MovieClip {
		
		private var strAppVersionUrl:String = "http://tapmovie.com/familyedu/checkVersion.php";
		private const strAppVersionUrlIos:String = "http://tapmovie.com/familyedu/checkVersion.php?p=ios";
		private const strUpdateUrl:String = "http://goo.gl/y9Y3gd";
		
		private var gameRecordSharedObject:SharedObject = null;
		private var eventChannel:EventChannel = EventChannel.getInstance();
		private var splashScreenForAndroid:SplashScreenForAndroid = null;
		private var navigator:TitleBarAndSideMenu = null;
		private var home:Home = null;
		private var intSelectMonth:int = 2;
		private var _geo:Geolocation = null;
		
		// Push Notification
		private var remoteNotifierSubscribeOptions : RemoteNotifierSubscribeOptions = new RemoteNotifierSubscribeOptions(); 
        private var remoteNotifier : RemoteNotifier = new RemoteNotifier(); 
		
		// Roy added for Action log
		private var sharedObject:SharedObject = null;
		
		public function Main() {
			// constructor code
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;
			
			this.addEventListener(Event.ADDED_TO_STAGE, init);
			this.stage.addEventListener(Event.DEACTIVATE, deactivateHandler);
		}
		
		private function init (e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(Event.REMOVED_FROM_STAGE, destructor);
			
			// for Dynamic Create
			var titleBarIconHome     : TitleBarIcon_Home = null;
			var titleBarIconBack     : TitleBarIcon_Back = null;
			var titleBarIconSideMenu : TitleBarIcon_SideMenu = null;
			var titleBarIconLocate   : TitleBarIcon_Locate = null;
			var titleBarIconListView : TitleBarIcon_ListView = null;
			var game:Game = null;
			var selectFamilyCenter:SelectFamilyCenter = null;
			var confirmFamilyCenter:ConfirmFamilyCenter = null;
			var urlList:URLList = null;
			
			CAMEO::ANE {
			//var pageSubjectView : PageSubjectView = null;
			var pageArticleList : PageArticleList = null;
			var pagePhotoWithTitleAndText : PagePhotoWithTitleAndText = null;
			}
			
			// add by mark
			NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, keyDownEevnt);
			// end by mark
			
			eventChannelAddEventListener();
			
			if (Capabilities.os.indexOf("iPhone") == -1) {
				splashScreenForAndroid = new SplashScreenForAndroid();
				this.stage.addChild(splashScreenForAndroid);
				splashScreenForAndroid.addEventListener(SplashScreenForAndroid.OnSplashScreenTimer, onSplashScreenTimer);
				
				CAMEO::ANDROID {
					var pushNotification : PushNotification = new PushNotification();
					pushNotification.registerDevice();
				}
			} else {
				strAppVersionUrl = strAppVersionUrlIos;
				createHome();
				
				var lstStrNotificationStyles : Vector.<String> = new Vector.<String>();
					lstStrNotificationStyles.push(NotificationStyle.ALERT, NotificationStyle.BADGE, NotificationStyle.SOUND);
				this.remoteNotifierSubscribeOptions.notificationStyles= lstStrNotificationStyles; 
				this.remoteNotifier.addEventListener(RemoteNotificationEvent.TOKEN, remoteNotifierOnToken); 
				this.remoteNotifier.addEventListener(RemoteNotificationEvent.NOTIFICATION, remoteNotifierOnNotification); 
				this.remoteNotifier.addEventListener(StatusEvent.STATUS, remoteNotifierOnStatus); 
				this.remoteNotifier.subscribe(this.remoteNotifierSubscribeOptions);
				
				checkVersion();
			}
			
			sharedObject = SharedObject.getLocal("PageHitCount");
			
			if (!sharedObject.data.hasOwnProperty("dicHitRecord")) {
				sharedObject.data["dicHitRecord"] = {"1":0, "2":0, "3":0, "4":0, "5":0, "6":0, "7":0, "8":0, "9":0, "10":0, "11":0, "12":0, "13":0, "14":0, "15":0, "16":0, "17":0, "18":0, "19":0, "20":0, "21":0, "22":0, "23":0, "24":0, "25":0, "26":0, "27":0};
				sharedObject.flush();
			}
				
			addHitRecord("26");
			
			//2014.02.11 Roy added : Action log
			var actionLog:ActionLog = new ActionLog();
			actionLog.addEventListener(ActionLog.SEND_ACTION_SUCCESS, onSendActionSuccess);
		}
		
		private function checkVersion() {
			trace("Main.as / checkVersion.");
			CheckAppVersion.checkVersion(strAppVersionUrl, strUpdateUrl, stage, true);
		}
		
		//2014.02.11 Roy added : Action log
		private function onSendActionSuccess(e:Event) {
			sharedObject.data["dicHitRecord"] = {"1":0, "2":0, "3":0, "4":0, "5":0, "6":0, "7":0, "8":0, "9":0, "10":0, "11":0, "12":0, "13":0, "14":0, "15":0, "16":0, "17":0, "18":0, "19":0, "20":0, "21":0, "22":0, "23":0, "24":0, "25":0, "26":0, "27":0};
			sharedObject.flush();
		}
		
		private function addHitRecord(strKey:String) {
			if (!sharedObject.data.hasOwnProperty("dicHitRecord")) {
				sharedObject.data["dicHitRecord"] = {"1":0, "2":0, "3":0, "4":0, "5":0, "6":0, "7":0, "8":0, "9":0, "10":0, "11":0, "12":0, "13":0, "14":0, "15":0, "16":0, "17":0, "18":0, "19":0, "20":0, "21":0, "22":0, "23":0, "24":0, "25":0, "26":0, "27":0};
			}
			sharedObject.data["dicHitRecord"][strKey] = sharedObject.data["dicHitRecord"][strKey] + 1;
			sharedObject.flush();
			trace(sharedObject.data["dicHitRecord"]);
		}		
		
		private function eventChannelAddEventListener() {
			eventChannel.addEventListener(Home.CLICK_NEWS, onHomeNewsClick);
			eventChannel.addEventListener(Home.CLICK_CENTER, onHomeCenterClick);
			eventChannel.addEventListener(Home.CLICK_GAME, onHomeGameClick);
			eventChannel.addEventListener(GameEvent.CLICK_GAME, onGameClick);
			eventChannel.addEventListener(GameMakerEvent.EXPORT_MOVIE_FINISH, onGameFinish);
			eventChannel.addEventListener(Lottery.FLOW_END_WIN, onLotteryEndWin);
			eventChannel.addEventListener(ConfirmFamilyCenter.SET_CENTER_COMPLETE, onSetCenterComplete);
		}
		
		private function destructor(e:Event) {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destructor);
			eventChannelRemoveEventListener();
			gameRecordSharedObject = null;
			eventChannel = null;
			removeSplashScreen();
			removeHome();
		}
		
		private function eventChannelRemoveEventListener() {
			eventChannel.removeEventListener(Home.CLICK_NEWS, onHomeNewsClick);
			eventChannel.removeEventListener(Home.CLICK_CENTER, onHomeCenterClick);
			eventChannel.removeEventListener(Home.CLICK_GAME, onHomeGameClick);
			eventChannel.removeEventListener(GameEvent.CLICK_GAME, onGameClick);
			eventChannel.removeEventListener(GameMakerEvent.EXPORT_MOVIE_FINISH, onGameFinish);
			eventChannel.removeEventListener(Lottery.FLOW_END_WIN, onLotteryEndWin);
			eventChannel.removeEventListener(FamilyCenterListEvent.CLICK_CENTER, onCenterClick);
			eventChannel.removeEventListener(FamilyCenterListEvent.CLICK_CENTER, onCenterInfoClick);
			eventChannel.removeEventListener(ConfirmFamilyCenter.SET_CENTER_COMPLETE, onSetCenterComplete);
		}
		
		private function onSplashScreenTimer(e:Event) {
			createHome();
			removeSplashScreen();
			checkVersion();
		}
		
		private function removeSplashScreen() {
			if (splashScreenForAndroid) {
				this.stage.removeChild(splashScreenForAndroid);
			}
			splashScreenForAndroid = null;
		}
		
		private function createHome() {
			eventChannel.removeEventListener(FamilyCenterListEvent.CLICK_CENTER, onCenterClick);
			home = new Home();
			this.stage.addChild(home);
			System.gc();
		}
		
		private function removeHome() {
			if (home) {
				this.stage.removeChild(home);
			}
			home = null;
		}
		
		private function onHomeNewsClick(e:Event) 
		{
			addHitRecord("27");
			
			var strURLFeed : String = CONFIG::WEB_SERVER_URL + CONFIG::WEB_PATH_PREFIX + "cat/News/feed/";
			var dicContentParameter = createDicContentParameterForPageArticleList("最新消息", strURLFeed);

			removeHome();
			setupNavigator(dicContentParameter);
		}
		
		private function createDicContentParameterForPageArticleList(strTitle : String, strURLFeed : String) : *
		{
			CAMEO::ANE {
			var dicContentParameter = {
				className: "tw.cameo.UI.PageArticleList",
				data: strURLFeed,
				title: strTitle,
				leftButton: TitleBarAndSideMenu.TITLE_BUTTON_TYPE_BACK,
				leftButtonOnMouseClick: titleButtonHomeHandler,
				rightButton: TitleBarAndSideMenu.TITLE_BUTTON_TYPE_NONE,
				rightButtonOnMouseClick: null,
				lstStrSideMenuItem: null,
				intIndexDefaultSideMenuItem: -1,
				sideMenuOnClose: null,
				contentOnLoaded: function(content : MovieClip) : void
				{
					// Show Loading Indicator
					var loadingIndicator : LoadingIndicator = null;
						loadingIndicator = new LoadingIndicator(0xffffff);
						loadingIndicator.x = stage.fullScreenWidth / 5;
						loadingIndicator.y = navigator.getTitleBarHeight() / 2;
						loadingIndicator.scaleX = LayoutManager.intScaleX;
						loadingIndicator.scaleY = LayoutManager.intScaleY;
					this.stage.addChild(loadingIndicator);

					var pageArticleList : PageArticleList = content as PageArticleList;
					pageArticleList.webView.addEventListener("WebViewStatusEvent.START_LOAD", function(event : WebViewNativeExtensionEvent)
					{
						
					});
					pageArticleList.webView.addEventListener("WebViewStatusEvent.FINISH_LOAD", function(event : WebViewNativeExtensionEvent)
					{
						// Hide Loading Indicator
						loadingIndicator.stopAnim();
						this.stage.removeChild(loadingIndicator);
					});
					pageArticleList.webView.addEventListener("WebViewStatusEvent.ERROR", function(event : WebViewNativeExtensionEvent)
					{
						loadingIndicator.stopAnim();
						this.stage.removeChild(loadingIndicator);
					});
					pageArticleList.webView.addEventListener("WebViewStatusEvent.LOCATION_CHANGED", function(event : WebViewNativeExtensionEvent)
					{
						var webView : WebViewNativeExtension = event.target as WebViewNativeExtension;
						try
						{
							var strPrefix : String = "http://tapmovie.com/blank.html?id=";
							var strLocation : String = event.strURL;
							if (strLocation.substring(0, strPrefix.length) == strPrefix)
							{
								var intIndex : int = parseInt(strLocation.substring(strPrefix.length));
								var dicData : Object = pageArticleList.getDicData(intIndex);
								var strURLFeed : String = dicData.link;

								createPagePhotoWithTitleAndText("詳細活動內容", strURLFeed);
							}
						}
						catch (error : Error)
						{
							webView.webViewLoadString(error.message + "<br />" + error.getStackTrace().replace("\n", "<br />"), "file:///");
						}
					});
					
					var intWidthHTML : int = (LayoutManager.intScreenWidth - convertToScaledLength(4));
					var intWebViewY : int = navigator.getTitleBarHeight();
					var intWebViewWidth : int = LayoutManager.intScreenWidth;
					var intWebViewHeight : int = LayoutManager.intScreenHeight - intWebViewY;

					pageArticleList.webView.setWebViewFrame(0, intWebViewY, intWebViewWidth, intWebViewHeight);
					pageArticleList.strHTMLStyleSheet = getStrStyleSheetForPageArticleList(intWidthHTML);
					pageArticleList.strHTMLViewPortWidth = (LayoutManager.intScreenWidth).toString();
					pageArticleList.isNoImage = true;
					pageArticleList.isShowCategory = true;
					if (Capabilities.os.indexOf("iPhone") != -1) 
					{
						pageArticleList.strHTMLViewPortInitialScale = ((pageArticleList.webView.isRetinaDisplay()) ? ("0.5") : ("1.0"));
						pageArticleList.strHTMLViewPortMaximumScale = ((pageArticleList.webView.isRetinaDisplay()) ? ("0.5") : ("1.0"));
					}
					pageArticleList.funcOnDataLoaded = function() : void
					{
						var lstDicData : Array = pageArticleList.lstDicData;
						for (var i : int = 0; i<lstDicData.length; i++)
						{
							var date : Date = lstDicData[i].date;
							var dateTimeFormatter : DateTimeFormatter = new DateTimeFormatter("zh-TW");
								dateTimeFormatter.setDateTimePattern("yyyy/MM/dd");
							
							lstDicData[i].summary = lstDicData[i].title;
							lstDicData[i].title = dateTimeFormatter.format(date);
							lstDicData[i].category = lstDicData[i].category.replace("家庭教育中心", "");
						}
						pageArticleList.lstDicData = lstDicData;
					};

					pageArticleList.addEventListener("LOAD_DATA_FAIL", function(e : Event) : void
					{
						var webView : WebViewNativeExtension = e.target.webView as WebViewNativeExtension;
						webView.stopWebView();
						webView.hideWebView();
						loadingIndicator.stopAnim();
						e.target.stage.removeChild(loadingIndicator);
						eventChannel.addEventListener(ToastMessage.CLOSE_MESSAGE, toastMessageonCloseMessage);
						ToastMessage.showToastMessage(MovieClip(e.target), "載入資料失敗，\n請檢查網路是否開啟！");
					});
					
					pageArticleList.loadData();
				}
			};
			return dicContentParameter;
			} // End of CAMEO::ANE
		}
		
		private function getStrStyleSheetForPageArticleList(intWidthHTML : Number) : String
		{
			var strURLBase : String = CONFIG::WEB_SERVER_URL + CONFIG::WEB_PATH_PREFIX;
			var fileCache1 : FileCache = new FileCache(strURLBase + "images/background_page.png");
			var fileCache2 : FileCache = new FileCache(strURLBase + "images/background_item_article_list.png");
			var fileCache3 : FileCache = new FileCache(strURLBase + "images/background_item_title_article_list.png");
			var fileCacheManager : FileCacheManager = new FileCacheManager();
				fileCacheManager.addFileCache(fileCache1);
				fileCacheManager.addFileCache(fileCache2);
				fileCacheManager.addFileCache(fileCache3);

			var strStyleSheet : String = "\t<style type='text/css'>\n";
				strStyleSheet += "\t\tbody { margin: 0px; background-image: url('" + fileCache1.toString() + "'); background-repeat: repeat-y; background-position: center; background-size: cover; }\n";
				strStyleSheet += "\t\ttable { width: " + (intWidthHTML).toString() + "px }\n";
				strStyleSheet += "\t\ttr {  }\n";
				strStyleSheet += "\t\ttd { width: " + (intWidthHTML).toString() + "px; height: " + convertToScaledLength(200) + "px; }\n";
				strStyleSheet += "\t\tdiv.container { background-image: url('" + fileCache2.toString() + "'); background-repeat: repeat; background-position: center; background-size: contain; margin: " + convertToScaledLength(20) + " auto 0 auto; width: " + (intWidthHTML).toString() + "px; height: " + convertToScaledLength(200) + "px; }\n";
				strStyleSheet += "\t\tdiv.title { float: left; width: " + convertToScaledLength(200) + "px; height: " + convertToScaledLength(40) + "px; margin: " + convertToScaledLength(10) + " 0 " + convertToScaledLength(-20) + " " + convertToScaledLength(50) + "; text-align: left; color: rgb(215, 148, 118); font-family: \"Microsoft JhengHei\"; font-size: " + convertToScaledLength(36) + "px; overflow: hidden; }\n";
				strStyleSheet += "\t\tdiv.category { float: right; width: " + convertToScaledLength(150) + "px; height: " + convertToScaledLength(48) + "px; line-height: " + convertToScaledLength(44) + "px; margin: " + convertToScaledLength(10) + " " + convertToScaledLength(14) + " " + convertToScaledLength(-20) + " 0; padding-left: " + convertToScaledLength(36) + "px; color: rgb(83, 127, 94); font-family: \"Microsoft JhengHei\"; font-size: " + convertToScaledLength(30) + "px; font-weight: bold; overflow: hidden; background-image: url('" + fileCache3.toString() + "'); background-repeat: no-repeat; background-position: center; background-size: cover; }\n";
				strStyleSheet += "\t\tdiv.summary { float: left; width: " + convertToScaledLength(528) + "px; height: " + convertToScaledLength(128) + "px; margin: " + convertToScaledLength(25) + " " + convertToScaledLength(-50) + " " + convertToScaledLength(-25) + " " + convertToScaledLength(50) + "; line-height: " + convertToScaledLength(45) + "px; text-align: left; color: black; font-family: \"Microsoft JhengHei\"; font-size: " + convertToScaledLength(32) + "px; overflow: hidden; }";
				strStyleSheet += "\t\ta { text-decoration: none; color: black; }";
				strStyleSheet += "\t</style>\n";
			return strStyleSheet;
		}
		
		private function convertToScaledLength(intLength : Number) : Number
		{
			return (LayoutManager.intScreenWidth * intLength / 640);
		}
		
		private function createPagePhotoWithTitleAndText(strTitle : String, strURLFeed : String) : void
		{
			CAMEO::ANE {
			var dicContentParameter = {
				className: "tw.cameo.UI.PagePhotoWithTitleAndText",
				data: strURLFeed,
				title: strTitle,
				leftButton: TitleBarAndSideMenu.TITLE_BUTTON_TYPE_BACK,
				leftButtonOnMouseClick: titleButtonBackHandler,
				rightButton: TitleBarAndSideMenu.TITLE_BUTTON_TYPE_NONE,
				rightButtonOnMouseClick: null,
				lstStrSideMenuItem: null,
				intIndexDefaultSideMenuItem: -1,
				sideMenuOnClose: null,
				contentOnLoaded: function(content : MovieClip) : void
				{
					// Show Loading Indicator
					var loadingIndicator : LoadingIndicator = null;
						loadingIndicator = new LoadingIndicator(0x333333);
						loadingIndicator.x = stage.fullScreenWidth / 4;
						loadingIndicator.y = navigator.getTitleBarHeight() / 2;
						loadingIndicator.scaleX = LayoutManager.intScaleX;
						loadingIndicator.scaleY = LayoutManager.intScaleY;
					this.stage.addChild(loadingIndicator);
					var pagePhotoWithTitleAndText : PagePhotoWithTitleAndText = content as PagePhotoWithTitleAndText;
					pagePhotoWithTitleAndText.webView.addEventListener("WebViewStatusEvent.FINISH_LOAD", function(event : WebViewNativeExtensionEvent)
					{
						// Hide Loading Indicator
						loadingIndicator.stopAnim();
						this.stage.removeChild(loadingIndicator);
					});
					pagePhotoWithTitleAndText.webView.addEventListener("WebViewStatusEvent.ERROR", function(event : WebViewNativeExtensionEvent)
					{
						loadingIndicator.stopAnim();
						this.stage.removeChild(loadingIndicator);
					});

					var intWebViewY : int = navigator.getTitleBarHeight();
					var intWebViewWidth : int = LayoutManager.intScreenWidth;
					var intWebViewHeight : int = LayoutManager.intScreenHeight - intWebViewY;

					pagePhotoWithTitleAndText.webView.setWebViewFrame(0, intWebViewY, intWebViewWidth, intWebViewHeight);
					pagePhotoWithTitleAndText.strHTMLStyleSheet = getStrStyleSheetForPagePhotoWithTitleAndText();
					pagePhotoWithTitleAndText.strScriptContentLoaded = getStrScriptForPagePhotoWithTitleAndText();
					pagePhotoWithTitleAndText.strCSSHeightPhoto = convertToScaledLength(480).toString();
					pagePhotoWithTitleAndText.strHTMLViewPortWidth = (LayoutManager.intScreenWidth).toString();
					//pagePhotoWithTitleAndText.isNoImage = true;
					pagePhotoWithTitleAndText.funcOnDataLoaded = null;

					pagePhotoWithTitleAndText.addEventListener("LOAD_DATA_FAIL", function(e : Event) : void
					{
						var webView : WebViewNativeExtension = e.target.webView as WebViewNativeExtension;
						webView.stopWebView();
						webView.hideWebView();
						loadingIndicator.stopAnim();
						e.target.stage.removeChild(loadingIndicator);
						eventChannel.addEventListener(ToastMessage.CLOSE_MESSAGE, toastMessageonCloseMessage);
						ToastMessage.showToastMessage(MovieClip(e.target), "載入資料失敗，\n請檢查網路是否開啟！");
					});

					pagePhotoWithTitleAndText.loadData();
				}
			};
			
			navigator.pushContent(dicContentParameter);
			} // End of CAMEO::ANE
		}
		
		private function getStrStyleSheetForPagePhotoWithTitleAndText() : String
		{
			var strURLBase : String = CONFIG::WEB_SERVER_URL + CONFIG::WEB_PATH_PREFIX;
			var fileCache1 : FileCache = new FileCache(strURLBase + "images/background_page.png");
			var fileCache2 : FileCache = new FileCache(strURLBase + "images/background_item_article_list.png");
			var fileCacheManager : FileCacheManager = new FileCacheManager();
				fileCacheManager.addFileCache(fileCache1);
				fileCacheManager.addFileCache(fileCache2);

			var intWidthHTML : int = (LayoutManager.intScreenWidth - convertToScaledLength(4));
			var strStyleSheet : String = "";
				strStyleSheet += " body { margin: 0px; background-image: url('" + fileCache1.toString() + "'); background-repeat: repeat-y; background-position: center; background-size: cover; }\n";
				strStyleSheet += " div.container { width: " + (intWidthHTML).toString() + "px; height: 100%; background-image: url('" + fileCache2.toString() + "'); background-repeat: repeat-y; background-position: center; background-size: contain; }\n";
				strStyleSheet += " div.title { width: " + convertToScaledLength(520) + "px; height: " + convertToScaledLength(96) + "px; line-height: " + convertToScaledLength(96) + "px; text-align: left; margin: 0 " + convertToScaledLength(-56) + " " + convertToScaledLength(48) + " " + convertToScaledLength(56) + "; padding-top: " + convertToScaledLength(48) + "px; color: rgb(215, 148, 118); font: " + convertToScaledLength(36) + "px \"Microsoft JhengHei\"; }\n";
				strStyleSheet += " div.content { width: " + convertToScaledLength(520) + "px; margin: " + convertToScaledLength(48) + " " + convertToScaledLength(-56) + " " + convertToScaledLength(48) + " " + convertToScaledLength(56) + "; padding-bottom: " + convertToScaledLength(48) + "px; text-align: left; color: black; font: " + convertToScaledLength(32) + "px \"Microsoft JhengHei\"; word-wrap: break-word; }\n";
				strStyleSheet += " * { margin:0; padding:0; }";
			return strStyleSheet;
		}
		
		private function getStrScriptForPagePhotoWithTitleAndText() : String
		{
			var strScript : String = "";
				//strScript += "      var h = $(document).height() + " + convertToScaledLength(480) + ";\n";
				strScript += "      var h = $(document).height();\n";
				strScript += "      $('div.container').css('height', h.toString());\n";
			return strScript;
		}
		
		private function onHomeCenterClick(e:Event) {
			trace("Main.as / onHomeCenterClick");
			eventChannel.addEventListener(FamilyCenterListEvent.CLICK_CENTER, onCenterInfoClick);
			var dicContentParameter = {
				className: "URLList",
				data: null,
				title: "全國家庭教育中心",
				leftButton: TitleBarAndSideMenu.TITLE_BUTTON_TYPE_BACK,
				leftButtonOnMouseClick: backHomeFromCenterList,
				rightButton: TitleBarAndSideMenu.TITLE_BUTTON_TYPE_LOCATE,
				rightButtonOnMouseClick: function() { goPageMapComplete() },
				lstStrSideMenuItem: null,
				intIndexDefaultSideMenuItem: -1,
				sideMenuOnClose: null,
				contentOnLoaded: null
			};

			removeHome();
			setupNavigator(dicContentParameter);
		}
		
		private function onCenterInfoClick(e:FamilyCenterListEvent) {
			addHitRecord(String(e.intCenterId + 1));
		}
		
		private function backHomeFromCenterList() {
			eventChannel.removeEventListener(FamilyCenterListEvent.CLICK_CENTER, onCenterInfoClick);
			titleButtonHomeHandler();
		}
		
		private function onHomeGameClick(e:Event) {
			var dicContentParameter = {
				className: "Game",
				data: null,
				title: "主題遊戲館",
				leftButton: TitleBarAndSideMenu.TITLE_BUTTON_TYPE_BACK,
				leftButtonOnMouseClick: titleButtonHomeHandler,
				rightButton: TitleBarAndSideMenu.TITLE_BUTTON_TYPE_NONE,
				rightButtonOnMouseClick: null,
				lstStrSideMenuItem: null,
				intIndexDefaultSideMenuItem: -1,
				sideMenuOnClose: null,
				contentOnLoaded: null
			};
			
			removeHome();
			setupNavigator(dicContentParameter);
		}
		
		private function onGameClick(e:GameEvent) {
			trace("Main.as / onGameClick. click month:", e.intSelectMonth);
			intSelectMonth = e.intSelectMonth;
			var strClassName:String = "GameResource.Month" + String(intSelectMonth) + "Game";
			var dicContentParameter = {
				className: strClassName,
				data: null,
				title: GameTitleInfo.lstStrTitle[e.intSelectMonth-1],
				leftButton: TitleBarAndSideMenu.TITLE_BUTTON_TYPE_BACK,
				leftButtonOnMouseClick: titleButtonBackHandler,
				rightButton: TitleBarAndSideMenu.TITLE_BUTTON_TYPE_NONE,
				rightButtonOnMouseClick: null,
				lstStrSideMenuItem: null,
				intIndexDefaultSideMenuItem: -1,
				sideMenuOnClose: null,
				contentOnLoaded: null
			};
			
			removeHome();
			setupNavigator(dicContentParameter);
		}
		
		private function onGameFinish(e:Event) {
			titleButtonBackHandler();
		}
		
		private function onLotteryEndWin(e:Event) {
			eventChannel.addEventListener(FamilyCenterListEvent.CLICK_CENTER, onCenterClick);
			trace("Main.as / onLotteryEndWin.");
			titleButtonBackHandler();
			var dicContentParameter = {
				className: "GameResource.SelectFamilyCenter",
				data: null,
				title: "選擇兌獎地點",
				leftButton: TitleBarAndSideMenu.TITLE_BUTTON_TYPE_BACK,
				leftButtonOnMouseClick: titleButtonBackHandler,
				rightButton: TitleBarAndSideMenu.TITLE_BUTTON_TYPE_NONE,
				rightButtonOnMouseClick: null,
				lstStrSideMenuItem: null,
				intIndexDefaultSideMenuItem: -1,
				sideMenuOnClose: null,
				contentOnLoaded: null
			};
			
			setupNavigator(dicContentParameter);
		}
		
		private function onCenterClick(e:FamilyCenterListEvent) {
			trace("Main.as / onCenterClick.");
			var dicContentParameter = {
				className: "GameResource.ConfirmFamilyCenter",
				data: e.intCenterId,
				title: "選擇兌獎地點",
				leftButton: TitleBarAndSideMenu.TITLE_BUTTON_TYPE_BACK,
				leftButtonOnMouseClick: titleButtonBackHandler,
				rightButton: TitleBarAndSideMenu.TITLE_BUTTON_TYPE_NONE,
				rightButtonOnMouseClick: null,
				lstStrSideMenuItem: null,
				intIndexDefaultSideMenuItem: -1,
				sideMenuOnClose: null,
				contentOnLoaded: null
			};
			
			setupNavigator(dicContentParameter);
		}
		
		private function onSetCenterComplete(e:Event) {
			gameRecordSharedObject = SharedObject.getLocal("GameRecord");
			var strPropertyName:String = "isMonth" + String(intSelectMonth) + "GameWinned";
			gameRecordSharedObject.data[strPropertyName] = true;
			gameRecordSharedObject.flush();
			
			eventChannel.removeEventListener(FamilyCenterListEvent.CLICK_CENTER, onCenterClick);
			navigator.popContent();
			navigator.popContent();
		}
		
		private function goPageMapComplete() {
			_geo = new Geolocation();
			_geo.addEventListener(GeolocationEvent.UPDATE,updateHandler);
		}

		private function updateHandler(e:GeolocationEvent)
		{
			_geo.removeEventListener(GeolocationEvent.UPDATE, updateHandler);
			var intLatitude:Number = Number(e.latitude.toString());
			var intLongitude:Number = Number(e.longitude.toString());
			_geo = null;
			
			var intIndex:Number = 0;
			var intMin:Number = 10000;
			
			for (var intCounter = 0; intCounter < FamilyCenterInfo.lstCenterData.length; intCounter++) {
				var intTemp1:Number = Number(FamilyCenterInfo.lstCenterData[intCounter].latitude);
				var intTemp2:Number = Number(FamilyCenterInfo.lstCenterData[intCounter].longitude);
				var intTemp:Number = LocationDistance.getDistance(intLatitude,intLongitude,intTemp1,intTemp2);//(intLatitude - intTemp1) + (intLongitude - intTemp2);
				if (intTemp < intMin) {
					intIndex = intCounter;
					intMin = intTemp;
				}
			}
			
			createPageMapComplete(intIndex);
		}
		
		private function createPageMapComplete(intIndex:Number) 
		{
			CAMEO::ANE {
			var dicContentParameter = {
				className: "tw.cameo.UI.PageMapComplete",
				data: null,
				title: FamilyCenterInfo.lstCenterData[intIndex].name,
				leftButton: TitleBarAndSideMenu.TITLE_BUTTON_TYPE_BACK,
				leftButtonOnMouseClick: titleButtonBackHandler,
				rightButton: TitleBarAndSideMenu.TITLE_BUTTON_TYPE_NONE,
				rightButtonOnMouseClick: null,
				lstStrSideMenuItem: null,
				intIndexDefaultSideMenuItem: -1,
				sideMenuOnClose: null,
				contentOnLoaded: function(content : MovieClip) : void
				{
					var pageMapComplete : PageMapComplete = content as PageMapComplete;
					pageMapComplete.webView.setWebViewFrame(0, navigator.getTitleBarHeight(), LayoutManager.intScreenWidth, LayoutManager.intScreenHeight - navigator.getTitleBarHeight());
					pageMapComplete.intLoadingHeight = navigator.getTitleBarHeight();
					pageMapComplete.strTitle = FamilyCenterInfo.lstCenterData[intIndex].name;
					pageMapComplete.strAddress = FamilyCenterInfo.lstCenterData[intIndex].address;
					pageMapComplete.strPhone = FamilyCenterInfo.lstCenterData[intIndex].tel;
					pageMapComplete.strFax = FamilyCenterInfo.lstCenterData[intIndex].fax;
					pageMapComplete.loadData();
				}
			};
			//setupNavigator(dicContentParameter);
			navigator.pushContent(dicContentParameter);
			} // End of CAMEO::ANE
		}
		
		private function setupNavigator(dicContentParameter:Object):void {
			if (navigator == null) {
				navigator = new TitleBarAndSideMenu(dicContentParameter);
				this.stage.addChild(navigator);
			} else {
				navigator.pushContent(dicContentParameter);
			}
		}
		
		private function titleButtonHomeHandler():void {
			this.stage.removeChild(navigator);
			navigator = null;
			createHome();
		}
		
		private function titleButtonBackHandler() : void
		{
			navigator.popContent();
		}
		
		private function deactivateHandler(e:Event) {
			SoundMixer.stopAll();
		}
		
		private function keyDownEevnt(ev:KeyboardEvent):void {
			if (ev.keyCode == Keyboard.BACK) {
				
				if (home == null) {
					ev.preventDefault();
        			ev.stopImmediatePropagation();
					if (navigator.numOfContent == 1) titleButtonHomeHandler();
					else titleButtonBackHandler();
				}
			}
		}

		private function toastMessageonCloseMessage(e:Event) {
			eventChannel.removeEventListener(ToastMessage.CLOSE_MESSAGE, toastMessageonCloseMessage);
			navigator.popContent();
			if (navigator.numOfContent == 0)
			{
				this.stage.removeChild(navigator);
				navigator = null;
				createHome();
			}
		}
		
		// iOS push notification event handlers
		private function remoteNotifierOnToken(event : RemoteNotificationEvent) : void
        {
			// 將 device token 註冊到 server
			var strDeviceToken : String = event.tokenId.toString();
			var strURL : String = CONFIG::WEB_SERVER_URL + CONFIG::WEB_PATH_PREFIX + "registerAPN.php?strDeviceToken=" + strDeviceToken;
			var urlRequest : URLRequest = new URLRequest(strURL);
			var urlLoader : URLLoader = new URLLoader();
				urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
				urlLoader.addEventListener(Event.COMPLETE, function(e : Event)
				{
					// 若收不到推播可以把以下註解拿掉, 看伺服器的回傳是什麼?
					//ToastMessage.showToastMessage(stage, String(e.target.data));
				});
				urlLoader.load(urlRequest);
        } 
		
		private function remoteNotifierOnNotification(event : RemoteNotificationEvent) : void
		{ 
			// 這邊是接收到 push notification
			var strMessage : String = "";
			for (var str:String in event.data) 
			{ 
				if (strMessage.length != 0) strMessage += "\n";
                strMessage += event.data[str];
            }
			//ToastMessage.showToastMessage(this.stage, strMessage);
		} 
		
		private function remoteNotifierOnStatus(e:StatusEvent) : void
		{ 
			// 若是失敗會到這邊
        } 
	}
}