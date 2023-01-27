package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.motion.*;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class TestBossThree extends Boss {

    public static inline var SPEED = 50;

    private var path:LinearPath;

    public function new(x:Float, y:Float, pathNodes:Array<Vector2>) {
        super(x, y);
        name = "testbossthree";
        health = 10;
        startingHealth = health;
        graphic = new Image("graphics/testbossthree.png");
        mask = new Hitbox(50, 50);

        path = new LinearPath(TweenType.Looping);
        for(point in pathNodes) {
            path.addPoint(point.x, point.y);
        }
        path.setMotionSpeed(SPEED);
        addTween(path, true);
    }

    override function update() {
        x = path.x;
        y = path.y;
        super.update();
    }
}
