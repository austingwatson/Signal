class_name DetectionComponent
extends Area2D

@export var damage: Damage
@export var use_attack_range := false
@export var use_alert_range := false
@export_flags_2d_physics var los_collision_mask := 0
var hurt_boxes: Array[HurtBox] = []
var params := PhysicsRayQueryParameters2D.new()


func _ready() -> void:
	if use_attack_range:
		$CollisionShape2D.shape.radius = damage.attack_range
	elif use_alert_range:
		$CollisionShape2D.shape.radius = damage.alert_range
	else:
		$CollisionShape2D.shape.radius = damage.detection_range
	params.collision_mask = los_collision_mask


func get_closest() -> HurtBox:
	var closest = null
	var dis := INF
	
	for hurt_box in hurt_boxes:
		var distance = global_position.distance_to(hurt_box.global_position)
		if distance < dis and has_line_of_sight(hurt_box):
			closest = hurt_box
			dis = distance
	
	return closest
	

func enable() -> void:
	$CollisionShape2D.set_deferred("disabled", false)
	

func disable() -> void:
	$CollisionShape2D.set_deferred("disabled", true)
	

func get_multi_closest(amount: int) -> Array[HurtBox]:
	var closest: Array[HurtBox] = []
	
	hurt_boxes.sort_custom(func(a, b):
		var dis_a := global_position.distance_to(a.global_position)
		var dis_b := global_position.distance_to(b.global_position)
		return dis_a < dis_b)
		
	for hurt_box in hurt_boxes:
		if has_line_of_sight(hurt_box) and in_angle_allowed(hurt_box):
			closest.append(hurt_box)
		if closest.size() == amount:
			break
	
	return closest
	
	
func get_all_in_los() -> Array[HurtBox]:
	var array: Array[HurtBox] = []
	
	for hurt_box in hurt_boxes:
		if has_line_of_sight(hurt_box):
			array.append(hurt_box)
	
	return array

func has_line_of_sight(enemy) -> bool:
	var space := get_world_2d().direct_space_state
	params.from = global_position
	params.to = enemy.global_position
	var result := space.intersect_ray(params)
	
	if result.is_empty():
		return true
	else:
		return false
		

func in_angle_allowed(enemy) -> bool:
	var to_enemy = (enemy.global_position - global_position).normalized()
	var forward = Vector2.RIGHT.rotated(rotation)
	var dot = forward.dot(to_enemy)
	
	return dot >= cos(damage.attack_angle)


func _on_area_entered(area: Area2D) -> void:
	if area is HurtBox:
		hurt_boxes.append(area)


func _on_area_exited(area: Area2D) -> void:
	if area is HurtBox:
		hurt_boxes.erase(area)
