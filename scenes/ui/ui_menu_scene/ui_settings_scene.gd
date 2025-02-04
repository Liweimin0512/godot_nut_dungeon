extends Control

@onready var _button_back = %ButtonBack
@onready var _music_slider = %MusicSlider
@onready var _sound_slider = %SoundSlider

func _ready() -> void:
	_button_back.pressed.connect(_on_button_back_pressed)
	_music_slider.value_changed.connect(_on_music_volume_changed)
	_sound_slider.value_changed.connect(_on_sound_volume_changed)
	
	# TODO: 从配置中加载音量设置
	_music_slider.value = 1.0
	_sound_slider.value = 1.0

func _on_button_back_pressed() -> void:
	queue_free()

func _on_music_volume_changed(_value: float) -> void:
	# TODO: 保存音乐音量设置
	pass

func _on_sound_volume_changed(_value: float) -> void:
	# TODO: 保存音效音量设置
	pass
