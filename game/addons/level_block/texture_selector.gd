extends EditorProperty

var property_control := preload("res://addons/level_block/texture_selector_scene.tscn").instance()

var current_value := 0
var updating := false
var texture_sheet : Texture
var texture_size : float
var asft = "awf"

var texture
var value

func _init():
	add_child(property_control)
	texture = property_control.get_node("TextureRect")
	value = property_control.get_node("SpinBox")
	add_focusable(property_control)
	value.connect("changed", self, "update_value")
	refresh_control()

func update_value():
	current_value = value.value
	emit_changed(get_edited_property(), current_value)

func update_property():
	var new_value = get_edited_object()[get_edited_property()]
	if (new_value == current_value):
		return
	updating = true
	current_value = new_value
	refresh_control()
	updating = false

func get_uv_gap() -> float:
	return texture_size / texture_sheet.get_size().x

func get_uv_position(index: int) -> Vector2:
	var pos = Vector2.ZERO
	pos.x = fmod(get_uv_gap() * index, 1.0)
	pos.y = floor(index / (1.0 / get_uv_gap())) * get_uv_gap()
	return pos

func refresh_control():
	if not texture_sheet is Texture:
		return
	texture.texture = AtlasTexture.new()
	texture.texture.atlas = texture_sheet
	var pos = Vector2.ZERO
	var gap = texture_size / texture_sheet.get_size().x
	pos.x = fmod(gap * current_value, 1.0)
	pos.y = floor(current_value / (1.0 / gap)) * gap
	texture.texture.region.position = pos
	texture.texture.region.size = Vector2(texture_size, texture_size)
