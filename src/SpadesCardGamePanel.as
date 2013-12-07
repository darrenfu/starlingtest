/**
 * Created with IntelliJ IDEA.
 * User: DarrenFu
 * Date: 11/27/13
 * Time: 1:47 PM
 * To change this template use File | Settings | File Templates.
 */
package {
import com.pogo.fgf.common.card.Card;
import com.pogo.fgf.gf1.DialogUtil;
import com.pogo.fgf.gf1.card.CardHolder;
import com.pogo.fgf.gf1.card.DraggableCard;
import FontLoader;
import com.pogo.game.spades2.client.Spades2ClientConfig;
import com.pogo.game.spades2.client.Spades2GamePanel;
import com.pogo.ui.FontConstants;
import com.pogo.ui.Layout;
import com.pogo.ui.PropsCoreUtils;
import com.pogo.ui.PropsUtils;
import com.pogo.ui.starling.BorderedSprite;
import com.pogo.ui.starling.ImageSprite;
import com.pogo.ui.starling.StarlingPropsUtils;
import com.pogo.ui.starling.StarlingSprite;
import com.pogo.ui.starling.StarlingUtils;
import com.pogo.ui.starling.anim.StarlingImageStripAnimator;
import com.pogo.ui.starling.events.ActionEvent;
import com.pogo.ui.starling.feathers.Button;
import com.pogo.ui.starling.gf1.DialogGF1;
import com.pogo.ui.starling.gf1.DialogListener;
import com.pogo.ui.starling.gf1.Panel;
import com.pogo.ui.starling.text.LabelSprite;
import com.pogo.util.HashTable;
import com.pogo.util.ITickable;
import com.pogo.util.MessageFormat;
import com.pogo.util.Properties;
import com.pogo.util.StringUtils;
import com.pogo.util.TickManager;


import feathers.controls.Callout;
import feathers.controls.Label;
import feathers.controls.text.BitmapFontTextRenderer;
import feathers.controls.text.TextFieldTextRenderer;
import feathers.core.ITextRenderer;
import feathers.display.Scale9Image;
import feathers.display.TiledImage;
import feathers.text.BitmapFontTextFormat;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;
import flash.geom.Rectangle;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import starling.animation.IAnimatable;
import starling.animation.Juggler;
import starling.animation.Tween;
import starling.core.Starling;

import starling.display.Image;
import starling.display.Quad;
import starling.textures.Texture;
import starling.textures.TextureSmoothing;
import starling.utils.Color;

public class SpadesCardGamePanel extends StarlingSprite implements IAnimatable,  DialogListener{

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
    [Embed(source="../../pogo/games/spades2/texture_assets/images/spades2.images.all.include.spades.gif")]
    private static const TRUMP_BMP:Class;

    private static const mStandardControlsStripKey:String = "spades.buttons";
    [Embed(source="../../pogo/games/spades2/texture_assets/images/spades2.images.all.include.stdcontrols.gif")]
    private static const STANDARDCONTROLSSTRIP_BMP:Class;
    private static var mStandardControlsStrip:Texture;

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

//        var applet:ClientApplet = new PlaceHolderApplet();
//        services = new PlaceHolderGameServices(new PlaceHolderApplet(), props);
//        services.cacheTexture(TRUMP_KEY, Texture.fromBitmapData(imageCache.get(TRUMP_KEY) as BitmapData));

        Spades2ClientConfig.init(p);
        config = Spades2ClientConfig.get();

        FontLoader.init();

        mStandardControlsStrip = Texture.fromBitmap(new STANDARDCONTROLSSTRIP_BMP() as Bitmap);


        //TODO
        initCardImages(p, this, imageCache);
        showLastTrick();
        madeBid("eaclub01", true, true, 1, 7);
//        playTrumpAnim(13);
    }

    private function madeBid(screenName:String, blind:Boolean, nilBid:Boolean,
                             minBid:int, maxBid:int):void {

        var s:String;
        if (blind) {
            var loss:int = 100;
            var points:String= numberFormat(loss);

            s = MessageFormat.applyFormat(props.getProperty("MESSAGE_ASK_BID_BLIND"),
                    [ screenName, points ]);
        } else {
            s = MessageFormat.applyFormat(props.getProperty("MESSAGE_SELECT_BID"),
                    [ screenName ]);
        }

        var msg:Label = new Label();
        msg.text = s;
        msg.textRendererFactory = function():ITextRenderer {
            var textRenderer:BitmapFontTextRenderer = new BitmapFontTextRenderer();
            textRenderer.textFormat = new BitmapFontTextFormat("spades.dialog");
            textRenderer.textFormat.letterSpacing = 1;
            textRenderer.smoothing = TextureSmoothing.BILINEAR;
            return textRenderer;
        }

        var buttons:Vector.<Button>= new Vector.<Button>(maxBid-minBid+((nilBid)?2:1)+((blind)?1:0));

        var i:int= 0;
        if (blind) {
            buttons[i] = createButton( config.mButtonBlindNoSubRect );
            i++;
        }
        if (nilBid) {
            buttons[i] = createButton( config.mButtonNilSubRect );
            i++;
        }
        for (var b:int= minBid; (b <= maxBid); b++) {
            buttons[i] = createDlogNumberButton(b);
            i++;
        }

        var footNote:LabelSprite= null;
//        var logic:Spades2Logic= Spades2Logic(mClient.getLogic());
//            if (logic.getOptions().suggestBids()) {
//                var suggest:String= config().mTextSuggestedBid +
//                        Spades2AI.suggestBid(logic, player, blind, nilBid, minBid, maxBid, true );
//                footNote = new GraphicalLabel(suggest, assets().mDialogFont, Label.CENTER );
////                footNote.setTransparent(true);
//            }

        mBidDialog = createGraphicalDialog("bid",msg, buttons, footNote );

        DialogUtil.layout(mBidDialog,(blind) ? DialogUtil.POSITION_CENTER : DialogUtil.POSITION_RIGHT,
                (blind) ? DialogUtil.POSITION_CENTER : DialogUtil.POSITION_TOP);
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

    public function createGraphicalDialog(dialogKey:String, msg:Label, buttons:Vector.<Button>, footnote:LabelSprite=null):DialogGF1{
        var  dialog:DialogGF1 = new DialogGF1(this,buttons);
        add(dialog);
        dialog.add(msg);
        msg.validate();


        var totalBtnWidth:int = 0;
        var btnHorizontalSpace:int = 5;
        for(var i:int = 0;i < buttons.length;i ++) {
            var button:Button = buttons[i];
            dialog.add(button);
            button.validate();
            totalBtnWidth += button.width;
        }

        totalBtnWidth += (buttons.length - 1) * btnHorizontalSpace;

        var horizontalPadding:int = 20;
        var verticalPadding:int = 20;

        var dialogWidth:int = totalBtnWidth + horizontalPadding * 2;
        if(dialogWidth < msg.width + horizontalPadding * 2) {
            dialogWidth = msg.width + horizontalPadding * 2;
        }

        var btnStartX:int = (dialogWidth - totalBtnWidth) / 2;


        var contentVerticalSpace:int = 5;
        var contentHeight = msg.height;
        if(buttons != null && buttons.length > 0) {
            contentHeight += buttons[0].height + contentVerticalSpace;
        }

        var footnoteX:int = 0;
        if(footnote != null) {
            contentHeight += footnote.height + contentVerticalSpace;
            footnoteX = (dialogWidth - footnote.width) / 2;
        }

        var dialogHeight:int = contentHeight + verticalPadding * 2;


        var msgY:int = (dialogHeight - contentHeight) / 2;
        var btnY:int = msgY + msg.height + contentVerticalSpace;
        var footnoteY:int = 0;
        if(footnote != null) {
            if(buttons != null && buttons.length > 0) {
                footnoteY = btnY + buttons[0].height + contentVerticalSpace;
            }else {
                footnoteY = msgY + msg.height + contentVerticalSpace;
            }

        }


        var x:int = (this.width - dialogWidth) / 2;
        var y:int = (this.height - dialogHeight) / 2;
        dialog.setBounds(x,y,dialogWidth,dialogHeight);

        //add background
        var bgSubRect:Rectangle = PropsUtils.makeRectWithProperties(props,"spades.dlog.back");
        var bgSprite:TiledImage = new TiledImage(Texture.fromTexture(mStandardControlsStrip, bgSubRect));
//        var bgSprite:ImageTilerSprite = new ImageTilerSprite(mStandardControlsStrip,bgSubRect);
        var bgOffset:int = 5;
//        var bgSprite:Quad = new Quad(dialogWidth - 2 * bgOffset,dialogHeight - 2 * bgOffset,
//                Spades2GamePanel.COLOR_DIALOG_BG);
        bgSprite.x = bgOffset;
        bgSprite.y = bgOffset;
        bgSprite.setSize(dialogWidth - 2 * bgOffset, dialogHeight - 2 * bgOffset);
        dialog.addChildAt(bgSprite, 0);

        //add borders
        var borders:Vector.<Rectangle> = StarlingPropsUtils.getBorderEdges(props, "spades.dlog");
//        borders.push(PropsUtils.makeRectWithProperties(props, "spades.dlog.back"));

        //TODO
//        var borderedSprite:Scale9Image = new Scale9ImageSprite((new STANDARDCONTROLSSTRIP_BMP() as Bitmap).bitmapData, borders);
//        borderedSprite.width = dialogWidth;
//        borderedSprite.height = dialogHeight;
//        dialog.addChildAt(borderedSprite, 1);
        //TODO
        var borderedSprite = new BorderedSprite();
        borderedSprite.expandBorderThickness = false;
        borderedSprite.initWithCorners(mStandardControlsStrip, borders);
        borderedSprite.setBounds(0,0,dialogWidth,dialogHeight);
//        borderedSprite.flatten();
        dialog.add(borderedSprite);


        var msgX:int = (dialogWidth - msg.width) / 2;
        msg.x = msgX;
        msg.y = msgY;

        //add buttons
        for(var i:int = 0;i < buttons.length;i ++) {
            var button:Button = buttons[i];
            if(i == 0) {
                button.x = btnStartX;
            }else {
                button.x = buttons[i - 1].x + buttons[i - 1].width + btnHorizontalSpace;
            }

            button.y = btnY;
        }

        //add footnote
        if(footnote != null) {
            footnote.x = footnoteX;
            footnote.y = footnoteY;
            dialog.add(footnote);
        }


//        var dialogBounds:Rectangle = PropsUtils.makeRectWithProperties(mServices.getProperties(),"spades.dlog." + dialogKey);
//        dialog.setBoundsFromRectangle(dialogBounds);

        //msg.x = PropsCoreUtils.makeInt(mServices.getProperties(),"spades.dlog." + dialogKey + ".msg.x");
        //msg.y = PropsCoreUtils.makeInt(mServices.getProperties(),"spades.dlog." + dialogKey + ".msg.y");
        //dialog.add(msg);




        return dialog;
    }

    private function createButton( subRect:Rectangle):Button {
        var b:Button = new Button();
        var up:ImageSprite = new ImageSprite(mStandardControlsStrip,subRect);
        b.defaultSkin = up;

        var bm:BitmapData = new BitmapData(up.width,up.height,false,Color.WHITE);
        var pressed:ImageSprite = new ImageSprite(Texture.fromBitmapData(bm));
        var up1:ImageSprite = new ImageSprite(mStandardControlsStrip,subRect);
        up1.x = 1;
        up1.y = 1;
        pressed.addChild(up1);

        b.downSkin = pressed;
        return b;
    }

    function createDlogNumberButton(num:int):Button {
        var rect:Rectangle= new Rectangle();
        rect.copyFrom(config.mButtonZeroSubRect);
        rect.x += num * (rect.width + 1);
        return createButton( rect);
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

        var t1:Tween = new Tween(p,1/7.0);
        t1.moveTo(100, 0);

        var t2:Tween = new Tween(p,1/7.0);
        t2.delay = .5;
        t2.moveTo(100, 100);
        t1.nextTween = t2;

        var juggler:Juggler = new Juggler();
        juggler.add(t1);
        Starling.juggler.add(juggler);

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

    public function handleDialogButton(dialog:DialogGF1, buttonIndex:int):Boolean {
        return false;
    }

    public function handleDialogEvent(dialog:DialogGF1, event:ActionEvent):Boolean {
        return false;
    }

    public function handleDialogClosed(dialog:DialogGF1):void {
    }
}
}
