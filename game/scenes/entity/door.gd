extends RigidBody

var opened := false

func interact():
	if !opened:
		$Animation.play("open")
		$Shape.disabled = true
	else:
		$Animation.play_backwards("open")
		$Shape.disabled = false
	opened = !opened
