extends Node2D

onready var tilemap = $tilemap
onready var layer_bg = $tilemap/layer_bg
onready var layer_0 = $tilemap/layer0
onready var layer_1 = $tilemap/layer1
onready var layer_2 = $tilemap/layer2
onready var dot = $dot
onready var camera_2d = $Camera2D
onready var hover = $hover


func _input(event):
	var mouse_pos = get_global_mouse_position()
	var cell_pos = layer_1.world_to_map(mouse_pos)
	var cell_id = layer_1.get_cell(cell_pos.x, cell_pos.y)
	
	hover.global_position = layer_1.map_to_world(cell_pos)
	
	if (
		layer_2.get_cell(cell_pos.x, cell_pos.y) == -1 &&
		layer_1.get_cell(cell_pos.x, cell_pos.y) != -1
	):
		hover.modulate.a = 0.5
		hover.modulate.r = 1.0
		hover.modulate.b = 1.0
		hover.modulate.g = 1.0
	else:
		hover.modulate.a = 0.3
		hover.modulate.r = 1.0
		hover.modulate.b = 0.0
		hover.modulate.g = 0.0
	
	if Input.is_action_just_pressed("CLICK"):
		
		if (
			layer_2.get_cell(cell_pos.x, cell_pos.y) == -1 &&
			layer_1.get_cell(cell_pos.x, cell_pos.y) != -1
		):
			var tween: Tween = Tween.new()
			add_child(tween)
			tween.interpolate_property(dot, "global_position", dot.global_position, layer_1.map_to_world(cell_pos), 0.25, Tween.TRANS_BACK, Tween.EASE_OUT)
			tween.start()
#			dot.global_position = layer_1.map_to_world(cell_pos)


func _process(delta):
	camera_2d.global_position = dot.global_position
	
	layer_bg.position += Vector2(0.1, 0.00)
	if layer_bg.position.x >= 16: layer_bg.position = Vector2.ZERO
