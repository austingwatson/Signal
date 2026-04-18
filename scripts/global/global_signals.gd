extends Node

signal added_metal(amount: int)
signal added_power_cell(amount: int)


func call_added_metal(amount: int) -> void:
	added_metal.emit(amount)
	

func call_added_power_cell(amount: int) -> void:
	added_power_cell.emit(amount)
