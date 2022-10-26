extends EditorSpatialGizmoPlugin

class_name DungeonTileGizmo

var mesh : Mesh

func get_name():
	return "DungeonTile"

func redraw():
	if mesh:
		add_collision_triangles(mesh.generate_triangle_mesh())
