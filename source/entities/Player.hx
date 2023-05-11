package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class Player extends MiniEntity
{
    public static inline var SPEED = 140;
    public static inline var SHOT_COOLDOWN = 0.1;
    public static inline var SHOT_SPEED = 400;

    public static var sfx:Map<String, Sfx> = null;

    public var sprite(default, null):Spritemap;
    public var isDead(default, null):Bool;
    private var velocity:Vector2;
    private var canMove:Bool;
    private var shotCooldown:Alarm;
    private var smallHitbox:Hitbox;

    public function new(x:Float, y:Float) {
        super(x, y);
        name = "player";
        type = "player";
        layer = -10;
        sprite = new Spritemap("graphics/player.png", 10, 15);
        sprite.add("idle", [0]);
        sprite.play("idle");
        var hitbox = new Hitbox(10, 15);
        smallHitbox = new Hitbox(2, 3, 4, 6);
        mask = new Masklist([hitbox, smallHitbox]);
        graphic = sprite;
        velocity = new Vector2();
        isDead = false;
        canMove = false;
        var allowMove = new Alarm(0.2, function() {
            canMove = true;
        });
        addTween(allowMove, true);
        shotCooldown = new Alarm(SHOT_COOLDOWN);
        addTween(shotCooldown);
        if(sfx == null) {
            sfx = [
                "die" => new Sfx("audio/death.ogg"),
                "shoot" => new Sfx("audio/shoot.ogg")
            ];
        }
    }

    override public function update() {
        if(!isDead) {
            if(canMove) {
                shooting();
                movement();
            }
            animation();
            if(canMove) {
                sound();
            }
            collisions();
        }
        super.update();
    }

    private function shooting() {
        if(Input.check("action") && !shotCooldown.active) {
            var spreadAmount = Math.PI / 16;
            var bullet = new Bullet(
                centerX, centerY,
                {
                    width: 6,
                    height: 12,
                    angle: (sprite.flipX ? -1 : 1) * Math.PI / 2
                        + (Math.random() - 0.5) * spreadAmount
                        - Math.PI / 2,
                    speed: SHOT_SPEED,
                    shotByPlayer: true,
                    collidesWithWalls: true
                }
            );
            scene.add(bullet);
            shotCooldown.start();
        }
        if(Input.check("action")) {
            if(!sfx["shoot"].playing) {
                sfx["shoot"].loop();
            }
        }
        else {
            sfx["shoot"].stop();
        }
    }

    private function collisions() {
        var fatal = collideMultiple(["hazard", "boss"], x, y);
        if(fatal != null) {
            if(smallHitbox.collide(fatal.mask)) {
                die();
            }
        }
    }

    private function stopSounds() {
        sfx["shoot"].stop();
    }

    public function die() {
        visible = false;
        collidable = false;
        isDead = true;
        explode();
        stopSounds();
        sfx["die"].play(0.8);
        cast(HXP.scene, GameScene).onDeath();
    }

    private function movement() {
        var heading = new Vector2();

        if(Input.check("left")) {
            heading.x = -1;
        }
        else if(Input.check("right")) {
            heading.x = 1;
        }
        else {
            heading.x = 0;
        }

        if(Input.check("up")) {
            heading.y = -1;
        }
        else if(Input.check("down")) {
            heading.y = 1;
        }
        else {
            heading.y = 0;
        }

        velocity = heading;
        velocity.normalize(SPEED);

        moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed);
    }


    private function animation() {
    }

    private function sound() {
    }
}
