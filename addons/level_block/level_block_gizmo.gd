extends EditorNode3DGizmoPlugin


const LevelBlock := preload("res://addons/level_block/level_block_node.gd")

const cube_line_points = [
	Vector3(-1.0, -1.0, -1.0),
	Vector3(1.0, -1.0, -1.0),
	Vector3(1.0, -1.0, -1.0),
	Vector3(1.0, -1.0, 1.0),
	Vector3(1.0, -1.0, 1.0),
	Vector3(-1.0, -1.0, 1.0),
	Vector3(-1.0, -1.0, 1.0),
	Vector3(-1.0, -1.0, -1.0),
	Vector3(-1.0, 1.0, -1.0),
	Vector3(1.0, 1.0, -1.0),
	Vector3(1.0, 1.0, -1.0),
	Vector3(1.0, 1.0, 1.0),
	Vector3(1.0, 1.0, 1.0),
	Vector3(-1.0, 1.0, 1.0),
	Vector3(-1.0, 1.0, 1.0),
	Vector3(-1.0, 1.0, -1.0),
	Vector3(-1.0, -1.0, -1.0),
	Vector3(-1.0, 1.0, -1.0),
	Vector3(1.0, -1.0, -1.0),
	Vector3(1.0, 1.0, -1.0),
	Vector3(1.0, -1.0, 1.0),
	Vector3(1.0, 1.0, 1.0),
	Vector3(-1.0, -1.0, 1.0),
	Vector3(-1.0, 1.0, 1.0),
]

func _init():
	create_material("Cube", Color.ORANGE)

func get_name():
	return "LevelBlock"

func has_gizmo(spatial):
	return spatial is LevelBlock

func redraw(gizmo):
	gizmo.clear()
	
	var block = gizmo.get_spatial_node() as LevelBlock
	var cube := BoxMesh.new()
	cube.size = Vector3.ONE * 2.0
	gizmo.add_collision_triangles(cube.generate_triangle_mesh())
	var lines = PackedVector3Array(cube_line_points)
	gizmo.add_lines(lines, get_material("Cube", gizmo))
