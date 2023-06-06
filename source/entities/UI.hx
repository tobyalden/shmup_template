package entities;

import haxepunk.*;
import haxepunk.utils.*;
import haxepunk.graphics.*;
import haxepunk.graphics.text.*;
import haxepunk.Tween;
import haxepunk.tweens.motion.*;
import haxepunk.tweens.misc.*;
import scenes.*;

class UI extends MiniEntity {
    public static inline var MAX_NUMBER_OF_BOSSES = 4;

    private var allSprites:Graphiclist;
    private var healthBars:Array<Image>;
    private var healthBarLabels:Array<Text>;
    private var retryPrompt:Text;
    private var initialNumberOfBosses:Int;

    public function new() {
        super(0, 0);
        layer = -100;
        allSprites = new Graphiclist();

        healthBars = [];
        healthBarLabels = [];
        for(i in 0...MAX_NUMBER_OF_BOSSES) {
            var healthBar = new Image("graphics/bosshealth.png");
            healthBar.y = 20 - healthBar.height - 4;

            var healthBarLabel = new Text('BOSS #${i}');
            healthBarLabel.y = healthBar.y - 10;

            healthBars.push(healthBar);
            allSprites.add(healthBar);

            healthBarLabels.push(healthBarLabel);
            allSprites.add(healthBarLabel);
        }

        allSprites.scrollX = 0;
        allSprites.scrollY = 0;

        retryPrompt = new Text(
            "",
            GameScene.GAME_WIDTH / 2,
            GameScene.GAME_HEIGHT / 2,
            GameScene.GAME_WIDTH,
            0,
            { size: 12, font: "font/arial.ttf", align: TextAlignType.CENTER}
        );
        retryPrompt.alpha = 0;
        allSprites.add(retryPrompt);

        graphic = allSprites;

        initialNumberOfBosses = 0;
    }

    public function showRetryPrompt() {
        var retryPromptFader = new VarTween();
        retryPromptFader.tween(retryPrompt, "alpha", 1, 0.5, Ease.sineOut);
        addTween(retryPromptFader, true);
    }

    public override function update() {
        var gameScene = cast(HXP.scene, GameScene);
        if(!gameScene.isRetrying) {
            retryPrompt.text = "Z: try again";
            retryPrompt.centerOrigin();
        }
        var activeBosses = gameScene.activeBosses;
        for(healthBar in healthBars) {
            healthBar.visible = false;
        }
        for(healthBarLabel in healthBarLabels) {
            healthBarLabel.visible = false;
        }
        if(activeBosses.length > 0) {
            if(initialNumberOfBosses == 0) {
                initialNumberOfBosses = activeBosses.length;
                for(i in 0...initialNumberOfBosses) {
                    healthBars[i].x = (
                        i * GameScene.GAME_WIDTH / initialNumberOfBosses + (8 / initialNumberOfBosses)
                    );
                    healthBarLabels[i].x = healthBars[i].x + 12 / initialNumberOfBosses;
                }
            }
            for(i in 0...activeBosses.length) {
                healthBars[i].visible = true;
                healthBars[i].scaleX = (
                    activeBosses[i].health / activeBosses[i].startingHealth / initialNumberOfBosses
                );

                healthBarLabels[i].visible = true;
                healthBarLabels[i].text = activeBosses[i].name.toUpperCase();
            }
        }
        else {
            initialNumberOfBosses = 0;
        }
        super.update();
    }
}


