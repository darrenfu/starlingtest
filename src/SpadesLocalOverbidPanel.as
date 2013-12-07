package {
import com.pogo.ui.starling.ImageSprite;
import com.pogo.ui.starling.gf1.Panel;

import flash.geom.Rectangle;

import starling.textures.Texture;

/**
 * Panel that displays the overbid dots in the scoreboard.
 */
public class SpadesLocalOverbidPanel extends Panel {
    [Embed(source="../../webapps/pogo/htdocs/applet/spades2/images/all/include/interface.gif")]
    public static const interfaceBmp:Class;

	private static const OVERBOOK_THRESHOLD:int= 10;
	private static const DOT_COLUMNS:int= 5;
	private static const DOT_ROWS:int= 2;
	private static const HGAP:int= 6;//2;
	private static const VGAP:int= 6;//1;


	private var mOverbidPicts:Vector.<ImageSprite>;
    private var onSubBounds:Rectangle = new Rectangle(116,5,5,5);
    private var offSubBounds:Rectangle = new Rectangle(116,0,5,5);

	public function SpadesLocalOverbidPanel() {
		mOverbidPicts = new Vector.<ImageSprite>(OVERBOOK_THRESHOLD);
		for (var i:int= 0; i < mOverbidPicts.length; ++i) {
			mOverbidPicts[i] = new ImageSprite(Texture.fromBitmap(new interfaceBmp()),offSubBounds );
//            trace("Overbid,", i, ":", HGAP + HGAP * (i % DOT_COLUMNS), VGAP + VGAP * int(i / DOT_COLUMNS ), HGAP, VGAP);
            mOverbidPicts[i].setBounds(HGAP + HGAP * (i % DOT_COLUMNS), VGAP + VGAP * int(i / DOT_COLUMNS ), HGAP, VGAP);
            add( mOverbidPicts[i]);
		}
	}

	function setOverbids(overbids:int):void {
		for (var i:int= 0; i <  mOverbidPicts.length; ++i) {
			if (i < overbids) {
				mOverbidPicts[i].setSubRect(onSubBounds);
			} else {
				mOverbidPicts[i].setSubRect(offSubBounds);
			}
		}
	}
}
}

