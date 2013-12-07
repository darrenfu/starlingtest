package com.pogo.ui.starling {

import feathers.display.TiledImage;

import flash.geom.Rectangle;

import starling.display.DisplayObject;
import starling.display.Image;
import starling.textures.Texture;

/**
 * A sprite with image-based edges and corners, and an empty area in the middle.
 * The sprite can be configured with an image strip and corresponding subrects
 * for each edge and corner. There's also a simplified version which supports
 * a left/right or top/bottom version, with no explicit corners.
 *
 * @author <a href="mailto:hshah@ea.com">Hemal Shah</a>
 */
public class BorderedSprite extends StarlingSprite {
	public static const CORNER_NE:int = 0;
	public static const CORNER_NW:int = 1;
	public static const CORNER_SE:int = 2;
	public static const CORNER_SW:int = 3;
	public static const SIDE_N:int = 4;
	public static const SIDE_S:int = 5;
	public static const SIDE_W:int = 6;
	public static const SIDE_E:int = 7;

	public static const NUM_PIECES:int = 8;

	protected var mPieces:Vector.<DisplayObject>;
	protected var mRaster:Texture;

	protected var maxHeight:int;
	protected var mResizeWithScaling:Boolean = false;

    private var mCorners:Vector.<Rectangle>;

    private var mExpandBorderThickness:Boolean = true;

	public function BorderedSprite() {
		super();
		// consumer must call one of the init methods after creating an instance
	}

	/**
	 * The public constructor.
	 *
	 * The order of the corners[] array is:
	 * 0 = Top Right (NE)
	 * 1 = Top Left (NW)
	 * 2 = Bottom Right (SE)
	 * 3 = Bottom Left (SW)
	 * 4 = Top (N)
	 * 5 = Bottom (S)
	 * 6 = Left (W)
	 * 7 = Right (E)
	 *
	 * @param borderRaster    The raster containing the edge images
	 * @param corners    Rectangles defining the images.
	 */
	public function initWithCorners(raster:Texture, corners:Vector.<Rectangle>):void {
		initialize(raster, corners);
	}

	protected function initialize(raster:Texture, corners:Vector.<Rectangle>):void {
        this.mCorners = corners;
		mPieces = new Vector.<DisplayObject>(NUM_PIECES);
		for (var i:int = CORNER_NE; i <= CORNER_SW; i++) {
			mPieces[i] = new Image(Texture.fromTexture(raster, corners[i]));
			addChild(mPieces[i]);
		}

		for (var j:int = SIDE_N; j <= SIDE_E; j++) {
//			var imageTilerSprite:ImageTilerSprite = new ImageTilerSprite(raster, corners[j]);
//			imageTilerSprite.setSizeByScaling = mResizeWithScaling;
            var subRaster:Texture = Texture.fromTexture(raster, corners[j]);
            var imageTilerSprite:TiledImage = new TiledImage(subRaster);
			mPieces[j] = imageTilerSprite;
			addChild(mPieces[j]);
		}

		setAlpha(getAlpha());
	}

	/**
	 * Creates a BorderedSprite with just two edges and no corners. The edges
	 * can be top and bottom (vertical) or left and right (horizontal).
	 *
	 * @param vertical true for a vertically-oriented sprite
	 * @param raster raster to pull border pixels from
	 * @param start subrect of start (top or left)
	 * @param end subrect of end (bottom or right)
	 */
	public function initSimpleBorderedSprite(vertical:Boolean, raster:Texture, start:Rectangle, end:Rectangle):void {
		var corners:Vector.<Rectangle> = new Vector.<Rectangle>(NUM_PIECES);

		if (vertical) {
			corners[CORNER_NE] = new Rectangle(0, 0, 0, start.height);
			corners[CORNER_NW] = corners[CORNER_NE];
			corners[CORNER_SE] = new Rectangle(0, 0, 0, end.height);
			corners[CORNER_SW] = corners[CORNER_SE];
			corners[SIDE_N] = start;
			corners[SIDE_S] = end;
			corners[SIDE_E] = new Rectangle(0, 0, 0, 0);
			corners[SIDE_W] = corners[SIDE_E];
		}
		else {
			corners[CORNER_NW] = new Rectangle(0, 0, start.width, 0);
			corners[CORNER_SW] = corners[BorderedSprite.CORNER_NW];
			corners[CORNER_NE] = new Rectangle(0, 0, end.width, 0);
			corners[CORNER_SE] = corners[BorderedSprite.CORNER_NE];
			corners[SIDE_W] = start;
			corners[SIDE_E] = end;
			corners[SIDE_N] = new Rectangle(0, 0, 0, 0);
			corners[SIDE_S] = corners[BorderedSprite.SIDE_N];

			maxHeight = start.height;
		}
		initialize(raster, corners);
	}

	protected function setOriginIfNotNull(d:DisplayObject, x:int, y:int):void {
		if (d != null) {
			d.x = x;
			d.y = y;
		}
	}

	protected function widthOrZero(d:DisplayObject):int {
		return (d == null) ? 0 : d.width;
	}

	protected function heightOrZero(d:DisplayObject):int {
		return (d == null) ? 0 : d.height;
	}

	protected function xOrZero(d:DisplayObject):int {
		return (d == null) ? 0 : d.x;
	}

	protected function yOrZero(d:DisplayObject):int {
		return (d == null) ? 0 : d.y;
	}

	protected function layoutPieces(width:int, height:int):void {
		// determine location of corner tiles
		setOriginIfNotNull(mPieces[CORNER_NW], 0, 0);
		setOriginIfNotNull(mPieces[CORNER_NE], width - widthOrZero(mPieces[CORNER_NE]), 0);
		setOriginIfNotNull(mPieces[CORNER_SE], width - widthOrZero(mPieces[CORNER_SE]), height - heightOrZero(mPieces[CORNER_SE]));
		setOriginIfNotNull(mPieces[CORNER_SW], 0, height - heightOrZero(mPieces[CORNER_SW]));

		var sideX:int;
		var sideY:int;
		var sideWidth:int;
		var sideHeight:int;
        var sideImage:TiledImage;

		// top
		if (mPieces[SIDE_N] != null) {
			sideX = xOrZero(mPieces[CORNER_NW]) + widthOrZero(mPieces[CORNER_NW]);
			sideY = yOrZero(mPieces[CORNER_NW]);
			sideWidth = Math.max(width - (widthOrZero(mPieces[CORNER_NW]) + widthOrZero(mPieces[CORNER_NE])), 0);
			if(mExpandBorderThickness) {
                sideHeight = Math.max(heightOrZero(mPieces[CORNER_NW]), heightOrZero(mPieces[CORNER_NE]));
            }else {
                sideHeight = mCorners[SIDE_N].height;
            }

            sideImage = TiledImage(mPieces[SIDE_N]);
            sideImage.x = sideX;
            sideImage.y = sideY;
            sideImage.setSize(sideWidth, sideHeight);
//            ImageTilerSprite(mPieces[SIDE_N]).setBounds(sideX, sideY, sideWidth,sideHeight);
		}

		// bottom
		if (mPieces[SIDE_S] != null) {
			sideX = xOrZero(mPieces[CORNER_SW]) + widthOrZero(mPieces[CORNER_SW]);
            if(mExpandBorderThickness) {
                sideY = yOrZero(mPieces[CORNER_SW]);
            }else {
                sideY = height - mCorners[SIDE_S].height;
            }

			sideWidth = Math.max(width - (widthOrZero(mPieces[CORNER_SW]) + widthOrZero(mPieces[CORNER_SE])), 0);
            if(mExpandBorderThickness) {
                sideHeight = Math.max(heightOrZero(mPieces[CORNER_SW]), heightOrZero(mPieces[CORNER_SE]));
            }else {
                sideHeight = mCorners[SIDE_S].height;
            }

            sideImage = TiledImage(mPieces[SIDE_S]);
            sideImage.x = sideX;
            sideImage.y = sideY;
            sideImage.setSize(sideWidth, sideHeight);
//            ImageTilerSprite(mPieces[SIDE_S]).setBounds(sideX, sideY, sideWidth, sideHeight);
		}

		// left
		if (mPieces[SIDE_W] != null) {
			sideX = xOrZero(mPieces[CORNER_NW]);
			sideY = yOrZero(mPieces[CORNER_NW]) + heightOrZero(mPieces[CORNER_NW]);
            if(mExpandBorderThickness) {
                sideWidth = Math.max(widthOrZero(mPieces[CORNER_NW]), widthOrZero(mPieces[CORNER_SW]));
            }else {
                sideWidth = mCorners[SIDE_W].width;
            }

			sideHeight = Math.max(height - (heightOrZero(mPieces[CORNER_SW]) + heightOrZero(mPieces[CORNER_NW])), 0);

            sideImage = TiledImage(mPieces[SIDE_W]);
            sideImage.x = sideX;
            sideImage.y = sideY;
            sideImage.setSize(sideWidth, sideHeight);
//            ImageTilerSprite(mPieces[SIDE_W]).setBounds(sideX, sideY,sideWidth, sideHeight);
		}

		// right
		if (mPieces[SIDE_E] != null) {
            if(mExpandBorderThickness) {
                sideX = xOrZero(mPieces[CORNER_NE]);
            }else {
                sideX = width - mCorners[SIDE_E].width;
            }

			sideY = yOrZero(mPieces[CORNER_NE]) + heightOrZero(mPieces[CORNER_NE]);
            if(mExpandBorderThickness) {
                sideWidth = Math.max(widthOrZero(mPieces[CORNER_NE]), widthOrZero(mPieces[CORNER_SE]));
            }else {
                sideWidth =  mCorners[SIDE_E].width;
            }
			sideHeight = Math.max(height - (heightOrZero(mPieces[CORNER_SE]) + heightOrZero(mPieces[CORNER_NE])), 0);

            sideImage = TiledImage(mPieces[SIDE_E]);
            sideImage.x = sideX;
            sideImage.y = sideY;
            sideImage.setSize(sideWidth, sideHeight);
//            ImageTilerSprite(mPieces[SIDE_E]).setBounds(sideX, sideY, sideWidth, sideHeight);
		}
	}

	override public function setSize(width:int, height:int):void {
		var oldWidth:int = getWidth();
		var oldHeight:int = getHeight();
		super.setSize(width, height);

		if ((width != oldWidth) || (height != oldHeight)) {
			layoutPieces(width, height);
		}
	}

	public override function setAlpha(alpha:int):void {
		super.setAlpha(alpha);
		for (var index:int = 0; index < mPieces.length; index++) {
			var piece:DisplayObject = mPieces[index];
			piece.alpha = Number(alpha) / 255.0;
		}
	}

	public override function dispose():void {
		var child:DisplayObject;
		for each (child in mPieces) {
			child.dispose();
		}
		super.dispose();
	}


	public function set setSizeByScaling(useScaling:Boolean):void {
		mResizeWithScaling = useScaling;
		for (var j:int = SIDE_N; j <= SIDE_E; j++) {
			if (mPieces[j]) {
                //TOOD
//				(mPieces[j] as ImageTilerSprite).setSizeByScaling = useScaling;
			}
		}
	}

    public function set expandBorderThickness(b:Boolean):void {
        this.mExpandBorderThickness = b;
    }

}
}