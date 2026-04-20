extends State

@export var path_finder_component: PathFinderComponent
@export var detection_component: DetectionComponent
@export var character_movement_component: CharacterMovementComponent
@export var animated_sprite: AnimatedSprite2D


func update(_delta: float) -> void:
	var closest := detection_component.get_closest()
	if closest != null:
		statemachine.enter_state("MoveTo")
	else:
		path_finder_component.path_find()
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
