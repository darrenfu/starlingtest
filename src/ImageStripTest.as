/**
 * Created with IntelliJ IDEA.
 * User: dgrossen
 * Date: 8/7/13
 * Time: 9:24 AM
 * To change this template use File | Settings | File Templates.
 */
package {
import com.pogo.game.domino2.client.Domino2Utils;
import com.pogo.game.domino2.client.DominoClientConfig;
import com.pogo.game.domino2.util.TextureSourceData;
import com.pogo.ui.anim.TickableQueue;
import com.pogo.ui.starling.StarlingPropsUtils;
import com.pogo.ui.starling.StarlingSprite;
import com.pogo.ui.starling.anim.FlyInTickerAnimation;
import com.pogo.ui.starling.anim.MarqueeTickerAnimation;
import com.pogo.ui.starling.anim.StarlingTickerSprite;
import com.pogo.ui.starling.anim.TickerAnimation;
import com.pogo.util.ITickable;
import com.pogo.util.MessageFormat;
import com.pogo.util.RunnableTask;
import com.pogo.util.TickManager;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Rectangle;

import starling.animation.IAnimatable;
import starling.core.Starling;

import starling.display.Quad;
import starling.textures.Texture;

public class ImageStripTest extends StarlingSprite implements IAnimatable {

    [Embed(source="../../webapps/pogo/htdocs/applet/domino2/images/all/include/tics_black_pips.png")]
    public static const pips:Class;//dom.anim.scoring.values.img.ras

	[Embed(source="../../webapps/pogo/htdocs/applet/domino2/images/all/include/dice_patterns.png")]
	public static const dice:Class;

    public function ImageStripTest() {
        super();

	    var rankValueRaster:BitmapData = Bitmap(new pips()).bitmapData;
	    var managedRankStyleRaster:BitmapData = new BitmapData(rankValueRaster.width, rankValueRaster.height);
	    var rankSubRect:Rectangle= new Rectangle(0, 60, 20, 20);
	    var tempRaster:BitmapData = new BitmapData(7 * rankSubRect.width, rankSubRect.height/*, true, 0xffcccc*/);
//	    tempRaster.copyPixels(rankValueRaster, new Rectangle(rankSubRect.x, rankSubRect.y, tempRaster.width, tempRaster.height),
//			    new Point(), null, null, true);
	    Domino2Utils.copyBlitBetweenRasters(rankValueRaster, managedRankStyleRaster);

		StarlingPropsUtils.blitBitmap(managedRankStyleRaster, tempRaster, 0, 0, rankSubRect.x, rankSubRect.y, tempRaster.width, tempRaster.height);
	    var rankValueSprite:DominoImageStripSprite = new DominoImageStripSprite("-rank-", tempRaster, new Rectangle(0, 0, rankSubRect.width, rankSubRect.height));
//		rankValueSprite.stripRect = new Rectangle(rankSubRect.x, rankSubRect.y, rankSubRect.width, rankSubRect.height);
//	    rankValueSprite.stripRect = new Rectangle(0, 0, rankSubRect.width, rankSubRect.height);
	    rankValueSprite.setSize(rankSubRect.width, rankSubRect.height);
	    trace(rankValueSprite.rows);
	    rankValueSprite.index = 6;
	    tempRaster.dispose();

//	    add(rankValueSprite);

	    var mHalfDominoRaster:TextureSourceData = new TextureSourceData("blabla", Texture.fromBitmap(new dice()));
	    var faceSprite:HalfTileSprite= new HalfTileSprite(mHalfDominoRaster, rankValueSprite);
	    var halfDominoStrip:Rectangle = new Rectangle(0,0,22,22);
	    faceSprite.stripRect = new Rectangle(halfDominoStrip.x, halfDominoStrip.y, halfDominoStrip.width, halfDominoStrip.height);
	    faceSprite.setSize(halfDominoStrip.width, halfDominoStrip.height);
	    trace(faceSprite.rows);
	    faceSprite.index = 0;
	    if (faceSprite.numChildren > 1) {
		    faceSprite.setChildIndex(rankValueSprite, faceSprite.numChildren - 1);
	    }

	    add(faceSprite);

	    createTickerText();

	    Starling.juggler.add(this);
    }

	public function advanceTime(time:Number):void {
		TickManager.singleton().doTick();
	}


	private function createTickerText():void {
		var marqueeAnim:MarqueeTickerAnimation= new DominoMarqueeTickerAnimation( DominoClientConfig.KEY_UI_TICKER, 30,
				7000, 7000);
		var flyAnim:TickerAnimation= new FlyInTickerAnimation(30,
				1000,
				2000,
				500);

		var tickerFontRaster:String= DominoClientConfig.FONT_RASTER_TICKER;
		var mTicker:StarlingTickerSprite = new StarlingTickerSprite(tickerFontRaster, marqueeAnim);
		mTicker.setBoundsFromRectangle(new Rectangle(149,307,430,21));
		mTicker.addTickerAnimation(DominoClientConfig.TICKER_FLY_ID, flyAnim);

//		var q:Quad = new Quad(mTicker.width, mTicker.height, 0x000000);
//		q.alpha = .3;
//		mTicker.add(q);

		TickManager.singleton().addTickable(mTicker);
		this.add(mTicker);

		var args:Array=[12.5444, 14.533424];
		var message:String = "There {0,choice,0#are no tiles|1# is one tile|1<are {0,number,0.000} tiles} in the bone pile.";
		message = MessageFormat.applyFormat(message, args);
		mTicker.queueMessage(message, DominoClientConfig.TICKER_FLY_ID);
	}

}
}
