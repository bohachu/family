package GameResource {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.SimpleButton;
	import flash.geom.Point;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import tw.cameo.LayoutManager;
	import tw.cameo.LayoutSettings;
	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	import flash.media.Sound;
	
	public class PuzzleGame extends MovieClip {
		
		public static const PUZZLE_COMPLETE:String = "PuzzleGame.PUZZLE_COMPLETE";

		private var intDefaultHeight:Number = LayoutSettings.intDefaultHeight;
		private const intDefaultHeightForIphone5:int = LayoutSettings.intDefaultHeightForIphone5;
		private const isUseIphone5Layout:Boolean = LayoutManager.useIphone5Layout();
		
		private var puzzleOriginalPicture:Sprite = null;
		private var lstPuzzles:Array = null;
		private var lstPuzzleOrder:Array = new Array();
		private var intEmptySlot:int = 8;
		private var intMovePuzzle:int = 0;
		
		private var puzzleBg:Sprite = null;
		private var puzzleBgPosition:Point = new Point(0, (isUseIphone5Layout) ? 118 : 16);
		
		private var lstPuzzleLocation:Array = [
			new Point(55, (isUseIphone5Layout) ? 172 : 70),
			new Point(231, (isUseIphone5Layout) ? 172 : 70),
			new Point(407, (isUseIphone5Layout) ? 172 : 70),
			new Point(55, (isUseIphone5Layout) ? 348 : 246),
			new Point(231, (isUseIphone5Layout) ? 348 : 246),
			new Point(407, (isUseIphone5Layout) ? 348 : 246),
			new Point(55, (isUseIphone5Layout) ? 524 : 422),
			new Point(231, (isUseIphone5Layout) ? 524 : 422),
			new Point(407, (isUseIphone5Layout) ? 524 : 422)
		];
		
		private var puzzleHintButton:SimpleButton = null;
		private var puzzleHintButtonPosition:Point = new Point(0, (isUseIphone5Layout) ? 830 : 655);
		private var puzzleHint:Sprite = null;
		private var puzzleHintPosition:Point = new Point(230, (isUseIphone5Layout) ? 640 : 465);
		private var puzzleMoveSound:Sound = null;
		
		public function PuzzleGame(puzzleOriginalPictureIn:Sprite = null, lstPuzzlesIn:Array = null) {
			// constructor code
			puzzleOriginalPicture = puzzleOriginalPictureIn;
			lstPuzzles = lstPuzzlesIn;
			
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event) {
			this.addEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(Event.REMOVED_FROM_STAGE, destructor);
			
			initPuzzleBg();
			initPuzzleOrder();
			initPuzzle();
			initPuzzleHintButton();
		}
		
		private function destructor(e:Event) {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destructor);
			removePuzzleHintButton();
			removePuzzle();
			removePuzzleBg();
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
		
		private function initPuzzleOrder() {
			var isOldNumber:Boolean = true;
			var intNewNumber:int = 0;
			for (var i=0; i<9; i++) {
				isOldNumber = true;
				while (isOldNumber) {
					intNewNumber = Math.floor(Math.random()*9);
					isOldNumber = false;
					for (var j=0; j<lstPuzzleOrder.length; j++) {
						if (intNewNumber == lstPuzzleOrder[j]) isOldNumber = true;
					}
				}
				lstPuzzleOrder.push(intNewNumber);
			}
		}
		
		private function initPuzzle() {
			lstPuzzles[8].name = "8";
			lstPuzzles[8].x = lstPuzzleLocation[8].x;
			lstPuzzles[8].y = lstPuzzleLocation[8].y;
			lstPuzzles[8].alpha = 0;
			this.addChild(lstPuzzles[8]);
			for (var i=0; i<9; i++) {
				var puzzle:Sprite = lstPuzzles[lstPuzzleOrder[i]];
				puzzle.name = String(lstPuzzleOrder[i]);
				if (lstPuzzleOrder[i] != 8)	{
					puzzle.x = lstPuzzleLocation[i].x;
					puzzle.y = lstPuzzleLocation[i].y;
					this.addChild(puzzle);
				} else {
					intEmptySlot = i;
				}
			}
			
			puzzleMoveSound = new PuzzleMoveSound();
			addControlToPuzzle();
		}
		
		private function removePuzzle() {
			if (lstPuzzles) {
				removeAllControlFromPuzzle();
				for (var i=0; i<9; i++) {
					this.removeChild(lstPuzzles[i]);
					lstPuzzles[i] = null;
				}
				lstPuzzles.length = 0;
			}
			lstPuzzles = null;
			
			lstPuzzleOrder.length = 0;
			lstPuzzleOrder = null;
			
			lstPuzzleLocation.length = 0;
			lstPuzzleLocation = null;
			
			if (puzzleOriginalPicture) {
				if (this.contains(puzzleOriginalPicture)) this.removeChild(puzzleOriginalPicture);
			}
			puzzleOriginalPicture = null;
			puzzleMoveSound = null;
		}
		
		private function addControlToPuzzle() {
			if ((intEmptySlot - 3) >= 0) lstPuzzles[lstPuzzleOrder[intEmptySlot - 3]].addEventListener(MouseEvent.MOUSE_DOWN, movePuzzle);
			if ((intEmptySlot + 3) <= 8) lstPuzzles[lstPuzzleOrder[intEmptySlot + 3]].addEventListener(MouseEvent.MOUSE_DOWN, movePuzzle);
			if ((intEmptySlot - 1) >= 0 && intEmptySlot != 3 && intEmptySlot != 6) lstPuzzles[lstPuzzleOrder[intEmptySlot - 1]].addEventListener(MouseEvent.MOUSE_DOWN, movePuzzle);
			if ((intEmptySlot + 1) <= 8 && intEmptySlot != 2 && intEmptySlot != 5) lstPuzzles[lstPuzzleOrder[intEmptySlot + 1]].addEventListener(MouseEvent.MOUSE_DOWN, movePuzzle);
		}
		
		private function removeAllControlFromPuzzle() {
			for (var i=0; i<8; i++) {
				lstPuzzles[i].removeEventListener(MouseEvent.MOUSE_DOWN, movePuzzle);
			}
		}
		
		private function movePuzzle(e:MouseEvent) {
			intMovePuzzle = int(e.target.name);
			removeAllControlFromPuzzle();
			puzzleMoveSound.play();
			TweenLite.to(e.target, 0.2, {x:lstPuzzleLocation[intEmptySlot].x, y:lstPuzzleLocation[intEmptySlot].y, onComplete:movePuzzleComplete});
		}
		
		private function movePuzzleComplete() {
			var intMovePuzzleLocation:int = lstPuzzleOrder.indexOf(intMovePuzzle);
			lstPuzzleOrder[intMovePuzzleLocation] = 8;
			lstPuzzleOrder[intEmptySlot] = intMovePuzzle;
			intEmptySlot = intMovePuzzleLocation;
			if (isPuzzleComplete()) {
				puzzleComplete();
			} else {
				addControlToPuzzle();
			}
		}
		
		private function isPuzzleComplete():Boolean {
			for (var i=0; i<lstPuzzleOrder.length; i++) {
				if (i != lstPuzzleOrder[i]) return false;
			}
			return true;
		}
		
		private function puzzleComplete() {
			puzzleHintButton.removeEventListener(MouseEvent.MOUSE_DOWN, showHint);
			TweenLite.to(lstPuzzles[8], 2, {alpha:1, onComplete:showLastPuzzleComplete});
		}
		
		private function showLastPuzzleComplete() {
			puzzleOriginalPicture.width = puzzleOriginalPicture.height = 528;
			puzzleOriginalPicture.x = lstPuzzleLocation[0].x;
			puzzleOriginalPicture.y = lstPuzzleLocation[0].y;
			puzzleOriginalPicture.alpha = 0;
			this.addChild(puzzleOriginalPicture);
			TweenLite.to(puzzleOriginalPicture, 2, {alpha:1, onComplete:showOriginalPictureComplete});
		}
		
		private function showOriginalPictureComplete() {
			this.dispatchEvent(new Event(PuzzleGame.PUZZLE_COMPLETE));
		}
		
		private function initPuzzleHintButton() {
			puzzleHintButton = new PuzzleHintButton();
			puzzleHintButton.x = puzzleHintButtonPosition.x;
			puzzleHintButton.y = puzzleHintButtonPosition.y;
			puzzleHintButton.addEventListener(MouseEvent.MOUSE_DOWN, showHint);
			this.addChild(puzzleHintButton);
		}
		
		private function removePuzzleHintButton() {
			if (puzzleHintButton) {
				puzzleHintButton.removeEventListener(MouseEvent.MOUSE_DOWN, showHint);
				puzzleHintButton.removeEventListener(MouseEvent.MOUSE_UP, hideHint);
				this.removeChild(puzzleHintButton);
			}
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
	}
	
}
