extends AnimatableBody3D

var opened := false

func interact():
	if !opened:
		$Animation.play("open")
		$Shape3D.disabled = true
	else:
		$Animation.play_backwards("open")
		$Shape3D.disabled = false
	opened = !opened
