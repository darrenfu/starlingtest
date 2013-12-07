package {
import com.pogo.ui.starling.gf1.image.*;
import com.pogo.fgf.external.IStarlingTableGameServices;
import com.pogo.ui.PropsUtils;
import com.pogo.util.HashTable;
import com.pogo.util.Properties;
import com.pogo.util.StringUtils;


import flash.display.BitmapData;
import flash.filters.ColorMatrixFilter;
import flash.geom.Point;
import flash.geom.Rectangle;

import starling.textures.Texture;
import starling.utils.Color;

/**
 * Builds images driven by
 * Currently used to generated Poker card textures for Spade2
 * User: terickson
 * Date: Sep 9, 2003
 * Time: 11:47:02 AM
 */
public class SpadesPropertiesImageBuilder {
	private var mImages:HashTable= new HashTable();
	private var mSubInfo:HashTable= new HashTable();
	private var mPoints:HashTable= new HashTable();
    private var mImageSource:HashTable = new HashTable();

    public static const FILTER_DARK:ColorMatrixFilter = new ColorMatrixFilter();

    private var mP:Properties;
    private var mKey:String;

	/**
	 * Constructor
	 * 
	 * How to configure the client props for the builder
	 * The main key will represented by the string key in the examples
	 * 
	 * The main key is a comma delimited list of images that can be used to build images from
	 * key.imgs=img1,img2,img3
	 * 
	 * Each image needs several sub keys
	 * The first one is the image key
	 * key.img1.img=
	 * 
	 * The second one is a command delimited list of rectangle key names
	 * key.img1.rects=rect1,rect2,rect3
	 * 
	 * Each rectangle needs its own rectangle key defining the rectangle
     * key.rect1.rect=
	 * 
	 * Optionally each rectangle can specify an additional offset when using indexed images like a flip book
	 * key.rect1.off=
	 * 
	 * In addition to the named images and rects you also need to specify a list of named points in the destination image
	 * key.pts=pt1,pt2,pt3
	 * 
	 * Each point needs its own point key defining the point
	 * key.pt1.pt=
	 * 
	 * See the client props for peaks for a very specific example of how this is used
	 * 
	 * @param p the properties instance to use for building the images
	 * @param key the property key that specifies the properties for this builder
	 */
	public function SpadesPropertiesImageBuilder(p:Properties, key:String, imageSource:HashTable) {
        var brightness:Number = .5;
        var matrix:Array = new Array();
        matrix=matrix.concat([brightness,0,0,0,0]);
        matrix=matrix.concat([0,brightness,0,0,0]);
        matrix=matrix.concat([0,0,brightness,0,0]);
        matrix=matrix.concat([0,0,0,1,0]);
        FILTER_DARK.matrix = matrix;

        mP = p;
        mKey = key;
        mImageSource = imageSource;

		var imageNames:Array= p.getArray( key+".imgs");
		for (var i:int= 0; i < imageNames.length; i++) {
			var imageName:String= StringUtils.trim(imageNames[i]);
			var image:BitmapData= mImageSource.get(key+"."+imageName) as BitmapData;
            // cache card foreground and background image strips
            trace("Cache image: ", imageName, image);
			mImages.put(imageName, image);
  			var subImageNames:Array = p.getArray( key+"."+imageName+".rects");
			for (var j:int= 0; j < subImageNames.length; j++) {
				var subImageName:String= StringUtils.trim(subImageNames[j]);
                var rect:Rectangle = PropsUtils.makeRectWithProperties(p, key + "." + subImageName);
				var offset:int= 0;
				var offsetKey:String= key+"."+subImageName+".off";
				if (p.containsKey(offsetKey)) {
					offset = p.getInt(offsetKey);
				}
				var subInfo:SubInfo= new SubInfo(imageName, rect, offset);
//                trace("Cache subInfo:", subImageName, imageName);
				mSubInfo.put(subImageName, subInfo);
			}
		}

		var pointNames:Array= p.getArray( key+".pts");
		for (var i:int= 0; i < pointNames.length; i++) {
			var pointName:String= StringUtils.trim(pointNames[i]);
			var point:Point= p.getPoint(key+"."+pointName+".pt");
			mPoints.put(pointName, point);
		}
	}


    /**
     * This utility method flushes and image that was previously created with buildImage
     * @param key the property key that specifies the image to flush
     */
    public function flushImage(key:String):void {

    }

	/**
	 * How to configure the client props for the builder buildImage
	 * The main key will represented by the string key in the examples
	 * You can define a default rectangle to use for all the images
	 * key.rect=
	 * 
	 * Each image you with to generate will need its own unique entry
	 * This defines how to build the image named by the key
	 * key.key1=
 	 * key.key2=
	 * 
	 * if the default rectangle is specified this is optional, manditory if there is not
	 * you can define a different rectangle for each image
	 * key.key1.rect=
	 * 
	 * The format of the image property is fairly simple
	 * It is a comma delimited list of images to paint
	 * paint1,paint2,paint3
	 * Each image to paint is specified by a : delimited list of values
	 * The first value is the named sub rectangle as specified above in the constructor comments
	 * The second value is the named sub point as specified above in the constructor comments
	 * Any additional values specify additional points to paint the same image in the order you with to paint them
	 * rect1:pt1
	 * rect1:pt1:pt2
	 * Optionally you can specify an index to the first param starting with 0, that tells is how many sub rect widths to move the point over, making this like a FlipBook
	 * rect1[index]:p1
	 * 
	 * See the client props for peaks for a very specific example of how this is used
	 * 
	 * Builds an image using the key specified
	 * Transparent images appear to blit slower, and they can not be used to get a graphics context
     *
	 * @param key the property key that specifies the output image
     * @param transparent whether the alpha channel is used
	 */
	public function buildImage(key:String, transparent:Boolean=false):BitmapData {
		var imageKey:String= mKey+"."+key;
 		var rect:Rectangle= p_makeRect(imageKey);
        var bgClr:uint = p_makeColor(imageKey);

		var destImage:BitmapData= new BitmapData(rect.width, rect.height, transparent, bgClr);

        var imageInfo:Array= mP.getArray( imageKey);
        for (var i:int= 0; i < imageInfo.length; i++) {
            var subImageList:Array= p_makeSubImageList(imageInfo[i]);
            if (subImageList.length < 2) {
                // skip if we do not at least have a source image name and one dest point name
                continue;
            }
            var subImageName:String= p_makeSubImageName(subImageList[0]);
            var subImageIndex:int= p_makeSubImageIndex(subImageList[0]);
            var subInfo:SubInfo= SubInfo(mSubInfo.get(subImageName));
            var image:BitmapData= mImages.get(subInfo.mImageName) as BitmapData;
            var subRect:Rectangle= new Rectangle();
            subRect.copyFrom(subInfo.mSubRect);
            // translate the rect by the index to form something like a flip book
            subRect.x += subRect.width*subImageIndex;
//            trace("Retrieve image: ", subImageName, subInfo.mImageName, subImageIndex,
//                    "rect:", subInfo.mSubRect.x, subInfo.mSubRect.y, subInfo.mSubRect.width, subInfo.mSubRect.height
//                    , ", ", subImageList[0]
//            );

            for (var j:int= 1; j < subImageList.length; j++) {
                var p:Point= Point(mPoints.get(subImageList[j]));

                // must merge alpha channel for transparent pixel copy!
                destImage.copyPixels(image, subRect, p, null, null, transparent);
            }
        }

        flushImage(key);
        mImageSource.put(key, destImage);

        return destImage;
    }

    public function darkenImage(image:BitmapData):BitmapData {
        var darkImage:BitmapData = image.clone();
        darkImage.applyFilter(darkImage, darkImage.rect, new Point(), FILTER_DARK);
        return darkImage;
    }

	/**
	 * Simple bitmask blending function, subclass and override this method to provide real alpha blending
	 * only supported by buildImage if transparent is true
	 * @param srcAlpha the alpha value of the srcPixel found by using ColorModel.getAlpha
	 * @param srcPixel the int value of the source pixel in packed format lower 8 bit red, etc.
	 * @param destPixel the int value of the destination pixel in packed format lower 8 bit red, etc.
	 * @return the blended pixel value
	 */
	protected function blend(srcAlpha:int, srcPixel:int, destPixel:int):int {
		if (srcAlpha == 0) {
			return destPixel;
		}
		else  {
			return srcPixel;
		}
	}

	private function p_makeRect(key:String):Rectangle {
		if (mP.containsKey(key+".rect")) {
			return PropsUtils.makeRectWithProperties(mP,  key +".rect");
		}
		else {
			return PropsUtils.makeRectWithProperties(mP,  mKey +".rect");
		}
	}

	private function p_makeColor(key:String):uint {
        var rgb:Array = [255, 255, 255];
		if (mP.containsKey(key+".clr")) {
			rgb = mP.getIntArray(key);
		}
		else if (mP.containsKey(mKey+".clr")) {
            rgb = mP.getIntArray(mKey);
		}
        return Color.rgb(rgb[0], rgb[1], rgb[2]);
	}

	private function p_makeSubImageList(imageInfo:String):Array {
        return StringUtils.trim(StringUtils.trim(imageInfo), '\t').split(':');
	}

	private function p_makeSubImageName(subImageInfo:String):String {
		var i:int= subImageInfo.indexOf("[");
		if (i < 0) {
			return subImageInfo;
		}
		return subImageInfo.substring(0, i);
	}

	private function p_makeSubImageIndex(subImageInfo:String):int {
		var i1:int= subImageInfo.indexOf("[");
		var i2:int= subImageInfo.indexOf("]");
		if (i1 < 0|| i2 < 0) {
			return 0;
		}
		return parseInt( subImageInfo.substring(i1+1, i2) );
	}
}


}

