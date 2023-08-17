extends Control

@onready var test_sound := $Test_Sound
@onready var volume_slider := $CanvasLayer/Sound_Slider
@onready var button_hover_audio : AudioStreamPlayer2D = $Button_Hover

func _ready() -> void:
	volume_slider.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))

func _process(_delta) -> void:
	if Input.is_action_just_pressed("pause"):
		_on_back_pressed()

func _on_back_pressed() -> void:
	Menus.main_menu_selected.emit()
	queue_free()

func _on_sound_slider_value_changed(value) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)

func _on_sound_test_button_pressed() -> void:
	test_sound.play()

func _on_sound_test_button_mouse_entered():
	button_hover_audio.play()

func _on_back_mouse_entered():
	button_hover_audio.play()
