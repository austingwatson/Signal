extends Node

signal added_metal(amount: int)
signal added_power_cell(amount: int)
signal activate_tower(tower)
signal deactivate_tower(tower)
signal flow_field_done


func call_added_metal(amount: int) -> void:
	added_metal.emit(amount)
	

func call_added_power_cell(amount: int) -> void:
	added_power_cell.emit(amount)
	

func call_activate_tower(tower) -> void:
	activate_tower.emit(tower)
	

func call_deactivate_tower(tower) -> void:
	deactivate_tower.emit(tower)
	

func call_flow_field_done() -> void:
	flow_field_done.emit()
