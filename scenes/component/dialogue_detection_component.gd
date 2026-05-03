extends Area2D

signal dialogueTrigger




func _on_area_entered(_area):
	dialogueTrigger.emit()
