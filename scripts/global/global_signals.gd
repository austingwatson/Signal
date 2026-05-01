extends Node

signal added_metal(amount: int)
signal added_power_cell(amount: int)
signal activate_tower(tower)
signal deactivate_tower(tower)
signal flow_field_done
signal ping_changed(distance: float, angle: float)
signal loading_done
signal player_health_changed(health: int, max_health: int)


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
	

func call_ping_changed(distance: float, angle: float) -> void:
	ping_changed.emit(distance, angle)
	

func call_loading_done() -> void:
	loading_done.emit()
	

func call_player_health_changed(health: int, max_health: int) -> void:
	player_health_changed.emit(health, max_health)
