package GameResource {
	
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.SimpleButton;
	import flash.utils.getDefinitionByName;
	import flash.utils.Timer;
	import flash.geom.Point;
	import flash.media.Sound;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import tw.cameo.LayoutManager;
	import tw.cameo.LayoutSettings;
	import tw.cameo.EventChannel;
	import tw.cameo.events.GameMakerEvent;
	import tw.cameo.ToastMessage;
	
	public class Month11PuzzleGame extends MovieClip {

		public static const PUZZLE_COMPLETE:String = "Month11PuzzleGame.PUZZLE_COMPLETE";
		
		private var eventChannel:EventChannel = EventChannel.getInstance();
		private const isUseIphone5Layout:Boolean = LayoutManager.useIphone5Layout();
		private var intDefaultHeight:Number = (isUseIphone5Layout) ? LayoutSettings.intDefaultHeightForIphone5 : LayoutSettings.intDefaultHeight;
		
		private var lstPuzzleX:Array = [60, 345];
		private var lstPuzzleY:Array = (isUseIphone5Layout) ? [88, 406, 725] : [32, 317, 602];
		private var lstPuzzleLocation:Array = new Array();
		private var lstFace:Array = null;
		
		private var firstSelectFace:MovieClip = null;
		private var secondSelectFace:MovieClip = null;
		private var lstIsFaceMatch:Array = [false, false, false];
		
		private var faceFlipSound:Sound = null;
		private var faceMatchSound:Sound = null;
		private var faceDismatchSound:Sound = null;
		
		public function Month11PuzzleGame() {
			// constructor code
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event) {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(Event.REMOVED_FROM_STAGE, destructor);
			
			initPuzzleLocation();
			initPuzzle();
			playPuzzle();
		}
		
		private function destructor(e:Event) {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destructor);
			remvoeFaceEventListener();
			remvoePuzzle();

			lstPuzzleX = null;
			lstPuzzleY = null;
			lstPuzzleLocation = null;
			lstIsFaceMatch = null;
			
			faceFlipSound = null;
			faceMatchSound = null;
			faceDismatchSound = null;
		}
		
		private function initPuzzleLocation() {
			for (var i:int = 0; i<6; i++) {
				var lstNewLocation:Array = new Array();
				lstPuzzleLocation.push(getNewLocation());
			}
		}
		
		private function getNewLocation():int {
			var isNewLocation:Boolean = true;
			var intNewLocation:int = 0;
			
			do {
				intNewLocation = Math.floor(Math.random()*6);
				isNewLocation = true;
				for (var i:int = 0; i<lstPuzzleLocation.length; i++) {
					if (lstPuzzleLocation[i] == intNewLocation) {
							isNewLocation = false;
					}
				}
			} while (!isNewLocation);
			
			return intNewLocation;
		}
		
		private function initPuzzle() {
			lstFace = new Array();
			for (var i:int = 0; i<3; i++) {
				var face1Class:Class = getDefinitionByName("Month11Face" + String(i*2+1)) as Class;
				var face1:MovieClip = new face1Class() as MovieClip;
				face1.name = String(i+1) + String("_1");
				face1.x = lstPuzzleX[lstPuzzleLocation[i] % 2];
				face1.y = lstPuzzleY[lstPuzzleLocation[i] % 3];
				face1.addEventListener(MouseEvent.CLICK, onFaceClick);
				var face2Class:Class = getDefinitionByName("Month11Face" + String(i*2+2)) as Class;
				var face2:MovieClip = new face2Class() as MovieClip;
				face2.name = String(i+1) + String("_2");
				face2.x = lstPuzzleX[lstPuzzleLocation[i+3] % 2];
				face2.y = lstPuzzleY[lstPuzzleLocation[i+3] % 3];
				face2.addEventListener(MouseEvent.CLICK, onFaceClick);
				
				lstFace[i] = face1;
				lstFace[i+3] = face2;
				
				this.addChild(face1);
				this.addChild(face2);
			}
			
			faceFlipSound = new PuzzleMoveSound();
			faceMatchSound = new LotteryWin();
			faceDismatchSound = new LotteryFail();
		}
		
		private function remvoePuzzle() {
			for (var i:int = 0; i<lstFace.length; i++) {
				this.removeChild(lstFace[i]);
				lstFace[i] = null;
				lstFace.length = 0;
			}
			lstFace = null;
		}
		
		private function playPuzzle() {
			firstSelectFace = null;
			secondSelectFace = null;
			addFaceEventListener();
		}
		
		private function addFaceEventListener() {
			for (var i:int = 0; i<lstIsFaceMatch.length; i++) {
				if (!lstIsFaceMatch[i]) {
					lstFace[i].addEventListener(MouseEvent.CLICK, onFaceClick);
					lstFace[i+3].addEventListener(MouseEvent.CLICK, onFaceClick);
				}
			}
		}
		
		private function remvoeFaceEventListener() {
			for (var i:int = 0; i<lstFace.length; i++) {
				lstFace[i].removeEventListener(MouseEvent.CLICK, onFaceClick);
			}
		}
		
		private function onFaceClick(e:MouseEvent) {
			faceFlipSound.play();
			
			var faceMovieClip:MovieClip = e.target as MovieClip;
			faceMovieClip.gotoAndStop(2);
			
			if (firstSelectFace == null) {
				faceMovieClip.removeEventListener(MouseEvent.CLICK, onFaceClick);
				firstSelectFace = faceMovieClip;
				return;
			}
			
			secondSelectFace = faceMovieClip;
			remvoeFaceEventListener();
			
			if (firstSelectFace.name.charAt(0) == secondSelectFace.name.charAt(0)) {
				faceMatchSound.play();
				lstIsFaceMatch[int(firstSelectFace.name.charAt(0))-1] = true;
				
				if (checkIsAllFaceMath()) {
					puzzleFinish();
				} else {
					playPuzzle();
				}
			} else {
				faceDismatchSound.play();
				var flipFaceBackTimer:Timer = new Timer(1000, 1);
				flipFaceBackTimer.addEventListener(TimerEvent.TIMER, onFlipFaceBackTimer);
				flipFaceBackTimer.start();
			}
		}
		
		private function onFlipFaceBackTimer(e:TimerEvent) {
			var flipFaceBackTimer:Timer = e.target as Timer;
			flipFaceBackTimer.stop();
			flipFaceBackTimer.removeEventListener(TimerEvent.TIMER, onFlipFaceBackTimer);
			flipFaceBackTimer = null;
			
			firstSelectFace.gotoAndStop(1);
			secondSelectFace.gotoAndStop(1);
			
			playPuzzle();
		}
		
		private function checkIsAllFaceMath():Boolean {
			var isAllFaceMatch:Boolean = true;
			
			for (var i:int=0; i<lstIsFaceMatch.length; i++) {
				if (!lstIsFaceMatch[i]) isAllFaceMatch = false;
			}
			
			return isAllFaceMatch;
		}
		
		private function puzzleFinish() {
			this.dispatchEvent(new Event(Month11PuzzleGame.PUZZLE_COMPLETE));
		}
		
		private function dummyFunctionForDynamicCreate() {
			var face1:Month11Face1 = null;
			var face2:Month11Face2 = null;
			var face3:Month11Face3 = null;
			var face4:Month11Face4 = null;
			var face5:Month11Face5 = null;
			var face6:Month11Face6 = null;
		}

	}
	
}
