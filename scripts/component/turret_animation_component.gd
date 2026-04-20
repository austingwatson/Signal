class_name TurretAnimationComponent
extends Node2D

@export var base_frame := 0
@export var gun_frame := 0
@onready var base := $Base
@onready var gun := $Gun


func _ready() -> void:
	base.frame = base_frame
	gun.frame = gun_frame
	

func set_dir(dir: Vector2i) -> void:
	if dir == Vector2i.ZERO:
		return
	
	var angle := atan2(dir.y, dir.x)
	var octant := int(round(angle / (PI / 4.0))) % 8
	if octant < 0:
		octant += 8
		
	gun.frame = gun_frame + octant
	

func not_attacking() -> void:
	base.frame = base_frame
	

func attacking() -> void:
	base.frame = base_frame + 1
