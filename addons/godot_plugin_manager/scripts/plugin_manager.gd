@tool
extends Control

const ADDONS_PATH = "res://addons"

var _plugin_info: Dictionary = {}
var _dependency_graph: Dictionary = {}

func _ready() -> void:
	scan_plugins()
	update_ui()

func scan_plugins() -> void:
	_plugin_info.clear()
	_dependency_graph.clear()
	
	var dir = DirAccess.open(ADDONS_PATH)
	if not dir:
		printerr("Failed to open addons directory")
		return
	
	dir.list_dir_begin()
	var plugin_dir = dir.get_next()
	
	while plugin_dir != "":
		if dir.current_is_dir() and not plugin_dir.begins_with("."):
			var plugin_cfg_path = ADDONS_PATH.path_join(plugin_dir).path_join("plugin.cfg")
			if FileAccess.file_exists(plugin_cfg_path):
				var plugin_data = _read_plugin_config(plugin_cfg_path)
				if plugin_data:
					_plugin_info[plugin_dir] = plugin_data
					# 构建依赖图
					if plugin_data.has("dependencies"):
						_dependency_graph[plugin_dir] = plugin_data["dependencies"].keys()
		plugin_dir = dir.get_next()

func _read_plugin_config(config_path: String) -> Dictionary:
	var config = ConfigFile.new()
	var err = config.load(config_path)
	if err != OK:
		printerr("Failed to load plugin config: ", config_path)
		return {}
	
	var plugin_data = {
		"name": config.get_value("plugin", "name", ""),
		"description": config.get_value("plugin", "description", ""),
		"author": config.get_value("plugin", "author", ""),
		"version": config.get_value("plugin", "version", "1.0.0"),
		"script": config.get_value("plugin", "script", ""),
		"dependencies": {
			"required": {},
			"optional": {}
		}
	}
	
	if config.has_section("dependencies"):
		if config.has_section_key("dependencies", "required"):
			plugin_data["dependencies"]["required"] = _parse_dependency_dict(
				config.get_value("dependencies", "required", {})
			)
		if config.has_section_key("dependencies", "optional"):
			plugin_data["dependencies"]["optional"] = _parse_dependency_dict(
				config.get_value("dependencies", "optional", {})
			)
	
	return plugin_data

func _parse_dependency_dict(dep_str: String) -> Dictionary:
	# 移除花括号并分割成键值对
	dep_str = dep_str.strip_edges()
	if dep_str.begins_with("{"): dep_str = dep_str.substr(1)
	if dep_str.ends_with("}"): dep_str = dep_str.substr(0, dep_str.length() - 1)
	
	var result = {}
	var pairs = dep_str.split(",")
	for pair in pairs:
		pair = pair.strip_edges()
		if pair.is_empty(): continue
		var kv = pair.split(":")
		if kv.size() != 2: continue
		var key = kv[0].strip_edges().trim_quotes()
		var value = kv[1].strip_edges().trim_quotes()
		result[key] = value
	
	return result

func install_all_dependencies() -> void:
	var missing_deps = check_missing_dependencies()
	if missing_deps.is_empty():
		print("All dependencies are satisfied!")
		return
	
	print("Installing missing dependencies...")
	for plugin_name in missing_deps:
		var url = missing_deps[plugin_name]
		install_plugin(plugin_name, url)

func check_missing_dependencies() -> Dictionary:
	var missing = {}
	
	for plugin_name in _plugin_info:
		var plugin_data = _plugin_info[plugin_name]
		if plugin_data.has("dependencies"):
			for dep_name in plugin_data["dependencies"].keys():
				for dep_type in plugin_data["dependencies"][dep_name].keys():
					if not _plugin_info.has(dep_name):
						missing[dep_name] = plugin_data["dependencies"][dep_name][dep_type]
	
	return missing

func install_plugin(plugin_name: String, url: String) -> void:
	print("Installing plugin: ", plugin_name, " from ", url)
	
	# 解析URL和版本
	var parts = url.split("#")
	var repo_url = parts[0]
	var version = parts[1] if parts.size() > 1 else ""
	
	if repo_url.begins_with("https://github.com"):
		_install_from_github(plugin_name, repo_url, version)
	else:
		_install_from_url(plugin_name, url)

func _install_from_github(plugin_name: String, repo_url: String, version: String) -> void:
	var target_dir = ADDONS_PATH.path_join(plugin_name)
	
	# 如果指定了版本，使用特定版本
	if not version.is_empty():
		if version.begins_with("^"):
			# 处理语义化版本范围
			version = version.substr(1)
		repo_url += "#" + version
	
	var output = []
	var exit_code = OS.execute("git", [
		"submodule",
		"add",
		repo_url,
		ProjectSettings.globalize_path(target_dir)
	], output)
	
	if exit_code != 0:
		printerr("Failed to install plugin from GitHub: ", output)
		return
	
	print("Successfully installed plugin: ", plugin_name)
	scan_plugins()
	update_ui()

func _install_from_url(plugin_name: String, url: String) -> void:
	# 实现从其他URL下载插件的逻辑
	# 可以使用HTTPRequest或其他方式
	pass

func get_plugin_info(plugin_name: String) -> Dictionary:
	return _plugin_info.get(plugin_name, {})

func check_updates() -> Array:
	var updates = []
	for plugin_name in _plugin_info:
		if _has_update_available(plugin_name):
			updates.append(plugin_name)
	return updates

func _has_update_available(plugin_name: String) -> bool:
	var plugin_data = _plugin_info.get(plugin_name)
	if not plugin_data or not plugin_data.has("dependencies"):
		return false
	
	for dep_name in plugin_data["dependencies"].keys():
		for dep_type in plugin_data["dependencies"][dep_name].keys():
			var url = plugin_data["dependencies"][dep_name][dep_type]
			# 检查GitHub release或其他来源的最新版本
			# 这需要实现具体的版本检查逻辑
	return false

func update_ui() -> void:
	# 更新UI显示
	$VBoxContainer/PluginList.clear()
	
	for plugin_name in _plugin_info:
		var plugin_data = _plugin_info[plugin_name]
		$VBoxContainer/PluginList.add_item(
			"%s v%s" % [plugin_data["name"], plugin_data["version"]]
		)

func _on_check_dependencies_pressed() -> void:
	var missing = check_missing_dependencies()
	if missing.is_empty():
		$VBoxContainer/StatusBar/StatusLabel.text = "All dependencies are satisfied!"
	else:
		var deps = missing.keys()
		$VBoxContainer/StatusBar/StatusLabel.text = "Missing dependencies: " + ", ".join(deps)

func _on_install_dependencies_pressed() -> void:
	install_all_dependencies()

func _on_plugin_list_item_selected(index: int) -> void:
	var plugin_name = _plugin_info.keys()[index]
	var plugin_data = _plugin_info[plugin_name]
	
	var details = $VBoxContainer/HSplitContainer/PluginDetails
	details.get_node("NameLabel").text = "Name: " + plugin_data["name"]
	details.get_node("VersionLabel").text = "Version: " + plugin_data["version"]
	details.get_node("AuthorLabel").text = "Author: " + plugin_data["author"]
	
	var deps_list = details.get_node("DependenciesList")
	deps_list.clear()
	if plugin_data.has("dependencies"):
		for dep_name in plugin_data["dependencies"].keys():
			for dep_type in plugin_data["dependencies"][dep_name].keys():
				deps_list.add_item(dep_name + " -> " + plugin_data["dependencies"][dep_name][dep_type])
