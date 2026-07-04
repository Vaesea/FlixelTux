package;

// Softcoded Level support by AnatolyStev
// Carrying over Tux's state support by AnatolyStev
// Saving and Loading support by AnatolyStev
// Original Global.hx by Discover HaxeFlixel, edited by Vaesea

// import characters.player.Tux.TuxStates;
import lime.utils.Assets;
import states.PlayState;

class Global
{
    // Player stuff
    public static var coins = 0;

    // PlayState
    public static var PS:PlayState;
    
    // Non-hardcoded levels thing
    public static var levels:Array<String> = [];

    // Level stuff
    public static var currentLevel:Int = 0;
    public static var levelName:String;

    // Checkpoint stuff
    public static var checkpointReached = false;

    // Current song that's playing (Could be turned into a bool?)
    public static var currentSong:String;

    // Load levels.txt file
    public static function loadLevels()
    {
        levels = Assets.getText("assets/data/levels.txt").split("\n").map(StringTools.trim).filter(function(l) return l != "");
    }
}