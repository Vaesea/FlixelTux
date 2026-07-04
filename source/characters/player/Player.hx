package characters.player;

import flixel.FlxG;
import flixel.FlxSprite;

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

    // Ducking, unused at the moment
    var ducking:Bool = false;
    
    // Direction
    public var direction:Int = 1;

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
    }

    override public function update(elapsed:Float)
    {
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
    }

    public function die()
    {
        FlxG.resetState();
    }
}