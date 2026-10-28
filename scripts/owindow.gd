extends Control

onready var bg = $bg
onready var vbox = $vbox
onready var object_texture_texturerect = $vbox/objectTextureAndName/objectTexture
onready var object_name_label = $vbox/objectTextureAndName/objectName
onready var object_desc_label = $vbox/objectDesc

onready var close_button = $vbox/buttons/closeButton
onready var drop_button = $vbox/buttons/dropButton
onready var use_button = $vbox/buttons/useButton


func _ready():
	close_button.connect("pressed", self, "_on_close_button_pressed")
	edit_owindow("", "", null, false, false, false)

func edit_owindow(objectName: String, objectDesc: String, objectTexture: Texture = null, show: bool = true, enable_dropButton: bool = true, enable_useButton: bool = true):
	visible = false
	
	object_name_label.text = objectName
	object_desc_label.bbcode_text = objectDesc
	object_texture_texturerect.texture = objectTexture
	object_texture_texturerect.visible = true if objectTexture else false
	
	drop_button.visible = enable_dropButton
	use_button.visible = enable_useButton
	
	yield(get_tree(), "idle_frame")
	
	visible = show
	
	rect_size.y = vbox.get_combined_minimum_size().y
	rect_position.y = get_viewport_rect().size.y /2 - vbox.get_combined_minimum_size().y / 2


func _on_close_button_pressed():
	visible = false
