extends State

@export var detection_component: DetectionComponent
@export var path_finder_component: PathFinderComponent
@export var character_movement_component: CharacterMovementComponent
@export var animated_sprite: AnimatedSprite2D


func enter(_data: Dictionary) -> void:
	character_movement_component.set_direction(Vector2.ZERO)
	animated_sprite.stop()


func update(_delta) -> void:
	if path_finder_component.use_flowfield:
		statemachine.enter_state("Move")
	else:
		var closest := detection_component.get_closest()
		if closest != null:
			statemachine.enter_state("MoveTo")
