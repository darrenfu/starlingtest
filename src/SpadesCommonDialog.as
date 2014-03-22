/**
 * Created with IntelliJ IDEA.
 * User: DarrenFu
 * Date: 11/27/13
 * Time: 1:47 PM
 * To change this template use File | Settings | File Templates.
 */
package {
import com.pogo.fgf.common.card.Card;
import com.pogo.fgf.game.TableConstants;
import com.pogo.fgf.gf1.DialogUtil;
import com.pogo.fgf.gf1.card.DraggableCard;
import com.pogo.game.spades2.client.Spades2ClientConfig;
import com.pogo.game.spades2.client.Spades2DraggableCard;
import com.pogo.game.spades2.client.Spades2GamePanel;
import com.pogo.ui.FontConstants;
import com.pogo.ui.starling.ImageSprite;
import com.pogo.ui.starling.StarlingPropsUtils;
import com.pogo.ui.starling.StarlingSprite;
import com.pogo.ui.starling.TableGameDialog;
import com.pogo.ui.starling.events.ActionEvent;
import com.pogo.ui.starling.feathers.BorderedSprite;
import com.pogo.ui.starling.feathers.Button;
import com.pogo.ui.starling.gf1.DialogGF1;
import com.pogo.ui.starling.gf1.DialogListener;
import com.pogo.ui.starling.gf1.Panel;
import com.pogo.ui.starling.text.LabelSprite;
import com.pogo.util.MessageFormat;
import com.pogo.util.Properties;

import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.text.BitmapFontTextRenderer;
import feathers.controls.text.TextFieldTextRenderer;
import feathers.core.FeathersControl;
import feathers.core.ITextRenderer;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalLayout;
import feathers.text.BitmapFontTextFormat;

import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.globalization.LocaleID;
import flash.globalization.NumberFormatter;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import starling.animation.IAnimatable;
import starling.display.DisplayObject;
import starling.display.Quad;
import starling.textures.Texture;
import starling.textures.TextureSmoothing;
import starling.utils.Color;

public class SpadesCommonDialog extends StarlingSprite implements IAnimatable,  DialogListener{

    protected static var tf:TextFormat = new TextFormat(FontConstants.HELVETICA_STD, 12, Color.BLACK);
    private static var mStandardControlsStrip:Texture;

    private var mBidDialog:DialogGF1;
    private var mPassResultsDialog:DialogGF1;
    private var mCutDialog:DialogGF1;
    private var mCutPanel:Spades2LocalCutPanel;

    private var config:Spades2ClientConfig;
    private var props:Properties;

    [Embed(source="../../webapps/pogo/htdocs/images/tabledialog/btn_normal.png")]
    public static const BUTTON_UP:Class;
    [Embed(source="../../webapps/pogo/htdocs/images/tabledialog/btn_down.png")]
    public static const BUTTON_DOWN:Class;
    [Embed(source="../../webapps/pogo/htdocs/images/tabledialog/btn_disable.png")]
    public static const BUTTON_DISABLE:Class;
    [Embed(source="../../webapps/pogo/htdocs/images/tabledialog/dialog.png")]
    public static const BUTTON_BG:Class;

    public function askJoin(screenName:String, playerId:int, rating:int):void {
        var profileButton:Button = null;
        var ratingContainer:LayoutGroup = null;
        if (true) {
            ratingContainer = new LayoutGroup();
            var hLayout:HorizontalLayout = new HorizontalLayout();
//            hLayout.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_MIDDLE;
            hLayout.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_JUSTIFY;
            hLayout.gap = 5;
            ratingContainer.layout = hLayout;

            var ratingLbl:Label = new Label();
            ratingLbl.text = "Rating:";
            ratingLbl.textRendererFactory = function():ITextRenderer {
                var tfr:TextFieldTextRenderer = TableGameDialog.getBodyTextRenderer() as TextFieldTextRenderer;
                //bold
                tfr.textFormat.font = TableGameDialog.mTitleFont;
                return tfr;
            }
            ratingContainer.addChild(ratingLbl);

            if (rating >= 0) {
//                var ratingIconStrip:ImageSprite = getIcons();
//                var subRect:Rectangle = new Rectangle(0, 0, IconStrip.DIM_IconSize, IconStrip.DIM_IconSize);
//                StarlingPropsUtils.showImageByStripPos(ratingIconStrip, player.getRatingStar(), -1, subRect);
//                var ratingIconBtn:Button = new Button();
//                ratingIconBtn.setEnabled(false);
//                ratingIconBtn.defaultSkin = ratingIconStrip;
//                ratingContainer.addChild(ratingIconBtn);

                var ratingStr:String= null;
                if (true) {
                    //TODO: wrap numberFormat as util class, to test
                    var numberFormat:NumberFormatter = new NumberFormatter(LocaleID.DEFAULT);
                    numberFormat.fractionalDigits = 0;
                    ratingStr = numberFormat.formatInt(rating);
                } else {
                    ratingStr = rating + "";
                }
                var ratingValueLbl:Label = new Label();
                ratingValueLbl.text = ratingStr;
                ratingValueLbl.textRendererFactory = function():ITextRenderer {
                    return TableGameDialog.getBodyTextRenderer();
                }
                ratingContainer.addChild(ratingValueLbl);
            }

            profileButton = new Button();
            profileButton.setColorScheme(Button.COLOR_SCHEME_TAN);
//            profileButton.addEventListener(ActionEvent.CLICKED, function(e:ActionEvent):void {
//                playerInfoByPlayer(player);
//            });
        }

        var props:Object = {};
        props.titl = "Joining Player";

        props.text = screenName + " would like to join the game at the seat across from you. \n \n~bDo you want to allow this player to join?";
                //i18N_ASK_JOIN(pos, numPlayers, screenName);
        props.btns = new <String>["Yes", "No"];
        props.callback = function():void {};
//        props.DIALOG_BODY_TEXT_MARGIN_BOTTOM = 30;

        var mJoinDialog:TableGameDialog = new TableGameDialog(this,TableConstants.ASK_JOIN_DLOG_NAME,props);
        mJoinDialog.show();

        if (ratingContainer) {
            mJoinDialog.add(ratingContainer);
            ratingContainer.validate();
            ratingContainer.x = mJoinDialog.bodyTextLabel.x;
            ratingContainer.y = 45;
            profileButton.y = ratingContainer.y;
            var yOffset:int = ratingContainer.y + ratingContainer.height - mJoinDialog.bodyTextLabel.y + 10;
            mJoinDialog.increaseYOffset(yOffset);
        }

        if (profileButton) {
            mJoinDialog.add(profileButton);
            profileButton.validate();
            profileButton.setLabel("View Profile", FontConstants.HELVETICA_STD, 12, Button.BLACK);
            profileButton.x = mJoinDialog.bodyTextLabel.x + mJoinDialog.bodyTextLabel.width - profileButton.width;
        }
    }


    public function SpadesCommonDialog() {
        super();

        mStandardControlsStrip = SpadesCardGamePanel.mStandardControlsStrip;
        config = Spades2ClientConfig.get();
        props = config.getProps();
    }

    public function handleDoCut(screenName:String, cards:Vector.<int>, isMe:Boolean=true):void {
        var noButtons:Vector.<Button>=new Vector.<Button>();
        if (isMe) {

            var cp:Spades2LocalCutPanel= mCutPanel;
            if (cp == null) {
                cp = new Spades2LocalCutPanel(this, props);
                mCutPanel = cp;
            }

            cp.setCards(cards);

            mCutDialog = createGraphicalDialog("cut", null, noButtons, null, cp);
            DialogUtil.layout(mCutDialog, DialogUtil.POSITION_RIGHT, DialogUtil.POSITION_TOP);
//            DialogUtil.layout(mCutDialog, DialogUtil.POSITION_CENTER, DialogUtil.POSITION_CENTER);

        } else {
            var msg:String= MessageFormat.applyFormat(props.getProperty("MESSAGE_CUTTING_CARDS"),
                    [ screenName ]);
            mCutDialog = createGraphicalDialog("cutting", createLabel(msg), noButtons);
            DialogUtil.layout(mCutDialog, DialogUtil.POSITION_CENTER, DialogUtil.POSITION_CENTER);
        }
    }

    public function madeBid(screenName:String, blind:Boolean, nilBid:Boolean,
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

        mBidDialog = createGraphicalDialog("bid",msg, buttons, null );
        DialogUtil.layout(mBidDialog,(blind) ? DialogUtil.POSITION_CENTER : DialogUtil.POSITION_RIGHT,
                (blind) ? DialogUtil.POSITION_CENTER : DialogUtil.POSITION_TOP);

        //TODO
//        var t1:Tween = new Tween(mBidDialog, 3);
//        t1.moveTo(200, 300);
//
//        var t2:Tween = new Tween(mBidDialog, 3);
//        t2.moveTo(0,0);
//        t2.nextTween = t1;
//        t1.nextTween = t2;
//
//        var juggler:Juggler = new Juggler();
//        juggler.add(t1);
//        Starling.juggler.add(juggler);
    }

    public function passed(screenName:String, cards:Vector.<int>):void {
        var args:Array=["You",screenName];
        var title:String = (cards.length == 1) ?
                        MessageFormat.applyFormat(props.getProperty("MESSAGE_PASSED_ONE_CARD"), args) :
                        MessageFormat.applyFormat(props.getProperty("MESSAGE_PASSED_TWO_CARDS"), args);
        var titleLabel:Label = new Label();
        titleLabel.text = title;
        titleLabel.textRendererFactory = function():ITextRenderer {
            var textRenderer:BitmapFontTextRenderer = new BitmapFontTextRenderer();
            textRenderer.textFormat = new BitmapFontTextFormat("spades.dialog");
            textRenderer.textFormat.letterSpacing = 1;
            textRenderer.textFormat.align = TextFormatAlign.CENTER;
            textRenderer.smoothing = TextureSmoothing.BILINEAR;
            return textRenderer;
        }

        var dlogContent:Panel= createCardPanelWithFont(cards);

        mPassResultsDialog =  okDialog(titleLabel, dlogContent, false );
    }

    public function okDialog(msg:Label, contents:Panel, usePauseDialog:Boolean):DialogGF1 {
        var okButton:Vector.<Button>=new <Button>[createButton(config.mButtonOkSubRect)];

        var d:DialogGF1= createGraphicalDialog("ok", msg, okButton, null, contents );
//        d.setUseFrame(false);
        if (usePauseDialog) {
//            pauseDialog(d);
        } else {
//            d.openInternal(this, getRoot(), Dialog.POSITION_CENTER, Dialog.POSITION_CENTER, false);
            DialogUtil.layout(d, DialogUtil.POSITION_CENTER, DialogUtil.POSITION_CENTER);
        }

        return d;
    }

    public function createCardPanelWithFont(cards:Vector.<int>):Panel {
        var cardPanel:Panel= new Panel();
        var x:int= 0;
        for (var i:int= 0; (i < cards.length); i++) {
            var card:DraggableCard= new Spades2DraggableCard(new Card(cards[i]), false, null);
            card.setAnchor(x, 0);
            card.moveToAnchor();
            card.setDraggable(false);
            cardPanel.add(card);
            x += DraggableCard.SPREAD;
        }

        cardPanel.setBounds(0, 0,
                DraggableCard.WIDTH + DraggableCard.SPREAD * (cards.length - 1),
                DraggableCard.HEIGHT);
        return cardPanel;
    }

    public function createGraphicalDialog(dialogKey:String, msg:Label, buttons:Vector.<Button>, footnote:LabelSprite=null,contents:Panel=null):DialogGF1 {
        var dialog:DialogGF1 = new DialogGF1(this,buttons);
        add(dialog);
        var dialogBody:LayoutGroup = new LayoutGroup();
        var hlayout:VerticalLayout = new VerticalLayout();
        hlayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
        hlayout.gap = 5;
        hlayout.padding = 22;
        dialogBody.layout = hlayout;

        if (msg) {
            dialogBody.addChild(msg);
        }

        if (contents) {
            dialogBody.addChild(contents);
        }

        var buttonGroup:LayoutGroup = new LayoutGroup();
        var vlayout:HorizontalLayout = new HorizontalLayout();
        vlayout.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_MIDDLE;
        vlayout.gap = 5;
        buttonGroup.layout = vlayout;
        for(var i:int = 0;i < buttons.length;i ++) {
            var button:Button = buttons[i];
            buttonGroup.addChild(button);
        }
        dialogBody.addChild(buttonGroup);

        //add footnote
        if(footnote != null) {
            dialogBody.addChild(footnote);
        }

        dialog.add(dialogBody);
        dialogBody.validate();

        //add background
//        var bgSubRect:Rectangle = PropsUtils.makeRectWithProperties(props,"spades.dlog.back");
//        var bgSprite:TiledImage = new TiledImage(Texture.fromTexture(mStandardControlsStrip, bgSubRect));
//        var bgSprite:ImageTilerSprite = new ImageTilerSprite(mStandardControlsStrip,bgSubRect);
        //TODO
        var bgOffset:int = 5;
        var bgSprite:Quad = new Quad(dialogBody.width - 2 * bgOffset, dialogBody.height - 2 * bgOffset,
                Spades2GamePanel.COLOR_DIALOG_BG);
        bgSprite.x = bgOffset;
        bgSprite.y = bgOffset;
//        bgSprite.setSize(dialogWidth - 2 * bgOffset, dialogHeight - 2 * bgOffset);
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
        var borderedSprite:BorderedSprite = new BorderedSprite();
        borderedSprite.expandBorderThickness = false;
        borderedSprite.initWithCorners(mStandardControlsStrip, borders);
        borderedSprite.setBounds(0,0,dialogBody.width,dialogBody.height);
        borderedSprite.flatten();
        dialog.add(borderedSprite);

        return dialog;
    }

    public function createGraphicalDialog_bak(dialogKey:String, msg:Label, buttons:Vector.<Button>, footnote:LabelSprite=null,contents:Panel=null):DialogGF1{
        var  dialog:DialogGF1 = new DialogGF1(this,buttons);
        add(dialog);
        if (msg) {
            dialog.add(msg);
            msg.validate();
        }

        var horizontalPadding:int = 20;
        var verticalPadding:int = 20;
        var contentVerticalSpace:int = 5;
        var contentHeight:int = msg.height;
//        var contentMaxHeight:int = 0;
//        if (contents) {
//            contents.y = msg.y + msg.height + verticalPadding;
//            contentHeight += contents.height + verticalPadding;
//            contentMaxHeight = contents.height + verticalPadding * 2;
//            dialog.add(contents);
//        }
        if(buttons != null && buttons.length > 0) {
            contentHeight += buttons[0].height + contentVerticalSpace;
        }

        var totalBtnWidth:int = 0;
        var btnHorizontalSpace:int = 5;
        for(var i:int = 0;i < buttons.length;i ++) {
            var button:Button = buttons[i];
            dialog.add(button);
            button.validate();
            totalBtnWidth += button.width;
//            button.y += contentMaxHeight;
        }

        totalBtnWidth += (buttons.length - 1) * btnHorizontalSpace;

        var dialogWidth:int = totalBtnWidth + horizontalPadding * 2;
        if(dialogWidth < msg.width + horizontalPadding * 2) {
            dialogWidth = msg.width + horizontalPadding * 2;
        }
//        if (contents) {
//            if (dialogWidth < contents.width + horizontalPadding * 2) {
//                dialogWidth = contents.width + horizontalPadding * 2;
//            }
//            contents.x = int ((dialogWidth - contents.width) / 2);
//        }

        var btnStartX:int = (dialogWidth - totalBtnWidth) / 2;

        var footnoteX:int = 0;
        if(footnote != null) {
            contentHeight += footnote.height + contentVerticalSpace;
            footnoteX = (dialogWidth - footnote.width) / 2;
        }

        var dialogHeight:int = contentHeight + verticalPadding * 2;
//        if (dialogHeight < contents.height + verticalPadding * 2) {
//            dialogHeight = contents.height + verticalPadding * 2;
//        }

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
//        var bgSubRect:Rectangle = PropsUtils.makeRectWithProperties(props,"spades.dlog.back");
//        var bgSprite:TiledImage = new TiledImage(Texture.fromTexture(mStandardControlsStrip, bgSubRect));
//        var bgSprite:ImageTilerSprite = new ImageTilerSprite(mStandardControlsStrip,bgSubRect);
        var bgOffset:int = 5;
        var bgSprite:Quad = new Quad(dialogWidth - 2 * bgOffset,dialogHeight - 2 * bgOffset,
                Spades2GamePanel.COLOR_DIALOG_BG);
        bgSprite.x = bgOffset;
        bgSprite.y = bgOffset;
//        bgSprite.setSize(dialogWidth - 2 * bgOffset, dialogHeight - 2 * bgOffset);
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
        var borderedSprite:BorderedSprite = new BorderedSprite();
        borderedSprite.expandBorderThickness = false;
        borderedSprite.initWithCorners(mStandardControlsStrip, borders);
        borderedSprite.setBounds(0,0,dialogWidth,dialogHeight);
        borderedSprite.flatten();
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

//        if (contents) {
//            dialog.add(contents);
//        }

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

    public function createLabel(text:String, alignment:String="left", fontStrip:String=null):Label {
        if (fontStrip == null) {
            fontStrip = "spades.dialog";
        }
        var lbl:Label = new Label();
        lbl.text = text;
//        lbl.x = bounds.x;
//        lbl.y = bounds.y;
        lbl.textRendererFactory = function():ITextRenderer {
            var textRenderer:BitmapFontTextRenderer = new BitmapFontTextRenderer();
            textRenderer.textFormat = new BitmapFontTextFormat(fontStrip);
            textRenderer.textFormat.align = alignment;
            textRenderer.textFormat.letterSpacing = 1;
            textRenderer.smoothing = TextureSmoothing.BILINEAR;
            return textRenderer;
        };
        return lbl;
    }

    public function advanceTime(time:Number):void {
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
