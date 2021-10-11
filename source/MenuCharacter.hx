package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class MenuCharacter extends FlxSprite
{
	public var character:String;
	var ang = 0;
	var sY = 60;

	public function new(x:Float, character:String = 'bf')
	{
		super(x);

		changeCharacter(character);
	}
	override function update(elapsed:Float)
	{
		ang ++;
		switch (character)
		{
			case 'wbshaggy':
				y = sY + Math.sin(ang / 50) * 15;
			default:
				y = sY;
		}
		super.update(elapsed);
	}

	public function changeCharacter(?character:String = 'bf') {
		alpha = 1;
		if (character == '') alpha = 0;
		
		if(character == this.character) return;
	
		this.character = character;
		antialiasing = ClientPrefs.globalAntialiasing;

		switch(character) {
			case 'bf':
				frames = Paths.getSparrowAtlas('menucharacters/Menu_BF');
				animation.addByPrefix('idle', "M BF Idle", 24);
				animation.addByPrefix('confirm', 'M bf HEY', 24, false);

			case 'gf':
				frames = Paths.getSparrowAtlas('menucharacters/Menu_GF');
				animation.addByPrefix('idle', "M GF Idle", 24);

			case 'shaggy':
				frames = Paths.getSparrowAtlas('menucharacters/Menu_Shaggy');
				animation.addByPrefix('idle', "M Shaggy Idle", 24);

			case 'pshaggy':
				frames = Paths.getSparrowAtlas('menucharacters/Menu_PShaggy');
				animation.addByPrefix('idle', "M PShaggy Idle", 24);

			case 'rshaggy':
				frames = Paths.getSparrowAtlas('menucharacters/Menu_RShaggy');
				animation.addByPrefix('idle', "M RShaggy Idle", 24);

			case 'wbshaggy':
				frames = Paths.getSparrowAtlas('menucharacters/Menu_WBShaggy');
				animation.addByPrefix('idle', "M WBShaggy Idle", 24);

			case 'shaggymatt':
				frames = Paths.getSparrowAtlas('menucharacters/Menu_ShaggyMatt');
				animation.addByPrefix('idle', "M ShaggyMatt Idle", 24);

			case 'senpai':
				frames = Paths.getSparrowAtlas('menucharacters/Menu_Senpai');
				animation.addByPrefix('idle', "M Senpai Idle", 24);
		}
		animation.play('idle');
		updateHitbox();

		switch(character) {
			case 'bf':
				offset.set(15, -40);

			case 'gf':
				offset.set(0, -25);

			case 'spooky':
				offset.set(0, -80);

			case 'pico':
				offset.set(0, -120);

			case 'mom':
				offset.set(0, 10);

			case 'parents':
				offset.set(110, 10);

			case 'senpai':
				offset.set(60, -70);
			case 'pshaggy':
				offset.set(-10, 20);
			case 'shaggymatt':
				offset.set(50, 10);
			default:
				offset.set(0, 10);
		}
	}
}
