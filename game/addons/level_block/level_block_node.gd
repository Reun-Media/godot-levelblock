tool

extends Spatial

signal texture_updated(new_texture)
signal texture_size_updated(new_size)

const size = 1.0

export(SpatialMaterial) var material = load("res://addons/level_block/default_material.tres")
export(Texture) var texture_sheet setget set_texture
func set_texture(new_value):
	texture_sheet = new_value
	emit_signal("texture_updated", texture_sheet)
	refresh()
export(float) var texture_size = 32 setget set_texture_size
func set_texture_size(new_value):
	texture_size = new_value
	emit_signal("texture_size_updated", texture_size)
	refresh()

export(int) var north_face = -1 setget set_north
func set_north(new_value):
	north_face = new_value
	refresh()
export(int) var east_face = -1 setget set_east
func set_east(new_value):
	east_face = new_value
	refresh()
export(int) var south_face = -1 setget set_south
func set_south(new_value):
	south_face = new_value
	refresh()
export(int) var west_face = -1 setget set_west
func set_west(new_value):
	west_face = new_value
	refresh()
export(int) var top_face = -1 setget set_top
func set_top(new_value):
	top_face = new_value
	refresh()
export(int) var bottom_face = -1 setget set_bottom
func set_bottom(new_value):
	bottom_face = new_value
	refresh()

export(bool) var flip_faces = false setget set_flip_faces
func set_flip_faces(new_value):
	flip_faces = new_value
	refresh()

var faces
var visual
var body
var mesh
var shape

func _ready():
	set_notify_transform(true)
	refresh()

func refresh():
	clear()
	faces = [north_face, east_face, south_face, west_face, top_face, bottom_face]
	if faces.max() < 0:
		return
	mesh = create_mesh()
	mesh.surface_set_material(0, material)
	# VisualServer
	visual = VisualServer.instance_create()
	if is_inside_tree():
		VisualServer.instance_set_scenario(visual, get_world().scenario)
	VisualServer.instance_set_base(visual, mesh)
	VisualServer.instance_set_transform(visual, transform)
	# PhysicsServer
	body = PhysicsServer.body_create(PhysicsServer.BODY_MODE_STATIC)
	PhysicsServer.body_set_mode(body, PhysicsServer.BODY_MODE_STATIC)
	shape = PhysicsServer.shape_create(PhysicsServer.SHAPE_CONCAVE_POLYGON)
	PhysicsServer.shape_set_data(shape, mesh.get_faces())
	PhysicsServer.body_add_shape(body, shape, transform)
	if is_inside_tree():
		PhysicsServer.body_set_space(body, get_world().space)
	PhysicsServer.body_set_ray_pickable(body, true)
	material.albedo_texture = texture_sheet

func clear():
	if visual is RID:
		VisualServer.free_rid(visual)
		visual = null
	if body is RID:
		PhysicsServer.free_rid(body)
		body = null
	if shape is RID:
		PhysicsServer.free_rid(shape)
		shape = null

func get_uv_gap() -> float:
	return float(texture_size) / texture_sheet.get_size().x

func get_uv_position(index: int) -> Vector2:
	var pos = Vector2.ZERO
	pos.x = fmod(get_uv_gap() * index, 1.0)
	pos.y = floor(index / (1.0 / get_uv_gap())) * get_uv_gap()
	return pos

func create_mesh() -> Mesh:
	var normals = [Vector3.BACK, Vector3.LEFT, Vector3.FORWARD, Vector3.RIGHT, Vector3.DOWN, Vector3.UP]
	var rot_axis = [Vector3.DOWN, Vector3.LEFT]
	if flip_faces:
		normals = [Vector3.FORWARD, Vector3.RIGHT, Vector3.BACK, Vector3.LEFT, Vector3.UP, Vector3.DOWN]
	var rot_angle = [0.0, PI / 2.0, PI, PI + (PI / 2), -(PI / 2.0), PI / 2.0]
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(6):
		st.add_normal(normals[i])
		st.add_uv(get_uv_position(faces[i]))
		var vertex_0 := Vector3(-size, size, -size)
		vertex_0 = vertex_0.rotated(rot_axis[i / 4], rot_angle[i])
		st.add_vertex(vertex_0)
		
		st.add_normal(normals[i])
		st.add_uv(get_uv_position(faces[i]) + (get_uv_gap() * Vector2(1.0, 0.0)))
		var vertex_1 := Vector3(size, size, -size)
		vertex_1 = vertex_1.rotated(rot_axis[i / 4], rot_angle[i])
		st.add_vertex(vertex_1)
		
		st.add_normal(normals[i])
		st.add_uv(get_uv_position(faces[i]) + (get_uv_gap() * Vector2(1.0, 1.0)))
		var vertex_2 := Vector3(size, -size, -size)
		vertex_2 = vertex_2.rotated(rot_axis[i / 4], rot_angle[i])
		st.add_vertex(vertex_2)
		
		st.add_normal(normals[i])
		st.add_uv(get_uv_position(faces[i]) + (get_uv_gap() * Vector2(0.0, 1.0)))
		var vertex_3 := Vector3(-size, -size, -size)
		vertex_3 = vertex_3.rotated(rot_axis[i / 4], rot_angle[i])
		st.add_vertex(vertex_3)
		
		if faces[i] < 0:
			continue
		
		if flip_faces:
			st.add_index(3 + (i * 4))
			st.add_index(1 + (i * 4))
			st.add_index(0 + (i * 4))
		
			st.add_index(3 + (i * 4))
			st.add_index(2 + (i * 4))
			st.add_index(1 + (i * 4))
			continue
		
		st.add_index(0 + (i * 4))
		st.add_index(1 + (i * 4))
		st.add_index(3 + (i * 4))
		
		st.add_index(1 + (i * 4))
		st.add_index(2 + (i * 4))
		st.add_index(3 + (i * 4))
	
	return st.commit()

func _notification(what):
	match what:
		NOTIFICATION_TRANSFORM_CHANGED:
			refresh()

func _enter_tree() -> void:
	refresh()

func _exit_tree() -> void:
	clear()
