extends EditorProperty

var property_control = preload("res://addons/level_block/texture_selector_scene.tscn").instantiate()
var clear_image := preload("res://addons/level_block/clear.svg")

var current_value := 0
var updating := false
var texture_sheet : Texture2D
var texture_size : float

var texture
var value

func _init():
	add_child(property_control)
	texture = property_control.get_node("TextureRect")
	value = property_control.get_node("SpinBox")
	add_focusable(property_control)
	value.connect("value_changed", Callable(self, "update_value"))
	refresh_control()

func update_value(new_value: float):
	if updating:
		return
	current_value = new_value
	refresh_control()
	emit_changed(get_edited_property(), current_value)

func _update_property():
	var new_value = get_edited_object()[get_edited_property()]
	if (new_value == current_value):
		refresh_control()
		return
	updating = true
	current_value = new_value
	value.value = new_value
	refresh_control()
	updating = false

func update_texture(new_texture: Texture2D):
	texture_sheet = new_texture
	refresh_control()

func update_texture_size(new_size: float):
	texture_size = new_size
	refresh_control()

func refresh_control():
	if not texture_sheet is Texture2D:
		return
	if current_value < 0:
		texture.texture = clear_image
		return
	texture.texture = AtlasTexture.new()
	texture.texture.atlas = texture_sheet.duplicate()
	# Texture flags have been moved to nodes in Godot 4
	var pos = Vector2.ZERO
	var gap = texture_size / texture_sheet.get_size().x
	pos.x = fmod(gap * current_value, 1.0) * texture_sheet.get_size().x
	pos.y = floor(current_value / (1.0 / gap)) * gap * texture_sheet.get_size().y
	texture.texture.region.position = pos
	texture.texture.region.size = Vector2(texture_size, texture_size)
