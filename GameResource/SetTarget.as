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
	
	public class SetTarget {

		public static const SEND_SUCCESS:String = "SetTarget.SEND_SUCCESS";
		public static const SEND_FAIL:String = "SetTarget.SEND_FAIL";
		public static const UNKNOW_ERROR:String = "SetTarget.UNKNOW_ERROR";
		public static var eventChannel:EventChannel = EventChannel.getInstance();
		
		static public function setTarget(strSetTargetUrl:String, 
										strUniqueId:String, 
										strTarget:String) {
											
			var variables:URLVariables = new URLVariables();
			variables.id = escape(strUniqueId);
			variables.target = strTarget;
			
			var urlRequest:URLRequest = new URLRequest(strSetTargetUrl);
			urlRequest.data = variables;
			urlRequest.method = URLRequestMethod.POST;
			
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, onLoadRequestComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			loader.load(urlRequest);
		}
		
		public static function ioErrorHandler(e:IOErrorEvent) {
			eventChannel.writeEvent(new Event(SetTarget.UNKNOW_ERROR));
		}
		
		static public function onLoadRequestComplete(e:Event) {
			var strResult:String = String(e.target.data);
			if (strResult == "1") {
				eventChannel.writeEvent(new Event(SetTarget.SEND_SUCCESS));
			} else {
				eventChannel.writeEvent(new Event(SetTarget.SEND_FAIL));
			}
		}

	}
	
}
