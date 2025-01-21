extends RefCounted
class_name UILocalizationManager

## 当前语言
var current_locale: String:
    set(value):
        if current_locale != value:
            current_locale = value
            _apply_locale(value)
            locale_changed.emit(value)

## 支持的语言列表
var supported_locales: Array[String] = []
## 翻译数据
var _translations: Dictionary = {}
## 本地化资源
var _localized_resources: Dictionary = {}
## 数字格式化配置
var _number_formats: Dictionary = {}
## 日期格式化配置
var _date_formats: Dictionary = {}
## 字体映射
var _font_mappings: Dictionary = {}

signal locale_changed(new_locale: String)
signal translation_loaded(locale: String)

func _init() -> void:
    # 加载默认配置
    load_default_config()
    # 设置初始语言
    current_locale = OS.get_locale()

## 加载默认配置
func load_default_config() -> void:
    # 加载支持的语言
    supported_locales = ["en", "zh_CN", "ja"]
    
    # 加载数字格式化配置
    _number_formats = {
        "en": {
            "decimal_separator": ".",
            "thousands_separator": ",",
            "currency_symbol": "$"
        },
        "zh_CN": {
            "decimal_separator": ".",
            "thousands_separator": ",",
            "currency_symbol": "¥"
        },
        "ja": {
            "decimal_separator": ".",
            "thousands_separator": ",",
            "currency_symbol": "¥"
        }
    }
    
    # 加载日期格式化配置
    _date_formats = {
        "en": {
            "short": "MM/DD/YYYY",
            "medium": "MMM DD, YYYY",
            "long": "MMMM DD, YYYY"
        },
        "zh_CN": {
            "short": "YYYY/MM/DD",
            "medium": "YYYY年MM月DD日",
            "long": "YYYY年MM月DD日"
        },
        "ja": {
            "short": "YYYY/MM/DD",
            "medium": "YYYY年MM月DD日",
            "long": "YYYY年MM月DD日"
        }
    }

## 加载翻译文件
func load_translations(locale: String, file_path: String) -> void:
    var file = FileAccess.open(file_path, FileAccess.READ)
    if file:
        var json = JSON.parse_string(file.get_as_text())
        if json:
            _translations[locale] = json
            translation_loaded.emit(locale)

## 获取翻译文本
func get_translation_str(key: String, params: Dictionary = {}) -> String:
    var translation = _get_translation(key)
    if translation:
        return _format_translation(translation, params)
    return key

## 获取本地化资源
func get_localized_resource(resource_key: String) -> Resource:
    var resources = _localized_resources.get(current_locale, {})
    return resources.get(resource_key)

## 格式化数字
func format_number(number: float, format: String = "default") -> String:
    var locale_format = _number_formats.get(current_locale, _number_formats["en"])
    var formatted = str(number)
    
    match format:
        "currency":
            return locale_format.currency_symbol + formatted
        "percent":
            return formatted + "%"
        _:
            return formatted

## 格式化日期
func format_date(date: Dictionary, format: String = "medium") -> String:
    var locale_format = _date_formats.get(current_locale, _date_formats["en"])
    var pattern = locale_format.get(format, locale_format.medium)
    return _format_date(date, pattern)

## 获取本地化字体
func get_font(font_key: String) -> Font:
    var fonts = _font_mappings.get(current_locale, {})
    return fonts.get(font_key)

func _get_translation(key: String) -> String:
    var translations = _translations.get(current_locale, {})
    return translations.get(key, key)

func _format_translation(text: String, params: Dictionary) -> String:
    var result = text
    for key in params:
        result = result.replace("{" + key + "}", str(params[key]))
    return result

func _format_date(date: Dictionary, pattern: String) -> String:
    # 实现日期格式化逻辑
    return pattern

func _apply_locale(locale: String) -> void:
    # 应用RTL设置
    if locale in ["ar", "he"]:
        _apply_rtl_layout(true)
    else:
        _apply_rtl_layout(false)
    
    # 应用字体
    _apply_fonts(locale)

func _apply_rtl_layout(is_rtl: bool) -> void:
    # 设置UI方向
    for node in UIManager.get_tree().get_nodes_in_group("localizable"):
        if node is Control:
            node.set_layout_direction(
                Control.LAYOUT_DIRECTION_RTL if is_rtl 
                else Control.LAYOUT_DIRECTION_LTR
            )

func _apply_fonts(locale: String) -> void:
    var fonts = _font_mappings.get(locale, {})
    for node in UIManager.get_tree().get_nodes_in_group("localizable"):
        if node is Control and "font_key" in node:
            var font = fonts.get(node.font_key)
            if font:
                node.add_theme_font_override("font", font)