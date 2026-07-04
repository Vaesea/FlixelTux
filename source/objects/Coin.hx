package objects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class Coin extends FlxSprite
{
    var targetY:Int = 64;

    public function new(x:Float, y:Float)
    {
        super(x, y);

        loadGraphic("assets/images/objects/coin.png", true, 16, 16);
        animation.add("normal", [0, 1, 2, 3], 8.0, true);
        animation.play("normal");

        setSize(10, 16);
        offset.set(3, 0);
    }

    public function collect()
    {
        alive = false;
        solid = false;
        Global.coins += 1;
        FlxG.sound.play('assets/sounds/coin.ogg');
        trace("Global.coins = " + Global.coins);
        FlxTween.tween(this, {alpha: 0, y: y - targetY}, 0.5, {ease: FlxEase.circOut, onComplete: function (_)
        {
            kill();
        }}); // thanks official haxeflixel tutorial
    }
}