extends CharacterBody2D

enum States {IDLE, WANDER, CHASE, COMBAT, DEAD}
var state: States

var speed: float = 200.0
var sightRange: float = 200.0
var enemyTarget: CharacterBody2D

@onready var navigationAgent: NavigationAgent2D = $NavigationAgent2D

func _ready() -> void:
	$AnimationPlayer.play("idle")

func _physics_process(delta: float) -> void:
#	$AnimationPlayer.play("idle")

	match state:
		States.IDLE:
			if is_instance_valid(enemyTarget):
				state = States.CHASE
			else:
				findClosestEnemy() # Which will set state to chase
		States.CHASE:
			if is_instance_valid(enemyTarget):
				if navigationAgent.is_navigation_finished():
					engageCombat() # Which will set state to combat
					return
				
				var currentAgentPosition: Vector2 = global_position
				var nextPathPosition: Vector2 = navigationAgent.get_next_path_position()
				
				var newVelocity: Vector2 = (nextPathPosition - currentAgentPosition).normalized() * speed
				velocity = newVelocity
				move_and_slide()
			else:
				state = States.IDLE

func engageCombat() -> void:
	if is_instance_valid(enemyTarget):
		state = States.COMBAT
		print("now engaging in combat with enemy!")
		$AttackCooldown.start()
		
		# Check if player pos left of enemy pos
		if leftOf(global_position, enemyTarget.global_position):
			$Sprite2D.flip_h = true
		# Check if enemy pos left of player pos
		if leftOf(enemyTarget.global_position, global_position):
			enemyTarget.getSprite().flip_h = true
	else:
		state = States.IDLE

func leftOf(object: Vector2, target: Vector2) -> bool:
	if target.x < object.x:
		return true
	return false

#func actorSetup() -> void:
#	await get_tree().physics_frame
#	setMovementTarget()

func setMovementTarget(movementTarget: Vector2):
	# To make sure the player is to the left or right of the enemy (because attacks would look weird otherwise)
	var newTargetPosition: Vector2 = movementTarget
	if global_position.x < movementTarget.x:
		newTargetPosition.x = movementTarget.x - 30
	else:
		newTargetPosition.x = movementTarget.x + 30
		
	newTargetPosition.y = movementTarget.y + 18
	
#	if global_position.y > movementTarget.x:
#		newTargetPosition.y = movementTarget.y + 5
#	else:
#		newTargetPosition.y = movementTarget.y - 5
	
	navigationAgent.target_position = newTargetPosition

func attack() -> void:
	if leftOf(global_position, enemyTarget.global_position):
		$AnimationPlayer.play("swingLeft")
	else:
		$AnimationPlayer.play("swingRight")		

func findClosestEnemy() -> void:
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if enemy.global_position.distance_squared_to(global_position) <= sightRange * sightRange:
			enemyTarget = enemy
			setMovementTarget(enemyTarget.global_position)
			state = States.CHASE
	

func setIdle() -> void: # move to inheritence later
	$AnimationPlayer.play("idle")
	state = States.IDLE


func _on_attack_cooldown_timeout():
	attack()
