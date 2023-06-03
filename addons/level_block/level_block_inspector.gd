extends EditorInspectorPlugin

const BlockNode := preload("res://addons/level_block/level_block_node.gd")
const TextureSelector := preload("res://addons/level_block/texture_selector.gd")

var face_paths := [
	"north_face",
	"east_face",
	"south_face",
	"west_face",
	"top_face",
	"bottom_face"
]


func _can_handle(object):
	if object is BlockNode:
		return true
	return false

func _parse_property(object, type, path, hint, hint_text, usage, wide):
	if type == TYPE_INT:
		for p in face_paths:
			if p == path:
				var selector := TextureSelector.new()
				selector.texture_sheet = object.texture_sheet
				object.connect("texture_updated", Callable(selector, "update_texture"))
				object.connect("texture_size_updated", Callable(selector, "update_texture_size"))
				selector.texture_size = object.texture_size
				add_property_editor(path, selector)
				return true
		return false
	else:
		return false
