package GameResource {
	
	import flash.net.URLVariables;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.events.Event;
	import flash.errors.IOError;
	import flash.events.IOErrorEvent;
	
	import tw.cameo.EventChannel;
	
	public class SendUserInfo {

		public static const SEND_SUCCESS:String = "SendUserInfo.SEND_SUCCESS";
		public static const SEND_FAIL:String = "SendUserInfo.SEND_FAIL";
		public static const UNKNOW_ERROR:String = "SendUserInfo.UNKNOW_ERROR";
		public static var eventChannel:EventChannel = EventChannel.getInstance();
		
		static public function sendInfo(strUserInfoUrl:String, 
										strUniqueId:String, 
										strPhoneNumber:String, 
										strEmail:String, 
										isReceiveEpaper:Boolean) {
											
			var variables:URLVariables = new URLVariables();
			variables.id = escape(strUniqueId);
			variables.phone = escape(strPhoneNumber);
			variables.email = escape(strEmail);
			variables.isReceiveEpaper = (isReceiveEpaper) ? "1" : "0";
			
			var urlRequest:URLRequest = new URLRequest(strUserInfoUrl);
			urlRequest.data = variables;
			urlRequest.method = URLRequestMethod.POST;
			
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, onLoadRequestComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			loader.load(urlRequest);
		}
		
		public static function ioErrorHandler(e:IOErrorEvent) {
			eventChannel.writeEvent(new Event(SendUserInfo.UNKNOW_ERROR));
		}
		
		static public function onLoadRequestComplete(e:Event) {
			var strResult:String = String(e.target.data);
			if (strResult == "1") {
				eventChannel.writeEvent(new Event(SendUserInfo.SEND_SUCCESS));
			} else {
				eventChannel.writeEvent(new Event(SendUserInfo.SEND_FAIL));
			}
		}

	}
	
}
