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

func _get_gizmo_name():
	return "LevelBlock"

func _init():
	create_material("Cube", Color.ORANGE)

func _has_gizmo(node):
	return node is LevelBlock

func _redraw(gizmo):
	gizmo.clear()
	
	var block = gizmo.get_node_3d() as LevelBlock
	var cube := BoxMesh.new()
	cube.size = Vector3.ONE * 2.0
	gizmo.add_collision_triangles(cube.generate_triangle_mesh())
	var lines = PackedVector3Array(cube_line_points)
	gizmo.add_lines(lines, get_material("Cube", gizmo))
