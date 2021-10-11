package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.effects.FlxTrail;
import flixel.FlxObject;
import flixel.FlxCamera;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxSave;

using StringTools;

class MASKcoll extends FlxSprite
{
	
	var mType:Int = 1;
	var imgName:String = 'none';

	var iniX:Float;
	var iniY:Float;

	var time:Float = 0;

	var mouseSpr:FlxSprite;
	var mouseState:Int = 0;
	var fx:FlxSprite;
	var give:FlxSprite;
	var gTrail:FlxTrail;

	var camFollow:FlxObject;
	var cam:FlxCamera;

	public var state = 0;

	//maskframe
	var vsp:Float = -10;

	//mouth
	var mVsp:Float = 0;
	var wait:Int = 1000;

	//eye
	var eVsp:Float = -10;

	//sheeeee
	var clickX:Float;
	var clickY:Float;

	public function new(type:Int, sX:Float, sY:Float, stJump:Int, ?camObj:FlxObject = null, ?exCam:FlxCamera = null)
	{
		x = sX;
		y = sY;
		iniX = x;
		iniY = y;
		state = stJump;
		mType = type;
		camFollow = camObj;
		cam = exCam;
		super(x, y);
		imgName = 'MASK/coll/' + mType;
		loadGraphic(Paths.image(imgName));
		updateHitbox();
		antialiasing = true;

		offset.set(width / 2, height / 2);
		switch (mType)
		{
			case 0:
			case 1:
			case 2:
				//offset.set(width / 2, height / 2);
				//scrollFactor.set(sc, sc);
			case 3:
		}
		mouseSpr = new FlxSprite(0, 0).loadGraphic(Paths.image('MASK/picker'));
		mouseSpr.antialiasing = true;
		mouseSpr.offset.set(10, 10);
		mouseSpr.alpha = 0;
		PlayState.maskMouseHud.add(mouseSpr);

		updateHitbox();
	}

	override function update(elapsed:Float)
	{
		mouseSpr.x = FlxG.mouse.x;
		mouseSpr.y = FlxG.mouse.y;

		clickX = getMidpoint().x;
		clickY = getMidpoint().y;
		if (mType == 3)
		{
			clickX = getMidpoint().x + camFollow.x - FlxG.camera.width / 2;
			clickY = getMidpoint().y + camFollow.y - FlxG.camera.height / 2 - 100;
		}

		var distance = Math.sqrt(Math.pow(mouseSpr.x - clickX, 2) + Math.pow(mouseSpr.y - clickY, 2));

		if (distance < 2000 && state != -1 && state != 10)
		{
			if (mouseSpr.alpha < 1)
				mouseSpr.alpha += 0.1;
		}
		else
		{
			if (mouseSpr.alpha > 0)
				mouseSpr.alpha -= 0.1;
		}

		switch (mType)
		{
			case 1:
				if (wait <= 0)
				{
					if (y <= 6000)
					{
						y += mVsp;
						mVsp += 0.02;
						angle -= 3;
					}
				}
				else
				{
					wait --;
				}
			case 2:
				switch (state)
				{
					case 0:
						y += vsp;
						angle += 10;
						vsp += 0.3;
						if (vsp > 10)
						{
							state = 1;
							angle = 0;
							x = iniX;
							y = iniY;
						}
					case 1:
						
				}
				//scrollFactor.set(sc, sc);
			case 3:
				var wSize = cam.width / 2;
				x = wSize + (wSize - 200) * Math.cos(-FlxG.camera.angle * Math.PI / 180);
				y = -Math.sin(-FlxG.camera.angle * Math.PI / 180) * wSize * 1.3 - 120;
				angle = FlxG.camera.angle;
				if (state != -1)
				{
					if (!PlayState.rotCam)
					{
						state = 10;
					}
					else
					{
						state = 0;
					}
				}
			case 4:
				switch (state)
				{
					case 0:
						angle += 1;
						y += eVsp;
						eVsp += 0.1;
						x += 2;

						if (y > 730)
						{
							state = 1;
						}
					case 1:
						angle = 0;
				}
		}

		if (state != -1 && state != 10)
		{
			if (distance < width / 2)
			{
				if (FlxG.mouse.justPressed)
				{
					FlxG.sound.play(Paths.sound('maskColl'));
					state = -1;
					alpha = 0;
					fx = new FlxSprite(clickX, clickY).loadGraphic(Paths.image('MASK/fx'));
					fx.offset.set(fx.width / 2, fx.height / 2);

					give = new FlxSprite(clickX, clickY).loadGraphic(Paths.image('MASK/partSmall'));
					give.offset.set(give.width / 2, give.height / 2);

					gTrail = new FlxTrail(give, null, 5, 7, 0.3, 0.001);

					PlayState.maskFxGroup.add(fx);
					PlayState.maskFxGroup.add(give);
					PlayState.maskTrailGroup.add(gTrail);

					FlxG.save.data.p_maskGot[mType - 1] = true;
				}
				if (mouseState == 0)
					mouseState = 1;
			}
			else
			{
				if (mouseState == 2)
					mouseState = 0;
			}
		}
		if (fx != null)
		{
			fx.scale.x += 0.04;
			fx.scale.y += 0.04;
			fx.alpha -= 0.03;

			if (fx.alpha <= 0)
			{
				PlayState.maskFxGroup.remove(fx);
			}
		}
		if (give != null)
		{
			give.x += (PlayState.bfAccess.getMidpoint().x - give.x) / 30;
			give.y += (PlayState.bfAccess.getMidpoint().y - give.y) / 30;

			if (Math.abs(give.x - PlayState.bfAccess.getMidpoint().x) < 20)
			{
				give.scale.x -= 0.01;
				give.scale.y -= 0.01;

				if (give.scale.x <= 0)
				{
					PlayState.maskTrailGroup.remove(gTrail);
					PlayState.maskFxGroup.remove(give);
				}
			}
		}
		switch mouseState
		{
			case 0:
				mouseSpr.scale.x += (1 - mouseSpr.scale.x) / 12;
				mouseSpr.scale.y += (1 - mouseSpr.scale.y) / 12;
			case 1:
				mouseState = 2;
				FlxG.sound.play(Paths.sound('cursor'));
			case 2:
				mouseSpr.scale.x += (1.6 - mouseSpr.scale.x) / 12;
				mouseSpr.scale.y += (1.6 - mouseSpr.scale.y) / 12;
		}

		super.update(elapsed);
	}
}
