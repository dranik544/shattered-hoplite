extends Control

onready var buttons = $buttons


func _ready():
	Global.connect("inventoryUpdated", self, "_on_updated_inventory")

func _on_updated_inventory():
	var itemNUM: int = 1
	for i in Global.inventory:
		buttons.get_node("Button" + str(itemNUM)).icon = i.itemTexture
		
		itemNUM += 1
