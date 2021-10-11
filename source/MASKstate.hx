package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.system.FlxSound;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.display.FlxBackdrop;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import Achievements;

using StringTools;

class MASKstate extends MusicBeatState
{
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;

	var dtBg:FlxBackdrop;
	var dtBgBg:FlxBackdrop;

	var mask:FlxSprite;
	var maskP:Array<FlxSprite>;
	var maskX:Float;
	var maskY:Float;
	var maskPartName = ['frame', 'horn', 'eye', 'mouth'];
	var maskExpNames = ['n', 'h', 's'];
	var maskExpAnim = [['normal', 'trauma', 'con', 'sad', 'happy'], ['normal', 'sad', 'happy'], ['normal', 'con', 'angry']];

	var gfxPart = [];
	var wFlash:FlxSprite;

	var introWait:Int;
	var state = 0;
	var lState = 0;

	var frameY = 370;

	var optsText:FlxText;

	var musicPlaying = false;
	var goodMenu:FlxSound;
	var badMenu:FlxSound;
	var musicIsGood = true;
	public static var nid:Map<String, Int> = [
		'FacePartsIntro' => 0,
		'backstory' => 1
	];
	var chucha = false;
	var collectAmmo = 0;

	public static function saveDataSetup()
	{
		trace('save setup attempt');
		if (FlxG.save.data.p_InSet == null)
		{
			FlxG.save.data.p_progress = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
			FlxG.save.data.p_hintSaw = [false, false, false, false];
			FlxG.save.data.p_first = [];
			for (i in nid)
			{
				FlxG.save.data.p_first.push(true);
			}

			FlxG.save.data.p_pGivenInd = [false, false, false, false];

			FlxG.save.data.p_maskGot = [false, false, false, false];
			FlxG.save.data.p_partsGiven = 0;
			FlxG.save.data.p_canTalk = false;
			FlxG.save.data.p_beat = false;
			FlxG.save.data.p_fought = 0;
			FlxG.save.data.p_Set = true;

			FlxG.save.data.ending = [false, false, false];

			FlxG.save.data.p_InSet = true;
			trace('save values set.');
		}
	}

	public static function endingUnlock(ed:Int)
	{
		if (!FlxG.save.data.ending[ed])
		{
			FlxG.save.data.ending[ed] = true;
			FlxG.sound.play(Paths.sound('ending'));
		}
	}

	var marks:Array<FlxSprite> = [];
	var mVis = [false, false, false];
	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		introWait = 200;
		FlxG.sound.music.fadeOut(1, 0);
		musicPlaying = false;

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		dtBg = new FlxBackdrop(null, 1, 1, true, true);
		dtBg.loadGraphic(Paths.image('MASK/menu/grid', 'shared'));

		dtBgBg = new FlxBackdrop(null, 1, 1, true, true);
		dtBgBg.x += 20;
		dtBgBg.loadGraphic(Paths.image('MASK/menu/grid', 'shared'));
		dtBgBg.alpha = 0.5;

		add(dtBgBg);
		add(dtBg);

		var bFrame = new FlxSprite(0, frameY).makeGraphic(2000, 2000, FlxColor.BLACK);
		add(bFrame);

		var bBorder = new FlxSprite(0, frameY).makeGraphic(2000, 5, 0xFF0064C9);
		add(bBorder);


		optsText = new FlxText(80, frameY + 50, 2000, '', 32);
		optsText.font = 'Pixel Arial 11 Bold';
		optsText.color = 0xFFFFFFFF;
		optsText.alpha = 0;
		updateOptions();

		bfCursor = new FlxSprite(10, 0).loadGraphic(Paths.image('bfIcon'));
		bfCursor.scale.x = 0.5;
		bfCursor.scale.y = 0.5;
		bfCursor.antialiasing = true;
		bfCursor.updateHitbox();
		bfCursor.alpha = 0;

		wFlash = new FlxSprite(0, 0).makeGraphic(3000, 3000, FlxColor.WHITE);
		wFlash.alpha = 0;

		for (i in 0...4)
		{
			marks[i] = new FlxSprite(100, 0).makeGraphic(32, 32, FlxColor.YELLOW);
			marks[i].alpha = 0;
			add(marks[i]);
		}

		add(optsText);
		add(bfCursor);

		//0064c9

		/*
		mask = new FlxSprite(0, 0);
		mask.frames = Paths.getSparrowAtlas('MASK/exp/ph_mask_old', 'shared');
		for (i in 0...maskExpNames.length)
		{
			for (j in 0...maskExpAnim[i].length)
			{
				var name = maskExpNames[i] + '_' + maskExpAnim[i][j];
				mask.animation.addByPrefix(name, name);
			}
		}
		mask.animation.play('n_normal', true);
		*/

		maskP = [];
		for (i in 0...4)
		{
			maskP[i] = new FlxSprite(0, 0);
			maskP[i].frames = Paths.getSparrowAtlas('MASK/exp/ph_mask', 'shared');
			maskP[i].antialiasing = true;

			var an = 0;
			for (j in 0...maskExpNames.length)
			{
				for (l in 0...maskExpAnim[j].length)
				{
					var name = maskExpNames[j] + '_' + maskExpAnim[j][l];
					maskP[i].animation.addByIndices(name + '_f', maskPartName[i] + '_f0', [an], "", 30, false);
					maskP[i].animation.addByIndices(name + '_e', maskPartName[i] + '_e0', [an], "", 30, false);

					an ++;
				}
			}
			add(maskP[i]);
		}
		maskPosSet();
		maskPlay('n_normal');
		if (FlxG.save.data.p_progress[0] == 1) maskPlay('s_normal');

		add(wFlash);

		var readOpt = CoolUtil.coolTextFile(Paths.txt(pathGet() + 'questions'));

		for (i in 0...5)
		{
			optList[i] = readOpt[i].split(":");
		}

		super.create();
	}

	function maskPosSet()
	{
		for (i in 0...4)
		{
			maskP[i].updateHitbox();
			maskP[i].screenCenter(X);
			maskP[i].screenCenter(Y);
			maskP[i].y -= 150;
		}
		maskX = maskP[0].x;
		maskY = maskP[0].y;
	}

	function maskPlay(animName:String)
	{
		var corr = [3 => 0, 0 => 1, 1 => 2, 2 => 3]; //xddddd
		var ang = 0;
		if (animName.startsWith('h'))
			ang = -45;
		else if (animName.startsWith('s'))
			ang = 35;

		for (i in 0...4)
		{
			var play = animName;

			if (!FlxG.save.data.p_pGivenInd[corr[i]])
			{
				play += '_e';
				maskP[i].alpha = 0.75;
			}
			else
			{
				play += '_f';
				maskP[i].alpha = 1;
			}

			maskP[i].animation.play(play);

			
			maskP[i].angle = ang;
		}
	}
	
	var mainSelect:Int = 0;
	var optSelect:Int = 0;

	var afterAction = 'menu';
	var afterData:Array<Dynamic> = [];
	var dial:Array<String> = ['text1. very, very Large!\nLARGE!!?! large? text. very, large! text.', 'text2'];
	var expList:Array<String> = ['n_normal', 'h_happy'];
	var instList:Array<String> = ['', ''];
	var txtSpeed:Float = 0.3;

	//mask movement
	var mTalk = false;
	var mExp = 'n_normal';
	var mChange = false;

	//prompt
	var bfCursor:FlxSprite;
	var renderOptions:Array<String> = ['yes', 'no'];
	var optAlpha:Float = 0;

	var optList:Array<Dynamic> = [
		[],
		[],
		[],
		[],
		[]
	];

	var optID:Array<String> = ['C1', 'C2', 'C3', 'parts', 'exit'];

	var gTimer = 0;

	var songTime:Float = 0;

	override function update(elapsed:Float)
	{
		dtBg.x += 0.4;
		dtBg.y += 0.2;

		dtBgBg.x -= 0.25;
		dtBgBg.y -= 0.15;

		for (i in 0...4)
		{
			maskP[i].x = maskX;
			maskP[i].y = maskY + Math.sin(dtBg.y / 10) * 10;
			//maskP[i].angle ++;

			if (mTalk)
			{
				maskP[i].y += Math.sin(dtBg.y) * 10;
			}
		}
		if (mChange)
		{
			maskPlay(mExp);
			maskPosSet();
			mChange = false;
		}

		super.update(elapsed);

		optAlpha = 0;
		
		for (i in 0...marks.length)
		{
			marks[i].alpha = 0;

			if (state == 3)
			{
				var o = i + 1;
				var optShown = FlxG.save.data.p_progress[o];

				if (optShown > getProgress() - 1) optShown = getProgress() - 1;
				if (optShown > 2) optShown = 2;

				var condition = false;
				if (i < 3)
				{
					condition = FlxG.save.data.p_progress[o] <= optShown;
				}
				else
				{
					var target = 0;
					while (target < 4 && FlxG.save.data.p_maskGot[target])
					{
						target ++;
					}
					if (target < 4)
					{
						if (!FlxG.save.data.p_hintSaw[target])
						{
							condition = true;
						}
					}
				}

				if (condition)
				{
					marks[i].x = optsText.x + renderOptions[i].length * 28;
					marks[i].y = optsText.y + 10 + i * 44;
					marks[i].alpha = 0.75 + 0.25 * Math.cos(dtBg.y / 3 + i / 10);
				}
			}
		}
		//Statin baby
		switch (state)
		{
			case 0: //lil pause before anything
				introWait --;
				if (introWait <= 0)
				{
					state = 1;
				}
			case 1: //intro texts
				loadData('intro');
				textSetup();
			case 2: //dialogue running
				textStep();
			case 3: //Main question menu
				//trace('cock');

				mainSelect = optSelect;

				if (!musicPlaying)
				{
					musicInit();
				}

				if (controls.ACCEPT)
				{
					var o = optSelect + 1;
					var optShown = FlxG.save.data.p_progress[o];
					if (optShown > getProgress() - 1) optShown = getProgress() - 1;
					if (optShown > 2) optShown = 2;

					var selS = 'q' + (optSelect + 1) + '-' + (optShown + 1);
					switch (optID[optSelect])
					{
						case 'parts':
							hintLoad();
						case 'exit':
							loadData('exit');
							textSetup();
						default:
							if (FlxG.save.data.p_progress[o] < getProgress())
								FlxG.save.data.p_progress[o] ++;
							loadData('answers/' + selS);
							textSetup();
					}
				}
			case 4: //Prompt menu
				if (controls.ACCEPT)
				{
					loadData(afterData[optSelect + 2]);
					textSetup();
				}
			case 5:
				gfxPart = [];
				collectAmmo = 0;
				while (FlxG.save.data.p_partsGiven < getProgress())
				{
					var g = new FlxSprite(Math.random() * FlxG.width, FlxG.height).loadGraphic(Paths.image('MASK/partSmall', 'shared'));
					g.scale.x = 1.75 + Math.random() - 0.5;
					g.scale.y = g.scale.x;
					g.offset.set(g.width / 2, g.height / 2);
					add(g);
					gfxPart.push(g);
					FlxG.save.data.p_partsGiven ++;
					collectAmmo ++;
				}
				for (i in 0...4)
				{
					FlxG.save.data.p_pGivenInd[i] = FlxG.save.data.p_maskGot[i];
				}
				gTimer = 0;
				state = 6;
			case 6:
				gTimer ++;
				for (i in 0...gfxPart.length)
				{
					var g = gfxPart[i];
					g.x += (maskP[0].getMidpoint().x - g.x) / 20;
					g.y += (maskP[0].getMidpoint().y - g.y) / 20;

					if (g.scale.x > 0)
					{
						g.scale.x -= 0.01;
						g.scale.y = g.scale.x;
					}
				}
				if (gTimer >= 240)
				{
					wFlash.alpha = 1.1;
					FlxG.sound.play(Paths.sound('maskColl'));
					state = 7;
					gTimer = 0;
					maskPlay('n_normal');
					for (i in 0...gfxPart.length)
					{
						remove(gfxPart[i]);
					}
				}
			case 7:
				gTimer ++;
				if (gTimer >= 200)
				{
					loadData('howManyLeft');
					textSetup();
				}
		}
		switch (state) //shared shit
		{
			case 3 | 4: //Cursored menus
				optAlpha = 1;
				bfCursor.y = optsText.y + optSelect * 44;

				var oMov = 0;
				if (controls.UI_DOWN_P)
					oMov = 1;
				else if (controls.UI_UP_P)
					oMov = -1;
				
				if (oMov != 0)
				{
					optSelect += oMov;
					FlxG.sound.play(Paths.sound('scrollMenu'));

					if (optSelect > renderOptions.length - 1) optSelect = 0;
					if (optSelect < 0) optSelect = renderOptions.length - 1;
				}
		}
		bfCursor.alpha = optAlpha;
		optsText.alpha = optAlpha;

		if (wFlash.alpha > 0)
		{
			wFlash.alpha -= 0.003;
		}
		if (musicPlaying && badMenu != null && goodMenu != null)
		{
			if (musicIsGood)
			{
				badMenu.time = FlxG.sound.music.time;
			}
		}
		lState = state;

		#if debug
		if (FlxG.keys.justPressed.NINE)
		{
			FlxG.save.data.p_InSet = null;
			saveDataSetup();
			FlxG.sound.play(Paths.sound('cancelMenu'));
			afterAction = 'exit';
			instList = [''];
			expList = ['n_normal'];
			dial = ['tu cuenta de freefire ha sido borrada'];
			textSetup();
			state = 2;
		}
		#end
		if (goodMenu != null)
		{
			songTime += elapsed * 1000;
			songTime %= goodMenu.length;
		}
	}
	function hintLoad()
	{
		var file = '';
		var check = FlxG.save.data.p_first[nid['FacePartIntro']];
		if (check)
		{
			file = 'hint/intro';
			FlxG.save.data.p_first[nid['FacePartIntro']] = false;
		}
		else
		{
			var partName = ['mouth', 'frame', 'horn', 'eye'];
			file = 'hint/';
			var target = 0;
			while (target < 4 && FlxG.save.data.p_maskGot[target])
			{
				target ++;
			}
			if (target < 4)
			{
				file += partName[target];
				if (!FlxG.save.data.p_hintSaw[target])
				{
					file += '_intro';
					FlxG.save.data.p_hintSaw[target] = true;
				}
			}
			else
			{
				if (FlxG.save.data.p_partsGiven > 0) file += 'last';
				else file += 'notSure';
			}
		}
		loadData(file);
		textSetup();
	}
	function musicInit()
	{
		FlxG.sound.playMusic(Paths.music('MASK/phantomMenu'));
		FlxG.sound.music.fadeIn(0, 1, 1);

		if (goodMenu != null)
		{
			goodMenu.stop();
		}
		if (badMenu != null)
		{
			badMenu.stop();
		}
		goodMenu = new FlxSound().loadEmbedded(Paths.music('MASK/phantomMenu'));
		goodMenu.play();
		goodMenu.looped = true;
		goodMenu.volume = 0;

		badMenu = new FlxSound().loadEmbedded(Paths.music('MASK/phantomMenuScary'));
		badMenu.play();
		badMenu.looped = true;
		badMenu.volume = 0;
		musicPlaying = true;
	}

	override public function onFocus():Void
	{
		if (musicPlaying && badMenu != null)
		{
			if (!musicIsGood)
			{
				badMenu.volume = 1;
			}
			badMenu.time = FlxG.sound.music.time;
		}
		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		if (badMenu != null) badMenu.volume = 0;
		super.onFocusLost();
	}

	function updateOptions()
	{
		optsText.text = '';
		for (i in 0...renderOptions.length)
		{
			optsText.text += renderOptions[i] + '\n';
		}
	}

	var onScreenText:FlxText;
	var read:String;
	var txtInd:Int;
	var charInd:Float = 0;
	var intChar:Int = 0;
	var lChar:Int = 0;

	function textSetup()
	{
		txtInd = -1;
		if (onScreenText != null)
			remove(onScreenText);

		onScreenText = new FlxText(10, frameY + 30, 2000, '', 32);
		onScreenText.font = 'Pixel Arial 11 Bold';
		onScreenText.color = 0xFFFFFFFF;

		add(onScreenText);

		state = 2;
		textNext();
	}

	function textNext()
	{
		txtInd ++;
		if (txtInd < dial.length)
		{
			read = dial[txtInd];
			mExp = expList[txtInd];
			mChange = true;
			charInd = 0;
			intChar = 0;
			lChar = 0;

			switch instList[txtInd]
			{
				case 'introMusic':
					FlxG.sound.playMusic(Paths.music('MASK/phantomIntro'));
					FlxG.sound.music.fadeIn(0, 1, 1);
				case 'musicStop':
					FlxG.sound.music.stop();
				case 'musicInit':
					musicInit();
				case 'songGood':
					badMenu.volume = 0;
					FlxG.sound.music.volume = 1;
					musicIsGood = true;

				case 'songScary':
					badMenu.volume = 1;
					FlxG.sound.music.volume = 0;
					musicIsGood = false;

				case 'fadeOut':
					FlxG.sound.music.fadeOut(1, 0);
				case 'fadeIn':
					FlxG.sound.music.volume = 1;
				case 'introAccept':
					FlxG.save.data.p_progress[0] = 2;
			}
		}
		else
		{
			remove(onScreenText);

			var p = getProgress();

			switch (afterAction)
			{
				case 'forceExit':
					FlxG.sound.music.stop();
					if (goodMenu != null)
						goodMenu.fadeOut(0.5, 0);
					Main.menuMusPlay = true;
					FlxG.switchState(new StoryMenuState());
				case 'exit':
					trace(FlxG.save.data.p_partsGiven, p);
					if (FlxG.save.data.p_partsGiven < p)
					{
						loadData('forgor');
						textSetup();
					}
					else
					{
						FlxG.sound.music.stop();
						FlxG.save.flush();
						if (goodMenu != null)
							goodMenu.fadeOut(0.5, 0);
						Main.menuMusPlay = true;
						FlxG.switchState(new StoryMenuState());
					}

				case 'menu' | 'markReplace':
					renderOptions = [];
					for (i in 0...optList.length)
					{
						var ind = FlxG.save.data.p_progress[i + 1];
						if (ind > p - 1) ind = p - 1;
						if (ind > 2) ind = 2;
						renderOptions.push(optList[i][ind]);
					}
					updateOptions();
					state = 3;

					if (FlxG.save.data.p_partsGiven < p && FlxG.save.data.p_partsGiven != 0)
					{
						state = 5;
					}

					if (afterAction == 'markReplace') FlxG.save.data.p_first[nid[afterData[0]]] = false;
				case 'prompt':
					renderOptions = [afterData[0], afterData[1]];
					updateOptions();
					optSelect = 0;
					state = 4;
				case 'continue':
					loadData(afterData[0]);
					textSetup();

				//hardcode argghh >>>>>:((((
				case 'facePartsIntro':
					hintLoad();
				case 'forgotPart':
					chucha = true;
					state = 5;
			}
		}
	}

	public static function getProgress():Int
	{
		var p = 0;
		for (i in 0...FlxG.save.data.p_maskGot.length)
		{
			if (FlxG.save.data.p_maskGot[i])
				p ++;
		}
		return(p);
	}

	function getInterest():Int
	{
		var p:Float = 0;
		for (i in 1...4)
		{
			p += FlxG.save.data.p_progress[i];
		}
		return(Std.int(p));
	}
	var pause = 0;
	var vc:FlxSound;
	function textStep()
	{
		//Advancing text if there's no current pause
		if (pause <= 0)
		{
			charInd += txtSpeed;
			mTalk = true;

			//Limiting
			if (charInd > read.length - 1)
			{
				mTalk = false;
				charInd = read.length - 1;
			}
		}
		else
		{
			pause --;
		}
		intChar = Std.int(Math.floor(charInd));

		//Helpful strings
		var newtxt = read.substr(0, intChar + 1);
		var charat = read.substr(intChar, 1);
		var nextChar = read.substr(intChar + 1, 1);

		//Pauses, sounds, etc
		if (intChar > lChar)
		{
			switch (charat)
			{
				case ',':
					pause = 10;
				case '!' | '?':
					if (nextChar == ' ')
						pause = 20;
				case '.':
					if (nextChar == ' ')
						pause = 30;
			}
			if (charat != ' ')
			{
				if (vc != null)
					vc.stop;
				vc = new FlxSound().loadEmbedded(Paths.sound('voice/defB', 'shared'));
				vc.play();
			}
		}	

		//Updating display text
		onScreenText.text = newtxt;

		//xd
		lChar = intChar;

		//Press start to pair bluetooth device is ready to peir
		if (FlxG.keys.justPressed.ANY)
		{
			if (intChar == read.length - 1)
			{
				textNext();
			}
			else
			{
				charInd = read.length - 1;
			}
		}
		#if debug
		if (FlxG.keys.justPressed.ONE)
		{
			txtInd = dial.length - 1;
			textNext();
		}
		#end
	}

	function pathGet():String
	{
		return(TextData.getLanPrefix() + '_phantom/');
	}

	function loadData(index:String):Int
	{
		var prog = FlxG.save.data.p_progress;
		var path = pathGet();
		var rChoose = false;

		switch (index)
		{
			case 'intro':
				path += 'intro/';
				switch (prog[0])
				{
					case 0:
						path += 'first/intro';
					case 1:
						path += 'reco/ask';
					default:
						rChoose = true;
						path = TextData.getLanPrefix() + '_phantom/welcome';
				}
			case 'intro/first/followups/sad':
				FlxG.save.data.p_progress[0] = 1;
				path += index;
				trace('hardcode ññññaaarghh');
			case 'exit':
				rChoose = true;
				path += 'exit';
			case 'howManyLeft':
				var left = 4 - getProgress();
				var pin = getInterest();

				path += 'give/';

				if (!chucha)
				{
					path += left + 'left';
				}
				else
				{
					//I am never going to code something like this ever again (maybe)
					if (collectAmmo == 1)
					{
						path += left + 'left';
					}
					else if (collectAmmo == 4)
					{
						path += 'all';
						if (pin < 4)
						{
							path += '_N';
						}
					}
					else
					{
						path += 'lot';
						if (pin < 3)
						{
							path += '_N';
						}
					}
				}

				chucha = false;
			default:
				path += index;
		}

		dial = [];
		expList = [];
		instList = [];

		var txtList = CoolUtil.coolTextFile(Paths.txt(path));

		var after:Array<String> = txtList[0].split(":");

		afterAction = after[0];
		switch (afterAction)
		{
			case 'prompt':
				afterData = [after[1], after[2], after[3], after[4]];

			case 'markReplace':
				if (FlxG.save.data.p_first[nid[after[1]]])
				{
					afterData = [after[1], after[2]];
				}
				else
				{
					loadData(after[2]);
					return(0);
				}
			default:
				afterData = [];
				for (i in 1...after.length)
				{
					afterData.push(after[i]);
				}
		}

		if (!rChoose)
		{
			for (i in 1...txtList.length)
			{
				var data:Array<String> = txtList[i].split(":");
				dial.push(StringTools.replace(data[1], '#', '\n'));
				expList.push(data[0]);

				if (data.length > 2)
				{
					instList.push(data[2]);
				}
				else
				{
					instList.push('');
				}
			}
		}
		else
		{
			var addNext = true;
			var readSkip = 0;

			var ind = Std.int(Math.round(Math.random() * (txtList.length - 2)) + 1);

			while (addNext)
			{
				addNext = false;

				var data:Array<String> = txtList[ind + readSkip].split(":");

				if (readSkip == 0 && data.length > 2)
				{
					while (data.length > 2 && data[2] == 'tied')
					{
						ind = Std.int(Math.round(Math.random() * (txtList.length - 2)) + 1);
						data = txtList[ind + readSkip].split(":");
					}
				}
				dial.push(StringTools.replace(data[1], '#', '\n'));
				expList.push(data[0]);

				if (data.length > 2)
				{
					instList.push(data[2]);
					if (data[2] == 'addNext')
					{
						addNext = true;
						readSkip ++;
					}
				}
				else
				{
					instList.push('');
				}
			}
		}

		return(0);
	}
}
