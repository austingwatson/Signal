extends Control

@onready var health_bar := $HealthBar


func _ready() -> void:
	GlobalSignals.player_health_changed.connect(_on_player_health_changed)
	

func _on_player_health_changed(health: int, max_health: int) -> void:
	health_bar.max_value = max_health
	health_bar.value = health
