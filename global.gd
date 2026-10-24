extends Node

var turn: bool = true   # true - игрок ходит, false - враги ходят
var inventory: Array = []
var maxInventorySlots: int = 8

signal enemyTurn


func _add_item_to_inventory(item: Node2D):
	if maxInventorySlots >= inventory.size(): return
	
	inventory.append(item)

func remove_item_from_inventory(item: Node2D):
	inventory.remove(inventory.find(item))
