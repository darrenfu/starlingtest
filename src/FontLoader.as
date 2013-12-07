/**
 * Created with IntelliJ IDEA.
 * User: pc
 * Date: 13-12-7
 * Time: 下午4:55
 * To change this template use File | Settings | File Templates.
 */
package {
import starling.text.BitmapFont;
import starling.text.TextField;
import starling.textures.Texture;

public class FontLoader {

    public static const dialogKey:String = "spades.dialog";
    [Embed(source="../../webapps/pogo/htdocs/applet/spades2/images/en_US/include/font-dialogue_star.xml", mimeType="application/octet-stream")]
    private static const dialogFontXml:Class;
    [Embed(source="../../pogo/games/spades2/texture_assets/lossless/spades2.images.en_US.include.fontdialoguestar.png")]
    private static const DIALOG_BMP:Class;

    public function FontLoader() {
    }
    public static function init():void {
        var xml:XML = new XML(new dialogFontXml());
        TextField.registerBitmapFont(new BitmapFont(Texture.fromBitmap(new DIALOG_BMP()), xml), dialogKey);
    }
}
}
