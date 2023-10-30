extends Marker2D

@onready var animationPlayer = $AnimationPlayer

func _on_timer_timeout():
	queue_free()
