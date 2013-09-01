//
// (c) 2005 Electronic Arts Inc.
//
package {
import com.pogo.ui.starling.anim.*;

import com.pogo.ui.anim.TickInterpolator;
import com.pogo.ui.anim.TickableQueue;
import com.pogo.ui.starling.StarlingLinearSpriteMover;
    import com.pogo.ui.starling.StarlingPropsUtils;
    import com.pogo.ui.starling.StarlingSprite;
import com.pogo.ui.starling.text.FontInfo;
import com.pogo.ui.starling.text.SimpleTextSprite;
import com.pogo.util.FontRasterUtils;
import com.pogo.util.ITickable;
    import com.pogo.util.Properties;
    import com.pogo.util.RunnableTask;

    import starling.text.BitmapFont;

    /**
 * Implements the standard scrolling ticker animation.
 * 
 * @author <a href="mailto:hshah@ea.com">Hemal Shah</a>
 * Nov 4, 2005
 */
public class DominoMarqueeTickerAnimation extends MarqueeTickerAnimation {

	internal var mScrollTime:int;
	internal var mSpacingTime:int;
    private var mTPS:int;
	// ============================================================================
	
	public function DominoMarqueeTickerAnimation( prefix:String, tps:int, scrollTime:int, spacingTime:int) {
		super(null, prefix, tps, scrollTime, spacingTime);
	}
	// ============================================================================	

	/* (non-Javadoc)
	 * @see com.pogo.game.client2.firstclass2.TickerAnimation#buildTickerAnimation(java.lang.String, com.pogo.game.uitools.sprite.Sprite, com.pogo.game.uitools.sprite.FontRaster)
	 */
	override public function buildTickerAnimation(message:String, tickerSprite:StarlingSprite,
			fontRaster:String):ITickable {
		var tickQueue:TickableQueue= new TickableQueue(true);
        var fontInfo:FontInfo = FontRasterUtils.getFontInfo(message, fontRaster);
        var labelSprite:SimpleTextSprite= new SimpleTextSprite(0,0, "");
        labelSprite.setText(message);
		labelSprite.setSize(fontInfo.renderedWidth, fontInfo.renderedHeight);
		labelSprite.setOrigin(tickerSprite.getWidth(), 0);
		//labelSprite.setColorKey(tickerSprite.getColorKey());
		//labelSprite.setBlendMode(tickerSprite.getBlendMode());

        var r1:Function = function():void{
            tickerSprite.add(labelSprite);
        };
		tickQueue.add(new RunnableTask(r1));
		
		var tickInterpolator:TickInterpolator= new TickInterpolator(mScrollTime, mTPS);
		var lsm:StarlingLinearSpriteMover= new StarlingLinearSpriteMover(labelSprite, -labelSprite.getWidth(), 0);
		tickInterpolator.addInterpolatable(lsm);
		
		tickQueue.add(tickInterpolator);

        var r2:Function = function():void{
            labelSprite.unlink();
        };
        tickQueue.add(new RunnableTask(r2));

		return tickQueue;
	}
}
}

