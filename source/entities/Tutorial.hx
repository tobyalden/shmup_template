package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.graphics.text.*;
import haxepunk.Tween;
import haxepunk.tweens.motion.*;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class Tutorial extends MiniEntity
{
    public function new(startX:Float, startY:Float, text:String) {
        super(startX, startY);
        graphic = new Text(
            text, {size: 24, font: "font/arial.ttf", align: TextAlignType.LEFT}
        );
    }
}
