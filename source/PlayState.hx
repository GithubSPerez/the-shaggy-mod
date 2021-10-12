package;

#if desktop
import Discord.DiscordClient;
#end
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import openfl.media.Video;
import Achievements;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class PlayState extends MusicBeatState
{
	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;

	public static var ratingStuff:Array<Dynamic> = [
		['You Suck!', 0.2], //From 0% to 19%
		['Shit', 0.4], //From 20% to 39%
		['Bad', 0.5], //From 40% to 49%
		['Bruh', 0.6], //From 50% to 59%
		['Meh', 0.69], //From 60% to 68%
		['Nice', 0.7], //69%
		['Good', 0.8], //From 70% to 79%
		['Great', 0.9], //From 80% to 89%
		['Sick!', 1], //From 90% to 99%
		['Perfect!!', 1] //The value on this one isn't used actually, since Perfect is always "1"
	]; 

	//event variables
	private var isCameraOnForcedPos:Bool = false;
	#if (haxe >= "4.0.0")
	public var boyfriendMap:Map<String, Boyfriend> = new Map();
	public var dadMap:Map<String, Character> = new Map();
	public var gfMap:Map<String, Character> = new Map();
	#else
	public var boyfriendMap:Map<String, Boyfriend> = new Map<String, Boyfriend>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	#end

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var boyfriendGroup:FlxTypedGroup<Boyfriend>;
	public var backGroup:FlxTypedGroup<FlxTrail>;
	public var dadGroup:FlxTypedGroup<Character>;
	public var gfGroup:FlxTypedGroup<Character>;

	public static var curStage:String = '';
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	public var vocals:FlxSound;

	public var dad:Character;
	public var gf:Character;
	public var boyfriend:Boyfriend;
	public static var bfAccess:Boyfriend;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<Dynamic> = [];

	private var strumLine:FlxSprite;
	private var curSection:Int = 0;

	//Handles the new epic mega sexy cam code that i've done
	private var camFollow:FlxPoint;
	private var camFollowPos:FlxObject;
	private static var prevCamFollow:FlxPoint;
	private static var prevCamFollowPos:FlxObject;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public static var maskMouseHud:FlxTypedGroup<FlxSprite>;
	public static var maskCollGroup:FlxTypedGroup<MASKcoll>;
	public static var maskTrailGroup:FlxTypedGroup<FlxTrail>; //FUCK.
	public static var maskFxGroup:FlxTypedGroup<FlxSprite>;

	private var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;
	private var health:Float = 1;
	private var combo:Int = 0;

	private var healthBarBG:AttachedSprite;
	public var healthBar:FlxBar;
	var songPercent:Float = 0;

	private var timeBarBG:FlxSprite;
	private var timeBar:FlxBar;

	private var generatedMusic:Bool = false;
	private var endingSong:Bool = false;
	private var startingSong:Bool = false;
	private var updateTime:Bool = false;
	public static var practiceMode:Bool = false;
	public static var usedPractice:Bool = false;
	public static var changedDifficulty:Bool = false;
	public static var cpuControlled:Bool = false;

	var botplaySine:Float = 0;
	var botplayTxt:FlxText;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	var dchar:Array<String>;
	var dface:Array<String>;
	var dside:Array<Int>;

	var halloweenBG:BGSprite;
	var halloweenWhite:BGSprite;

	var phillyCityLights:FlxTypedGroup<BGSprite>;
	var phillyTrain:BGSprite;
	var phillyBlack:BGSprite;
	var phillyBlackTween:FlxTween;
	var phillyCityLightsEvent:FlxTypedGroup<BGSprite>;
	var phillyCityLightsEventTween:FlxTween;
	var trainSound:FlxSound;

	var limoKillingState:Int = 0;
	var limo:BGSprite;
	var limoMetalPole:BGSprite;
	var limoLight:BGSprite;
	var limoCorpse:BGSprite;
	var limoCorpseTwo:BGSprite;
	var bgLimo:BGSprite;
	var grpLimoParticles:FlxTypedGroup<BGSprite>;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:BGSprite;

	var upperBoppers:BGSprite;
	var bottomBoppers:BGSprite;
	var santa:BGSprite;
	var heyTimer:Float;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();
	var bgGhouls:BGSprite;

	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var scoreTxt:FlxText;
	var timeTxt:FlxText;
	var scoreTxtTween:FlxTween;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;

	public var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	public var inCutscene:Bool = false;
	var songLength:Float = 0;
	public static var displaySongName:String = "";

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	var luaArray:Array<FunkinLua> = [];

	//Achievement shit
	var keysPressed:Array<Bool> = [false, false, false, false];
	var boyfriendIdleTime:Float = 0.0;
	var boyfriendIdled:Bool = false;

	// Lua shit
	public var backgroundGroup:FlxTypedGroup<FlxSprite>;
	public var foregroundGroup:FlxTypedGroup<FlxSprite>;

	//// My shiaatt

	//general
	var songEnded:Bool = false;

	//more keys
	public static var mania = 0;

	//shaggg
	var rock:FlxSprite;
	var gf_rock:FlxSprite;
	var doorFrame:FlxSprite;
	var legs:FlxSprite;
	var shaggyT:FlxTrail;
	var legT:FlxTrail;
	var burst:FlxSprite;

	//cum
	var camLerp:Float = 1;
	var bgDim:FlxSprite;
	var dimGo:Bool = false;

	//cutscenxs
	var cutTime = 0;
	var sEnding = 'none';

	//bgggg
	public static var bgTarget = 0;
	public static var bgEdit = false;

	//zephyrus ete zeph
	var zeph:FlxSprite;
	var zephScreen:FlxSprite;
	var zephState:Int = 0;
	var zephAddX:Float = 0;
	var zephAddY:Float = 0;
	var zLockX:Float = 0;
	var zLockY:Float = 0;

	override public function create()
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		rotCam = false;
		camera.angle = 0;

		practiceMode = false;
		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camOther);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		FlxCamera.defaultCameras = [camGame];
		//FlxG.cameras.setDefaultDrawTarget(camGame, true);

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		mania = SONG.mania;

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		var songName:String = SONG.song;
		displaySongName = StringTools.replace(songName, '-', ' ');

		#if desktop
		storyDifficultyText = '' + CoolUtil.difficultyStuff[storyDifficulty][0];

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			var weekCustomName = 'Week ' + storyWeek;
			if(WeekData.weekResetName[storyWeek] != null)
				weekCustomName = '' + WeekData.weekResetName[storyWeek];
			else if(WeekData.weekNumber[storyWeek] != null)
				weekCustomName = 'Week ' + WeekData.weekNumber[storyWeek];

			detailsText = "Story Mode: " + weekCustomName;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end

		switch (SONG.song.toLowerCase())
		{
			case 'where-are-you' | 'eruption' | 'kaio-ken' | 'whats-new' | 'blast' | 'super-saiyan' | 'overflow':
				defaultCamZoom = 0.9;
				curStage = 'mansion';
				var bg:FlxSprite = new FlxSprite(-400, -160).loadGraphic(Paths.image('bg_lemon'));
				bg.setGraphicSize(Std.int(bg.width * 1.5));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.95, 0.95);
				bg.active = false;
				add(bg);
			case 'god-eater':
				defaultCamZoom = 0.65;
				curStage = 'sky';

				var sky = new FlxSprite(-850, -850);
				sky.frames = Paths.getSparrowAtlas('god_bg');
				sky.animation.addByPrefix('sky', "bg", 30);
				sky.setGraphicSize(Std.int(sky.width * 0.8));
				sky.animation.play('sky');
				sky.scrollFactor.set(0.1, 0.1);
				sky.antialiasing = true;
				add(sky);

				var bgcloud = new FlxSprite(-850, -1250);
				bgcloud.frames = Paths.getSparrowAtlas('god_bg');
				bgcloud.animation.addByPrefix('c', "cloud_smol", 30);
				//bgcloud.setGraphicSize(Std.int(bgcloud.width * 0.8));
				bgcloud.animation.play('c');
				bgcloud.scrollFactor.set(0.3, 0.3);
				bgcloud.antialiasing = true;
				add(bgcloud);

				add(new MansionDebris(300, -800, 'norm', 0.4, 1, 0, 1));
				add(new MansionDebris(600, -300, 'tiny', 0.4, 1.5, 0, 1));
				add(new MansionDebris(-150, -400, 'spike', 0.4, 1.1, 0, 1));
				add(new MansionDebris(-750, -850, 'small', 0.4, 1.5, 0, 1));

				/*
				add(new MansionDebris(-300, -1700, 'norm', 0.5, 1, 0, 1));
				add(new MansionDebris(-600, -1100, 'tiny', 0.5, 1.5, 0, 1));
				add(new MansionDebris(900, -1850, 'spike', 0.5, 1.2, 0, 1));
				add(new MansionDebris(1500, -1300, 'small', 0.5, 1.5, 0, 1));
				*/

				add(new MansionDebris(-300, -1700, 'norm', 0.75, 1, 0, 1));
				add(new MansionDebris(-1000, -1750, 'rect', 0.75, 2, 0, 1));
				add(new MansionDebris(-600, -1100, 'tiny', 0.75, 1.5, 0, 1));
				add(new MansionDebris(900, -1850, 'spike', 0.75, 1.2, 0, 1));
				add(new MansionDebris(1500, -1300, 'small', 0.75, 1.5, 0, 1));
				add(new MansionDebris(-600, -800, 'spike', 0.75, 1.3, 0, 1));
				add(new MansionDebris(-1000, -900, 'small', 0.75, 1.7, 0, 1));

				var fgcloud = new FlxSprite(-1150, -2900);
				fgcloud.frames = Paths.getSparrowAtlas('god_bg');
				fgcloud.animation.addByPrefix('c', "cloud_big", 30);
				//bgcloud.setGraphicSize(Std.int(bgcloud.width * 0.8));
				fgcloud.animation.play('c');
				fgcloud.scrollFactor.set(0.9, 0.9);
				fgcloud.antialiasing = true;
				add(fgcloud);

				var bg:FlxSprite = new FlxSprite(-400, -160).loadGraphic(Paths.image('bg_lemon'));
				bg.setGraphicSize(Std.int(bg.width * 1.5));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.95, 0.95);
				bg.active = false;
				add(bg);

				var techo = new FlxSprite(0, -20);
				techo.frames = Paths.getSparrowAtlas('god_bg');
				techo.animation.addByPrefix('r', "broken_techo", 30);
				techo.setGraphicSize(Std.int(techo.frameWidth * 1.5));
				techo.animation.play('r');
				techo.scrollFactor.set(0.95, 0.95);
				techo.antialiasing = true;
				add(techo);

				gf_rock = new FlxSprite(20, 20);
				gf_rock.frames = Paths.getSparrowAtlas('god_bg');
				gf_rock.animation.addByPrefix('rock', "gf_rock", 30);
				gf_rock.animation.play('rock');
				gf_rock.scrollFactor.set(0.8, 0.8);
				gf_rock.antialiasing = true;
				add(gf_rock);

				rock = new FlxSprite(20, 20);
				rock.frames = Paths.getSparrowAtlas('god_bg');
				rock.animation.addByPrefix('rock', "rock", 30);
				rock.animation.play('rock');
				rock.scrollFactor.set(1, 1);
				rock.antialiasing = true;
				add(rock);

				//god eater legs
				legs = new FlxSprite(-850, -850);
				legs.frames = Paths.getSparrowAtlas('characters/pshaggy');
				legs.animation.addByPrefix('legs', "solo_legs", 30);
				legs.animation.play('legs');
				legs.antialiasing = true;
				legs.updateHitbox();
				legs.offset.set(legs.frameWidth / 2, 10);
				legs.alpha = 0;
			case 'astral-calamity' | 'talladega':
				defaultCamZoom = 0.56;
				if (SONG.song == 'Talladega') defaultCamZoom = 0.6;

				curStage = 'lava';

				var bgbg:BGElement = new BGElement('WBG/BGBG', -1940, -1112, 0.5, 1, 0);
				add(bgbg);

				var lavaLimits:BGElement = new BGElement('WBG/LavaLimits', -1770, 168, 0.55, 1, 1);
				add(lavaLimits);

				var bgSpikes:BGElement = new BGElement('WBG/BGSpikes', 112, -36, 0.6, 1, 2);
				add(bgSpikes);

				var spikes:BGElement = new BGElement('WBG/Spikes', -1186, -234, 0.8, 1, 3);
				add(spikes);

				var ground:BGElement = new BGElement('WBG/Ground', -1320, 590, 1, 1, 4);
				add(ground);
			case 'soothing-power' | 'thunderstorm' | 'dissasembler':
				defaultCamZoom = 0.8;
				curStage = 'out';

				var sky:BGElement = new BGElement('OBG/sky', -1204, -456, 0.15, 1, 0);
				add(sky);

				var clouds:BGElement = new BGElement('OBG/clouds', -988, -260, 0.25, 1, 1);
				add(clouds);

				var backMount:BGElement = new BGElement('OBG/backmount', -700, -40, 0.4, 1, 2);
				add(backMount);

				var middleMount:BGElement = new BGElement('OBG/middlemount', -240, 200, 0.6, 1, 3);
				add(middleMount);

				var ground:BGElement = new BGElement('OBG/ground', -660, 624, 1, 1, 4);
				add(ground);
			default:
				defaultCamZoom = 0.9;
				curStage = 'stage';
				var bg:BGSprite = new BGSprite('stageback', -600, -200, 0.9, 0.9);
				add(bg);

				var stageFront:BGSprite = new BGSprite('stagefront', -650, 600, 0.9, 0.9);
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				add(stageFront);

				if(!ClientPrefs.lowQuality) {
					var stageLight:BGSprite = new BGSprite('stage_light', -125, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					add(stageLight);
					var stageLight:BGSprite = new BGSprite('stage_light', 1225, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					stageLight.flipX = true;
					add(stageLight);

					var stageCurtains:BGSprite = new BGSprite('stagecurtains', -500, -300, 1.3, 1.3);
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					add(stageCurtains);
				}
		}

		backgroundGroup = new FlxTypedGroup<FlxSprite>();
		add(backgroundGroup);

		var gfVersion:String = SONG.player3;
		if(gfVersion == null || gfVersion.length < 1) {
			switch (curStage)
			{
				case 'limo':
					gfVersion = 'gf-car';
				case 'mall' | 'mallEvil':
					gfVersion = 'gf-christmas';
				case 'school' | 'schoolEvil':
					gfVersion = 'gf-pixel';
				default:
					gfVersion = 'gf';
			}
			SONG.player3 = gfVersion; //Fix for the Chart Editor
		}

		boyfriendGroup = new FlxTypedGroup<Boyfriend>();
		backGroup = new FlxTypedGroup<FlxTrail>();
		dadGroup = new FlxTypedGroup<Character>();
		gfGroup = new FlxTypedGroup<Character>();

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'limo':
				BF_Y -= 220;
				BF_X += 260;

			case 'mall':
				BF_X += 200;

			case 'mallEvil':
				BF_X += 320;
				DAD_Y -= 80;
			case 'school':
				BF_X += 200;
				BF_Y += 220;
				GF_X += 180;
				GF_Y += 300;
			case 'schoolEvil':
				BF_X += 200;
				BF_Y += 220;
				GF_X += 180;
				GF_Y += 300;
			case 'lava':
				BF_X += 350;
				BF_Y += 60;
				DAD_X -= 400;
				DAD_Y -= 400;
				if (SONG.player2 != 'wbshaggy')
				{
					DAD_Y += 400;
				}
			case 'out':
				BF_X += 300;
				BF_Y += 10;
				GF_X += 70;
				DAD_X -= 100;
		}

		gf = new Character(GF_X, GF_Y, gfVersion);
		gf.x += gf.positionArray[0];
		gf.y += gf.positionArray[1];
		//gf.scrollFactor.set(0.95, 0.95);
		gfGroup.add(gf);

		dad = new Character(DAD_X, DAD_Y, SONG.player2);
		dad.x += dad.positionArray[0];
		dad.y += dad.positionArray[1];
		dadGroup.add(dad);

		scoob = new Character(9000, 290, 'scooby', false);

		boyfriend = new Boyfriend(BF_X, BF_Y, SONG.player1);
		bfAccess = boyfriend;
		boyfriend.x += boyfriend.positionArray[0];
		boyfriend.y += boyfriend.positionArray[1];

		if (FlxG.save.data.p_partsGiven >= 4 && SONG.player2 != 'zshaggy' && !FlxG.save.data.ending[2] && isStoryMode)
		{
			zeph = new FlxSprite().loadGraphic(Paths.image('MASK/zephyrus', 'shared'));
			zeph.updateHitbox();
			zeph.antialiasing = true;
			zeph.x = -2000;
			zephScreen = new FlxSprite().makeGraphic(4000, 4000, FlxColor.BLACK);
			zephScreen.scrollFactor.set(0, 0);
		}

		boyfriendGroup.add(boyfriend);
		
		var camPos:FlxPoint = new FlxPoint(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y);
		camPos.x += gf.cameraPosition[0];
		camPos.y += gf.cameraPosition[1];

		if(dad.curCharacter.startsWith('gf')) {
			dad.setPosition(GF_X, GF_Y);
			gf.visible = false;
			if (isStoryMode)
			{
				camPos.x += 300;
				camPos.y -= 30;
				tweenCamIn();
			}
		}

		switch(curStage)
		{
			case 'limo':
				resetFastCar();
				add(fastCar);
			
			case 'schoolEvil':
				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
				add(evilTrail);
		}

		add(gfGroup);

		if (SONG.player2 == 'sshaggy')
		{
			shaggyT = new FlxTrail(dad, null, 3, 6, 0.3, 0.002);
			shaggyT.visible = false;
			add(shaggyT);
			camLerp = 2;
		}
		else if (SONG.player2 == 'pshaggy')
		{
			shaggyT = new FlxTrail(dad, null, 5, 7, 0.3, 0.001);
			add(shaggyT);

			legT = new FlxTrail(legs, null, 5, 7, 0.3, 0.001);
			add(legT);
		}

		doorFrame = new FlxSprite(-160, 160).loadGraphic(Paths.image('doorframe'));
		doorFrame.updateHitbox();
		doorFrame.setGraphicSize(1);
		doorFrame.alpha = 0;
		doorFrame.antialiasing = true;
		doorFrame.scrollFactor.set(1, 1);
		doorFrame.active = false;
		add(doorFrame);

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);

		if (curStage == 'sky')
		{
			add(legs);
		}

		add(backGroup);
		add(dadGroup);
		if (zeph != null) add(zeph);
		add(boyfriendGroup);

		add(scoob);

		bgDim = new FlxSprite().makeGraphic(4000, 4000, FlxColor.BLACK);
		bgDim.scrollFactor.set(0);
		bgDim.screenCenter();
		bgDim.alpha = 0;
		add(bgDim);
		
		maskTrailGroup = new FlxTypedGroup<FlxTrail>();
		add(maskTrailGroup);

		maskFxGroup = new FlxTypedGroup<FlxSprite>();
		add(maskFxGroup);

		maskCollGroup = new FlxTypedGroup<MASKcoll>();
		add(maskCollGroup);

		foregroundGroup = new FlxTypedGroup<FlxSprite>();
		add(foregroundGroup);

		if(curStage == 'spooky') {
			add(halloweenWhite);
		}

		var lowercaseSong:String = SONG.song.toLowerCase();
		var file:String = Paths.txt(lowercaseSong + '/' + lowercaseSong + 'Dialogue');
		if (OpenFlAssets.exists(file)) {
			dialogue = CoolUtil.coolTextFile(file);
		}
		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;
		doof.nextDialogueThing = startNextDialogue;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, 50).makeGraphic(FlxG.width, 10);
		if(ClientPrefs.downScroll) strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();

		timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 20, 400, "", 32);
		timeTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = !ClientPrefs.hideTime;
		if(ClientPrefs.downScroll) timeTxt.y = FlxG.height - 45;

		timeBarBG = new FlxSprite(timeTxt.x, timeTxt.y + (timeTxt.height / 4)).loadGraphic(Paths.image('timeBar'));
		timeBarBG.scrollFactor.set();
		timeBarBG.alpha = 0;
		timeBarBG.visible = !ClientPrefs.hideTime;
		timeBarBG.color = FlxColor.BLACK;
		add(timeBarBG);

		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
			'songPercent', 0, 1);
		timeBar.scrollFactor.set();
		timeBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
		timeBar.numDivisions = 800; //How much lag this causes?? Should i tone it down to idk, 400 or 200?
		timeBar.alpha = 0;
		timeBar.visible = !ClientPrefs.hideTime;
		add(timeBar);
		add(timeTxt);

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);
		add(grpNoteSplashes);

		maskMouseHud = new FlxTypedGroup<FlxSprite>();
		add(maskMouseHud);

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.0;

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();

		// startCountdown();

		generateSong(SONG.song);

		// After all characters being loaded, it makes then invisible 0.01s later so that the player won't freeze when you change characters
		// add(strumLine);

		camFollow = new FlxPoint();
		camFollowPos = new FlxObject(0, 0, 1, 1);

		snapCamFollowToPos(camPos.x, camPos.y);
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		if (prevCamFollowPos != null)
		{
			camFollowPos = prevCamFollowPos;
			prevCamFollowPos = null;
		}
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new AttachedSprite('healthBar');
		healthBarBG.y = FlxG.height * 0.89;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.visible = !ClientPrefs.hideHud;
		healthBarBG.xAdd = -4;
		healthBarBG.yAdd = -4;
		add(healthBarBG);
		if(ClientPrefs.downScroll) healthBarBG.y = 0.11 * FlxG.height;

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		// healthBar
		healthBar.visible = !ClientPrefs.hideHud;
		add(healthBar);
		healthBarBG.sprTracker = healthBar;

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		iconP1.visible = !ClientPrefs.hideHud;
		add(iconP1);

		iconP2 = new HealthIcon(dad.healthIcon, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		iconP2.visible = !ClientPrefs.hideHud;
		add(iconP2);
		reloadHealthBarColors();

		scoreTxt = new FlxText(0, healthBarBG.y + 36, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.visible = !ClientPrefs.hideHud;
		add(scoreTxt);

		botplayTxt = new FlxText(400, timeBarBG.y + 55, FlxG.width - 800, "BOTPLAY", 32);
		botplayTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = cpuControlled;
		add(botplayTxt);
		if(ClientPrefs.downScroll) {
			botplayTxt.y = timeBarBG.y - 78;
		}

		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		botplayTxt.cameras = [camHUD];
		timeBar.cameras = [camHUD];
		timeBarBG.cameras = [camHUD];
		timeTxt.cameras = [camHUD];
		doof.cameras = [camHUD];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;
		updateTime = true;

		#if MODS_ALLOWED
		var doPush:Bool = false;
		var luaFile:String = 'data/' + PlayState.SONG.song.toLowerCase() + '/script.lua';
		if(sys.FileSystem.exists(Paths.mods(luaFile))) {
			luaFile = Paths.mods(luaFile);
			doPush = true;
		} else {
			luaFile = Paths.getPreloadPath(luaFile);
			if(sys.FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}
		
		if(doPush) 
			luaArray.push(new FunkinLua(luaFile));
		#end
		
		var daSong:String = curSong.toLowerCase();
		if (isStoryMode)
		{
			switch (daSong)
			{	
				case 'where-are-you':
					textIndex = '1-pre-whereareyou';
					schoolIntro(1);
				case 'eruption':
					sEnding = 'here we go';
					textIndex = '2-pre-eruption';
					schoolIntro(0);
				case 'kaio-ken':
					//sEnding = 'week1 end';
					startCountdown();
				case 'whats-new':
					textIndex = '5-pre-whatsnew';
					sEnding = 'post whats new';
					schoolIntro(1);
				case 'blast':
					sEnding = 'post blast';
					startCountdown();

					if (!FlxG.save.data.p_maskGot[0])
					{
						maskObj = new MASKcoll(1, boyfriend.x - 200, -300, 0);
						maskCollGroup.add(maskObj);
					}
				case 'super-saiyan':
					sEnding = 'week2 end';
					startCountdown();
				case 'god-eater':
					sEnding = 'finale end';
					if (!Main.skipDes)
					{
						godIntro();
						Main.skipDes = true;
					}
					else
					{
						godCutEnd = true;
						godMoveGf = true;
						godMoveSh = true;
						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							startCountdown();
						});
					}
				case 'soothing-power':
					if (Main.skipDes)
					{
						startCountdown();
					}
					else
					{
						dad.playAnim('sit', true);
						camFollow.x -= 300;
						Main.skipDes = true;
						textIndex = 'upd/1';
						afterAction = 'stand up';
						schoolIntro(2);
					}
				case 'thunderstorm':
					if (Main.skipDes)
					{
						startCountdown();
					}
					else
					{
						Main.skipDes = true;
						textIndex = 'upd/2';
						schoolIntro(0);
					}
				case 'dissasembler':
					sEnding = 'last goodbye';
					if (Main.skipDes)
					{
						startCountdown();
					}
					else
					{
						Main.skipDes = true;
						textIndex = 'upd/3';
						schoolIntro(0);
					}
					if (!FlxG.save.data.p_maskGot[2])
					{
						maskObj = new MASKcoll(3, 0, 0, 0, camFollowPos, camHUD);
						maskObj.cameras = [camHUD];
						maskCollGroup.add(maskObj);
					}
				case 'astral-calamity':
					if (FlxG.save.data.p_partsGiven < 4 || FlxG.save.data.ending[2])
					{
						sEnding = 'wb ending';
						if (Main.skipDes)
						{
							startCountdown();
						}
						else
						{
							Main.skipDes = true;
							textIndex = 'upd/wb1';
							schoolIntro(1);
						}
					}
					else
					{
						textIndex = 'upd/zeph1';
						afterAction = 'possess';
						//sEnding = 'wb ending';
						schoolIntro(1);
					}
				case 'talladega':
					sEnding = 'zeph ending';
					if (Main.skipDes)
					{
						startCountdown();
					}
					else
					{
						camFollow.y -= 200;
						camFollowPos.y = camFollow.y;
						Main.skipDes = true;
						textIndex = 'upd/zeph2';
						new FlxTimer().start(2, function(tmr:FlxTimer)
						{
							FlxG.sound.playMusic(Paths.music('zephyrus'));
						});
						afterAction = "zephyrus";
						schoolIntro(2);
					}
				default:
					startCountdown();
			}
			seenCutscene = true;
		} else {
			var cs = curSong.toLowerCase();

			switch (cs)
			{		
				case 'god-eater':
					godCutEnd = true;
					godMoveGf = true;
					godMoveSh = true;
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						startCountdown();
					});
				case 'blast':
					if (!FlxG.save.data.p_maskGot[0])
					{
						maskObj = new MASKcoll(1, boyfriend.x - 200, -300, 0);
						maskCollGroup.add(maskObj);
					}
					startCountdown();
				case 'dissasembler':
					if (!FlxG.save.data.p_maskGot[2])
					{
						maskObj = new MASKcoll(3, 0, 0, 0, camFollowPos, camHUD);
						maskObj.cameras = [camHUD];
						maskCollGroup.add(maskObj);
					}
					startCountdown();
				default:
					startCountdown();
			}
		}
		RecalculateRating();

		//PRECACHING MISS SOUNDS BECAUSE I THINK THEY CAN LAG PEOPLE AND FUCK THEM UP IDK HOW HAXE WORKS
		CoolUtil.precacheSound('missnote1');
		CoolUtil.precacheSound('missnote2');
		CoolUtil.precacheSound('missnote3');
		
		#if desktop
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, displaySongName + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		#end
		super.create();
	}
	
	public function reloadHealthBarColors() {
		healthBar.createFilledBar(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
			FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
		healthBar.updateBar();
	}

	public function addCharacterToList(newCharacter:String, type:Int) {
		switch(type) {
			case 0:
				if(!boyfriendMap.exists(newCharacter)) {
					var newBoyfriend:Boyfriend = new Boyfriend(BF_X, BF_Y, newCharacter);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.visible = false;
				}

			case 1:
				if(!dadMap.exists(newCharacter)) {
					var newDad:Character = new Character(DAD_X, DAD_Y, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad);
					newDad.visible = false;
				}

			case 2:
				if(!gfMap.exists(newCharacter)) {
					var newGf:Character = new Character(GF_X, GF_Y, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.visible = false;
				}
		}
	}
	function startCharacterPos(char:Character, ?gfCheck:Bool = false) {
		if(gfCheck && char.curCharacter.startsWith('gf')) { //IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	var dialogueCount:Int = 0;

	//You don't have to add a song, just saying. You can just do "dialogueIntro(dialogue);" and it should work
	public function dialogueIntro(dialogue:Array<String>, ?song:String = null):Void
	{
		// TO DO: Make this more flexible, maybe?
		inCutscene = true;
		CoolUtil.precacheSound('dialogue');
		CoolUtil.precacheSound('dialogueClose');
		var doof:DialogueBoxPsych = new DialogueBoxPsych(dialogue, song);
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;
		doof.nextDialogueThing = startNextDialogue;
		doof.cameras = [camHUD];
		add(doof);
	}


	var tb_x = 60;
	var tb_y = 410;
	var tb_fx = -510 + 40;
	var tb_fy = 320;
	var tb_rx = 200 - 55;
	var jx:Int;

	var curr_char:Int;
	var curr_dial:Int;
	var dropText:FlxText;
	var tbox:FlxSprite;
	var talk:Int;
	var tb_appear:Int;
	var dcd:Int;
	var fimage:String;
	var fsprite:FlxSprite;
	var fside:Int;
	var black:FlxSprite;
	var tb_open:Bool = false;

	var afterAction:String = 'countdown';

	var textIndex = 'example';

	var vc_sfx:FlxSound;

	function schoolIntro(btrans:Int):Void
	{
		var readFrom:Array<Dynamic> = TextData.getText(textIndex);
		dialogue = readFrom[0];
		dchar = readFrom[1];
		dface = readFrom[2];
		dside = readFrom[3];

		black = new FlxSprite(-500, -400).makeGraphic(FlxG.width * 4, FlxG.height * 4, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var dim:FlxSprite = new FlxSprite(-500, -400).makeGraphic(FlxG.width * 4, FlxG.height * 4, FlxColor.WHITE);
		dim.alpha = 0;
		dim.scrollFactor.set();
		add(dim);

		if (black.alpha == 1)
		{
			dropText = new FlxText(140, tb_y + 25, 2000, "", 32);
			curr_char = 0;
			curr_dial = 0;
			talk = 1;
			tb_appear = 0;
			tbox = new FlxSprite(tb_x, tb_y, Paths.image('TextBox'));
			fimage = dchar[0] + '_' + dface[0];
			faceRender();
			fsprite.alpha = 0;
			tbox.alpha = 0;
			dcd = 7;

			if (btrans == 0)
			{
				dcd = 2;
				black.alpha = 0;
			}
			else if (btrans == 2)
			{
				dcd = 11;
			}
		}
		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		if (!tb_open)
		{
			tb_open = true;
			new FlxTimer().start(0.2, function(tmr:FlxTimer)
			{
				black.alpha -= 0.15;
				dcd --;
				if (dcd == 0)
				{
					tb_appear = 1;
				}
				tmr.reset(0.3);
			});
			if (talk == 1 || tbox.alpha >= 0)
			{
				new FlxTimer().start(0.03, function(ap_dp:FlxTimer)
				{
					
					if (tb_appear == 1)
					{
						if (tbox.alpha < 1)
						{
							tbox.alpha += 0.1;
						}
					}
					else
					{
						if (tbox.alpha > 0)
						{
							tbox.alpha -= 0.1;
						}
					}
					dropText.alpha = tbox.alpha;
					fsprite.alpha = tbox.alpha;
					dim.alpha = tbox.alpha / 2;
					ap_dp.reset(0.05);
				});
				var writing = dialogue[curr_dial];
				new FlxTimer().start(0.025, function(tmr2:FlxTimer)
				{
					if (talk == 1)
					{
						var newtxt = dialogue[curr_dial].substr(0, curr_char);
						var charat = dialogue[curr_dial].substr(curr_char - 1, 1);
						if (curr_char <= dialogue[curr_dial].length && tb_appear == 1)
						{
							if (charat != ' ')
							{
								vc_sfx = FlxG.sound.load(TextData.vcSound(dchar[curr_dial], dface[curr_dial]));
								vc_sfx.play();
							}
							curr_char ++;
						}

						//portraitLeft.loadGraphic(Paths.image('logo'), false, 500, 200, false);
						//portraitLeft.setGraphicSize(200);

						fsprite.updateHitbox();
						fsprite.scrollFactor.set();
						if (dside[curr_dial] == -1)
						{
							fsprite.flipX = true;
						}
						add(fsprite);

						tbox.updateHitbox();
						tbox.scrollFactor.set();
						add(tbox);

						dropText.text = newtxt;
						dropText.font = 'Pixel Arial 11 Bold';
						dropText.color = 0x00000000;
						dropText.scrollFactor.set();
						add(dropText);
					}
					tmr2.reset(0.025);
				});

				new FlxTimer().start(0.001, function(prs:FlxTimer)
				{
					var skip:Bool = false;
					if (textIndex == 'cs/scooby_hold_talk' && curr_dial == 6 && curr_char >= 16)
					{
						skip = true;
					}
					if (FlxG.keys.justReleased.ANY || skip)
					{
						if ((curr_char <= dialogue[curr_dial].length) && !skip)
						{
							curr_char = dialogue[curr_dial].length;
						}
						else
						{
							curr_char = 0;
							curr_dial ++;
							if (curr_dial >= dialogue.length)
							{
								if (cs_reset)
								{
									if (skip)
									{
										tbox.alpha = 0;
									}
									cs_wait = false;
									cs_time ++;
								}
								else
								{
									switch afterAction
									{
										case 'countdown':
											startCountdown();
										case 'transform':
											superShaggy();
										case 'end song':
											endSong();
										case 'possess':
											FlxG.sound.playMusic(Paths.music('possess'));
											zephState = 1;
										case 'zephyrus':
											FlxG.sound.music.fadeOut(1, 0);
											new FlxTimer().start(1, function(cock:FlxTimer)
											{
												startCountdown();
											});
										case 'stand up':
											dad.playAnim('standUP', true);
											new FlxTimer().start(1, function(cock:FlxTimer)
											{
												startCountdown();
											});
										case 'wb bye':
											wb_state = 1;
										case 'zeph bye':
											new FlxTimer().start(1, function(cock:FlxTimer)
											{
												dad.alpha = 0;
												zend_state = 1;
											});

									}
								}
								talk = 0;
								dropText.alpha = 0;
								curr_dial = 0;
								tb_appear = 0;
							}
							else
							{
								if (textIndex == 'cs/sh_bye' && curr_dial == 3)
								{
									cs_mus.stop();
								}
								fimage = dchar[curr_dial] + '_' + dface[curr_dial];
								if (fimage != "n")
								{
									fsprite.destroy();
									faceRender();
									fsprite.flipX = false;
									if (dside[curr_dial] == -1)
									{
										fsprite.flipX = true;
									}
								}
							}
						}
					}
					prs.reset(0.001 / (FlxG.elapsed / (1/60)));
				});
			}
		}
	}
	function faceRender():Void
	{
		jx = tb_fx;
		if (dside[curr_dial] == -1)
		{
			jx = tb_rx;
		}
		fsprite = new FlxSprite(tb_x + Std.int(tbox.width / 2) + jx, tb_y - tb_fy, Paths.image('face/f_' + fimage));
		fsprite.centerOffsets(true);
		fsprite.antialiasing = true;
		fsprite.updateHitbox();
		fsprite.scrollFactor.set();
		add(fsprite);
	}

	function superShaggy()
	{
		new FlxTimer().start(0.008, function(ct:FlxTimer)
		{
			switch (cutTime)
			{
				case 0:
					camFollow.x = dad.getMidpoint().x - 100;
					camFollow.y = dad.getMidpoint().y;
					camLerp = 2;
				case 15:
					dad.playAnim('powerup');
				case 48:
					dad.playAnim('idle_s');
					burst = new FlxSprite(-1110, 0);
					FlxG.sound.play(Paths.sound('burst'));
					remove(burst);
					burst = new FlxSprite(dad.getMidpoint().x - 1000, dad.getMidpoint().y - 100);
					burst.frames = Paths.getSparrowAtlas('characters/shaggy');
					burst.animation.addByPrefix('burst', "burst", 30);
					burst.animation.play('burst');
					//burst.setGraphicSize(Std.int(burst.width * 1.5));
					burst.antialiasing = true;
					add(burst);

					FlxG.sound.play(Paths.sound('powerup'), 1);
				case 62:
					burst.y = 0;
					remove(burst);
				case 95:
					FlxG.camera.angle = 0;
				case 200:
					endSong();
			}

			var ssh:Float = 45;
			var stime:Float = 30;
			var corneta:Float = (stime - (cutTime - ssh)) / stime;

			if (cutTime % 6 >= 3)
			{
				corneta *= -1;
			}
			if (cutTime >= ssh && cutTime <= ssh + stime)
			{
				FlxG.camera.angle = corneta * 5;
			}
			cutTime ++;
			ct.reset(0.008);
		});
	}

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;
	var perfectMode:Bool = false;

	public function startCountdown():Void
	{
		if(startedCountdown) {
			return;
		}

		inCutscene = false;
		hudArrows = [];

		var ret:Dynamic = callOnLuas('onStartCountdown', []);
		if(ret != FunkinLua.Function_Stop) {
			generateStaticArrows(0);
			generateStaticArrows(1);
			for (i in 0...playerStrums.length) {
				setOnLuas('defaultPlayerStrumX' + i, playerStrums.members[i].x);
				setOnLuas('defaultPlayerStrumY' + i, playerStrums.members[i].y);
			}
			for (i in 0...opponentStrums.length) {
				setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
				setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
				if(ClientPrefs.middleScroll) opponentStrums.members[i].visible = false;
			}

			startedCountdown = true;
			Conductor.songPosition = 0;
			Conductor.songPosition -= Conductor.crochet * 5;
			setOnLuas('startedCountdown', true);

			var swagCounter:Int = 0;

			startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
			{
				if (tmr.loopsLeft % gfSpeed == 0)
				{
					gf.dance();
				}
				if(tmr.loopsLeft % 2 == 0) {
					if (!boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.specialAnim)
					{
						boyfriend.dance();
					}
					if (!dad.animation.curAnim.name.startsWith('sing') && !dad.specialAnim)
					{
						dad.dance();
					}
				}
				else if(dad.danceIdle && !dad.specialAnim && !dad.curCharacter.startsWith('gf') && !dad.animation.curAnim.name.startsWith("sing"))
				{
					dad.dance();
				}

				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				introAssets.set('default', ['ready', 'set', 'go']);
				introAssets.set('school', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
				introAssets.set('schoolEvil', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

				var introAlts:Array<String> = introAssets.get('default');
				var antialias:Bool = ClientPrefs.globalAntialiasing;
				var altSuffix:String = "";

				for (value in introAssets.keys())
				{
					if (value == curStage)
					{
						introAlts = introAssets.get(value);
						altSuffix = '-pixel';
					}
				}
				switch(curStage) {
					case 'school' | 'schoolEvil':
						antialias = false;

					case 'mall':
						if(!ClientPrefs.lowQuality)
							upperBoppers.dance(true);
		
						bottomBoppers.dance(true);
						santa.dance(true);
				}

				switch (swagCounter)
				{
					case 0:
						FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);
					case 1:
						var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
						ready.scrollFactor.set();
						ready.updateHitbox();

						if (curStage.startsWith('school'))
							ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

						ready.screenCenter();
						ready.antialiasing = antialias;
						add(ready);
						FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								ready.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);
					case 2:
						var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
						set.scrollFactor.set();

						if (curStage.startsWith('school'))
							set.setGraphicSize(Std.int(set.width * daPixelZoom));

						set.screenCenter();
						set.antialiasing = antialias;
						add(set);
						FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								set.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);
					case 3:
						var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
						go.scrollFactor.set();

						if (curStage.startsWith('school'))
							go.setGraphicSize(Std.int(go.width * daPixelZoom));

						go.updateHitbox();

						go.screenCenter();
						go.antialiasing = antialias;
						add(go);
						FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								go.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);
					case 4:
				}
				callOnLuas('onCountdownTick', [swagCounter]);

				if (generatedMusic)
				{
					notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
				}

				swagCounter += 1;
				// generateSong('fresh');
			}, 5);
		}
	}

	function startNextDialogue() {
		dialogueCount++;
		callOnLuas('onNextDialogue', [dialogueCount]);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.onComplete = finishSong;
		vocals.play();

		if(paused) {
			//trace('Oopsie doopsie! Paused sound');
			FlxG.sound.music.pause();
			vocals.pause();
		}

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		FlxTween.tween(timeBarBG, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});

		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, displaySongName + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength);
		#end
		setOnLuas('songLength', songLength);
		callOnLuas('onSongStart', []);
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.song)));

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		var songName:String = SONG.song.toLowerCase();
		var file:String = Paths.json(songName + '/events');
		#if sys
		if (sys.FileSystem.exists(file)) {
		#else
		if (OpenFlAssets.exists(file)) {
		#end
			var eventsData:Array<SwagSection> = Song.loadFromJson('events', songName).notes;
			for (section in eventsData)
			{
				for (songNotes in section.sectionNotes)
				{
					if(songNotes[1] < 0) {
						eventNotes.push(songNotes);
						eventPushed(songNotes);
					}
				}
			}
		}

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				if(songNotes[1] > -1) { //Real notes
					var daStrumTime:Float = songNotes[0];
					var daNoteData:Int = Std.int(songNotes[1] % Main.ammo[mania]);

					var gottaHitNote:Bool = section.mustHitSection;

					if (songNotes[1] > Main.ammo[mania] - 1)
					{
						gottaHitNote = !section.mustHitSection;
					}

					var oldNote:Note;
					if (unspawnNotes.length > 0)
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
					else
						oldNote = null;

					var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
					swagNote.sustainLength = songNotes[2];
					swagNote.noteType = songNotes[3];
					swagNote.scrollFactor.set();

					var susLength:Float = swagNote.sustainLength;

					susLength = susLength / Conductor.stepCrochet;
					unspawnNotes.push(swagNote);

					var floorSus:Int = Math.floor(susLength);
					if(floorSus > 0) {
						for (susNote in 0...floorSus+1)
						{
							oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

							var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(SONG.speed, 2)), daNoteData, oldNote, true);
							sustainNote.noteType = swagNote.noteType;
							sustainNote.scrollFactor.set();
							unspawnNotes.push(sustainNote);

							sustainNote.mustPress = gottaHitNote;

							if (sustainNote.mustPress)
							{
								sustainNote.x += FlxG.width / 2; // general offset
							}
						}
					}

					swagNote.mustPress = gottaHitNote;

					if (swagNote.mustPress)
					{
						swagNote.x += FlxG.width / 2; // general offset
					}
					else {}
				} else { //Event Notes
					eventNotes.push(songNotes);
					eventPushed(songNotes);
				}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);
		if(eventNotes.length > 1) { //No need to sort if there's a single one or none at all
			eventNotes.sort(sortByTime);
		}

		generatedMusic = true;
	}

	public function burstRelease(bX:Float, bY:Float)
	{
		FlxG.sound.play(Paths.sound('burst'));
		remove(burst);
		burst = new FlxSprite(bX - 1000, bY - 100);
		burst.frames = Paths.getSparrowAtlas('characters/shaggy');
		burst.animation.addByPrefix('burst', "burst", 30);
		burst.animation.play('burst');
		//burst.setGraphicSize(Std.int(burst.width * 1.5));
		burst.antialiasing = true;
		add(burst);
		new FlxTimer().start(0.5, function(rem:FlxTimer)
		{
			remove(burst);
		});
	}

	function eventPushed(event:Array<Dynamic>) {
		switch(event[2]) {
			case 'Change Character':
				var charType:Int = Std.parseInt(event[3]);
				if(Math.isNaN(charType)) charType = 0;

				var newCharacter:String = event[4];
				addCharacterToList(newCharacter, charType);
		}
	}

	function eventNoteEarlyTrigger(event:Array<Dynamic>):Float {
		var returnedValue:Float = callOnLuas('eventEarlyTrigger', [event[2]]);
		if(returnedValue != 0) {
			return returnedValue;
		}

		switch(event[2]) {
			case 'Kill Henchmen': //Better timing so that the kill sound matches the beat intended
				return 280; //Plays 280ms before the actual position
		}
		return 0;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByTime(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int
	{
		var earlyTime1:Float = eventNoteEarlyTrigger(Obj1);
		var earlyTime2:Float = eventNoteEarlyTrigger(Obj2);
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0] - earlyTime1, Obj2[0] - earlyTime2);
	}

	var hudArrows:Array<FlxSprite>;
	var hudArrXPos:Array<Float>;
	var hudArrYPos:Array<Float>;

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...Main.ammo[mania])
		{
			// FlxG.log.add(i);
			var babyArrow:StrumNote = new StrumNote(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, strumLine.y, i);
			hudArrows.push(babyArrow);

			switch (curStage)
			{
				case 'school' | 'schoolEvil':
					babyArrow.loadGraphic(Paths.image('weeb/pixelUI/NOTE_assets'));
					babyArrow.width = babyArrow.width / 4;
					babyArrow.height = babyArrow.height / 5;
					babyArrow.loadGraphic(Paths.image('weeb/pixelUI/NOTE_assets'), true, Math.floor(babyArrow.width), Math.floor(babyArrow.height));
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						default:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
					}

				default:
					var skin:String = 'NOTE_assets';
					if(SONG.arrowSkin != null && SONG.arrowSkin.length > 1) skin = SONG.arrowSkin;

					babyArrow.frames = Paths.getSparrowAtlas(skin);
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = ClientPrefs.globalAntialiasing;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * Note.scales[mania]));

					babyArrow.x += Note.swidths[mania] * Note.swagWidth * Math.abs(i);
					
					var dirName = Main.gfxDir[Main.gfxHud[mania][i]];
					var pressName = Main.gfxLetter[Main.gfxIndex[mania][i]];
					babyArrow.animation.addByPrefix('static', 'arrow' + dirName);
					babyArrow.animation.addByPrefix('pressed', pressName + ' press', 24, false);
					babyArrow.animation.addByPrefix('confirm', pressName + ' confirm', 24, false);
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}
			else
			{
				opponentStrums.add(babyArrow);
			}

			babyArrow.playAnim('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);
			babyArrow.x -= Note.posRest[mania];

			strumLineNotes.add(babyArrow);
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = false;

			if(phillyBlackTween != null)
				phillyBlackTween.active = false;
			if(phillyCityLightsEventTween != null)
				phillyCityLightsEventTween.active = false;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (i in 0...chars.length) {
				if(chars[i].colorTween != null) {
					chars[i].colorTween.active = false;
				}
			}
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = true;

			if(phillyBlackTween != null)
				phillyBlackTween.active = true;
			if(phillyCityLightsEventTween != null)
				phillyCityLightsEventTween.active = true;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (i in 0...chars.length) {
				if(chars[i].colorTween != null) {
					chars[i].colorTween.active = true;
				}
			}
			paused = false;
			callOnLuas('onResume', []);

			#if desktop
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, displaySongName + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, displaySongName + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, displaySongName + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, displaySongName + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			}
		}
		#end

		super.onFocus();
	}
	
	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, displaySongName + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if(finishTimer != null) return;

		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var limoSpeed:Float = 0;

	//ass crack
	var sh_r:Float = 600;
	var sShake:Float = 0;
	var ldx:Float = 0;
	var ldy:Float = 0;
	var lstep:Float = 0;
	var legs_in = false;
	var gf_launched:Bool = false;

	var godCutEnd:Bool = false;
	var godMoveBf:Bool = true;
	var godMoveGf:Bool = false;
	var godMoveSh:Bool = false;

	var rotInd:Int = 0;

	//oooOOooOoO
	public static var rotCam = false;
	var rotCamSpd:Float = 1;
	var rotCamRange:Float = 10;
	var rotCamInd = 0;

	//WB ending
	var wb_state = 0;
	var wb_speed:Float = 0;
	var wb_time = 0;
	var wb_eX:Float = 0;
	var wb_eY:Float = 0;

	//ZEPHYRUS vars mask vars
	var bfControlY:Float = 0;
	var maskCreated = false;
	var maskObj:MASKcoll;
	var alterRoute:Int = 0;
	var zephRot:Int = 0;
	var zephTime:Int = 0;
	var zephVsp:Float = 0;
	var zephGrav:Float = 0.15;

	//zeph ending
	var zend_state = 0;
	var zend_time = 0;
	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end

		if (bgEdit)
		{
			if (FlxG.keys.justPressed.UP)
				bgTarget ++;
			if (FlxG.keys.justPressed.DOWN)
				bgTarget --;
		}
		/*if (FlxG.keys.justPressed.NINE)
		{
			iconP1.swapOldIcon();
		}*/

		callOnLuas('onUpdate', [elapsed]);

		switch (curStage)
		{
			case 'schoolEvil':
				if(!ClientPrefs.lowQuality && bgGhouls.animation.curAnim.finished) {
					bgGhouls.visible = false;
				}
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed * 1.5;
			case 'limo':
				if(!ClientPrefs.lowQuality) {
					grpLimoParticles.forEach(function(spr:BGSprite) {
						if(spr.animation.curAnim.finished) {
							spr.kill();
							grpLimoParticles.remove(spr, true);
							spr.destroy();
						}
					});

					switch(limoKillingState) {
						case 1:
							limoMetalPole.x += 5000 * elapsed;
							limoLight.x = limoMetalPole.x - 180;
							limoCorpse.x = limoLight.x - 50;
							limoCorpseTwo.x = limoLight.x + 35;

							var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
							for (i in 0...dancers.length) {
								if(dancers[i].x < FlxG.width * 1.5 && limoLight.x > (370 * i) + 130) {
									switch(i) {
										case 0 | 3:
											if(i == 0) FlxG.sound.play(Paths.sound('dancerdeath'), 0.5);

											var diffStr:String = i == 3 ? ' 2 ' : ' ';
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x + 200, dancers[i].y, 0.4, 0.4, ['hench leg spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x + 160, dancers[i].y + 200, 0.4, 0.4, ['hench arm spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x, dancers[i].y + 50, 0.4, 0.4, ['hench head spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);

											var particle:BGSprite = new BGSprite('gore/stupidBlood', dancers[i].x - 110, dancers[i].y + 20, 0.4, 0.4, ['blood'], false);
											particle.flipX = true;
											particle.angle = -57.5;
											grpLimoParticles.add(particle);
										case 1:
											limoCorpse.visible = true;
										case 2:
											limoCorpseTwo.visible = true;
									} //Note: Nobody cares about the fifth dancer because he is mostly hidden offscreen :(
									dancers[i].x += FlxG.width * 2;
								}
							}

							if(limoMetalPole.x > FlxG.width * 2) {
								resetLimoKill();
								limoSpeed = 800;
								limoKillingState = 2;
							}

						case 2:
							limoSpeed -= 4000 * elapsed;
							bgLimo.x -= limoSpeed * elapsed;
							if(bgLimo.x > FlxG.width * 1.5) {
								limoSpeed = 3000;
								limoKillingState = 3;
							}

						case 3:
							limoSpeed -= 2000 * elapsed;
							if(limoSpeed < 1000) limoSpeed = 1000;

							bgLimo.x -= limoSpeed * elapsed;
							if(bgLimo.x < -275) {
								limoKillingState = 4;
								limoSpeed = 800;
							}

						case 4:
							bgLimo.x = FlxMath.lerp(bgLimo.x, -150, CoolUtil.boundTo(elapsed * 9, 0, 1));
							if(Math.round(bgLimo.x) == -150) {
								bgLimo.x = -150;
								limoKillingState = 0;
							}
					}

					if(limoKillingState > 2) {
						var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
						for (i in 0...dancers.length) {
							dancers[i].x = (370 * i) + bgLimo.x + 280;
						}
					}
				}
			case 'mall':
				if(heyTimer > 0) {
					heyTimer -= elapsed;
					if(heyTimer <= 0) {
						bottomBoppers.dance(true);
						heyTimer = 0;
					}
				}
			
			case 'sky':
				var rotRate = curStep * 0.25;
				var rotRateSh = curStep / 9.5;
				var rotRateGf = curStep / 9.5 / 4;
				var derp = 12;
				if (!startedCountdown)
				{
					camFollow.x = boyfriend.x - 300;
					camFollow.y = boyfriend.y - 40;
					derp = 20;
				}

				if (godCutEnd)
				{
					if (!maskCreated)
					{
						if (isStoryMode && !FlxG.save.data.p_maskGot[1])
						{
							maskObj = new MASKcoll(2, 330, 660, 0);
							maskCollGroup.add(maskObj);
						}
						maskCreated = true;
					}
					if (curBeat < 32)
					{
						sh_r = 60;
					}
					else if ((curBeat >= 140 * 4) || (curBeat >= 50 * 4 && curBeat <= 58 * 4))
					{
						sh_r += (60 - sh_r) / 32;
					}
					else
					{
						sh_r = 600;
					}

					if ((curBeat >= 32 && curBeat < 48) || (curBeat >= 124 * 4 && curBeat < 140 * 4))
					{
						if (boyfriend.animation.curAnim.name.startsWith('idle'))
						{
							boyfriend.playAnim('scared', true);
						}
					}

					if (curBeat < 58*4)
					{
					}
					else if (curBeat < 74 * 4)
					{
						rotRateSh *= 1.2;
					}
					else if (curBeat < 124 * 4)
					{
					}
					else if (curBeat < 140 * 4)
					{
						rotRateSh *= 1.2;
					}
					var bf_toy = -2000 + Math.sin(rotRate) * 20 + bfControlY;

					var sh_toy = -2450 + -Math.sin(rotRateSh * 2) * sh_r * 0.45;
					var sh_tox = -330 -Math.cos(rotRateSh) * sh_r;

					var gf_tox = 100 + Math.sin(rotRateGf) * 200;
					var gf_toy = -2000 -Math.sin(rotRateGf) * 80;

					if (godMoveBf)
					{
						boyfriend.y += (bf_toy - boyfriend.y) / derp;
						rock.x = boyfriend.x - 200;
						rock.y = boyfriend.y + 200;
						rock.alpha = 1;
						if (true)//(!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
						{
							if (FlxG.keys.pressed.UP && bfControlY > 0)
							{
								bfControlY --;
							}
							if (FlxG.keys.pressed.DOWN && bfControlY < 2290)
							{
								trace(bfControlY);
								bfControlY ++;
								if (bfControlY >= 400)
								{
									alterRoute = 1;
								}
							}
						}
					}

					if (godMoveSh)
					{
						dad.x += (sh_tox - dad.x) / 12;
						dad.y += (sh_toy - dad.y) / 12;

						if (dad.animation.name == 'idle')
						{
							var pene = 0.07;
							dad.angle = Math.sin(rotRateSh) * sh_r * pene / 4;

							legs.alpha = 1;
							legs.angle = Math.sin(rotRateSh) * sh_r * pene;// + Math.cos(curStep) * 5;

							legs.x = dad.x + 120 + Math.cos((legs.angle + 90) * (Math.PI/180)) * 150;
							legs.y = dad.y + 300 + Math.sin((legs.angle + 90) * (Math.PI/180)) * 150;
						}
						else
						{
							dad.angle = 0;
							legs.alpha = 0;
						}
						legT.visible = true;
						if (legs.alpha == 0)
							legT.visible = false;
					}

					if (godMoveGf)
					{
						gf.x += (gf_tox - gf.x) / derp;
						gf.y += (gf_toy - gf.y) / derp;

						gf_rock.x = gf.x + 80;
						gf_rock.y = gf.y + 530;
						gf_rock.alpha = 1;
						if (!gf_launched)
						{
							gf.scrollFactor.set(0.8, 0.8);
							gf.setGraphicSize(Std.int(gf.width * 0.8));
							gf_launched = true;
						}
					}
				}
				if (!godCutEnd || !godMoveBf)
				{
					rock.alpha = 0;
				}
				if (!godMoveGf)
				{
					gf_rock.alpha = 0;
				}
			case 'lava':
				if (dad.curCharacter == 'wbshaggy')
				{
					rotInd ++;
					var rot = rotInd / 6;

					dad.x = DAD_X + Math.cos(rot / 3) * 20 + wb_eX;
					dad.y = DAD_Y + Math.cos(rot / 5) * 40 + wb_eY;
				}
		}

		if (rotCam)
		{
			rotCamInd ++;
			camera.angle = Math.sin(rotCamInd / 100 * rotCamSpd) * rotCamRange;
		}
		else
		{
			rotCamInd = 0;
		}

		if (dimGo)
		{
			if (bgDim.alpha < 0.5) bgDim.alpha += 0.01;
		}
		else
		{
			if (bgDim.alpha > 0) bgDim.alpha -= 0.01;
		}

		if(!inCutscene) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4, 0, 1) * camLerp;
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
			if(!startingSong && !endingSong && boyfriend.animation.curAnim.name.startsWith('idle')) {
				boyfriendIdleTime += elapsed;
				if(boyfriendIdleTime >= 0.15) { // Kind of a mercy thing for making the achievement easier to get as it's apparently frustrating to some playerss
					boyfriendIdled = true;
				}
			} else {
				boyfriendIdleTime = 0;
			}
		}

		super.update(elapsed); //TEST

		//Zephyrus buddy
		if (zeph != null)
		{
			if (zephState < 2) zephRot ++;

			var zToX = boyfriend.getMidpoint().x + 240 + Math.sin(zephRot / 213) * 20;
			var zToY = boyfriend.getMidpoint().y - 220 + Math.sin(zephRot / 50) * 15;

			switch (zephState)
			{
				case 1:
					var tow = new FlxPoint(dad.getMidpoint().x, dad.getMidpoint().y - 1200);
					zephAddX -= 1.25;

					var c = tow.y - (zeph.y + zephAddY);
					zephAddY += (c / Math.abs(c)) * 0.75;

					camFollow.x = zeph.x - 100;
					camFollow.y = zeph.y + 200;
					camLerp = 0.5;

					if (zeph.x < tow.x - 40)
					{
						zephState = 2;
						FlxG.sound.music.stop();
						remove(zeph);
						zeph = new FlxSprite().loadGraphic(Paths.image('MASK/possessed', 'shared'));
						zeph.updateHitbox();
						zeph.antialiasing = true;
						camFollow.x = zeph.getMidpoint().x;
						camFollow.y = zeph.getMidpoint().y;
						camFollowPos.x = camFollow.x;
						camFollowPos.y = camFollow.y;
						zLockX = camFollow.x;
						zLockY = camFollow.y;

						zephScreen.screenCenter(X);
						zephScreen.screenCenter(Y);
						add(zephScreen);
						add(zeph);

						zeph.scrollFactor.set(0, 0);
						zeph.screenCenter(X);
						zeph.screenCenter(Y);

						healthBarBG.alpha = 0;
						healthBar.alpha = 0;
						iconP1.alpha = 0;
						iconP2.alpha = 0;
						scoreTxt.alpha = 0;
						boyfriend.alpha = 0;
					}
				case 2:
					camFollow.x = zLockX;
					camFollow.y = zLockY;
					camFollowPos.x = camFollow.x;
					camFollowPos.y = camFollow.y;

					zephTime ++;
					
					if (zephTime > 350)
					{
						zephVsp += zephGrav;
						zeph.angle -= 0.4;
						zeph.y += zephVsp;

						if (zephTime == 510)
						{
							FlxG.sound.play(Paths.sound('undSnap', 'preload'));
						}
						if (zephTime == 700)
						{
							trace(sEnding);
							storyPlaylist = ['Astral-calamity', 'Talladega'];
							endSong();
						}
					}
			}
			zToX += zephAddX;
			zToY += zephAddY;

			if (zeph.x == -2000)
			{
				zeph.x = zToX;
				zeph.y = zToY;
			}
			if (zephState < 2)
			{
				zeph.x += (zToX - zeph.x) / 12;
				zeph.y += (zToY - zeph.y) / 12;
			}
		}

		switch (wb_state)
		{
			case 1:
				wb_speed += 0.1;
				if (wb_speed > 20) wb_speed = 20;
				wb_eY -= wb_speed;
				wb_eX += wb_speed;
				
				wb_time ++;

				switch (wb_time)
				{
					case 400:
						var bDim = new FlxSprite(0, 0).makeGraphic(4000, 4000, FlxColor.BLACK);
						bDim.alpha = 0.5;
						bDim.scrollFactor.set(0);
						bDim.screenCenter();
						add(bDim);

						var cong = new Alphabet(0, 40, 'Congratulations!', true, false);
						cong.cameras = [camHUD];
						cong.screenCenter(X);
						add(cong);
						FlxG.sound.play(Paths.sound('victory'));
					case 600:
						var bef = new Alphabet(0, 200, 'You defeated WB', true, false);
						bef.cameras = [camHUD];
						bef.screenCenter(X);

						var bef2 = new Alphabet(0, 260, 'Shaggy!', true, false);
						bef2.cameras = [camHUD];
						bef2.screenCenter(X);

						add(bef);
						add(bef2);
					case 750:
						var bef = new Alphabet(0, 400, 'And got stuck in hell...', true, false);
						//bef.color = FlxColor.WHITE;
						bef.cameras = [camHUD];
						bef.screenCenter(X);
						add(bef);

					case 1000:

						var bef2 = new Alphabet(0, 600, 'Full ending', true, false);
						bef2.cameras = [camHUD];
						bef2.screenCenter(X);

						MASKstate.endingUnlock(1);
						add(bef2);
					case 1300:
						FlxG.sound.playMusic(Paths.music('freakyMenu'));
						MusicBeatState.switchState(new CreditsState());
				}
		}
		switch (zend_state)
		{
			case 1:
				zend_time ++;
				switch (zend_time)
				{
					case 200:
						camFollow.x = boyfriend.getMidpoint().x - 100;
						camFollow.y = boyfriend.getMidpoint().y - 300;

						var bDim = new FlxSprite(0, 0).makeGraphic(4000, 4000, FlxColor.BLACK);
						bDim.alpha = 0.5;
						bDim.scrollFactor.set(0);
						bDim.screenCenter();
						add(bDim);

						var cong = new Alphabet(0, 40, 'Congratulations!', true, false);
						cong.cameras = [camHUD];
						cong.screenCenter(X);
						add(cong);
						FlxG.sound.play(Paths.sound('victory'));
					
					case 400:
						var bef = new Alphabet(0, 200, 'You befriended a', true, false);
						bef.cameras = [camHUD];
						bef.screenCenter(X);

						var bef2 = new Alphabet(0, 260, 'universe conqueror!', true, false);
						bef2.cameras = [camHUD];
						bef2.screenCenter(X);

						add(bef);
						add(bef2);
					
					case 700:
						FlxG.sound.playMusic(Paths.music('MASK/phantomMenu'));

						MASKstate.endingUnlock(2);
						var bef3 = new Alphabet(0, 600, 'secret ending', true, false);
						bef3.cameras = [camHUD];
						bef3.screenCenter(X);

						add(bef3);
					case 1000:
						MusicBeatState.switchState(new CreditsState());
				}

		}

		if(ratingString == '?') {
			scoreTxt.text = 'Score: ' + songScore + ' | Misses: ' + songMisses + ' | Rating: ' + ratingString;
		} else {
			scoreTxt.text = 'Score: ' + songScore + ' | Misses: ' + songMisses + ' | Rating: ' + ratingString + ' (' + Math.floor(ratingPercent * 100) + '%)';
		}

		if(cpuControlled) {
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}
		botplayTxt.visible = cpuControlled;

		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{
			var ret:Dynamic = callOnLuas('onPause', []);
			if(ret != FunkinLua.Function_Stop) {
				persistentUpdate = false;
				persistentDraw = true;
				paused = true;

				// 1 / 1000 chance for Gitaroo Man easter egg
				if (FlxG.random.bool(0.1))
				{
					// gitaroo man easter egg
					MusicBeatState.switchState(new GitarooPause());
				}
				else {
					if(FlxG.sound.music != null) {
						FlxG.sound.music.pause();
						vocals.pause();
					}
					openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				}
			
				#if desktop
				DiscordClient.changePresence(detailsPausedText, displaySongName + " (" + storyDifficultyText + ")", iconP2.getCharacter());
				#end
			}
		}

		if (FlxG.keys.justPressed.SEVEN && !endingSong)
		{
			persistentUpdate = false;
			paused = true;
			MusicBeatState.switchState(new ChartingState());

			#if desktop
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, CoolUtil.boundTo(1 - (elapsed * 30), 0, 1))));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, CoolUtil.boundTo(1 - (elapsed * 30), 0, 1))));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		if (FlxG.keys.justPressed.EIGHT) {
			persistentUpdate = false;
			paused = true;
			MusicBeatState.switchState(new CharacterEditorState(SONG.player2));
		}

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			if (!songEnded)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;

				if (!paused)
				{
					songTime += FlxG.game.ticks - previousFrameTime;
					previousFrameTime = FlxG.game.ticks;

					// Interpolation type beat
					if (Conductor.lastSongPos != Conductor.songPosition)
					{
						songTime = (songTime + Conductor.songPosition) / 2;
						Conductor.lastSongPos = Conductor.songPosition;
						// Conductor.songPosition += FlxG.elapsed * 1000;
						// trace('MISSED FRAME');
					}

					if(updateTime) {
						var curTime:Float = FlxG.sound.music.time - ClientPrefs.noteOffset;
						if(curTime < 0) curTime = 0;
						songPercent = (curTime / songLength);

						var secondsTotal:Int = Math.floor((songLength - curTime) / 1000);
						if(secondsTotal < 0) secondsTotal = 0;

						var minutesRemaining:Int = Math.floor(secondsTotal / 60);
						var secondsRemaining:String = '' + secondsTotal % 60;
						if(secondsRemaining.length < 2) secondsRemaining = '0' + secondsRemaining; //Dunno how to make it display a zero first in Haxe lol
						timeTxt.text = minutesRemaining + ':' + secondsRemaining;
					}
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null && !endingSong && !isCameraOnForcedPos)
		{
			moveCameraSection(Std.int(curStep / 16));
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (curSong == 'Bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					//vocals.volume = 0;
					// FlxG.sound.music.stop();
					// MusicBeatState.switchState(new PlayState());
			}
		}
		// better streaming of shit

		// RESET = Quick Game Over Screen
		if (controls.RESET && !inCutscene && !endingSong)
		{
			health = 0;
			trace("RESET = True");
		}

		if (health <= 0 && !practiceMode)
		{
			var ret:Dynamic = callOnLuas('onGameOver', []);
			if(ret != FunkinLua.Function_Stop) {
				boyfriend.stunned = true;
				deathCounter++;

				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y, camFollowPos.x, camFollowPos.y));

				// MusicBeatState.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				
				#if desktop
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("Game Over - " + detailsText, displaySongName + " (" + storyDifficultyText + ")", iconP2.getCharacter());
				#end
			}
		}

		var roundedSpeed:Float = FlxMath.roundDecimal(SONG.speed, 2);
		if (unspawnNotes[0] != null)
		{
			var time:Float = 1500;
			if(roundedSpeed < 1) time /= roundedSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
			notes.forEachAlive(function(daNote:Note)
			{
				if(!daNote.mustPress && ClientPrefs.middleScroll)
				{
					daNote.active = true;
					daNote.visible = false;
				}
				else if (daNote.y > FlxG.height)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}

				// i am so fucking sorry for this if condition
				var strumY:Float = 0;
				if(daNote.mustPress) {
					strumY = playerStrums.members[daNote.noteData].y;
				} else {
					strumY = opponentStrums.members[daNote.noteData].y;
				}
				var swagWidth = Note.swidths[0] * Note.scales[mania];
				var center:Float = strumY + swagWidth / 2;

				if (ClientPrefs.downScroll) {
					daNote.y = (strumY + 0.45 * (Conductor.songPosition - daNote.strumTime) * roundedSpeed);
					if (daNote.isSustainNote) {
						//Jesus fuck this took me so much mother fucking time AAAAAAAAAA
						if (daNote.animation.curAnim.name.endsWith('tail')) {
							daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * roundedSpeed + (46 * (roundedSpeed - 1));
							daNote.y -= 46 * (1 - (fakeCrochet / 600)) * roundedSpeed;
							if(curStage == 'school' || curStage == 'schoolEvil') {
								daNote.y += 8;
							}
						} 
						daNote.y += (swagWidth / 2) - (60.5 * (roundedSpeed - 1));
						daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (roundedSpeed - 1);

						if(daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center
							&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
						{
							var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
							swagRect.height = (center - daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;

							daNote.clipRect = swagRect;
						}
					}
				} else {
					daNote.y = (strumY - 0.45 * (Conductor.songPosition - daNote.strumTime) * roundedSpeed);

					if (daNote.isSustainNote
						&& daNote.y + daNote.offset.y * daNote.scale.y <= center
						&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
					{
						var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
						swagRect.y = (center - daNote.y) / daNote.scale.y;
						swagRect.height -= swagRect.y;

						daNote.clipRect = swagRect;
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit && !daNote.ignoreNote)
				{
					if (SONG.song != 'Tutorial')
						camZooming = true;

					var isAlt:Bool = false;

					if(daNote.noteType == 2 && dad.animOffsets.exists('hey')) {
						dad.playAnim('hey', true);
						dad.specialAnim = true;
						dad.heyTimer = 0.6;
					} else {
						var altAnim:String = "";

						if (SONG.notes[Math.floor(curStep / 16)] != null)
						{
							if (SONG.notes[Math.floor(curStep / 16)].altAnim || daNote.noteType == 1) {
								altAnim = '-alt';
								isAlt = true;
							}
						}

						var animToPlay:String = '';
						animToPlay = 'sing' + Main.charDir[Main.gfxHud[mania][Std.int(Math.abs(daNote.noteData))]];
			
						dad.playAnim(animToPlay + altAnim, true);
					}

					dad.holdTimer = 0;

					if (SONG.needsVoices)
						vocals.volume = 1;

					var time:Float = 0.15;
					if(daNote.isSustainNote && !daNote.animation.curAnim.name.endsWith('end')) {
						time += 0.15;
					}
					StrumPlayAnim(true, Std.int(Math.abs(daNote.noteData)) % Main.ammo[mania], time);
					daNote.ignoreNote = true;

					if (!daNote.isSustainNote)
					{
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				}

				if(daNote.mustPress && cpuControlled) {
					if(daNote.isSustainNote) {
						if(daNote.canBeHit) {
							goodNoteHit(daNote);
						}
					} else if(daNote.strumTime <= Conductor.songPosition) {
						goodNoteHit(daNote);
					}
				}

				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				var doKill:Bool = daNote.y < -daNote.height;
				if(ClientPrefs.downScroll) doKill = daNote.y > FlxG.height;

				if (doKill)
				{
					if (daNote.mustPress && !cpuControlled)
					{
						if (daNote.tooLate || !daNote.wasGoodHit)
						{
							if(!endingSong) {
								//Dupe note remove
								notes.forEachAlive(function(note:Note) {
									if (daNote != note && daNote.mustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 10) {
										note.kill();
										notes.remove(note, true);
										note.destroy();
									}
								});

								switch(daNote.noteType) {
									case 3:
										//Hurt note, does nothing.

									default:
										health -= 0.0475; //For testing purposes
										songMisses++;
										vocals.volume = 0;
										RecalculateRating();

										if(ClientPrefs.ghostTapping) {
											boyfriend.playAnim('sing' + Main.charDir[Main.gfxHud[mania][Std.int(Math.abs(daNote.noteData))]] + 'miss', true);
										}
										callOnLuas('noteMiss', [daNote.noteData, daNote.noteType]);
								}
							}
						}
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}


		while(eventNotes.length > 0) {
			var early:Float = eventNoteEarlyTrigger(eventNotes[0]);
			var leStrumTime:Float = eventNotes[0][0];
			if(Conductor.songPosition < leStrumTime - early) {
				break;
			}

			var value1:String = '';
			if(eventNotes[0][3] != null)
				value1 = eventNotes[0][3];

			var value2:String = '';
			if(eventNotes[0][4] != null)
				value2 = eventNotes[0][4];

			triggerEventNote(eventNotes[0][2], value1, value2);
			eventNotes.shift();
		}

		if (!inCutscene) {
			if(!cpuControlled) {
				keyShit();
			} else if(boyfriend.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss')) {
				boyfriend.dance();
			}
		}

		//super.update(elapsed); //TEST
		
		#if debug
		if(!endingSong && !startingSong) {
			if (FlxG.keys.justPressed.ONE)
				FlxG.sound.music.onComplete();
			if(FlxG.keys.justPressed.TWO) { //Go 10 seconds into the future :O
				FlxG.sound.music.pause();
				vocals.pause();
				Conductor.songPosition += 10000;
				notes.forEachAlive(function(daNote:Note)
				{
					if(daNote.strumTime + 800 < Conductor.songPosition) {
						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});
				for (i in 0...unspawnNotes.length) {
					var daNote:Note = unspawnNotes[0];
					if(daNote.strumTime + 800 >= Conductor.songPosition) {
						break;
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					unspawnNotes.splice(unspawnNotes.indexOf(daNote), 1);
					daNote.destroy();
				}

				FlxG.sound.music.time = Conductor.songPosition;
				FlxG.sound.music.play();

				vocals.time = Conductor.songPosition;
				vocals.play();
			}
		}

		setOnLuas('cameraX', camFollowPos.x);
		setOnLuas('cameraY', camFollowPos.y);
		setOnLuas('botPlay', PlayState.cpuControlled);
		callOnLuas('onUpdatePost', [elapsed]);
		#end
	}

	public function getControl(key:String) {
		var pressed:Bool = Reflect.getProperty(controls, key);
		//trace('Control result: ' + pressed);
		return pressed;
	}

	public function triggerEventNote(eventName:String, value1:String, value2:String, ?onLua:Bool = false) {
		switch(eventName) {
			case 'Hey!':
				var value:Int = Std.parseInt(value1);
				var time:Float = Std.parseFloat(value2);
				if(Math.isNaN(time) || time <= 0) time = 0.6;

				if(value != 0) {
					if(dad.curCharacter == 'gf') { //Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = time;
					} else {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = time;
					}

					if(curStage == 'mall') {
						bottomBoppers.animation.play('hey', true);
						heyTimer = time;
					}
				}
				if(value != 1) {
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = time;
				}

			case 'Set GF Speed':
				var value:Int = Std.parseInt(value1);
				if(Math.isNaN(value)) value = 1;
				gfSpeed = value;

			case 'Blammed Lights':
				if(curStage == 'philly') {
					var lightId:Int = Std.parseInt(value1);
					if(Math.isNaN(lightId)) lightId = 0;

					if(lightId > 0 && curLightEvent != lightId) {
						if(lightId > 5) lightId = FlxG.random.int(1, 5, [curLightEvent]);

						var color:Int = 0xffffffff;
						switch(lightId) {
							case 1: //Blue
								color = 0xff31a2fd;
							case 2: //Green
								color = 0xff31fd8c;
							case 3: //Pink
								color = 0xfff794f7;
							case 4: //Red
								color = 0xfff96d63;
							case 5: //Orange
								color = 0xfffba633;
						}
						curLightEvent = lightId;

						if(phillyBlack.alpha != 1) {
							if(phillyBlackTween != null) {
								phillyBlackTween.cancel();
							}
							phillyBlackTween = FlxTween.tween(phillyBlack, {alpha: 1}, 1, {ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween) {
									phillyBlackTween = null;
								}
							});

							var chars:Array<Character> = [boyfriend, gf, dad];
							for (i in 0...chars.length) {
								if(chars[i].colorTween != null) {
									chars[i].colorTween.cancel();
								}
								chars[i].colorTween = FlxTween.color(chars[i], 1, FlxColor.WHITE, color, {onComplete: function(twn:FlxTween) {
									chars[i].colorTween = null;
								}, ease: FlxEase.quadInOut});
							}
						} else {
							dad.color = color;
							boyfriend.color = color;
							gf.color = color;
						}

						phillyCityLightsEvent.forEach(function(spr:BGSprite) {
							spr.visible = false;
						});
						phillyCityLightsEvent.members[lightId - 1].visible = true;
						phillyCityLightsEvent.members[lightId - 1].alpha = 1;
					} else {
						if(phillyBlack.alpha != 0) {
							if(phillyBlackTween != null) {
								phillyBlackTween.cancel();
							}
							phillyBlackTween = FlxTween.tween(phillyBlack, {alpha: 0}, 1, {ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween) {
									phillyBlackTween = null;
								}
							});
						}

						phillyCityLights.forEach(function(spr:BGSprite) {
							spr.visible = false;
						});
						phillyCityLightsEvent.forEach(function(spr:BGSprite) {
							spr.visible = false;
						});

						var memb:FlxSprite = phillyCityLightsEvent.members[curLightEvent - 1];
						if(memb != null) {
							memb.visible = true;
							memb.alpha = 1;
							if(phillyCityLightsEventTween != null)
								phillyCityLightsEventTween.cancel();

							phillyCityLightsEventTween = FlxTween.tween(memb, {alpha: 0}, 1, {onComplete: function(twn:FlxTween) {
								phillyCityLightsEventTween = null;
							}, ease: FlxEase.quadInOut});
						}

						var chars:Array<Character> = [boyfriend, gf, dad];
						for (i in 0...chars.length) {
							if(chars[i].colorTween != null) {
								chars[i].colorTween.cancel();
							}
							chars[i].colorTween = FlxTween.color(chars[i], 1, chars[i].color, FlxColor.WHITE, {onComplete: function(twn:FlxTween) {
								chars[i].colorTween = null;
							}, ease: FlxEase.quadInOut});
						}

						curLight = 0;
						curLightEvent = 0;
					}
				}

			case 'Kill Henchmen':
				killHenchmen();

			case 'Add Camera Zoom':
				if(ClientPrefs.camZooms && FlxG.camera.zoom < 1.35) {
					var camZoom:Float = Std.parseFloat(value1);
					var hudZoom:Float = Std.parseFloat(value2);
					if(Math.isNaN(camZoom)) camZoom = 0.015;
					if(Math.isNaN(hudZoom)) hudZoom = 0.03;

					FlxG.camera.zoom += camZoom;
					camHUD.zoom += hudZoom;
				}

			case 'Trigger BG Ghouls':
				if(curStage == 'schoolEvil' && !ClientPrefs.lowQuality) {
					bgGhouls.dance(true);
					bgGhouls.visible = true;
				}

			case 'Play Animation':
				trace('Anim to play: ' + value1);
				var val2:Int = Std.parseInt(value2);
				if(Math.isNaN(val2)) val2 = 0;

				var char:Character = dad;
				switch(val2) {
					case 1: char = boyfriend;
					case 2: char = gf;
				}
				char.playAnim(value1, true);
				char.specialAnim = true;

			case 'Camera Follow Pos':
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 0;
				if(Math.isNaN(val2)) val2 = 0;

				isCameraOnForcedPos = false;
				if(!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2))) {
					camFollow.x = val1;
					camFollow.y = val2;
					isCameraOnForcedPos = true;
				}

			case 'Alt Idle Animation':
				var val:Int = Std.parseInt(value1);
				if(Math.isNaN(val)) val = 0;

				var char:Character = dad;
				switch(val) {
					case 1: char = boyfriend;
					case 2: char = gf;
				}
				char.idleSuffix = value2;
				char.recalculateDanceIdle();

			case 'Screen Shake':
				var valuesArray:Array<String> = [value1, value2];
				var targetsArray:Array<FlxCamera> = [camGame, camHUD];
				for (i in 0...targetsArray.length) {
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = Std.parseFloat(split[0].trim());
					var intensity:Float = Std.parseFloat(split[1].trim());
					if(Math.isNaN(duration)) duration = 0;
					if(Math.isNaN(intensity)) intensity = 0;

					if(duration > 0 && intensity != 0) {
						targetsArray[i].shake(intensity, duration);
					}
				}

			case 'Change Character':
				var charType:Int = Std.parseInt(value1);
				if(Math.isNaN(charType)) charType = 0;

				switch(charType) {
					case 0:
						if(boyfriend.curCharacter != value2) {
							if(!boyfriendMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							boyfriend.visible = false;
							boyfriend = boyfriendMap.get(value2);
							boyfriend.visible = true;
							iconP1.changeIcon(boyfriend.healthIcon);
						}

					case 1:
						if(dad.curCharacter != value2) {
							if(!dadMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.startsWith('gf');
							dad.visible = false;
							dad = dadMap.get(value2);
							if(!dad.curCharacter.startsWith('gf')) {
								if(wasGf) {
									gf.visible = true;
								}
							} else {
								gf.visible = false;
							}
							dad.visible = true;
							iconP2.changeIcon(dad.healthIcon);
						}

					case 2:
						if(gf.curCharacter != value2) {
							if(!gfMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var isGfVisible:Bool = gf.visible;
							gf.visible = false;
							gf = gfMap.get(value2);
							gf.visible = isGfVisible;
						}

				}
			case 'Shaggy trail alpha':
				if (dad.curCharacter == 'rshaggy')
				{
					camLerp = 2.5;
				}
				else
				{
					var a = value1;
					if (a == '1' || a == 'true')
						shaggyT.visible = false;
					else
						shaggyT.visible = true;
				}
			case 'Shaggy burst':
				burstRelease(dad.getMidpoint().x, dad.getMidpoint().y);
			case 'Camera rotate on':
				rotCam = true;
				rotCamSpd = Std.parseFloat(value1);
				rotCamRange = Std.parseFloat(value2);
			case 'Camera rotate off':
				rotCam = false;
				camera.angle = 0;
			case 'Toggle bg dim':
				dimGo = !dimGo;
			case 'Drop eye':
				if (!FlxG.save.data.p_maskGot[3])
				{
					maskObj = new MASKcoll(4, dad.getMidpoint().x, dad.getMidpoint().y - 300, 0);
					maskCollGroup.add(maskObj);
				}
		}
		if(!onLua) {
			callOnLuas('onEvent', [eventName, value1, value2]);
		}
	}

	function moveCameraSection(?id:Int = 0):Void {
		if (SONG.notes[id] != null && camFollow.x != dad.getMidpoint().x + 150 && !SONG.notes[id].mustHitSection)
		{
			moveCamera(true);
			callOnLuas('onMoveCamera', ['dad']);
		}

		if (SONG.notes[id] != null && SONG.notes[id].mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
		{
			moveCamera(false);
			callOnLuas('onMoveCamera', ['boyfriend']);
		}
	}

	public function moveCamera(isDad:Bool) {
		if(isDad) {
			camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			camFollow.x += dad.cameraPosition[0];
			camFollow.y += dad.cameraPosition[1];
			
			if (dad.curCharacter.startsWith('mom'))
				vocals.volume = 1;

			if (SONG.song.toLowerCase() == 'tutorial')
			{
				tweenCamIn();
			}
		} else {
			camFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

			switch (curStage)
			{
				case 'limo':
					camFollow.x = boyfriend.getMidpoint().x - 300;
				case 'mall':
					camFollow.y = boyfriend.getMidpoint().y - 200;
				case 'school' | 'schoolEvil':
					camFollow.x = boyfriend.getMidpoint().x - 200;
					camFollow.y = boyfriend.getMidpoint().y - 200;
			}
			camFollow.x -= boyfriend.cameraPosition[0];
			camFollow.y += boyfriend.cameraPosition[1];

			if (SONG.song.toLowerCase() == 'tutorial')
			{
				FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
			}
		}
	}

	function snapCamFollowToPos(x:Float, y:Float) {
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	function finishSong():Void
	{
		var finishCallback:Void->Void = endSong; //In case you want to change it in a specific song.

		updateTime = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		vocals.pause();
		if(ClientPrefs.noteOffset <= 0) {
			finishCallback();
		} else {
			finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer) {
				finishCallback();
			});
		}
	}


	var transitioning = false;
	function endSong():Void
	{
		timeBarBG.visible = false;
		timeBar.visible = false;
		timeTxt.visible = false;
		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;
		updateTime = false;

		deathCounter = 0;
		seenCutscene = false;
		KillNotes();

		callOnLuas('onEndSong', []);
		if (SONG.validScore)
		{
			#if !switch
			var percent:Float = ratingPercent;
			if(Math.isNaN(percent)) percent = 0;
			Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent);
			#end
		}

		songEnded = true;

		if (isStoryMode)
		{
			if (hudArrows != null)
			{
				new FlxTimer().start(0.003, function(fadear:FlxTimer)
				{
					var decAl:Float = 0.01;
					for (i in 0...hudArrows.length)
					{
						hudArrows[i].alpha -= decAl;
					}
					healthBarBG.alpha -= decAl;
					healthBar.alpha -= decAl;
					iconP1.alpha -= decAl;
					iconP2.alpha -= decAl;
					scoreTxt.alpha -= decAl;
					fadear.reset(0.003);
				});
			}

			if (sEnding == 'none')
			{
				Main.skipDes = false;
				campaignScore += songScore;
				campaignMisses += songMisses;

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					if (Main.menuBad)
					{
						FlxG.sound.playMusic(Paths.music('menuBad'));
					}
					else
					{
						FlxG.sound.playMusic(Paths.music('freakyMenu'));
					}

					transIn = FlxTransitionableState.defaultTransIn;
					transOut = FlxTransitionableState.defaultTransOut;

					MusicBeatState.switchState(new StoryMenuState());

					// if ()
					StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

					if (SONG.validScore)
					{
						Highscore.saveWeekScore(WeekData.getCurrentWeekNumber(), campaignScore, storyDifficulty);
					}

					FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
					FlxG.save.flush();
					usedPractice = false;
					changedDifficulty = false;
					cpuControlled = false;
				}
				else
				{
					var difficulty:String = '' + CoolUtil.difficultyStuff[storyDifficulty][1];

					trace('LOADING NEXT SONG');
					trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

					var winterHorrorlandNext = (SONG.song.toLowerCase() == "eggnog");
					if (winterHorrorlandNext)
					{
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						add(blackShit);
						camHUD.visible = false;

						FlxG.sound.play(Paths.sound('Lights_Shut_off'));
					}

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;

					prevCamFollow = camFollow;
					prevCamFollowPos = camFollowPos;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					if(winterHorrorlandNext) {
						new FlxTimer().start(1.5, function(tmr:FlxTimer) {
							LoadingState.loadAndSwitchState(new PlayState());
						});
					} else {
						LoadingState.loadAndSwitchState(new PlayState());
					}
				}
			}
			else
			{
				switch (sEnding)
				{
					case 'here we go':
						textIndex = '3-post-eruption';
						afterAction = 'transform';
						schoolIntro(0);
					case 'week1 end':
						textIndex = '4-post-kaioken';
						afterAction = 'end song';
						schoolIntro(0);
					case 'post whats new':
						textIndex = '6-post-whatsnew';
						afterAction = 'transform';
						schoolIntro(0);
					case 'post blast':
						textIndex = '7-post-blast';
						afterAction = 'end song';
						schoolIntro(0);
					case 'week2 end':
						ssCutscene();
					case 'finale end':
						Main.menuBad = false;
						finalCutscene();
					case 'last goodbye': // not actually this is just a name
						lgCutscene();
					case 'wb ending':
						camFollow.x = gf.getMidpoint().x - 100;
						camFollow.y = gf.getMidpoint().y - 100;

						textIndex = 'upd/wb2';
						afterAction = 'wb bye';
						schoolIntro(0);
					case 'zeph ending':
						camFollow.x = dad.getMidpoint().x;
						camFollow.y = dad.getMidpoint().y;
						textIndex = 'upd/zeph3';
						afterAction = 'zeph bye';
						schoolIntro(0);
				}
				sEnding = 'none';
			}
		}
		else
		{
			trace('WENT BACK TO FREEPLAY??');
			MusicBeatState.switchState(new FreeplayState());
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			usedPractice = false;
			changedDifficulty = false;
			cpuControlled = false;
		}
	}

	#if ACHIEVEMENTS_ALLOWED
	var achievementObj:AchievementObject = null;
	function startAchievement(achieve:Int) {
		achievementObj = new AchievementObject(achieve, camOther);
		achievementObj.onFinish = achievementEnd;
		add(achievementObj);
		trace('Giving achievement ' + achieve);
	}
	function achievementEnd():Void
	{
		endSong();
		/*
		achievementObj = null;
		if(endingSong && !inCutscene) {
			
		}
		*/
	}
	#end

	private function KillNotes() {
		while(notes.length > 0) {
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	private function popUpScore(note:Note = null):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + 8); 

		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var daRating:String = "sick";

		if (noteDiff > Conductor.safeZoneOffset * 0.55)
		{
			daRating = 'shit';
			score = 50;
			songMisses++;
			combo = 0;
			health -= 0.1;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.4)
		{
			daRating = 'bad';
			score = 100;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.2)
		{
			daRating = 'good';
			score = 200;
		}

		if(daRating == 'sick')
		{
			spawnNoteSplashOnNote(note);
		}

		if(!practiceMode && !cpuControlled) {
			songScore += score;
			songHits++;
			RecalculateRating();
			if(scoreTxtTween != null) {
				scoreTxtTween.cancel();
			}
			scoreTxt.scale.x = 1.1;
			scoreTxt.scale.y = 1.1;
			scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
				onComplete: function(twn:FlxTween) {
					scoreTxtTween = null;
				}
			});
		}

		/* if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
		 */

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (curStage.startsWith('school'))
		{
			pixelShitPart1 = 'weeb/pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);
		rating.visible = !ClientPrefs.hideHud;

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;
		comboSpr.visible = !ClientPrefs.hideHud;

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		add(rating);

		if (!curStage.startsWith('school'))
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = ClientPrefs.globalAntialiasing;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = ClientPrefs.globalAntialiasing;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		seperatedScore.push(Math.floor(combo / 100));
		seperatedScore.push(Math.floor((combo - (seperatedScore[0] * 100)) / 10));
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			if (!curStage.startsWith('school'))
			{
				numScore.antialiasing = ClientPrefs.globalAntialiasing;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);
			numScore.visible = !ClientPrefs.hideHud;

			if (combo >= 10 || combo == 0)
				add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}
		/* 
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});

		curSection += 1;
	}

	private function keyShit():Void
	{
		// HOLDING
		var up = controls.NOTE_UP;
		var right = controls.NOTE_RIGHT;
		var down = controls.NOTE_DOWN;
		var left = controls.NOTE_LEFT;

		var sH = [
			controls.A1,
			controls.A2,
			controls.A3,
			controls.A5,
			controls.A6,
			controls.A7
		];

		var vH = [
			controls.A1,
			controls.A2,
			controls.A3,
			controls.A4,
			controls.A5,
			controls.A6,
			controls.A7
		];

		var nH = [
			controls.B1,
			controls.B2,
			controls.B3,
			controls.B4,
			controls.B5,
			controls.B6,
			controls.B7,
			controls.B8,
			controls.B9
		];


		var sP = [
			controls.A1_P,
			controls.A2_P,
			controls.A3_P,
			controls.A5_P,
			controls.A6_P,
			controls.A7_P
		];

		var vP = [
			controls.A1_P,
			controls.A2_P,
			controls.A3_P,
			controls.A4_P,
			controls.A5_P,
			controls.A6_P,
			controls.A7_P
		];

		var nP = [
			controls.B1_P,
			controls.B2_P,
			controls.B3_P,
			controls.B4_P,
			controls.B5_P,
			controls.B6_P,
			controls.B7_P,
			controls.B8_P,
			controls.B9_P
		];


		var sR = [
			controls.A1_R,
			controls.A2_R,
			controls.A3_R,
			controls.A5_R,
			controls.A6_R,
			controls.A7_R
		];

		var vR = [
			controls.A1_R,
			controls.A2_R,
			controls.A3_R,
			controls.A4_R,
			controls.A5_R,
			controls.A6_R,
			controls.A7_R
		];

		var nR = [
			controls.B1_R,
			controls.B2_R,
			controls.B3_R,
			controls.B4_R,
			controls.B5_R,
			controls.B6_R,
			controls.B7_R,
			controls.B8_R,
			controls.B9_R
		];

		var upP = controls.NOTE_UP_P;
		var rightP = controls.NOTE_RIGHT_P;
		var downP = controls.NOTE_DOWN_P;
		var leftP = controls.NOTE_LEFT_P;

		var upR = controls.NOTE_UP_R;
		var rightR = controls.NOTE_RIGHT_R;
		var downR = controls.NOTE_DOWN_R;
		var leftR = controls.NOTE_LEFT_R;

		var controlArray:Array<Bool> = [leftP, downP, upP, rightP];
		var controlReleaseArray:Array<Bool> = [leftR, downR, upR, rightR];
		var controlHoldArray:Array<Bool> = [left, down, up, right];

		switch (mania)
		{
			case 1:
				controlArray = sP;
				controlReleaseArray = sR;
				controlHoldArray = sH;
			case 2:
				controlArray = vP;
				controlReleaseArray = vR;
				controlHoldArray = vH;
			case 3:
				controlArray = nP;
				controlReleaseArray = nR;
				controlHoldArray = nH;
		}

		var anyH = false;
		var anyP = false;
		var anyR = false;
		for (i in 0...controlArray.length)
		{
			if (controlHoldArray[i])
				anyH = true;
			if (controlArray[i])
				anyP = true;
			if (controlReleaseArray[i])
				anyR = true;
		}

		// FlxG.watch.addQuick('asdfa', upP);
		if (!boyfriend.stunned && generatedMusic)
		{
			if(anyH && !endingSong) {
				notes.forEachAlive(function(daNote:Note) {
					if(daNote.isSustainNote && controlHoldArray[daNote.noteData] && daNote.canBeHit && daNote.mustPress) {
						goodNoteHit(daNote);
					}
				});

				#if ACHIEVEMENTS_ALLOWED
				var achieve:Int = checkForAchievement([11]);
				if(achieve > -1) {
					startAchievement(achieve);
				}
				#end
			} else if(boyfriend.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing')
			&& !boyfriend.animation.curAnim.name.endsWith('miss')) {
				boyfriend.dance();
			}

			if(anyP && !endingSong) {
				if(!ClientPrefs.ghostTapping)
					boyfriend.holdTimer = 0;

				var canMiss:Bool = !ClientPrefs.ghostTapping;

				var notesHitArray:Array<Note> = [];
				var notesDatas:Array<Int> = [];
				var dupeNotes:Array<Note> = [];
				notes.forEachAlive(function(daNote:Note) {
					if (!daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit) {
						if (notesDatas.indexOf(daNote.noteData) != -1) {
							for (i in 0...notesHitArray.length) {
								var prevNote = notesHitArray[i];
								if (prevNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - prevNote.strumTime) < 10) {
									dupeNotes.push(daNote);
								} else if (prevNote.noteData == daNote.noteData && daNote.strumTime < prevNote.strumTime) {
									notesHitArray.remove(prevNote);
									notesHitArray.push(daNote);
								}
							}
						} else {
							notesHitArray.push(daNote);
							notesDatas.push(daNote.noteData);
						}
						canMiss = true;
					}
				});

				for (i in 0...dupeNotes.length) {
					var daNote = dupeNotes[i];
					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
				notesHitArray.sort(sortByShit);

				if (perfectMode)
					goodNoteHit(notesHitArray[0]);
				else if (notesHitArray.length > 0) {
					for (i in 0...controlArray.length) {
						if(controlArray[i] && notesDatas.indexOf(i) == -1) {
							/*if(canMiss) {
								noteMiss(i);
								callOnLuas('noteMissPress', [i]);
								break;
							}*/ 
							// fuck ur anti mash
						}
					}
					for (i in 0...notesHitArray.length) {
						var daNote = notesHitArray[i];
						if(controlArray[daNote.noteData]) {
							goodNoteHit(daNote);
							if(ClientPrefs.ghostTapping)
								boyfriend.holdTimer = 0;
						}
					}
				} else if(canMiss) {
					badNoteHit();
				}

				for (i in 0...keysPressed.length) {
					if(!keysPressed[i] && controlArray[i]) keysPressed[i] = true;
				}
			}
		}

		playerStrums.forEach(function(spr:StrumNote)
		{
			if(controlArray[spr.ID] && spr.animation.curAnim.name != 'confirm') {
				spr.playAnim('pressed');
				spr.resetAnim = 0;
			}
			if(controlReleaseArray[spr.ID]) {
				spr.playAnim('static');
				spr.resetAnim = 0;
			}
		});
	}

	function badNoteHit():Void {
		var sP = [
			controls.A1_P,
			controls.A2_P,
			controls.A3_P,
			controls.A5_P,
			controls.A6_P,
			controls.A7_P
		];

		var vP = [
			controls.A1_P,
			controls.A2_P,
			controls.A3_P,
			controls.A4_P,
			controls.A5_P,
			controls.A6_P,
			controls.A7_P
		];

		var nP = [
			controls.B1_P,
			controls.B2_P,
			controls.B3_P,
			controls.B4_P,
			controls.B5_P,
			controls.B6_P,
			controls.B7_P,
			controls.B8_P,
			controls.B9_P
		];

		var controlArray:Array<Bool> = [controls.NOTE_LEFT_P, controls.NOTE_DOWN_P, controls.NOTE_UP_P, controls.NOTE_RIGHT_P];

		switch (mania)
		{
			case 1:
				controlArray = sP;
			case 2:
				controlArray = vP;
			case 3:
				controlArray = nP;
		}
		for (i in 0...controlArray.length) {
			if(controlArray[i]) {
				noteMiss(i);
				callOnLuas('noteMissPress', [i]);
			}
		}
	}

	function noteMiss(direction:Int = 1):Void
	{
		if (!boyfriend.stunned)
		{
			health -= 0.04;
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			if(!practiceMode) songScore -= 10;
			if(!endingSong) songMisses++;
			RecalculateRating();

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			/*boyfriend.stunned = true;

			// get stunned for 1/60 of a second, makes you able to
			new FlxTimer().start(1 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});*/
			boyfriend.playAnim('sing' + Main.charDir[Main.gfxHud[mania][direction]] + 'miss', true);
			vocals.volume = 0;
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			switch(note.noteType) {
				case 3: //Hurt note
					if(cpuControlled) return;

					if(!boyfriend.stunned)
					{
						noteMiss(note.noteData);
						if(!endingSong)
						{
							--songMisses;
							RecalculateRating();
							if(!note.isSustainNote) {
								health -= 0.26; //0.26 + 0.04 = -0.3 (-15%) of HP if you hit a hurt note
								spawnNoteSplashOnNote(note);
							}
							else health -= 0.06; //0.06 + 0.04 = -0.1 (-5%) of HP if you hit a hurt sustain note
	
							if(boyfriend.animation.getByName('hurt') != null) {
								boyfriend.playAnim('hurt', true);
								boyfriend.specialAnim = true;
							}
						}

						note.wasGoodHit = true;
						vocals.volume = 0;

						if (!note.isSustainNote)
						{
							note.kill();
							notes.remove(note, true);
							note.destroy();
						}
					}
					return;
			}

			if (!note.isSustainNote)
			{
				popUpScore(note);
				combo += 1;
			}

			if (note.noteData >= 0)
				health += 0.023;
			else
				health += 0.004;

			if(note.noteType == 2) {
				boyfriend.playAnim('hey', true);
				boyfriend.specialAnim = true;
				boyfriend.heyTimer = 0.6;

				gf.playAnim('cheer', true);
				gf.specialAnim = true;
				gf.heyTimer = 0.6;
			} else {
				var daAlt = '';
				if(note.noteType == 1) daAlt = '-alt';

				var animToPlay:String = '';

				animToPlay = 'sing' + Main.charDir[Main.gfxHud[mania][Std.int(Math.abs(note.noteData))]];
	
				boyfriend.playAnim(animToPlay + daAlt, true);
			}

			if(cpuControlled) {
				var time:Float = 0.15;
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
					time += 0.15;
				}
				StrumPlayAnim(false, Std.int(Math.abs(note.noteData)) % 4, time);
			} else {
				playerStrums.forEach(function(spr:StrumNote)
				{
					if (Math.abs(note.noteData) == spr.ID)
					{
						spr.playAnim('confirm', true);
					}
				});
			}

			note.wasGoodHit = true;
			vocals.volume = 1;

			var isSus:Bool = note.isSustainNote; //GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
			var leData:Int = note.noteData;
			var leType:Int = note.noteType;
			if (!note.isSustainNote)
			{
				if(cpuControlled) {
					boyfriend.holdTimer = 0;
				}
				note.kill();
				notes.remove(note, true);
				note.destroy();
			} else if(cpuControlled) {
				var targetHold:Float = Conductor.stepCrochet * 0.001 * boyfriend.singDuration;
				if(boyfriend.holdTimer + 0.2 > targetHold) {
					boyfriend.holdTimer = targetHold - 0.2;
				}
			}
			callOnLuas('goodNoteHit', [leData, leType, isSus]);
		}
	}

	function spawnNoteSplashOnNote(note:Note) {
		/*
		if(ClientPrefs.noteSplashes && note != null) {
			var strum:StrumNote = playerStrums.members[note.noteData];
			if(strum != null) {
				spawnNoteSplash(strum.x, strum.y, note.noteData, note.noteType);
			}
		}
		*/
	}

	public function spawnNoteSplash(x:Float, y:Float, data:Int, type:Int) {
		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x, y, data, type);
		grpNoteSplashes.add(splash);
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	function fastCarDrive()
	{
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gf.playAnim('hairBlow');
			gf.specialAnim = true;
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		gf.danced = false; //Sets head to the correct position once the animation ends
		gf.playAnim('hairFall');
		gf.specialAnim = true;
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		if(!ClientPrefs.lowQuality) halloweenBG.animation.play('halloweem bg lightning strike');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		if(boyfriend.animOffsets.exists('scared')) {
			boyfriend.playAnim('scared', true);
		}
		if(gf.animOffsets.exists('scared')) {
			gf.playAnim('scared', true);
		}

		if(ClientPrefs.camZooms) {
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;

			if(!camZooming) { //Just a way for preventing it to be permanently zoomed until Skid & Pump hits a note
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.5);
				FlxTween.tween(camHUD, {zoom: 1}, 0.5);
			}
		}

		if(ClientPrefs.flashing) {
			halloweenWhite.alpha = 0.45;
			FlxTween.tween(halloweenWhite, {alpha: 0.6}, 0.075);
			FlxTween.tween(halloweenWhite, {alpha: 0}, 0.25, {startDelay: 0.15});
		}
	}

	function killHenchmen():Void
	{
		if(!ClientPrefs.lowQuality && ClientPrefs.violence && curStage == 'limo') {
			if(limoKillingState < 1) {
				limoMetalPole.x = -400;
				limoMetalPole.visible = true;
				limoLight.visible = true;
				limoCorpse.visible = false;
				limoCorpseTwo.visible = false;
				limoKillingState = 1;

				#if ACHIEVEMENTS_ALLOWED
				Achievements.henchmenDeath++;
				var achieve:Int = checkForAchievement([10]);
				if(achieve > -1) {
					startAchievement(achieve);
				} else {
					FlxG.save.data.henchmenDeath = Achievements.henchmenDeath;
					FlxG.save.flush();
				}
				FlxG.log.add('Deaths: ' + Achievements.henchmenDeath);
				#end
			}
		}
	}

	function resetLimoKill():Void
	{
		if(curStage == 'limo') {
			limoMetalPole.x = -500;
			limoMetalPole.visible = false;
			limoLight.x = -500;
			limoLight.visible = false;
			limoCorpse.x = -500;
			limoCorpse.visible = false;
			limoCorpseTwo.x = -500;
			limoCorpseTwo.visible = false;
		}
	}

	override function destroy() {
		for (i in 0...luaArray.length) {
			luaArray[i].call('onDestroy', []);
			luaArray[i].stop();
		}
		super.destroy();
	}

	var lastStepHit:Int = -1;
	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		if(curStep == lastStepHit) {
			return;
		}

		lastStepHit = curStep;
		setOnLuas('curStep', curStep);
		callOnLuas('onStepHit', []);
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	var lastBeatHit:Int = -1;
	override function beatHit()
	{
		super.beatHit();

		if(lastBeatHit >= curBeat) {
			trace('BEAT HIT: ' + curBeat + ', LAST HIT: ' + lastBeatHit);
			return;
		}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				//FlxG.log.add('CHANGED BPM!');
				setOnLuas('curBpm', Conductor.bpm);
				setOnLuas('crochet', Conductor.crochet);
				setOnLuas('stepCrochet', Conductor.stepCrochet);
			}
			setOnLuas('mustHitSection', SONG.notes[Math.floor(curStep / 16)].mustHitSection);
			// else
			// Conductor.changeBPM(SONG.bpm);
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);

		if (camZooming && FlxG.camera.zoom < 1.35 && ClientPrefs.camZooms && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0 && !gf.stunned)
		{
			gf.dance();
		}

		if(curBeat % 2 == 0) {
			if (!boyfriend.animation.curAnim.name.startsWith("sing") && !boyfriend.specialAnim)
			{
				boyfriend.dance();
			}
			if (!dad.animation.curAnim.name.startsWith("sing") && !dad.stunned)
			{
				dad.dance();
			}
		} else if(dad.danceIdle && !dad.curCharacter.startsWith('gf') && !dad.animation.curAnim.name.startsWith("sing") && !dad.stunned) {
			dad.dance();
		}

		switch (curStage)
		{
			case 'school':
				if(!ClientPrefs.lowQuality) {
					bgGirls.dance();
				}

			case 'mall':
				if(!ClientPrefs.lowQuality) {
					upperBoppers.dance(true);
				}

				if(heyTimer <= 0) bottomBoppers.dance(true);
				santa.dance(true);

			case 'limo':
				if(!ClientPrefs.lowQuality) {
					grpLimoDancers.forEach(function(dancer:BackgroundDancer)
					{
						dancer.dance();
					});
				}

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					phillyCityLights.forEach(function(light:BGSprite)
					{
						light.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1, [curLight]);

					phillyCityLights.members[curLight].visible = true;
					phillyCityLights.members[curLight].alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		if (curStage == 'spooky' && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
		lastBeatHit = curBeat;

		setOnLuas('curBeat', curBeat);
		callOnLuas('onBeatHit', []);
	}

	public function callOnLuas(event:String, args:Array<Dynamic>):Dynamic {
		var returnVal:Dynamic = FunkinLua.Function_Continue;
		for (i in 0...luaArray.length) {
			var ret:Dynamic = luaArray[i].call(event, args);
			if(ret != FunkinLua.Function_Continue) {
				returnVal = ret;
			}
		}
		return returnVal;
	}

	public function setOnLuas(variable:String, arg:Dynamic) {
		for (i in 0...luaArray.length) {
			luaArray[i].set(variable, arg);
		}
	}

	function StrumPlayAnim(isDad:Bool, id:Int, time:Float) {
		var spr:StrumNote = null;
		if(isDad) {
			spr = strumLineNotes.members[id];
		} else {
			spr = playerStrums.members[id];
		}

		if(spr != null) {
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	public var ratingString:String;
	public var ratingPercent:Float;
	public function RecalculateRating() {
		setOnLuas('score', songScore);
		setOnLuas('misses', songMisses);
		setOnLuas('hits', songHits);

		var ret:Dynamic = callOnLuas('onRecalculateRating', []);
		if(ret != FunkinLua.Function_Stop) {
			ratingPercent = songScore / ((songHits + songMisses) * 350);
			if(!Math.isNaN(ratingPercent) && ratingPercent < 0) ratingPercent = 0;

			if(Math.isNaN(ratingPercent)) {
				ratingString = '?';
			} else if(ratingPercent >= 1) {
				ratingPercent = 1;
				ratingString = ratingStuff[ratingStuff.length-1][0]; //Uses last string
			} else {
				for (i in 0...ratingStuff.length-1) {
					if(ratingPercent < ratingStuff[i][1]) {
						ratingString = ratingStuff[i][0];
						break;
					}
				}
			}

			setOnLuas('rating', ratingPercent);
			setOnLuas('ratingName', ratingString);
		}
	}

	#if ACHIEVEMENTS_ALLOWED
	private function checkForAchievement(arrayIDs:Array<Int>):Int {
		for (i in 0...arrayIDs.length) {
			if(!Achievements.achievementsUnlocked[arrayIDs[i]][1]) {
				switch(arrayIDs[i]) {
					case 1 | 2 | 3 | 4 | 5 | 6 | 7:
						if(isStoryMode && campaignMisses + songMisses < 1 && CoolUtil.difficultyString() == 'Hard' &&
						storyPlaylist.length <= 1 && WeekData.getCurrentWeekNumber() == arrayIDs[i] && !changedDifficulty && !usedPractice) {
							Achievements.unlockAchievement(arrayIDs[i]);
							return arrayIDs[i];
						}
					case 8:
						if(ratingPercent < 0.2 && !practiceMode && !cpuControlled) {
							Achievements.unlockAchievement(arrayIDs[i]);
							return arrayIDs[i];
						}
					case 9:
						if(ratingPercent >= 1 && !usedPractice && !cpuControlled) {
							Achievements.unlockAchievement(arrayIDs[i]);
							return arrayIDs[i];
						}
					case 10:
						if(Achievements.henchmenDeath >= 100) {
							Achievements.unlockAchievement(arrayIDs[i]);
							return arrayIDs[i];
						}
					case 11:
						if(boyfriend.holdTimer >= 20 && !usedPractice) {
							Achievements.unlockAchievement(arrayIDs[i]);
							return arrayIDs[i];
						}
					case 12:
						if(!boyfriendIdled && !usedPractice) {
							Achievements.unlockAchievement(arrayIDs[i]);
							return arrayIDs[i];
						}
					case 13:
						if(!usedPractice) {
							var howManyPresses:Int = 0;
							for (j in 0...keysPressed.length) {
								if(keysPressed[j]) howManyPresses++;
							}

							if(howManyPresses <= 2) {
								Achievements.unlockAchievement(arrayIDs[i]);
								return arrayIDs[i];
							}
						}
					case 14:
						if(ClientPrefs.framerate <= 60 && ClientPrefs.lowQuality && !ClientPrefs.globalAntialiasing && !ClientPrefs.imagesPersist) {
							Achievements.unlockAchievement(arrayIDs[i]);
							return arrayIDs[i];
						}
					case 15:
						if(SONG.song.toLowerCase() == 'test' && !usedPractice) {
							Achievements.unlockAchievement(arrayIDs[i]);
							return arrayIDs[i];
						}
				}
			}
		}
		return -1;
	}
	#end
	
	public function godIntro()
	{
		dad.playAnim('back', true);
		new FlxTimer().start(3, function(tmr:FlxTimer)
		{
			dad.playAnim('snap', true);
			new FlxTimer().start(0.85, function(tmr2:FlxTimer)
			{
				FlxG.sound.play(Paths.sound('snap'));
				FlxG.sound.play(Paths.sound('undSnap'));
				sShake = 10;
				//pon el sonido con los efectos circulares
				new FlxTimer().start(0.06, function(tmr3:FlxTimer)
				{
					dad.playAnim('snapped', true);
				});
				new FlxTimer().start(1.5, function(tmr4:FlxTimer)
				{
					//la camara tiembla y puede ser que aparezcan rocas?
					new FlxTimer().start(0.001, function(shkUp:FlxTimer)
					{
						sShake += 0.51;
						if (!godCutEnd) shkUp.reset(0.001);
					});
					new FlxTimer().start(1, function(tmr5:FlxTimer)
					{
						add(new MansionDebris(-300, -120, 'ceil', 1, 1, -4, -40));
						add(new MansionDebris(0, -120, 'ceil', 1, 1, -4, -5));
						add(new MansionDebris(200, -120, 'ceil', 1, 1, -4, 40));

						sShake += 5;
						FlxG.sound.play(Paths.sound('ascend'));
						boyfriend.playAnim('hit');
						godCutEnd = true;
						new FlxTimer().start(0.4, function(tmr6:FlxTimer)
						{
							godMoveGf = true;
							boyfriend.playAnim('hit');
						});
						new FlxTimer().start(1, function(tmr9:FlxTimer)
						{
							boyfriend.playAnim('scared', true);
						});
						new FlxTimer().start(2, function(tmr7:FlxTimer)
						{
							dad.playAnim('idle', true);
							FlxG.sound.play(Paths.sound('shagFly'));
							godMoveSh = true;
							new FlxTimer().start(1.5, function(tmr8:FlxTimer)
							{
								startCountdown();
							});
						});
					});
				});	
			});
		});
		new FlxTimer().start(0.001, function(shk:FlxTimer)
		{
			if (sShake > 0)
			{
				sShake -= 0.5;
				FlxG.camera.angle = FlxG.random.float(-sShake, sShake);
			}
			shk.reset(0.001);
		});
	}

	var curLight:Int = 0;
	var curLightEvent:Int = 0;

	var scoob:Character;
	var cs_time:Int = 0;
	var cs_wait:Bool = false;
	var cs_zoom:Float = 1;
	var cs_slash_dim:FlxSprite;
	var cs_sfx:FlxSound;
	var cs_mus:FlxSound;
	var sh_body:FlxSprite;
	var sh_head:FlxSprite;
	var cs_cam:FlxObject;
	var cs_black:FlxSprite;
	var sh_ang:FlxSprite;
	var sh_ang_eyes:FlxSprite;
	var cs_bg:FlxSprite;
	var cs_reset:Bool = false;
	var nex:Float = 1;

	public function ssCutscene()
	{
		cs_cam = new FlxObject(0, 0, 1, 1);
		cs_cam.x = 605;
		cs_cam.y = 410;
		add(cs_cam);
		camFollowPos.destroy();
		FlxG.camera.follow(cs_cam, LOCKON, 0.01);

		Main.menuBad = true;
		new FlxTimer().start(0.002, function(tmr:FlxTimer)
		{
			switch (cs_time)
			{
				case 1:
					cs_zoom = 0.65;
				case 25:
					//scoob = new Character(1700, 290, 'scooby', false);
					scoob.playAnim('walk', true);
					scoob.x = 1700;
					scoob.y = 290;
					//scoob.playAnim('walk');
				case 240:
					scoob.playAnim('idle', true);
				case 340:
					burstRelease(dad.getMidpoint().x, dad.getMidpoint().y);

					dadGroup.remove(dad);
					dad = new Character(dad.x, dad.y, 'shaggy');
					dadGroup.add(dad);
					dad.playAnim('idle', true);
				case 390:
					remove(burst);
				case 420:
					if (!cs_wait)
					{
						csDial('found_scooby');
						schoolIntro(0);
						cs_wait = true;
						cs_reset = true;

						cs_mus = FlxG.sound.load(Paths.sound('cs_happy'));
						cs_mus.play();
						cs_mus.looped = true;
					}
				case 540:
					scoob.playAnim('scare', true);
					cs_mus.fadeOut(2, 0);
				case 900:
					FlxG.sound.play(Paths.sound('blur'));
					scoob.playAnim('blur', true);
					scoob.x -= 200;
					scoob.y += 100;
					scoob.angle = 23;
					dad.playAnim('catch', true);
				case 903:
					scoob.x = -4000;
					scoob.angle = 0;
				case 940:
					dad.playAnim('hold', true);
					cs_sfx = FlxG.sound.load(Paths.sound('scared'));
					cs_sfx.play();
					cs_sfx.looped = true;
				case 1200:
					if (!cs_wait)
					{
						csDial('scooby_hold_talk');
						schoolIntro(0);
						cs_wait = true;
						cs_reset = true;

						cs_mus.stop();
						cs_mus = FlxG.sound.load(Paths.sound('cs_drums'));
						cs_mus.play();
						cs_mus.looped = true;
					}
				case 1201:
					cs_sfx.stop();
					cs_mus.stop();
					FlxG.sound.play(Paths.sound('counter_back'));
					cs_slash_dim = new FlxSprite(-500, -400).makeGraphic(FlxG.width * 4, FlxG.height * 4, FlxColor.WHITE);
					cs_slash_dim.scrollFactor.set();
					add(cs_slash_dim);
					dad.playAnim('h_half', true);
					gf.playAnim('kill', true);
					scoob.playAnim('half', true);
					scoob.x += 4100;
					scoob.y -= 150;

					scoob.x -= 90;
					scoob.y -= 252;
				case 1700:
					scoob.playAnim('fall', true);
					cs_cam.x -= 150;
				case 1740:
					FlxG.sound.play(Paths.sound('body_fall'));
				case 2000:
					if (!cs_wait)
					{
						gf.playAnim('danceRight', true);
						csDial('gf_sass');
						schoolIntro(0);
						cs_wait = true;
						cs_reset = true;
					}
				case 2150:
					dad.playAnim('fall', true);
				case 2180:
					FlxG.sound.play(Paths.sound('shaggy_kneel'));
				case 2245:
					FlxG.sound.play(Paths.sound('body_fall'));
				case 2280:
					dad.playAnim('kneel', true);
					sh_head = new FlxSprite(440, 100);
					sh_head.y = 100 + FlxG.random.int(-0, 0);
					sh_head.frames = Paths.getSparrowAtlas('bshaggy');
					sh_head.animation.addByPrefix('idle', "bshaggy_head_still", 30);
					sh_head.animation.addByPrefix('turn', "bshaggy_head_transform", 30);
					sh_head.animation.addByPrefix('idle2', "bsh_head2_still", 30);
					sh_head.animation.play('turn');
					sh_head.animation.play('idle');
					sh_head.antialiasing = true;

					sh_ang = new FlxSprite(0, 0);
					sh_ang.frames = Paths.getSparrowAtlas('bshaggy');
					sh_ang.animation.addByPrefix('idle', "bsh_angry", 30);
					sh_ang.animation.play('idle');
					sh_ang.antialiasing = true;

					sh_ang_eyes = new FlxSprite(0, 0);
					sh_ang_eyes.frames = Paths.getSparrowAtlas('bshaggy');
					sh_ang_eyes.animation.addByPrefix('stare', "bsh_eyes", 30);
					sh_ang_eyes.animation.play('stare');
					sh_ang_eyes.antialiasing = true;

					cs_bg = new FlxSprite(-500, -80);
					cs_bg.frames = Paths.getSparrowAtlas('cs_bg');
					cs_bg.animation.addByPrefix('back', "cs_back_bg", 30);
					cs_bg.animation.addByPrefix('stare', "cs_bg", 30);
					cs_bg.animation.play('back');
					cs_bg.antialiasing = true;
					cs_bg.setGraphicSize(Std.int(cs_bg.width * 1.1));

					cs_sfx = FlxG.sound.load(Paths.sound('powerup'));
				case 2500:
					add(cs_bg);
					add(sh_head);

					sh_body = new FlxSprite(200, 250);
					sh_body.frames = Paths.getSparrowAtlas('bshaggy');
					sh_body.animation.addByPrefix('idle', "bshaggy_body_still", 30);
					sh_body.animation.play('idle');
					sh_body.antialiasing = true;
					add(sh_body);

					cs_mus = FlxG.sound.load(Paths.sound('cs_cagaste'));
					cs_mus.looped = false;
					cs_mus.play();
					cs_cam.x += 150;
					FlxG.camera.follow(cs_cam, LOCKON, 1);
				case 3100:
					burstRelease(1000, 300);
				case 3580:
					burstRelease(1000, 300);
					cs_sfx.play();
					cs_sfx.looped = false;
					FlxG.camera.angle = 10;
				case 4000:
					burstRelease(1000, 300);
					cs_sfx.play();
					FlxG.camera.angle = -20;
					sh_head.animation.play('turn');
					sh_head.offset.set(0, 60);

					cs_sfx = FlxG.sound.load(Paths.sound('charge'));
					cs_sfx.play();
					cs_sfx.looped = true;
				case 4003:
					cs_mus.play(true, 12286 - 337);
				case 4065:
					sh_head.animation.play('idle2');
				case 4550:
					remove(sh_head);
					remove(sh_body);
					cs_sfx.stop();


					sh_ang.x = -140;
					sh_ang.y = -5;

					sh_ang_eyes.x = 688;
					sh_ang_eyes.y = 225;

					add(sh_ang);
					add(sh_ang_eyes);

					cs_bg.animation.play('stare');

					cs_black = new FlxSprite(-500, -400).makeGraphic(FlxG.width * 4, FlxG.height * 4, FlxColor.BLACK);
					cs_black.scrollFactor.set();
					add(cs_black);

					cs_mus.play(true, 16388);
				case 6000:
					cs_black.alpha = 2;
					cs_mus.stop();
				case 6100:
					endSong();
			}
			if (cs_time >= 25 && cs_time <= 240)
			{
				scoob.x -= 6;
				scoob.playAnim('walk');
			}
			if (cs_time > 240 && cs_time < 540)
			{
				scoob.playAnim('idle');
			}
			if (cs_time > 940 && cs_time < 1201)
			{
				dad.playAnim('hold');
			}
			if (cs_time > 1201 && cs_time < 2500)
			{
				cs_slash_dim.alpha -= 0.003;
			}
			if (cs_time >= 2500 && cs_time < 4550)
			{
				cs_zoom += 0.0001;
			}
			if (cs_time >= 5120 && cs_time <= 6000)
			{
				cs_black.alpha -= 0.0015;
			}
			if (cs_time >= 3580 && cs_time < 4000)
			{
				sh_head.y = 100 + FlxG.random.int(-5, 5);
			}
			if (cs_time >= 4000 && cs_time <= 4548)
			{
				sh_head.x = 440 + FlxG.random.int(-10, 10);
				sh_body.x = 200 + FlxG.random.int(-5, 5);
			}

			if (cs_time == 3400 || cs_time == 3450 || cs_time == 3500 || cs_time == 3525 || cs_time == 3550 || cs_time == 3560 || cs_time == 3570)
			{
				burstRelease(1000, 300);
			}

			FlxG.camera.zoom += (cs_zoom - FlxG.camera.zoom) / 12;
			FlxG.camera.angle += (0 - FlxG.camera.angle) / 12;
			if (!cs_wait)
			{
				cs_time ++;
			}
			tmr.reset(0.002);
		});
	}

	var dfS:Float = 1;
	var toDfS:Float = 1;
	public function finalCutscene()
	{
		cs_zoom = defaultCamZoom;
		cs_cam = new FlxObject(0, 0, 1, 1);
		camFollow.x = boyfriend.getMidpoint().x - 100;
		camFollow.y = boyfriend.getMidpoint().y - 100;
		cs_cam.x = camFollow.x;
		cs_cam.y = camFollow.y;
		add(cs_cam);
		camFollow.destroy();
		FlxG.camera.follow(cs_cam, LOCKON, 0.01);

		new FlxTimer().start(0.002, function(tmr:FlxTimer)
		{
			switch (cs_time)
			{
				case 200:
					cs_cam.x -= 500;
					cs_cam.y -= 200;
				case 400:
					dad.playAnim('smile');
				case 500:
					if (!cs_wait)
					{
						var exStr = '';
						if (alterRoute == 1)
						{
							exStr += '_alter';
						}
						csDial('sh_amazing' + exStr);
						schoolIntro(0);
						cs_wait = true;
						cs_reset = true;
					}
				case 700:
					godCutEnd = false;
					FlxG.sound.play(Paths.sound('burst'));
					if (maskObj != null) maskObj.x -= 5000;
					//maskCollGroup.remove(maskObj);
					dad.playAnim('stand', true);
					dad.x = 100;
					dad.y = 100;
					boyfriend.x = 770;
					boyfriend.y = 450;
					gf.x = 400;
					gf.y = 130;
					gf.scrollFactor.set(0.95, 0.95);
					gf.setGraphicSize(Std.int(gf.width));
					cs_cam.y = boyfriend.y;
					cs_cam.x += 100;
					cs_zoom = 0.8;
					FlxG.camera.zoom = cs_zoom;
					scoob.x = dad.x - 400;
					scoob.y = 290;
					scoob.flipX = true;
					remove(shaggyT);
					FlxG.camera.follow(cs_cam, LOCKON, 1);
				case 800:
					if (!cs_wait)
					{
						var exStr = '';
						if (alterRoute == 1)
						{
							exStr += '_alter';
						}
						csDial('sh_expo' + exStr);
						schoolIntro(0);
						cs_wait = true;
						cs_reset = true;

						cs_mus = FlxG.sound.load(Paths.sound('cs_finale'));
						cs_mus.looped = true;
						cs_mus.play();
					}
				case 840:
					FlxG.sound.play(Paths.sound('exit'));
					doorFrame.alpha = 1;
					doorFrame.x -= 90;
					doorFrame.y -= 130;
					toDfS = 700;
				case 1150:
					if (!cs_wait)
					{
						csDial('sh_bye');
						schoolIntro(0);
						cs_wait = true;
						cs_reset = true;
					}
				case 1400:
					FlxG.sound.play(Paths.sound('exit'));
					toDfS = 1;
				case 1645:
					cs_black = new FlxSprite(-500, -400).makeGraphic(FlxG.width * 4, FlxG.height * 4, FlxColor.BLACK);
					cs_black.scrollFactor.set();
					cs_black.alpha = 0;
					add(cs_black);
					cs_wait = true;
					modCredits();
					cs_time ++;
				case -1:
					if (!cs_wait)
					{
						csDial('troleo');
						schoolIntro(0);
						cs_wait = true;
						cs_reset = true;
					}
				case 1651:
					endSong();
			}
			if (cs_time > 700)
			{
				scoob.playAnim('idle');
			}
			if (cs_time > 1150)
			{
				scoob.alpha -= 0.004;
				dad.alpha -= 0.004;
			}
			FlxG.camera.zoom += (cs_zoom - FlxG.camera.zoom) / 12;
			if (!cs_wait)
			{
				cs_time ++;
			}

			dfS += (toDfS - dfS) / 18;
			doorFrame.setGraphicSize(Std.int(dfS));
			tmr.reset(0.002);
		});
	}
	var title:FlxSprite;
	var thanks:Alphabet;
	var endtxt:Alphabet;
	public function modCredits()
	{
		FlxG.sound.play(Paths.sound('cs_credits'));
		new FlxTimer().start(0.002, function(btmr:FlxTimer)
		{
			cs_black.alpha += 0.0025;
			btmr.reset(0.002);
		});

		new FlxTimer().start(3, function(tmrt:FlxTimer)
		{
			title = new FlxSprite(FlxG.width / 2 - 400, FlxG.height / 2 - 300).loadGraphic(Paths.image('sh_title'));
			title.setGraphicSize(Std.int(title.width * 1.2));
			title.antialiasing = true;
			title.scrollFactor.set();
			title.centerOffsets();
			//title.active = false;
			add(title);

			new FlxTimer().start(2.5, function(tmrth:FlxTimer)
			{
				thanks = new Alphabet(0, FlxG.height / 2 + 300, "THANKS FOR PLAYING THIS MOD", true, false);
				thanks.screenCenter(X);
				thanks.x -= 150;
				add(thanks);

				new FlxTimer().start(2.5, function(tmrth:FlxTimer)
				{
					MASKstate.endingUnlock(0);
					endtxt = new Alphabet(6, FlxG.height / 2 + 380, "MAIN ENDING", true, false);
					endtxt.screenCenter(X);
					endtxt.x -= 150;
					add(endtxt);

					new FlxTimer().start(12, function(gback:FlxTimer)
					{
						cs_wait = false;
					});
				});
			});
		});
	}

	public function lgCutscene()
	{
		new FlxTimer().start(0.002, function(tmr:FlxTimer)
		{
			switch (cs_time)
			{
				case 0:
					if (!cs_wait)
					{
						textIndex = 'upd/4-1';
						schoolIntro(0);
						cs_wait = true;
						cs_reset = true;
					}	
				case 40:
					FlxG.sound.play(Paths.sound('exit'));
					doorFrame.alpha = 1;
					doorFrame.y -= 110;
					toDfS = 600;
				case 200:
					if (!cs_wait)
					{
						textIndex = 'upd/4-2';
						schoolIntro(0);
						cs_wait = true;
						cs_reset = true;
					}
				case 480:
					FlxG.sound.play(Paths.sound('exit'));
					toDfS = 1;
				case 720:
					var video:MP4Handler = new MP4Handler();

					video.playMP4(Paths.video('zoinks'));
					video.finishCallback = function()
					{
						endSong();
					}
			}
			if (cs_time > 220)
			{
				dad.alpha -= 0.004;
			}
			if (!cs_wait)
			{
				cs_time ++;
			}
			dfS += (toDfS - dfS) / 18;
			doorFrame.setGraphicSize(Std.int(dfS));
			tmr.reset(0.002);
		});
	}

	public function csDial(puta:String)
	{
		textIndex  = 'cs/' + puta;
	}
}
