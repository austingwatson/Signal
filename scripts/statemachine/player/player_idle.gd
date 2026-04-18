extends State

@export var movement_component: MovementComponent


func enter() -> void:
	movement_component.set_direction(Vector2.ZERO)


func input() -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction != Vector2.ZERO:
		movement_component.set_direction(direction)
		statemachine.enter_state("Move")
