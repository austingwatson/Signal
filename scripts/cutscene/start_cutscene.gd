extends CanvasLayer

@onready var animation_player := $AnimationPlayer


func _ready() -> void:
	GlobalSignals.loading_done.connect(_on_loading_done)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "crash":
		var player := get_tree().get_first_node_in_group("player")
		var spawn_point := get_tree().get_first_node_in_group("spawn_point")
		player.global_position = spawn_point.global_position + Vector2(0, 32)
		queue_free()
	

func _on_loading_done() -> void:
	animation_player.play("crash")
