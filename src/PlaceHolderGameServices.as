/**
 * Created with IntelliJ IDEA.
 * User: DarrenFu
 * Date: 11/29/13
 * Time: 12:24 PM
 * To change this template use File | Settings | File Templates.
 */
package {
import com.pogo.fgf.external.IStarlingTableGameServices;
import com.pogo.fgf.game.ClientApplet;
import com.pogo.table.services.StarlingTableGameServices;
import com.pogo.util.Properties;

import starling.textures.Texture;

public class PlaceHolderGameServices extends StarlingTableGameServices implements IStarlingTableGameServices {

    private var textureCache:Object = new Object();

    public function PlaceHolderGameServices(applet:ClientApplet, p:Properties) {
        super(applet, p);
    }

    override public function getRaster(key:String):Texture {
        return textureCache[key];
    }

    override public function hasRaster(key:String):Boolean {
        return textureCache[key] ? true : false;
    }

    override public function cacheTexture(key:String, t:Texture):void {
        if (key) textureCache[key] = t;
    }

}
}
