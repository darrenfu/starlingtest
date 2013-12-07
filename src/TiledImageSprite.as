/**
 * Created with IntelliJ IDEA.
 * User: pc
 * Date: 13-12-7
 * Time: 下午5:31
 * To change this template use File | Settings | File Templates.
 */
package {
import com.pogo.ui.starling.BorderedSprite;
import com.pogo.ui.starling.StarlingSprite;

import feathers.display.Scale9Image;
import feathers.textures.Scale9Textures;

import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.utils.ByteArray;

import starling.display.DisplayObject;

import starling.display.Sprite;

import starling.textures.Texture;

public class TiledImageSprite extends Sprite {
    public static const CORNER_NE:int = 0;
    public static const CORNER_NW:int = 1;
    public static const CORNER_SE:int = 2;
    public static const CORNER_SW:int = 3;
    public static const SIDE_N:int = 4;
    public static const SIDE_S:int = 5;
    public static const SIDE_W:int = 6;
    public static const SIDE_E:int = 7;
    public static const CENTER:int = 8;

    public static const NUM_PIECES:int = 8;

    protected var mPieces:Vector.<DisplayObject>;
    protected var mCorners:Vector.<Rectangle>;
    protected var mRaster:Texture;

    public function TiledImageSprite(raster:Texture, corners:Vector.<Rectangle>) {
        mRaster = raster;
        mCorners = corners;

        initTextures();
    }

    public function initTextures():void {
        //TODO: may calculate the max width and height
        var width:Number = mCorners[CORNER_NW].width + mCorners[SIDE_N].width + mCorners[CORNER_NE].width;
        var height:Number = mCorners[CORNER_NW].height + mCorners[SIDE_W].height + mCorners[CORNER_SW].height;
//        if (mCorners[CENTER].width > width - mCorners[CORNER_NW].width) {
//            mCorners[CENTER].width = width - mCorners[CORNER_NW].width;
//        }
//        if (mCorners[CENTER].height > height - mCorners[CORNER_NW].height) {
//            mCorners[CENTER].height = height - mCorners[CORNER_NW].height;
//        }

        mPieces = new Vector.<ByteArray>(NUM_PIECES);
        for (var i:int = CORNER_NE; i <= SIDE_E; i++) {
            var bytes:ByteArray = mRaster.getPixels(mCorners[i]);
            bytes.position = 0;
            mPieces[i] = bytes;
        }
        return layoutPieces(width, height);
    }

    protected function layoutPieces(width:Number, height:Number):Scale9Textures {
        var borderBmd:BitmapData = new BitmapData(width, height, true);
        var pieceRect:Rectangle = new Rectangle();

        // center
//        pieceRect.x = mCorners[CORNER_NW].width/2;
//        pieceRect.y = mCorners[CORNER_NW].height/2;
//        pieceRect.width = mCorners[CENTER].width;
//        pieceRect.height = mCorners[CENTER].height;
//        borderBmd.setPixels(pieceRect, mPieces[CENTER]);

        // top left
        pieceRect.x = 0;
        pieceRect.y = 0;
        pieceRect.width = mCorners[CORNER_NW].width;
        pieceRect.height = mCorners[CORNER_NW].height;
        borderBmd.setPixels(pieceRect, mPieces[CORNER_NW]);

        // top right
        pieceRect.x = width - mCorners[CORNER_NE].width;
        pieceRect.y = 0;
        pieceRect.width = mCorners[CORNER_NE].width;
        pieceRect.height = mCorners[CORNER_NE].height;
        borderBmd.setPixels(pieceRect, mPieces[CORNER_NE]);

        // bottom left
        pieceRect.x = 0;
        pieceRect.y = height - mCorners[CORNER_SW].height;
        pieceRect.width = mCorners[CORNER_SW].width;
        pieceRect.height = mCorners[CORNER_SW].height;
        borderBmd.setPixels(pieceRect, mPieces[CORNER_SW]);

        // bottom right
        pieceRect.x = width - mCorners[CORNER_SE].width;
        pieceRect.y = height - mCorners[CORNER_SE].height;
        pieceRect.width = mCorners[CORNER_SE].width;
        pieceRect.height = mCorners[CORNER_SE].height;
        borderBmd.setPixels(pieceRect, mPieces[CORNER_SE]);

        // top
        pieceRect.x = mCorners[CORNER_NW].width;
        pieceRect.y = 0;
        pieceRect.width = mCorners[SIDE_N].width;
        pieceRect.height = mCorners[SIDE_N].height;
        borderBmd.setPixels(pieceRect, mPieces[SIDE_N]);

        // bottom
        pieceRect.x = mCorners[CORNER_SW].width;
        pieceRect.y = height - mCorners[SIDE_S].height;
        pieceRect.width = mCorners[SIDE_S].width;
        pieceRect.height = mCorners[SIDE_S].height;
        borderBmd.setPixels(pieceRect, mPieces[SIDE_S]);

        // left
        pieceRect.x = 0;
        pieceRect.y = mCorners[CORNER_NW].height;
        pieceRect.width = mCorners[SIDE_W].width;
        pieceRect.height = mCorners[SIDE_W].height;
        borderBmd.setPixels(pieceRect, mPieces[SIDE_W]);

        // right
        pieceRect.x = width - mCorners[SIDE_E].width;
        pieceRect.y = mCorners[CORNER_NE].height;
        pieceRect.width = mCorners[SIDE_E].width;
        pieceRect.height = mCorners[SIDE_E].height;
        borderBmd.setPixels(pieceRect, mPieces[SIDE_E]);

        // unscalable area
        pieceRect.x = mCorners[CORNER_NW].width;
        pieceRect.y = mCorners[CORNER_NW].height;
        pieceRect.width = mCorners[SIDE_N].width;
        pieceRect.height = mCorners[SIDE_W].height;

        var textures:Scale9Textures = new Scale9Textures(Texture.fromBitmapData(borderBmd), pieceRect);
        borderBmd.dispose();
        mPieces.length = 0;
        return textures;
    }

}
}
