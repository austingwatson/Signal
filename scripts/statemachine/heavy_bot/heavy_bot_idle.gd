extends State

@export var animated_sprite: AnimatedSprite2D
@export var alert_detection: DetectionComponent
@export var character_movement_component: CharacterMovementComponent
@export var path_finder_component: PathFinderComponent
var ups := ["idle_up", "move_up", "attack_up"]
@onready var timer := $Timer


func enter(_data: Dictionary) -> void:
	character_movement_component.set_direction(Vector2.ZERO)
	
	if ups.has(animated_sprite.animation):
		animated_sprite.play("idle_up")
	else:
		animated_sprite.play("idle")
		
	timer.start()


func update(_delta) -> void:
	if path_finder_component.use_flowfield:
		timer.stop()
		statemachine.enter_state("Move")
	else:
		var closest := alert_detection.get_closest()
		if closest != null:
			timer.stop()
			statemachine.enter_state("MoveTo")


func _on_timer_timeout() -> void:
	timer.stop()
	statemachine.enter_state("Sleep")
