/**
 * Created with IntelliJ IDEA.
 * User: DarrenFu
 * Date: 11/27/13
 * Time: 1:47 PM
 * To change this template use File | Settings | File Templates.
 */
package {
import com.pogo.game.chess2.client.ChessGamePanel;
import com.pogo.game.chess2.common.ChessBoardAndLogic;
import com.pogo.ui.FontDefinition;
import com.pogo.ui.starling.FeathersPropsUtils;
import com.pogo.ui.starling.ImageSprite;
import com.pogo.ui.starling.feathers.Button;
import com.pogo.ui.starling.gf1.MultiList;
import com.pogo.ui.starling.gf1.MultiListRowDisplay;
import com.pogo.ui.starling.gf1.Panel;
import com.pogo.ui.starling.gf1.ScrollBarConfig;
import com.pogo.util.RandomGenerator;

import feathers.controls.text.TextFieldTextRenderer;
import feathers.core.ITextRenderer;

import flash.geom.Rectangle;
import flash.text.TextFormat;

import starling.display.Image;
import starling.events.Event;
import starling.textures.Texture;
import starling.utils.Color;

public class ChessMultiListDemo extends Panel {

    [Embed(source="images/chess_scrollbar.png")]
    private static const SCROLLBAR_IMAGE:Class;

    [Embed(source="../../pogo/games/chess2/texture_assets/chess2_assets_1.png")]
    private static const ATLAS_IMAGE:Class;

    private static var ATLAS:Texture = Texture.fromBitmap(new ATLAS_IMAGE());

    private var list:MultiList;
    private var display:MultiListRowDisplay;

    private var historyEmailButton:Button;
    private var prevButton:Button;
    private var nextButton:Button;
    private var addButton:Button;
    private var minButton:Button;
    private var nextColor:int;
    private var selectedMove:int;

    private static const COLUMN_NUMBER:int=	0;
    private static const COLUMN_WHITE:int=		1;
    private static const COLUMN_BLACK:int=		2;

    private static const TB_MARGIN:int= 0;
    private static const COLUMN_MARGIN:int= 2;
    private static const BUTTON_MARGIN:int= 4;
    private static const LABEL_MARGIN:int= 8;
    private static const PIECES_MARGIN:int= 0;
    private static const PIECE_ADJUST:int= 6;

    private static const REGULAR_EMAIL_BUTTON:int= 0;
    private static const DISABLED_EMAIL_BUTTON:int= 1;

    private static const SELECT_BACKGROUND:uint= Color.rgb(0xFF,0xFF,0x00),
            SELECT_FOREGROUND:uint = Color.rgb(0x00,0x33,0x66),
            COLOR_LIGHT_PURPLE:uint = Color.rgb(0xCC, 0x99, 0x99),
            COLOR_MEDIUM_PURPLE:uint = Color.rgb(0x99, 0x66, 0x66),
            COLOR_DARK_PURPLE:uint = Color.rgb(0x66, 0x33, 0x33),
            COLOR_LIGHT_TAN:uint = Color.rgb( 0xFF, 0xFF, 0xCC);

    public function ChessMultiListDemo() {
        nextColor = ChessBoardAndLogic.WHITE_PLAYER_ID;
        selectedMove = -1;


        addChild(new Image(Texture.fromTexture(ATLAS, new Rectangle(567, 480, 165, 189))));

        prevButton = createButton(ChessGamePanel.RECT_BACK_NORMAL, ChessGamePanel.RECT_BACK_PRESSED, ChessGamePanel.RECT_BACK_DISABLED);
        nextButton = createButton(ChessGamePanel.RECT_FWD_NORMAL, ChessGamePanel.RECT_FWD_PRESSED, ChessGamePanel.RECT_FWD_DISABLED);
        addButton = createButton(new Rectangle(590, 0, 17, 18), new Rectangle(590, 18, 17, 18), new Rectangle(590, 36, 17, 18));
        minButton = createButton(new Rectangle(607, 0, 17, 18), new Rectangle(607, 18, 17, 18), new Rectangle(607, 36, 17, 18));
        prevButton.y = nextButton.y = addButton.y = minButton.y = 165;
        prevButton.x = 35;
        nextButton.x = prevButton.x + 40;
        addButton.x = nextButton.x + 47;
        minButton.x = addButton.x + 20;
        addChild(prevButton);
        addChild(nextButton);
        addChild(addButton);
        addChild(minButton);

        prevButton.addEventListener( Event.TRIGGERED, actionHandler );
        nextButton.addEventListener( Event.TRIGGERED, actionHandler );
        addButton.addEventListener( Event.TRIGGERED, actionHandler );
        minButton.addEventListener( Event.TRIGGERED, actionHandler );

//        this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
        addedToStageHandler(null);
    }

    protected function addedToStageHandler(event:Event):void
    {
//        this.removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
        list = new MultiList(3, false, true);
		list.setPreferredDisplayedRows(6);
        list.height = 18 * list.getPreferredDisplayedRows() + 2;
//		list.setFillColumn(-1);
//		list.setBackground( COLOR_LIGHT_TAN );
        display = list.getRowDisplay();
        display.setRowHeight(int(110 / list.getPreferredDisplayedRows()));
//		display.sort(-1);

        // scrollbar
        var scrollConfig:ScrollBarConfig = new ScrollBarConfig();
        scrollConfig.textureAtlas = Texture.fromBitmap(new SCROLLBAR_IMAGE());
        scrollConfig.thumbBound = new Rectangle(0,64,18,29);
        scrollConfig.decrementButtonBound = new Rectangle(0,0,18,17);
        scrollConfig.decrementButtonDownBound = new Rectangle(18,0,18,17);
        scrollConfig.incrementButtonBound = new Rectangle(0,93,18,17);
        scrollConfig.incrementButtonDownBound = new Rectangle(18,93,18,17);
        scrollConfig.minimumTrackBound = new Rectangle(0,17,18,46);
        scrollConfig.maximumTrackBound = new Rectangle(0,17,18,46);
        scrollConfig.minimumTrackDisabledBound = new Rectangle(0,17,18,46);
        scrollConfig.maximumTrackDisabledBound = new Rectangle(0,17,18,46);
        display.scrollConfig = scrollConfig;
//		list.getScrollbar().setBackground( COLOR_LIGHT_PURPLE );
//		list.getScrollbar().setColorScheme( HISTORY_COLORSCHEME );

        // selection
        display.setSelectionBackground( SELECT_BACKGROUND );
//		display.setSelectionForeground( SELECT_FOREGROUND );
        display.setSelectable(true);
        display.setColumnSelectable(false, COLUMN_NUMBER);

        // border
//        list.setHasBorder(true);
//        display.setColumnBorder(true, COLUMN_NUMBER);
//        display.setColumnBorder(true, COLUMN_WHITE);
//        display.setBorderColor(Panel.COLOR_BLACK);

        var tf:TextFormat = FeathersPropsUtils.createNativeTextFormat(new FontDefinition("Helvetica", 0, 11/*, SELECT_FOREGROUND*/));
        display.cellLabelFactory = function():ITextRenderer {
            var textRenderer:TextFieldTextRenderer = new TextFieldTextRenderer();
            textRenderer.textFormat = tf;
            return textRenderer;
        };
        list.resizeHandler = resizeList;
        list.listChangeHandler = handleMoveSelected;
        addChild(list);

        list.x = 2;
        list.y = 49;
    }

    private function resizeList():void {
//        for (var i:int = 0; i <= list.getPreferredDisplayedRows(); i ++) {
        display.addTypicalRow(["188. ", "g8-g8(Q)+ ", "g8-g8(Q)+ "]);
//        display.setColumnWidth(0, 25);
//        display.setColumnWidth(1, 58);
//        display.setColumnWidth(2, 58);
//        }
        list.layout();
        display.clear();
    }

    private function handleMoveSelected(/*event:Event*/):void {
//		var row:int= display.getSelectedRowIndex();
//		var col:int= display.getSelectedColumnIndex();
        var selectedCellIdx:Array = display.getSelectedCellIndex();
        var row:int = selectedCellIdx[0];
        var col:int = selectedCellIdx[1];
        trace("handleMoveSelected [rxc]", row, col, "nextColor:", nextColor, "selectedMove:", selectedMove);
        var lastRow:int= display.getRowCount() - 1;

        // Fudge selection if appropriate...
        if (lastRow >= 0&& row >= 0) {
            if (col == COLUMN_NUMBER ||
                    (row == lastRow && col == COLUMN_BLACK &&
                            nextColor == ChessBoardAndLogic.BLACK_PLAYER_ID))
            {
                display.selectCell(row, COLUMN_WHITE);
                return;
            }
        }

        var oldSelectedMove:int= selectedMove;

        if (lastRow < 0|| row < 0||
                (row == lastRow &&
                        (col < 0|| col == COLUMN_BLACK ||
                                nextColor == ChessBoardAndLogic.BLACK_PLAYER_ID)))
        {
            selectedMove = -1;
        }
        else {
            selectedMove = (row * 2) + (col - 1);
        }

        if (selectedMove != oldSelectedMove) {
            if (selectedMove < 0) {
//                chessPanel.historyToLatest();
                selectLastMove();
            } else {
//                chessPanel.historyTo(selectedMove + 1);
                selectMove(selectedMove + 1 - 1);
            }
            updateButtons();
        }
        trace("handleMoveSelected2", "      selectedMove:", selectedMove);
    }

    public function addMove(move:String):void {
        trace("---------- new move: "+move + " --------------");
        var wasSelected:Boolean= (selectedMove < 0);
        if (nextColor == ChessBoardAndLogic.WHITE_PLAYER_ID) {
            var row:Array = new Array(3);
            var rowNumber:int= display.getRowCount() + 1;
            row[COLUMN_NUMBER] = rowNumber + ".";
            row[COLUMN_WHITE] = move;
			row[COLUMN_BLACK] = "";
            display.addRow(row);
        } else {
//			var row:Array= display.getRow(display.getRowCount() - 1);
//          row.getCell(COLUMN_BLACK).setData(move);
//            display.push(move);
            display.setCell(move, display.getRowCount() - 1, COLUMN_BLACK);
        }

        nextColor = 1- nextColor;

//        var client:ChessClient= ChessClient(chessPanel.getClient());
        if (wasSelected/* || !client.isWatcher()*/) {
            selectLastMove();
        }

//		list.inval();
        updateButtons();
    }

    public function removeLastMove():void {
        var wasSelected:Boolean= (selectedMove < 0);
        var lastRow:int= display.getRowCount() - 1;
        if (lastRow >= 0) {
//			var row:Array= display.getRow(lastRow);
            if (nextColor == ChessBoardAndLogic.BLACK_PLAYER_ID) {
//				display.removeRow(row);
                display.removeRow(lastRow);
            } else {
//				row.getCell(COLUMN_BLACK).setData("");
//                display.pop();
                display.setCell("", lastRow, COLUMN_BLACK);
//				display.invalRow(row);
            }

            nextColor = 1- nextColor;

            if (wasSelected) {
                selectLastMove();
            }

            updateButtons();
        }
    }

    public function removeAllMoves():void {
        nextColor = ChessBoardAndLogic.WHITE_PLAYER_ID;
        selectedMove = -1;
        display.clear();
        updateButtons();
    }

    public function countMoves():int {
        var moves:int= display.getRowCount() * 2;
        if (moves > 0&& nextColor == ChessBoardAndLogic.BLACK_PLAYER_ID) {
            moves--;
        }
        return moves;
    }

    public function isLastMoveSelected():Boolean {
        return (selectedMove < 0);
    }

    public function selectLastMove():void {
        var lastRow:int= display.getRowCount() - 1;
        trace("selectLastMove: " + lastRow);
        if (lastRow >= 0) {
            display.selectCell(lastRow, (nextColor == ChessBoardAndLogic.BLACK_PLAYER_ID) ?
                    COLUMN_WHITE : COLUMN_BLACK);
//			display.scroll(lastRow);
            display.scrollToEnd();
        }
    }

    public function selectPreviousMove():void {
        if (selectedMove < 0) {
            var moves:int= countMoves();
            if (moves > 1) {
                selectMove(moves - 2);
            }
        }
        else if (selectedMove > 0) {
            selectMove(selectedMove - 1);
        }
    }

    public function selectNextMove():void {
        if (selectedMove >= 0) {
            selectMove(selectedMove + 1);
        }
    }

    public function selectMove(move:int):void {
        if (move < 0|| move >= (countMoves() - 1)) {
            move = -1;
        }
        trace("selectMove:", move);
        if (move != selectedMove) {
            if (move < 0) {
                selectLastMove();
            } else {
                display.selectCell(int(move / 2), move % 2+ 1);
                display.scroll(int(move / 2));
            }
        }
    }

    public function actionHandler(event:Event):void {
        var target:Button= event.target as Button;
        if (target == prevButton) {
            selectPreviousMove();
        } else if (target == nextButton) {
            selectNextMove();
        } else if (target == addButton) {
            //g8-g8(Q)+
            const SIZE:int = 8;
            var randomMove:String = String.fromCharCode(RandomGenerator.instance().nextInt(SIZE) + 97) +
                    (RandomGenerator.instance().nextInt(SIZE) + 1) +
                    (RandomGenerator.instance().nextBoolean() ? "-" : "x") +
                    String.fromCharCode(RandomGenerator.instance().nextInt(SIZE) + 97) +
                    (RandomGenerator.instance().nextInt(SIZE) + 1) +
                    (RandomGenerator.instance().nextInt(10) > 8 ? "(Q)" : "") +
                    (RandomGenerator.instance().nextInt(5) > 3 ? "+" : "");
            addMove(randomMove);
            if (!minButton.isEnabled) {
                minButton.enable();
            }
        } else if (target == minButton) {
            removeLastMove();
            var toEnable:Boolean = countMoves() > 0;
            if (minButton.isEnabled != toEnable) {
                minButton.enable(toEnable);
            }
        }
    }

    private function updateButtons():void {
        if (countMoves() < 2) {
            prevButton.disable();
            nextButton.disable();
        } else {
            prevButton.enable(selectedMove != 0);
            nextButton.enable(selectedMove >= 0);
        }
    }

    public static function createButton(upSubRect:Rectangle, downSubRect:Rectangle, disabledSubRect:Rectangle):Button {
        var b:Button = new Button();
        upSubRect.x += 2;
        upSubRect.y += 2;
        var up:ImageSprite = new ImageSprite(ATLAS, upSubRect);
        b.defaultSkin = up;

        downSubRect.x += 2;
        downSubRect.y += 2;
        var down:ImageSprite = new ImageSprite(ATLAS,downSubRect);
        b.downSkin = down;

        disabledSubRect.x += 2;
        disabledSubRect.y += 2;
        var disabled:ImageSprite = new ImageSprite(ATLAS, disabledSubRect);
        b.disabledSkin = disabled;

        return b;
    }
}
}

