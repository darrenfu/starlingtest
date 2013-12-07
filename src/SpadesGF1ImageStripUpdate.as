/**
 * Created with IntelliJ IDEA.
 * User: dgrossen
 * Date: 8/7/13
 * Time: 9:24 AM
 * To change this template use File | Settings | File Templates.
 */
package {
import com.pogo.ui.FontDefinition;
import com.pogo.ui.starling.ButtonSprite;
import com.pogo.ui.starling.StarlingPropsUtils;
import com.pogo.ui.starling.StarlingSprite;
import com.pogo.ui.starling.gf1.Panel;
import com.pogo.ui.starling.text.LabelSprite;
import com.pogo.util.TickManager;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.filters.ColorMatrixFilter;
import flash.filters.DropShadowFilter;
import flash.geom.Rectangle;
import flash.utils.getTimer;

import starling.animation.IAnimatable;
import starling.core.Starling;
import starling.textures.Texture;

public class SpadesGF1ImageStripUpdate extends StarlingSprite implements IAnimatable {
    [Embed(source="../../webapps/pogo/htdocs/applet/spades2/images/all/include/vranks.jpg")]
    public static const spadesRanks:Class;

    private var spadesRanksImg:Texture;
    private var spadesBtn:ButtonSprite;
    private var spadesSysLbl:LabelSprite;

    private var mRankBaseRect:Rectangle = new Rectangle(0,0,50,25);
    private var mBoundRect:Rectangle = new Rectangle(86,82,50,25);

    private var lastTime:Number=-1;
    private var currentTime:Number = 0;
    private var rankIdx:int = 0;
    private var sysFont:FontDefinition = new FontDefinition("Helvetica", 1, 12);

    public function SpadesGF1ImageStripUpdate() {
        super();
        var bmd:BitmapData = (new spadesRanks() as Bitmap).bitmapData;
        var bmp:Bitmap = new spadesRanks() as Bitmap;

        var container:Sprite = new Sprite();

        var val:Number = .5;
        var matrix:Array = [].concat([val,0,0,0,0])
                .concat([0,val,0,0,0])
                .concat([0,0,val,0,0])
                .concat([0,0,0,1,0]);
        var filter:ColorMatrixFilter = new ColorMatrixFilter(matrix);
//        bmd.applyFilter(bmd, bmd.rect, new Point(), filter);
//        var underneath:Shape = new Shape();
//        underneath.graphics.beginFill(0x0, 1);
//        underneath.graphics.drawRect(0,0,mRankBaseRect.width, mRankBaseRect.height);
//        underneath.graphics.endFill();
//        container.addChild(new Bitmap(bmd));

        var mask:Shape=new Shape();
        mask.graphics.beginFill(0x0);
        mask.graphics.drawRoundRect(0,0,mRankBaseRect.width, mRankBaseRect.height, 20);
        mask.graphics.endFill();
//        mask.blendMode = BlendMode.ALPHA;
//        mask.cacheAsBitmap = true;

//        mask.blendMode = BlendMode.ERASE;
//        container.blendMode = BlendMode.LAYER;
        container.addChild(bmp);
        container.addChild(mask);
//        container.cacheAsBitmap = true;
//        mask.cacheAsBitmap = true;
        container.mask = mask;
        container.filters = [filter, new DropShadowFilter(3, 45, 0, 1, 4, 4, 1, 1, false)];

        var nBmd:BitmapData = new BitmapData(bmd.width, bmd.height, true, 0xffffffff);
//        nBmd.draw(container);
        spadesRanksImg = Texture.fromBitmapData(nBmd);

        spadesBtn = StarlingPropsUtils.makeButtonWithSubRectAndBounds(spadesRanksImg, mRankBaseRect, mBoundRect);
//        add(spadesBtn);




        // score board
//        spadesSysLbl = StarlingPropsUtils.makeSystemLabelWithBoundsAndAlign(
//                sysFont, "Score:", new Rectangle(5,25,139,62), 0);
//        add (spadesSysLbl);
//        spadesSysLbl = StarlingPropsUtils.makeSystemLabelWithBoundsAndAlign(
//                sysFont, "Overbooks:", new Rectangle(5,39,165,62 ),0);
//        add (spadesSysLbl);
//        spadesSysLbl = StarlingPropsUtils.makeSystemLabelWithBoundsAndAlign(
//                sysFont, "Tricks:", new Rectangle(6,56,139,62 ),0);
//        add (spadesSysLbl);
//        spadesSysLbl = StarlingPropsUtils.makeSystemLabelWithBoundsAndAlign(
//                sysFont, "Bid:", new Rectangle(59,56,124,62 ),0);
//        add (spadesSysLbl);
//        var overbidPanel:Panel = new SpadesLocalOverbidPanel();
//        overbidPanel.setBounds(70,41,35,12);
//        add( overbidPanel);

        var dialog:StarlingSprite = new SpadesCardGamePanel();
        dialog.x = 200;
        dialog.y = 200;
        add(dialog);

        Starling.juggler.add(this);
    }

    public function advanceTime(time:Number):void {
        TickManager.singleton().doTick();

        currentTime = getTimer();
//        trace(lastTime, currentTime);
        var diff:Number = currentTime - lastTime;
        if (diff * .001 > .3) {
//            trace(rankIdx);
//            StarlingPropsUtils.showButtonImageByStripPos(spadesBtn, 0, rankIdx++);
//            if (spadesBtn.getUpState()) {
//                (spadesBtn.getUpState() as ImageSprite).setSubRect(mRankBaseRect);
//            }
//            if (rankIdx++ == 25) {
//                mRankBaseRect.x = 0;
//                mRankBaseRect.y += mRankBaseRect.height;
//            } else {
//                mRankBaseRect.x += mRankBaseRect.width;
//            }
            lastTime = currentTime;
        }
    }

}
}
