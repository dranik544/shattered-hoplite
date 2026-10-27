extends Control

onready var buttons = $buttons


func _ready():
	Global.connect("inventoryUpdated", self, "_on_updated_inventory")

func _on_updated_inventory():
	var itemNUM: int = 1
	for i in Global.inventory:
		var button: Button = buttons.get_node("Button" + str(itemNUM))
		
		button.icon = i.itemTexture
		button.set_meta("itemScenePath", i.itemScenePath)
		if button.is_connected("pressed", self, "_on_button_pressed"):
			button.disconnect("pressed", self, "_on_button_pressed")
		
		button.connect("pressed", self, "_on_button_pressed", [itemNUM])
		
		itemNUM += 1

func _on_button_pressed(itemNUM: int = -1):
	if itemNUM == 1: return
	
	
