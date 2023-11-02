extends CharacterBody2D

@onready var healthBarUnder = $Control/HealthBarUnder
@onready var healthBarOver = $Control/HealthBarOver

enum States {IDLE, WANDER, ATTACKING, DEAD}
var state: States

var totalHealth: int = 20
var health: int = 20

func _ready() -> void:
	$AnimationPlayer.play("idle")

func hurt(damage: int) -> void:
	health -= damage
	healthBarOver.value = (float(health) / float(totalHealth)) * 100.0
	
	var tween := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(healthBarUnder, "value", healthBarOver.value, 0.4)
	
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
	
