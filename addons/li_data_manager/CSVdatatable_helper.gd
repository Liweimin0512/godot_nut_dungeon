extends DatatableHelper
class_name CSVDatatableHelper

## 重写加载单一数据表，这里对CSV文件数据行格式化
func load_datatable(table_path: StringName) -> Dictionary:
	var file := FileAccess.open(table_path, FileAccess.READ)
	var ok := FileAccess.get_open_error()
	if ok != OK: push_error("未能正确打开文件！")
	var _file_data : Dictionary = {}
	# CSV数据解析
	var data_names : PackedStringArray = file.get_csv_line(",")					# 第1行是数据名称字段
	var _dec : PackedStringArray = file.get_csv_line(",")						# 第2行是数据注释字段
	var data_types : PackedStringArray = file.get_csv_line(",")					# 第3行是数据类型字段
	while not file.eof_reached():
		var row : PackedStringArray = file.get_csv_line(",")				# 每行的数据，如果为空则跳过
		if row.is_empty(): continue
		var row_data := {}
		for index: int in row.size():
			# 遍历当前行的每一列
			var data_name : StringName = data_names[index]
			if data_name.is_empty(): continue
			var data_type : StringName = data_types[index]
			if data_type.is_empty(): continue
			# row_data[data_name] = row[index]
			row_data[data_name] = _parse_value(row[index], data_type)
		if not row_data.is_empty() and not row_data.ID.is_empty(): 
			_file_data[StringName(row_data.ID)] = row_data
	return _file_data

## 数据格式化
func _parse_value(value: String, type: String) -> Variant:
	if type == "string": return value
	elif type == "int": return value.to_int() if not value.is_empty() else 0
	elif type == "float": return value.to_float() if not value.is_empty() else 0
	elif type == "bool": return bool(value.to_int()) if not value.is_empty() else bool(0)
	elif type == "int[]":
		var ints : Array[int] = []
		Array(value.split("*")).map(func(v: String): ints.append(v.to_int()))
		return ints
	elif type == "float[]":
		var floats : Array[float] = []
		Array(value.split("*")).map(func(v: String): floats.append(v.to_float()))
		return floats
	elif type == "string[]":
		return value.split("*") if not value.is_empty() else []
	elif type == "resource":
		if value.is_empty(): return null
		if ResourceLoader.exists(value): return ResourceLoader.load(value)
		else:
			var error_info : String = "未知的资源类型：" + value
			if OS.has_feature("release"): push_error(error_info)
			else: assert(false, error_info)
			return null
	else:
		var error_info : String = "未知的数据类型：" + value
		if OS.has_feature("release"): push_error(error_info)
		else: assert(false, error_info)
		return null
