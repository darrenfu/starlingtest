/**
 * Created with IntelliJ IDEA.
 * User: DarrenFu
 * Date: 11/27/13
 * Time: 1:47 PM
 * To change this template use File | Settings | File Templates.
 */
package {
import com.pogo.fgf.common.card.Card;
import com.pogo.fgf.gf1.card.DraggableCard;
import com.pogo.game.chess2.client.ChessBoardPanel;
import com.pogo.game.chess2.client.DraggableChessPiece;
import com.pogo.ui.FontConstants;
import com.pogo.ui.PropsCoreUtils;
import com.pogo.ui.anim.TickableTask;
import com.pogo.ui.starling.StarlingPropsUtils;
import com.pogo.ui.starling.StarlingSprite;
import com.pogo.ui.starling.StarlingTickableTaskUtils;
import com.pogo.ui.starling.anim.StarlingImageStripAnimator;
import com.pogo.util.HashTable;
import com.pogo.util.ITickable;
import com.pogo.util.Properties;
import com.pogo.util.StringUtils;
import com.pogo.util.TickManager;

import feathers.controls.text.TextFieldTextRenderer;
import feathers.core.ITextRenderer;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import starling.animation.IAnimatable;
import starling.core.Starling;
import starling.utils.Color;

public class ChessGamePanel_Local extends StarlingSprite implements IAnimatable {

    protected var mTransientTickMgr:TickManager;

    protected static var tf:TextFormat = new TextFormat(FontConstants.HELVETICA_STD, 12, Color.BLACK);

    public static const CAPTURE_ANIM_KEY:String = "chess2.capture";
    [Embed(source="../../pogo/games/chess2/texture_assets/images/chess2.images.all.include.capture.jpg")]
    private static const CAPTURE_ANIM_BMD:Class;

//    private var config:Spades2ClientConfig;
    public var imageCache:HashTable = new HashTable();
    private var textureCache:HashTable = new HashTable();
    private var props:Properties = new Properties();

    public function ChessGamePanel_Local() {
        super();

        var loader:URLLoader = new URLLoader(new URLRequest("def_chess2.properties"));
        loader.addEventListener(Event.COMPLETE, onComplete);

        mTransientTickMgr = new TickManager();
        Starling.juggler.add(this);
    }

    function onComplete(e:Event):void
    {
        var p:Properties = props;
        var data:String = e.target.data;
        var isWinFormat:Boolean = data.indexOf("\r") != -1;
        var pairs:Array = data.split(isWinFormat ? "\r\n" : "\n");
        var pattern:RegExp = /^[0-9a-zA-Z_-]+(\.[0-9a-zA-Z_-]+)*=/g;
        for each (var s:String in pairs) {
            if (s.indexOf("#") == 0) {
                continue;
            }
            var matched:Array = s.match(pattern);
            if (matched) {
                var idx:int = s.indexOf("=");
                if (idx > -1) {
                    var key:String = s.substr(0, idx);
                    key = StringUtils.trim(StringUtils.trim(key), '\t');
                    var val:String = s.substr(idx + 1, s.length);
                    val = StringUtils.trim(StringUtils.trim(val), '\t');
                    p.put(key, val);
                }
            }
        }

        var captureAnimBmd:BitmapData = (new CAPTURE_ANIM_BMD() as Bitmap).bitmapData;
        imageCache.put(CAPTURE_ANIM_KEY, captureAnimBmd);
//        ResourceMgrSingleton.instance().putImage("dialog.tablegame.btn.normal", (new SpadesCommonDialog.BUTTON_UP() as Bitmap).bitmapData);
//        ResourceMgrSingleton.instance().putImage("dialog.tablegame.btn.down", (new SpadesCommonDialog.BUTTON_DOWN() as Bitmap).bitmapData);
//        ResourceMgrSingleton.instance().putImage("dialog.tablegame.btn.disable", (new SpadesCommonDialog.BUTTON_DISABLE() as Bitmap).bitmapData);
//        ResourceMgrSingleton.instance().putImage("dialog.tablegame.background", (new SpadesCommonDialog.BUTTON_BG() as Bitmap).bitmapData);

//        Spades2ClientConfig.init(p);
//        config = Spades2ClientConfig.get();
        FontLoader.init();

//        playFirstCaptureAnim();
//        var listContainer:ChessMultiListTest = new ChessMultiListTest();
        var listContainer:ChessMultiListDemo = new ChessMultiListDemo();
        addChild(listContainer);
    }

    public function playFirstCaptureAnim():void {
        // play capture animation
        var captureAnimBmd:BitmapData = imageCache.get(CAPTURE_ANIM_KEY) as BitmapData;
        var captureAnimation:DominoImageStripSprite= StarlingPropsUtils.makeImageStrip(props, captureAnimBmd, CAPTURE_ANIM_KEY) as DominoImageStripSprite;
        add( captureAnimation );

        var pieceSize:int = DraggableChessPiece.SQUARE_SIZE_LARGE;
        var animSubRect:Rectangle = new Rectangle(0,0,pieceSize,pieceSize);
//		captureAnimation = new Picture(gCaptureAnimationImage/*, DraggableChessPiece.SQUARE_SIZE_LARGE, 0*/);
//        captureAnimation = new StarlingImageStripSprite("chess2.capture");
        captureAnimation.setSubRect(animSubRect);

        var destloc:Point= new Point(50, 50);//capturedPiece.getLocation();
        captureAnimation.setBounds(destloc.x, destloc.y,
                DraggableChessPiece.SQUARE_SIZE_LARGE,
                DraggableChessPiece.SQUARE_SIZE_LARGE);

        var dark:Boolean= (ChessBoardPanel.MAX_ROW - int(destloc.y/DraggableChessPiece.SQUARE_SIZE_LARGE) +
                int(destloc.x/DraggableChessPiece.SQUARE_SIZE_LARGE)) % 2== 0;
        var seq:Vector.<int> = PropsCoreUtils.makeIntArray(dark ? "06789A" : "012345", "");
        playAnim(captureAnimation, seq, 25);
    }

    private function playAnim(animatedStrip:DominoImageStripSprite, seq:Vector.<int>, fps:int,
                              onComplete:Function=null, onCompleteArgs:Array=null):void {
        animatedStrip.fps = 12;
        var row:int = 0;
        var loop:int = -1;

        var flipBook:StarlingImageStripAnimator = new StarlingImageStripAnimator(
                animatedStrip, row, 0, 0, seq, loop, false);

        var wholeAnimTask:ITickable = StarlingTickableTaskUtils.appendTickable(
                flipBook, new TickableTask(function():void {
//                    animatedStrip.removeFromParent();
                }));
        mTransientTickMgr.addTickable(wholeAnimTask);



//        var holderBounds:Rectangle= config.mHolderRect[0];
//
//        // build pict
//        var suit:int= new Card(card).getSuit();
//        var subRect:Rectangle= new Rectangle();
//        subRect.copyFrom(config.mTrumpAnimSubRect);
//        subRect.y = subRect.y + subRect.height * suit;
////        var trumPict:Texture = Texture.fromBitmapData(imageCache.get(TRUMP_KEY) as BitmapData);
////        var trumpPict:ImageSprite= new ImageSprite( Texture.fromBitmapData(imageCache.get(TRUMP_KEY) as BitmapData),  subRect);
////        trumpPict.setSubRect( new Rectangle(holderBounds.x + config.mTrumpAnimRect.x,
////                holderBounds.y + config.mTrumpAnimRect.y,
////                config.mTrumpAnimRect.width, config.mTrumpAnimRect.height ));
//
//        // add pict
////        add( trumpPict );
//
//        // run anim
//        var trumpBmd:BitmapData = imageCache.get(TRUMP_KEY) as BitmapData;
//        var trumpImg:ImageSprite = new ImageSprite(Texture.fromBitmapData(trumpBmd), new Rectangle(/*holderBounds.x + config.mTrumpAnimRect.x*/0,
//                /*holderBounds.y + config.mTrumpAnimRect.y*/0,
//                config.mTrumpAnimRect.width, config.mTrumpAnimRect.height ));
////        add(trumpImg);
//
//        //TODO: need update the type in makeImageStrip
//        var trumpStrip:DominoImageStripSprite= StarlingPropsUtils.makeImageStrip(props,
//                trumpBmd, TRUMP_KEY) as DominoImageStripSprite;
//        trumpStrip.setOrigin(holderBounds.x + config.mTrumpAnimRect.x, holderBounds.y + config.mTrumpAnimRect.y);
//        trumpStrip.setSubRect(new Rectangle(0,0,
////                holderBounds.x + config.mTrumpAnimRect.x,
////                holderBounds.y + config.mTrumpAnimRect.y,
//                config.mTrumpAnimRect.width, config.mTrumpAnimRect.height ));
//        trumpStrip.fps = 12;
//        add(trumpStrip);
//
//        var loops:int = 5;
//        var row:int = 0;
//        var seq:Vector.<int> = PropsCoreUtils.makeIntArrayWithProperties(props, "spades.trumpanim.seq", "");
//        var unlink:Boolean = true;
//        var trumpAnim:StarlingImageStripAnimator = new StarlingImageStripAnimator(trumpStrip, row, 0, 0, seq, loops, unlink);
//        mTransientTickMgr.addTickable(trumpAnim);
//        var trumpAnim:FlipBook= new FlipBook( trumpPict, config.mTrumpAnimSeq, FLIPBOOK_RATE, subRect);
//        trumpAnim.run();

        // remove pict
//        remove( trumpPict );
    }

    private static function numberFormat(num:*):String {
        if (num is Number || num is int) {
            return num.toString();
        }
        return null;
    }

    public function createSystemTextRender():ITextRenderer {
        var textRenderer:TextFieldTextRenderer = new TextFieldTextRenderer();
        tf.align = TextFormatAlign.CENTER;
        textRenderer.textFormat = tf;
//      textRenderer.textFormat.letterSpacing = 1;
//      textRenderer.smoothing = TextureSmoothing.BILINEAR;
        return textRenderer;
    }

    public function createDraggableCard(card:Card):DraggableCard {
        return (new DraggableCard({"card":card}));
    }

    public function addTickable(t:ITickable):void {
        //checkThread();
        if (mTransientTickMgr && t) {
            mTransientTickMgr.addTickable(t);
        }
    }

    public function advanceTime(time:Number):void {
        if (mTransientTickMgr != null) {
            mTransientTickMgr.doTick();
        }
    }

}
}
