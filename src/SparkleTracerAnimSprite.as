/**
 * Created with IntelliJ IDEA.
 * User: peterpeng
 * Date: 7/12/13
 * Time: 6:46 PM
 * To change this template use File | Settings | File Templates.
 */
package {
import com.pogo.game.domino2.client.Domino2Utils;
import com.pogo.game.domino2.util.TickableTimeTracker;
import com.pogo.ui.anim.TickInterpolator;
import com.pogo.ui.anim.TickInterpolatorJavaPort;
import com.pogo.ui.anim.TickableQueue;
import com.pogo.ui.anim.TickableSet;
import com.pogo.ui.starling.StarlingAlphaInterpolator;
import com.pogo.ui.starling.StarlingSprite;
import com.pogo.util.ITickable;
import com.pogo.util.Properties;
import com.pogo.util.Randleton;
import com.pogo.util.VectorUtils;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;

import starling.core.Starling;

import starling.textures.Texture;
import starling.utils.Color;

public class SparkleTracerAnimSprite extends StarlingSprite implements ITickable{

    private var mSparkleRaster:Texture;
    private var mTraceRaster:BitmapData;
    private var mTracerSubRect:Rectangle;

    private var mNumTracers:int;
    private var mTailFadeTime:Number;
    private var mTraceColor:uint;
    private var mTraceHistorySize:int;
    private var mTraceTime:Number;
    private var mFPS:int;
    private var mMilliPerStep:Number;
    private var mTailInitialOpacity:Number;

    private var mStepTimeAccumulator:Number = 0;


    private var mTracerSprites:Vector.<Tracer>;

    private var mTempVector:Vector.<Object>= new Vector.<Object>();

    private var mTimeTracker:TickableTimeTracker;
    private var mTickSet:TickableSet;

    public function SparkleTracerAnimSprite(...args) {
        if(args.length == 11) {
            var sparkleRaster:Texture = args[0] as Texture;
            var traceRaster:BitmapData = args[1] as BitmapData;
            var tracerSubRect:Rectangle = args[2] as Rectangle;
            var traceColor:uint = args[3] as uint;
            var numSparkles:int = args[4] as int;
            var traceTime:Number = args[5]as Number;
            var tailFadeTime:int = args[6] as int;
            var tailInitialOpacity:Number = args[7] as Number;
            var traceHistorySize:int = args[8] as int;
            var fps:int = args[9] as int;
            var stepsPerSecond:Number = args[10];
        }else if(args.length == 9) {
            var sparkleRaster:Texture = args[0] as Texture;
            var traceRaster:BitmapData = args[1] as BitmapData;
            var tracerSubRect:Rectangle = null;
            var traceColor:uint = args[2] as uint;
            var numSparkles:int = args[3] as int;
            var traceTime:Number = args[4] as Number;
            var tailFadeTime:int = args[5] as int;
            var tailInitialOpacity:Number = 1.0;
            var traceHistorySize:int = args[6] as int;
            var fps:int = args[7] as int;
            var stepsPerSecond:Number = args[8] as Number;
        } else {
	        throw new Error("SparkleTracerAnimationSprite Constructor argument does not match!");
        }

        mSparkleRaster = sparkleRaster;
        mTraceRaster = traceRaster;
        mTracerSubRect = (null == tracerSubRect ?
                new Rectangle(0, 0, traceRaster.width, traceRaster.height) :
                tracerSubRect);

        mNumTracers = numSparkles;
        mTailFadeTime = tailFadeTime;
        mTailInitialOpacity = tailInitialOpacity;
        mTraceColor = traceColor;
        mTraceHistorySize = traceHistorySize;
        mTraceTime = traceTime;

        mTimeTracker = new TickableTimeTracker();
        mTickSet = new TickableSet();

        mFPS = fps;
        mMilliPerStep = 1000.0/ stepsPerSecond;

        setSize(mTracerSubRect.width, mTracerSubRect.height);

        createTracers();
    }

    /**
     * External request to cancel this Tickable. Invoked just prior to a
     * Tickable being prematurely terminated. Implementations should
     * perform any necessary cleanup.
     */
    public function cancel():void {
	    mTickSet.cancel();
	    mTimeTracker.reset();
	    reset();
    }

	public function tick(seq:Number, systime:Number):Boolean {
		if (mTimeTracker.getElapsedTime() >= mTraceTime) {
			mTimeTracker.reset();
			mStepTimeAccumulator = 0;
			return true;
		} else {
			var deltaElapsedTime:Number = mTimeTracker.getElapsedTime(systime);
			mStepTimeAccumulator += deltaElapsedTime;


			while (mStepTimeAccumulator > mMilliPerStep) {
				mStepTimeAccumulator -= mMilliPerStep;
				updateTracers(mStepTimeAccumulator);
			}


			mTimeTracker.tick(seq, systime);
			mTickSet.tick(seq, systime);

			return false;
		}
	}



	private function updateTracers(stepTimeElapsed:Number):void {
		for (var index:int = 0; index < mTracerSprites.length; index++) {
			var tracer:Tracer = mTracerSprites[index];
			var tracePoints:Vector.<Point> = scanForTrace(tracer.getCurrentTraceX(), tracer.getCurrentTraceY(), 2, false);

			// error case
			if (!tracePoints) {
				continue;
			}

			// should be at least 3, one behind, one current, one forward
			var nextPoint:Point = null;
			var maxSumHistoryDistance:int = -1;
			for (var pointIdx:int = 0; pointIdx < tracePoints.length; pointIdx++) {
				var tracePoint:Point = tracePoints[pointIdx];
				if (!tracer.isTraceHistoryPoint(tracePoint) && !tracer.isCurrentTracePoint(tracePoint)) {
					// problem of checking a grid of 9 spaces and a history of 1, pick the one farthest away from the history
					var sumHistoryDistance:int = tracer.calculateSumRoughDistanceFromHistory(tracePoint);
					if (sumHistoryDistance > maxSumHistoryDistance) {
						maxSumHistoryDistance = sumHistoryDistance;
						nextPoint = tracePoint;
					}
				}
			}

			// error case if next point is null
			if (nextPoint != null) {
				// prepare fade away animation
				var tracerFadeAnim:ITickable = makeTracerFadeAnim(tracer.getCurrentTraceX(), tracer.getCurrentTraceY(), stepTimeElapsed);
				mTickSet.add(tracerFadeAnim);

				// move tracer
                tracer.setTracePosition(nextPoint.x, nextPoint.y);
			}
		}
	}

	public function calculateRoughDistance(pt1:Point, x2:int, y2:int):int {
		return (Math.abs(pt1.x - x2) + Math.abs(pt1.y - y2)) as int;
	}

	private function makeTracerFadeAnim(traceX:int, traceY:int, elapsedTime:Number):ITickable {
		var tracerSprite:Tracer = new Tracer(this, mSparkleRaster, traceX, traceY);
		var setupTickable:ITickable = Domino2Utils.createLinkTask(this, tracerSprite, -1, false);

		var fadeTime:Number = Math.max(0, mTailFadeTime - elapsedTime);
		var alpha:Number = (mTailInitialOpacity * (fadeTime / mTailFadeTime) * getAlpha()) as Number;
        alpha = alpha / 255.0;
//        addChild(tracerSprite);
//
//        Starling.juggler.tween(tracerSprite, fadeTime / 1000.0, {
//            onComplete: function():void {
//                Starling.juggler.removeTweens(tracerSprite);
//                tracerSprite.unlink();
//            },
//            alpha: 0.0
////            delay: delay / 1000.0
//        });
		var tickInterop:TickInterpolator = new TickInterpolator(fadeTime, mFPS);
		var alphaInterop:StarlingAlphaInterpolator = new StarlingAlphaInterpolator(tracerSprite, alpha, 0);
		tickInterop.addInterpolatable(alphaInterop);

		var destroyTickable:ITickable = Domino2Utils.createUnlinkSpriteTask(tracerSprite, true);

		var animQueue:TickableQueue = new TickableQueue(true);
		animQueue.add(setupTickable);
		animQueue.add(tickInterop);
		animQueue.add(destroyTickable);

		return animQueue;
	}

	override public function setAlpha(alpha:int):void {
		super.setAlpha(alpha);
		for (var index:int = 0; index < mTracerSprites.length; index++) {
			var sprite:StarlingSprite = mTracerSprites[index] as StarlingSprite;
			sprite.setAlpha(alpha);
		}
	}

	public function reset():void {
		for (var index:int = 0; index < mTracerSprites.length; index++) {
			var sprite:StarlingSprite = mTracerSprites[index] as StarlingSprite;
			sprite.unlink();
		}

		createTracers();
	}

	private function createTracers():void {
		mTracerSprites = new Vector.<Tracer>(mNumTracers);
		for (var index:int= 0; index < mTracerSprites.length; index++) {
			var tracerPosition:Point= findValidTracerPosition();

			var tracerSprite:Tracer= new Tracer(this, mSparkleRaster, tracerPosition.x, tracerPosition.y);
			add(tracerSprite);

			mTracerSprites[index] = tracerSprite;
		}
	}

	private function findValidTracerPosition():Point {
		// randomly pick a location and find the closest red point
		var x:int = Randleton.instance().nextIntWithBounds(mTracerSubRect.x, mTracerSubRect.x + mTracerSubRect.width);
		var y:int = Randleton.instance().nextIntWithBounds(mTracerSubRect.y, mTracerSubRect.y + mTracerSubRect.height);

		var tracePoints:Vector.<Point> = scanForTrace(x, y, Math.max(mTracerSubRect.width, mTracerSubRect.height), true);
		// should have at least one
		if (tracePoints.length > 0) {
			return tracePoints[0];
		} else {
			return null;
		}
	}

	private function scanForTrace(centerX:int, centerY:int, maxSize:int, onlyFirst:Boolean):Vector.<Point> {
		VectorUtils.removeAllElements(mTempVector);
		var tracePoints:Vector.<Object> = mTempVector;
		var maxOffset:int = maxSize / 2;

		for (var currentOffset:int = 0; currentOffset <= maxOffset; currentOffset++) {
			// horizontal scan lines
			var xMinMax:Array = [
                Math.max(centerX - currentOffset, mTracerSubRect.x) as int,
                Math.min(centerX + currentOffset, mTracerSubRect.x + mTracerSubRect.width - 1) as int];
			var yMinMax:Array = [
                Math.max(centerY - currentOffset, mTracerSubRect.y) as int,
                Math.min(centerY + currentOffset, mTracerSubRect.y + mTracerSubRect.height - 1) as int];
//			trace("xMinMax", xMinMax, "yMinMax", yMinMax);

			for (var yIdx:int = 0; yIdx < yMinMax.length; yIdx++) {
				for (var xIdx:int = 0; xIdx < xMinMax.length; xIdx++) {

					// horizontal lines
					var yBound:int = yMinMax[yIdx];
					for (var x:int = xMinMax[0]; x <= xMinMax[1]; x++) {
						if (x < mTracerSubRect.x) {
							continue;
						} else if (x >= mTracerSubRect.x + mTracerSubRect.width) {
							break;
						}

						if (isTracePixel(x, yBound)) {
							var point:Point = new Point(x, yBound);

							if (onlyFirst) {
//								trace("Only first H: " + point.x, point.y);
								return new <Point>[point];
							}
							tracePoints.push(point);
						}
					}

					// vertical lines
					var xBound:int = xMinMax[xIdx];
					for (var y:int = yMinMax[0]; y <= yMinMax[1]; y++) {
						if (y < mTracerSubRect.y) {
							continue;
						} else if (y >= mTracerSubRect.y + mTracerSubRect.height) {
							break;
						}

						if (isTracePixel(xBound, y)) {
							var point:Point = new Point(xBound, y);
							if (onlyFirst) {
//								trace("Only first V: " + point.x, point.y);
								return new <Point>[point];
							}
							tracePoints.push(point);
						}
					}
				}
			}
		}

		var tracePointsArray:Vector.<Point> = new Vector.<Point>(tracePoints.length);
		for (var index:int = 0; index < tracePointsArray.length; index++) {
			tracePointsArray[index] = tracePoints[index] as Point;
		}

		return tracePointsArray;
	}

	private function isTracePixel(x:int, y:int):Boolean {
		var pixel:uint = mTraceRaster.getPixel(x, y);
		return mTraceColor == pixel;
	}


	public function getTracerLocations():Vector.<Point> {
		var tracerLocationsArray:Vector.<Point>= new Vector.<Point>(mNumTracers);

		for (var index:int= 0; index < mTracerSprites.length; index++) {
			var tracer:Tracer= mTracerSprites[index];
			tracerLocationsArray[index] = tracer.getCurrentLocation();
		}

		return tracerLocationsArray;
	}

	public function getNumTracers():int {
		return mNumTracers;
	}

	public function getAnimTime():Number {
		return mTraceTime;
	}

    public function getTraceTime():Number {
        return this.mTraceTime;
    }

	public static function makeSparkleTracerSprite(
            p:Properties, sparkleRaster:Texture, traceRaster:BitmapData, fps:int,
            prefix:String):SparkleTracerAnimSprite {
        return makeSparkleTracerSpriteWithTraceSubRect(p, sparkleRaster, traceRaster, null, fps,
                prefix);
    }

    public static function makeSparkleTracerSpriteWithTraceSubRectForScoring(
            p:Properties, sparkleRaster:Texture, traceRaster:BitmapData,
            traceSubRect:Rectangle, fps:int, prefix:String):SparkleTracerAnimSprite {
        var numSparkles:int= 10;//PropsCoreUtils.makeInt(p, prefix + ".sparkles.num");
        var traceHistorySize:int= 1;
        var tailFadeTime:int= 600;//PropsCoreUtils.makeInt(p, prefix + ".tailfade.ms");
        var tracerAnimTime:int= 1500;//PropsCoreUtils.makeInt(p, prefix + ".anim.ms");
        var stepsPerSecond:Number= 100.0;//PropsCoreUtils.makeDouble(p, prefix + ".speed");
        var traceRasterSubRect:Rectangle= traceSubRect;//(traceSubRect != null ? traceSubRect
        //: PropsUtils.makeRectWithProperties(p, prefix + ".trace.sub"));
        var traceColor:uint = Color.RED;
        var tailInitialOpacity:Number= 1.0;

//        if (p.getProperty(prefix + ".trace.size") != null) {
//            traceHistorySize = PropsCoreUtils.makeInt(p, prefix + ".trace.size");
//        }
//
//	    trace("makeSparkleTracerSpriteWithTraceSubRect", prefix + ".trace");
//        if (p.getProperty(prefix + ".trace") != null) {
//            traceColor = PropsUtils.makeColorWithProperties(p, prefix + ".trace");
//        }
//
//        if (p.getProperty(prefix + ".tail.opacity.init") != null) {
//            tailInitialOpacity = PropsCoreUtils.makeDouble(p, prefix
//                    + ".tail.opacity.init");
//        }

        return new SparkleTracerAnimSprite(sparkleRaster, traceRaster,
                traceRasterSubRect, traceColor, numSparkles, tracerAnimTime,
                tailFadeTime, tailInitialOpacity, traceHistorySize, fps,
                stepsPerSecond);
    }

    public static function makeSparkleTracerSpriteWithTraceSubRect(
            p:Properties, sparkleRaster:Texture, traceRaster:BitmapData,
            traceSubRect:Rectangle, fps:int, prefix:String):SparkleTracerAnimSprite {
        var numSparkles:int= 5;//PropsCoreUtils.makeInt(p, prefix + ".sparkles.num");
        var traceHistorySize:int= 1;
        var tailFadeTime:int= 250;//PropsCoreUtils.makeInt(p, prefix + ".tailfade.ms");
        var tracerAnimTime:int= 1000;//PropsCoreUtils.makeInt(p, prefix + ".anim.ms");
        var stepsPerSecond:Number= 100.0;//PropsCoreUtils.makeDouble(p, prefix + ".speed");
        var traceRasterSubRect:Rectangle= traceSubRect;//(traceSubRect != null ? traceSubRect
                //: PropsUtils.makeRectWithProperties(p, prefix + ".trace.sub"));
        var traceColor:uint = Color.RED;
        var tailInitialOpacity:Number= 1.0;

//        if (p.getProperty(prefix + ".trace.size") != null) {
//            traceHistorySize = PropsCoreUtils.makeInt(p, prefix + ".trace.size");
//        }
//
//	    trace("makeSparkleTracerSpriteWithTraceSubRect", prefix + ".trace");
//        if (p.getProperty(prefix + ".trace") != null) {
//            traceColor = PropsUtils.makeColorWithProperties(p, prefix + ".trace");
//        }
//
//        if (p.getProperty(prefix + ".tail.opacity.init") != null) {
//            tailInitialOpacity = PropsCoreUtils.makeDouble(p, prefix
//                    + ".tail.opacity.init");
//        }

        return new SparkleTracerAnimSprite(sparkleRaster, traceRaster,
                traceRasterSubRect, traceColor, numSparkles, tracerAnimTime,
                tailFadeTime, tailInitialOpacity, traceHistorySize, fps,
                stepsPerSecond);
    }

    public function get traceHistorySize():int {
        return mTraceHistorySize;
    }

    public function get tracerSubRect():Rectangle {
        return mTracerSubRect;
    }
}
}
