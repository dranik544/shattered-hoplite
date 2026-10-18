# hoplite_pl.gd
extends Node2D

export(NodePath) var tilemapPath
export(NodePath) var hoverPath

onready var tween: Tween = $Tween
onready var hover: Sprite = get_node(hoverPath)

onready var tilemap: Node2D = get_node(tilemapPath)
onready var tilemapLayer0: TileMap = tilemap.get_node("layer0")
onready var tilemapLayer1: TileMap = tilemap.get_node("layer1")
onready var tilemapLayer2: TileMap = tilemap.get_node("layer2")


func _input(event):
	if event is InputEventMouse:
		var mousePOS = get_global_mouse_position()
		var cellPOS = tilemapLayer1.world_to_map(mousePOS)
		var currentPOS = tilemapLayer1.world_to_map(global_position)
		
		hover.global_position = tilemapLayer1.map_to_world(cellPOS)
		if check_valid_to_move_cell(cellPOS):
			hover.modulate.a = 0.75
		else:
			hover.modulate.a = 0.40
		
		if Input.is_action_just_pressed("CLICK"):
			if check_valid_to_move_cell(cellPOS):
				if check_distance(cellPOS, currentPOS) == 1:
					move_player(tilemapLayer1.map_to_world(cellPOS))


func check_valid_to_move_cell(cellpos: Vector2):
	if (
		tilemapLayer2.get_cell(cellpos.x, cellpos.y) == -1 &&
		tilemapLayer1.get_cell(cellpos.x, cellpos.y) != -1
	):
		return true
	else:
		return false

func check_distance(cellpos: Vector2, currentpos: Vector2):
	var distance: int = int(max(abs(currentpos.x - cellpos.x), abs(currentpos.y - cellpos.y)))
	return distance

func move_player(to: Vector2, from: Vector2 = global_position):
	tween.interpolate_property(self, "global_position", from, to, 0.25, Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.start()
