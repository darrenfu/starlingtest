package {
import com.pogo.ui.starling.ImageSprite;

import flash.geom.Point;

import starling.textures.Texture;

public class Tracer extends ImageSprite {
    private var mTraceHistoryX:Vector.<int>;
    private var mTraceHistoryY:Vector.<int>;
    private var mTraceHistoryPos:int;

    private var mCurrentTraceX:int;
    private var mCurrentTraceY:int;

    private var mTracerAnimationSprite:SparkleTracerAnimSprite;


    public function Tracer(animationSprite:SparkleTracerAnimSprite,raster:Texture, x:int, y:int) {
        super(raster);
        this.mTracerAnimationSprite = animationSprite;
        mTraceHistoryX = new Vector.<int>(animationSprite.traceHistorySize);
        mTraceHistoryY = new Vector.<int>(animationSprite.traceHistorySize);
        for (var index:int= 0; index < animationSprite.traceHistorySize; index++) {
            mTraceHistoryX[index] = -1;
            mTraceHistoryY[index] = -1;
        }

        mCurrentTraceX = -1;
        mCurrentTraceY = -1;

        setTracePosition(x, y);
    }

    public function setTracePosition(x:int, y:int):void {
        mTraceHistoryX[mTraceHistoryPos] = mCurrentTraceX;
        mTraceHistoryY[mTraceHistoryPos] = mCurrentTraceY;
        mTraceHistoryPos = (mTraceHistoryPos + 1) % mTracerAnimationSprite.traceHistorySize;

        mCurrentTraceX = x;
        mCurrentTraceY = y;

        // center sprite on the trace position
        setOrigin((x - mTracerAnimationSprite.tracerSubRect.x) - getWidth() / 2, (y - mTracerAnimationSprite.tracerSubRect.y) - getHeight() / 2);
    }

    public function calculateSumRoughDistanceFromHistory(point:Point):int {
        var sumDistance:int= 0;
        for (var index:int= 0; index < mTracerAnimationSprite.traceHistorySize; index++) {
            sumDistance += mTracerAnimationSprite.calculateRoughDistance(point, mTraceHistoryX[index], mTraceHistoryY[index]);
        }

        return sumDistance;
    }

    public function isTraceHistoryPoint(point:Point):Boolean {
        for (var index:int= 0; index < mTracerAnimationSprite.traceHistorySize; index++) {
            if (point.x == mTraceHistoryX[index] && point.y == mTraceHistoryY[index]) {
                return true;
            }
        }

        return false;
    }

    public function isCurrentTracePoint(point:Point):Boolean {
        return point.x == mCurrentTraceX && point.y == mCurrentTraceY;
    }


    public function getCurrentTraceX():int {
        return mCurrentTraceX;
    }

    public function getCurrentTraceY():int {
        return mCurrentTraceY;
    }

    public function getCurrentLocation():Point {
        return new Point(mCurrentTraceX, mCurrentTraceY);
    }
}

}