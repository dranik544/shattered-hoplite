# hoplite_pl.gd
extends Node2D

var currentCellPOS: Vector2 = Vector2.ZERO

export(NodePath) var tilemapPath
export(NodePath) var hoverPath

export(int) var health = 10
var maxHealth: int = health
export(int) var attackDamage = 1

onready var tween: Tween = $Tween
onready var hover: Sprite = get_node(hoverPath)
onready var sprite: Sprite = $sprite
onready var shadow: Sprite = $shadow
onready var default_animation_tween: Tween = $default_animation_tween

onready var inventory: Control = $CanvasLayer/inventory
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



func start_default_animation():
	default_animation_tween.repeat = true
	default_animation_tween.interpolate_property(sprite, "scale", Vector2(0.95, 1.00), Vector2(1.00, 0.95), 0.3, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	default_animation_tween.interpolate_property(sprite, "scale", Vector2(1.00, 0.95), Vector2(0.95, 1.00), 0.3, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.5)
	default_animation_tween.start()

func _input(event):
	if event is InputEvent:
		if Input.is_action_just_pressed("WAIT"):
			end_turn(false)
	
	if event is InputEventMouse:
		var mousePOS = get_global_mouse_position()
		var cellPOS = tilemapLayer1.world_to_map(mousePOS)
		
		hover.global_position = tilemapLayer1.map_to_world(cellPOS)
		
		if get_enemy_by_cell_pos(cellPOS) != null:
			hover.modulate = Color(1.0, 0.0, 0.0)
		else:
			hover.modulate = Color(1.0, 1.0, 1.0)
		
		if check_valid_to_move_cell(cellPOS):
			hover.modulate.a = 0.75
		else:
			hover.modulate.a = 0.40
		
		if Global.turn == true:
			if Input.is_action_just_pressed("CLICK") && !inventory.visible:
				if check_distance(cellPOS, currentCellPOS) == 1:
					if check_valid_to_move_cell(cellPOS):
						move_player_with_animation(tilemapLayer1.map_to_world(cellPOS))
						end_turn()
					elif !check_valid_to_move_cell(cellPOS) && get_enemy_by_cell_pos(cellPOS) != null:
						attack_enemy(cellPOS)
						end_turn()



func end_turn(waittime: bool = true):
	if get_tree().get_nodes_in_group("enemy").size() > 0:
		Global.turn = false
	
	yield(get_tree().create_timer(0.3 if waittime else 0.025), "timeout")
	Global.emit_signal("enemyTurn")

func attack_enemy(cellpos: Vector2, damage: int = attackDamage):
	var enemy: Node2D = get_enemy_by_cell_pos(cellpos)
	
	if enemy != null:
		enemy.damage(-damage)

func damage(attackDamage: int):
	health += attackDamage
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

func get_enemy_by_cell_pos(cellpos: Vector2):
	for i in get_tree().get_nodes_in_group("enemy"):
		if i.currentCellPOS == cellpos:
			return i
	
	return null

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



func _on_inventory_button_pressed():
	inventory.visible = not inventory.visible
