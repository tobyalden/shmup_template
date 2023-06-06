package scenes;

import entities.*;
import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.graphics.tile.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import openfl.Assets;

class GameScene extends Scene
{
    public static inline var SAVE_FILE_NAME = "saveme";
    public static inline var GAME_WIDTH = 270;
    public static inline var GAME_HEIGHT = 360;

    public static var totalTime:Float = 0;
    public static var deathCount:Float = 0;
    public static var sfx:Map<String, Sfx> = null;

    public var activeBosses(default, null):Array<Boss>;
    public var defeatedBossNames(default, null):Array<String>;

    public var curtain(default, null):Curtain;
    public var isRetrying(default, null):Bool;
    private var level:Level;
    private var player:Player;
    private var ui:UI;
    private var canRetry:Bool;

    public function saveGame() {
        Data.write("hasSaveData", true);
        Data.write("totalTime", totalTime);
        Data.write("deathCount", deathCount);
        Data.write("defeatedBossNames", defeatedBossNames.join(','));
        Data.save(SAVE_FILE_NAME);
    }

    override public function begin() {
        Data.load(SAVE_FILE_NAME);

        activeBosses = [];
        defeatedBossNames = Data.read("defeatedBossNames", "").split(",");
        defeatedBossNames.remove("");

        curtain = add(new Curtain());
        curtain.fadeOut(1);

        activeBosses = [];

        ui = add(new UI());
        canRetry = false;
        isRetrying = false;

        player = new Player(GAME_WIDTH / 2, GAME_HEIGHT / 4 * 3);
        player.moveBy(-player.width / 2, -player.height / 2);
        add(player);
        
        var boss = add(new TestBoss(GAME_WIDTH / 2, GAME_HEIGHT / 8));
        boss.moveBy(-boss.width / 2, 0);
        boss.active = true;
        activeBosses.push(boss);
        add(boss);

        if(sfx == null) {
            sfx = [
                "restart" => new Sfx("audio/restart.ogg"),
                "retryprompt" => new Sfx("audio/retryprompt.ogg"),
                "retry" => new Sfx("audio/retry.wav"),
                "backtosavepoint" => new Sfx("audio/backtosavepoint.ogg"),
                "ambience" => new Sfx("audio/ambience.wav")
            ];
        }
        if(!sfx["ambience"].playing) {
            sfx["ambience"].loop();
        }
    }

    public function defeatBoss(boss:Boss) {
        activeBosses.remove(boss);
        defeatedBossNames.push(boss.name);
    }

    public function isAnyBossActive() {
        return activeBosses.length > 0;
    }

    public function isBossDefeated(bossName:String) {
        return defeatedBossNames.indexOf(bossName) != -1;
    }

    public function triggerBoss(bossName:String) {
        if(isBossDefeated(bossName)) {
            return;
        }
        var boss = cast(getInstance(bossName), Boss);
        boss.active = true;
        activeBosses.push(boss);
    }

    public function onDeath() {
        Boss.sfx["klaxon"].stop();
        Data.load(SAVE_FILE_NAME);
        GameScene.deathCount++;
        HXP.alarm(1, function() {
            ui.showRetryPrompt();
            sfx["retryprompt"].play();
            canRetry = true;
        });
    }

    override public function update() {
        if(canRetry && !isRetrying) {
            var retry = false;
            if(Input.pressed("jump")) {
                sfx["retry"].play(0.75);
                retry = true;
            }
            if(retry) {
                isRetrying = true;
                curtain.fadeIn(0.2);
                var reset = new Alarm(0.2, function() {
                    HXP.scene = new GameScene();
                });
                addTween(reset, true);
            }
        }

        totalTime += HXP.elapsed;
        if(Input.pressed("restart")) {
            Data.clear(SAVE_FILE_NAME);
            HXP.scene = new GameScene();
            sfx["restart"].play();
        }
        if(Key.pressed(Key.P)) {
            trace(activeBosses);
        }
        super.update();
    }
}
