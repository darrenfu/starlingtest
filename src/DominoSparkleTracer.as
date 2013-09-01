/**
 * Created with IntelliJ IDEA.
 * User: dgrossen
 * Date: 8/7/13
 * Time: 9:24 AM
 * To change this template use File | Settings | File Templates.
 */
package {
import com.pogo.game.domino2.client.Domino2Utils;
import com.pogo.ui.anim.TickInterpolator;
import com.pogo.ui.anim.TickInterpolatorJavaPort;
import com.pogo.ui.anim.TickableQueue;
import com.pogo.ui.starling.ImageSprite;
import com.pogo.ui.starling.StarlingAlphaInterpolator;
import com.pogo.ui.starling.StarlingSprite;
import com.pogo.ui.starling.StarlingTickableTaskUtils;
import com.pogo.util.ITickable;
import com.pogo.util.TickManager;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Rectangle;

import starling.animation.IAnimatable;
import starling.animation.Tween;
import starling.core.Starling;
import starling.textures.Texture;

public class DominoSparkleTracer extends StarlingSprite implements IAnimatable {
    [Embed(source="../../webapps/pogo/htdocs/applet/domino2/images/all/include/default_dominoset.png")]
    public static const tile:Class; // dom.tilesets.default.img.ras
    [Embed(source="../../webapps/pogo/htdocs/applet/domino2/images/all/include/small_sparkle.png")]
    public static const sparkle:Class;  //dom.anim.dominotile.tracer.sparkle.img.ras
    [Embed(source="../../webapps/pogo/htdocs/applet/domino2/images/all/include/dominoe_red.gif")]
    public static const trace:Class; // dom.anim.dominotile.tracer.trace.img.ras

    public static const FRAME_RATE:int = 30;

    private var dominoTileImage:ImageSprite;

    public function DominoSparkleTracer() {
        super();
        var bmp:Bitmap = new tile();
        dominoTileImage = new ImageSprite(Texture.fromBitmap(bmp));
        dominoTileImage.x = 100;
        dominoTileImage.y = 100;
        addChild(dominoTileImage);

        var sparkleAnim:ITickable = makeTracerAnim(dominoTileImage, this, null);//"dom.anim.dominotile.tracer");
//            addTransientAnimation(sparkleAnim, "domplayed");
        var animationTick:ITickable = sparkleAnim;
        var tickQueue:TickableQueue = new TickableQueue(true);
        tickQueue.add(animationTick);

        //ADDED for local testing
        TickManager.singleton().addTickable(tickQueue);
        Starling.juggler.add(this);
    }

    public function advanceTime(time:Number):void {
        TickManager.singleton().doTick();
    }

    /**
     * Create a trace animation for the image sprite.
     * @param sprite
     * @param parent
     * @param key
     * @param tracerSubRect
     * @return
     */
    public function makeTracerAnim(sprite:ImageSprite, parent:StarlingSprite, key:String, tracerSubRect:Rectangle = null):ITickable {
        if (tracerSubRect == null) {
            tracerSubRect = sprite.getSubRect();
        }

        // tracer animation
        var sparkleRaster:Texture = Texture.fromBitmap(new sparkle);// mServices.getRaster(key + ".sparkle");
        var traceRaster:BitmapData = (new trace() as Bitmap).bitmapData; // mServices.getBitmap(key + ".trace");

        var tracerAnimSprite:SparkleTracerAnimSprite = SparkleTracerAnimSprite.makeSparkleTracerSpriteWithTraceSubRect(
                null,
                sparkleRaster, traceRaster,
                tracerSubRect, FRAME_RATE,
                key);
        tracerAnimSprite.setOrigin(sprite.getX(), sprite.getY());
//        addChild(tracerAnimSprite);

        var fadeTracerTick:ITickable= makeFadeAnimationBySprite(tracerAnimSprite, false, tracerAnimSprite.getAnimTime());

        var linkTracerAnimTick:ITickable = Domino2Utils.createLinkTask(parent, tracerAnimSprite, -1, false);

        var tracerFadeAnim:ITickable= Domino2Utils.combineTickable(fadeTracerTick, tracerAnimSprite);
        var unlinkTracerAnimTick:ITickable= Domino2Utils.createUnlinkSpriteTask(tracerAnimSprite, true);

        var tickQueue:TickableQueue = new TickableQueue(true);
        tickQueue.add(linkTracerAnimTick);
//        tickQueue.add(tracerAnimSprite);
        tickQueue.add(tracerFadeAnim);
//        tickQueue.add(fadeTracerTick);
        tickQueue.add(unlinkTracerAnimTick);
        return tickQueue;
    }

        public function makeFadeAnimationBySprite(fadingSprite:StarlingSprite, fadeIn:Boolean, duration:Number):ITickable {
            var spriteVector:Vector.<StarlingSprite> = new <StarlingSprite>[fadingSprite];
            return makeFadeAnimationBySpriteVector(spriteVector, fadeIn, duration);
        }

        public function makeFadeAnimationBySpriteVector(
                fadingSprites:Vector.<StarlingSprite>, fadeIn:Boolean, duration:Number):ITickable {
            var tickQueue:TickableQueue= new TickableQueue(true);

            var alpha1:int= fadeIn? 0 : 1;
            var alpha2:int= fadeIn? 1 : 0;
            var tickInterop:TickInterpolatorJavaPort= new TickInterpolatorJavaPort(duration, FRAME_RATE);
            tickInterop.alwaysExecute();

            for (var index:int= 0; index < fadingSprites.length; index++) {
//                var fadingSprite:StarlingSprite = fadingSprites[index];
//                Starling.juggler.tween(fadingSprite, duration / 1000.0, {
//                            onComplete: function():void {
//                                fadingSprite.visible = !fadeIn;
//                                Starling.juggler.removeTweens(fadingSprite);
//                            },
//                            alpha: fadeIn ? 1.0 : 0.0,
//                            delay: delay / 1000.0
//                });
                var alphaInterop:StarlingAlphaInterpolator= new StarlingAlphaInterpolator(fadingSprites[index], alpha1, alpha2);
                tickInterop.addInterpolatable(alphaInterop);
            }


            var fadingSpritesArray:Array = new Array();
            for each(var sprite:StarlingSprite in fadingSprites) {
                fadingSpritesArray.push(sprite);
            }
            var setVisibleTick:ITickable= StarlingTickableTaskUtils.createSetSpritesVisibleTask(fadingSpritesArray, fadeIn, true);

            if (fadeIn) tickQueue.add(setVisibleTick);	// set visible before fade in
            tickQueue.add(tickInterop);
            if (!fadeIn) tickQueue.add(setVisibleTick); // set invisible after fade out

            return tickQueue;
        }


}
}
