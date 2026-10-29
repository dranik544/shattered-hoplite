# hoplite_pl.gd
extends Node2D

var currentCellPOS: Vector2 = Vector2.ZERO

export(NodePath) var tilemapPath
export(NodePath) var hoverPath

export(int) var health = 10
export(int) var maxHealth = 10
export(int) var attackDamage = 1
export(Array) var moveDirections = [
	Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1),
	Vector2(1, 1), Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1),
	Vector2(2, 0), Vector2(-2, 0), Vector2(0, 2), Vector2(0, -2),
#	Vector2(-2, -2), Vector2(2, 2), Vector2(-2, 2), Vector2(2, -2),
	Vector2(-1, -2), Vector2(1, 2), Vector2(-2, 1), Vector2(2, -1),
	Vector2(-2, -1), Vector2(2, 1), Vector2(-1, 2), Vector2(1, -2),
]
export(Array) var attackDirections = [
	Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1),
	Vector2(-1, -1), Vector2(1, 1), Vector2(-1, 1), Vector2(1, -1),
#	Vector2(2, 0), Vector2(-2, 0), Vector2(0, 2), Vector2(0, -2),
#	Vector2(-2, -2), Vector2(2, 2), Vector2(-2, 2), Vector2(2, -2),
#	Vector2(-1, -2), Vector2(1, 2), Vector2(-2, 1), Vector2(2, -1),
#	Vector2(-2, -1), Vector2(2, 1), Vector2(-1, 2), Vector2(1, -2),
]

onready var tween: Tween = $Tween
onready var hover: Sprite = get_node(hoverPath)
onready var sprite: Sprite = $sprite
onready var shadow: Sprite = $shadow
onready var default_animation_tween: Tween = $default_animation_tween

onready var inventory: Control = $CanvasLayer/inventory
onready var owindow: Control = $CanvasLayer/owindow
onready var inventory_button = $CanvasLayer/bottom_panel/buttons/inventory_button
onready var healthbar = $CanvasLayer/bottom_panel/healthbar
onready var healthbar_label = $CanvasLayer/bottom_panel/healthbar/Label

onready var tilemap: Node2D = get_node_or_null(tilemapPath)
onready var tilemapLayer0: TileMap
onready var tilemapLayer1: TileMap
onready var tilemapLayer2: TileMap
onready var logtext: RichTextLabel


func _init():
	add_to_group("player")

func _ready():
	if tilemap == null: tilemap = get_tree().get_first_node_in_group("tilemap")
	tilemapLayer0 = tilemap.get_node("layer0")
	tilemapLayer1 = tilemap.get_node("layer1")
	tilemapLayer2 = tilemap.get_node("layer2")
	logtext = get_tree().get_first_node_in_group("logtext")
	
	inventory_button.connect("pressed", self, "_on_inventory_button_pressed")
	
	currentCellPOS = tilemapLayer1.world_to_map(global_position)
	global_position = tilemapLayer1.map_to_world(currentCellPOS)
	
	start_default_animation()
	
	damage(0)



func start_default_animation():
	default_animation_tween.repeat = true
	default_animation_tween.interpolate_property(sprite, "scale", Vector2(0.95, 1.00), Vector2(1.00, 0.95), 0.35, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	default_animation_tween.interpolate_property(sprite, "scale", Vector2(1.00, 0.95), Vector2(0.95, 1.00), 0.35, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.35)
	default_animation_tween.start()

func _input(event):
	if event is InputEvent:
		if Input.is_action_just_pressed("WAIT"):
			end_turn(false)
	
	if event is InputEventMouse:
		var mousePOS = get_global_mouse_position()
		var cellPOS = tilemapLayer1.world_to_map(mousePOS)
		
		hover.global_position = tilemapLayer1.map_to_world(cellPOS)
		if get_object_by_cell_pos(cellPOS, "enemy") != null:
			hover.modulate = Color(1.0, 0.0, 0.0)
		else:
			hover.modulate = Color(1.0, 1.0, 1.0)
		
		if check_valid_to_move_cell(cellPOS):
			hover.modulate.a = 0.75
		else:
			hover.modulate.a = 0.40
		
		if Global.turn == true and event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
			if !inventory.visible && !owindow.visible:
				if get_object_by_cell_pos(cellPOS, "enemy") != null:
					if attack_enemy(cellPOS):
						end_turn()
					return
				
				if check_valid_to_move_cell(cellPOS):
					move_player_with_animation(tilemapLayer1.map_to_world(cellPOS))
					end_turn()
					return
				
				if get_object_by_cell_pos(cellPOS, "item") != null:
					if check_valid_to_move_cell(cellPOS, true):
						get_object_by_cell_pos(cellPOS, "item").pickup(
							get_viewport().get_canvas_transform().affine_inverse().xform(inventory_button.rect_global_position + (inventory_button.rect_size / 2))
						)
						end_turn()



func end_turn(waittime: bool = true):
	if get_tree().get_nodes_in_group("enemy").size() > 0:
		Global.turn = false
	
	Global.totalTurns += 1
	yield(get_tree().create_timer(0.3 if waittime else 0.025), "timeout")
	Global.emit_signal("enemyTurn")

func attack_enemy(cellpos: Vector2, damage: int = attackDamage):
	if !check_attack_directions(cellpos): return false
	
	var enemy = get_object_by_cell_pos(cellpos, "enemy")
	if enemy != null:
		enemy.damage(-damage)
		return true
	
	return false

func damage(attackDamage: int):
	health += attackDamage
	
	healthbar.max_value = maxHealth
	healthbar.value = health
	healthbar_label.text = str(health) + "/" + str(maxHealth)
	
	tween.interpolate_property(sprite, "modulate", Color(1.0, 0.0, 0.0), Color(1.0, 1.0, 1.0), 0.2, Tween.TRANS_QUAD, Tween.EASE_IN)
	tween.start()
	
	if health <= 0: kill()

func kill():
	tween.interpolate_property(sprite, "modulate", sprite.modulate, Color(1.0, 0.0, 0.0), 1.0)
	tween.start()
	
	return   # позже сделаю смерть
	
#	queue_free()

func get_object_by_cell_pos(cellpos: Vector2, object_group_name: String):
	for i in get_tree().get_nodes_in_group(object_group_name):
		if i.currentCellPOS == cellpos:
			return i
	
	return null

func check_valid_to_move_cell(cellpos: Vector2, skipgroups: bool = false, skipmovedirections: bool = false):
	if !skipmovedirections:
		var valid = false
		for dir in moveDirections:
			if currentCellPOS + dir == cellpos:
				valid = true
				break
		if !valid: return false
	
	if !skipgroups:
		var groups: Array = [
			get_tree().get_nodes_in_group("enemy"),
			get_tree().get_nodes_in_group("item"),
		]
		for i in groups:
			for o in i:
				if cellpos == o.currentCellPOS:
					return false
	
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

func is_path_clear(start_cell: Vector2, end_cell: Vector2) -> bool:
	var dist = int(max(abs(start_cell.x - end_cell.x), abs(start_cell.y - end_cell.y)))
	var dir_x = sign(end_cell.x - start_cell.x)
	var dir_y = sign(end_cell.y - start_cell.y)
	
	var check_cell = start_cell
	for i in range(dist - 1):
		check_cell.x += dir_x
		check_cell.y += dir_y
		if tilemapLayer2.get_cell(check_cell.x, check_cell.y) != -1:
			return false
	return true

func check_attack_directions(target_cell: Vector2, currentcell: Vector2 = currentCellPOS) -> bool:
	for dir in attackDirections:
		var check_cell = currentcell + dir
		if check_cell == target_cell:
			if is_path_clear(currentcell, target_cell):
				return true
	return false

func move_player_with_animation(to: Vector2, from: Vector2 = global_position):
	currentCellPOS = tilemapLayer1.world_to_map(to)
	tween.interpolate_property(self, "global_position", from, to, 0.25, Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.start()



func _on_inventory_button_pressed():
	inventory.visible = not inventory.visible
