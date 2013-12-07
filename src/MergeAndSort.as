/**
 * Created with IntelliJ IDEA.
 * User: darrenfu
 * Date: 9/2/13
 * Time: 3:53 PM
 * To change this template use File | Settings | File Templates.
 */
package {
import flash.display.MovieClip;
import flash.geom.Point;

public class MergeAndSort extends MovieClip {
	public function MergeAndSort() {
		super();
		var s:String="";
		if (!s)
			trace("empty")
		s=null
		if (!s)
			trace("null")

//		var d:uint = parseInt("0xFF00FF", 16);
//		graphics.beginFill(d, 1);
//		graphics.drawCircle(100, 100, 5);
//		graphics.endFill();

//		var lines:Vector.<Point> = new <Point>[
//			new Point(5, 6),
//			new Point(4, 8),
//			new Point(8, 9),
//			new Point(1, 2),
//			new Point(100, 102),
//			new Point(102, 105),
//			new Point(103, 106)
//		];
//		var outputs:Vector.<Point> = mergeAndSort(lines);
//		trace(outputs.length);
//		for (var i:int=0; i<outputs.length; i++) {
//			trace(outputs[i].x, outputs[i].y);
//		}
	}

	public static function mergeAndSort(lines:Vector.<Point>):Vector.<Point> {
		var res:Vector.<Point> = new Vector.<Point>();
		if (lines && lines.length) {
			var min:int = int.MAX_VALUE;
			var max:int = int.MIN_VALUE;
			for (var i:int=0; i<lines.length; i++) {
				var p:Point = lines[i];
				if (min > p.x) {
					min = p.x;
				}
				if (max < p.y) {
					max = p.y;
				}
			}

			var flagLen:int = max - min;
			var flags:Vector.<Boolean> = new Vector.<Boolean>(flagLen, true);
			for (var i:int=0; i<flags.length; i++) {
				flags[i] = false; // init flags
			}
			for (var i:int=0; i<lines.length; i++) {
				var p:Point = lines[i];
				for (var markIdx:int=p.x; markIdx<p.y; markIdx++) {
					flags[markIdx-min] = true;
					//TODO: optimization
				}
			}

			var isContinue:Boolean = false;
			var lastFlag:Boolean = false;
			var tmpPoint:Point = new Point();
			for (var i:int=0; i<flags.length; i++) {
				if (flags[i] != lastFlag) {
					isContinue = false;

					//TODO
					if (lastFlag) { // push to
						tmpPoint.y = i + 1;
						res.push(tmpPoint);
					} else {
						tmpPoint = new Point(i, int.MIN_VALUE);
					}
				} else {
					isContinue = true;
				}
				lastFlag = flags[i];
			}
		}
		return res;
	}
}
}
