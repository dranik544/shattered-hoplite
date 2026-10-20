extends Camera2D

var lerpZoom: Vector2 = Vector2.ONE * 0.5


func _input(event):
	if event is InputEvent:
		if Input.is_action_pressed("ZOOM_UP"):
			lerpZoom -= Vector2.ONE * 0.02
		elif Input.is_action_pressed("ZOOM_DOWN"):
			lerpZoom += Vector2.ONE * 0.02
		
		lerpZoom.x = clamp(lerpZoom.x, 0.2, 0.9)
		lerpZoom.y = clamp(lerpZoom.y, 0.2, 0.9)

func _process(delta):
	zoom = lerp(zoom, lerpZoom, 5 * delta)
