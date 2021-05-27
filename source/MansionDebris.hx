package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class MansionDebris extends FlxSprite
{
	
	var sc:Float = 1;
	var tF:Float = 1;
	var tD:Float = 1;
	var pF:Float = 1;
	var sx:Float = 0;
	var sy:Float = 0;

	var time:Float = 0;
	public function new(sX:Float, sY:Float, debName:String, scroll:Float, tFactor:Float, tDelay:Float, posFactor:Float)
	{
		sx = sX;
		sy = sY;
		x = sx;
		y = sy;
		super(x, y);
		sc = scroll;
		tF = tFactor;
		tD = tDelay;
		pF = posFactor;
		frames = Paths.getSparrowAtlas('god_bg');
		animation.addByPrefix('c', "deb_" + debName, 30);
		//bgcloud.setGraphicSize(Std.int(bgcloud.width * 0.8));
		animation.play('c');
		scrollFactor.set(sc, sc);
		antialiasing = true;
		setGraphicSize(Std.int(frameWidth * (sc / 0.75)));

		updateHitbox();
	}

	var grav:Float = 0.15;
	var vsp:Float = -20;
	var hsp:Float = 0;
	override function update(elapsed:Float)
	{
		time ++;
		if (tD != -4)
		{
			x = sx;
			y = sy + Math.sin((time + tD) / 50 * tF) * 50 * pF;
		}
		else
		{
			hsp = pF;
			vsp += grav;

			x += hsp;
			y += vsp;
			angle -= hsp / 2;
		}

		super.update(elapsed);
	}
}
