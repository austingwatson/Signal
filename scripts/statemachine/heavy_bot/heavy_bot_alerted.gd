extends State

@export var damage: Damage
@export var animated_sprite: AnimatedSprite2D
@export var detection_component: DetectionComponent
@onready var timer := $Timer


func enter(_data: Dictionary) -> void:
	animated_sprite.play("alert")
	timer.start(damage.alert_timer)
	

func update(_delta: float) -> void:
	var closest: HurtBox = detection_component.get_closest()
	if closest != null:
		statemachine.enter_state("Idle")


func _on_timer_timeout() -> void:
	timer.stop()
	statemachine.enter_state("Idle")
