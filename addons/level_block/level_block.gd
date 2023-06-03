@tool
extends EditorPlugin

const Icon = preload("res://addons/level_block/icon.svg")
const BlockNode = preload("res://addons/level_block/level_block_node.gd")
const GizmoPlugin = preload("res://addons/level_block/level_block_gizmo.gd")
const InspectorPlugin = preload("res://addons/level_block/level_block_inspector.gd")

var gizmo_plugin = GizmoPlugin.new()
var inspector_plugin = InspectorPlugin.new()

func _enter_tree():
	add_custom_type("LevelBlock", "Node3D", BlockNode, Icon)
	add_node_3d_gizmo_plugin(gizmo_plugin)
	add_inspector_plugin(inspector_plugin)

func _exit_tree():
	remove_custom_type("LevelBlock")
	remove_node_3d_gizmo_plugin(gizmo_plugin)
	remove_inspector_plugin(inspector_plugin)
