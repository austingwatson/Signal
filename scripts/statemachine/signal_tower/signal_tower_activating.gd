extends State

@export var tower: SignalTower
@export var sprite: Sprite2D
@export var timer := 5.0


func enter(_data: Dictionary) -> void:
	sprite.frame = 2
	#GlobalSignals.flow_field_done.connect(_on_flowfield_done)
	GlobalSignals.call_activate_tower(tower)
	await get_tree().create_timer(timer).timeout
	statemachine.enter_state("Activated")


func _on_flowfield_done() -> void:
	#GlobalSignals.flow_field_done.disconnect(_on_flowfield_done)
	#statemachine.enter_state("Activated")
	pass
