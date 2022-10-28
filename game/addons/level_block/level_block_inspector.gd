extends EditorInspectorPlugin

var BlockNode := preload("res://addons/level_block/level_block_node.gd")
var TextureSelector := preload("res://addons/level_block/texture_selector.gd")

func can_handle(object):
	if object is BlockNode:
		return true
	return false

func parse_property(object, type, path, hint, hint_text, usage):
	if type == TYPE_INT:
		var selector := TextureSelector.new()
		selector.texture_sheet = object.texture_sheet
		selector.texture_size = object.texture_size
		add_property_editor(path, selector)
		return true
	else:
		return false
