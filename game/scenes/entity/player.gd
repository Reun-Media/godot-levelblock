extends Spatial

export var move_time := 0.3

var tween := Tween.new()

func _ready():
	add_child(tween)

func _physics_process(delta):
	if tween.is_active():
		return
	if Input.is_action_pressed("forward"):
		if !check_collision(Vector3.FORWARD.rotated(Vector3.UP, rotation.y)):
			tween.interpolate_property(self, "translation", null, translation + Vector3.FORWARD.rotated(Vector3.UP, rotation.y) * 2.0, move_time, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	elif Input.is_action_pressed("back"):
		if !check_collision(Vector3.BACK.rotated(Vector3.UP, rotation.y)):
			tween.interpolate_property(self, "translation", null, translation + Vector3.BACK.rotated(Vector3.UP, rotation.y) * 2.0, move_time, Tween.TRANS_CUBIC, Tween.EASE_OUT)
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
