extends GutTest

var ui_manager

func before_each():
	ui_manager = preload("res://addons/godot_ui_framework/source/ui_manager.gd").new()
	add_child_autofree(ui_manager)

func test_ui_manager_initialization():
	assert_not_null(ui_manager)
	assert_true(ui_manager is Node)

func test_show_window():
	var window_id = ui_manager.show_window("test_window", {})
	assert_not_null(window_id)
	assert_true(ui_manager.is_window_visible(window_id))

func test_hide_window():
	var window_id = ui_manager.show_window("test_window", {})
	ui_manager.hide_window(window_id)
	assert_false(ui_manager.is_window_visible(window_id))

func test_window_stack():
	var window1 = ui_manager.show_window("window1", {})
	var window2 = ui_manager.show_window("window2", {})
	assert_true(ui_manager.get_window_stack_count() == 2)
	ui_manager.hide_window(window2)
	assert_true(ui_manager.get_window_stack_count() == 1)
