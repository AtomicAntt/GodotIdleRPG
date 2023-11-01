extends CharacterBody2D

enum States {IDLE, WANDER, ATTACKING, DEAD}
var state: States

var health: int = 20

func _ready() -> void:
	$AnimationPlayer.play("idle")

func hurt(damage: int) -> void:
	print("health: " + str(health))
	health -= damage
	if health > 0:
		$AnimationPlayer.play("hurt")
	else:
		$AnimationPlayer.play("hurtDeath")

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
	
func remove() -> void:
	queue_free()

func death() -> void: # called by hurtDeath animation from animationplayer
	$AnimationPlayer.play("death")
	state = States.DEAD

func isDead() -> bool:
	if state == States.DEAD:
		return true
	return false
	
