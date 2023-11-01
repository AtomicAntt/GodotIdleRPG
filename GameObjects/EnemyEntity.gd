extends CharacterBody2D

enum States {IDLE, WANDER, ATTACKING, DEAD}
var state: States

var health: int = 20

func _ready() -> void:
	$AnimationPlayer.play("idle")

func hurt(damage: int) -> void:
	print("health: " + str(health))
	health -= damage
	$AnimationPlayer.play("hurt")

func _physics_process(delta: float) -> void:
#	$AnimationPlayer.play("idle")
	match state:
		States.IDLE:
			pass

func setIdle() -> void: # move to inheritence later
	$AnimationPlayer.play("idle")
	state = States.IDLE

func getSprite() -> Sprite2D:
	return $Sprite2D
