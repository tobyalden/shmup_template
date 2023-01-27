package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.graphics.tile.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.motion.*;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class Lock extends MiniEntity
{
    public function new(startX:Float, startY:Float, startWidth:Int, startHeight:Int) {
        super(startX, startY);
        type = "walls";
        mask = new Hitbox(startWidth, startHeight);
        graphic = new ColoredRect(width, height, 0x808080);
    }

    override public function update() {
        collidable = cast(HXP.scene, GameScene).isAnyBossActive();
        visible = collidable;
        super.update();
    }
}
