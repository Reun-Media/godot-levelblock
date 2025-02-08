@tool

const LevelBlockNode = preload("res://addons/level_block/level_block_node.gd")

var source_geometry_parser: RID
var source_geometry_parser_callback: Callable

func create_parser() -> void:
	source_geometry_parser_callback = Callable(
		self,
		"_on_source_geometry_parser_callback"
	)
	source_geometry_parser = NavigationServer3D.source_geometry_parser_create()
	NavigationServer3D.source_geometry_parser_set_callback(
		source_geometry_parser,
		source_geometry_parser_callback
	)

func delete_parser() -> void:
	NavigationServer3D.free_rid(source_geometry_parser)
	source_geometry_parser = RID()
	source_geometry_parser_callback = Callable()

func _on_source_geometry_parser_callback(
	p_navigation_mesh: NavigationMesh,
	p_source_geometry_data: NavigationMeshSourceGeometryData3D,
	p_parsed_node: Node) -> void:
	
	# Skip navmesh generation for nodes that are not LevelBlock nodes
	if not p_parsed_node is LevelBlockNode:
		return
	
	# Skip navmesh generation for LevelBlocks without collision
	if not p_parsed_node.generate_collision:
		return
	
	# Skip navmesh generation for LevelBlocks with no faces
	if p_parsed_node.mesh_faces.size() == 0:
		return
	
	# Skip navmesh generation for LevelBlocks that are outside the
	# navigation mesh filter baking AABB
	var filter_baking_aabb := p_navigation_mesh.filter_baking_aabb
	if filter_baking_aabb.has_volume() && p_parsed_node.mesh_aabb.has_volume():
		# Offset the mesh AABB by the filter baking AABB offset
		var filter_baking_aabb_offset := p_navigation_mesh.get_filter_baking_aabb_offset()
		filter_baking_aabb.position += filter_baking_aabb_offset
		
		# Convert the mesh AABB to global space with LevelBlock transfrom
		var mesh_aabb: AABB = p_parsed_node.global_transform * p_parsed_node.mesh_aabb
		
		if not filter_baking_aabb.intersects(mesh_aabb):
			return
	
	p_source_geometry_data.add_faces(
		p_parsed_node.mesh_faces,
		p_parsed_node.global_transform
	)
