package GameResource {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import tw.cameo.LayoutManager;
	import tw.cameo.LayoutSettings;
	import tw.cameo.EventChannel;
	import tw.cameo.DeviceUniqueID;
	import GameResource.CheckLotteryResult;
	import tw.cameo.events.MovieEvents;
	import tw.cameo.events.GameMakerEvent;
	import tw.cameo.ToastMessage;
	import GameResource.Lottery;
	
	public class LotteryFlowType2 extends MovieClip {

		private const strLotteryResultUrl:String = CONFIG::WEB_SERVER_URL + CONFIG::WEB_PATH_PREFIX + "isDrawn.php";
		
		private var eventChannel:EventChannel = null;
		private var intDefaultWidth:Number = LayoutSettings.intDefaultWidth;
		private var intDefaultHeight:Number = LayoutSettings.intDefaultHeight;
		private const intDefaultHeightForIphone5:Number = LayoutSettings.intDefaultHeightForIphone5;
		private var isIphone5Layout:Boolean = false;
		
		private var deviceUniqueId:DeviceUniqueID = null;
		
		private var isResultReturn:Boolean = false;
		private var strResult:String = "LOSE";
		private var loopAnimation:MovieClip = null;
		private var resultAnimation:MovieClip = null;
		private var lottoryGameSound:Sound = null;
		private var soundChannel:SoundChannel = null;
		
		public function LotteryFlowType2() {
			// constructor code
			this.addEventListener(Event.ADDED_TO_STAGE, init);
			deviceUniqueId = new DeviceUniqueID();
		}

		private function init(e:Event) {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(Event.REMOVED_FROM_STAGE, destructor);
			
			eventChannel = EventChannel.getInstance();
			
			isIphone5Layout = LayoutManager.useIphone5Layout();
			
			if (isIphone5Layout) {
				changeLayoutForIphone5();
			}
			
			initLoopAnimation();
			goCheckLotteryResult();
		}
		
		private function destructor(e:Event = null) {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destructor);
			ToastMessage.dispose();
			
			removeResultAnimation();
			removeLoopAnimation();
			deviceUniqueId = null;
			
			removeEventChannelListener();
			eventChannel.removeEventListener(ToastMessage.CLOSE_MESSAGE, onCloseMessage);
			eventChannel = null;
		}
		
		private function removeEventChannelListener() {
			eventChannel.removeEventListener(CheckLotteryResult.WIN, onLotteryWin);
			eventChannel.removeEventListener(CheckLotteryResult.LOSE, onLotteryLose);
			eventChannel.removeEventListener(CheckLotteryResult.UNKNOW_ERROR, onUnknowError);
		}
		
		private function changeLayoutForIphone5() {
		}
		
		private function initLoopAnimation() {
			loopAnimation = new LotteryType2AnimationLoop();
			loopAnimation.addEventListener(MovieEvents.MOVIE_PLAY_END, onLoopAnimationPlayEnd);
			this.addChild(loopAnimation);
			lottoryGameSound = new LottoryGameSoundType2();
			soundChannel = new SoundChannel();
			soundChannel = lottoryGameSound.play(0, int.MAX_VALUE);
		}
		
		private function removeLoopAnimation() {
			if (loopAnimation) {
				loopAnimation.removeEventListener(MovieEvents.MOVIE_PLAY_END, onLoopAnimationPlayEnd);
				this.removeChild(loopAnimation);
			}
			if (soundChannel) soundChannel.stop();
			
			soundChannel = null;
			lottoryGameSound = null;
			loopAnimation = null;
		}
		
		private function onLoopAnimationPlayEnd(e:Event) {
			if (isResultReturn) {
				loopAnimation.removeEventListener(MovieEvents.MOVIE_PLAY_END, onLoopAnimationPlayEnd);
				removeLoopAnimation();
				playResult();
			}
		}
		
		private function playResult() {
			resultAnimation = (strResult == "WIN") ? new LotteryType2AnimationWin() : new LotteryType2AnimationLose();
			resultAnimation.addEventListener(MovieEvents.MOVIE_PLAY_END, onResultAnimationPlayEnd);
			this.addChild(resultAnimation);
		}
		
		private function removeResultAnimation() {
			if (resultAnimation) {
				resultAnimation.removeEventListener(MovieEvents.MOVIE_PLAY_END, onResultAnimationPlayEnd);
				this.removeChild(resultAnimation);
			}
			resultAnimation = null;
		}
		
		private function onResultAnimationPlayEnd(e:Event) {
			var strMessage:String = (strResult == "WIN") ? "恭喜您抽中小禮品1份！請選擇領取禮品的家庭教育中心。" :"銘謝惠顧！歡迎您再次參與本活動，以獲得一次試試好手氣的機會。";
			
			eventChannel.addEventListener(ToastMessage.CLOSE_MESSAGE, onCloseMessage);
			ToastMessage.showToastMessage(this, strMessage);
		}
		
		private function goCheckLotteryResult() {
			eventChannel.addEventListener(CheckLotteryResult.WIN, onLotteryWin);
			eventChannel.addEventListener(CheckLotteryResult.LOSE, onLotteryLose);
			eventChannel.addEventListener(CheckLotteryResult.UNKNOW_ERROR, onUnknowError);
			
			deviceUniqueId = new DeviceUniqueID();
			var strUniqueId:String = deviceUniqueId.getDeviceUniqueID();
			
			CheckLotteryResult.checkResult(strLotteryResultUrl, strUniqueId);
		}
		
		private function onLotteryWin(e:Event) {
			removeEventChannelListener();
			isResultReturn = true;
			strResult = "WIN";
		}
		
		private function onLotteryLose(e:Event) {
			removeEventChannelListener();
			isResultReturn = true;
			strResult = "LOSE";
		}
		
		private function onUnknowError(e:Event) {
			removeEventChannelListener();
			isResultReturn = true;
			strResult = "LOSE";
		}
		
		private function onCloseMessage(e:Event) {
			eventChannel.removeEventListener(ToastMessage.CLOSE_MESSAGE, onCloseMessage);
			if (strResult == "WIN") eventChannel.writeEvent(new Event(Lottery.FLOW_END_WIN));
			if (strResult == "LOSE") eventChannel.writeEvent(new Event(GameMakerEvent.EXPORT_MOVIE_FINISH));
		}
	}
	
}
