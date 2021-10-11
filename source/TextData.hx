package;
import StringTools;
import flixel.FlxG;

class TextData {
	
	public static var defaultText:Array<Dynamic> = [
		[
			'sample text 1',
			'sample text 2',
			'sample text 3'
		],
		[
			'sh',
			'bf',
			'sh'
		],
		[
			'normal',
			'scared',
			'ang'
		],
		[1, -1, 1]
	];

	public static function getLanNumber():Int
	{
		return(CoolUtil.coolTextFile(Paths.txt('languages')).length);
	}
	public static function getLanAtt():Array<String>
	{
		var lanList = CoolUtil.coolTextFile(Paths.txt('languages'));
		var lanAtt = lanList[FlxG.save.data.language].split(":");
		trace(lanAtt);
		return(lanAtt);
	}
	//espanio
	public static function getLanPrefix():String
	{
		var prefix = 'z';
		prefix = getLanAtt()[1];
		return(prefix);
	}
	//xd
	public static function getText(dataIndex:String):Array<Dynamic>
	{
		var data:Array<Dynamic> = [[], [], [], []];

		var txtList = CoolUtil.coolTextFile(Paths.txt(getLanPrefix() + '_textbox/' + dataIndex));
		for (i in 0...txtList.length)
		{
			var seps:Array<String> = txtList[i].split(":");
			data[0].push(StringTools.replace(seps[3], '#', '\n'));
			data[1].push(seps[0]);
			data[2].push(seps[1]);
			data[3].push(Std.parseInt(seps[2]));
		}

		if (data == [])
		{
			data = defaultText;
		}
		return data;
	}

	public static function vcSound(char:String, emote:String)
	{
		var snd = 'defA';
		switch (char)
		{
			case 'bf' | 'gf' | 'scooby' | 'zp':
				snd = 'defB';
			/*
			case ('bf'):
				switch (emote)
				{
					case 'burn' | 'scared':
						snd = 'bf_a';
					case 'a':
						snd = 'bf_o';
					default:
						snd = 'bf_bee';
				}
			case ('sh' | 'rsh'):
				switch (emote)
				{
					case 'kill':
						snd = 'sh_eh';
					case 'smug' | 'pens':
						snd = 'sh_ee';
					case 'happy':
						snd = 'sh_oh';
					case 'ang' | 'sad' | 'ser':
						snd = 'sh_low_do';
					default:
						snd = 'sh_do';
				}
				*/
		}
		return Paths.sound('voice/' + snd);
	}
}