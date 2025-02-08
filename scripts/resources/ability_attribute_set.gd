extends Resource
class_name AbilityAttributeSet

@export var attributes : Array[AbilityAttribute]

func _init_from_data(data: Dictionary) -> void:
	for key in data:
		var value = data[key]
		if key == "ID":
			continue
		if key == "character_name":
			continue
		var atr : AbilityAttribute = DataManager.get_data_model("ability_attribute", key)
		atr.attribute_id = key
		atr.base_value = value
		attributes.append(atr)