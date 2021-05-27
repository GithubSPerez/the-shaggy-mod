package;

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
import openfl.display.FPS;

using StringTools;

class PlayState extends MusicBeatState
{
	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var weekSong:Int = 0;
	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;
	public static var mania:Int = 0;
	public static var keyAmmo:Array<Int> = [4, 6, 9];

	public static var rep:Replay;
	public static var loadRep:Bool = false;
	public static var pStep:Float;

	var halloweenLevel:Bool = false;

	private var vocals:FlxSound;

	private var dad:Character;
	private var gf:Character;
	private var boyfriend:Boyfriend;

	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	private var strumLine:FlxSprite;
	private var curSection:Int = 0;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	private var strumLineNotes:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxTypedGroup<FlxSprite>;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;
	private var health:Float = 1;
	private var combo:Int = 0;
	public static var misses:Int = 0;
	private var accuracy:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalPlayed:Int = 0;
	private var ss:Bool = false;


	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;
	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	private var cutTime:Float;
	private var shaggyT:FlxTrail;
	private var ctrTime:Float = 0;
	private var notice:FlxText;
	private var nShadow:FlxText;

	var songEnded:Bool = false;

	var stress:Float;

	var sh_r:Float = 600;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	var dface:Array<String>;
	var dside:Array<Int>;

	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;

	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;

	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	var fc:Bool = true;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();

	var talking:Bool = true;
	var songScore:Int = 0;
	var scoreTxt:FlxText;
	var replayTxt:FlxText;


	var godCutEnd:Bool = false;
	var godMoveBf:Bool = true;
	var godMoveGf:Bool = false;
	var godMoveSh:Bool = false;

	
	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	public static var daPixelZoom:Float = 6;

	public static var theFunne:Bool = true;
	var funneEffect:FlxSprite;
	var burst:FlxSprite;
	var rock:FlxSprite;
	var gf_rock:FlxSprite;
	var doorFrame:FlxSprite;
	var dfS:Float = 1;
	var inCutscene:Bool = false;
	public static var repPresses:Int = 0;
	public static var repReleases:Int = 0;

	public static var timeCurrently:Float = 0;
	public static var timeCurrentlyR:Float = 0;

	var cs_reset:Bool = false;
	var s_ending:Bool = false;

	var gf_launched:Bool = false;

	override public function create()
	{
		theFunne = FlxG.save.data.newInput;
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		sicks = 0;
		bads = 0;
		shits = 0;
		goods = 0;

		misses = 0;

		stress = 1;

		repPresses = 0;
		repReleases = 0;

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		mania = SONG.mania;
		
		switch (SONG.song.toLowerCase())
		{
			case 'tutorial':
				dialogue = ["Hey you're pretty cute.", 'suck my clit or you die.'];
			case 'where-are-you':
				//the text to appear;
				dialogue = [
					"Hey you guys",
					"I'm looking for a dog that got lost\nin this mansion",
					"His name is scooby, have you like seen him\nor anything?",
					"beep bap boop", //na man, haven't seen any dog. Hey are u good at singing? we came here for a battle.
					"You wanna like, sing?\nBut I haven't found scoobs yet",
					"bop bee bap", //This house is a mess, there ain't nothing u can do but sing! I hope yo dog isn't fuckin dead tho
					"I sure hope so too...",
					"Alright, just a couple of songs though, I\ndon't know that many"
				];
				//the sprites to go along with text (n for no change)
				dface = [
						"f_sh_ser", "n", "n",
						"f_bf",
						"f_sh_con",
						"f_bf",
						"f_sh_ser",
						"f_sh_smug"
						];
				//the sides of the faces (1=left, -1=right and flipped)
				dside = [1, 1, 1, -1, 1, -1, 1, 1];
			case 'eruption':
				dialogue = [
					"Zoinks! I lost control for a second...",
					"I'm sorry man, don't wanna make it\nunfair for you or anything.",
					"beep boop", //adequate sentiment bitch. uh i mean let's keep singing bro!!
					"Okay, like, get ready now and stuff"
				];
				dface = [
						"f_sh",
						"f_sh",
						"f_bf",
						"f_sh_smug"
						];
				dside = [1, 1, -1, 1];
			case 'kaio-ken':
				dialogue = [
					"You're like, actually good and stuff",
					"I don't wanna like bore you, so I'll\nsing faster this time",
					"beep boop boop bap bee", //yeah like that's gonna make it harder for me. ur too easy man! come up with something... not boring!
					"...",
					"Alright, alright...\nHere we go man!",
				];
				dface = [
						"f_sh",
						"f_sh",
						"f_bf",
						"f_sh_ser",
						"f_sh_smug"
						];
				dside = [1, 1, -1, 1, 1];
			case 'whats-new':
				dialogue = [
					"You haven't seen scoob around?",
					"bap boop",
					"Oh gosh! I haven't like, found him either!\nHe must be so scared...",
					"boop bap",
					"Huh? sing again?", //Did I fuckin stutter? Bring it on bitch, I'm tired of your shit. I didn't even care for your dog.
					"You know, maybe singing Scooby's\nfavorite song might call his attention\nand stuff",
					"If he can hear us...",
					"Alright, here we go."
				];
				dface = [
						"f_sh_ser",
						"f_bf",
						"f_sh_con",
						"f_bf",
						"f_sh_con",
						"f_sh_ser",
						"f_sh_con",
						"f_sh"
						];
				dside = [1, -1, 1, -1, 1, 1, 1, 1];
			case 'blast':
				dialogue = [
					"...",
					"...",
					"...",
					"Scooby's my closest friend y'know",
					"We've been together for the last 70 years!",
					"I stopped my aging when I was like 17.",
					"I didn't do the same to my friends because it\nwould be selfish for me to not let them\nrest and stuff...",
					"But zoinks! Scooby was so insistent.\nhe told me he'd never regret his decision if\nit meant to spend eternity side by side.",
					"Now he's the only one I have left...",
					"beep bee bap!",
					"...",
					"I'm uh.. gonna make some noise."
				];
				dface = [
						"f_sh", "f_sh_ser",
						"f_bf",
						"f_sh_ser", "f_sh", "f_sh_ser", "f_sh_con", "f_sh_pens", "f_sh_sad",
						"f_bf",
						"f_sh_ang", "f_sh_smug"
						];
				dside = [1, 1, -1, 1, 1, 1, 1, 1, 1, -1, 1, 1];
			case 'super-saiyan':
				dialogue = [
					"beep boo baa", 
					"bap bee beep boop bee", 
					"bap bap bee pop", 
					"That's like, really rude man...\nI really-",
					"bee boop",
					"...",
					"Heh.",
					"Prick."
				];
				dface = [
						"f_bf", "n", "n",
						"f_sh_con",
						"f_bf",
						"f_sh_ang", "f_sh_smug", "n"
						];
				dside = [-1, -1, -1, 1, -1, 1, 1, 1, 1];
			case 'dadbattle':
				
			case 'garden-havoc':
		}

		if (SONG.song.toLowerCase() == 'spookeez' || SONG.song.toLowerCase() == 'monster' || SONG.song.toLowerCase() == 'south')
		{
			curStage = "spooky";
			halloweenLevel = true;

			var hallowTex = Paths.getSparrowAtlas('halloween_bg');

			halloweenBG = new FlxSprite(-200, -100);
			halloweenBG.frames = hallowTex;
			halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
			halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
			halloweenBG.animation.play('idle');
			halloweenBG.antialiasing = true;
			add(halloweenBG);

			isHalloween = true;
		}
		else if (SONG.song.toLowerCase() == 'pico' || SONG.song.toLowerCase() == 'blammed' || SONG.song.toLowerCase() == 'philly')
		{
			curStage = 'philly';

			var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky'));
			bg.scrollFactor.set(0.1, 0.1);
			add(bg);

			var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city'));
			city.scrollFactor.set(0.3, 0.3);
			city.setGraphicSize(Std.int(city.width * 0.85));
			city.updateHitbox();
			add(city);

			phillyCityLights = new FlxTypedGroup<FlxSprite>();
			add(phillyCityLights);

			for (i in 0...5)
			{
				var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win' + i));
				light.scrollFactor.set(0.3, 0.3);
				light.visible = false;
				light.setGraphicSize(Std.int(light.width * 0.85));
				light.updateHitbox();
				light.antialiasing = true;
				phillyCityLights.add(light);
			}

			var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain'));
			add(streetBehind);

			phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train'));
			add(phillyTrain);

			trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
			FlxG.sound.list.add(trainSound);

			// var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

			var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street'));
			add(street);
		}
		else if (SONG.song.toLowerCase() == 'milf' || SONG.song.toLowerCase() == 'satin-panties' || SONG.song.toLowerCase() == 'high')
		{
			curStage = 'limo';
			defaultCamZoom = 0.90;

			var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('limo/limoSunset'));
			skyBG.scrollFactor.set(0.1, 0.1);
			add(skyBG);

			var bgLimo:FlxSprite = new FlxSprite(-200, 480);
			bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo');
			bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
			bgLimo.animation.play('drive');
			bgLimo.scrollFactor.set(0.4, 0.4);
			add(bgLimo);

			grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
			add(grpLimoDancers);

			for (i in 0...5)
			{
				var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
				dancer.scrollFactor.set(0.4, 0.4);
				grpLimoDancers.add(dancer);
			}

			var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('limo/limoOverlay'));
			overlayShit.alpha = 0.5;
			// add(overlayShit);

			// var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);

			// FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);

			// overlayShit.shader = shaderBullshit;

			var limoTex = Paths.getSparrowAtlas('limo/limoDrive');

			limo = new FlxSprite(-120, 550);
			limo.frames = limoTex;
			limo.animation.addByPrefix('drive', "Limo stage", 24);
			limo.animation.play('drive');
			limo.antialiasing = true;

			fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol'));
			// add(limo);
		}
		else if (SONG.song.toLowerCase() == 'cocoa' || SONG.song.toLowerCase() == 'eggnog')
		{
			curStage = 'mall';

			defaultCamZoom = 0.80;

			var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls'));
			bg.antialiasing = true;
			bg.scrollFactor.set(0.2, 0.2);
			bg.active = false;
			bg.setGraphicSize(Std.int(bg.width * 0.8));
			bg.updateHitbox();
			add(bg);

			upperBoppers = new FlxSprite(-240, -90);
			upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop');
			upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
			upperBoppers.antialiasing = true;
			upperBoppers.scrollFactor.set(0.33, 0.33);
			upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
			upperBoppers.updateHitbox();
			add(upperBoppers);

			var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('christmas/bgEscalator'));
			bgEscalator.antialiasing = true;
			bgEscalator.scrollFactor.set(0.3, 0.3);
			bgEscalator.active = false;
			bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
			bgEscalator.updateHitbox();
			add(bgEscalator);

			var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/christmasTree'));
			tree.antialiasing = true;
			tree.scrollFactor.set(0.40, 0.40);
			add(tree);

			bottomBoppers = new FlxSprite(-300, 140);
			bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop');
			bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
			bottomBoppers.antialiasing = true;
			bottomBoppers.scrollFactor.set(0.9, 0.9);
			bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
			bottomBoppers.updateHitbox();
			add(bottomBoppers);

			var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('christmas/fgSnow'));
			fgSnow.active = false;
			fgSnow.antialiasing = true;
			add(fgSnow);

			santa = new FlxSprite(-840, 150);
			santa.frames = Paths.getSparrowAtlas('christmas/santa');
			santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
			santa.antialiasing = true;
			add(santa);
		}
		else if (SONG.song.toLowerCase() == 'winter-horrorland')
		{
			curStage = 'mallEvil';
			var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG'));
			bg.antialiasing = true;
			bg.scrollFactor.set(0.2, 0.2);
			bg.active = false;
			bg.setGraphicSize(Std.int(bg.width * 0.8));
			bg.updateHitbox();
			add(bg);

			var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree'));
			evilTree.antialiasing = true;
			evilTree.scrollFactor.set(0.2, 0.2);
			add(evilTree);

			var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow"));
			evilSnow.antialiasing = true;
			add(evilSnow);
		}
		else if (SONG.song.toLowerCase() == 'senpai' || SONG.song.toLowerCase() == 'roses')
		{
			curStage = 'school';

			// defaultCamZoom = 0.9;

			var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky'));
			bgSky.scrollFactor.set(0.1, 0.1);
			add(bgSky);

			var repositionShit = -200;

			var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool'));
			bgSchool.scrollFactor.set(0.6, 0.90);
			add(bgSchool);

			var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet'));
			bgStreet.scrollFactor.set(0.95, 0.95);
			add(bgStreet);

			var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack'));
			fgTrees.scrollFactor.set(0.9, 0.9);
			add(fgTrees);

			var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
			var treetex = Paths.getPackerAtlas('weeb/weebTrees');
			bgTrees.frames = treetex;
			bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
			bgTrees.animation.play('treeLoop');
			bgTrees.scrollFactor.set(0.85, 0.85);
			add(bgTrees);

			var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
			treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals');
			treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
			treeLeaves.animation.play('leaves');
			treeLeaves.scrollFactor.set(0.85, 0.85);
			add(treeLeaves);

			var widShit = Std.int(bgSky.width * 6);

			bgSky.setGraphicSize(widShit);
			bgSchool.setGraphicSize(widShit);
			bgStreet.setGraphicSize(widShit);
			bgTrees.setGraphicSize(Std.int(widShit * 1.4));
			fgTrees.setGraphicSize(Std.int(widShit * 0.8));
			treeLeaves.setGraphicSize(widShit);

			fgTrees.updateHitbox();
			bgSky.updateHitbox();
			bgSchool.updateHitbox();
			bgStreet.updateHitbox();
			bgTrees.updateHitbox();
			treeLeaves.updateHitbox();

			bgGirls = new BackgroundGirls(-100, 190);
			bgGirls.scrollFactor.set(0.9, 0.9);

			if (SONG.song.toLowerCase() == 'roses')
			{
				bgGirls.getScared();
			}

			bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
			bgGirls.updateHitbox();
			add(bgGirls);
		}
		else if (SONG.song.toLowerCase() == 'thorns')
		{
			curStage = 'schoolEvil';

			var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
			var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);

			var posX = 400;
			var posY = 200;

			var bg:FlxSprite = new FlxSprite(posX, posY);
			bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool');
			bg.animation.addByPrefix('idle', 'background 2', 24);
			bg.animation.play('idle');
			bg.scrollFactor.set(0.8, 0.9);
			bg.scale.set(6, 6);
			add(bg);

			/* 
				var bg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolBG'));
				bg.scale.set(6, 6);
				// bg.setGraphicSize(Std.int(bg.width * 6));
				// bg.updateHitbox();
				add(bg);

				var fg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolFG'));
				fg.scale.set(6, 6);
				// fg.setGraphicSize(Std.int(fg.width * 6));
				// fg.updateHitbox();
				add(fg);

				wiggleShit.effectType = WiggleEffectType.DREAMY;
				wiggleShit.waveAmplitude = 0.01;
				wiggleShit.waveFrequency = 60;
				wiggleShit.waveSpeed = 0.8;
			 */

			// bg.shader = wiggleShit.shader;
			// fg.shader = wiggleShit.shader;

			/* 
				var waveSprite = new FlxEffectSprite(bg, [waveEffectBG]);
				var waveSpriteFG = new FlxEffectSprite(fg, [waveEffectFG]);

				// Using scale since setGraphicSize() doesnt work???
				waveSprite.scale.set(6, 6);
				waveSpriteFG.scale.set(6, 6);
				waveSprite.setPosition(posX, posY);
				waveSpriteFG.setPosition(posX, posY);

				waveSprite.scrollFactor.set(0.7, 0.8);
				waveSpriteFG.scrollFactor.set(0.9, 0.8);

				// waveSprite.setGraphicSize(Std.int(waveSprite.width * 6));
				// waveSprite.updateHitbox();
				// waveSpriteFG.setGraphicSize(Std.int(fg.width * 6));
				// waveSpriteFG.updateHitbox();

				add(waveSprite);
				add(waveSpriteFG);
			 */
		}
		else if (SONG.song.toLowerCase() == 'where-are-you' || SONG.song.toLowerCase() == 'kaio-ken' || SONG.song.toLowerCase() == 'eruption' || SONG.song.toLowerCase() == 'blast' || SONG.song.toLowerCase() == 'whats-new' || SONG.song.toLowerCase() == 'super-saiyan')
		{
			//dad.powerup = true;
			defaultCamZoom = 0.9;
			curStage = 'stage_2';
			var bg:FlxSprite = new FlxSprite(-400, -160).loadGraphic(Paths.image('bg_lemon'));
			bg.setGraphicSize(Std.int(bg.width * 1.5));
			bg.antialiasing = true;
			bg.scrollFactor.set(0.95, 0.95);
			bg.active = false;
			add(bg);

			if (SONG.song.toLowerCase() == 'kaio-ken')
			{
				var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2); //creo que esta weá no hace nada
			}
		}
		else if (SONG.song.toLowerCase() == 'god-eater')
		{
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
		}
		else
		{
			defaultCamZoom = 0.8;
			curStage = 'stage';
			var bg:FlxSprite = new FlxSprite(-900, -700).loadGraphic(Paths.image('stageback'));
			bg.antialiasing = true;
			bg.scrollFactor.set(0.9, 0.9);
			bg.active = false;
			add(bg);

			var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
			stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
			stageFront.updateHitbox();
			stageFront.antialiasing = true;
			stageFront.scrollFactor.set(0.9, 0.9);
			stageFront.active = false;
			add(stageFront);

			var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
			stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
			stageCurtains.updateHitbox();
			stageCurtains.antialiasing = true;
			stageCurtains.scrollFactor.set(1.3, 1.3);
			stageCurtains.active = false;

			add(stageCurtains);
		}

		var gfVersion:String = 'gf';

		switch (curStage)
		{
			case 'limo':
				gfVersion = 'gf-car';
			case 'mall' | 'mallEvil':
				gfVersion = 'gf-christmas';
			case 'school':
				gfVersion = 'gf-pixel';
			case 'schoolEvil':
				gfVersion = 'gf-pixel';
		}

		if (curStage == 'limo')
			gfVersion = 'gf-car';

		gf = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);

		dad = new Character(100, 100, SONG.player2);

		scoob = new Character(9000, 290, 'scooby', false);

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}

			case "spooky":
				dad.y += 200;
			case "monster":
				dad.y += 100;
			case 'monster-christmas':
				dad.y += 130;
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				dad.y += 300;
			case 'parents-christmas':
				dad.x -= 500;
			case 'senpai':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'senpai-angry':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'spirit':
				dad.x -= 150;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
		}


		
		boyfriend = new Boyfriend(770, 450, SONG.player1);

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;

				resetFastCar();
				add(fastCar);

			case 'mall':
				boyfriend.x += 200;

			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;
			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'schoolEvil':
				// trailArea.scrollFactor.set();

				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
				// evilTrail.changeValuesEnabled(false, false, false, false);
				// evilTrail.changeGraphic()
				add(evilTrail);
				// evilTrail.scrollFactor.set(1.1, 1.1);

				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'stage_2':
				//
			case 'sky':
				//
		}

		add(gf);

		if (SONG.player2 == 'pshaggy')
		{
			shaggyT = new FlxTrail(dad, null, 5, 7, 0.3, 0.001);
			add(shaggyT);

			doorFrame = new FlxSprite(-160, 160).loadGraphic(Paths.image('doorframe'));
			doorFrame.updateHitbox();
			doorFrame.setGraphicSize(1);
			doorFrame.alpha = 0;
			doorFrame.antialiasing = true;
			doorFrame.scrollFactor.set(1, 1);
			doorFrame.active = false;
			add(doorFrame);
		}

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);

		add(dad);
		add(boyfriend);

		add(scoob);

		foreground();

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;


		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();
		
		if (FlxG.save.data.downscroll)
			strumLine.y = FlxG.height - 165;

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();

		// startCountdown();

		generateSong(SONG.song);

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.01);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;


		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		if (FlxG.save.data.downscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		// healthBar
		add(healthBar);

		// Add Kade Engine watermark
		var kadeEngineWatermark = new FlxText(4,FlxG.height - 4,0,SONG.song + " " + (storyDifficulty == 2 ? "Hard" : storyDifficulty == 1 ? "Normal" : "Easy") + " - KE " + MainMenuState.kadeEngineVer, 16);
		kadeEngineWatermark.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		kadeEngineWatermark.scrollFactor.set();
		add(kadeEngineWatermark);

		scoreTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 150, healthBarBG.y + 50, 0, "", 20);
		if (!FlxG.save.data.accuracyDisplay)
			scoreTxt.x = healthBarBG.x + healthBarBG.width / 2;
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		add(scoreTxt);

		replayTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (FlxG.save.data.downscroll ? 100 : -100), 0, "REPLAY", 20);
		replayTxt.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		replayTxt.scrollFactor.set();
		if (loadRep)
			{
				add(replayTxt);
			}

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		doof.cameras = [camHUD];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		if (isStoryMode)
		{
			switch (curSong.toLowerCase())
			{
				case "tutorial":
					startCountdown();
					FlxG.camera.zoom = 1;
				case "where-are-you" | "whats-new":
					schoolIntro(1);
				case "super-saiyan":
					//FlxG.sound.music.onComplete = ssCutscene;
					schoolIntro(0);

					dad.powerup = true;
					dad.dance();

					camFollow = new FlxObject(0, 0, 1, 1);

					camFollow.setPosition(dad.getMidpoint().x - 100, dad.getMidpoint().y - 0);

					add(camFollow);
					FlxG.camera.follow(camFollow, LOCKON, 0.04);
					s_ending = true;
				case "god-eater":
					s_ending = true;
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
				default:
					schoolIntro(0);
			}
		}
		else
		{
			var cs = curSong.toLowerCase();
			if (cs == 'kaio-ken' || cs == 'super-saiyan' || cs == 'blast')
			{
				dad.powerup = true;

				camFollow = new FlxObject(0, 0, 1, 1);

				camFollow.setPosition(dad.getMidpoint().x - 100, dad.getMidpoint().y - 0);

				add(camFollow);
				FlxG.camera.follow(camFollow, LOCKON, 0.04);
			}

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
				default:
					startCountdown();
			}
		}

		if (!loadRep)
			rep = new Replay("na");

		super.create();
	}

	function foreground()
	{
		if (curStage == 'stage_2')
		{
			/*
			var cshd:FlxSprite = new FlxSprite(-330, 800).loadGraphic(Paths.image('bg_cshad'));
			cshd.setGraphicSize(Std.int(cshd.width * stress));
			cshd.updateHitbox();
			cshd.antialiasing = true;
			cshd.scrollFactor.set(1.1, 1.1);
			cshd.active = false;
			add(cshd);
			*/
		}
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

	function schoolIntro(btrans:Int):Void
	{
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
			fimage = dface[0];
			faceRender();
			tbox.alpha = 0;
			dcd = 7;

			if (btrans != 1)
			{
				dcd = 2;
				black.alpha = 0.15;
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
				new FlxTimer().start(0.03, function(tmr2:FlxTimer)
				{
					if (talk == 1)
					{
						var newtxt = dialogue[curr_dial].substr(0, curr_char);
						if (curr_char <= dialogue[curr_dial].length && tb_appear == 1)
						{
							if (dside[curr_dial] == 1)
							{
								FlxG.sound.play(Paths.sound('pixelText'));
							}
							else
							{
								FlxG.sound.play(Paths.sound('pixelBText'));
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
					tmr2.reset(0.03);
				});

				new FlxTimer().start(0.001, function(prs:FlxTimer)
				{
					var skip:Bool = false;
					if (dialogue[curr_dial] == "Why are you saying that" && curr_char >= 16)
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
									if (curSong.toLowerCase() != "kaio-ken" && curSong.toLowerCase() != "blast")
									{
										startCountdown();
									}
									else
									{
										cutTime = 0;
										superShaggy();
									}
								}
								talk = 0;
								dropText.alpha = 0;
								curr_dial = 0;
								tb_appear = 0;
							}
							else
							{
								if (dialogue[curr_dial] == sh_kill_line)
								{
									cs_mus.stop();
								}
								fimage = dface[curr_dial];
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
		fsprite = new FlxSprite(tb_x + Std.int(tbox.width / 2) + jx, tb_y - tb_fy, Paths.image(fimage));
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
					camFollow = new FlxObject(0, 0, 1, 1);

					camFollow.setPosition(dad.getMidpoint().x - 100, dad.getMidpoint().y - 0);

					add(camFollow);
					FlxG.camera.follow(camFollow, LOCKON, 0.04);
				case 15:
					dad.playAnim('power');
				case 48:
					dad.playAnim('idle_s');
					dad.powerup = true;
					burst = new FlxSprite(-1110, 0);
					FlxG.sound.play(Paths.sound('burst'));
					remove(burst);
					burst = new FlxSprite(dad.getMidpoint().x - 1000, dad.getMidpoint().y - 100);
					burst.frames = Paths.getSparrowAtlas('shaggy');
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
				case 130:
					startCountdown();
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
	var perfectMode:Bool = false;
	var noticeB:Array<FlxText> = [];
	var nShadowB:Array<FlxText> = [];

	function startCountdown():Void
	{
		inCutscene = false;

		hudArrows = [];
		generateStaticArrows(0);
		generateStaticArrows(1);
		FlxG.camera.angle = 0;

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;
		var c_div:Float = 1;

		if (SONG.song.toLowerCase() == "garden-havoc")
		{
			c_div = 0.75;
		}

		if (SONG.song.toLowerCase() == "kaio-ken" || SONG.song.toLowerCase() == "blast")
		{
			new FlxTimer().start(0.002, function(cbt:FlxTimer)
			{
				if (ctrTime == 0)
				{
					var cText = "S      D      F      J      K      L";

					if (FlxG.save.data.dfjk == 0)
					{
						cText = "A      S      D";
					}
					else if (FlxG.save.data.dfjk == 2)
					{
						cText = "Z      X      C      1      2      3";
					}
					notice = new FlxText(0, 0, 0, cText, 32);
					notice.x = FlxG.width * 0.572;
					notice.y = 120;
					if (FlxG.save.data.downscroll)
					{
						notice.y = FlxG.height - 200;
					}
					notice.scrollFactor.set();

					nShadow = new FlxText(0, 0, 0, cText, 32);
					nShadow.x = notice.x + 4;
					nShadow.y = notice.y + 4;
					nShadow.scrollFactor.set();

					nShadow.alpha = notice.alpha;
					nShadow.color = 0x00000000;

					notice.alpha = 0;

					add(nShadow);
					add(notice);
				}
				else
				{
					if (ctrTime < 300)
					{
						if (notice.alpha < 1)
						{
							notice.alpha += 0.02;
						}
					}
					else
					{
						notice.alpha -= 0.02;
					}
				}
				nShadow.alpha = notice.alpha;

				ctrTime ++;
				cbt.reset(0.004 / (FlxG.elapsed / (1/60)));
			});
		}

		if (SONG.song.toLowerCase() == "god-eater")
		{
			new FlxTimer().start(0.002, function(cbt:FlxTimer)
			{
				if (ctrTime == 0)
				{
					var cText:Array<String> = ['A', 'S', 'D', 'F', 'S\nP\nA\nC\nE', 'H', 'J', 'K', 'L'];

					if (FlxG.save.data.dfjk == 2)
					{
						cText = ['A', 'S', 'D', 'F', 'S\nP\nA\nC\nE', '1', '2', '3', 'R\nE\nT\nU\nR\nN'];
					}
					var nJx = 100;
					for (i in 0...9)
					{
						noticeB[i] = new FlxText(0, 0, 0, cText[i], 32);
						noticeB[i].x = FlxG.width * 0.5 + nJx*i + 55;
						noticeB[i].y = 20;
						if (FlxG.save.data.downscroll)
						{
							noticeB[i].y = FlxG.height - 120;
							switch (i)
							{
								case 4:
									noticeB[i].y -= 160;
								case 8:
									if (FlxG.save.data.dfjk == 2)
									noticeB[i].y -= 190;
							}
						}
						noticeB[i].scrollFactor.set();
						//notice[i].alpha = 0;

						nShadowB[i] = new FlxText(0, 0, 0, cText[i], 32);
						nShadowB[i].x = noticeB[i].x + 4;
						nShadowB[i].y = noticeB[i].y + 4;
						nShadowB[i].scrollFactor.set();

						nShadowB[i].alpha = noticeB[i].alpha;
						nShadowB[i].color = 0x00000000;

						//notice.alpha = 0;

						add(nShadowB[i]);
						add(noticeB[i]);
					}

					
				}
				else
				{
					for (i in 0...9)
					{
						if (ctrTime < 600)
						{
							if (noticeB[i].alpha < 1)
							{
								noticeB[i].alpha += 0.02;
							}
						}
						else
						{
							noticeB[i].alpha -= 0.02;
						}
					}
				}
				for (i in 0...9)
				{
					nShadowB[i].alpha = noticeB[i].alpha;
				}
				ctrTime ++;
				cbt.reset(0.004);
			});
		}

		startTimer = new FlxTimer().start(Conductor.crochet / (1000 / c_div), function(tmr:FlxTimer)
		{
			dad.dance();
			gf.dance();
			boyfriend.playAnim('idle');

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', [
				'weeb/pixelUI/ready-pixel',
				'weeb/pixelUI/set-pixel',
				'weeb/pixelUI/date-pixel'
			]);
			introAssets.set('schoolEvil', [
				'weeb/pixelUI/ready-pixel',
				'weeb/pixelUI/set-pixel',
				'weeb/pixelUI/date-pixel'
			]);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			switch (swagCounter)

			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3'), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2'), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1'), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (curStage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo'), 0.6);
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.onComplete = endSong;
		vocals.play();
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

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			//some 5note changes
			var mn:Int = keyAmmo[mania]; //new var to determine max notes
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % mn);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] >= mn)
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
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}
					else
					{
						sustainNote.strumTime -= FlxG.save.data.offset;
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else
				{
					swagNote.strumTime -= FlxG.save.data.offset;
				}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	var hudArrows:Array<FlxSprite>;
	var hudArrXPos:Array<Float>;
	var hudArrYPos:Array<Float>;
	private function generateStaticArrows(player:Int):Void
	{
		if (player == 1)
		{
			hudArrXPos = [];
			hudArrYPos = [];
		}
		for (i in 0...keyAmmo[mania])
		{
			// FlxG.log.add(i);

			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);
			hudArrows.push(babyArrow);

			switch (curStage)
			{
				case 'school' | 'schoolEvil':
					babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
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
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
					}

				default:
					babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * Note.noteScale));

					var nSuf:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
					var pPre:Array<String> = ['left', 'down', 'up', 'right'];
					switch (mania)
					{
						case 1:
							nSuf = ['LEFT', 'UP', 'RIGHT', 'LEFT', 'DOWN', 'RIGHT'];
							pPre = ['left', 'up', 'right', 'yel', 'down', 'dark'];
						case 2:
							nSuf = ['LEFT', 'DOWN', 'UP', 'RIGHT', 'SPACE', 'LEFT', 'DOWN', 'UP', 'RIGHT'];
							pPre = ['left', 'down', 'up', 'right', 'white', 'yel', 'violet', 'black', 'dark'];
							babyArrow.x -= Note.tooMuch;
					}
					babyArrow.x += Note.swagWidth * i;
					babyArrow.animation.addByPrefix('static', 'arrow' + nSuf[i]);
					babyArrow.animation.addByPrefix('pressed', pPre[i] + ' press', 24, false);
					babyArrow.animation.addByPrefix('confirm', pPre[i] + ' confirm', 24, false);
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (!isStoryMode || curSong.toLowerCase() == 'kaio-ken')
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);

			if (player == 1)
			{
				hudArrXPos.push(babyArrow.x);
				hudArrYPos.push(babyArrow.y);
				playerStrums.add(babyArrow);
			}

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
			paused = false;
		}

		super.closeSubState();
	}

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	function truncateFloat( number : Float, precision : Int): Float {
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round( num ) / Math.pow(10, precision);
		return num;
		}

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

	var sShake:Float = 0;

	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end

		pStep = curStep;

		if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'bf-old')
				iconP1.animation.play(SONG.player1);
			else
				iconP1.animation.play('bf-old');
		}

		switch (curStage)
		{
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
				// phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed;
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
					if (curBeat < 32)
					{
						sh_r = 60;
					}
					else if ((curBeat >= 132 * 4) || (curBeat >= 42 * 4 && curBeat <= 50 * 4))
					{
						sh_r += (60 - sh_r) / 32;
					}
					else
					{
						sh_r = 600;
					}

					if ((curBeat >= 32 && curBeat < 48) || (curBeat >= 116 * 4 && curBeat < 132 * 4))
					{
						if (boyfriend.animation.curAnim.name.startsWith('idle'))
						{
							boyfriend.playAnim('scared', true);
						}
					}

					if (curBeat < 50*4)
					{
					}
					else if (curBeat < 66 * 4)
					{
						rotRateSh *= 1.2;
					}
					else if (curBeat < 116 * 4)
					{
					}
					else if (curBeat < 132 * 4)
					{
						rotRateSh *= 1.2;
					}
					var bf_toy = -2000 + Math.sin(rotRate) * 20;

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
					}

					if (godMoveSh)
					{
						dad.x += (sh_tox - dad.x) / 12;
						dad.y += (sh_toy - dad.y) / 12;
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
		}

		super.update(elapsed);
		playerStrums.forEach(function(spr:FlxSprite)
		{
			spr.x = hudArrXPos[spr.ID];//spr.offset.set(spr.frameWidth / 2, spr.frameHeight / 2);
			spr.y = hudArrYPos[spr.ID];
			if (spr.animation.curAnim.name == 'confirm')
			{
				var jj:Array<Float> = [0, 3, 9];
				spr.x = hudArrXPos[spr.ID] + jj[mania];
				spr.y = hudArrYPos[spr.ID] + jj[mania];
			}
		});

		if (FlxG.save.data.accuracyDisplay)
		{
			scoreTxt.text = "Score:" + songScore + " | Misses:" + misses + " | Accuracy:" + truncateFloat(accuracy, 2) + "% " + (fc ? "| FC" : misses == 0 ? "| A" : accuracy <= 75 ? "| BAD" : "");
		}
		else
		{
			scoreTxt.text = "Score:" + songScore;
		}

		var pauseBtt:Bool = FlxG.keys.justPressed.ENTER;
		if (Main.woops)
		{
			pauseBtt = FlxG.keys.justPressed.ESCAPE;
		}
		if (pauseBtt && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
			{
				// gitaroo man easter egg
				FlxG.switchState(new GitarooPause());
			}
			else
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			Main.editor = true;
			FlxG.switchState(new ChartingState());
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));

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

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		#if debug
		if (FlxG.keys.justPressed.EIGHT)
			FlxG.switchState(new AnimationDebug(SONG.player2));
		#end

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else if (!songEnded)
		{
			// Conductor.songPosition = FlxG.sound.music.time;
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
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null && !songEnded)
		{
			if (curBeat % 4 == 0)
			{
				// trace(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			}

			if (camFollow.x != dad.getMidpoint().x + 150 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
				// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

				switch (dad.curCharacter)
				{
					case 'mom':
						camFollow.y = dad.getMidpoint().y;
					case 'senpai':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;
					case 'senpai-angry':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;
					case 'dad':
						camFollow.y = dad.getMidpoint().y - 100;
						camFollow.x = dad.getMidpoint().x - 100;
					case 'pshaggy':
						camFollow.y = dad.getMidpoint().y + 0;
						camFollow.x = dad.getMidpoint().x + 100;
				}

				if (dad.curCharacter == 'mom')
					vocals.volume = 1;

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					tweenCamIn();
				}
			}

			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
			{
				camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

				switch (curStage)
				{
					case 'limo':
						camFollow.x = boyfriend.getMidpoint().x - 300;
					case 'mall':
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'school':
						camFollow.x = boyfriend.getMidpoint().x - 200;
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'schoolEvil':
						camFollow.x = boyfriend.getMidpoint().x - 200;
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'stage_2':
						//camFollow.y = boyfriend.getMidpoint().y - 20;
				}

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
				}
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);
		if (loadRep) // rep debug
			{
				FlxG.watch.addQuick('rep rpesses',repPresses);
				FlxG.watch.addQuick('rep releases',repReleases);
				// FlxG.watch.addQuick('Queued',inputsQueued);
			}

		if (curSong == 'Fresh')
		{
			switch (curBeat)
			{
				case 16:
					camZooming = true;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
				case 163:
					// FlxG.sound.music.stop();
					// FlxG.switchState(new TitleState());
			}
		}
		//yyyy messi meteee un golazoooooooO!!!!!
		if (curSong.toLowerCase() == 'where-are-you')
		{
			switch (curBeat)
			{
				case 12:
					burst = new FlxSprite(-1110, 0);
				case 245:
					if (burst.y == 0)
					{
						FlxG.sound.play(Paths.sound('burst'));
						remove(burst);
						burst = new FlxSprite(dad.getMidpoint().x - 1000, dad.getMidpoint().y - 100);
						burst.frames = Paths.getSparrowAtlas('shaggy');
						burst.animation.addByPrefix('burst', "burst", 30);
						burst.animation.play('burst');
						//burst.setGraphicSize(Std.int(burst.width * 1.5));
						burst.antialiasing = true;
						add(burst);
					}

					/*
					var bgLimo:FlxSprite = new FlxSprite(-200, 480);
					bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo');
					bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
					bgLimo.animation.play('drive');
					bgLimo.scrollFactor.set(0.4, 0.4);
					add(bgLimo);
					*/
					// FlxG.sound.music.stop();
					// FlxG.switchState(new TitleState());
				case 246:
					remove(burst);
			}
		}
		if (curSong.toLowerCase() == 'kaio-ken')
		{
			if (curBeat == 48 || curBeat == 144 || curBeat == 56 * 4 || curBeat == 84 * 4 || curBeat == 104 * 4)
			{
				remove(shaggyT);
				shaggyT = new FlxTrail(dad, null, 4, 1, 0.3, 0.005);
				add(shaggyT);
				shaggyT.delay = Std.int(Math.round(1 / (FlxG.elapsed / (1/60))));
			}
			else if (curBeat == 80 || curBeat == 192 || curBeat == 60 * 4 || curBeat == 96 * 4 || curBeat == 108 * 4)
			{
				remove(shaggyT);
			}
		}

		if (false)//curSong == 'Bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
					// FlxG.sound.music.stop();
					// FlxG.switchState(new PlayState());
			}
		}

		if (health <= 0)
		{
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
			{
				notes.forEachAlive(function(daNote:Note)
				{	
					if (daNote.y > FlxG.height)
					{
						daNote.active = false;
						daNote.visible = false;
					}
					else
					{
						daNote.visible = true;
						daNote.active = true;
					}
	
					if (!daNote.mustPress && daNote.wasGoodHit)
					{
						if (SONG.song != 'Tutorial')
							camZooming = true;
	
						var altAnim:String = "";
	
						if (SONG.notes[Math.floor(curStep / 16)] != null)
						{
							if (SONG.notes[Math.floor(curStep / 16)].altAnim)
								altAnim = '-alt';
						}
						
						if (mania == 0)
						{
							switch (Math.abs(daNote.noteData))
							{
								case 2:
									dad.playAnim('singUP' + altAnim, true);
								case 3:
									dad.playAnim('singRIGHT' + altAnim, true);
								case 1:
									dad.playAnim('singDOWN' + altAnim, true);
								case 0:
									dad.playAnim('singLEFT' + altAnim, true);
							}
						}
						else if (mania == 1)
						{
							switch (Math.abs(daNote.noteData))
							{
								case 1:
									dad.playAnim('singUP' + altAnim, true);
								case 0:
									dad.playAnim('singLEFT' + altAnim, true);
								case 2:
									dad.playAnim('singRIGHT' + altAnim, true);
								case 3:
									dad.playAnim('singLEFT' + altAnim, true);
								case 4:
									dad.playAnim('singDOWN' + altAnim, true);
								case 5:
									dad.playAnim('singRIGHT' + altAnim, true);
							}
						}
						else
						{
							switch (Math.abs(daNote.noteData))
							{
								case 0:
									dad.playAnim('singLEFT' + altAnim, true);
								case 1:
									dad.playAnim('singDOWN' + altAnim, true);
								case 2:
									dad.playAnim('singUP' + altAnim, true);
								case 3:
									dad.playAnim('singRIGHT' + altAnim, true);
								case 4:
									dad.playAnim('singUP' + altAnim, true);
								case 5:
									dad.playAnim('singLEFT' + altAnim, true);
								case 6:
									dad.playAnim('singDOWN' + altAnim, true);
								case 7:
									dad.playAnim('singUP' + altAnim, true);
								case 8:
									dad.playAnim('singRIGHT' + altAnim, true);
							}
						}
	
						dad.holdTimer = 0;
	
						if (SONG.needsVoices)
							vocals.volume = 1;
	
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
	
					if (FlxG.save.data.downscroll)
						daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (-0.45 * FlxMath.roundDecimal(SONG.speed, 2)));
					else
						daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2)));
					//trace(daNote.y);
					// WIP interpolation shit? Need to fix the pause issue
					// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));
	
					if (daNote.y < -daNote.height && !FlxG.save.data.downscroll || daNote.y >= strumLine.y + 106 && FlxG.save.data.downscroll)
					{
						if (daNote.isSustainNote && daNote.wasGoodHit)
						{
							daNote.kill();
							notes.remove(daNote, true);
							daNote.destroy();
						}
						else
						{
							health -= 0.075;
							vocals.volume = 0;
							if (theFunne)
								noteMiss(daNote.noteData);
						}
	
						daNote.active = false;
						daNote.visible = false;
	
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});
			}


		if (!inCutscene)
			keyShit();

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end
	}

	function endSong():Void
	{
		songEnded = true;
		if (!loadRep)
			rep.SaveReplay();

		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		if (SONG.validScore)
		{
			#if !switch
			Highscore.saveScore(SONG.song, songScore, storyDifficulty);
			#end
		}

		if (isStoryMode)
		{
			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);

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

			if (!s_ending)
			{
				if (storyPlaylist.length <= 0)
				{
					if (!Main.menuBad)
					{
						FlxG.sound.playMusic(Paths.music('freakyMenu'));
					}
					else
					{
						FlxG.sound.playMusic(Paths.sound('menuBad'));
					}

					transIn = FlxTransitionableState.defaultTransIn;
					transOut = FlxTransitionableState.defaultTransOut;

					FlxG.switchState(new StoryMenuState());

					// if ()
					StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

					if (SONG.validScore)
					{
						NGio.unlockMedal(60961);
						Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
					}

					FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
					FlxG.save.flush();
				}
				else
				{
					var difficulty:String = "";

					if (storyDifficulty == 0)
						difficulty = '-easy';

					if (storyDifficulty == 2)
						difficulty = '-hard';

					trace('LOADING NEXT SONG');
					trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

					if (SONG.song.toLowerCase() == 'eggnog')
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

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					LoadingState.loadAndSwitchState(new PlayState());
				}
			}
			else
			{
				s_ending = false;
				switch (SONG.song.toLowerCase())
				{
					case ('super-saiyan'):
						if (FlxG.save.data.progress < 1)
						{
							FlxG.save.data.progress = 1;
							FlxG.save.flush();
						}
						ssCutscene();
					case ('god-eater'):
						Main.menuBad = false;
						if (FlxG.save.data.progress < 2)
						{
							FlxG.save.data.progress = 2;
							FlxG.save.flush();
						}
						finalCutscene();
				}
			}
		}
		else
		{
			trace('WENT BACK TO FREEPLAY??');
			FlxG.switchState(new FreeplayState());
		}
	}

	var endingSong:Bool = false;

	private function popUpScore(strumtime:Float):Void
		{
			var sjy = 0;
			if (curStage == "sky")
			{
				sjy = -2400;
			}
			var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
			// boyfriend.playAnim('hey');
			vocals.volume = 1;
	
			var placement:String = Std.string(combo);
	
			var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
			coolText.screenCenter();
			coolText.x = FlxG.width * 0.55;
			coolText.y += sjy;
	
			var rating:FlxSprite = new FlxSprite();
			var score:Int = 350;
	
			var daRating:String = "sick";
				
			if (noteDiff > Conductor.safeZoneOffset * 2)
				{
					daRating = 'shit';
					totalNotesHit -= 2;
					ss = false;
					if (theFunne)
						{
							score = -3000;
							combo = 0;
							misses++;
							health -= 0.2;
						}
					shits++;
				}
				else if (noteDiff < Conductor.safeZoneOffset * -2)
				{
					daRating = 'shit';
					totalNotesHit -= 2;
					if (theFunne)
					{
						score = -3000;
						combo = 0;
						misses++;
						health -= 0.2;
					}
					ss = false;
					shits++;
				}
				else if (noteDiff < Conductor.safeZoneOffset * -0.45)
				{
					daRating = 'bad';
					totalNotesHit += 0.2;
					if (theFunne)
					{
						score = -1000;
						health -= 0.03;
					}
					else
						score = 100;
					ss = false;
					bads++;
				}
				else if (noteDiff > Conductor.safeZoneOffset * 0.45)
				{
					daRating = 'bad';
					totalNotesHit += 0.2;
					if (theFunne)
						{
							score = -1000;
							health -= 0.03;
						}
						else
							score = 100;
					ss = false;
					bads++;
				}
				else if (noteDiff < Conductor.safeZoneOffset * -0.25)
				{
					daRating = 'good';
					totalNotesHit += 0.65;
					if (theFunne)
					{
						score = 200;
						//health -= 0.01;
					}
					else
						score = 200;
					ss = false;
					goods++;
				}
				else if (noteDiff > Conductor.safeZoneOffset * 0.25)
				{
					daRating = 'good';
					totalNotesHit += 0.65;
					if (theFunne)
						{
							score = 200;
							//health -= 0.01;
						}
						else
							score = 200;
					ss = false;
					goods++;
				}
			if (daRating == 'sick')
			{
				totalNotesHit += 1;
				if (health < 2)
					health += 0.1;
				sicks++;
			}
	
			if (daRating != 'shit' || daRating != 'bad')
				{
	
	
			songScore += score;
	
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
			rating.y += sjy;
			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			rating.velocity.x -= FlxG.random.int(0, 10);
	
			var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
			comboSpr.screenCenter();
			comboSpr.x = coolText.x;
			comboSpr.acceleration.y = 600;
			comboSpr.velocity.y -= 150;
			comboSpr.y += sjy;
	
			comboSpr.velocity.x += FlxG.random.int(1, 10);
			add(rating);
	
			if (!curStage.startsWith('school'))
			{
				rating.setGraphicSize(Std.int(rating.width * 0.7));
				rating.antialiasing = true;
				comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
				comboSpr.antialiasing = true;
			}
			else
			{
				rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
				comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
			}
	
			comboSpr.updateHitbox();
			rating.updateHitbox();
	
			var seperatedScore:Array<Int> = [];
	
			var comboSplit:Array<String> = (combo + "").split('');

			if (comboSplit.length == 2)
				seperatedScore.push(0); // make sure theres a 0 in front or it looks weird lol!

			for(i in 0...comboSplit.length)
			{
				var str:String = comboSplit[i];
				seperatedScore.push(Std.parseInt(str));
			}
	
			var daLoop:Int = 0;
			for (i in seperatedScore)
			{
				var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
				numScore.screenCenter();
				numScore.x = coolText.x + (43 * daLoop) - 90;
				numScore.y += 80;
	
				if (!curStage.startsWith('school'))
				{
					numScore.antialiasing = true;
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
		}
	public function NearlyEquals(value1:Float, value2:Float, unimportantDifference:Float = 10):Bool
		{
			return Math.abs(FlxMath.roundDecimal(value1, 1) - FlxMath.roundDecimal(value2, 1)) < unimportantDifference;
		}

		var upHold:Bool = false;
		var downHold:Bool = false;
		var rightHold:Bool = false;
		var leftHold:Bool = false;	

		var l1Hold:Bool = false;
		var uHold:Bool = false;
		var r1Hold:Bool = false;
		var l2Hold:Bool = false;
		var dHold:Bool = false;
		var r2Hold:Bool = false;

		var n0Hold:Bool = false;
		var n1Hold:Bool = false;
		var n2Hold:Bool = false;
		var n3Hold:Bool = false;
		var n4Hold:Bool = false;
		var n5Hold:Bool = false;
		var n6Hold:Bool = false;
		var n7Hold:Bool = false;
		var n8Hold:Bool = false;

		var reachBeat:Float;
	private function keyShit():Void
	{
		// HOLDING
		var up = controls.UP;
		var right = controls.RIGHT;
		var down = controls.DOWN;
		var left = controls.LEFT;

		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		var upR = controls.UP_R;
		var rightR = controls.RIGHT_R;
		var downR = controls.DOWN_R;
		var leftR = controls.LEFT_R;

		var l1 = controls.L1;
		var u = controls.U1;
		var r1 = controls.R1;
		var l2 = controls.L2;
		var d = controls.D1;
		var r2 = controls.R2;

		var l1P = controls.L1_P;
		var uP = controls.U1_P;
		var r1P = controls.R1_P;
		var l2P = controls.L2_P;
		var dP = controls.D1_P;
		var r2P = controls.R2_P;

		var l1R = controls.L1_R;
		var uR = controls.U1_R;
		var r1R = controls.R1_R;
		var l2R = controls.L2_R;
		var dR = controls.D1_R;
		var r2R = controls.R2_R;


		var n0 = controls.N0;
		var n1 = controls.N1;
		var n2 = controls.N2;
		var n3 = controls.N3;
		var n4 = controls.N4;
		var n5 = controls.N5;
		var n6 = controls.N6;
		var n7 = controls.N7;
		var n8 = controls.N8;

		var n0P = controls.N0_P;
		var n1P = controls.N1_P;
		var n2P = controls.N2_P;
		var n3P = controls.N3_P;
		var n4P = controls.N4_P;
		var n5P = controls.N5_P;
		var n6P = controls.N6_P;
		var n7P = controls.N7_P;
		var n8P = controls.N8_P;

		var n0R = controls.N0_R;
		var n1R = controls.N1_R;
		var n2R = controls.N2_R;
		var n3R = controls.N3_R;
		var n4R = controls.N4_R;
		var n5R = controls.N5_R;
		var n6R = controls.N6_R;
		var n7R = controls.N7_R;
		var n8R = controls.N8_R;

		var ex1 = false;

		if (loadRep) // replay code
		{
			// disable input
			up = false;
			down = false;
			right = false;
			left = false;

			// new input


			//if (rep.replay.keys[repPresses].time == Conductor.songPosition)
			//	trace('DO IT!!!!!');

			//timeCurrently = Math.abs(rep.replay.keyPresses[repPresses].time - Conductor.songPosition);
			//timeCurrentlyR = Math.abs(rep.replay.keyReleases[repReleases].time - Conductor.songPosition);

			
			if (repPresses < rep.replay.keyPresses.length && repReleases < rep.replay.keyReleases.length)
			{
				upP = NearlyEquals(rep.replay.keyPresses[repPresses].time, Conductor.songPosition) && rep.replay.keyPresses[repPresses].key == "up";
				rightP = NearlyEquals(rep.replay.keyPresses[repPresses].time, Conductor.songPosition) && rep.replay.keyPresses[repPresses].key == "right";
				downP = NearlyEquals(rep.replay.keyPresses[repPresses].time, Conductor.songPosition) && rep.replay.keyPresses[repPresses].key == "down";
				leftP = NearlyEquals(rep.replay.keyPresses[repPresses].time, Conductor.songPosition)  && rep.replay.keyPresses[repPresses].key == "left";	

				upR = NearlyEquals(rep.replay.keyReleases[repReleases].time, Conductor.songPosition) && rep.replay.keyReleases[repReleases].key == "up";
				rightR = NearlyEquals(rep.replay.keyReleases[repReleases].time, Conductor.songPosition) && rep.replay.keyReleases[repReleases].key == "right";
				downR = NearlyEquals(rep.replay.keyReleases[repReleases].time, Conductor.songPosition) && rep.replay.keyReleases[repReleases].key == "down";
				leftR = NearlyEquals(rep.replay.keyReleases[repReleases].time, Conductor.songPosition) && rep.replay.keyReleases[repReleases].key == "left";

				upHold = upP ? true : upR ? false : true;
				rightHold = rightP ? true : rightR ? false : true;
				downHold = downP ? true : downR ? false : true;
				leftHold = leftP ? true : leftR ? false : true;
			}
		}
		else if (!loadRep) // record replay code
		{
			if (upP)
				rep.replay.keyPresses.push({time: Conductor.songPosition, key: "up"});
			if (rightP)
				rep.replay.keyPresses.push({time: Conductor.songPosition, key: "right"});
			if (downP)
				rep.replay.keyPresses.push({time: Conductor.songPosition, key: "down"});
			if (leftP)
				rep.replay.keyPresses.push({time: Conductor.songPosition, key: "left"});

			if (upR)
				rep.replay.keyReleases.push({time: Conductor.songPosition, key: "up"});
			if (rightR)
				rep.replay.keyReleases.push({time: Conductor.songPosition, key: "right"});
			if (downR)
				rep.replay.keyReleases.push({time: Conductor.songPosition, key: "down"});
			if (leftR)
				rep.replay.keyReleases.push({time: Conductor.songPosition, key: "left"});
		}
		var controlArray:Array<Bool> = [leftP, downP, upP, rightP];

		// FlxG.watch.addQuick('asdfa', upP);
		var ankey = (upP || rightP || downP || leftP);
		if (mania == 1)
		{ 
			ankey = (l1P || uP || r1P || l2P || dP || r2P);
			controlArray = [l1P, uP, r1P, l2P, dP, r2P];
		}
		else if (mania == 2)
		{
			ankey = (n0P || n1P || n2P || n3P || n4P || n5P || n6P || n7P || n8P);
			controlArray = [n0P, n1P, n2P, n3P, n4P, n5P, n6P, n7P, n8P];
		}
		if (ankey && !boyfriend.stunned && generatedMusic)
			{
				repPresses++;
				boyfriend.holdTimer = 0;
	
				var possibleNotes:Array<Note> = [];
	
				var ignoreList:Array<Int> = [];
	
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate)
					{
						// the sorting probably doesn't need to be in here? who cares lol
						possibleNotes.push(daNote);
						possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
	
						ignoreList.push(daNote.noteData);
					}
				});
	
				
				if (possibleNotes.length > 0)
				{
					var daNote = possibleNotes[0];
	
					// Jump notes
					if (possibleNotes.length >= 2)
					{
						if (possibleNotes[0].strumTime == possibleNotes[1].strumTime)
						{
							for (coolNote in possibleNotes)
							{
								if (controlArray[coolNote.noteData])
									goodNoteHit(coolNote);
								else
								{
									var inIgnoreList:Bool = false;
									for (shit in 0...ignoreList.length)
									{
										if (controlArray[ignoreList[shit]])
											inIgnoreList = true;
									}
									if (!inIgnoreList && !theFunne && startedCountdown && !cs_reset && !grace)
										badNoteCheck();
								}
							}
						}
						else if (possibleNotes[0].noteData == possibleNotes[1].noteData)
						{
							if (loadRep)
							{
								if (NearlyEquals(daNote.strumTime,rep.replay.keyPresses[repPresses].time, 30))
								{
									goodNoteHit(daNote);
									trace('force note hit');
								}
								else
									noteCheck(controlArray, daNote);
							}
							else
								noteCheck(controlArray, daNote);
						}
						else
						{
							for (coolNote in possibleNotes)
							{
								if (loadRep)
									{
										if (NearlyEquals(coolNote.strumTime,rep.replay.keyPresses[repPresses].time, 30))
										{
											goodNoteHit(coolNote);
											trace('force note hit');
										}
										else
											noteCheck(controlArray, daNote);
									}
								else
									noteCheck(controlArray, coolNote);
							}
						}
					}
					else // regular notes?
					{	
						if (loadRep)
						{
							if (NearlyEquals(daNote.strumTime,rep.replay.keyPresses[repPresses].time, 30))
							{
								goodNoteHit(daNote);
								trace('force note hit');
							}
							else
								noteCheck(controlArray, daNote);
						}
						else
							noteCheck(controlArray, daNote);
					}
					/* 
						if (controlArray[daNote.noteData])
							goodNoteHit(daNote);
					 */
					// trace(daNote.noteData);
					/* 
						switch (daNote.noteData)
						{
							case 2: // NOTES YOU JUST PRESSED
								if (upP || rightP || downP || leftP)
									noteCheck(upP, daNote);
							case 3:
								if (upP || rightP || downP || leftP)
									noteCheck(rightP, daNote);
							case 1:
								if (upP || rightP || downP || leftP)
									noteCheck(downP, daNote);
							case 0:
								if (upP || rightP || downP || leftP)
									noteCheck(leftP, daNote);
						}
					 */
					if (daNote.wasGoodHit)
					{
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				}
				else if (!theFunne && startedCountdown && !cs_reset && !grace)
				{
					badNoteCheck();
				}
			}
			
			var condition = ((up || right || down || left) && generatedMusic || (upHold || downHold || leftHold || rightHold) && loadRep && generatedMusic);
			if (mania == 1)
			{
				condition = ((l1 || u || r1 || l2 || d || r2) && generatedMusic || (l1Hold || uHold || r1Hold || l2Hold || dHold || r2Hold) && loadRep && generatedMusic);
			}
			else if (mania == 2)
			{
				condition = ((n0 || n1 || n2 || n3 || n4 || n5 || n6 || n7 || n8) && generatedMusic || (n0Hold || n1Hold || n2Hold || n3Hold || n4Hold || n5Hold || n6Hold || n7Hold || n8Hold) && loadRep && generatedMusic);
			}
			if (condition)
			{
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && daNote.isSustainNote)
					{
						if (mania == 0)
						{
							switch (daNote.noteData)
							{
								// NOTES YOU ARE HOLDING
								case 2:
									if (up || upHold)
										goodNoteHit(daNote);
								case 3:
									if (right || rightHold)
										goodNoteHit(daNote);
								case 1:
									if (down || downHold)
										goodNoteHit(daNote);
								case 0:
									if (left || leftHold)
										goodNoteHit(daNote);
							}
						}
						else if (mania == 1)
						{
							switch (daNote.noteData)
							{
								// NOTES YOU ARE HOLDING
								case 0:
									if (l1 || l1Hold)
										goodNoteHit(daNote);
								case 1:
									if (u || uHold)
										goodNoteHit(daNote);
								case 2:
									if (r1 || r1Hold)
										goodNoteHit(daNote);
								case 3:
									if (l2 || l2Hold)
										goodNoteHit(daNote);
								case 4:
									if (d || dHold)
										goodNoteHit(daNote);
								case 5:
									if (r2 || r2Hold)
										goodNoteHit(daNote);
							}
						}
						else
						{
							switch (daNote.noteData)
							{
								// NOTES YOU ARE HOLDING
								case 0: if (n0 || n0Hold) goodNoteHit(daNote);
								case 1: if (n1 || n1Hold) goodNoteHit(daNote);
								case 2: if (n2 || n2Hold) goodNoteHit(daNote);
								case 3: if (n3 || n3Hold) goodNoteHit(daNote);
								case 4: if (n4 || n4Hold) goodNoteHit(daNote);
								case 5: if (n5 || n5Hold) goodNoteHit(daNote);
								case 6: if (n6 || n6Hold) goodNoteHit(daNote);
								case 7: if (n7 || n7Hold) goodNoteHit(daNote);
								case 8: if (n8 || n8Hold) goodNoteHit(daNote);
							}
						}
					}
				});
			}
	
			if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !up && !down && !right && !left)
			{
				if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
				{
					boyfriend.playAnim('idle');
				}
			}
	
			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (mania == 0)
				{
					switch (spr.ID)
					{
						case 2:
							if (upP && spr.animation.curAnim.name != 'confirm')
							{
								spr.animation.play('pressed');
								trace('play');
							}
							if (upR)
							{
								spr.animation.play('static');
								repReleases++;
							}
						case 3:
							if (rightP && spr.animation.curAnim.name != 'confirm')
								spr.animation.play('pressed');
							if (rightR)
							{
								spr.animation.play('static');
								repReleases++;
							}
						case 1:
							if (downP && spr.animation.curAnim.name != 'confirm')
								spr.animation.play('pressed');
							if (downR)
							{
								spr.animation.play('static');
								repReleases++;
							}
						case 0:
							if (leftP && spr.animation.curAnim.name != 'confirm')
								spr.animation.play('pressed');
							if (leftR)
							{
								spr.animation.play('static');
								repReleases++;
							}
					}
				}
				else if (mania == 1)
				{
					switch (spr.ID)
					{
						case 0:
							if (l1P && spr.animation.curAnim.name != 'confirm')
							{
								spr.animation.play('pressed');
								trace('play');
							}
							if (l1R)
							{
								spr.animation.play('static');
								repReleases++;
							}
						case 1:
							if (uP && spr.animation.curAnim.name != 'confirm')
								spr.animation.play('pressed');
							if (uR)
							{
								spr.animation.play('static');
								repReleases++;
							}
						case 2:
							if (r1P && spr.animation.curAnim.name != 'confirm')
								spr.animation.play('pressed');
							if (r1R)
							{
								spr.animation.play('static');
								repReleases++;
							}
						case 3:
							if (l2P && spr.animation.curAnim.name != 'confirm')
								spr.animation.play('pressed');
							if (l2R)
							{
								spr.animation.play('static');
								repReleases++;
							}
						case 4:
							if (dP && spr.animation.curAnim.name != 'confirm')
								spr.animation.play('pressed');
							if (dR)
							{
								spr.animation.play('static');
								repReleases++;
							}
						case 5:
							if (r2P && spr.animation.curAnim.name != 'confirm')
								spr.animation.play('pressed');
							if (r2R)
							{
								spr.animation.play('static');
								repReleases++;
							}
					}
				}
				else if (mania == 2)
				{
					switch (spr.ID)
					{
						case 0:
							if (n0P && spr.animation.curAnim.name != 'confirm') spr.animation.play('pressed');
							if (n0R) spr.animation.play('static');
						case 1:
							if (n1P && spr.animation.curAnim.name != 'confirm') spr.animation.play('pressed');
							if (n1R) spr.animation.play('static');
						case 2:
							if (n2P && spr.animation.curAnim.name != 'confirm') spr.animation.play('pressed');
							if (n2R) spr.animation.play('static');
						case 3:
							if (n3P && spr.animation.curAnim.name != 'confirm') spr.animation.play('pressed');
							if (n3R) spr.animation.play('static');
						case 4:
							if (n4P && spr.animation.curAnim.name != 'confirm') spr.animation.play('pressed');
							if (n4R) spr.animation.play('static');
						case 5:
							if (n5P && spr.animation.curAnim.name != 'confirm') spr.animation.play('pressed');
							if (n5R) spr.animation.play('static');
						case 6:
							if (n6P && spr.animation.curAnim.name != 'confirm') spr.animation.play('pressed');
							if (n6R) spr.animation.play('static');
						case 7:
							if (n7P && spr.animation.curAnim.name != 'confirm') spr.animation.play('pressed');
							if (n7R) spr.animation.play('static');
						case 8:
							if (n8P && spr.animation.curAnim.name != 'confirm') spr.animation.play('pressed');
							if (n8R) spr.animation.play('static');
					}
				}
				
				if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
				{
					spr.centerOffsets();
					spr.offset.x -= 13;
					spr.offset.y -= 13;
				}
				else
					spr.centerOffsets();
			});
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
			misses++;

			songScore -= 10;

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			switch (direction)
			{
				case 0:
					boyfriend.playAnim('singLEFTmiss', true);
				case 1:
					boyfriend.playAnim('singDOWNmiss', true);
				case 2:
					boyfriend.playAnim('singUPmiss', true);
				case 3:
					boyfriend.playAnim('singRIGHTmiss', true);
				case 4:
					boyfriend.playAnim('singDOWNmiss', true);
				case 5:
					boyfriend.playAnim('singRIGHTmiss', true);
				case 6:
					boyfriend.playAnim('singDOWNmiss', true);
				case 7:
					boyfriend.playAnim('singUPmiss', true);
				case 8:
					boyfriend.playAnim('singRIGHTmiss', true);
			}

			updateAccuracy();
		}
	}

	function badNoteCheck()
		{
			// just double pasting this shit cuz fuk u
			// REDO THIS SYSTEM!
			var upP = controls.UP_P;
			var rightP = controls.RIGHT_P;
			var downP = controls.DOWN_P;
			var leftP = controls.LEFT_P;

			var l1P = controls.L1_P;
			var uP = controls.U1_P;
			var r1P = controls.R1_P;
			var l2P = controls.L2_P;
			var dP = controls.D1_P;
			var r2P = controls.R2_P;

			var n0P = controls.N0_P;
			var n1P = controls.N1_P;
			var n2P = controls.N2_P;
			var n3P = controls.N3_P;
			var n4P = controls.N4_P;
			var n5P = controls.N5_P;
			var n6P = controls.N6_P;
			var n7P = controls.N7_P;
			var n8P = controls.N8_P;
			
			if (mania == 0)
			{
				if (leftP)
					noteMiss(0);
				if (upP)
					noteMiss(2);
				if (rightP)
					noteMiss(3);
				if (downP)
					noteMiss(1);
			}
			else if (mania == 1)
			{
				if (l1P)
					noteMiss(0);
				else if (uP)
					noteMiss(1);
				else if (r1P)
					noteMiss(2);
				else if (l2P)
					noteMiss(3);
				else if (dP)
					noteMiss(4);
				else if (r2P)
					noteMiss(5);
			}
			else
			{
				if (n0P) noteMiss(0);
				if (n1P) noteMiss(1);
				if (n2P) noteMiss(2);
				if (n3P) noteMiss(3);
				if (n4P) noteMiss(4);
				if (n5P) noteMiss(5);
				if (n6P) noteMiss(6);
				if (n7P) noteMiss(7);
				if (n8P) noteMiss(8);
			}
			updateAccuracy();
		}

	function updateAccuracy()
		{
			if (misses > 0 || accuracy < 96)
				fc = false;
			else
				fc = true;
			totalPlayed += 1;
			accuracy = totalNotesHit / totalPlayed * 100;
		}


	function getKeyPresses(note:Note):Int
	{
		var possibleNotes:Array<Note> = []; // copypasted but you already know that

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate)
			{
				possibleNotes.push(daNote);
				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
			}
		});
		return possibleNotes.length;
	}
	
	var mashing:Int = 0;
	var grace:Bool = false;

	function noteCheck(controlArray:Array<Bool>, note:Note):Void // sorry lol
		{
			if (loadRep)
			{
				if (controlArray[note.noteData])
					goodNoteHit(note);
				else if (!theFunne && startedCountdown && !cs_reset) 
					badNoteCheck();
				else if (rep.replay.keyPresses.length > repPresses && !controlArray[note.noteData])
				{
					if (NearlyEquals(note.strumTime,rep.replay.keyPresses[repPresses].time, 4))
					{
						goodNoteHit(note);
					}
					else if (!theFunne && startedCountdown && !cs_reset) 
						badNoteCheck();
				}
			}
			else if (controlArray[note.noteData])
				{
					for (b in controlArray) {
						if (b)
							mashing++;
					}

					if ((mashing <= getKeyPresses(note)) || !theFunne || !FlxG.save.data.mash_punish)
						goodNoteHit(note);
					else
					{
						playerStrums.members[note.noteData].animation.play('static');
						trace('mash ' + mashing);
					}
				}
			else if (!theFunne && startedCountdown && !cs_reset && !grace)
			{
				badNoteCheck();
			}
		}

		function goodNoteHit(note:Note):Void
			{
				if (mashing != 0)
					mashing = 0;
				if (!note.wasGoodHit)
				{
					if (!note.isSustainNote)
					{
						popUpScore(note.strumTime);
						combo += 1;
					}
					else
						totalNotesHit += 1;
	
					var sDir:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
					if (mania == 1)
					{
						sDir = ['LEFT', 'UP', 'RIGHT', 'LEFT', 'DOWN', 'RIGHT'];
					}
					else if (mania == 2)
					{
						sDir = ['LEFT', 'DOWN', 'UP', 'RIGHT', 'UP', 'LEFT', 'DOWN', 'UP', 'RIGHT'];
					}

					boyfriend.playAnim('sing' + sDir[note.noteData], true);
		
					playerStrums.forEach(function(spr:FlxSprite)
					{
						if (Math.abs(note.noteData) == spr.ID)
						{
							spr.animation.play('confirm', true);
						}
						//spr.updateHitbox();
					});
		
					note.wasGoodHit = true;
					vocals.volume = 1;
		
					note.kill();
					notes.remove(note, true);
					note.destroy();
					
					updateAccuracy();

					grace = true;
					new FlxTimer().start(0.15, function(tmr:FlxTimer)
					{
						grace = false;
					});
				}
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
		gf.playAnim('hairFall');
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
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		if (dad.curCharacter == 'spooky' && curStep % 4 == 2)
		{
			// dad.dance();
		}
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			// else
			// Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			if (SONG.notes[Math.floor(curStep / 16)].mustHitSection && SONG.song.toLowerCase() != "garden-havoc")
				dad.dance();
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

		// HARDCODING FOR MILF ZOOMS!
		if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0 && SONG.song.toLowerCase() != "garden-havoc")
		{
			gf.dance();
		}

		if (!boyfriend.animation.curAnim.name.startsWith("sing") && !boyfriend.animation.curAnim.name.startsWith("scared"))
		{
			boyfriend.playAnim('idle');
		}

		if (curBeat % 8 == 7 && curSong == 'Bopeebo')
		{
			boyfriend.playAnim('hey', true);

			if (SONG.song == 'Tutorial' && dad.curCharacter == 'gf')
			{
				dad.playAnim('cheer', true);
			}
		}

		switch (curStage)
		{
			case 'school':
				bgGirls.dance();

			case 'mall':
				upperBoppers.animation.play('bop', true);
				bottomBoppers.animation.play('bop', true);
				santa.animation.play('idle', true);

			case 'limo':
				grpLimoDancers.forEach(function(dancer:BackgroundDancer)
				{
					dancer.dance();
				});

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					phillyCityLights.forEach(function(light:FlxSprite)
					{
						light.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1);

					phillyCityLights.members[curLight].visible = true;
					// phillyCityLights.members[curLight].alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
	}

	var curLight:Int = 0;
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
	var nex:Float = 1;

	public function ssCutscene()
	{
		cs_cam = new FlxObject(0, 0, 1, 1);
		cs_cam.x = 605;
		cs_cam.y = 410;
		add(cs_cam);
		remove(camFollow);
		camFollow.destroy();
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

					dad.powerup = false;
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

	var toDfS:Float = 1;
	public function finalCutscene()
	{
		cs_zoom = defaultCamZoom;
		cs_cam = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
		cs_cam.x = camFollow.x;
		cs_cam.y = camFollow.y;
		add(cs_cam);
		remove(camFollow);
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
						csDial('sh_amazing');
						schoolIntro(0);
						cs_wait = true;
						cs_reset = true;
					}
				case 700:
					godCutEnd = false;
					FlxG.sound.play(Paths.sound('burst'));
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
						csDial('sh_expo');
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
			title = new FlxSprite(FlxG.width / 2 - 400, FlxG.height / 2 - 400).loadGraphic(Paths.image('sh_title'));
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
					endtxt = new Alphabet(6, FlxG.height / 2 + 380, "THE END", true, false);
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
	public function burstRelease(bX:Float, bY:Float)
	{
		FlxG.sound.play(Paths.sound('burst'));
		remove(burst);
		burst = new FlxSprite(bX - 1000, bY - 100);
		burst.frames = Paths.getSparrowAtlas('shaggy');
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
	var sh_kill_line:String = "Oh and next time you cut scooby in half I'm\nnot gonna pretend like singing is\nmy only option again.";
	public function csDial(csIndex:String)
	{
		switch (csIndex)
		{
			case 'found_scooby':
				dialogue = [
					"Scooby!! where were you?!",
					"I don't know shraggy, this mansion\nis really big!",
					"I think I even sawr a monster, tho\nI don't remember wh..."
				];
				dface = [
						"f_sh_happy",
						"f_scb", "n"
						];
				dside = [1, -1, -1];
			case 'scooby_hold_talk':
				dialogue = [
					"Like, what's wrong scoob?",
					"The monster shraggy...",
					"She's mean!",
					"She scares me...",
					"What are you talking about?\nThis lady?",
					"She's like, totally cool man!",
					"Why are you saying that"
				];
				dface = [
						"f_sh_ser",
						"f_scb_scared", "n", "n",
						"f_sh_con", "f_sh_smug", "f_sh"
						];
				dside = [1, 1, 1, 1, 1, 1, 1];
			case 'gf_sass':
				dialogue = [
					"BEP?!",
					"Will that get you to sing for real\nthis time?"
				];
				dface = [
						"f_bf_scared",
						"f_gf"
						];
				dside = [-1, -1];
			case 'sh_amazing':
				dialogue = [
					"...",
					"Amazing!"
				];
				dface = [
						"f_sh_smug",
						"f_sh_smug"
						];
				dside = [1, 1];
			case 'sh_expo':
				dialogue = [
					"I scared you didn't I?",
					"bee",
					"I don't even need a finger snap to like,\nbring every dead being in this planet\nback to life",
					"Wouldn't have killed your dog if\nI didn't know that",
					"...",
					"Anyways, to tell you the truth Scooby\nwas looking for you.",
					"We came to your universe because we\nheard a teenager was like, immortal",
					"And you beat me first try!",
					"From my perspective at least...",
					"I'm guessing you have some time resetting\nability so I'm glad I didn't go\nfull power against you.",
					"baap be?",
					"0.002%",
					"a",
					"Welp, we gotta go and stuff."
				];
				dface = [
						"f_sh_smug",
						"f_bf_a",
						"f_sh",
						"f_gf",
						"f_sh_ser", "f_sh", "n", "f_sh_smug", "f_sh_con", "n",
						"f_bf",
						"f_sh",
						"f_bf_a",
						"f_sh"
						];
				dside = [1, -1, 1, -1, 1, 1, 1, 1, 1, 1, -1, 1, -1, 1];
			case "sh_bye":
				dialogue = [
					"I heard they're gathering up some powerful\nindividuals for a tournament in\na universe close by...",
					"And if saitama's gonna be there, I can't\nmiss it.",
					"So like, goodbye! For now at least.",
					sh_kill_line
				];
				dface = [
						"f_sh",
						"f_sh_smug",
						"f_sh",
						"f_sh_kill"
				];
				dside = [1, 1, 1, 1];
			case "troleo":
				dialogue = [
					"Chupenme la corneta giles culiaooos!!!!",
					"You speak everything but english huh"
				];
				dface = [
						"f_bf_burn",
						"f_gf"
				];
				dside = [-1, -1];
		}
	}
}
