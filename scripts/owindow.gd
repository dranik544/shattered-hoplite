extends Control

onready var object_texture_texturerect = $vbox/objectTextureAndName/objectTexture
onready var object_name_label = $vbox/objectTextureAndName/objectName
onready var object_desc_label = $vbox/objectDesc
onready var drop_button = $vbox/buttons/dropButton
onready var use_button = $vbox/buttons/useButton


func _ready():
	edit_owindow(
		"1",
		"2\n32\n32\n32\n32\n32\n32\n32\n32\n32\nn32\n32\n32\n3",
		null,
		true,
		true
	)

func edit_owindow(
		objectName: String,
		objectDesc: String,
		objectTexture: Texture,
		
		enable_dropButton: bool = true,
		enable_useButton: bool = true
		
	):
		rect_size.y = rect_min_size.y + object_desc_label.rect_size.y
		set_anchors_and_margins_preset(Control.PRESET_CENTER)
		rect_size.y = rect_min_size.y + object_desc_label.rect_size.y
