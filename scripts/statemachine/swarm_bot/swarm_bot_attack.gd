extends State

@export var damage: Damage


func enter(data: Dictionary) -> void:
	var target = data["target"]
	await get_tree().create_timer(damage.cooldown).timeout
	statemachine.enter_state("Move")
