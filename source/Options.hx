package;

class Options
{
	if (FlxG.save.data.volume == null)
	{
		FlxG.save.data.volume = 0.5;
	}
	public static var masterVolume:Float = FlxG.save.data.volume;
}
