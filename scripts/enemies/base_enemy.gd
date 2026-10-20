# base_enemy.gd
extends Node2D

var currentCellPOS: Vector2 = Vector2.ZERO
var freeze: bool = false

export(NodePath) var tilemapPath
export(NodePath) var playerPATH

export(int) var health = 1
export(int) var attackDistance = 1
export(int) var attackDamage = 1
export(Array) var moveDirections = [
	Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1),
	Vector2(1, 1), Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1)
]

onready var tween: Tween = $Tween
onready var sprite = $sprite
onready var shadow = $shadow

onready var tilemap: Node2D = get_node_or_null(tilemapPath)
onready var tilemapLayer0: TileMap
onready var tilemapLayer1: TileMap
onready var tilemapLayer2: TileMap
onready var player: Node2D = get_node_or_null(playerPATH)
onready var default_animation_tween = $default_animation_tween


func _init():
	add_to_group("enemy")

func _ready():
	Global.connect("enemyTurn", self, "move_enemy_to_player")
	
	if player == null: player = get_tree().get_first_node_in_group("player")
	if tilemap == null: tilemap = get_tree().get_first_node_in_group("tilemap")
	tilemapLayer0 = tilemap.get_node("layer0")
	tilemapLayer1 = tilemap.get_node("layer1")
	tilemapLayer2 = tilemap.get_node("layer2")
	
	currentCellPOS = tilemapLayer1.world_to_map(global_position)
	global_position = tilemapLayer1.map_to_world(currentCellPOS)
	
	start_default_animation()


func start_default_animation():
	default_animation_tween.repeat = true
	default_animation_tween.interpolate_property(sprite, "scale", Vector2(0.95, 1.00), Vector2(1.00, 0.95), 0.3, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	default_animation_tween.interpolate_property(sprite, "scale", Vector2(1.00, 0.95), Vector2(0.95, 1.00), 0.3, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.5)
	default_animation_tween.start()

func move_enemy_to_player():
	if freeze: return
	
	var distance: int = check_distance(currentCellPOS, player.currentCellPOS)
	
	if distance <= attackDistance:
		attack(attackDamage)
		end_turn()
		return
	
	if distance > attackDistance:
#		var testMoveCell: Vector2 = currentCellPOS - Vector2(1, 0)   # чисто для теста, в одну сторону
		var testMoveCell: Vector2 = find_best_step(player.currentCellPOS)   # чисто для теста, в одну сторону
		
		if check_valid_to_move_cell(testMoveCell):
			move_enemy_with_animation(tilemapLayer1.map_to_world(testMoveCell))
		end_turn()
		return

func find_best_step(target_cell: Vector2, currentcell: Vector2 = currentCellPOS) -> Vector2:
	var best_dir = currentcell
	var min_dist = 999
	
	for i in moveDirections:
		var check_cell = currentcell + i
		
		if check_valid_to_move_cell(check_cell):
			var dist = check_distance(check_cell, target_cell)
			if dist < min_dist:
				min_dist = dist
				best_dir = check_cell
	
	return best_dir

func end_turn():
	Global.turn = true
	yield(get_tree().create_timer(0.3), "timeout")
	print("Враг " + str(self) + " сделал ход")

func attack(damage: float = attackDamage):
	player.damage(-damage)
	print("Игрок атакован")

func damage(attackDamage: int):
	health += attackDamage
	tween.interpolate_property(sprite, "modulate", Color(1.0, 0.0, 0.0), Color(1.0, 1.0, 1.0), 0.2, Tween.TRANS_QUAD, Tween.EASE_IN)
	tween.start()
	
	if health <= 0: kill()

func kill():
	freeze = true
	remove_from_group("enemy")
	
	tween.interpolate_property(sprite, "modulate:a", 1.0, 0.0, 0.2, Tween.TRANS_QUAD, Tween.EASE_IN)
	tween.interpolate_property(shadow, "modulate:a", 1.0, 0.0, 0.2, Tween.TRANS_QUAD, Tween.EASE_IN)
	tween.start()
	yield(tween, "tween_all_completed")
	
	queue_free()

func check_distance(cellpos: Vector2, currentpos: Vector2):
	var distance: int = int(max(abs(currentpos.x - cellpos.x), abs(currentpos.y - cellpos.y)))
	return distance

func check_valid_to_move_cell(cellpos: Vector2):
	var enemies: Array = get_tree().get_nodes_in_group("enemy")
	for i in enemies:
		if cellpos == i.currentCellPOS:
			return false
			break
	
	if (
		tilemapLayer2.get_cell(cellpos.x, cellpos.y) == -1 &&
		tilemapLayer1.get_cell(cellpos.x, cellpos.y) != -1 &&
		cellpos != player.currentCellPOS
	):
		return true
	else:
		return false

func move_enemy_with_animation(to: Vector2, from: Vector2 = global_position):
	currentCellPOS = tilemapLayer1.world_to_map(to)
	tween.interpolate_property(self, "global_position", from, to, 0.25, Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.start()
