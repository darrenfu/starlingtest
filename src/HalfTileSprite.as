/**
 * Created with IntelliJ IDEA.
 * User: darrenfu
 * Date: 8/22/13
 * Time: 5:04 PM
 * To change this template use File | Settings | File Templates.
 */
package {
import com.pogo.game.domino2.util.TextureSourceData;

public class HalfTileSprite extends DominoImageStripSprite {
//	private var mShaderSprite:StarlingSprite;

	public function HalfTileSprite(faceRaster:TextureSourceData, /*shaderSprite:StarlingImageStripSprite, */rankValueSprite:DominoImageStripSprite) {
		super(faceRaster.cacheKey, faceRaster.bitmapData);
//		mShaderSprite = shaderSprite;

		add(rankValueSprite);
//		add(mShaderSprite);
//		shadeFace(false);
	}

//	public function shadeFace(shade:Boolean):void {
//		mShaderSprite.setVisible(shade);
//	}
}
}

