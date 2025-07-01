@tool
extends EditorPlugin

const DEERS_TIMER_PANEL_CONTAINER = preload("res://addons/deers_time_plugin/ui/deers_timer_panel_container.tscn")
var deers_timer_panel_container

func _enter_tree() -> void:
	deers_timer_panel_container = DEERS_TIMER_PANEL_CONTAINER.instantiate()
	get_editor_interface().get_base_control().get_child(0).get_child(0).get_child(1).add_child(deers_timer_panel_container)

func _exit_tree() -> void:
	deers_timer_panel_container.queue_free()
