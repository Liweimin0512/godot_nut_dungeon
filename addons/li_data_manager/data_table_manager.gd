extends Node

## 数据表管理器

## 数据表加载器
var _datatable_helper : DatatableHelper = CSVDatatableHelper.new()
## 数据表数据
var _datatable_dics : Dictionary = {}
## 表格模型
var _table_types: Dictionary = {}
## 数据模型
var _model_types: Dictionary = {}
## 数据表加载状态
var _table_completed: Dictionary = {}
## 加载线程
var _thread: Thread

## 加载数据表完成
signal load_completed(datatable_name: String, data: Dictionary)

## 批量加载数据表
func load_datatables(table_types: Array[TableType]) -> void:
	table_types.map(func(type: TableType): _table_completed[type.table_name] = false)
	table_types.map(func(type: TableType): load_datatable(type))

## 加载单一数据表
func load_datatable(table_type: TableType) -> void:
	if _datatable_helper.is_async:
		if not is_instance_valid(_thread): _thread = Thread.new()
		_thread.start(_load_datatable.bind(table_type))
		_thread.wait_to_finish()
	else:
		_load_datatable(table_type)

func _load_datatable(table_type: TableType) -> void:
	if not _table_completed.has(table_type.table_name):
		_table_completed[table_type.table_name] = false
	for table_path in table_type.table_paths:
		if _datatable_dics.has(table_path): continue
		_datatable_dics[table_path] = _datatable_helper.load_datatable(table_path)
	_table_types[table_type.table_name] = table_type
	_table_completed[table_type.table_name] = true
	call_deferred_thread_group(
		"emit_signal", 
		"load_completed", 
		table_type.table_name
		)

## 是否全部数据表载完成
func is_all_completed() -> bool:
	for table in _table_completed:
		if _table_completed[table] == false:
			return false
	return true

## 获取数据表行
func get_datatable_row(table_name : StringName, row_id : StringName) -> Dictionary:
	'''
	获取数据表行
	'''
	assert(not row_id.is_empty() and not table_name.is_empty())
	if not _table_types.has(table_name):
		push_error("can not found data by row id: ", row_id, " in datatable: ", table_name)
		return {}
	var table_type: TableType = _table_types[table_name]
	var data: Dictionary = {}
	for path : String in table_type.table_paths:
		if not _datatable_dics[path].has(row_id): continue
		var row : Dictionary = _datatable_dics[path][row_id]
		if not row.is_empty(): data.merge(row)
	return data

## 获取数据表全部数据
func get_datatable_all(table_name: StringName) -> Dictionary:
	var data := {}
	var table_type: TableType = _table_types[table_name]
	for table_path : String in table_type.table_paths:
		if _datatable_dics.has(table_path):
			data.merge(_datatable_dics[table_path])
	return data

#region 据模型相关

## 批量加载数据模型
func load_data_models(model_types: Array[ModelType]) -> void:
	for model_type: ModelType in model_types:
		load_data_model(model_type)

## 加载数据模型
func load_data_model(model_type: ModelType) -> void:
	_model_types[model_type.model_name] = model_type
	load_datatables(model_type.tables)

## 获取数据模型
func get_data_model(model_name: StringName, dataID : StringName) -> Resource:
	var model_type : ModelType = _model_types[model_name]
	var data : Dictionary = {}
	for table_type : TableType in model_type.tables:
		var row_data := get_datatable_row(table_type.table_name, dataID)
		if not row_data.is_empty(): 
			data = row_data
			break
	if data.is_empty() : return null
	var model : Resource = _create_model(model_type.model_script, data)
	return model

## 获取全部数据型
func get_data_models(model_name: StringName) -> Array[Resource]:
	var model_type : ModelType = _model_types[model_name]
	var models: Array[Resource]
	for table_type: TableType in model_type.tables:
		for data : Dictionary in get_datatable_all(table_type.table_name).values():
			var model := _create_model(model_type.model_script, data)
			models.append(model)
	return models

## 数据初始化
func _create_model(model_scrit: GDScript, data : Dictionary) -> Resource:
	var model : Resource = model_scrit.new()
	data.keys().map(
		func(key: String):
			model.set(key, data[key])
	)
	if model.has_method("_ready"): model.call("_ready", data)
	return model

#endregion
