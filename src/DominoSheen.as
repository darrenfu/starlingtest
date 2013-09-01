/**
 * Created with IntelliJ IDEA.
 * User: dgrossen
 * Date: 8/7/13
 * Time: 9:24 AM
 * To change this template use File | Settings | File Templates.
 */
package {
import com.pogo.ui.anim.TickInterpolator;
import com.pogo.ui.anim.TickableDelay;
import com.pogo.ui.anim.TickableQueue;
import com.pogo.ui.anim.TickableSet;
import com.pogo.ui.anim.TickableTask;
import com.pogo.ui.starling.ImageSprite;
import com.pogo.ui.starling.StarlingLinearSpriteMover;
import com.pogo.ui.starling.StarlingSprite;
import com.pogo.util.ITickable;
import com.pogo.util.TickManager;

import flash.display.Bitmap;
import flash.display.BitmapData;

import starling.animation.IAnimatable;
import starling.core.Starling;
import starling.extensions.pixelmask.PixelMaskDisplayObject;
import starling.textures.Texture;

public class DominoSheen extends StarlingSprite implements IAnimatable {
    [Embed(source="../../webapps/pogo/htdocs/applet/domino2/images/en/include/e_domino.png")]
    public static const domino:Class;
    [Embed(source="../../webapps/pogo/htdocs/applet/domino2/images/all/include/emblem_gradient.png")]  //dom.anim.endhand.message.sheen.gradient.alpha.img.ras //sheenGradientAlphaRaster
    public static const sheen:Class;  //dom.anim.endhand.message.sheen.gradient.alpha.img.ras //sheenGradientAlphaRaster
    [Embed(source="../../webapps/pogo/htdocs/applet/domino2/images/en/include/e_domino_sheen.png")]  //dom.anim.endhand.message.sheen.mask //maskRaster
    public static const messageSheenMask:Class; //dom.anim.endhand.message.sheen.mask //maskRaster

    private var dominoImage:StarlingSprite;
    private var sheenGradientAlphaRaster:StarlingSprite;

    public function DominoSheen() {
        super();
        dominoImage = new ImageSprite(Texture.fromBitmap(new domino()));
        addChild(dominoImage);

        var staggeredSheenAnim:ITickable = makeStaggeredSheenAnimation(this, (new messageSheenMask() as Bitmap).bitmapData, "dom.anim.endhand.message");

        var animationTick:ITickable = staggeredSheenAnim;
        var tickQueue:TickableQueue = new TickableQueue(true);
//            tickQueue.add(setupTickable);
        tickQueue.add(animationTick);
//            tickQueue.add(destroyTickable);
        TickManager.singleton().addTickable(tickQueue);
        Starling.juggler.add(this);
    }

    public function advanceTime(time:Number):void {
        TickManager.singleton().doTick();
    }

    internal function makeStaggeredSheenAnimation(parent:StarlingSprite, maskRaster:BitmapData, key:String):ITickable {
        var staggeredSheenAnim:TickableSet = new TickableSet();
        var numSheens:int = 1;
        var sheenStagger:int = 2000;

        for (var count:int = 0; count < 30; count++) {
            var sheenAnim:ITickable = makeSheenAnimation(parent, maskRaster, key);
            var staggerDelay:TickableDelay = new TickableDelay(sheenStagger * count);

            var tickQueue:TickableQueue = new TickableQueue(true);
            tickQueue.add(staggerDelay);
            tickQueue.add(sheenAnim);
            staggeredSheenAnim.add(tickQueue);
        }

        return staggeredSheenAnim;
    }

    public function makeSheenAnimation(parent:StarlingSprite, maskRaster:BitmapData, key:String):ITickable {
        sheenGradientAlphaRaster = new ImageSprite(Texture.fromBitmap(new sheen()));
        var sheenAlpha:Number = 1;
        var animTime:int = 800;

        var maskFilter:PixelMaskDisplayObject = new PixelMaskDisplayObject();

        var maskRasterImage:ImageSprite = new ImageSprite(Texture.fromBitmapData(maskRaster));
        maskFilter.addChild(sheenGradientAlphaRaster);
        maskRasterImage.alpha = sheenAlpha;
        maskFilter.mask = maskRasterImage;

        var initialX:int = 0;//-sheenGradientAlphaRaster.width;
        var initialY:int = 0;
        sheenGradientAlphaRaster.setOrigin(initialX, initialY);

        //var sheenMaskMoveSprite:SheenMaskMoveAdapterSprite= new SheenMaskMoveAdapterSprite(sheenGradientAlphaRaster, maskFilter);

        var runnable:Function = function ():void {
            parent.add(maskFilter);
        };
        var linkSheenSpriteTick:ITickable = new TickableTask(runnable);

        var shineSheenTick:TickInterpolator = new TickInterpolator(animTime, 30);
        var moveSheenAcross:StarlingLinearSpriteMover = new StarlingLinearSpriteMover(sheenGradientAlphaRaster, maskRaster.width, 0);
        shineSheenTick.addInterpolatable(moveSheenAcross);

        var runnable2:Function = function ():void {
            sheenGradientAlphaRaster.unlink(false);
        }
//            var unlinkSheenSpriteTick:ITickable= new TickableTask(runnable2);
        var animQueue:TickableQueue = new TickableQueue(true);
        animQueue.add(linkSheenSpriteTick);
        animQueue.add(shineSheenTick);
//            animQueue.add(unlinkSheenSpriteTick);

        return animQueue;
    }
}
}
