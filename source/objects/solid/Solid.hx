package objects.solid;

import misc.VPBSprite;

class Solid extends VPBSprite
{
    public function new(x:Float, y:Float, width:Int, height:Int)
    {
        super(x, y);
        makeSolidGraphic(width, height, ALL);
    }
}