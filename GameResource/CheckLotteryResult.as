package GameResource  {
	
	import flash.net.URLVariables;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.events.Event;
	import flash.errors.IOError;
	import flash.events.IOErrorEvent;
	
	import tw.cameo.EventChannel;
	
	public class CheckLotteryResult {

		public static const WIN:String = "CheckLotteryResult.WIN";
		public static const LOSE:String = "CheckLotteryResult.LOSE";
		public static const UNKNOW_ERROR:String = "CheckLotteryResult.UNKNOW_ERROR";
		
		public static var eventChannel:EventChannel = EventChannel.getInstance();
		
		static public function checkResult(strLotteryResultUrl:String, strUniqueId:String) {
			var variables:URLVariables = new URLVariables();
			variables.id = escape(strUniqueId);
			
			var urlRequest:URLRequest = new URLRequest(strLotteryResultUrl);
			urlRequest.data = variables;
			urlRequest.method = URLRequestMethod.POST;
			
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, onLoadRequestComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			loader.load(urlRequest);
		}
		
		public static function ioErrorHandler(e:IOErrorEvent) {
			eventChannel.writeEvent(new Event(CheckLotteryResult.UNKNOW_ERROR));
		}
		
		static public function onLoadRequestComplete(e:Event) {
			var strResult:String = String(e.target.data);
			if (strResult == "1") {
				eventChannel.writeEvent(new Event(CheckLotteryResult.WIN));
			} else {
				eventChannel.writeEvent(new Event(CheckLotteryResult.LOSE));
			}
		}
	}
	
}
