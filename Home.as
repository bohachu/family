package  {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import tw.cameo.LayoutManager;
	import tw.cameo.LayoutSettings;
	import tw.cameo.EventChannel;
	import tw.cameo.RandomRotateObjectModify;
	import tw.cameo.GetVersionNumber;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.geom.Point;
	
	public class Home extends Sprite {
		
		static public const CLICK_NEWS:String = "Home.CLICK_NEWS";
		static public const CLICK_CENTER:String = "Home.CLICK_CENTER";
		static public const CLICK_GAME:String = "Home.CLICK_GAME";
		
		private var eventChannel:EventChannel = null;
		
		private var intDefaultWidth:Number = LayoutSettings.intDefaultWidth;
		private var intDefaultHeight:Number = LayoutSettings.intDefaultHeight;
		private const intDefaultHeightForIphone5:Number = LayoutSettings.intDefaultHeightForIphone5;
		private var isIphone5Layout:Boolean = false;
		private var bg:Sprite = null;
		
		private var gameButton:SimpleButton = null;
		private const intGameButtonX:int = 124;
		private var intGameButtonY:int = 504;
		private const intGameButtonYIphone5:int = 564;
		
		private var gameIcon:Sprite = null;
		private const intGameIconX:int = 146;
		private var intGameIconY:int = 573;
		private const intGameIconYIphone5:int = 633;
		private var gameIconRotateObject:RandomRotateObjectModify = null;

		private var newsButton:SimpleButton = null;
		private const intNewsButtonX:int = 130;
		private var intNewsButtonY:int = 637;
		private const intNewsButtonYIphone5:int = 737;
		
		private var newsIcon:Sprite = null;
		private const intNewsIconX:int = 510;
		private var intNewsIconY:int = 701;
		private const intNewsIconYIphone5:int = 801;
		private var newsIconRotateObject:RandomRotateObjectModify = null;
		
		private var centerButton:SimpleButton = null;
		private const intCenterButtonX:int = 123;
		private var intCenterButtonY:int = 772;
		private const intCenterButtonYIphone5:int = 892;
		
		private var centerIcon:Sprite = null;
		private const intCenterIconX:int = 148;
		private var intCenterIconY:int = 827;
		private const intCenterIconYIphone5:int = 947;
		private var centerIconRotateObject:RandomRotateObjectModify = null;

		private var pointVersionNumber:Point = new Point(8, 78);
		
		public function Home() {
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
			createButton();
			addVersionNumber();
		}
		
		private function destructor(e:Event) {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destructor);
			removeButton();
			removeBackground();
			eventChannel = null;
		}
		
		private function changeLayoutForIphone5() {
			intGameButtonY = intGameButtonYIphone5;
			intGameIconY = intGameIconYIphone5;
			intNewsButtonY = intNewsButtonYIphone5;
			intNewsIconY = intNewsIconYIphone5;
			intCenterButtonY = intCenterButtonYIphone5;
			intCenterIconY = intCenterIconYIphone5;
		}
		private function createBackground() {
			bg = (isIphone5Layout) ? new HomeBackgroundIphone5() : new HomeBackgroundIphone4();
			this.addChild(bg);
		}
		
		private function removeBackground() {
			this.removeChild(bg);
			bg = null;
		}
		private function createButton() {
			gameButton = new HomeButton_Game();
			gameButton.x = intGameButtonX;
			gameButton.y = intGameButtonY;
			this.addChild(gameButton);
			
			gameIcon = new HomeGameIcon();
			gameIcon.x = intGameIconX;
			gameIcon.y = intGameIconY;
			this.addChild(gameIcon);
			gameIconRotateObject = new RandomRotateObjectModify(gameIcon);
			
			newsButton = new HomeButton_News();
			newsButton.x = intNewsButtonX;
			newsButton.y = intNewsButtonY;
			this.addChild(newsButton);
			
			newsIcon = new HomeNewsIcon();
			newsIcon.x = intNewsIconX;
			newsIcon.y = intNewsIconY;
			this.addChild(newsIcon);
			newsIconRotateObject = new RandomRotateObjectModify(newsIcon);
			
			centerButton = new HomeButton_Center();
			centerButton.x = intCenterButtonX;
			centerButton.y = intCenterButtonY;
			this.addChild(centerButton);
			
			centerIcon = new HomeCenterIcon();
			centerIcon.x = intCenterIconX;
			centerIcon.y = intCenterIconY;
			this.addChild(centerIcon);
			centerIconRotateObject = new RandomRotateObjectModify(centerIcon);
			
			addButtonEventListener();
		}
		
		private function addButtonEventListener() {
			gameButton.addEventListener(MouseEvent.CLICK, onHomeButtonClick);
			newsButton.addEventListener(MouseEvent.CLICK, onHomeButtonClick);
			centerButton.addEventListener(MouseEvent.CLICK, onHomeButtonClick);
		}
		
		private function removeButtonEventListener() {
			gameButton.removeEventListener(MouseEvent.CLICK, onHomeButtonClick);
			newsButton.removeEventListener(MouseEvent.CLICK, onHomeButtonClick);
			centerButton.removeEventListener(MouseEvent.CLICK, onHomeButtonClick);
		}
		
		private function removeButton() {
			removeButtonEventListener();
			gameIconRotateObject.dispose();
			gameIconRotateObject = null;
			newsIconRotateObject.dispose();
			newsIconRotateObject = null;
			centerIconRotateObject.dispose();
			centerIconRotateObject = null;
			
			this.removeChild(gameButton);
			this.removeChild(gameIcon);
			this.removeChild(newsButton);
			this.removeChild(newsIcon);
			this.removeChild(centerButton);
			this.removeChild(centerIcon);
			gameButton = null;
			gameIcon = null;
			newsButton = null;
			newsIcon = null;
			centerButton = null;
			centerIcon = null;
		}
		
		private function onHomeButtonClick(e:MouseEvent) {
			if (e.target is HomeButton_Game)     eventChannel.writeEvent(new Event(Home.CLICK_GAME)); 
			if (e.target is HomeButton_News)     eventChannel.writeEvent(new Event(Home.CLICK_NEWS)); 
			if (e.target is HomeButton_Center)   eventChannel.writeEvent(new Event(Home.CLICK_CENTER)); 
		}
		
		private function addVersionNumber() {
			var strVersionNumber:String = GetVersionNumber.getAppVersion();
			var versionTextField:TextField = _createTextField("left", pointVersionNumber.x, pointVersionNumber.y);
			versionTextField.text = "v " + strVersionNumber;
		}
		
		private function _createTextField(align:String, x:Number, y:Number):TextField {
			var tf:TextField = new TextField();
			tf.defaultTextFormat = new TextFormat("Arial", 25, 0xFFFFFF, false, null, null, null, null, align);
			tf.x = x;
			tf.y = y;
			tf.selectable = false;
			this.addChild(tf);
			return tf;
		}
	}
	
}
