extends CharacterBody2D

enum States {IDLE, WANDER, ATTACKING, DEAD}
var state: States

func _ready() -> void:
	$AnimationPlayer.play("idle")

func _physics_process(delta: float) -> void:
#	$AnimationPlayer.play("idle")

	match state:
		States.IDLE:
			pass

func attack(enemy: CharacterBody2D):
	$AnimationPlayer.play("swing")



func setIdle() -> void: # move to inheritence later
	$AnimationPlayer.play("idle")
	state = States.IDLE
