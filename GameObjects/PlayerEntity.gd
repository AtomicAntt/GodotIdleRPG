extends CharacterBody2D

enum States {IDLE, WANDER, CHASE, COMBAT, DEAD}
var state: States

var totalHealth: int = 100
var health: int = 100

var currentLevel: int = 1
var expRequired: int = 20
var exp: int = 0

var speed: float = 60.0
var sightRange: float = 200.0
var attackRange: float = 30.0
var enemyTarget: CharacterBody2D

@onready var navigationAgent: NavigationAgent2D = $NavigationAgent2D

@onready var healthBarUnder = $Control/HealthBarUnder
@onready var healthBarOver = $Control/HealthBarOver
@onready var nameLabel = $Control/NameLabel
@onready var levelLabel = $Control/LevelLabel

@onready var main = get_tree().get_nodes_in_group("main")[0]

@onready var weaponAnimation := preload("res://GameObjects/WeaponAnimation.tscn")

@onready var usernameGenerator := get_tree().get_nodes_in_group("usernameGenerator")[0]

func _ready() -> void:
	$AnimationPlayer.play("idle")
	nameLabel.text = usernameGenerator.returnRandomUsername()

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
				faceEnemy()
				if navigationAgent.is_navigation_finished() and closeToEnemy():
					attack() # attack initially right away
					engageCombat() # Which will set state to combat
					return # to prevent playing that "run" animation again
				
				$AnimationPlayer.play("run")
				var currentAgentPosition: Vector2 = global_position
				var nextPathPosition: Vector2 = navigationAgent.get_next_path_position()
				
				var newVelocity: Vector2 = (nextPathPosition - currentAgentPosition).normalized() * speed
				velocity = newVelocity
				move_and_slide()
			else:
#				state = States.IDLE
				setIdle()
#				print("Enemy is not valid, returning to idle")
		States.COMBAT:
			if not is_instance_valid(enemyTarget):
#				state = States.IDLE
				setIdle()
#				print("Enemy is not valid, returning to idle")
				

func hurt(damage: int) -> void:
	if not isDead():
		health -= damage
		healthBarOver.value = (float(health) / float(totalHealth)) * 100.0
		
		var tween := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(healthBarUnder, "value", healthBarOver.value, 0.4)
		
		if health > 0:
			$AnimationPlayer.play("hurt")
		else:
			state = States.DEAD
			$AnimationPlayer.play("hurtDeath")

func death() -> void: # called by hurtDeath animation from animationplayer 
	$AnimationPlayer.play("death")

func isDead() -> bool:
	if state == States.DEAD:
		return true
	return false
	
func calculateexpRequiredForLevel(levelTo: int) -> int:
	return 10 * pow((levelTo - 1), 2)+ 10 * (levelTo - 1)

func giveExp(expAmount: int) -> void:
	exp += expAmount
#	print("giving " + str(nameLabel.text) + " " + str(expAmount) + " exp, now " + str(nameLabel.text) + " has " + str(exp) + " exp")
	main.addExperience(expAmount)
	levelCheck()

func levelCheck() -> void:
	while exp >= expRequired:
		exp -= expRequired
		currentLevel += 1
		main.addLevel()
		expRequired = calculateexpRequiredForLevel(currentLevel + 1)
		levelLabel.text = "level " + str(currentLevel)
#		print(nameLabel.text + " is now level " + str(currentLevel))
#		print("the experience required is " + str(expRequired) + " now")
		
	
#	if exp >= expRequired: # To account for multiple level-ups
#		levelCheck()

func engageCombat() -> void:
	if is_instance_valid(enemyTarget):
		state = States.COMBAT
		$AnimationPlayer.play("idle")
#		print("now engaging in combat with enemy!")
		
		$AttackCooldown.start()
		
		faceEnemy()
		
		# Check if enemy pos left of player pos
		if leftOf(enemyTarget.global_position, global_position):
			enemyTarget.getSprite().flip_h = true
	else:
		state = States.IDLE



func closeToEnemy() -> bool:
	if is_instance_valid(enemyTarget):
		if enemyTarget.global_position.distance_to(global_position) <= attackRange:
			return true
	return false

func leftOf(object: Vector2, target: Vector2) -> bool:
	if target.x < object.x:
		return true
	return false

func faceEnemy() -> void:
	if not is_instance_valid(enemyTarget):
		return
	
	if leftOf(global_position, enemyTarget.global_position):
		$Sprite2D.flip_h = true
	else:
		$Sprite2D.flip_h = false

#func actorSetup() -> void:
#	await get_tree().physics_frame
#	setMovementTarget()

func setMovementTarget(movementTarget: Vector2, enemy: CharacterBody2D) -> void:
	# To make sure the player is to the left or right of the enemy (because attacks would look weird otherwise)
	var newTargetPosition: Vector2 = movementTarget
	# if close to left w/ unoccupied left side OR have no choice but to go to the left because enemy is at the right..
	if (global_position.x <= movementTarget.x and enemy.atLeft == false) or (enemy.atRight == true and enemy.atLeft == false):
		enemy.atLeft = true
		newTargetPosition.x = movementTarget.x - 20
#		print("locking in the left side for " + str(enemy))
	# if close to the right w/ unoccupied right OR have no choice but to go to the right because enemy is at the left
	elif (global_position.x > movementTarget.x and enemy.atRight == false) or (enemy.atRight == false and enemy.atLeft == true):
		enemy.atRight = true
		newTargetPosition.x = movementTarget.x + 20
#		print("locking in the right side for " + str(enemy))
		
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
	if closeToEnemy() and not enemyTarget.isDead():
		var weaponAnimationInstance = weaponAnimation.instantiate()
		weaponAnimationInstance.global_position = enemyTarget.global_position
		weaponAnimationInstance.position.y = weaponAnimationInstance.position.y - 5
		if leftOf(global_position, enemyTarget.global_position):
	#		weaponAnimationInstance.global_position.x = weaponAnimationInstance.global_position.x - 1
			get_parent().add_child(weaponAnimationInstance)
			weaponAnimationInstance.animationPlayer.play("SwingLeft") 
		else:
	#		weaponAnimationInstance.global_position.x = weaponAnimationInstance.global_position.x + 1
			get_parent().add_child(weaponAnimationInstance)
			weaponAnimationInstance.animationPlayer.play("SwingRight")
	
		enemyTarget.hurt(5, self)

func findClosestEnemy() -> void:
	var closestEnemy: CharacterBody2D = null
	
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if enemy.global_position.distance_squared_to(global_position) <= sightRange * sightRange and enemy.isAvailable():
			if closestEnemy != null:
				if enemy.global_position.distance_to(global_position) < closestEnemy.global_position.distance_to(global_position):
					closestEnemy = enemy
			else:
				closestEnemy = enemy
	
	if closestEnemy != null:
		enemyTarget = closestEnemy
		setMovementTarget(enemyTarget.global_position, enemyTarget)
		state = States.CHASE

func setIdle() -> void: # move to inheritence later
	state = States.IDLE
	$AttackCooldown.stop()
	$AnimationPlayer.play("idle")

# called by hurt animation after its played but it doesnt always mean going back to idle state
func playIdle() -> void:
	$AnimationPlayer.play("idle")

func _on_attack_cooldown_timeout() -> void:
	if is_instance_valid(enemyTarget) and state == States.COMBAT:
		attack()
	else:
		$AttackCooldown.stop()
