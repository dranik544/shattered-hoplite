# base_item.gd
extends Node2D

var currentCellPOS: Vector2 = Vector2.ZERO

export(NodePath) var tilemapPath

export(String) var itemName = "Item"
export(String) var itemDesc = "Item desc."

onready var tween = $Tween
onready var shadow = $shadow
onready var sprite = $Sprite

onready var tilemap: Node2D = get_node_or_null(tilemapPath)
onready var tilemapLayer0: TileMap
onready var tilemapLayer1: TileMap
onready var tilemapLayer2: TileMap
onready var logtext: RichTextLabel


func _init():
	add_to_group("item")

func _ready():
	if tilemap == null: tilemap = get_tree().get_first_node_in_group("tilemap")
	tilemapLayer0 = tilemap.get_node("layer0")
	tilemapLayer1 = tilemap.get_node("layer1")
	tilemapLayer2 = tilemap.get_node("layer2")
	logtext = get_tree().get_first_node_in_group("logtext")
	
	currentCellPOS = tilemapLayer1.world_to_map(global_position)
	global_position = tilemapLayer1.map_to_world(currentCellPOS)



func pickup(inventory_pos: Vector2 = Vector2.ZERO):
	var info: Dictionary = {
		"itemName": itemName,
		"itemDesc": itemDesc,
		"itemTexture": sprite.texture,
		"itemScenePath": filename
	}
	
	currentCellPOS = Vector2.ONE * 9999
	Global.add_item_to_inventory(info)
	logtext.print_log("[color=grey]The item " + itemName + " was picked up.\n")
	
	if inventory_pos != Vector2.ZERO:
		var time: float = 0.3
		tween.interpolate_property(self, "global_position", global_position, inventory_pos, time)
		tween.interpolate_property(self, "modulate:a", 1.0, 0.0, time+0.1)
		tween.interpolate_property(self, "scale", Vector2.ONE, Vector2.ZERO, time+0.1)
		tween.start()
		yield(tween, "tween_all_completed")
	
	queue_free()

func use():
	return
