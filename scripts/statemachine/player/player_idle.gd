extends State

@export var movement_component: MovementComponent
@export var animated_sprite: AnimatedSprite2D
@export var multi_tool: MultiTool


func enter(_data: Dictionary) -> void:
	movement_component.set_direction(Vector2.ZERO)
	play_idle_animation()
	

func input() -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction != Vector2.ZERO:
		statemachine.enter_state("Move", {"direction": direction})
	else:
		var mouse_dir := (get_global_mouse_position() - global_position)
		if mouse_dir.x < 0:
			animated_sprite.flip_h = true
			multi_tool.facing_direction = -1
		else:
			animated_sprite.flip_h = false
			multi_tool.facing_direction = 1


func play_idle_animation() -> void:
	if animated_sprite.animation == "move":
		animated_sprite.play("idle")
	elif animated_sprite.animation == "move_up":
		animated_sprite.play("idle_up")
