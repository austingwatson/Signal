extends State

@export var detection_component: DetectionComponent
@export var a_detection_component: DetectionComponent
@export var character_movement_component: CharacterMovementComponent
@export var animated_sprite: AnimatedSprite2D


func update(_delta) -> void:
	var closest := detection_component.get_closest()
	if closest == null:
		statemachine.enter_state("Idle")
	else:
		var a_closest := a_detection_component.get_closest()
		if a_closest != null:
			character_movement_component.set_direction(Vector2.ZERO)
			statemachine.enter_state("Attack", {"target": a_closest})
		else:
			var dir := (closest.global_position - global_position).normalized()
			character_movement_component.set_direction(dir)
			set_animation(character_movement_component.direction)


func set_animation(dir: Vector2) -> void:
	if dir.y < 0:
		animated_sprite.play("move_up")
	else:
		animated_sprite.play("move")
	if dir.x < 0:
		animated_sprite.flip_h = true
	elif dir.x > 0:
		animated_sprite.flip_h = false
