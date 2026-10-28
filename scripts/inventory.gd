extends Control

onready var buttons = $buttons
onready var owindow = $"../owindow"


func _ready():
	Global.connect("inventoryUpdated", self, "_on_updated_inventory")
	_on_updated_inventory()

func _on_updated_inventory():
	var itemNUM: int = 1
	
	for i in buttons.get_children():
		i.icon = null
		i.remove_meta("itemData")
	
	for i in Global.inventory:
		var button: Button = buttons.get_node("Button" + str(itemNUM))
		
		button.icon = i.itemTexture
		button.set_meta("itemData", i)
		
		if button.is_connected("pressed", self, "_on_button_pressed"):
			button.disconnect("pressed", self, "_on_button_pressed")
		button.connect("pressed", self, "_on_button_pressed", [itemNUM])
		
		itemNUM += 1

func _on_button_pressed(itemNUM: int = -1):
	if itemNUM == -1: return
	
	var button: Button = buttons.get_node("Button" + str(itemNUM))
	print(button)
	if button.has_meta("itemData"):
		owindow.edit_owindow(
			button.get_meta("itemData").itemName,
			button.get_meta("itemData").itemDesc,
			button.get_meta("itemData").itemTexture,
			true,
			true,
			true
		)
