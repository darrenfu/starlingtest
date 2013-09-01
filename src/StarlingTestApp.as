//
// Written by Craig Kelley on 2013-04-16
// Copyright (c) 2013 Electronic Arts
// All rights reserved.
//
package {
import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.MouseEvent;

    import starling.core.Starling;
    import starling.utils.Color;
    import starling.utils.HAlign;
    import starling.utils.VAlign;

    [SWF(width="1024", height="800", backgroundColor="#008855")]
public class StarlingTestApp extends MovieClip {

	private var _starling:Starling;

	public function StarlingTestApp() {
		starling = new Starling(StarlingMain, stage);
		starling.start();
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        Starling.current.showStats = true;
        Starling.current.showStatsAt(HAlign.LEFT, VAlign.CENTER);
	}

    private function onAddedToStage(e:Event):void
    {
        stage.addEventListener(MouseEvent.RIGHT_CLICK, doNothing);
    }
    private function doNothing(e:MouseEvent):void
    {

    }


	public function get starling():Starling {
		return _starling;
	}

	public function set starling(value:Starling):void {
		_starling = value;
	}
}
}
