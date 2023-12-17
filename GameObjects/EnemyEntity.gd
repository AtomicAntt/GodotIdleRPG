extends CharacterBody2D

@onready var healthBarUnder = $Control/HealthBarUnder
@onready var healthBarOver = $Control/HealthBarOver
@onready var navigationAgent: NavigationAgent2D = $NavigationAgent2D

@onready var enemyAttackAnimation = preload("res://GameObjects/EnemyAttackAnimation.tscn")

@onready var world = get_tree().get_nodes_in_group("world")[0]

enum States {IDLE, WANDER, ATTACKING, DEAD}
var state: States

var totalHealth: int = 20
var health: int = 20
var expValue: int = 10

var speed: float = 40.0

var maxQueue: int = 2
var queue: int = 0

# player attacking at
var atLeft: bool = false
var atRight: bool = false

var playerTarget: CharacterBody2D

func _ready() -> void:
	$AnimationPlayer.play("idle")
	
func _physics_process(delta: float) -> void:
#	$Control/Label.text = str(state)
#	$AnimationPlayer.play("idle")
	match state:
		States.IDLE:
			pass
		States.WANDER:
			if navigationAgent.is_navigation_finished():
				setIdle()
			else:
				$AnimationPlayer.play("run")
				var currentAgentPosition: Vector2 = global_position
				var nextPathPosition: Vector2 = navigationAgent.get_next_path_position()
				
				var newVelocity: Vector2 = (nextPathPosition - currentAgentPosition).normalized() * speed
				velocity = newVelocity
				move_and_slide()
		States.ATTACKING:
			if not is_instance_valid(playerTarget):
				setIdle()

func isAvailable() -> bool:
	if atLeft and atRight and queue == maxQueue:
		return false
	return true


func hurt(damage: int, player: CharacterBody2D) -> void:
	if not isDead():
		state = States.ATTACKING
		playerTarget = player
		facePlayer()
		health -= damage
		healthBarOver.value = (float(health) / float(totalHealth)) * 100.0
		
		var tween := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(healthBarUnder, "value", healthBarOver.value, 0.4)
		
		if health > 0:
			$AnimationPlayer.play("hurt")
			$AttackCooldown.start() # lets queue up an attack to be done
		else:
			state = States.DEAD
			$AnimationPlayer.play("hurtDeath")
			player.giveExp(expValue)


func attack() -> void:
	if is_instance_valid(playerTarget):
		var enemyAttackInstance := enemyAttackAnimation.instantiate()
		enemyAttackInstance.global_position = playerTarget.global_position
		enemyAttackInstance.position.y -= 6
		get_parent().add_child(enemyAttackInstance)
		enemyAttackInstance.animationPlayer.play("attack")
		playerTarget.hurt(5)
	
func facePlayer() -> void:
	if not is_instance_valid(playerTarget):
		return
	
	if leftOf(global_position, playerTarget.global_position):
		$Sprite2D.flip_h = true
	else:
		$Sprite2D.flip_h = false

func leftOf(object: Vector2, target: Vector2) -> bool:
	if target.x < object.x:
		return true
	return false

func setAttacking() -> void:
	$AnimationPlayer.play("idle")
	state = States.ATTACKING

func setIdle() -> void: # move to inheritence later
	$AnimationPlayer.play("idle")
	state = States.IDLE

func getSprite() -> Sprite2D:
	return $Sprite2D
	
func remove() -> void:
	queue_free()

func death() -> void: # called by hurtDeath animation from animationplayer 
	$AnimationPlayer.play("death")

func isDead() -> bool:
	if state == States.DEAD:
		return true
	return false
	
#func queueCheck() -> bool:
#	if queue.size() > maxQueue:
#		var player = queue.pop_back()
#		player.setIdle() # you may not chase me
#		return true
#	return false
#
#
#func enqueue(player: CharacterBody2D) -> void:
#	queue.push_front(player)
#	queueCheck()

func enqueue() -> bool:
	if queue < maxQueue:
		queue += 1
		return true
	else:
		return false

func _on_attack_cooldown_timeout():
	if not isDead() and is_instance_valid(playerTarget):
		attack()

func setPositionTarget(movementTarget: Vector2) -> void:
	navigationAgent.target_position = movementTarget

func facePosition(position: Vector2) -> void:
	if leftOf(global_position, position):
		$Sprite2D.flip_h = true
	else:
		$Sprite2D.flip_h = false

func wanderToRandomLocation():
	var randomLocation = world.returnValidPlayerLocation()
	facePosition(randomLocation)
	setPositionTarget(randomLocation)

func setWander():
	state = States.WANDER

func _on_wander_timeout():
	if state == States.IDLE:
		setWander()
		wanderToRandomLocation()
