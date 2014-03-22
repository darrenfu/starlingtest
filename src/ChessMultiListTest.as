/**
 * Created with IntelliJ IDEA.
 * User: DarrenFu
 * Date: 11/27/13
 * Time: 1:47 PM
 * To change this template use File | Settings | File Templates.
 */
package {
import com.pogo.ui.starling.FeathersPropsUtils;

import feathers.controls.Button;
import feathers.controls.IScrollBar;
import feathers.controls.List;
import feathers.controls.ScrollBar;
import feathers.controls.renderers.DefaultListItemRenderer;
import feathers.controls.renderers.IListItemRenderer;
import feathers.controls.text.TextFieldTextRenderer;
import feathers.core.ITextRenderer;
import feathers.data.ListCollection;
import feathers.display.Scale3Image;
import feathers.layout.HorizontalLayout;
import feathers.textures.Scale3Textures;

import flash.geom.Rectangle;
import flash.text.TextFormat;

import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.ResizeEvent;
import starling.textures.Texture;
import starling.utils.Color;

public class ChessMultiListTest extends Sprite {

    [Embed(source="images/chess_scrollbar.png")]
    private static const SCROLLBAR_IMAGE:Class;

    private var _multiList:Vector.<List>;
    private var col:int = 3;

    public function ChessMultiListTest() {
        this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
    }

    protected function layout():void
    {
//        8, 182, 159, 110
//        var width:Number = 70;///*60*3+ 18;*/159;
        var height:Number = 115;

        var curTotalWidth:Number = 0;
        var hGap:Number = 21;
        var borderForeground:uint = Color.BLACK;
        var borderThickness:Number = 1;
        for (var i:int = 0; i < col; i ++) {
            _multiList[i].x += curTotalWidth;
            _multiList[i].height = height;
            _multiList[i].validate();
            _multiList[i].width += hGap;
            createBorder(borderForeground, new Rectangle(_multiList[i].x, _multiList[i].y, borderThickness, _multiList[i].height));
            curTotalWidth += _multiList[i].width;
        }
        createBorder(borderForeground, new Rectangle(_multiList[0].x, _multiList[0].y, curTotalWidth, borderThickness));
        createBorder(borderForeground, new Rectangle(_multiList[0].x, _multiList[0].y + height, curTotalWidth, borderThickness));
    }

    protected function addedToStageHandler(event:Event):void
    {
        this.removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
        this.stage.addEventListener(ResizeEvent.RESIZE, stage_resizeHandler);

//        const listLayout:TiledRowsLayout = new TiledRowsLayout();
//        listLayout.paging = TiledRowsLayout.PAGING_NONE;
//        listLayout.useSquareTiles = false;
//        listLayout.tileHorizontalAlign = TiledRowsLayout.TILE_HORIZONTAL_ALIGN_LEFT;
//        listLayout.horizontalAlign = TiledRowsLayout.HORIZONTAL_ALIGN_LEFT;
//        listLayout.manageVisibility = true;
//        listLayout.useVirtualLayout = false; // NOTE: must set to false, otherwise the layout will NOT be organized by cell label width!

//        _list.typicalItem = { label: "1." };

        var array:Array = [];
        for (var i:int = 1; i <= 10; i++) {
            array.push({label: i + "."});
            array.push({label: "f1-e" + i});
            array.push({label: "c5xf" + i});
        }

        const collections:Vector.<ListCollection> = new Vector.<ListCollection>(col);
        for (var i:int = 0; i < col; i ++) {
            collections[i] = new ListCollection();
        }
        array.forEach(function(item:*, index:int, array:Array):void {
            collections[index % 3].push(item);
        });

        _multiList = new Vector.<List>(col);
        for (var i:int = 0; i < col; i ++) {
            var showScrollBar:Boolean = i == col - 1;
            _multiList[i] = createList(showScrollBar);
            _multiList[i].dataProvider = collections[i];
        }
        
        this.layout();
    }

    private function createList(showScrollBar:Boolean):List {
//        var listLayout:VerticalLayout = new VerticalLayout();
//        listLayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_JUSTIFY;
//        listLayout.manageVisibility = true;

        var _list:List = new CustomList();
        // use default vertical layout, @see List.initialize()
//        _list.layout = listLayout;

        // scrollbar
        _list.snapToPages = true; // if touch scrolling will snap to the nearest page
        _list.horizontalScrollPolicy = List.SCROLL_POLICY_OFF; // disable horizontal scroll
        _list.verticalScrollPolicy = List.SCROLL_POLICY_AUTO; // only allow vertical
        _list.interactionMode = List.INTERACTION_MODE_MOUSE; // disable touch to fire scroll, only allow to use scrollbar and mouse scroll button

        if (showScrollBar) {
            _list.scrollBarDisplayMode = List.SCROLL_BAR_DISPLAY_MODE_FIXED; // always show scrollbar
            _list.verticalScrollBarFactory = createScrollBar;
        } else {
            _list.scrollBarDisplayMode = List.SCROLL_BAR_DISPLAY_MODE_NONE;
        }
        _list.addEventListener(Event.SCROLL, list_scrollHandler);

        // selectable and selected skin
        _list.isSelectable = true;
        _list.allowMultipleSelection = false;
        _list.addEventListener(Event.CHANGE, list_changeHandler);
        _list.itemRendererFactory = tileListItemRendererFactory;

        this.addChild(_list);
        return _list;
    }

    private function createScrollBar():IScrollBar {
        var scrollbarAtlas:Texture = Texture.fromBitmap(new SCROLLBAR_IMAGE(), false);
        var _scrollbar:ScrollBar = new ScrollBar();
        _scrollbar.direction = ScrollBar.DIRECTION_VERTICAL;
        _scrollbar.trackLayoutMode = ScrollBar.TRACK_LAYOUT_MODE_MIN_MAX;

        //skin the scroll bar here
        _scrollbar.thumbFactory = function():Button
        {
            var button:Button = new Button();
            var scrollbar:Texture = Texture.fromTexture(scrollbarAtlas, new Rectangle(0,64,18,29));
            const defaultSkin:Scale3Image = new Scale3Image(new Scale3Textures(scrollbar, 4, 21, Scale3Textures.DIRECTION_VERTICAL));
            defaultSkin.height = 29;
            button.defaultSkin = defaultSkin;
            return button;
        };
        _scrollbar.decrementButtonFactory = function():Button
        {
            var button:Button = new Button();
            var scrollbar:Texture = Texture.fromTexture(scrollbarAtlas, new Rectangle(0,0,18,17));
            button.defaultSkin = new Image( scrollbar );
            return button;
        };
        _scrollbar.incrementButtonFactory = function():Button
        {
            var button:Button = new Button();
            var scrollbar:Texture = Texture.fromTexture(scrollbarAtlas, new Rectangle(0,93,18,17));
            button.defaultSkin = new Image( scrollbar );
            return button;
        };
        _scrollbar.minimumTrackFactory = function():Button
        {
            var button:Button = new Button();
            var scrollbar:Texture = Texture.fromTexture(scrollbarAtlas, new Rectangle(0,17,18,47));
            button.defaultSkin = new Image( scrollbar );
            return button;
        };
        _scrollbar.maximumTrackFactory = function():Button
        {
            var button:Button = new Button();
            var _scrollbar:Texture = Texture.fromTexture(scrollbarAtlas, new Rectangle(0,17,18,47));
            button.defaultSkin = new Image( _scrollbar );
            return button;
        };
        return _scrollbar;
    }

    private function list_changeHandler(event:Event):void
    {
        var _list:List = event.target as List;
//        const selectedIndices:Vector.<int> = _list.selectedIndices;
//        trace("List onChange:", selectedIndices.length > 0 ? selectedIndices : _list.selectedIndex);

        if (_list.selectedIndex >= 0) {
            // when select in one list, auto-deselect in the rest lists
            _multiList.forEach(function(item:*, index:int, arr:Vector.<*>):void {
                if (item != _list) {
                    (item as CustomList).selectedIndex = -1;
                }
            });
        }
    }

    private function list_scrollHandler(event:Event):void {
        var _list:CustomList = event.target as CustomList;
        if (_list.isScrollingDispatched) {
            _list.isScrollingDispatched = false;
            return;
        }
//        trace("scrolling #" + _multiList.indexOf(_list) + " list");

        _multiList.forEach(function(item:*, index:int, arr:Vector.<*>):void {
            var itemList:CustomList = item as CustomList;
            if (itemList != _list) {
                itemList.scrollToPosition(0, _list.verticalScrollPosition);
                itemList.isScrollingDispatched = true;
            }
        });
    }

    protected function tileListItemRendererFactory():IListItemRenderer {
        var renderer:DefaultListItemRenderer = new DefaultListItemRenderer();

        renderer.labelField = "label";
        var tf:TextFormat = FeathersPropsUtils.createNativeTextFormat();
        renderer.labelFactory = function():ITextRenderer {
            var textRenderer:TextFieldTextRenderer = new TextFieldTextRenderer();
            textRenderer.textFormat = tf;
            return textRenderer;
        };

//        renderer.accessoryField = "label";
//        renderer.accessoryFunction = function( item:Object ):DisplayObject {
//            var accessory:DisplayObject = makeCellLabel(
//            cachedAccessories[item] = accessory;
//            return accessory;
//         };
//        renderer.iconSourceField = "texture";
//        renderer.iconPosition = Button.ICON_POSITION_TOP;
        renderer.isQuickHitAreaEnabled = true; // similar to mouseChildren, if true, children cannot dispatch touch events

        renderer.defaultSkin = new Quad(10, 10, Color.rgb(0xFF, 0xFF, 0xCC));
        renderer.defaultSelectedSkin = new Quad(10, 10, Color.rgb(0xFF,0xFF,0x00));
        // to ensure left alignment under list's JUSTIFY layout
        renderer.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_LEFT;
        return renderer;
    }

    protected function stage_resizeHandler(event:ResizeEvent):void
    {
        this.layout();
    }

    private function createBorder(color:uint, bound:Rectangle):Quad {
        var border:Quad = new Quad(bound.width, bound.height, color);
        border.x = bound.x;
        border.y = bound.y;
        addChild(border);
        return border;
    }
}
}

import feathers.controls.List;

class CustomList extends List {
    public var isScrollingDispatched:Boolean = false;

//    override protected function nativeStage_mouseWheelHandler(event:MouseEvent):void {
//    }
}
