extends State

@export var interactable_component: InteractableComponent
@export var sprite: Sprite2D
@export var interact_positive_sound: AudioStreamPlayer
@export var collision_shape: CollisionShape2D
#@export var collision_shape: 
var in_state := false


func enter(_data: Dictionary) -> void:
	sprite.frame = 1
	await get_tree().create_timer(0.25).timeout
	in_state = true
	collision_shape.set_deferred("disabled", false)


func _on_interactable_component_interacted() -> void:
	if not in_state:
		return
	
	in_state = false
	interact_positive_sound.play()
	statemachine.enter_state("Activating")
