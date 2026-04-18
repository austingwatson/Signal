extends State

@export var player: Node2D
@export var movement_component: MovementComponent


func enter(data: Dictionary) -> void:
	movement_component.set_direction(data["direction"])
	

func input() -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction == Vector2.ZERO:
		statemachine.enter_state("Idle")
	else:
		movement_component.set_direction(direction)
