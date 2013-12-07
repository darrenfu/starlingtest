/**
 * Created with IntelliJ IDEA.
 * User: dgrossen
 * Date: 8/7/13
 * Time: 9:24 AM
 * To change this template use File | Settings | File Templates.
 */
package {
import com.pogo.ui.FontDefinition;
import com.pogo.ui.FontDefinition;
import com.pogo.ui.starling.ImageSprite;
import com.pogo.ui.starling.StarlingSprite;
import com.pogo.ui.starling.gf1.ChatBubble;
import com.pogo.util.TickManager;

import flash.display.Bitmap;
import flash.geom.Rectangle;

import starling.animation.IAnimatable;
import starling.textures.Texture;
import starling.utils.Color;

public class SpadesChatBubbleContainer extends StarlingSprite implements IAnimatable {
    [Embed(source="../../webapps/pogo/htdocs/applet/images/avatar/spades_UI_Elements.png")]
    public static const spadesBg:Class;

    [Embed(source="../../webapps/pogo/htdocs/applet/images/avatar/chat-bubbles-arrows.png")]
    public static const chatBubble:Class;

    private var spadesImg:ImageSprite;
    private var chatBubbleImg:Texture;
    private var mChatBubble:Vector.<ChatBubble>;

    public function SpadesChatBubbleContainer() {
        super();
        spadesImg = new ImageSprite(Texture.fromBitmap(new spadesBg()));
        add(spadesImg);

        chatBubbleImg = Texture.fromBitmap(new chatBubble());


        mChatBubble = new Vector.<ChatBubble>(1);
        var font:FontDefinition = new FontDefinition();
        font.fontName = "Helvetica";
        font.fontSize = 12;

        var i:int=0;
        mChatBubble[i] = new ChatBubble(
                null,
                font,
                Color.BLACK,
                chatBubbleImg,
                new Rectangle(0,0,106,47),
                new Rectangle(107,4,12,12),
                new Rectangle(5,5,106,47),
                new Rectangle(0,0,12,12),
                new Rectangle(7,7,99,40)
        );
//                    props.getRect("player.bubble." + i + ".tail.sub"),
//                    props.getRect("player.bubble." + i + ".bubble"),
//                    props.getRect("player.bubble." + i + ".tail"),
//                    props.getRect("player.bubble." + i + ".label"));

        mChatBubble[i].setBounds(407,214,112,52);
//                    props.getRect("player.bubble." + i));


        i = 1;
        mChatBubble[i] = new ChatBubble(
                null,
                font,
                Color.BLACK,
                chatBubbleImg,
                new Rectangle(0,0,106,47),
                new Rectangle(120,29,11,12),
                new Rectangle(0,0,106,47),
                new Rectangle(49,40,11,12),
                new Rectangle(2,2,99,40)
        );
        mChatBubble[i].setBounds(178,21,108,52);

        i = 2;
        mChatBubble[i] = new ChatBubble(
                null,
                font,
                Color.BLACK,
                chatBubbleImg,
                new Rectangle(0,0,106,47),
                new Rectangle(107,29,12,12),
                new Rectangle(5,0,106,47),
                new Rectangle(0,37,12,12),
                new Rectangle(7,2,99,40)
        );
        mChatBubble[i].setBounds(407,1,112,49);

        i = 3;
        mChatBubble[i] = new ChatBubble(
                null,
                font,
                Color.BLACK,
                chatBubbleImg,
                new Rectangle(0,0,106,47),
                new Rectangle(145,31,16,8),
                new Rectangle(0,0,106,47),
                new Rectangle(68,44,16,82),
                new Rectangle(2,2,99,40)
        );
        mChatBubble[i].setBounds(474,49,108,52);

        for (i = 0; i < mChatBubble.length; ++i) {
            add(mChatBubble[i]);

            //TODO: deduct banner height
            mChatBubble[i].y += 22;
            mChatBubble[i].setChat("FDSLKFJL :DSJF:LSDJ FL:SDJF");
        }
    }

    public function advanceTime(time:Number):void {
        TickManager.singleton().doTick();

    }

}
}
