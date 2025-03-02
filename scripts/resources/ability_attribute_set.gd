extends Resource
class_name AbilityAttributeSet

@export var attributes : Array[AbilityAttribute]

func _init_from_data(data: Dictionary) -> void:
	for key in data:
		var value = data[key]
		if key == "ID" or key == "character_name":
			continue
		var atr : AbilityAttribute = DataManager.get_data_model("ability_attribute", key)
		if not atr:
			GASLogger.error("atr is null, cant set atr by atr id: %s" %key)
			return
		atr.attribute_id = key
		atr.base_value = value
		attributes.append(atr)
