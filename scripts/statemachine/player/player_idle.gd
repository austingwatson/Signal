extends State

@export var movement: Movement


func enter(_data: Dictionary) -> void:
	movement.set_direction(Vector2.ZERO)
	

func input() -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction != Vector2.ZERO:
		statemachine.enter_state("Move", {"direction": direction})
