extends Node2D

onready var layer_bg = $tilemap/layer_bg
onready var dot = $ysort/hoplite_pl
onready var camera_2d = $Camera2D


func _process(delta):
	camera_2d.global_position = dot.global_position
	
	layer_bg.position += Vector2(0.03, 0.00)
	if layer_bg.position.x >= 16: layer_bg.position = Vector2.ZERO
