extends Control

@onready var label : Label = $Label
@export var text : String = ""
@export var is_visible := false
func _ready():
	set_text(text)
	visible = is_visible

func set_text(txt : String) -> void:
	label.text = txt
	return
	
func set_label_settings(label_settings : LabelSettings) -> void:
	label.label_settings = label_settings


	
