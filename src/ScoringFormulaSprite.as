//
// (c) 2007 Electronic Arts Inc.
//
package {
import com.pogo.game.domino2.client.*;


import com.pogo.game.domino2.common.DominoBoardZone;
import com.pogo.game.domino2.common.DominoCommonLogic;
import com.pogo.game.domino2.common.DominoTile;
import com.pogo.game.domino2.common.DominoTileBoardPlacement;
import com.pogo.ui.PropsCoreUtils;
import com.pogo.ui.starling.StarlingImageStripSprite;
import com.pogo.ui.starling.StarlingPropsUtils;
import com.pogo.ui.starling.StarlingSprite;
import com.pogo.ui.starling.text.LabelSprite;
import com.pogo.ui.starling.text.SimpleTextSprite;
import com.pogo.util.Properties;
import com.pogo.util.VectorUtils;

import flash.display.Bitmap;

import flash.display.BitmapData;
import flash.geom.Rectangle;

import starling.textures.Texture;

/**
 * @author <a href="mailto:hshah@ea.com">Hemal Shah</a>
 * Aug 14, 2007
 */
public class ScoringFormulaSprite extends StarlingSprite {
	private var mEndTiles:Vector.<DominoTile>;
	private var mEndRanks:Vector.<int>;
	private var mDominoSprites:Vector.<StarlingSprite>;
	private var mTileSumLabel:LabelSprite;
	private var mBackPanelSprite:StarlingSprite;
	private var mZoneSprite:StarlingImageStripSprite;
	private var mActivatedScoringZone:DominoBoardZone;
			
	private var mSpacing:int;
	private var mScoringCode:int;
	
	private var mMaxElementHeight:int;
	
	public function ScoringFormulaSprite(
										endTiles:Vector.<DominoTile>,							
										scoringCode:int, 										
										endRanks:Vector.<int>, 
										activatedZone:DominoBoardZone, 
										sumValue:int) {
		mEndTiles = endTiles;
		mEndRanks = endRanks;			
		mSpacing = 4;//PropsCoreUtils.makeInt(mServices.getProperties(), "dom.anim.scoring.formula.spacing");
		mMaxElementHeight = 0;
		mScoringCode = scoringCode;
		
		createBackground();
		
		if (!DominoAnimationFactory.isZoneOnlyScoringCode(scoringCode)) {																		
//			createDominoTiles();
//			createScoreSumLabel(sumValue);
		} 
										
		
		
		
		if (scoringCode != DominoAnimationFactory.SCORING_CODE_TILES_ONLY) {
			mActivatedScoringZone = activatedZone;
			createBoardZoneSprite();
		}
								
		layoutEquation();			
	}
	
	
	private function createBackground():void {
		// Backpanel
//		var backPanelKey:String= "dom.anim.scoring.formula.back";
//		var backPanelRaster:Texture= mServices.getRaster(backPanelKey);
//
//		if (backPanelRaster != null) {
//			mBackPanelSprite = StarlingPropsUtils.makeImage(props(), backPanelRaster, backPanelKey);
//			add(mBackPanelSprite);
//		}
	}
	
	private function createBoardZoneSprite():void {				
//		var zoneRaster:BitmapData = (new DominoScoringAnim.boardZone() as Bitmap).bitmapData;//mServices.getBitmap("dom.anim.scoring.formula.zone");
//		mZoneSprite = makeImageStrip(null, zoneRaster, "dom.anim.scoring.formula.zone");
//		var row:int= 4;//DominoBoardZoneSprite.getZoneImageRow(null, mActivatedScoringZone);
//        mZoneSprite.row = row;
//
//		// WARNING: For Mystery Zone, the image does NOT have the values, so anything but
//		// image index 0 here will be a blank square. The reveal mystery tile animation
//		// will reset this image index back to 0 no matter what, and then animate
//		// to the correct image frame in another image
//        //TODO
//		var image:int= 1;//DominoBoardZoneSprite.getZoneImageIndex(mActivatedScoringZone, true);
//		mZoneSprite.index = image;
//		add(mZoneSprite);
//
//		mMaxElementHeight = Math.max(mMaxElementHeight, mZoneSprite.getHeight());
	}


    public static function makeImageStrip(p:Properties, bitmap:BitmapData, prefix:String):StarlingImageStripSprite {
        var s:StarlingImageStripSprite = new StarlingImageStripSprite(prefix, bitmap);
        var bounds:Rectangle = new Rectangle(0,0,45,45);//PropsUtils.makeRectWithProperties(p, prefix);
        if (bounds != null) {
            s.setBoundsFromRectangle(bounds);
        }

        var strip:Rectangle = new Rectangle(0,0,45,45);//PropsUtils.makeRectWithProperties(p, prefix + ".strip");
        if (strip != null) {
            // NOTE: In the Java implementation, the following line of code was actually a
            //       call to the sprite's setStrip() method (not the setBounds() method).
//			s.setBounds(strip.x, strip.y, strip.width, strip.height);
            s.stripRect = strip;
            if (bounds == null) {
                s.setSize(strip.width, strip.height);
            }
        }

//        var gapKey:String = prefix + ".strip.gap";
//        if (p.getProperty(gapKey) != null) {
//            var gap:Vector.<int> = PropsCoreUtils.makeIntArrayWithProperties(p, gapKey);
//            s.hGap = gap[0];
//            s.vGap = gap[1];
//        }

//        if (p.containsKey(prefix + ".index")) {
//            s.index = PropsCoreUtils.makeInt(p, prefix + ".index");
//        }

        //NOT KNOWN TO BE USED IN MONOPOLY
        /*var layerString:String = p.getProperty(prefix + ".layer");
         if (layerString!=null){
         s.setLayer(PropsCoreUtils.parseDouble(layerString));
         }*/
        return s;
    }
	
//	private function createDominoTiles():void {
//		var logic:DominoCommonLogic= mServices.getLogic();
//		var dominoFormulaTileSprites:Vector.<StarlingSprite>= new Vector.<StarlingSprite>();
//		var lastTile:DominoTile= null;
//
//		var uniqueTiles:int= 0;
//		// determind if we have one, or more tiles are participating in this scoring formula
//		for (var chainId:int= 0; chainId < mEndTiles.length; chainId++) {
//			var tile:DominoTile= mEndTiles[chainId];
//			if (null != tile) {
//				if (null != lastTile){
//					if (lastTile == (tile)) {
//						// this tile is the same as the revious one
//						continue;
//					} else {
//						uniqueTiles++;
//					}
//				} else {
//					lastTile = tile;
//					uniqueTiles++;
//				}
//			}
//		}
//
//		// This if statement is meant to handle the case in which the first tile to be played is
//		// a scoring tile (5:5, 1:4, 0:5, 2:3, 6:4) (bug 112249, 112349).
//		if (uniqueTiles == 1) {
//			// this case will essetially only handle the 5:5 case
//			if (lastTile.isDouble()) {
//				var dominoSprite:StarlingSprite= createTileForFormula(lastTile, -1, false);
//				mMaxElementHeight = Math.max(dominoSprite.getHeight(), mMaxElementHeight);
//				dominoFormulaTileSprites.push(dominoSprite);
//				add(dominoSprite);
//			} else {
//				// make 2 half sprites, one for each half of the single tile that is scoring
//				var dominoSprite:StarlingSprite= createTileForFormula(lastTile, lastTile.getLowNumber(), true);
//				mMaxElementHeight = Math.max(dominoSprite.getHeight(), mMaxElementHeight);
//				dominoFormulaTileSprites.push(dominoSprite);
//				add(dominoSprite);
//				dominoSprite = createTileForFormula(lastTile, lastTile.getHighNumber(), true);
//				mMaxElementHeight = Math.max(dominoSprite.getHeight(), mMaxElementHeight);
//				dominoFormulaTileSprites.push(dominoSprite);
//				add(dominoSprite);
//			}
//		} else {
//			// more than one tile participating in scoring animation
//			for (var chainId:int= 0; chainId < mEndTiles.length; chainId++) {
//				var dominoSprite:StarlingSprite= null;
//				var tile:DominoTile= mEndTiles[chainId];
//
//				if (null == tile) {
//					continue;
//				}
//
//				if (tile.isDouble() && logic.isEndDominoPlayedAsDouble(chainId)) {
//					dominoSprite = createTileForFormula(tile, -1, false);
//				} else {
//					dominoSprite = createTileForFormula(tile, mEndRanks[chainId], true);
//				}
//				mMaxElementHeight = Math.max(dominoSprite.getHeight(), mMaxElementHeight);
//				dominoFormulaTileSprites.push(dominoSprite);
//				add(dominoSprite);
//			}
//		}
//		mDominoSprites = new Vector.<StarlingSprite>(dominoFormulaTileSprites.length);
//		VectorUtils.copyInto(dominoFormulaTileSprites, mDominoSprites);
//	}
	
//	private function createTileForFormula(tile:DominoTile, endRank:int, halfTile:Boolean):StarlingSprite {
//		var tileSpriteManager:DominoTileSpriteManager= mServices.getGamePanel().getTileSpriteManager();
//		var dominoSprite:StarlingSprite;
//		if (!halfTile) {
//			var dominoTileSprite:DominoTileSprite= tileSpriteManager.createDominoTileSpriteByDominoSet(tile,
//				DominoTileSpriteManager.DOMINO_HAND_PROFILE, DominoTileSpriteManager.DEFAULT_DOMINO_TILESET);
//			dominoTileSprite.setOrientation(DominoTileBoardPlacement.ORIENTATION_NORTH);
//			dominoSprite = dominoTileSprite;
//		} else {
//			var halfTileSprite:DominoHalfTileSprite= tileSpriteManager.createHalfDominoSprite(
//					endRank,
//					DominoTileSpriteManager.DEFAULT_DOMINO_TILESET);
//			dominoSprite = halfTileSprite;
//		}
//		return dominoSprite;
//
//	}
	
//	private function createScoreSumLabel(sumValue:int):void {
//
//        var mTileSumLabel:SimpleTextSprite = StarlingPropsUtils.makeText(mServices.getProperties(),
//                DominoClientConfig.FONT_RASTER_TILESUM, "dom.anim.scoring.formula.sum");
//        mTileSumLabel.setText(String(sumValue));
//
//		add(mTileSumLabel);
//	}
					
	private function layoutEquation():void {
		var x:int= 0;			
		var height:int= mMaxElementHeight;
		var halfHeight:int= height / 2;
		
		if (mDominoSprites != null && mDominoSprites.length > 0) {
			
			if (hasScoreMultiplier()) {
				// add open parenthesis
				var symbolSprite:StarlingSprite= makeMathSymbolSprite('(');
				add(symbolSprite);
				symbolSprite.setOrigin(x, halfHeight - symbolSprite.getHeight() / 2);					 
				x += symbolSprite.getWidth();
				x += mSpacing;
			}
		
			for (var index:int= 0; index < mDominoSprites.length; index++) {
				var dominoSprite:StarlingSprite= mDominoSprites[index];
				if (null == dominoSprite) {
					continue;
				}
				
				dominoSprite.setOrigin(x, halfHeight - dominoSprite.getHeight() / 2);
				
				x += dominoSprite.getWidth();				
				
				// not the last
				if (index != mDominoSprites.length - 1) {
					 x += mSpacing;
					 var symbolSprite:StarlingSprite= makeMathSymbolSprite('+');
					 add(symbolSprite);
					 symbolSprite.setOrigin(x, halfHeight - symbolSprite.getHeight() / 2);					 
					 x += symbolSprite.getWidth();
					 x += mSpacing;
				}
			}

			if (hasScoreZone()) {
				if (hasScoreBonus()) {
					// add board zone with +
					x += mSpacing;				
					var symbolSprite:StarlingSprite= makeMathSymbolSprite('+');
					add(symbolSprite);
					symbolSprite.setOrigin(x, halfHeight - symbolSprite.getHeight() / 2);					 
					x += symbolSprite.getWidth();
					
				} else if (hasScoreMultiplier()) {
					// add closing parentheses
					x += mSpacing;				
					var paranthesesSprite:StarlingSprite= makeMathSymbolSprite(')');
					add(paranthesesSprite);
					paranthesesSprite.setOrigin(x, halfHeight - paranthesesSprite.getHeight() / 2);					 
					x += paranthesesSprite.getWidth();
					
					// add multiplier symbol
					x += mSpacing;				
					var multiplierSprite:StarlingSprite= makeMathSymbolSprite('*');
					add(multiplierSprite);
					multiplierSprite.setOrigin(x, halfHeight - multiplierSprite.getHeight() / 2);					 
					x += multiplierSprite.getWidth();
				}
			}						
			x += mSpacing;
		}

		// add board zone
		if (hasScoreZone()) {
			mZoneSprite.setOrigin(x, halfHeight - mZoneSprite.getHeight() / 2);
			x += mZoneSprite.getWidth();
		}
							
		if (!DominoAnimationFactory.isZoneOnlyScoringCode(mScoringCode)) {
			x += mSpacing;
			// add the equals sign
            //TODO
//			var symbolSprite:StarlingSprite= makeMathSymbolSprite('=');
//			add(symbolSprite);
//			symbolSprite.setOrigin(x, halfHeight - symbolSprite.getHeight() / 2);
//			x += symbolSprite.getWidth();
//			x += mSpacing;
			
			// add tile sum
//			mTileSumLabel.setOrigin(x, halfHeight - mTileSumLabel.getHeight() / 2);
//			x += mTileSumLabel.getWidth();
		}
		
		setSize(x, mMaxElementHeight);
		
		// center back panel
		if (mBackPanelSprite != null) {
			mBackPanelSprite.setOrigin(	getWidth() / 2- mBackPanelSprite.getWidth() / 2,
										getHeight() / 2- mBackPanelSprite.getHeight() / 2);
		}
	}
	
	private function makeMathSymbolSprite(symbolChar:String):StarlingSprite {
		/*
        var fontRaster:FontRaster= mServices.getFontRaster(DominoClientConfig.FONT_RASTER_TILESUM);
		var symbolSprite:LabelSprite= new LabelSprite(fontRaster, String.valueOf(symbolChar));
		symbolSprite.setAlignment(0.5, 0.5);
		symbolSprite.setSize(symbolSprite.getTextWidth(), symbolSprite.getTextHeight());
         */

        var symbolSprite:SimpleTextSprite = SimpleTextSprite.buildSimpleTextSprite(symbolChar,DominoClientConfig.FONT_RASTER_TILESUM);
        symbolSprite.setAlignment(0.5,0.5);
        symbolSprite.setSize(symbolSprite.textWidth,symbolSprite.textHeight);

        add(mTileSumLabel);

		return symbolSprite;			
	}
	
	private function hasScoreZone():Boolean {
		return mScoringCode != DominoAnimationFactory.SCORING_CODE_TILES_ONLY;
	}
	
	private function hasScoreMultiplier():Boolean {
		return mScoringCode == DominoAnimationFactory.SCORING_CODE_TILES_PLUS_MULTIPLIER;
	}
	
	private function hasScoreBonus():Boolean {
		return mScoringCode == DominoAnimationFactory.SCORING_CODE_BONUS_ONLY || 
				mScoringCode == DominoAnimationFactory.SCORING_CODE_TILES_PLUS_BONUS ||
				mScoringCode == DominoAnimationFactory.SCORING_CODE_TILES_PLUS_MYSTERY_BONUS;
	}	
	
	public function getTileSumLabel():LabelSprite {
		return mTileSumLabel;
	}
	
	public function getZoneSprite():StarlingImageStripSprite {
		return mZoneSprite;
	}		
	
//	private function props():Properties {
//		return mServices.getProperties();
//	}
}
}

