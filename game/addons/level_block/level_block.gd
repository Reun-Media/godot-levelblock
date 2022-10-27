tool
extends EditorPlugin

const Icon = preload("res://addons/level_block/icon.svg")
const BlockNode = preload("res://addons/level_block/level_block_node.gd")
const GizmoPlugin = preload("res://addons/level_block/level_block_gizmo.gd")

var gizmo_plugin = GizmoPlugin.new()

func _enter_tree():
	add_custom_type("LevelBlock", "Spatial", BlockNode, Icon)
	add_spatial_gizmo_plugin(gizmo_plugin)

func _exit_tree():
	remove_custom_type("LevelBlock")
	remove_spatial_gizmo_plugin(gizmo_plugin)
