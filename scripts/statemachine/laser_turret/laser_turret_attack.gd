extends State

@export var damage: Damage


func enter(data: Dictionary) -> void:
	data["enemy"].take_damage(damage.damage)
	await get_tree().create_timer(damage.cooldown).timeout
	statemachine.enter_state("Idle")
