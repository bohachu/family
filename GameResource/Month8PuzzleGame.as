package GameResource {
	
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.SimpleButton;
	import flash.geom.Point;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.media.Sound;
	import tw.cameo.LayoutManager;
	import tw.cameo.LayoutSettings;
	import tw.cameo.EventChannel;
	import tw.cameo.events.GameMakerEvent;
	import tw.cameo.ToastMessage;
	
	public class Month8PuzzleGame extends MovieClip {

		public static const PUZZLE_COMPLETE:String = "Month8PuzzleGame.PUZZLE_COMPLETE";
		
		private var eventChannel:EventChannel = EventChannel.getInstance();
		private const isUseIphone5Layout:Boolean = LayoutManager.useIphone5Layout();
		private var intDefaultHeight:Number = (isUseIphone5Layout) ? LayoutSettings.intDefaultHeightForIphone5 : LayoutSettings.intDefaultHeight;
		
		private var puzzleOriginalPicture:Sprite = null;
		private var lstPuzzles:Array = null;
		private var lstPuzzleMover:Array = null;
		private var lstBoolLocationDone:Array = [false, false, false, false, false, false, false];
		
		private var puzzleBg:Sprite = null;
		private var puzzleBgPosition:Point = new Point(0, (isUseIphone5Layout) ? 118 : 16);
		
		private var intCloseRange:int = 15;
		private var dicPuzzleLocation:Object = {
			"1": new Point(53, (isUseIphone5Layout) ? 69 : 69),
			"2": new Point(397, (isUseIphone5Layout) ? 69 : 69),
			"3": new Point(171, (isUseIphone5Layout) ? 69 : 69),
			"4": new Point(170, (isUseIphone5Layout) ? 290 : 290),
			"5": new Point(54, (isUseIphone5Layout) ? 292 : 292),
			"6": new Point(54, (isUseIphone5Layout) ? 291 : 291),
			"7": new Point(54, (isUseIphone5Layout) ? 424 : 424)
		};
		
		private var puzzleHintButton:SimpleButton = null;
		private var puzzleHintButtonPosition:Point = new Point(0, (isUseIphone5Layout) ? 830 : 655);
		private var puzzleHint:Sprite = null;
		private var puzzleHintPosition:Point = new Point(230, (isUseIphone5Layout) ? 640 : 465);
		private var puzzleSound:Sound = null;
		
		public function Month8PuzzleGame() {
			// constructor code
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event) {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(Event.REMOVED_FROM_STAGE, destructor);
			initPuzzleBg();
			initPuzzleHintButton();
			initPuzzleMover();
			initPuzzle();
		}
		
		private function destructor(e:Event) {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destructor);
			removePuzzleHintButton();
			removePuzzle();
			removePuzzleMover();
			removePuzzleBg();
			
			dicPuzzleLocation = null;
			puzzleHintButtonPosition = null;
			puzzleHintPosition = null;
		}
		
		private function initPuzzleBg() {
			puzzleBg = new PuzzleBackground();
			puzzleBg.x = puzzleBgPosition.x;
			puzzleBg.y = puzzleBgPosition.y;
			this.addChild(puzzleBg);
		}
		
		private function removePuzzleBg() {
			if (puzzleBg) this.removeChild(puzzleBg);
			puzzleBg = null;
			puzzleBgPosition = null;
		}
		
		private function initPuzzleMover() {
			lstPuzzleMover = [
				new PuzzleMover01(),
				new PuzzleMover02(),
				new PuzzleMover03(),
				new PuzzleMover04(),
				new PuzzleMover05(),
				new PuzzleMover06(),
				new PuzzleMover07()
			];
			
			for (var i:int = 0; i<lstPuzzleMover.length; i++) {
				lstPuzzleMover[i].name = String(i+1);
				lstPuzzleMover[i].x = getRandomLocation("x", lstPuzzleMover[i].width/2);
				lstPuzzleMover[i].y = getRandomLocation("y", lstPuzzleMover[i].height/2);
				lstPuzzleMover[i].addEventListener(MouseEvent.MOUSE_DOWN, handlePuzzleMouseDown);
				lstPuzzleMover[i].addEventListener(MouseEvent.MOUSE_UP, handlePuzzleMouseUp);
				lstPuzzleMover[i].alpha = 0;
				this.addChild(lstPuzzleMover[i]);
			}
		}
		
		private function removePuzzleMover() {
			for (var i:int = 0; i<lstPuzzleMover.length; i++) {
				lstPuzzleMover[i].removeEventListener(MouseEvent.MOUSE_DOWN, handlePuzzleMouseDown);
				lstPuzzleMover[i].removeEventListener(MouseEvent.MOUSE_UP, handlePuzzleMouseUp);
				lstPuzzleMover[i].removeEventListener(MouseEvent.MOUSE_MOVE, handlePuzzleMouseMove);
				this.removeChild(lstPuzzleMover[i]);
				lstPuzzleMover[i] = null;
			}
			lstPuzzleMover.length = 0;
			lstPuzzleMover = null;
		}
		
		private function handlePuzzleMouseDown(e:MouseEvent) {
			var puzzleMover:MovieClip = e.target as MovieClip;
			var intIndex:int = int(puzzleMover.name) - 1;
			disableAllMouseExcept(intIndex);
			
			puzzleMover.startDrag();
			puzzleMover.addEventListener(MouseEvent.MOUSE_MOVE, handlePuzzleMouseMove);
		}
		
		private function disableAllMouseExcept(intIndex:int) {
			for (var i:int = 0; i<lstPuzzleMover.length; i++) {
				if (i != intIndex) lstPuzzleMover[i].mouseEnabled = false;
			}
		}
		
		private function enableAllMouse() {
			for (var i:int = 0; i<lstPuzzleMover.length; i++) {
				lstPuzzleMover[i].mouseEnabled = true;
			}
		}
		
		private function handlePuzzleMouseUp(e:MouseEvent) {
			var puzzleMover:MovieClip = e.target as MovieClip;
			puzzleMover.stopDrag();
			puzzleMover.removeEventListener(MouseEvent.MOUSE_MOVE, handlePuzzleMouseMove);
			enableAllMouse();
			
			if (checkIsCloseLocation(puzzleMover)) {
				var intIndex:int = int(puzzleMover.name)-1;
				puzzleMover.x = lstPuzzles[intIndex].x = dicPuzzleLocation[puzzleMover.name].x;
				puzzleMover.y = lstPuzzles[intIndex].y = dicPuzzleLocation[puzzleMover.name].y;
				puzzleMover.removeEventListener(MouseEvent.MOUSE_DOWN, handlePuzzleMouseDown);
				puzzleMover.removeEventListener(MouseEvent.MOUSE_UP, handlePuzzleMouseUp);
				
				lstBoolLocationDone[intIndex] = true;
				puzzleSound.play();
			}
			
			if (checkAllPuzzleIsDone()) puzzleFinish();
		}
		
		private function handlePuzzleMouseMove(e:MouseEvent) {
			var puzzleMover:MovieClip = e.target as MovieClip;
			var intIndex:int = int(puzzleMover.name)-1;
			lstPuzzles[intIndex].x = puzzleMover.x;
			lstPuzzles[intIndex].y = puzzleMover.y;
		}
		
		private function checkIsCloseLocation(puzzleMover:MovieClip):Boolean {
			var isClose:Boolean = false;
			var intDx:Number = Math.abs(puzzleMover.x - dicPuzzleLocation[puzzleMover.name].x);
			var intDy:Number = Math.abs(puzzleMover.y - dicPuzzleLocation[puzzleMover.name].y);
			
			if (intDx < intCloseRange && intDy < intCloseRange) {
				isClose = true;
			}
			
			return isClose;
		}
		
		private function checkAllPuzzleIsDone():Boolean {
			var isAllTrue:Boolean = true;
			for (var i:int = 0; i<lstBoolLocationDone.length; i++) {
				if (lstBoolLocationDone[i] != true) isAllTrue = false;
			}
			return isAllTrue;
		}
		
		private function initPuzzle() {
			lstPuzzles = [
				new Mouse08PuzzleSprite01(),
				new Mouse08PuzzleSprite02(),
				new Mouse08PuzzleSprite03(),
				new Mouse08PuzzleSprite04(),
				new Mouse08PuzzleSprite05(),
				new Mouse08PuzzleSprite06(),
				new Mouse08PuzzleSprite07()
			];
			
			for (var i:int = 0; i<lstPuzzles.length; i++) {
				lstPuzzles[i].x = lstPuzzleMover[i].x;
				lstPuzzles[i].y = lstPuzzleMover[i].y;
				this.addChild(lstPuzzles[i]);
			}
			
			puzzleSound = new PuzzleMoveSound();
		}
		
		private function removePuzzle() {
			for (var i:int = 0; i<lstPuzzles.length; i++) {
				this.removeChild(lstPuzzles[i]);
				lstPuzzles[i] = null;
			}
			lstPuzzles.length = 0;
			lstPuzzles = null;
			puzzleSound = null;
		}
		
		private function getRandomLocation(strTarget:String, intLength:Number):Number {
			var intRange:Number = 0;
			
			if (strTarget == "x") {
				intRange = 640-intLength;
			}
			if (strTarget == "y") {
				intRange = intDefaultHeight - intLength;
			}
			
			var intResult:Number = Math.random()*intRange;
			
			return intResult;
		}
		
		private function initPuzzleHintButton() {
			puzzleHintButton = new PuzzleHintButton();
			puzzleHintButton.x = puzzleHintButtonPosition.x;
			puzzleHintButton.y = puzzleHintButtonPosition.y;
			puzzleHintButton.addEventListener(MouseEvent.MOUSE_DOWN, showHint);
			
			puzzleOriginalPicture = new Month8PuzzleOriginal();
			
			this.addChild(puzzleHintButton);
		}
		
		private function removePuzzleHintButton() {
			if (puzzleHintButton) {
				puzzleHintButton.removeEventListener(MouseEvent.MOUSE_DOWN, showHint);
				puzzleHintButton.removeEventListener(MouseEvent.MOUSE_UP, hideHint);
				this.removeChild(puzzleHintButton);
			}
			puzzleOriginalPicture = null;
			puzzleHintButton = null;
		}
		
		private function showHint(e:MouseEvent) {
			puzzleHintButton.addEventListener(MouseEvent.MOUSE_UP, hideHint);
			puzzleHint = new PuzzleHintBg();
			puzzleHint.x = puzzleHintPosition.x;
			puzzleHint.y = puzzleHintPosition.y;
			
			puzzleOriginalPicture.width = puzzleOriginalPicture.height = 240;
			puzzleOriginalPicture.x = 65;
			puzzleOriginalPicture.y = 30;
			puzzleHint.addChild(puzzleOriginalPicture);
			this.addChild(puzzleHint);
		}
		
		private function hideHint(e:MouseEvent) {
			puzzleHintButton.removeEventListener(MouseEvent.MOUSE_UP, hideHint);
			if (puzzleHint) {
				puzzleHint.removeChild(puzzleOriginalPicture);
				this.removeChild(puzzleHint);
			}
			puzzleHint = null;
		}
		
		private function puzzleFinish() {
			this.dispatchEvent(new Event(Month8PuzzleGame.PUZZLE_COMPLETE));
		}

	}
	
}
