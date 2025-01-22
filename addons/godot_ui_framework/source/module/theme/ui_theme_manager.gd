extends RefCounted
class_name UIThemeManager

## 当前主题名称
var current_theme: String:
	set(value):
		if current_theme != value:
			current_theme = value
			_apply_theme(value)
			theme_changed.emit(value)

## 主题配置
var themes: Dictionary = {}
## 全局样式配置
var global_styles: Dictionary = {}
## 主题资源缓存
var _theme_cache: Dictionary = {}

## 主题变更信号
signal theme_changed(theme_name: String)
signal style_changed(style_name: String, value: Variant)

## 初始化
func _init() -> void:
	# 加载默认主题
	load_default_themes()

## 加载默认主题
func load_default_themes() -> void:
	# 加载内置主题
	var default_theme = {
		"name": "default",
		"colors": {
			"primary": Color(0.2, 0.6, 1.0),
			"secondary": Color(0.4, 0.4, 0.4),
			"background": Color(0.15, 0.15, 0.15),
			"text": Color(1.0, 1.0, 1.0),
			"text_disabled": Color(0.5, 0.5, 0.5)
		},
		"fonts": {
			#"normal": preload("res://default_font.tres"),
			#"bold": preload("res://default_font_bold.tres")
		},
		"metrics": {
			"margin": 10,
			"padding": 5,
			"border_width": 1,
			"corner_radius": 4
		}
	}
	register_theme("default", default_theme)

## 注册新主题
func register_theme(theme_name: String, theme_data: Dictionary) -> void:
	themes[theme_name] = theme_data
	# 创建Theme资源
	var theme = Theme.new()
	_setup_theme_resource(theme, theme_data)
	_theme_cache[theme_name] = theme

## 通过配置注册主题
func register_theme_config(config: ThemeConfig) -> void:
	var theme_data = {
		"name": config.theme_name,
		"colors": config.colors,
		"fonts": config.fonts,
		"metrics": config.metrics,
		"styles": config.styles
	}
	register_theme(config.theme_name, theme_data)

## 从文件加载主题
func load_theme_from_file(path: String) -> void:
	if ResourceLoader.exists(path):
		var config = ResourceLoader.load(path) as ThemeConfig
		if config:
			register_theme_config(config)

## 设置主题资源
func _setup_theme_resource(theme: Theme, theme_data: Dictionary) -> void:
	# 设置颜色
	for color_name in theme_data.colors:
		theme.set_color(color_name, "Global", theme_data.colors[color_name])
	
	# 设置字体
	for font_name in theme_data.fonts:
		theme.set_font(font_name, "Global", theme_data.fonts[font_name])
	
	# 设置常量
	for metric_name in theme_data.metrics:
		theme.set_constant(metric_name, "Global", theme_data.metrics[metric_name])

## 应用主题
func _apply_theme(theme_name: String) -> void:
	if not themes.has(theme_name):
		push_error("Theme not found: " + theme_name)
		return
	
	var theme = _theme_cache[theme_name]
	# 应用到所有UI节点
	_apply_theme_to_node(UIManager.get_tree().root, theme)

## 递归应用主题到节点
func _apply_theme_to_node(node: Node, theme: Theme) -> void:
	if node is Control:
		node.theme = theme
	
	for child in node.get_children():
		_apply_theme_to_node(child, theme)

## 获取主题颜色
func get_color(color_name: String) -> Color:
	var theme_data = themes.get(current_theme, {})
	var colors = theme_data.get("colors", {})
	return colors.get(color_name, Color.WHITE)

## 获取主题字体
func get_font(font_name: String) -> Font:
	var theme_data = themes.get(current_theme, {})
	var fonts = theme_data.get("fonts", {})
	return fonts.get(font_name, null)

## 获取主题度量值
func get_metric(metric_name: String) -> int:
	var theme_data = themes.get(current_theme, {})
	var metrics = theme_data.get("metrics", {})
	return metrics.get(metric_name, 0)

## 设置全局样式
func set_global_style(style_name: String, value: Variant) -> void:
	global_styles[style_name] = value
	style_changed.emit(style_name, value)
