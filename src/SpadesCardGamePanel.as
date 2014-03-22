/**
 * Created with IntelliJ IDEA.
 * User: DarrenFu
 * Date: 11/27/13
 * Time: 1:47 PM
 * To change this template use File | Settings | File Templates.
 */
package {
import com.pogo.fgf.common.card.Card;
import com.pogo.fgf.gf1.card.CardHolder;
import com.pogo.fgf.gf1.card.DraggableCard;
import com.pogo.game.spades2.client.Spades2ClientConfig;
import com.pogo.ui.FontConstants;
import com.pogo.ui.Layout;
import com.pogo.ui.PropsCoreUtils;
import com.pogo.ui.PropsUtils;
import com.pogo.ui.starling.ImageSprite;
import com.pogo.ui.starling.StarlingPropsUtils;
import com.pogo.ui.starling.StarlingSprite;
import com.pogo.ui.starling.anim.StarlingImageStripAnimator;
import com.pogo.ui.starling.gf1.DialogGF1;
import com.pogo.ui.starling.gf1.Panel;
import com.pogo.util.HashTable;
import com.pogo.util.ITickable;
import com.pogo.util.Properties;
import com.pogo.util.ResourceMgrSingleton;
import com.pogo.util.StringUtils;
import com.pogo.util.TickManager;

import feathers.controls.Callout;
import feathers.controls.Label;
import feathers.controls.text.TextFieldTextRenderer;
import feathers.core.ITextRenderer;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;
import flash.geom.Rectangle;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import starling.animation.IAnimatable;
import starling.core.Starling;
import starling.display.Image;
import starling.textures.Texture;
import starling.utils.Color;

public class SpadesCardGamePanel extends StarlingSprite implements IAnimatable {

    protected var mTransientTickMgr:TickManager;

    public static const HOLDER_LOCATIONS:Vector.<String>= new <String>[
        Layout.SOUTH,
        Layout.WEST,
        Layout.NORTH,
        Layout.EAST];

    protected static const NO_CARD:int= -1;

    protected static var tf:TextFormat = new TextFormat(FontConstants.HELVETICA_STD, 12, Color.BLACK);

    private static const PCS_KEY:String = "spades.card.pcs";
    [Embed(source="images/card-pieces.png")]
    private static const PCS_BMP:Class;

    private static const BGD_KEY:String = "spades.card.bgd";
    [Embed(source="images/cards.png")]
    private static const BGD_BMP:Class;

    private static const TRUMP_KEY:String = "spades.trumpanim";
    [Embed(source="../../pogo/games/spades2/texture_assets/lossless/spades2.images.all.include.spades.gif")]
    private static const TRUMP_BMP:Class;

    private static const mStandardControlsStripKey:String = "spades.buttons";
    [Embed(source="../../pogo/games/spades2/texture_assets/images/spades2.images.all.include.stdcontrols.gif")]
    private static const STANDARDCONTROLSSTRIP_BMP:Class;
    public static var mStandardControlsStrip:Texture;

    private var config:Spades2ClientConfig;
    private var imageCache:HashTable = new HashTable();
    private var textureCache:HashTable = new HashTable();
    private var props:Properties = new Properties();
    private var mBidDialog:DialogGF1;
//    private var services:StarlingTableGameServices;

    public function SpadesCardGamePanel() {
        super();

        var loader:URLLoader = new URLLoader(new URLRequest("def_spades2.properties"));
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

        imageCache.put(PCS_KEY, (new PCS_BMP() as Bitmap).bitmapData);
        imageCache.put(BGD_KEY, (new BGD_BMP() as Bitmap).bitmapData);
        imageCache.put(TRUMP_KEY, (new TRUMP_BMP() as Bitmap).bitmapData);
        ResourceMgrSingleton.instance().putImage("dialog.tablegame.btn.normal", (new SpadesCommonDialog.BUTTON_UP() as Bitmap).bitmapData);
        ResourceMgrSingleton.instance().putImage("dialog.tablegame.btn.down", (new SpadesCommonDialog.BUTTON_DOWN() as Bitmap).bitmapData);
        ResourceMgrSingleton.instance().putImage("dialog.tablegame.btn.disable", (new SpadesCommonDialog.BUTTON_DISABLE() as Bitmap).bitmapData);
        ResourceMgrSingleton.instance().putImage("dialog.tablegame.background", (new SpadesCommonDialog.BUTTON_BG() as Bitmap).bitmapData);

//        var applet:ClientApplet = new PlaceHolderApplet();
//        services = new PlaceHolderGameServices(new PlaceHolderApplet(), props);
//        services.cacheTexture(TRUMP_KEY, Texture.fromBitmapData(imageCache.get(TRUMP_KEY) as BitmapData));

        Spades2ClientConfig.init(p);
        config = Spades2ClientConfig.get();
        FontLoader.init();
        mStandardControlsStrip = Texture.fromBitmap(new STANDARDCONTROLSSTRIP_BMP() as Bitmap);

        //TODO
        initCardImages(p, this, imageCache);
//        showLastTrick();

        var dialog:SpadesCommonDialog = new SpadesCommonDialog();
        add(dialog);
        dialog.x = 200;
        dialog.y = 200;
//        dialog.madeBid("eaclub01", true, true, 1, 7);
//        dialog.passed("eaclub01", new <int>[35, 27]);
//        dialog.handleDoCut("eaclub01", new <int>[35, 27, 34, 29]);
        dialog.askJoin("eaclub01", 0, 1500);
//        playTrumpAnim(13);
    }

    private function initCardImages(props:Properties, arena:StarlingSprite, imageCache:HashTable):void {
        // build the cards: generate all enabled and disabled cards and cache them into texture pool
        var cardPrefix:String = "spades.card";
        var cardImgBuilder:SpadesPropertiesImageBuilder = new SpadesPropertiesImageBuilder(props, cardPrefix, imageCache);
        var cardNames:Array = props.getArray(cardPrefix + ".cards");
        var cardSize:int = cardNames.length;
        var cardImages:Vector.<Texture> = new Vector.<Texture>(cardSize);
        var disabledCardImages:Vector.<Texture> = new Vector.<Texture>(cardSize);
        var cardBmd:BitmapData = null;
        var darkBmd:BitmapData = null;
        for (var i:int=0; i< cardSize; i++) {
            cardBmd = cardImgBuilder.buildImage(cardNames[i], true);
            if (cardBmd) {
                cardImages[i] = Texture.fromBitmapData(cardBmd);
                darkBmd = cardImgBuilder.darkenImage(cardBmd);
                cardBmd.dispose();
                cardBmd = null;
                disabledCardImages[i] = Texture.fromBitmapData(darkBmd);
                darkBmd.dispose();
                darkBmd = null;
            }
        }

        // init draggable card
        var cardRect:Rectangle = PropsUtils.makeRectWithProperties(props, cardPrefix);
        DraggableCard.setCardImagesWithTextures(
                cardImages,
                disabledCardImages,
                null,/*gameServices.getRaster("back"),*/ arena,
                cardRect.width, cardRect.height,
                props.getInt(cardPrefix + ".spread"));
    }



    private static function numberFormat(num:*):String {
        if (num is Number || num is int) {
            return num.toString();
        }
        return null;
    }

    public function playTrumpAnim(card:int):void {
        var holderBounds:Rectangle= config.mHolderRect[0];

        // build pict
        var suit:int= new Card(card).getSuit();
        var subRect:Rectangle= new Rectangle();
        subRect.copyFrom(config.mTrumpAnimSubRect);
        subRect.y = subRect.y + subRect.height * suit;
//        var trumPict:Texture = Texture.fromBitmapData(imageCache.get(TRUMP_KEY) as BitmapData);
//        var trumpPict:ImageSprite= new ImageSprite( Texture.fromBitmapData(imageCache.get(TRUMP_KEY) as BitmapData),  subRect);
//        trumpPict.setSubRect( new Rectangle(holderBounds.x + config.mTrumpAnimRect.x,
//                holderBounds.y + config.mTrumpAnimRect.y,
//                config.mTrumpAnimRect.width, config.mTrumpAnimRect.height ));

        // add pict
//        add( trumpPict );

        // run anim
        var trumpBmd:BitmapData = imageCache.get(TRUMP_KEY) as BitmapData;
        var trumpImg:ImageSprite = new ImageSprite(Texture.fromBitmapData(trumpBmd), new Rectangle(/*holderBounds.x + config.mTrumpAnimRect.x*/0,
                /*holderBounds.y + config.mTrumpAnimRect.y*/0,
                config.mTrumpAnimRect.width, config.mTrumpAnimRect.height ));
//        add(trumpImg);

        //TODO: need update the type in makeImageStrip
        var trumpStrip:DominoImageStripSprite= StarlingPropsUtils.makeImageStrip(props,
                trumpBmd, TRUMP_KEY) as DominoImageStripSprite;
        trumpStrip.setOrigin(holderBounds.x + config.mTrumpAnimRect.x, holderBounds.y + config.mTrumpAnimRect.y);
        trumpStrip.setSubRect(new Rectangle(0,0,
//                holderBounds.x + config.mTrumpAnimRect.x,
//                holderBounds.y + config.mTrumpAnimRect.y,
                config.mTrumpAnimRect.width, config.mTrumpAnimRect.height ));
        trumpStrip.fps = 12;
        add(trumpStrip);

        var loops:int = 5;
        var row:int = 0;
        var seq:Vector.<int> = PropsCoreUtils.makeIntArrayWithProperties(props, "spades.trumpanim.seq", "");
        var unlink:Boolean = true;
        var trumpAnim:StarlingImageStripAnimator = new StarlingImageStripAnimator(trumpStrip, row, 0, 0, seq, loops, unlink);
        mTransientTickMgr.addTickable(trumpAnim);
//        var trumpAnim:FlipBook= new FlipBook( trumpPict, config.mTrumpAnimSeq, FLIPBOOK_RATE, subRect);
//        trumpAnim.run();

        // remove pict
//        remove( trumpPict );
    }

    public function createTrickPanel(title:String, cards:Vector.<int>):Panel {
        var p:Panel= new Panel(/*new BorderLayout(5, 5)*/);

        var dialogRect:Rectangle = new Rectangle(0,0,210,275);
        p.setBoundsFromRectangle(dialogRect);

        var lbl:Label = new Label();
        lbl.text = title;
        lbl.textRendererFactory = createSystemTextRender;
        p.addWithLayout(Layout.NORTH, lbl);

        var cardPanel:Panel= new Panel(/*new BorderLayout(10, 5)*/);
        var middlePanel:Panel= new Panel(/*new BorderLayout(10, 5)*/);
        cardPanel.add(middlePanel);
        cardPanel.setBoundsFromRectangle(dialogRect);
        middlePanel.setBoundsFromRectangle(dialogRect);

        for (var i:int= 0; (i < cards.length); i++) {
            var b:int= cards[i];
            var cp:Panel= (i % 2== 0) ? middlePanel : cardPanel;
            if (b != NO_CARD) {
                trace(b, new Card(b).toString());
                var c:DraggableCard= createDraggableCard(new Card(b));
                c.enable();
                c.setDraggable(false);
                cp.addWithLayout(HOLDER_LOCATIONS[i], c);
            } else {
                var h:CardHolder= new CardHolder();
                /* Color.darkGray */
                h.setBorderColor(Color.rgb(64, 64, 64));
                h.setFillColor(Color.GRAY);
                h.enableDropping(false);
                cp.addWithLayout(HOLDER_LOCATIONS[i], h);
            }
        }

        p.add(cardPanel);
        return p;
    }

    private function showLastTrick():void {
        var mLastTrick:Vector.<int> = new <int> [46, 43, 44, 39];
        var p:Panel= createTrickPanel("The last trick was:", mLastTrick);
        var winner:String = "Computer_3 won the trick";
        var msg:Label = new Label();
        msg.text = (winner);
        msg.textRendererFactory = createSystemTextRender;
        p.addWithLayout(Layout.SOUTH, msg);

//        var t1:Tween = new Tween(p,1/7.0);
//        t1.moveTo(100, 0);
//
//        var t2:Tween = new Tween(p,1/7.0);
//        t2.delay = .5;
//        t2.moveTo(100, 100);
//        t1.nextTween = t2;
//
//        var juggler:Juggler = new Juggler();
//        juggler.add(t1);
//        Starling.juggler.add(juggler);

        //TODO
//        var d:Dialog= lastTrickDialog;
//        if (d != null) {
//            if (lastTrickDialogTrickId == mLastTrickId) {
//                d.open(this);
//                return;
//            }
//            d.close();
//        }
//        d = new Dialog(this, p, i18N_DIALOG_LAST_TRICK(), Dialog.OK_BUTTONS);
//        lastTrickDialog = d;
//        lastTrickDialogTrickId = mLastTrickId;
//        d.open(this);

        function customCalloutFactory():Callout
        {
            var callout:Callout = new Callout();
//            callout.nameList.add( "my-custom-callout" );
            var yellow:Texture = Texture.fromBitmapData(new BitmapData(p.width, p.height, false, Color.rgb(255,255,128)));
//            var bgd:Scale9Image = new Scale9Image(new Scale9Textures(yellow, p.getBounds(null)));
            callout.backgroundSkin = new Image(yellow);
            return callout;
        };
        var dialog:Callout = Callout.show(p, this, Callout.DIRECTION_ANY, true, customCalloutFactory);
//        var dialogManager:CalloutPopUpContentManager = new CalloutPopUpContentManager();
//        dialogManager.open(p, this);
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
