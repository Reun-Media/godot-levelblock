extends Node3D

@export var move_time := 0.3

var tween: Tween

func _init():
	RenderingServer.set_debug_generate_wireframes(true)

func _physics_process(_delta):
	# If there is a tween running, prevent any new inputs and tweens from starting
	if tween is Tween and tween.is_running():
		return
	if Input.is_action_just_pressed("action"):
		if check_collision(Vector3.FORWARD.rotated(Vector3.UP, rotation.y)):
			var result = return_collision(Vector3.FORWARD.rotated(Vector3.UP, rotation.y))
			if result && result["collider"]:
				if result["collider"].has_method("interact"):
					result["collider"].interact()
	if Input.is_action_pressed("forward"):
		if !check_collision(Vector3.FORWARD.rotated(Vector3.UP, rotation.y)):
			tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			tween.tween_property(self, "position", position + Vector3.FORWARD.rotated(Vector3.UP, rotation.y) * 2.0, move_time)
	elif Input.is_action_pressed("back"):
		if !check_collision(Vector3.BACK.rotated(Vector3.UP, rotation.y)):
			tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			tween.tween_property(self, "position", position + Vector3.BACK.rotated(Vector3.UP, rotation.y) * 2.0, move_time)
	elif Input.is_action_pressed("strafe_left"):
		if !check_collision(Vector3.LEFT.rotated(Vector3.UP, rotation.y)):
			tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			tween.tween_property(self, "position", position + Vector3.LEFT.rotated(Vector3.UP, rotation.y) * 2.0, move_time)
	elif Input.is_action_pressed("strafe_right"):
		if !check_collision(Vector3.RIGHT.rotated(Vector3.UP, rotation.y)):
			tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			tween.tween_property(self, "position", position + Vector3.RIGHT.rotated(Vector3.UP, rotation.y) * 2.0, move_time)
	elif Input.is_action_pressed("left"):
		tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "rotation:y", rotation.y + (PI / 2.0), move_time)
	elif Input.is_action_pressed("right"):
		tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "rotation:y", rotation.y - (PI / 2.0), move_time)

func check_collision(direction: Vector3) -> bool:
	var space = get_world_3d().direct_space_state
	var params = PhysicsRayQueryParameters3D.new()
	params.from = global_position
	params.to = global_position + (direction * 2.0)
	params.exclude = []
	params.collision_mask = 1
	var result = space.intersect_ray(params)
	if result:
		return true
	return false

func return_collision(direction: Vector3):
	var space = get_world_3d().direct_space_state
	var params = PhysicsRayQueryParameters3D.new()
	params.from = global_position
	params.to = global_position + (direction * 2.0)
	params.exclude = []
	params.collision_mask = 1
	var result = space.intersect_ray(params)
	if result:
		return result
	return null

func _unhandled_input(event):
	if event is InputEventKey:
		if event.keycode == KEY_T and event.pressed:
			var vp = get_viewport()
			vp.debug_draw = (vp.debug_draw + 1) % 5
