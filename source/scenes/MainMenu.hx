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
import haxepunk.utils.*;
import openfl.Assets;

class MainMenu extends Scene
{
    public static inline var MENU_LEFT_MARGIN = 50;
    public static inline var MENU_TOP_MARGIN = 50;
    public static inline var MENU_FONT_SIZE = 16;
    public static inline var MENU_ITEM_SPACING = 5;
    public static inline var MENU_FONT = "arial.ttf";
    public static inline var MENU_CONFIRM_SPACES = "    ";
    public static inline var MENU_CONFIRM_YES = "YES";
    public static inline var MENU_CONFIRM_NO = "NO";

    public static var sfx:Map<String, Sfx> = null;
    private var curtain:Curtain;
    private var cursor:Entity;
    private var cursorIndex:Int;
    private var menuItems:Array<Text>;
    private var hasSaveData:Bool;
    private var isConfirming:Bool;
    private var confirmChoiceIsYes:Bool;
    private var isStarting:Bool;

    private var menuItemHeight:Int;
    private var menuConfirmYesX:Int;
    private var menuConfirmNoX:Int;

    override public function begin() {
        Data.load(GameScene.SAVE_FILE_NAME);
        hasSaveData = Data.read("hasSaveData", false);
        addGraphic(new Image("graphics/mainmenu.png"), 20);
        curtain = add(new Curtain());
        curtain.fadeOut(1);

        var menuItemNames = ["NEW GAME", "CONTINUE"];
        menuItems = new Array<Text>();
        var count = 0;
        var totalHeight = 0;
        var totalWidth = 0;

        var testText = new Text("WWW", {size: MENU_FONT_SIZE, font: 'font/${MENU_FONT}'});
        menuItemHeight = testText.height + MENU_ITEM_SPACING;
        testText.text = '${MENU_CONFIRM_SPACES}';
        menuConfirmYesX = MENU_LEFT_MARGIN + testText.textWidth;
        testText.text = '${MENU_CONFIRM_SPACES}${MENU_CONFIRM_YES}${MENU_CONFIRM_SPACES}';
        menuConfirmNoX = MENU_LEFT_MARGIN + testText.textWidth;

        for(menuItemName in menuItemNames) {
            var text = new Text(
                menuItemName, MENU_LEFT_MARGIN, MENU_TOP_MARGIN + menuItemHeight * count,
                { size: MENU_FONT_SIZE, font: 'font/${MENU_FONT}'}
            );
            menuItems.push(text);
            totalWidth = text.textWidth > totalWidth ? text.textWidth : totalWidth;
            totalHeight += (text.textHeight + 5);
            if(menuItemName == "CONTINUE" && !hasSaveData) {
                text.alpha = 0.5;
            }
            count++;
        }
        totalWidth += 15;
        var menuBackdrop = new ColoredRect(totalWidth, totalHeight, 0x000000);
        menuBackdrop.alpha = 0.5;
        addGraphic(menuBackdrop, 5, menuItems[0].x, menuItems[0].y);
        for(menuItem in menuItems) {
            addGraphic(menuItem);
        }

        var cursorImage = new Image("graphics/cursor.png");
        cursorImage.originX = cursorImage.width;
        cursorImage.originY = Std.int(cursorImage.height / 2);
        cursor = addGraphic(cursorImage, 0);
        var cursorBobber = new VarTween(TweenType.PingPong);
        cursorBobber.tween(cursor.graphic, "x", 10, 0.7, Ease.circInOut);
        addTween(cursorBobber, true);

        cursorIndex = hasSaveData ? 1 : 0;
        isConfirming = false;
        isStarting = false;

        if(sfx == null) {
            sfx = [
                "start" => new Sfx("audio/start.wav"),
                "select" => new Sfx("audio/menuselect.ogg"),
                "back" => new Sfx("audio/menuback.ogg"),
                "no" => new Sfx("audio/menuno.ogg"),
                "newgame" => new Sfx("audio/newgame.wav"),
                "continue" => new Sfx("audio/continue.wav")
            ];
        }
    }

    override public function update() {
        if(isStarting) {
            // Do nothing
        }
        else if(isConfirming) {
            if(!confirmChoiceIsYes && Input.pressed("left")) {
                confirmChoiceIsYes = true;
                sfx["select"].play();
            }
            else if(confirmChoiceIsYes && Input.pressed("right")) {
                confirmChoiceIsYes = false;
                sfx["select"].play();
            }
            else if(Input.pressed("jump")) {
                if(confirmChoiceIsYes) {
                    Data.clear();
                    startGame();
                    sfx["newgame"].play();
                }
                else {
                    menuItems[0].text = "NEW GAME";
                    menuItems[1].text = "CONTINUE";
                    cursorIndex = 0;
                    isConfirming = false;
                    sfx["back"].play();
                }
            }
            if(confirmChoiceIsYes) {
                cursor.x = menuConfirmYesX;
            }
            else {
                cursor.x = menuConfirmNoX;
            }
        }
        else {
            if(Input.pressed("up")) {
                if(cursorIndex > 0) {
                    cursorIndex--;
                }
                sfx["select"].play();
            }
            else if(Input.pressed("down")) {
                if(cursorIndex < menuItems.length - 1) {
                    cursorIndex++;
                }
                sfx["select"].play();
            }
            else if(Input.pressed("jump")) {
                if(cursorIndex == 0) {
                    if(hasSaveData) {
                        sfx["select"].play();
                        menuItems[0].text = "REALLY?";
                        menuItems[1].text = '${MENU_CONFIRM_SPACES}${MENU_CONFIRM_YES}${MENU_CONFIRM_SPACES}${MENU_CONFIRM_NO}';
                        cursorIndex = 1;
                        isConfirming = true;
                        confirmChoiceIsYes = false;
                    }
                    else {
                        startGame();
                        sfx["newgame"].play();
                    }
                }
                else if(cursorIndex == 1) {
                    if(hasSaveData) {
                        startGame();
                        sfx["continue"].play();
                    }
                    else {
                        sfx["no"].play();
                        // Do nothing, play "nope" sfx
                    }
                }
            }
            cursor.x = menuItems[0].x;
        }
        cursor.y = menuItems[0].y + menuItemHeight * (cursorIndex + 0.5);
        super.update();
    }

    private function startGame() {
        isStarting = true;
        curtain.fadeIn(1);
        GameScene.totalTime = Data.read("totalTime", 0);
        GameScene.deathCount = Data.read("deathCount", 0);
        HXP.alarm(1, function() {
            HXP.scene = new GameScene();
        });
    }
}
