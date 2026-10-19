# hoplite_pl.gd
extends Node2D

var currentCellPOS: Vector2 = Vector2.ZERO

export(NodePath) var tilemapPath
export(NodePath) var hoverPath

onready var tween: Tween = $Tween
onready var hover: Sprite = get_node(hoverPath)

onready var tilemap: Node2D = get_node_or_null(tilemapPath)
onready var tilemapLayer0: TileMap
onready var tilemapLayer1: TileMap
onready var tilemapLayer2: TileMap


func _init():
	add_to_group("player")

func _ready():
	if tilemap == null: tilemap = get_tree().get_first_node_in_group("tilemap")
	tilemapLayer0 = tilemap.get_node("layer0")
	tilemapLayer1 = tilemap.get_node("layer1")
	tilemapLayer2 = tilemap.get_node("layer2")
	
	currentCellPOS = tilemapLayer1.world_to_map(global_position)
	global_position = tilemapLayer1.map_to_world(currentCellPOS)

func _input(event):
	if event is InputEvent:
		if Input.is_action_just_pressed("WAIT"):
			end_turn(false)
	
	if event is InputEventMouse:
		var mousePOS = get_global_mouse_position()
		var cellPOS = tilemapLayer1.world_to_map(mousePOS)
		
		hover.global_position = tilemapLayer1.map_to_world(cellPOS)
		if check_valid_to_move_cell(cellPOS):
			hover.modulate.a = 0.75
		else:
			hover.modulate.a = 0.40
		
		if Global.turn == true:
			if Input.is_action_just_pressed("CLICK"):
				if check_valid_to_move_cell(cellPOS) && check_distance(cellPOS, currentCellPOS) == 1:
					move_player_with_animation(tilemapLayer1.map_to_world(cellPOS))
					end_turn()



func end_turn(waittime: bool = true):
	Global.turn = false
	
	yield(get_tree().create_timer(0.3 if waittime else 0.025), "timeout")
	print("Игрок " + str(self) + " сделал ход на клетку " + str(currentCellPOS))
	Global.emit_signal("enemyTurn")

func check_valid_to_move_cell(cellpos: Vector2):
	var enemies: Array = get_tree().get_nodes_in_group("enemy")
	for i in enemies:
		if cellpos == i.currentCellPOS:
			return false
			break
	
	if (
		tilemapLayer2.get_cell(cellpos.x, cellpos.y) == -1 &&
		tilemapLayer1.get_cell(cellpos.x, cellpos.y) != -1
	):
		return true
	else:
		return false

func check_distance(cellpos: Vector2, currentpos: Vector2 = currentCellPOS):
	var distance: int = int(max(abs(currentpos.x - cellpos.x), abs(currentpos.y - cellpos.y)))
	return distance

func move_player_with_animation(to: Vector2, from: Vector2 = global_position):
	currentCellPOS = tilemapLayer1.world_to_map(to)
	tween.interpolate_property(self, "global_position", from, to, 0.25, Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.start()
