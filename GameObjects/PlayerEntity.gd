extends CharacterBody2D

enum States {IDLE, WANDER, CHASE, COMBAT, DEAD}
var state: States

var speed: float = 60.0
var sightRange: float = 200.0
var enemyTarget: CharacterBody2D

@onready var navigationAgent: NavigationAgent2D = $NavigationAgent2D

@onready var weaponAnimation := preload("res://GameObjects/WeaponAnimation.tscn")

@onready var usernameGenerator := get_tree().get_nodes_in_group("usernameGenerator")[0]

func _ready() -> void:
	$AnimationPlayer.play("idle")
	$Control/Label.text = usernameGenerator.returnRandomUsername()

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
				
				$AnimationPlayer.play("run")
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
		$AnimationPlayer.play("idle")
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

func setMovementTarget(movementTarget: Vector2) -> void:
	# To make sure the player is to the left or right of the enemy (because attacks would look weird otherwise)
	var newTargetPosition: Vector2 = movementTarget
	if global_position.x < movementTarget.x:
		newTargetPosition.x = movementTarget.x - 30
	else:
		newTargetPosition.x = movementTarget.x + 30
		
#	newTargetPosition.y = movementTarget.y + 2
	
#	if global_position.y > movementTarget.x:
#		newTargetPosition.y = movementTarget.y + 5
#	else:
#		newTargetPosition.y = movementTarget.y - 5
	
	navigationAgent.target_position = newTargetPosition

#func attack() -> void:
#	if leftOf(global_position, enemyTarget.global_position):
#		$AnimationPlayer.play("swingLeft")
#	else:
#		$AnimationPlayer.play("swingRight")

func attack() -> void:
	var weaponAnimationInstance = weaponAnimation.instantiate()
	weaponAnimationInstance.global_position = enemyTarget.global_position
	if leftOf(global_position, enemyTarget.global_position):
#		weaponAnimationInstance.global_position.x = weaponAnimationInstance.global_position.x - 1
		get_parent().add_child(weaponAnimationInstance)
		weaponAnimationInstance.animationPlayer.play("SwingLeft") 
		enemyTarget.hurt(5)
	else:
#		weaponAnimationInstance.global_position.x = weaponAnimationInstance.global_position.x + 1
		get_parent().add_child(weaponAnimationInstance)
		weaponAnimationInstance.animationPlayer.play("SwingRight")

func findClosestEnemy() -> void:
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if enemy.global_position.distance_squared_to(global_position) <= sightRange * sightRange:
			enemyTarget = enemy
			setMovementTarget(enemyTarget.global_position)
			state = States.CHASE
	

func setIdle() -> void: # move to inheritence later
	$AnimationPlayer.play("idle")
	state = States.IDLE


func _on_attack_cooldown_timeout() -> void:
	attack()
