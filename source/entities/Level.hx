package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.graphics.tile.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import openfl.Assets;

class Level extends Entity
{
    public static inline var TILE_SIZE = 10;

    public var entities(default, null):Array<MiniEntity>;

    public function new(levelName:String) {
        super(0, 0);
        loadLevel(levelName);
    }


    override public function update() {
        super.update();
    }

    private function loadLevel(levelName:String) {
        var levelData = haxe.Json.parse(Assets.getText('levels/${levelName}.json'));
        for(layerIndex in 0...levelData.layers.length) {
            var layer = levelData.layers[layerIndex];
            if(layer.name == "entities") {
                // Load entities
                entities = new Array<MiniEntity>();
                for(entityIndex in 0...layer.entities.length) {
                    var entity = layer.entities[entityIndex];
                    if(entity.name == "player") {
                        entities.push(new Player(entity.x - 3, entity.y - 4));
                    }
                    else if(entity.name == "testBoss") {
                        entities.push(new TestBoss(entity.x, entity.y));
                    }
                    else if(entity.name == "testBossTwo") {
                        entities.push(new TestBossTwo(entity.x, entity.y));
                    }
                    else if(entity.name == "testBossThree") {
                        entities.push(new TestBossThree(entity.x, entity.y, getPathNodes(entity, entity.nodes)));
                    }
                    else if(entity.name == "tutorial") {
                        entities.push(new Tutorial(entity.x, entity.y, entity.values.text));
                    }
                }
            }
        }
    }

    private function getPathNodes(entity:Dynamic, nodes:Dynamic) {
        var pathNodes = new Array<Vector2>();
        pathNodes.push(new Vector2(entity.x, entity.y));
        for(i in 0...entity.nodes.length) {
            pathNodes.push(new Vector2(entity.nodes[i].x, entity.nodes[i].y));
        }
        pathNodes.push(new Vector2(entity.x, entity.y));
        return pathNodes;
    }
}
