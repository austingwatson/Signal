extends Control

signal dialogue_finished

@export var icon_texture: Texture2D
@onready var icon := $HBoxContainer/Icon
@onready var label := $HBoxContainer/Label
@onready var alienchatter := $AlienChatter
@onready var talkinghead := $TalkingHead

var dialogue: Dialogue
var index := 0


func _ready() -> void:
	visible = false
	icon.texture = icon_texture


func start(dialogue: Dialogue) -> void:
	self.dialogue = dialogue
	index = 0
	visible = true
	show_line()
	

func show_line() -> void:
	if index >= dialogue.lines.size():
		finish()
		return
	
	var line = dialogue.lines[index]
	label.text = line.text
	
	alienchatter.play()
	
	auto_advance(line.delay)
	

func auto_advance(delay: float) -> void:
	await get_tree().create_timer(delay).timeout
	index += 1
	show_line()
	

func finish() -> void:
	visible = false
	dialogue_finished.emit()
