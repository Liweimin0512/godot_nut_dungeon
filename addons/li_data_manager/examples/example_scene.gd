extends Control

## 数据模型
const ItemModel = preload("res://addons/li_data_manager/examples/scripts/resource/item_model.gd")
const PlayerModel = preload("res://addons/li_data_manager/examples/scripts/resource/player_model.gd")

## 数据表路径
const TEST_CSV_PATH = "res://addons/li_data_manager/examples/data_table/test_data.csv"
const TEST_JSON_PATH = "res://addons/li_data_manager/examples/data_table/test_data.json"

## UI 组件
@onready var test_output : RichTextLabel = %TestOutput

@export var _model_types : Array[ModelType]

func _ready() -> void:
	# 连接信号
	DataManager.load_completed.connect(_on_load_completed)
	DataManager.batch_load_completed.connect(_on_batch_load_completed)
	
	# 输出初始信息
	_print_test_info("数据管理器测试")
	_print_test_info("点击按钮开始测试...")

## 加载完成回调
func _on_load_completed(table_name: String) -> void:
	_print_test_info("\n表格加载完成: %s" % table_name)
	var data = DataManager.get_table_data(table_name)
	_print_table_data(table_name, data)

## 批量加载完成回调
func _on_batch_load_completed(loaded_tables: Array[String]) -> void:
	_print_test_info("\n批量加载完成!")
	_print_test_info("已加载表格: {0}".format([loaded_tables]))

## 输出测试信息
func _print_test_info(text: String) -> void:
	if test_output:
		test_output.append_text("[{0}]{1}\n".format([Time.get_unix_time_from_system(), text]))

## 打印表格数据
func _print_table_data(table_name: String, data: Dictionary) -> void:
	if data == null:
		_print_test_info("[color=yellow]警告: 表格数据为空: %s[/color]" % table_name)
		return
		
	_print_test_info("\n=== 表格内容: %s ===" % table_name)
	for key in data:
		var value = data[key]
		if typeof(value) == TYPE_ARRAY:
			value = ""
			for v in data[key]:
				value += v + " "
		_print_test_info("{0}: {1}".format([key, value]))

## 测试数据模型的方法
func _test_model_methods() -> void:
	_print_test_info("\n=== 测试数据模型方法 ===")
	
	# 测试玩家模型方法
	var player_models := DataManager.get_all_data_models("player")
	for player : PlayerModel in player_models:
		_print_test_info("\n玩家模型方法测试 (player_1):")
		_print_test_info("- 攻击力: %d" % player.get_attack())
		_print_test_info("- 防御力: %d" % player.get_defense())
		_print_test_info("- 速度: %d" % player.get_speed())
	
	# 测试物品模型方法
	var item_models := DataManager.get_all_data_models("item")
	var sword : ItemModel = DataManager.get_data_model("item", "sword_1") 
	if sword:
		_print_test_info("\n物品模型方法测试 (sword_1):")
		_print_test_info("- 是否武器: %s" % sword.is_weapon())
		_print_test_info("- 是否防具: %s" % sword.is_shield())
		_print_test_info("- 主属性值: %d" % sword.get_main_property())
		_print_test_info("- 是否有'武器'标签: %s" % sword.has_tag("武器"))
		
	var shield : ItemModel = DataManager.get_data_model("item", "shield_1")
	if shield:
		_print_test_info("\n物品模型方法测试 (shield_1):")
		_print_test_info("- 是否武器: %s" % shield.is_weapon())
		_print_test_info("- 是否防具: %s" % shield.is_shield())
		_print_test_info("- 主属性值: %d" % shield.get_main_property())
		_print_test_info("- 是否有'防具'标签: %s" % shield.has_tag("防具"))

func _on_sync_test_btn_pressed() -> void:
	_print_test_info("\n=== 开始同步加载测试 ===")
	
	# 配置为同步加载
	DataManager.enable_thread = false
	# 同步加载
	DataManager.load_models(_model_types)
	
	# 输出加载结果
	_print_test_info("\n同步加载完成！")
	for model_type in _model_types:
		var table_name : String = model_type.table.table_name
		var models : Array = DataManager.get_all_data_models(model_type.model_name)
		for model in models:
			var data : Dictionary = DataManager.get_table_item(table_name, model.id)
			_print_table_data(table_name, data)
	_test_model_methods()

func _on_async_test_btn_pressed() -> void:
	_print_test_info("\n=== 开始异步加载测试 ===")
	
	# 配置为异步加载
	DataManager.enable_thread = true
	
	# 异步加载
	DataManager.load_models(_model_types, func(loaded_tables: Array[String]):
		_print_test_info("\n异步加载完成回调!")
		_print_test_info("已加载表格:{0}".format([loaded_tables]))
		# 测试数据模型方法
		_test_model_methods()
	)

func _on_clear_btn_pressed() -> void:
	_print_test_info("\n=== 清理测试数据 ===")
	DataManager.clear_model_types()
	DataManager.clear_table_types()
	test_output.text = ""
	_print_test_info("数据已清理!")
	_print_test_info("点击按钮开始新的测试...")
