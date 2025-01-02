extends MarginContainer
class_name W_AbilityResource

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var label: Label = $Label

var _ability_resource : AbilityResource

func setup(ability_resource: AbilityResource) -> void:
	_ability_resource = ability_resource
	_ability_resource.current_value_changed.connect(
		func(value : int) -> void:
			_update_display(value, _ability_resource.max_value)
	)
	_ability_resource.max_value_changed.connect(
		func(value: int, max_value: int) -> void:
			_update_display(value, max_value)
	)
	_update_display(_ability_resource.current_value, _ability_resource.max_value)
	custom_minimum_size.y = _ability_resource.size_y
	var fill : StyleBoxFlat = progress_bar.get_theme_stylebox("fill")
	fill.bg_color = _ability_resource.resource_color
	progress_bar.add_theme_stylebox_override("fill", fill)

func _update_display(value: int, max_value: int) -> void:
	progress_bar.value = value
	progress_bar.max_value = max_value
	label.text = "{0}/{1}".format([value, max_value])
