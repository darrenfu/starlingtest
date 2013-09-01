/**
 * Created with IntelliJ IDEA.
 * User: darrenfu
 * Date: 8/30/13
 * Time: 11:29 AM
 * To change this template use File | Settings | File Templates.
 */
package {
import com.pogo.ui.starling.StarlingSprite;

import flash.utils.setTimeout;

import starling.core.Starling;
import starling.extensions.PDParticleSystem;
import starling.textures.Texture;

public class ParticleSys extends StarlingSprite {

	// embed configuration XML
	[Embed(source="particle.pex", mimeType="application/octet-stream")]
	public static const ExplosionConfig:Class;

	[Embed(source="large_sparkle.png")]
	public static const largeSparkle:Class;

	private var ps1:PDParticleSystem;

	public function ParticleSys() {
		// instantiate embedded objects
		var psConfig:XML = XML(new ExplosionConfig());
		var psTexture:Texture = Texture.fromBitmap(new largeSparkle());

		// create particle system
//		for (var i:int=0;i<10;i++) {
		var ps:PDParticleSystem = new PDParticleSystem(psConfig, psTexture);
		ps.x = 100 + 20;
		ps.y = 200;

		// add it to the stage and the juggler
		addChild(ps);
		Starling.juggler.add(ps);

		// change position where particles are emitted
		ps.emitterX = 200;
		ps.emitterY = 25;

		// emit particles for two seconds, then stop
		ps.start();

		// stop emitting particles; on restart, it will start from scratch
		//		ps.stop();

		ps1 = new PDParticleSystem(psConfig, psTexture);
		ps1.x = 100 + 20;
		ps1.y = 200;
		ps1.alpha = .5;

		// add it to the stage and the juggler
		addChild(ps1);
		Starling.juggler.add(ps1);

		// change position where particles are emitted
		ps1.emitterX = 200;
		ps1.emitterY = 225;

		// emit particles for two seconds, then stop
		ps1.start();//setTimeout(run, 200);

	}

	function run():void {
		ps1.start();
	}
}
}
