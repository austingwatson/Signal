extends State

@export var player: Node2D
@export var movement_component: CharacterMovementComponent
@export var animated_sprite: AnimatedSprite2D
@export var multi_tool: MultiTool


func enter(data: Dictionary) -> void:
	movement_component.set_direction(data["direction"])
	play_move_animation(data["direction"])
	

func input() -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction == Vector2.ZERO:
		statemachine.enter_state("Idle")
	else:
		if movement_component.direction != direction:
			play_move_animation(direction)
		movement_component.set_direction(direction)


func play_move_animation(direction: Vector2) -> void:
	if direction.y < 0:
		animated_sprite.play("move_up")
	else:
		animated_sprite.play("move")
	
	if direction.x < 0:
		animated_sprite.flip_h = true
		multi_tool.facing_direction = -1
	elif direction.x > 0:
		animated_sprite.flip_h = false
		multi_tool.facing_direction = 1
