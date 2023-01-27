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

class TestBoss extends Boss {

    public function new(x:Float, y:Float) {
        super(x, y);
        name = "testboss";
        health = 10;
        startingHealth = health;
        graphic = new Image("graphics/testboss.png");
        mask = new Hitbox(50, 50);
    }
}

