package entities;

import haxepunk.*;
import haxepunk.utils.*;
import haxepunk.graphics.*;

class Dust extends MiniEntity {
    public var sprite:Spritemap;

    public function new(x:Float, y:Float) {
        super(x, y);
        sprite = new Spritemap("graphics/grounddust.png", 8, 4);
        sprite.add("idle", [0, 1, 2, 3, 4], 16, false);
        sprite.play("idle");
        graphic = sprite;
    }

    public override function update() {
        if(sprite.complete) {
            scene.remove(this);
        }
        super.update();
    }
}

