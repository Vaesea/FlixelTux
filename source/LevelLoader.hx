package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.tile.FlxTilemap;
import objects.Coin;
import objects.Goal;
import objects.solid.Solid;
import states.PlayState;

class LevelLoader extends FlxState
{
    public static function loadLevel(state:PlayState, level:String)
    {
        var tiledMap = new TiledMap("assets/data/levels/" + level + ".tmx");

        // Don't remove the custom properties of the base level unless you remove one of the custom properties here!
        var song = tiledMap.properties.get("Music");
        var levelName = tiledMap.properties.get("Level Name");

        Global.levelName = levelName;

        // FlxG.sound.playMusic(song, 1.0, true); only add back if there's a problem
        Global.currentSong = song;

        FlxG.camera.bgColor = tiledMap.backgroundColor;
        
        // Background
        var backgroundLayer:TiledTileLayer = cast tiledMap.getLayer("Background");
        
        var backgroundMap = new FlxTilemap();
        backgroundMap.loadMapFromArray(backgroundLayer.tileArray, tiledMap.width, tiledMap.height, "assets/images/tiles.png", 16, 16, Global.PS.startingTile);
        backgroundMap.solid = false;

        // Interactive / Main
        var interactiveLayer:TiledTileLayer = cast tiledMap.getLayer("Main");

        state.map = new FlxTilemap();
        state.map.loadMapFromArray(interactiveLayer.tileArray, tiledMap.width, tiledMap.height, "assets/images/tiles.png", 16, 16, Global.PS.startingTile);
        state.map.solid = false;

        state.add(backgroundMap);
        state.add(state.map);

        // Load collision
        for (solid in getLevelObjects(tiledMap, "Solid"))
        {
            var solidSquare = new Solid(solid.x, solid.y, solid.width, solid.height); // Need this because width and height.
            state.solidThings.add(solidSquare);
        }

        // Load goal
        for (object in getLevelObjects(tiledMap, "Level"))
        {
            switch (object.type)
            {
                case "goal": // Will add a checkpoint at some point!
                    state.items.add(new Goal(object.x, object.y, object.width, object.height));
            }
        }

        // Load coins
        for (object in getLevelObjects(tiledMap, "Objects"))
        {
            switch (object.type)
            {
                case "coin":
                    state.items.add(new Coin(object.x, object.y - 16));
            }
        }
        
        // Don't be like me. Don't remove this.
        var playerPosition:TiledObject = getLevelObjects(tiledMap, "Player")[0];
        state.player.setPosition(playerPosition.x, playerPosition.y - 26);
    }

    public static function getLevelObjects(map:TiledMap, layer:String):Array<TiledObject>
    {
        if ((map != null) && (map.getLayer(layer) != null))
        {
            var objLayer:TiledObjectLayer = cast map.getLayer(layer);
            return objLayer.objects;
        }
        else
        {
            trace("Object layer " + layer + " not found! Also credits to Discover Haxeflixel.");
            return [];
        }
    }
}