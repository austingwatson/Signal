extends State

@export var tower: SignalTower


func enter(_data: Dictionary) -> void:
	GlobalSignals.call_activate_tower(tower)	
