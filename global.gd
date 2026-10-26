extends Node

var turn: bool = true   # true - игрок ходит, false - враги ходят
var inventory: Array = []
var maxInventorySlots: int = 20

signal enemyTurn
signal inventoryUpdated


# template:
# 	var info: Dictionary = {
# 		"itemName": itemName,
# 		"itemTexture": sprite.texture,
# 		"itemScenePath": filename
# 	}
func add_item_to_inventory(item: Dictionary):
	if maxInventorySlots <= inventory.size(): return
	
	inventory.append(item)
	emit_signal("inventoryUpdated")

func remove_item_from_inventory(item: Node2D):
	inventory.remove(inventory.find(item))
	emit_signal("inventoryUpdated")
