extends Node2D

onready var tilemap = $tilemap
onready var layer_bg = $tilemap/layer_bg
onready var layer_0 = $tilemap/layer0
onready var layer_1 = $tilemap/layer1
onready var layer_2 = $tilemap/layer2
onready var dot = $hoplite_pl
onready var camera_2d = $Camera2D


func _process(delta):
	camera_2d.global_position = dot.global_position
	
	layer_bg.position += Vector2(0.04, 0.00)
	if layer_bg.position.x >= 16: layer_bg.position = Vector2.ZERO
