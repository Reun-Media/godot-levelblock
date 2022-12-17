extends Spatial

export var move_time := 0.3

var tween := Tween.new()

func _init():
	VisualServer.set_debug_generate_wireframes(true)

func _ready():
	add_child(tween)

func _physics_process(delta):
	if tween.is_active():
		return
	if Input.is_action_just_pressed("action"):
		if check_collision(Vector3.FORWARD.rotated(Vector3.UP, rotation.y)):
			var result = return_collision(Vector3.FORWARD.rotated(Vector3.UP, rotation.y))
			if result && result["collider"]:
				if result["collider"].has_method("interact"):
					result["collider"].interact()
	if Input.is_action_pressed("forward"):
		if !check_collision(Vector3.FORWARD.rotated(Vector3.UP, rotation.y)):
			tween.interpolate_property(self, "translation", null, translation + Vector3.FORWARD.rotated(Vector3.UP, rotation.y) * 2.0, move_time, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	elif Input.is_action_pressed("back"):
		if !check_collision(Vector3.BACK.rotated(Vector3.UP, rotation.y)):
			tween.interpolate_property(self, "translation", null, translation + Vector3.BACK.rotated(Vector3.UP, rotation.y) * 2.0, move_time, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	elif Input.is_action_pressed("strafe_left"):
		if !check_collision(Vector3.LEFT.rotated(Vector3.UP, rotation.y)):
			tween.interpolate_property(self, "translation", null, translation + Vector3.LEFT.rotated(Vector3.UP, rotation.y) * 2.0, move_time, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	elif Input.is_action_pressed("strafe_right"):
		if !check_collision(Vector3.RIGHT.rotated(Vector3.UP, rotation.y)):
			tween.interpolate_property(self, "translation", null, translation + Vector3.RIGHT.rotated(Vector3.UP, rotation.y) * 2.0, move_time, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	elif Input.is_action_pressed("left"):
		tween.interpolate_property(self, "rotation:y", null, rotation.y + (PI / 2.0), move_time, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	elif Input.is_action_pressed("right"):
		tween.interpolate_property(self, "rotation:y", null, rotation.y - (PI / 2.0), move_time, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	else:
		return
	tween.start()

func check_collision(direction: Vector3) -> bool:
	var space = get_world().direct_space_state
	var result = space.intersect_ray(global_translation, global_translation + (direction * 2.0))
	if result:
		return true
	return false

func return_collision(direction: Vector3):
	var space = get_world().direct_space_state
	var result = space.intersect_ray(global_translation, global_translation + (direction * 2.0))
	if result:
		return result
	return null

func _unhandled_input(event):
	if event is InputEventKey:
		if event.scancode == KEY_T and event.pressed:
			var vp = get_viewport()
			vp.debug_draw = (vp.debug_draw + 1) % 4
