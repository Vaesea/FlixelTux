package characters.player;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;

class Player extends FlxSprite
{
    // Movement
    var playerAcceleration:Int = 2000;
    var deceleration:Int = 1000;
    var gravity:Int = 1000;
    public var minJumpHeight:Int = 320;
    public var maxJumpHeight:Int = 384;
    var walkSpeed:Int = 128;
    var speed:Int = 0;
    var runSpeed:Int = 192;
    var decelerateOnJumpRelease:Float = 0.5;

    // Ducking
    var ducking:Bool = false;
    
    // Direction
    public var direction:Int = 1;

    // Extra Hitbox
    public var ceilingDetector:FlxSprite; // Really bad way to implement this, I think!

    public function new()
    {
        super();

        // Image + Animations
        loadGraphic("assets/images/characters/oriopha.png", true, 16, 32);
        animation.add("stand", [0], 8.0, false);
        animation.add("walk", [1, 2, 3, 2], 8.0, true);
        animation.add("jump", [4], 8.0, false);
        animation.add("duck", [5], 8.0, false);
        animation.play("stand");

        // Add deceleration (drag) and gravity
        drag.x = deceleration;
        acceleration.y = gravity;

        // Hitbox
        setSize(9, 26);
        offset.set(4, 6);
        
        // Ceiling Detector
        ceilingDetector = new FlxSprite(this.x, this.y - 6);
        ceilingDetector.makeGraphic(Std.int(this.width), 5, FlxColor.TRANSPARENT);

        // Add Ceiling Detector to PlayState to make it appear in the level
        Global.PS.add(ceilingDetector);
    }

    override public function update(elapsed:Float)
    {
        // Sync Ceiling Detector with player. This is a bad way to do it, as there's a delay, but who cares?
        ceilingDetector.x = this.x;
        ceilingDetector.y = this.y - 6;

        // Stop the player from falling off the map through the left
        if (x < 0)
        {
            x = 0;
        }

        if (x > Global.PS.map.width - this.width)
        {
            x = Global.PS.map.width - this.width;
        }

        // Kill the player when they fall into the void
        if (y > Global.PS.map.height)
        {
            die();
        }

        // Functions
        move();
        animate();

        FlxG.overlap(Global.PS.map, ceilingDetector);

        super.update(elapsed);
    }

    function animate()
    {
        if (!ducking)
        {
            // If the player is on the floor and staying where they are, stand.
            if (velocity.x == 0 && isTouching(FLOOR))
            {
                animation.play("stand");
            }

            // If the player is on the floor and moving, walk.
            if (velocity.x != 0 && isTouching(FLOOR))
            {
                animation.play("walk");
            }

            // If the player is not on the floor, jump.
            // TODO: Is velocity.y != 0 needed?
            if (velocity.y != 0 && !isTouching(FLOOR))
            {
                animation.play("jump");
            }
        }
        else
        {
            animation.play("duck");
        }
    }

    function move()
    {
        // Speed is, by default, 0.
        acceleration.x = 0;

        // If CONTROL is being pressed, run, If not, then just walk
        if (FlxG.keys.pressed.CONTROL)
        {
            speed = runSpeed;
        }
        else
        {
            speed = walkSpeed;
        }

        maxVelocity.x = speed; // Limit the player's speed

        // If player presses left, move left. If player presses right, move right.
        var duck_on_floor = (ducking && isTouching(FLOOR));
        
        if (!duck_on_floor)
        {
            if (FlxG.keys.anyPressed([LEFT, A]))
            {
                flipX = true; // Flip player
                direction = -1; // Set direction
                acceleration.x -= playerAcceleration; // Move
            }
            else if (FlxG.keys.anyPressed([RIGHT, D]))
            {
                flipX = false; // Unflip player
                direction = 1; // Set direction
                acceleration.x += playerAcceleration; // Move
            }
        }

        // If player is pressing jump keys and is on ground, jump.
        // If player is walking at the speed of runSpeed, jump higher than usual.
        if (FlxG.keys.anyJustPressed([SPACE, UP, W]) && isTouching(FLOOR))
        {
            if (velocity.x == runSpeed || velocity.x == -runSpeed) // Might replace this with Math.abs()
            {
                velocity.y = -maxJumpHeight;
            }
            else
            {
                velocity.y = -minJumpHeight;
            }

            FlxG.sound.play("assets/sounds/jump.ogg");
        }

        if (velocity.y < 0 && FlxG.keys.anyJustReleased([SPACE, W, UP]))
        {
            velocity.y -= velocity.y * decelerateOnJumpRelease;
        }

        // Ducking and standing (I wish there was a better way to do this)
        if (!ducking && isTouching(FLOOR) && FlxG.keys.anyPressed([DOWN, S]))
        {
            ducking = true;

            var oldHeight = height;
            setSize(12, 13);
            offset.set(4, 19); // Things seem to be reversed here.
            y += oldHeight - height;
        }
        else if (ducking && isTouching(FLOOR) && !FlxG.keys.anyPressed([DOWN, S]))
        {
            if (!ceilingDetector.overlaps(Global.PS.map))
            {
                ducking = false;

                var oldHeight = height;
                setSize(9, 26);
                y -= height - oldHeight;
                offset.set(4, 6);
            }
        }
    }

    public function die()
    {
        Global.coins = 0;
        FlxG.resetState();
    }
}