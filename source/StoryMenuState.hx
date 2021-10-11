package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;

using StringTools;

class StoryMenuState extends MusicBeatState
{
	// Wether you have to beat the previous week for playing this one
	// Not recommended, as people usually download your mod for, you know,
	// playing just the modded week then delete it.
	// defaults to True
	public static var weekUnlocked:Array<Bool> = [
		true,	//Tutorial
		true,	//Week 1
		true,	//Week 2
		true,	//Week 3
		true,	//Week 4
		true,	//Week 5
		true,	//Week 6
		true
	];

	//It works like this:
	// ['Left character', 'Center character', 'Right character']
	var weekCharacters:Array<Dynamic> = [
		['shaggy', 'bf', 'gf'],
		['shaggy', 'bf', 'gf'],
		['pshaggy', 'bf', 'gf'],
		['shaggymatt', 'bf', 'gf'],
		['rshaggy', 'bf', 'gf'],
		['wbshaggy', 'bf', 'gf'],
		['', 'bf', 'gf']
	];

	//The week's name, displayed on top-right
	var weekNames:Array<String> = [
		"First encounter",
		"The rematch",
		"Ultimate destruction",
		"Cruel revelation",
		"Bonus match",
		"Special Kombat with the third of his kind",
		"BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB"
	];

	//Background asset name, the background files are stored on assets/preload/menubackgrounds/
	var weekBackground:Array<String> = [
		'halloween',		
		'halloween',
		'sky',
		'boxin',
		'outside',
		'lava',
		'blank'
	];
	
	var scoreText:FlxText;

	private static var curDifficulty:Int = 1;

	var txtWeekTitle:FlxText;
	var bgSprite:FlxSprite;

	private static var curWeek:Int = 0;

	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var difficultySelectors:FlxGroup;
	var sprDifficultyGroup:FlxTypedGroup<FlxSprite>;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	var zephGfx:MenuItem;

	var zephMenu:FlxSprite;

	var moNotice:FlxText;

	override function create()
	{
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		scoreText = new FlxText(10, 10, 0, "SCORE: 49324858", 36);
		scoreText.setFormat("VCR OSD Mono", 32);

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

		moNotice = new FlxText(FlxG.width * 0.7, 600, 0, "", 32);
		moNotice.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, RIGHT);

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("vcr.ttf"), 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		bgSprite = new FlxSprite(0, 56);
		bgSprite.antialiasing = ClientPrefs.globalAntialiasing;

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		if (Main.menuMusPlay)
		{
			new FlxTimer().start(0.5, function(tmr:FlxTimer)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				FlxG.sound.music.fadeIn(1, 0.1, 1);
				Main.menuMusPlay = false;
			});
		}

		var zInclude = 0;
		if (MASKstate.getProgress() > 0 && FlxG.save.data.p_progress[4] == 0) zInclude = 1;
		if (FlxG.save.data.ending[2]) zInclude = 0;

		for (i in 0...(WeekData.songsNames.length - (1 - zInclude)))
		{
			var weekThing:MenuItem = new MenuItem(0, bgSprite.y + 396, i);
			weekThing.y += ((weekThing.height + 20) * i);
			weekThing.targetY = i;
			grpWeekText.add(weekThing);

			if (i == 6) zephGfx = weekThing;

			weekThing.screenCenter(X);
			weekThing.antialiasing = ClientPrefs.globalAntialiasing;
			// weekThing.updateHitbox();

			// Needs an offset thingie
			if (i < weekUnlocked.length && !weekUnlocked[i])
			{
				var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
				lock.frames = ui_tex;
				lock.animation.addByPrefix('lock', 'lock');
				lock.animation.play('lock');
				lock.ID = i;
				lock.antialiasing = ClientPrefs.globalAntialiasing;
				grpLocks.add(lock);
			}
		}

		for (char in 0...3)
		{
			var weekCharacterThing:MenuCharacter = new MenuCharacter((FlxG.width * 0.25) * (1 + char) - 150, weekCharacters[0][char]);
			weekCharacterThing.y += 70;
			weekCharacterThing.antialiasing = ClientPrefs.globalAntialiasing;
			grpWeekCharacters.add(weekCharacterThing);
		}

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		leftArrow = new FlxSprite(grpWeekText.members[0].x + grpWeekText.members[0].width + 10, grpWeekText.members[0].y + 40);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		leftArrow.antialiasing = ClientPrefs.globalAntialiasing;
		difficultySelectors.add(leftArrow);

		sprDifficultyGroup = new FlxTypedGroup<FlxSprite>();
		add(sprDifficultyGroup);

		
		for (i in 0...CoolUtil.difficultyStuff.length) {
			var sprDifficulty:FlxSprite = new FlxSprite(leftArrow.x + 35, leftArrow.y).loadGraphic(Paths.image('menudifficulties/' + CoolUtil.difficultyStuff[i][0].toLowerCase()));
			sprDifficulty.x += (308 - sprDifficulty.width) / 2;
			sprDifficulty.ID = i;
			sprDifficulty.antialiasing = ClientPrefs.globalAntialiasing;
			sprDifficultyGroup.add(sprDifficulty);
		}

		difficultySelectors.add(sprDifficultyGroup);

		rightArrow = new FlxSprite(leftArrow.x + 340, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		rightArrow.antialiasing = ClientPrefs.globalAntialiasing;
		difficultySelectors.add(rightArrow);

		add(bgSprite);
		add(grpWeekCharacters);

		if (FlxG.save.data.p_partsGiven >= 4 && !FlxG.save.data.ending[2])
		{
			zephMenu = new FlxSprite(200, 40).loadGraphic(Paths.image('menucharacters/zephyrus'));
			zephMenu.scale.x = 0.75;
			zephMenu.scale.y = 0.75;
			zephMenu.antialiasing = true;
			add(zephMenu);
		}

		var coverUp:FlxSprite = new FlxSprite(0, 443).makeGraphic(400, 1280, FlxColor.BLACK);
		add(coverUp);

		var tracksSprite:FlxSprite = new FlxSprite(FlxG.width * 0.07, bgSprite.y + 435).loadGraphic(Paths.image('Menu_Tracks'));
		tracksSprite.antialiasing = ClientPrefs.globalAntialiasing;
		add(tracksSprite);

		txtTracklist = new FlxText(FlxG.width * 0.05, tracksSprite.y + 60, 0, "", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = rankText.font;
		txtTracklist.color = 0xFFe55777;
		add(txtTracklist);
		// add(rankText);
		add(scoreText);
		add(txtWeekTitle);
		add(moNotice);

		changeDifficulty();

		if (Main.menuBad)
		{
			curWeek = 2;
		}
		changeWeek();

		super.create();
	}

	override function closeSubState() {
		persistentUpdate = true;
		changeWeek();
		super.closeSubState();
	}

	var ztime = 0;
	override function update(elapsed:Float)
	{
		Main.skipDes = false;
		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 30, 0, 1)));
		if(Math.abs(intendedScore - lerpScore) < 10) lerpScore = intendedScore;

		scoreText.text = "WEEK SCORE:" + lerpScore;

		if (zephMenu != null)
		{
			ztime ++;
			zephMenu.x = 800;
			zephMenu.y = 40 + Math.sin(ztime / 60) * 10;
		}

		moNotice.text = "";
		if (curWeek == 1)
		{
			moNotice.text = "First song has copyright :(\nPress P for drums cover\n";
			if (Main.drums) moNotice.text += "(drums cover active)\n";

			if (FlxG.keys.justPressed.P)
			{
				Main.drums = !Main.drums;
				if (Main.drums) FlxG.sound.play(Paths.sound('cancelMenu'));
				else FlxG.sound.play(Paths.sound('scrollMenu'));
			}
		}

		// FlxG.watch.addQuick('font', scoreText.font);

		difficultySelectors.visible = weekUnlocked[curWeek];

		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpWeekText.members[lock.ID].y;
		});

		if (!movedBack && !selectedWeek)
		{
			if (controls.UI_UP_P)
			{
				changeWeek(-1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if (controls.UI_DOWN_P)
			{
				changeWeek(1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if (controls.UI_RIGHT)
				rightArrow.animation.play('press')
			else
				rightArrow.animation.play('idle');

			if (controls.UI_LEFT)
				leftArrow.animation.play('press');
			else
				leftArrow.animation.play('idle');

			if (controls.UI_RIGHT_P)
				changeDifficulty(1);
			if (controls.UI_LEFT_P)
				changeDifficulty(-1);

			if (controls.ACCEPT)
			{
				selectWeek();
			}
			else if(controls.RESET)
			{
				persistentUpdate = false;
				openSubState(new ResetScoreSubState('', curDifficulty, '', curWeek));
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			MusicBeatState.switchState(new MainMenuState());
		}

		if (zephGfx != null)
		{
			zephGfx.scale.x = 0.2 + 0.5 * Math.random();
			zephGfx.scale.y = 0.75 + 0.5 * Math.random();

			if (Math.random() > 0.5) zephGfx.scale.x *= -1;
			if (Math.random() > 0.5) zephGfx.scale.y *= -1;
			
			if (FlxG.save.data.p_progress[0] == 0)
			if (Math.random() > 0.9) zephGfx.scale.y *= 4;
		}
		//bullShit ++;

		super.update(elapsed);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (curWeek >= weekUnlocked.length || weekUnlocked[curWeek])
		{
			switch (curWeek)
			{
				case 3:
					CoolUtil.browserLoad('https://gamejolt.com/games/fnf-shaggy-matt/648032');
				case 6:
					MusicBeatState.switchState(new MASKstate());
				default:
					trace(curDifficulty, WeekData.maniaSongs[curWeek]);
					if (curDifficulty != 0 || WeekData.maniaSongs[curWeek][0] != '')
					{
						if (stopspamming == false)
						{
							FlxG.sound.play(Paths.sound('confirmMenu'));

							grpWeekText.members[curWeek].startFlashing();
							grpWeekCharacters.members[1].animation.play('confirm');
							stopspamming = true;
						}

						// We can't use Dynamic Array .copy() because that crashes HTML5, here's a workaround.
						var songArray:Array<String> = [];
						var leWeek:Array<Dynamic> = WeekData.songsNames[curWeek];

						if (curDifficulty == 0)
						{
							leWeek = WeekData.maniaSongs[curWeek];
						}

						for (i in 0...leWeek.length) {
							songArray.push(leWeek[i]);
						}

						// I'm a motherfucking genious
						PlayState.storyPlaylist = songArray;
						PlayState.isStoryMode = true;
						selectedWeek = true;

						var diffic = CoolUtil.difficultyStuff[curDifficulty][1];
						if(diffic == null) diffic = '';

						PlayState.storyDifficulty = curDifficulty;

						PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
						PlayState.storyWeek = curWeek;
						PlayState.campaignScore = 0;
						PlayState.campaignMisses = 0;
						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							LoadingState.loadAndSwitchState(new PlayState(), true);
							FreeplayState.destroyFreeplayVocals();
						});
					}
			}
		}
	}

	function changeDifficulty(change:Int = 0):Void
	{
		var lDif = curDifficulty;
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficultyStuff.length-1;
		if (curDifficulty >= CoolUtil.difficultyStuff.length)
			curDifficulty = 0;

		if (lDif == 0 || curDifficulty == 0)
		{
			updateText();
		}
		//updateText();

		sprDifficultyGroup.forEach(function(spr:FlxSprite) {
			spr.visible = false;
			if(curDifficulty == spr.ID) {
				spr.visible = true;
				spr.alpha = 0;
				spr.y = leftArrow.y - 15;
				FlxTween.tween(spr, {y: leftArrow.y + 10 + 33 - spr.height / 2, alpha: 1}, 0.07);
			}
		});

		#if !switch
		intendedScore = Highscore.getWeekScore(WeekData.getWeekNumber(curWeek), curDifficulty);
		#end
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		var zSub = 1;
		if (MASKstate.getProgress() > 0 && FlxG.save.data.p_progress[4] == 0) zSub = 0;
		if (FlxG.save.data.ending[2]) zSub = 1;

		if (curWeek > WeekData.songsNames.length - 1 - zSub)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = WeekData.songsNames.length - 1 - zSub;

		var leName:String = '';
		if(curWeek < weekNames.length) {
			leName = weekNames[curWeek];
		}

		txtWeekTitle.text = leName.toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		var bullShit:Int = 0;

		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == Std.int(0) && weekUnlocked[curWeek])
				item.alpha = 1;
			else
				item.alpha = 0.6;

			bullShit++;
		}

		var assetName:String = weekBackground[0];
		if(curWeek < weekBackground.length) assetName = weekBackground[curWeek];

		bgSprite.loadGraphic(Paths.image('menubackgrounds/menu_' + assetName));
		updateText();
	}

	function updateText()
	{
		var weekArray:Array<String> = weekCharacters[0];
		if(curWeek < weekCharacters.length) weekArray = weekCharacters[curWeek];

		for (i in 0...grpWeekCharacters.length) {
			grpWeekCharacters.members[i].changeCharacter(weekArray[i]);
		}

		var stringThing:Array<String> = WeekData.songsNames[curWeek];

		if (curDifficulty == 0)
		{
			stringThing = WeekData.maniaSongs[curWeek];
		}

		txtTracklist.text = '';
		for (i in 0...stringThing.length)
		{
			txtTracklist.text += stringThing[i] + '\n';
		}

		txtTracklist.text = StringTools.replace(txtTracklist.text, '-', ' ');
		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;

		#if !switch
		intendedScore = Highscore.getWeekScore(WeekData.getWeekNumber(curWeek), curDifficulty);
		#end
	}
}
