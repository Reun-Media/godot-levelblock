tool

extends Spatial

signal texture_updated(new_texture)
signal texture_size_updated(new_size)

const size = 1.0
const occluder_multiplier = 1.001

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

export(bool) var generate_collision = true setget set_generate_collision
func set_generate_collision(new_value):
	generate_collision = new_value
	refresh()

export(bool) var generate_occluders = false setget set_generate_occluders
func set_generate_occluders(new_value):
	generate_occluders = new_value
	refresh()

var faces
var visual
var body
var mesh
var shape
var occluders : Array

func _ready():
	set_notify_transform(true)
	refresh()

func refresh():
	clear()
	faces = [north_face, east_face, south_face, west_face, top_face, bottom_face]
	if faces.max() < 0:
		return
	if generate_occluders:
		create_occluders()
	mesh = create_mesh()
	mesh.surface_set_material(0, material)
	material.albedo_texture = texture_sheet
	# VisualServer
	visual = VisualServer.instance_create()
	VisualServer.instance_set_base(visual, mesh)
	if is_inside_tree():
		VisualServer.instance_set_scenario(visual, get_world().scenario)
		VisualServer.instance_set_transform(visual, global_transform)
	# PhysicsServer
	if !generate_collision:
		return
	body = PhysicsServer.body_create(PhysicsServer.BODY_MODE_STATIC)
	PhysicsServer.body_set_mode(body, PhysicsServer.BODY_MODE_STATIC)
	shape = PhysicsServer.shape_create(PhysicsServer.SHAPE_CONCAVE_POLYGON)
	PhysicsServer.shape_set_data(shape, mesh.get_faces())
	if is_inside_tree():
		PhysicsServer.body_add_shape(body, shape, global_transform)
		PhysicsServer.body_set_space(body, get_world().space)
	PhysicsServer.body_set_ray_pickable(body, true)
	PhysicsServer.body_attach_object_instance_id(body, get_instance_id())

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
	if occluders.size() > 0:
		for o in occluders:
			o.queue_free()
	occluders.clear()

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

func create_occluders():
	var positions = [Vector3.FORWARD, Vector3.RIGHT, Vector3.BACK, Vector3.LEFT, Vector3.UP, Vector3.DOWN]
	var rot_axis = [Vector3.UP, Vector3.RIGHT]
	var rot_angle = [0.0, -(PI / 2.0), PI, PI / 2, PI / 2.0, -(PI / 2.0)]
	for i in range(6):
		if faces[i] < 0:
			continue
		var occluder = Occluder.new()
		occluder.shape = OccluderShapePolygon.new()
		for p in range(occluder.shape.polygon_points.size()):
			occluder.shape.polygon_points[p] *= occluder_multiplier
		occluder.translation = positions[i]
		occluder.rotate(rot_axis[i / 4], rot_angle[i])
		add_child(occluder)
		occluders.append(occluder)

func _notification(what):
	match what:
		NOTIFICATION_TRANSFORM_CHANGED:
			refresh()
		NOTIFICATION_VISIBILITY_CHANGED:
			if visual is RID:
				VisualServer.instance_set_visible(visual, is_visible_in_tree())

func _enter_tree() -> void:
	refresh()

func _exit_tree() -> void:
	clear()
