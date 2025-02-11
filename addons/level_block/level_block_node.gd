@tool
extends Node3D

# Signals for texture updates
signal texture_updated(new_texture)
signal texture_size_updated(new_size)

# Constants and properties
const size = 1.0

@export var material: BaseMaterial3D = load("res://addons/level_block/default_material.tres")
@export var texture_sheet: Texture2D = null : set = set_texture
@export var texture_size: float = 32 : set = set_texture_size
@export var north_face: int = -1 : set = set_north
@export var east_face: int = -1 : set = set_east
@export var south_face: int = -1 : set = set_south
@export var west_face: int = -1 : set = set_west
@export var top_face: int = -1 : set = set_top
@export var bottom_face: int = -1 : set = set_bottom
@export var flip_faces: bool = false : set = set_flip_faces
@export var generate_collision: bool = true : set = set_generate_collision
@export var generate_occluders: bool = false : set = set_generate_occluders

# Internal variables
var faces
var visual
var body
var mesh
var shape
var occluders: Array
var mesh_faces := PackedVector3Array()
var mesh_aabb := AABB()

## NAVIGATION SERVER ADDITION - Navigation-related variables
var source_geometry_parser: RID
var source_geometry_parser_callback: Callable

# Property setters
func set_texture(new_value):
	texture_sheet = new_value
	emit_signal("texture_updated", texture_sheet)
	refresh()

func set_texture_size(new_value):
	texture_size = new_value
	emit_signal("texture_size_updated", texture_size)
	refresh()

func set_north(new_value):
	north_face = new_value
	refresh()

func set_east(new_value):
	east_face = new_value
	refresh()

func set_south(new_value):
	south_face = new_value
	refresh()

func set_west(new_value):
	west_face = new_value
	refresh()

func set_top(new_value):
	top_face = new_value
	refresh()

func set_bottom(new_value):
	bottom_face = new_value
	refresh()

func set_flip_faces(new_value):
	flip_faces = new_value
	refresh()

func set_generate_collision(new_value):
	generate_collision = new_value
	refresh()

func set_generate_occluders(new_value):
	generate_occluders = new_value
	refresh()

# Initialization
func _ready():
	set_notify_transform(true)
	
	## NAVIGATION SERVER FIX - Initialize navigation parser
	source_geometry_parser_callback = Callable(self, "_on_source_geometry_parser_callback")
	source_geometry_parser = NavigationServer3D.source_geometry_parser_create()
	NavigationServer3D.source_geometry_parser_set_callback(source_geometry_parser, source_geometry_parser_callback)
	
	refresh()

# Refresh the block
func refresh():
	clear()
	faces = [north_face, east_face, south_face, west_face, top_face, bottom_face]
	if faces.max() < 0:
		return
	
	if generate_occluders:
		create_occluders()
	
	mesh = create_mesh()
	
	## NAVIGATION SERVER FIX - Store mesh data for navigation
	mesh_faces = mesh.get_faces()
	mesh_aabb = mesh.get_aabb()
	
	mesh.surface_set_material(0, material)
	material.albedo_texture = texture_sheet
	
	# RenderingServer setup
	visual = RenderingServer.instance_create()
	RenderingServer.instance_set_base(visual, mesh)
	if is_inside_tree():
		RenderingServer.instance_set_scenario(visual, get_world_3d().scenario)
		RenderingServer.instance_set_transform(visual, global_transform)
	
	# PhysicsServer3D setup
	if !generate_collision:
		return
	body = PhysicsServer3D.body_create()
	PhysicsServer3D.body_set_mode(body, PhysicsServer3D.BODY_MODE_STATIC)
	shape = PhysicsServer3D.concave_polygon_shape_create()
	PhysicsServer3D.shape_set_data(shape, {"faces": mesh.get_faces()})
	if is_inside_tree():
		PhysicsServer3D.body_add_shape(body, shape, global_transform)
		PhysicsServer3D.body_set_space(body, get_world_3d().space)
	PhysicsServer3D.body_set_ray_pickable(body, true)
	PhysicsServer3D.body_attach_object_instance_id(body, get_instance_id())

# Cleanup resources
func clear():
	if visual is RID:
		RenderingServer.free_rid(visual)
		visual = null
	if body is RID:
		PhysicsServer3D.free_rid(body)
		body = null
	if shape is RID:
		PhysicsServer3D.free_rid(shape)
		shape = null
	if occluders.size() > 0:
		for o in occluders:
			o.queue_free()
	occluders.clear()
	mesh_faces.clear()
	
	## NAVIGATION SERVER FIX - Clean up navigation parser
	delete_parser()

## NAVIGATION SERVER ADDITION - Safe parser cleanup
func delete_parser() -> void:
	if source_geometry_parser.is_valid():
		NavigationServer3D.free_rid(source_geometry_parser)
	source_geometry_parser = RID()

## NAVIGATION SERVER ADDITION - Navigation callback
func _on_source_geometry_parser_callback(
	p_navigation_mesh: NavigationMesh,
	p_source_geometry_data: NavigationMeshSourceGeometryData3D,
	p_parsed_node: Node
) -> void:
	if generate_collision && mesh != null:
		p_source_geometry_data.add_mesh(mesh, global_transform)

# UV calculations
func get_uv_gap() -> float:
	return float(texture_size) / texture_sheet.get_size().x

func get_uv_position(index: int) -> Vector2:
	var pos = Vector2.ZERO
	pos.x = fmod(get_uv_gap() * index, 1.0)
	pos.y = floor(index / (1.0 / get_uv_gap())) * get_uv_gap()
	return pos

# Mesh creation
func create_mesh() -> Mesh:
	var normals = [Vector3.BACK, Vector3.LEFT, Vector3.FORWARD, Vector3.RIGHT, Vector3.DOWN, Vector3.UP]
	var rot_axis = [Vector3.DOWN, Vector3.LEFT]
	if flip_faces:
		normals = [Vector3.FORWARD, Vector3.RIGHT, Vector3.BACK, Vector3.LEFT, Vector3.UP, Vector3.DOWN]
	var rot_angle = [0.0, PI / 2.0, PI, PI + (PI / 2), -(PI / 2.0), PI / 2.0]
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(6):
		st.set_normal(normals[i])
		st.set_uv(get_uv_position(faces[i]))
		var vertex_0 := Vector3(-size, size, -size)
		vertex_0 = vertex_0.rotated(rot_axis[i / 4], rot_angle[i])
		st.add_vertex(vertex_0)
		
		st.set_normal(normals[i])
		st.set_uv(get_uv_position(faces[i]) + (get_uv_gap() * Vector2(1.0, 0.0)))
		var vertex_1 := Vector3(size, size, -size)
		vertex_1 = vertex_1.rotated(rot_axis[i / 4], rot_angle[i])
		st.add_vertex(vertex_1)
		
		st.set_normal(normals[i])
		st.set_uv(get_uv_position(faces[i]) + (get_uv_gap() * Vector2(1.0, 1.0)))
		var vertex_2 := Vector3(size, -size, -size)
		vertex_2 = vertex_2.rotated(rot_axis[i / 4], rot_angle[i])
		st.add_vertex(vertex_2)
		
		st.set_normal(normals[i])
		st.set_uv(get_uv_position(faces[i]) + (get_uv_gap() * Vector2(0.0, 1.0)))
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

# Occluder creation
func create_occluders():
	var positions = [Vector3.FORWARD, Vector3.RIGHT, Vector3.BACK, Vector3.LEFT, Vector3.UP, Vector3.DOWN]
	var rot_axis = [Vector3.UP, Vector3.RIGHT]
	var rot_angle = [0.0, -(PI / 2.0), PI, PI / 2, PI / 2.0, -(PI / 2.0)]
	for i in range(6):
		if faces[i] < 0:
			continue
		var occluder = OccluderInstance3D.new()
		occluder.occluder = QuadOccluder3D.new()
		occluder.occluder.size *= 2.0
		occluder.position = positions[i]
		occluder.rotate(rot_axis[i / 4], rot_angle[i])
		add_child(occluder)
		occluders.append(occluder)

# Notification handling
func _notification(what):
	match what:
		NOTIFICATION_TRANSFORM_CHANGED:
			refresh()
		NOTIFICATION_VISIBILITY_CHANGED:
			if visual is RID:
				RenderingServer.instance_set_visible(visual, is_visible_in_tree())

# Tree lifecycle
func _enter_tree() -> void:
	refresh()

func _exit_tree() -> void:
	clear()
	## NAVIGATION SERVER FIX - Ensure parser cleanup
	if source_geometry_parser.is_valid():
		delete_parser()
