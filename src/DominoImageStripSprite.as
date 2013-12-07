/**
 * Created with IntelliJ IDEA.
 * User: darrenfu
 * Date: 8/22/13
 * Time: 4:44 PM
 * To change this template use File | Settings | File Templates.
 */
package {
import com.pogo.ui.anim.IInterpolatable;
import com.pogo.ui.starling.StarlingImageStripSprite;
import com.pogo.ui.starling.StarlingPropsUtils;
import com.pogo.ui.starling.assets.AssetTooLargeError;
import com.pogo.util.HashTable;
import com.pogo.util.Log;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;

import starling.display.MovieClip;
import starling.textures.Texture;

/**
	 * This class creates a starling movieclip whose frames come from a single texture with multiple image frame.
	 * The purpose of this class is to provide similar functionality to com/pogo/game/uitools/sprite/ImageStripSprite.java
	 * Like ImageStripSprite this class uses a sprite sheet that defines a movie/animation. The setters/getters for
	 * row and column have been preserved and strips and gaps are still there but the Starling MovieClip class is
	 * utilized for moving from one image to another. Notice that the setter/getter for image has been renamed to index
	 * to point to the frame of the movie clip. So instead of calculating the x/y of where the image should be
	 * the current rows/columns are used to calculate which frame should be set. Also the class attempts to use
	 * cached textures as much as possible.
	 *
	 * NOTE: In some cases there may be an instance of where you find a strip (sprite sheet) contained within a strip.
	 * If this is the case you will need to use the StarlingPropsUtils::blitBitmap method to create a sub strip first and
	 * then pass that in as the source for the constructor. Please also note that you may have to configure the rect and
	 * strip properties first in order for it to completely work
	 *
	 * @author ekramer@ea.com
	 *
	 */
public class DominoImageStripSprite extends StarlingImageStripSprite implements IInterpolatable {

    private var _stripRect:Rectangle;
    private var _isVertical:Boolean = false;
    private var _index:int;
    private var _row:int = 0;
    private var _rows:int = 0;
    private var _column:int = 0;
    private var _columns:int = 0;
    private var _hGap:int = 0;
    private var _vGap:int = 0;
    private var _sourceSize:Rectangle;
    private var _transientBitmap:BitmapData;
    private var _currentAnimation:Vector.<Texture>;
    private var _cacheKey:String;

    private var mc:MovieClip;
    private var needDisposeTextures:Boolean = false;
    private var generateFromRaster:Boolean = false;
    private var _textureCache:HashTable = new HashTable();
    private var _fps:Number = 12;

    public function DominoImageStripSprite(textureCache:HashTable, cacheKey:String = null, source:BitmapData = null, stripRect:Rectangle = null) {
        super(cacheKey, source, stripRect);

        _transientBitmap = source;
        _stripRect = stripRect;
        _cacheKey = cacheKey;
        _textureCache = textureCache;

        // this is a bit complicated because we can create strip sprites from bitmapdata or an existing texture
        // such as from a TextureAtalas (for performance reasons)

        if (!stripRect && source) {
            _stripRect = new Rectangle(0, 0, source.width, source.height);
        } else if (!stripRect) {
            _stripRect = new Rectangle(0, 0, 0, 0);
        }

        if (source) {
            if (!cacheKey) {
                throw new Error("Must supply cacheKey if source bitmap is given");
            }
            _sourceSize = new Rectangle(0, 0, source.width, source.height);
        } else {
            if (cacheKey) {
                //TODO
                var t:Texture = _textureCache.get(cacheKey) as Texture;

//                var services:StarlingTableGameServices = StarlingTableGameServices.singleton();
//                if (services.hasRaster(cacheKey)) {
                if (t) {
//                    var t:Texture = services.getRaster(cacheKey);
                    _sourceSize = new Rectangle(0, 0, t.width, t.height);
                    if (!stripRect) {
                        _stripRect = new Rectangle(0, 0, t.width, t.height);
                    }
                }
            }
        }
    }

    override protected function disposeTexture():void
    {
        if(needDisposeTextures && _currentAnimation != null)
        {
            needDisposeTextures = false;
            for(var i:int = 0; i < _currentAnimation.length; i++)
            {
                _currentAnimation[i].dispose();
            }
            _currentAnimation = null;
        }
    }

    /**
     * A rectangle that define the bounds of a single frame of strip.
     */
    override public function get stripRect():Rectangle {
        return _stripRect;
    }

    override public function set stripRect(value:Rectangle):void {
        destroy();
        _stripRect = value;
    }

    override public function set fps(val:Number):void {
        _fps = val;
    }

    override public function get fps():Number {
        return _fps;
    }
    /**
     * The index of the current frame being shown.
     */
    override public function get index():int {
        return _index;
    }

    override public function set index(value:int):void {
        _index = value;
        var frame:int;
        if (_isVertical)
            frame = _index + (_column * rows);
        else
            frame = _index + (_row * columns);

        if (!mc) {
            mc = new MovieClip(currentAnimation, fps);
            mc.stop();
            if (mRGBA >= 0) {
                mc.color = mRGBA >> 8;
                mc.alpha = (mRGBA & 0xFF) / 0xFF;
            }
            addChild(mc);
        }

        if (frame >= 0)
        {
            mc.visible = true;
            mc.currentFrame = frame;
        }
        else
        {
            mc.visible = false;
        }
    }

    /**
     * The RGBA color filter to apply to the object
     * @default -1 (no color filter applied)
     */
    private var mRGBA:Number = -1;

    override public function set color(c:Number):void {
        destroy();
        mRGBA = c;
        index = index;
    }

    override public function get color():Number {
        return mRGBA;
    }

    /**
     * Set to true if the frames of the strip are arranged vertically.
     * @default false
     */
    override public function get isVertical():Boolean {
        return _isVertical;
    }

    override public function set isVertical(value:Boolean):void {
        destroy();
        _isVertical = value;
    }

    /**
     * Amount of vertical gap between frames.
     * @default 0
     */
    override public function get vGap():int {
        return _vGap;
    }

    override public function set vGap(value:int):void {
        destroy();
        _vGap = value;
    }

    /**
     * The amount of horizontal gap between frames.
     * @default 0
     */
    override public function get hGap():int {
        return _hGap;
    }

    override public function set hGap(value:int):void {
        destroy();
        _hGap = value;
    }

    /**
     * If the texture contains multiple columns, you can specify which column to use.
     * @default 0
     */
    override public function get column():int {
        return _column;
    }

    override public function set column(value:int):void {
        destroy();
        _column = value;
    }

    /**
     * If the texture contains multiple rows, you can specify which row to use.
     * @default 0
     */
    override public function get row():int {
        return _row;
    }

    private function get columns():int {
        if (!_columns)
            _columns = _sourceSize.width / (_stripRect.width + vGap);

        return _columns;
    }

    override public function set row(value:int):void {
        destroy();
        _row = value;
    }

    override public function get rows():int {
        if (!_rows)
            _rows = _sourceSize.height / (_stripRect.height + hGap);

        return _rows;
    }

    /**
     * Gets the number of images frames contained in the baseTexture. This value is computed by dividing the width or height of the texture
     * by the stripRect width or height, respectively.
     * @return Calculated value of frames contained by the baseTexture
     *
     * @see baseTexture
     */
    override public function getNumImages():int {
        if (_currentAnimation) {
            return _currentAnimation.length;
        }
        else {
            return columns * rows;
        }
    }

    /**
     * @inheritDoc
     */
    override public function interpolate(p:Number):void {
        index = Math.ceil(p * getNumImages()) - 1;
    }

    /**
     * Cleans up object when it's properties have changed or it is to be discarded.
     */
    override public function destroy():void {
        if (mc) {
            removeChild(mc);
            mc.dispose()
            mc = null;
        }
        disposeTexture();
    }

    override public function dispose():void {
        super.dispose();
        destroy();
    }

    /**
     * Generates a vector of textures from the base texture or bitmap which can be used to populate a Starling MovieClip.
     * @return A vector of textures taken from the base texture or bitmap
     * @see baseTexture
     */
    override protected function generateTextures(withKey:String, fromBitmap:BitmapData = null):Vector.<Texture> {

        if (fromBitmap) {
            _transientBitmap = fromBitmap;
            _sourceSize = new Rectangle(0, 0, fromBitmap.width, fromBitmap.height);
            _cacheKey = withKey;
        }

        var textures:Vector.<Texture> = findCachedFrames(withKey);

        if (!textures) {

            if (!_stripRect) throw new Error("StripRect is undefined, cannot generate strip images");

            textures = new Vector.<Texture>();

            var index:int = 0;
            var column:int;
            var row:int;
            var x:int = 0;
            var y:int = 0;
            var totalFrames:int = _rows * _columns;

            var bRect:Rectangle;
            var bPoint:Point = new Point(0, 0);
//            var services:StarlingTableGameServices = StarlingTableGameServices.singleton();
            var raster:Texture = _textureCache.get(withKey) as Texture;
            try {
                if (raster) {
//                    raster = services.getRaster(withKey);
                    _sourceSize = new Rectangle(0, 0, raster.width, raster.height);
                }
            } catch (error:AssetTooLargeError) {
                // ignore and use bitmap method
            }

            for (var frame:int = 0; frame < totalFrames; frame++) {

                if (_isVertical) {
                    x = _stripRect.x + (column * (_stripRect.width + vGap));
                    y = _stripRect.y + (index * (_stripRect.height + hGap));
                }
                else {
                    x = _stripRect.x + (index * (_stripRect.width + vGap));
                    y = _stripRect.y + (row * (_stripRect.height + hGap));
                }

                // try to use an existing texture, if possible, for performance reasons
                bRect = new Rectangle(x, y, _stripRect.width, _stripRect.height);
                if (raster) {
                    this.generateFromRaster = true;
                    textures.push(Texture.fromTexture(_textureCache.get(withKey) as Texture, bRect));
                } else {
                    if (!_transientBitmap) throw new Error("transientBitmap is undefined and no raster was found, cannot generate strip images");
                    var frameBitmap:BitmapData = new BitmapData(_stripRect.width, _stripRect.height);
                    StarlingPropsUtils.blitBitmap(_transientBitmap, frameBitmap, 0, 0, x, y, bRect.width, bRect.height);
                    var frameTexture:Texture = Texture.fromBitmapData(frameBitmap);
                    if(CONFIG::Debug)
                        Log.info("StarlingImageStripSprite: caching texture: " + toCacheKey(withKey, frame));
//                    services.cacheTexture(toCacheKey(withKey, frame), frameTexture);
                    _textureCache.put(toCacheKey(withKey, frame), frameTexture);
                    textures.push(frameTexture);
                    frameBitmap.dispose();
                }
                index++;

                if (_isVertical && index == _rows) {
                    column++;
                    //we've reached the end of the column, if we have more columns let's shift right
                    if (x + _stripRect.width + vGap < _sourceSize.width) {
                        index = 0;
                    }
                    else {
                        break;
                    }
                }
                else if (index == _columns) {
                    row++;
                    //we've reached the end of the row, if we have more rows let's shift down
                    if (y + _stripRect.height + hGap < _sourceSize.height) {
                        index = 0;
                    }
                    else {
                        break;
                    }
                }
            }

            if (frameBitmap) {
                frameBitmap.dispose();
            }
            _transientBitmap = null;
            if (textures.length < 1) {
                throw new Error("No frames found from texture: " + _transientBitmap + " for key " + withKey);
            }
        }

        return textures;
    }

    private function toCacheKey(prefix:String, index:int):String {
        return prefix + "-" + index;
    }

    private function findCachedFrames(key:String):Vector.<Texture> {
//        var services:StarlingTableGameServices = StarlingTableGameServices.singleton();
        var numFrames:int = getNumImages();
        var t:Texture = _textureCache.get(toCacheKey(key, 0)) as Texture;
//        if (services.hasRaster(toCacheKey(key, 0))) {
        if (t) {
            var textures:Vector.<Texture> = new Vector.<Texture>();
            for (var i:int = 0; i < numFrames; i++) {
//                var t:Texture = services.getRaster(toCacheKey(key, i));
                t = _textureCache.get(toCacheKey(key, i)) as Texture;
                if (!t) {
                    throw new Error("Unable to find cached texture: " + toCacheKey(key, i));
                }
                textures.push(t);
            }
//			Log.info("StarlingImageStripSprite: found " + textures.length + " cached textures for " + key);
            return textures;
        }
        return null;
    }

    override public function getSubRect():Rectangle {
        return _stripRect;
    }

    override public function setSubRect(rect:Rectangle):void {
        _stripRect = rect;
    }


    override public function get currentAnimation():Vector.<Texture> {
        if (!_currentAnimation) {
            generateFromRaster = false;
            _currentAnimation = generateTextures(_cacheKey);
            if(generateFromRaster)
            {
                this.needDisposeTextures = true;
            }
        }
        return _currentAnimation;
    }

    override public function set currentAnimation(value:Vector.<Texture>):void {
        destroy();
        _currentAnimation = value;
    }
}
}