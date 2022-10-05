package;

/**
 * ...
 * @author Overcharged Dev
 */
class NoteHit {
    public static function getHitData(noteDiff:Float,type:HitDataType):Dynamic{
        var customTimeScale = (Conductor.safeZoneOffset / 166) * 10 / 166 * 10;

        var rating:String = ""; 
        var score:Int = 0;
        var health:Int = 0;

        var noteHitData:Array<Dynamic> = [['shit',50,-100],['bad',100,-45],['good',200,0],['sick',350,5],['good',200,0],['bad',100,-45],['shit',50,-100]];
        var timingWindows:Array<Dynamic> = [[166,135], [135,90], [90,45], [45,-45], [-90,-45], [-135,-90], [-166,-135]];

        for(i in 0... timingWindows.length){
            if(noteDiff <= timingWindows[i][0] * customTimeScale && noteDiff >= timingWindows[i][1] * customTimeScale){
                rating = noteHitData[i][0];
                score = noteHitData[i][1];
                health = noteHitData[i][2];
                break;
            }
        }
        switch(type){
            case HitDataType.RATING:
                return rating;
            case HitDataType.SCORE:
                return score;
            case HitDataType.HEALTH:
                return health/250;
        }

        return "DEFAULT_VALUE";
    }
}

@:enum abstract HitDataType(String){
    var RATING = "RATING";
    var SCORE = "SCORE";
    var HEALTH = "HEALTH";
}
