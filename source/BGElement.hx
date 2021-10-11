package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class BGElement extends FlxSprite
{
	
	var sc:Float = 1;
	var sz:Float = 1;
	var movID:Int = 0;
	var imgName:String = 'none';

	var time:Float = 0;
	public function new(image:String, sX:Float, sY:Float, scroll:Float, size:Float, movid:Int)
	{
		movID = movid;
		x = sX;
		y = sY;
		super(x, y);
		sc = scroll;
		imgName = image;
		loadGraphic(Paths.image(imgName));
		scrollFactor.set(sc, sc);
		antialiasing = true;
		setGraphicSize(Std.int(width * (size)));

		updateHitbox();
	}

	override function update(elapsed:Float)
	{
		if (PlayState.bgEdit && PlayState.bgTarget == movID)
		{
			if (FlxG.keys.justPressed.K)
				sc += 0.05;
			if (FlxG.keys.justPressed.I)
				sc -= 0.05;

			var spd = 4;
			if (FlxG.keys.pressed.SHIFT)
				spd = 10;

			if (FlxG.keys.pressed.D)
				x += spd;
			if (FlxG.keys.pressed.A)
				x -= spd;
			if (FlxG.keys.pressed.S)
				y += spd;
			if (FlxG.keys.pressed.W)
				y -= spd;

			scrollFactor.set(sc, sc);

			if (FlxG.keys.justPressed.SPACE)
			{
				FlxG.sound.play(Paths.sound('Charting_3'));
				trace(imgName + ': ' + x + ',' + y + ',' + sc);
			}
		}
		super.update(elapsed);
	}
}
