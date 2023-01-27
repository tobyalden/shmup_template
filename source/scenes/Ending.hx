package scenes;

import entities.*;
import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.graphics.text.*;
import haxepunk.graphics.text.TextAlignType;
import haxepunk.graphics.tile.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import openfl.Assets;

class Ending extends Scene
{
    //public static inline var MAP_TILE_SIZE = 16;

    public static var sfx:Map<String, Sfx> = null;
    private var curtain:Curtain;
    private var message:Text;
    private var canMove:Bool;
    private var isReturningToMainMenu:Bool;

    override public function begin() {
        addGraphic(new Image("graphics/ending.png"), 1);
        curtain = add(new Curtain());
        curtain.fadeOut(1);
        var totalTime = timeRound(GameScene.totalTime);
        var deathText = "deaths";
        if(GameScene.deathCount == 1) {
            deathText = "death";
        }
        message = new Text(
            '${totalTime} seconds\n${GameScene.deathCount} ${deathText}',
            0, 0, GameScene.GAME_WIDTH, 0,
            {
                color: 0xFFFFFF, align: TextAlignType.CENTER, leading: 0,
                font: "font/arial.ttf", size: 16
            }
        );
        message.centerOrigin();
        message.x = GameScene.GAME_WIDTH / 2;
        message.y = GameScene.GAME_HEIGHT / 2;
        addGraphic(message);
        canMove = false;
        isReturningToMainMenu = false;
        var allowMove = new Alarm(0.25, function() {
            canMove = true;
        });
        addTween(allowMove, true);
        if(sfx == null) {
            sfx = [
                "endingmusic" => new Sfx("audio/endtheme.ogg"),
                "select" => new Sfx("audio/menuselect.ogg")
            ];
        }
        sfx["endingmusic"].play();
    }

    private function timeRound(number:Float, precision:Int = 2) {
        number *= Math.pow(10, precision);
        return Math.round(number) / Math.pow(10, precision);
    }

    override public function update() {
        if(canMove && !isReturningToMainMenu && Input.pressed("jump")) {
            isReturningToMainMenu = true;
            curtain.fadeIn(1);
            sfx["select"].play();
            HXP.alarm(1, function() {
                HXP.scene = new MainMenu();
            });
        }
        super.update();
    }
}
