/**
 * Created with IntelliJ IDEA.
 * User: dgrossen
 * Date: 8/7/13
 * Time: 9:24 AM
 * To change this template use File | Settings | File Templates.
 */
package {
import com.pogo.game.domino2.client.Domino2Utils;
import com.pogo.game.domino2.common.DominoBoardZone;
import com.pogo.game.domino2.common.DominoTile;
import com.pogo.game.domino2.util.ColoredParticleEmitter;
import com.pogo.game.domino2.util.DominoEmitterTicker;
import com.pogo.game.domino2.util.DominoParticleSprite;
import com.pogo.game.domino2.util.ImageParticleEmitter;
import com.pogo.game.domino2.util.ImageStreakParticleEmitter;
import com.pogo.game.domino2.util.ParticleSprite;
import com.pogo.ui.anim.TickInterpolator;
import com.pogo.ui.anim.TickInterpolatorJavaPort;
import com.pogo.ui.anim.TickableDelay;
import com.pogo.ui.anim.TickableQueue;
import com.pogo.ui.anim.TickableSet;
import com.pogo.ui.anim.TickableTask;
import com.pogo.ui.starling.ImageSprite;
import com.pogo.ui.starling.StarlingAlphaInterpolator;
import com.pogo.ui.starling.StarlingImageStripSprite;
import com.pogo.ui.starling.StarlingLinearSpriteMover;
import com.pogo.ui.starling.StarlingPropsUtils;
import com.pogo.ui.starling.StarlingSprite;
import com.pogo.ui.starling.StarlingTickableTaskUtils;
import com.pogo.util.ITickable;
import com.pogo.util.Properties;
import com.pogo.util.TickManager;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;

import starling.animation.IAnimatable;
import starling.core.Starling;
import starling.extensions.PDParticleSystem;
import starling.extensions.ParticleSystem;
import starling.extensions.pixelmask.PixelMaskDisplayObject;
import starling.textures.Texture;

public class DominoScoringAnim extends StarlingSprite implements IAnimatable {
    [Embed(source="../../webapps/pogo/htdocs/applet/domino2/images/all/include/score_shadow.png")]
    public static const scoreShadow:Class; //dom.anim.scoring.bg.img.ras
    [Embed(source="../../webapps/pogo/htdocs/applet/domino2/images/en/include/e_scored.png")]
    public static const emblem:Class;  //dom.anim.scoring.emblem.local.img.ras
    [Embed(source="../../webapps/pogo/htdocs/applet/domino2/images/en/include/e_scored_sheen_alpha.png")]
    public static const scoreSheemMask:Class;  //dom.anim.scoring.emblem.local.sheen.mask.img.ras
    [Embed(source="../../webapps/pogo/htdocs/applet/domino2/images/all/include/emblem_gradient.png")]
    public static const sheen:Class;  //dom.anim.scoring.emblem.local.sheen.gradient.alpha.img.ras

    [Embed(source="../../webapps/pogo/htdocs/applet/domino2/images/all/include/large_sparkle.png")]
    public static const largeSparkle:Class;  //dom.anim.scoring.tracer.sparkle.img.ras
    [Embed(source="../../webapps/pogo/htdocs/applet/domino2/images/all/include/small_sparkle.png")]
    public static const smallSparkle:Class;  //dom.anim.dominotile.tracer.sparkle.img.ras
    [Embed(source="../../webapps/pogo/htdocs/applet/domino2/images/all/include/dominoe_red.gif")]
    public static const trace:Class; // dom.anim.dominotile.tracer.trace.img.ras
    [Embed(source="../../webapps/pogo/htdocs/applet/domino2/images/en/include/e_scored_red.gif")]
    public static const scoreTrace:Class; // dom.anim.scoring.emblem.tracer.trace.img.ras

    [Embed(source="../../webapps/pogo/htdocs/applet/domino2/images/all/include/score_numbers.png")]
    public static const scoreNums:Class;//dom.anim.scoring.values.img.ras
//    [Embed(source="../../webapps/pogo/htdocs/applet/superdomino/images/all/include/whammies_super.jpg")]
//    public static const boardZone:Class; //dom.anim.scoring.formula.zone.img.ras

    // embed configuration XML
    [Embed(source="particle.pex", mimeType="application/octet-stream")]
    public static const ExplosionConfig:Class;

    public static const FRAME_RATE:int = 30;

    public function DominoScoringAnim() {
        super();

        var scoringAnim:ITickable= makeLocalScoringAnimation(0,
                null,
                null, 0,
                null, 2);
        var tickQueue:TickableQueue = new TickableQueue(true);
        tickQueue.add(scoringAnim);

        //ADDED for local testing
        TickManager.singleton().addTickable(tickQueue);
        Starling.juggler.add(this);
    }

    public function advanceTime(time:Number):void {
        TickManager.singleton().doTick();
    }

    public function makeLocalScoringAnimation(scoreDelta:int,
                                              endTiles:Vector.<DominoTile>,
                                              endRankValues:Vector.<int>,
                                              tileSum:int,
                                              activatedBoardZone:DominoBoardZone,
                                              scoringCode:int = -1):ITickable {

//        if(scoringCode == -1) {
//            var scoringCode:int= determineScoringAnimationCode(scoreDelta, activatedBoardZone, tileSum);
//        }
        // == SETUP
        // Scoring background
        var scoringBgRaster:Texture= Texture.fromBitmap(new scoreShadow());//mServices.getRaster("dom.anim.scoring.bg");
        var scoringBgSprite:ImageSprite= new ImageSprite(scoringBgRaster);

        // "You Score"
        var emblemFadeInStaggerTime:int= 800;//PropsCoreUtils.makeInt(props, "dom.anim.scoring.emblem.fadein.stagger.time.ms");
        var emblemFadeInTime:int= 250;//PropsCoreUtils.makeInt(props, "dom.anim.scoring.emblem.fadein.time.ms");
//        var emblemKey:String= "dom.anim.scoring.emblem" + DominoClientConfig.KEY_PLAYER_LOCAL_SUFFIX;
        var emblemRaster:Texture= Texture.fromBitmap(new emblem());
        var scoringEmblemSprite:ImageSprite= new ImageSprite(emblemRaster);
        scoringEmblemSprite.setVisible(false);
        var emblemSheenMaskRaster:BitmapData= (new scoreSheemMask() as Bitmap).bitmapData;//mServices.getBitmap(emblemKey + ".sheen.mask");

        // emblem tracer animation
        var sparkleRaster:Texture= Texture.fromBitmap(new largeSparkle());//.getRaster("dom.anim.scoring.tracer.sparkle");

        var traceRaster:BitmapData= (new scoreTrace() as Bitmap).bitmapData;//mServices.getBitmap("dom.anim.scoring.emblem.tracer.trace");
        var emblemTracerAnimSprite:SparkleTracerAnimSprite= SparkleTracerAnimSprite.makeSparkleTracerSpriteWithTraceSubRectForScoring(
                null,
                sparkleRaster, traceRaster, null, FRAME_RATE,
                null);
        emblemTracerAnimSprite.setOrigin(scoringEmblemSprite.getX(), scoringEmblemSprite.getY());
        var numEmblemSparkles:int= emblemTracerAnimSprite.getNumTracers();

        // Particle emitter
//        var particleStreakPercent:Number= 0.6;//PropsCoreUtils.makeDouble(props, "dom.anim.scoring.particle.streak.percent");
//
        var particleRaster:Texture = Texture.fromBitmap(new smallSparkle());//mServices.getRaster("dom.anim.scoring.particle");
//        var particleRect:Rectangle= new Rectangle(0,0, particleRaster.width, particleRaster.height);
//        var particleSprite:ParticleSprite= new DominoParticleSprite();
//        particleSprite.setBoundsFromRectangle(scoringBgSprite.bounds);

        var emitterArray:Vector.<Point> = new Vector.<Point>(numEmblemSparkles);
//        for(var i:int= 0; i < numEmblemSparkles; i++) {
//
//            emitterArray[i] = new ImageStreakParticleEmitter(
//                    particleSprite,
//                    particleRaster,
//                    new <Rectangle>[particleRect],
//                    particleStreakPercent
//            );
//            //emitterArray[i].setBlendMode(Sprite.BLEND_USE_SOURCE);
//            configureEmitter(
//                    null,
//                    emitterArray[i],
//                    "dom.anim.scoring.particle",
//                    FRAME_RATE);
//        }
//
        var emitterOffset:Point= new Point(scoringEmblemSprite.getX(), scoringEmblemSprite.getY());
//
//        /*****************************/
        var tracerLocations:Vector.<Point>= emblemTracerAnimSprite.getTracerLocations();

        for(var i:int=0; i<tracerLocations.length; i++) {
            emitterArray[i] = new Point(emitterOffset.x + tracerLocations[i].x, emitterOffset.y + tracerLocations[i].y);
        }

        //TODO: create a particle system
        var psConfig:XML = XML(new ExplosionConfig());

        // create particle system
//        particleRaster = Texture.fromBitmap(new largeSparkle());
        var ps:ParticleSystem = new DominoParticleSystem(psConfig, particleRaster, emitterArray, numEmblemSparkles);
        var particleSprite:DominoParticleContainer = new DominoParticleContainer(ps);
        particleSprite.setBoundsFromRectangle(scoringBgSprite.bounds);

        var tickFunction:Function = function() {
            Starling.juggler.add(ps);
            ps.start(.5);
        };
        var cancelFunction:Function = function() {
//            Starling.juggler.remove(ps);
            ps.stop();
        };
        var  emitterTick:ITickable = new EmitterTicker(tickFunction, cancelFunction);
        /*****************************/


        var messageSprites:Vector.<StarlingSprite>= null;

//        if (scoringCode == SCORING_CODE_TILES_ONLY) {
            // scoring value
            var scoringValueRaster:BitmapData= (new scoreNums() as Bitmap).bitmapData;//mServices.getBitmap("dom.anim.scoring.values");
//            var scoringValuesStripSprite:StarlingImageStripSprite= StarlingPropsUtils.makeImageStrip(null,
//                    scoringValueRaster, "dom.anim.scoring.values");
//            // if scored with only board zone and not domino tiles
//            scoringValuesStripSprite.index = (scoreDelta / 5) - 1;
//            scoringValuesStripSprite.setVisible(false);

            messageSprites = new <StarlingSprite>[
                scoringEmblemSprite/*,
                scoringValuesStripSprite*/];
//        } else {
//            messageSprites = new <StarlingSprite>[scoringEmblemSprite];
//        }

        //tile sprites
        var formulaFadeInTime:int= 500;//PropsCoreUtils.makeInt(props, "dom.anim.scoring.formula.fadein.time.ms");
        var scoringFormulaSprite:ScoringFormulaSprite= new ScoringFormulaSprite(
                endTiles, scoringCode, endRankValues, activatedBoardZone, tileSum);

//        var formulaCenterPtKey:String= "dom.anim.scoring.formula.center"  + DominoClientConfig.KEY_PLAYER_LOCAL_SUFFIX;
        var formulaCenterPt:Point= new Point(285,241);
//        if (!props.containsKey(formulaCenterPtKey + gScoringCodeSuffixes[scoringCode] + ".pt")) {
//            formulaCenterPt = PropsUtils.makePointWithProperties(props, formulaCenterPtKey);
//        } else {
//            formulaCenterPt = PropsUtils.makePointWithProperties(props, formulaCenterPtKey + gScoringCodeSuffixes[scoringCode]);
//        }
        scoringFormulaSprite.setOrigin(formulaCenterPt.x - scoringFormulaSprite.getWidth() / 2,
                formulaCenterPt.y - scoringFormulaSprite.getHeight() / 2);



        var delayTime:int=1500;// PropsCoreUtils.makeInt(mServices.getProperties(), "dom.anim.scoring.time.ms");

        // === SCRIPT

        // phase 1: tracer animation
        var linkBgSpriteTick:ITickable= Domino2Utils.createLinkTask(
                this,
                scoringBgSprite, -1,
                false);

        var linkParticleSprite:ITickable= Domino2Utils.createLinkTask(
                this,
                particleSprite, -1,
                false);

        var tracerFadeOutTime:int= 450;//PropsCoreUtils.makeInt(props, "dom.anim.scoring.emblem.tracer.fadeout.time.ms");
        var tracerFadeOutStagger:int= 1050;//PropsCoreUtils.makeInt(props, "dom.anim.scoring.emblem.tracer.fadeout.stagger.time.ms");
        var fadeOutTracerTick:ITickable=
                makeFadeAnimationBySprite(emblemTracerAnimSprite, false, tracerFadeOutTime);
        var tracerFadeOutStaggerDelayTick:TickableDelay= new TickableDelay(tracerFadeOutStagger);

        var staggerFadeOutTracerTick:ITickable= Domino2Utils.appendTickable(tracerFadeOutStaggerDelayTick, fadeOutTracerTick);

        var linkMessageSpritesTick:ITickable= Domino2Utils.createLinkMultipleSpritesTask(
                this,
                messageSprites, -1,
                false);
        var linkTracerAnimTick:ITickable= Domino2Utils.createLinkTask(this,
                emblemTracerAnimSprite, -1,
                false);


        var fadeInMessageSpritesTick:ITickable=
                makeFadeAnimationBySpriteVector(messageSprites, true, emblemFadeInTime);
        var staggerDelayFadeInMessageSpritesTick:ITickable= new TickableDelay(emblemFadeInStaggerTime);
        fadeInMessageSpritesTick = Domino2Utils.appendTickable(staggerDelayFadeInMessageSpritesTick, fadeInMessageSpritesTick, true);

        var unlinkTracerAnimTick:ITickable= Domino2Utils.createUnlinkSpriteTask(emblemTracerAnimSprite, true);


        var phase1Tick:ITickable= Domino2Utils.appendTickable(linkBgSpriteTick, linkMessageSpritesTick, true);
        phase1Tick = Domino2Utils.appendTickable(phase1Tick, linkParticleSprite, true);
        phase1Tick = Domino2Utils.appendTickable(phase1Tick, linkTracerAnimTick, true);
        phase1Tick = Domino2Utils.appendTickable(phase1Tick, fadeInMessageSpritesTick);
        phase1Tick = Domino2Utils.combineTickable(phase1Tick, emblemTracerAnimSprite);
        phase1Tick = Domino2Utils.combineTickable(phase1Tick, staggerFadeOutTracerTick);
        phase1Tick = Domino2Utils.appendTickable(phase1Tick, unlinkTracerAnimTick, true);


        // phase 2: explosion and fade in formula animation
        var linkFormulaTick:ITickable= Domino2Utils.createLinkTask(this,
                scoringFormulaSprite, -1,
                false);
        var fadeInFormulaTick:ITickable=
                makeFadeAnimationBySprite(scoringFormulaSprite, true, formulaFadeInTime);

        var phase2Tick:ITickable= Domino2Utils.appendTickable(linkFormulaTick, fadeInFormulaTick, true);
        phase2Tick = Domino2Utils.combineTickable(phase2Tick, emitterTick);

        //Start up the explosion
//        for(var i:int= 0; i < numEmblemSparkles; i++) {
//            phase2Tick = Domino2Utils.combineTickable(phase2Tick, emitterArray[i]);
//        }
//        phase2Tick = Domino2Utils.combineTickable(phase2Tick, particleSprite);

        // optional phase 3: zoom in board zone
        var phase3Tick:TickableQueue= null;

        // a zone was activated and is not null
//        if (scoringCode != SCORING_CODE_TILES_ONLY) { // extra check for zone sprite for cheats
//            phase3Tick = new TickableQueue(true);
//
//            var zoneSprite:StarlingImageStripSprite= scoringFormulaSprite.getZoneSprite();
//            var formulaZoneX:int= zoneSprite.getX();
//            var formulaZoneY:int= zoneSprite.getY();
//            var formulaZoneOffscreenPt:Point= PropsUtils.makePointWithProperties(props, "dom.anim.scoring.formula.zone.offscreen");
//            zoneSprite.setOrigin(formulaZoneOffscreenPt.x,formulaZoneOffscreenPt.y);
//
//            var flyInBoardZoneTime:int= PropsCoreUtils.makeInt(props, "dom.anim.scoring.formula.zone.flyIn.time");
//
//            var transitionInBoardZoneTick:TickInterpolator= new TickInterpolator(flyInBoardZoneTime, config.FRAME_RATE);
//            var flyInBoardZone:StarlingSmoothLinearMoveInterpolator=
//                    new StarlingSmoothLinearMoveInterpolator(zoneSprite,
//                            formulaZoneX, formulaZoneY);
//            transitionInBoardZoneTick.addInterpolatable(flyInBoardZone);
//
//            // add sound
//            var flyingZoneAnim:ITickable= Domino2Utils.combineTickable(transitionInBoardZoneTick,
//                    StarlingTickableTaskUtils.createPlaySoundTask("dom.whammy.fly", true));
//
//            phase3Tick.add(flyingZoneAnim);
//
//            // if score bonus mystery tile
//            if (scoringCode == SCORING_CODE_MYSTERY_BONUS_ONLY ||
//                    scoringCode == SCORING_CODE_TILES_PLUS_MYSTERY_BONUS) {
//                // reset to question mark only
//                zoneSprite.index =
//                        DominoBoardZoneSprite.getZoneImageIndex(activatedBoardZone, false);
//                var mysteryBonusValue:int= activatedBoardZone.getIntParam(DominoBoardZone.PARAM_BONUS);
//                var hideFormulaZoneSpriteTick:ITickable= StarlingTickableTaskUtils.createSetVisibleTask(
//                        zoneSprite,
//                        false, false);
//                var revealMysteryZoneTick:ITickable= makeRevealMysteryZoneAnimation(
//                        mysteryBonusValue,
//                        scoringFormulaSprite,
//                        formulaZoneX, formulaZoneY);
//                phase3Tick.add(Domino2Utils.appendTickable(
//                        hideFormulaZoneSpriteTick,
//                        revealMysteryZoneTick, true));
//            }
//
//
//            if (!isZoneOnlyScoringCode(scoringCode)) {
//                var labelIncrementTime:int= PropsCoreUtils.makeInt(props, "dom.anim.scoring.formula.score.increment.time");
//
//                var incrementLabelTick:ITickable= makeSmoothIncrementingCountAnimation(
//                        scoringFormulaSprite.getTileSumLabel(),
//                        tileSum,
//                        scoreDelta,
//                        labelIncrementTime);
//                phase3Tick.add(incrementLabelTick);
//            }
//
//
//        }

        // phase 3.5: specular highlight sheens across the you score emblems
        var staggeredSheenAnim:ITickable= makeStaggeredSheenAnimation(scoringEmblemSprite,
                emblemSheenMaskRaster, null);
        var phase3_5Tick:ITickable= Domino2Utils.combineTickable(phase3Tick, staggeredSheenAnim);


        // end of anim delay
        var delayTickable:TickableDelay= new TickableDelay(delayTime);

        // destroy
        var unlinkScoringBgSpriteTick:ITickable= Domino2Utils.createUnlinkSpriteTask(scoringBgSprite, true);
        var unlinkMessageSpritesTick:ITickable= Domino2Utils.createUnlinkSpritesTask(messageSprites, true);
        var unlinkScoringFormulaTick:ITickable= Domino2Utils.createUnlinkSpriteTask(scoringFormulaSprite, true);
        var destroyTick:ITickable= Domino2Utils.combineTickable(unlinkMessageSpritesTick, unlinkScoringFormulaTick);
        destroyTick = Domino2Utils.combineTickable(destroyTick, unlinkScoringBgSpriteTick);


        var tickQueue:TickableQueue= new TickableQueue(true);
        tickQueue.add(phase1Tick);
        tickQueue.add(phase2Tick);
        tickQueue.add(phase3_5Tick);

        tickQueue.add(delayTickable);
        tickQueue.add(destroyTick);
//        return makeClickCancellableAnimWrap(tickQueue, this);
        return tickQueue;
    }

    public static function configureEmitter(props:Properties, emitter:ColoredParticleEmitter, prefix:String, tps:int):void {
//        var s:String= props.getProperty(prefix + ".cnt");
//        if (s != null)
//        {
//            var random:PogoRandom= Randleton.instance();
//            emitter.setEmitDuration(1);
//            var counts:Vector.<int>= PropsCoreUtils.makeIntArrayWithProperties(props, prefix + ".cnt");
//            var count:int= random.nextIntWithBounds(counts[0], counts[1] + 1);
//            emitter.setRate(count);
//        }
//        else
//        {
            var params:Vector.<int>= new <int>[200,25];//PropsCoreUtils.makeIntArrayWithProperties(props, prefix + ".emit");
            if (params[0] == 0)
            {
                emitter.setContinuous();
                emitter.setRate(Number(params[1] )/ Number(tps));
            }
            else
            {
                emitter.setEmitDuration(params[0] * tps / 1000);
                emitter.setRate(Number(params[1] )/ Number(tps));
            }
//        }

        var s:String = null;//"294,191";//props.getProperty(prefix + ".origin.pt");
//        if (s != null) {
            var origin:Point= new Point(294, 191);//PropsUtils.makePointWithProperties(props, prefix + ".origin");
            emitter.setOrigin(origin.x, origin.y);
//        }         /

//        s = props.getProperty(prefix + ".x");
//        if (s != null)
//        {
            var xo:Vector.<Number>= new <Number>[0.0,0.0];//PropsCoreUtils.makeDoubleArrayWithProperties(props, prefix + ".x");
            emitter.setXOffset(xo[0], xo[1]);
//        }

//        s = props.getProperty(prefix + ".y");
//        if (s != null)
//        {
            var yo:Vector.<Number>= new <Number>[0.0,0.0];//PropsCoreUtils.makeDoubleArrayWithProperties(props, prefix + ".y");
            emitter.setYOffset(yo[0], yo[1]);
//        }

//        s = props.getProperty(prefix + ".dx");
//        if (s != null)
//        {
            var dx:Vector.<Number>= new <Number>[0.0,0.0];//PropsCoreUtils.makeDoubleArrayWithProperties(props, prefix + ".dx");
            emitter.setXVelocity(dx[0], dx[1]);
//        }

//        s = props.getProperty(prefix + ".dy");
//        if (s != null)
//        {
            var dy:Vector.<Number>= new <Number>[-10.0,-5.0];//PropsCoreUtils.makeDoubleArrayWithProperties(props, prefix + ".dy");
            emitter.setYVelocity(dy[0], dy[1]);
//        }

//        s = props.getProperty(prefix + ".ddx");
//        if (s != null)
//        {
            var ddx:Vector.<Number>= new <Number>[-0.5,0.5];//PropsCoreUtils.makeDoubleArrayWithProperties(props, prefix + ".ddx");
            emitter.setXAccel(ddx[0], ddx[1]);
//        }

//        s = props.getProperty(prefix + ".ddy");
//        if (s != null)
//        {
            var ddy:Vector.<Number>= new <Number>[0.0,0.0];//PropsCoreUtils.makeDoubleArrayWithProperties(props, prefix + ".ddy");
            emitter.setYAccel(ddy[0], ddy[1]);
//        }

//        s = props.getProperty(prefix + ".gravity");
//        if (s != null)
//        {
            var gravityTick:Number= 1.0;//PropsCoreUtils.makeDouble(props, prefix + ".gravity");
            emitter.setGravity(gravityTick);
//        }



//        s = props.getProperty(prefix + ".weight");
//        if (s != null)
//        {
            emitter.setWeight(1.0);//PropsCoreUtils.makeDouble(props, prefix + ".weight"));
//        }

        var duration:Vector.<int>= new <int>[500, 800];//PropsCoreUtils.makeIntArrayWithProperties(props, prefix + ".dur");
        emitter.setParticleDuration(calculateNumFrames(duration[0], tps),
                calculateNumFrames(duration[1], tps));

    }

    public static function calculateNumFrames(ms:int, fps:int):int {
        return (ms * fps) / 1000;
    }

    internal function makeStaggeredSheenAnimation(parent:StarlingSprite, maskRaster:BitmapData, key:String):ITickable {
        var staggeredSheenAnim:TickableSet= new TickableSet();
        var numSheens:int= 2;//PropsCoreUtils.makeInt(props, key + ".sheen.num");
        var sheenStagger:int= 500;//PropsCoreUtils.makeInt(props, key + ".sheen.stagger.time.ms");

        for (var count:int= 0; count < numSheens; count++) {
            var sheenAnim:ITickable= makeSheenAnimation(parent, maskRaster, key);
            var staggerDelay:TickableDelay= new TickableDelay(sheenStagger * count);

            staggeredSheenAnim.add(Domino2Utils.appendTickable(staggerDelay, sheenAnim, true));
        }

        return staggeredSheenAnim;
    }

    public function makeSheenAnimation(parent:StarlingSprite, maskRaster:BitmapData, key:String):ITickable {
        var sheenGradientAlphaRaster:ImageSprite = new ImageSprite(Texture.fromBitmap(new sheen()));
        var sheenAlpha:Number = 1; //100
        var animTime:int = 800;

        var maskFilter:PixelMaskDisplayObject = new PixelMaskDisplayObject();

        var maskRasterImage:ImageSprite = new ImageSprite(Texture.fromBitmapData(maskRaster));
        maskFilter.addChild(sheenGradientAlphaRaster);
        maskRasterImage.alpha = sheenAlpha;
        maskFilter.mask = maskRasterImage;

        var initialX:int = -sheenGradientAlphaRaster.width;
        var initialY:int = 0;
        sheenGradientAlphaRaster.setOrigin(initialX, initialY);

        //var sheenMaskMoveSprite:SheenMaskMoveAdapterSprite= new SheenMaskMoveAdapterSprite(sheenGradientAlphaRaster, maskFilter);

        var runnable:Function = function ():void {
            parent.add(maskFilter);
        };
        var linkSheenSpriteTick:ITickable = new TickableTask(runnable);

        var shineSheenTick:TickInterpolator = new TickInterpolator(animTime, 30);
        var moveSheenAcross:StarlingLinearSpriteMover = new StarlingLinearSpriteMover(sheenGradientAlphaRaster, maskRaster.width, 0);
        shineSheenTick.addInterpolatable(moveSheenAcross);

        var runnable2:Function = function ():void {
            sheenGradientAlphaRaster.unlink(false);
        }
//            var unlinkSheenSpriteTick:ITickable= new TickableTask(runnable2);
        var animQueue:TickableQueue = new TickableQueue(true);
        animQueue.add(linkSheenSpriteTick);
        animQueue.add(shineSheenTick);
//            animQueue.add(unlinkSheenSpriteTick);

        return animQueue;
    }

//    private function makeClickCancellableAnimWrap(animation:ITickable, clickPaneSprite:StarlingSprite):ITickable {
//        var cancelMouseListener:Function= function(e:MouseEvent) {
//            animation.cancel();
////            mServices.dumpSoundChannels();
//        };
//
//        var attachListenerTick:ITickable= Domino2Utils.createAddMouseListenerTask(
//                clickPaneSprite, cancelMouseListener, false);
//        var detachListenerTick:ITickable= Domino2Utils.createRemoveMouseListenerTask(
//                clickPaneSprite, cancelMouseListener, true);
//        var wrappedAnimation:ITickable= Domino2Utils.appendTickable(attachListenerTick, animation, true);
//        wrappedAnimation = Domino2Utils.appendTickable(wrappedAnimation, detachListenerTick, true);
//
//        return wrappedAnimation;
//    }

    /**
     * Create a trace animation for the image sprite.
     * @param sprite
     * @param parent
     * @param key
     * @param tracerSubRect
     * @return
     */
    public function makeTracerAnim(sprite:ImageSprite, parent:StarlingSprite, key:String, tracerSubRect:Rectangle = null):ITickable {
        if (tracerSubRect == null) {
            tracerSubRect = sprite.getSubRect();
        }

        // tracer animation
        var sparkleRaster:Texture = Texture.fromBitmap(new smallSparkle);// mServices.getRaster(key + ".sparkle");
        var traceRaster:BitmapData = (new trace() as Bitmap).bitmapData; // mServices.getBitmap(key + ".trace");

        var tracerAnimSprite:SparkleTracerAnimSprite = SparkleTracerAnimSprite.makeSparkleTracerSpriteWithTraceSubRectForScoring(
                null,
                sparkleRaster, traceRaster,
                tracerSubRect, FRAME_RATE,
                key);
        tracerAnimSprite.setOrigin(sprite.getX(), sprite.getY());
//        addChild(tracerAnimSprite);

        var fadeTracerTick:ITickable= makeFadeAnimationBySprite(tracerAnimSprite, false, tracerAnimSprite.getAnimTime());

        var linkTracerAnimTick:ITickable = Domino2Utils.createLinkTask(parent, tracerAnimSprite, -1, false);

        var tracerFadeAnim:ITickable= Domino2Utils.combineTickable(fadeTracerTick, tracerAnimSprite);
        var unlinkTracerAnimTick:ITickable= Domino2Utils.createUnlinkSpriteTask(tracerAnimSprite, true);

        var tickQueue:TickableQueue = new TickableQueue(true);
        tickQueue.add(linkTracerAnimTick);
//        tickQueue.add(tracerAnimSprite);
        tickQueue.add(tracerFadeAnim);
//        tickQueue.add(fadeTracerTick);
        tickQueue.add(unlinkTracerAnimTick);
        return tickQueue;
    }

        public function makeFadeAnimationBySprite(fadingSprite:StarlingSprite, fadeIn:Boolean, duration:Number):ITickable {
            var spriteVector:Vector.<StarlingSprite> = new <StarlingSprite>[fadingSprite];
            return makeFadeAnimationBySpriteVector(spriteVector, fadeIn, duration);
        }

        public function makeFadeAnimationBySpriteVector(
                fadingSprites:Vector.<StarlingSprite>, fadeIn:Boolean, duration:Number):ITickable {
            var tickQueue:TickableQueue= new TickableQueue(true);

            var alpha1:int= fadeIn? 0 : 1;
            var alpha2:int= fadeIn? 1 : 0;
            var tickInterop:TickInterpolatorJavaPort= new TickInterpolatorJavaPort(duration, FRAME_RATE);
            tickInterop.alwaysExecute();

            for (var index:int= 0; index < fadingSprites.length; index++) {
//                var fadingSprite:StarlingSprite = fadingSprites[index];
//                Starling.juggler.tween(fadingSprite, duration / 1000.0, {
//                            onComplete: function():void {
//                                fadingSprite.visible = !fadeIn;
//                                Starling.juggler.removeTweens(fadingSprite);
//                            },
//                            alpha: fadeIn ? 1.0 : 0.0,
//                            delay: delay / 1000.0
//                });
                var alphaInterop:StarlingAlphaInterpolator= new StarlingAlphaInterpolator(fadingSprites[index], alpha1, alpha2);
                tickInterop.addInterpolatable(alphaInterop);
            }


            var fadingSpritesArray:Array = new Array();
            for each(var sprite:StarlingSprite in fadingSprites) {
                fadingSpritesArray.push(sprite);
            }
            var setVisibleTick:ITickable= StarlingTickableTaskUtils.createSetSpritesVisibleTask(fadingSpritesArray, fadeIn, true);

            if (fadeIn) tickQueue.add(setVisibleTick);	// set visible before fade in
            tickQueue.add(tickInterop);
            if (!fadeIn) tickQueue.add(setVisibleTick); // set invisible after fade out

            return tickQueue;
        }


}
}
