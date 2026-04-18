extends State

@export var player: Node2D
@export var movement: Movement


func enter(data: Dictionary) -> void:
	movement.set_direction(data["direction"])
	

func input() -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction == Vector2.ZERO:
		statemachine.enter_state("Idle")
	else:
		movement.set_direction(direction)
		

func update(delta: float) -> void:
	player.global_position = movement.move(player.global_position, delta)
