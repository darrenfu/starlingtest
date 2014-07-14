//
// Written by Craig Kelley on 2013-04-16
// Copyright (c) 2013 Electronic Arts
// All rights reserved.
//
package {

import com.pogo.ui.starling.StarlingSprite;
import com.pogo.ui.starling.gf1.ChatBubble;

import flash.display.BitmapData;
    import flash.display.Stage;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.utils.Timer;

    import starling.core.Starling;

    import starling.display.DisplayObject;
    import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;
    import starling.extensions.pixelmask.PixelMaskDisplayObject;
    import starling.filters.ColorMatrixFilter;
    import starling.text.TextField;
import starling.textures.Texture;
import starling.utils.Color;

public class StarlingMain extends Sprite {

    private var image:Image;
    private var textures:Vector.<Texture> = new Vector.<Texture>();
    private var times:int;
    private var mHovered:Boolean;

	public function StarlingMain() {
		super();
		addEventListener(Event.ADDED_TO_STAGE, init);

	}

    private function onRightClick(e:MouseEvent):void
    {
        trace("got it");
    }

    public function init(e:Event):void {
        /*
        addChild(new TextField(200, 50, "Hello."));
        var stage:Stage = Starling.current.nativeStage;
        while (!stage){
            trace("wait");
        }
        stage.addEventListener(MouseEvent.RIGHT_CLICK, onRightClick);
        drawShapes();
        */
        //TODO: switch to which test case
//		addChild(new ImageStripTest());
//        addChild(new DominoSheen());
//        addChild(new DominoSparkleTracer());
//        var s:StarlingSprite = new DominoScoringAnim();
//        var s:StarlingSprite = new ChessGamePanel_Local();
        var s:StarlingSprite = new MahjongTileTest();
        s.x = 100;
        s.y = 100;
        addChild(s);

//		addChild(new ParticleSys());
	}

	private function drawShapes():void {
		var aquaBox:Sprite = makeSquare(200, 200, Color.AQUA);
		var blackBox:Sprite = makeSquare(200, 200, Color.BLACK);
		var redBox:Sprite = makeSquare(200, 200, Color.RED);

        var filter:ColorMatrixFilter = new ColorMatrixFilter();
        filter.adjustSaturation(-1);
        //redBox.filter = filter;
        //.filter = filter;
        aquaBox.filter = filter;

        textures.push(makeTexture(200, 200, Color.AQUA));
        textures.push(makeTexture(200, 200, Color.BLACK));
        textures.push(makeTexture(200, 200, Color.RED));

        var button:Sprite = new Sprite();
        image = new Image(textures[0]);
        button.addChild(image);

		aquaBox.x = 10;
		aquaBox.y = 10;
		blackBox.x = 10;
		blackBox.y = 10;
		redBox.x = 10;
		redBox.y = 10;

		aquaBox.addChild(blackBox);
		blackBox.addChild(redBox);
		addChild(aquaBox);

        //addChild(button);

	}

    private function onTouch(e:TouchEvent):void
    {
        if (e.getTouch(this, TouchPhase.HOVER))
            trace(TouchPhase.HOVER);
        else if (e.getTouch(this, TouchPhase.BEGAN))
            trace(TouchPhase.BEGAN);
        else if (e.getTouch(this, TouchPhase.ENDED))
            trace(TouchPhase.ENDED);
        else if (e.getTouch(this, TouchPhase.MOVED))
            trace(TouchPhase.MOVED);
        else
            trace("null");
        /*
        if (touch && !mHovered)
        {
            mHovered = true;
            touchTimes++;
            trace("I've been touched " + touchTimes + " times!");
        }
        else
        {
            mHovered = false;
        }
        */
    }

	private function makeSquare(width:int, height:int, color:uint):Sprite {
		var container:Sprite = new Sprite();
		container.addChild(new Image(makeTexture(width, height, color)));

		return container;
	}

    private function makeTexture(width:int, height:int, color:uint):Texture {
        var s:flash.display.Sprite = new flash.display.Sprite();
        //s.graphics.lineStyle(1, color);
        s.graphics.beginFill(color, 1.0);
        s.graphics.drawRect(0, 0, width - 1, height - 1);
        s.graphics.endFill();

        var bmd:BitmapData = new BitmapData(width, height, true, 0xffffff);
        bmd.draw(s);
        var texture:Texture = Texture.fromBitmapData(bmd);

        return texture;
    }

    private function makeAlphaTexture(width:int, height:int, color:uint):Texture {
        var s:flash.display.Sprite = new flash.display.Sprite();
        //s.graphics.lineStyle(1, color);
        s.graphics.beginFill(Color.BLACK, 1.0);
        s.graphics.drawRect(0, 0, width - 1, height - 1);
        s.graphics.endFill();

        var bmd:BitmapData = new BitmapData(width, height, true, 0xffffff);
        bmd.draw(s);
        var texture:Texture = Texture.fromBitmapData(bmd);

        return texture;
    }

}
}
