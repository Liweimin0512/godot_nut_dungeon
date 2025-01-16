extends Resource
class_name AbilityAttributeSet

@export var attributes : Array[AbilityAttribute]

func _ready(config: Dictionary) -> void:
	for key in config:
		var value = config[key]
		if key == "ID":
			continue
		if key == "character_name":
			continue
		var atr : AbilityAttribute = DatatableManager.get_data_model("ability_attribute", key)
		atr.attribute_id = key
		atr.base_value = value
		attributes.append(atr)
