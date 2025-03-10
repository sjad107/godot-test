extends CharacterBody2D

const SPEED = 300.0
const ROLL_SPEED = 500.0

var is_rolling = false
var direction: Vector2
var roll_direction: Vector2  # <-- NEW: Store the roll direction
var is_attacking = false
func _physics_process(delta: float) -> void:
	if is_rolling:
		# Use the locked roll direction, not the updated "direction"
		velocity = roll_direction * ROLL_SPEED
		move_and_slide()
		return  # <-- Exit early to ignore normal movement input
	
	# Normal movement (only runs when not rolling)
	direction = Input.get_vector("move_right", "move_left", "move_up", "move_down")
	
	velocity = direction.normalized() * SPEED
	
	if velocity.length() > 0.0:
		$AnimatedSprite2D.play("RUN")
		if velocity.x < 0:
			$Sword.position.x=-50.0
			$AnimatedSprite2D.flip_h = true
			
		elif velocity.x > 0:
			$Sword.position.x=50.0
			$AnimatedSprite2D.flip_h = false
	else:
		$AnimatedSprite2D.play("IDLE")
	
	move_and_slide()

	# Start roll
	if Input.is_action_just_pressed("roll") and $RollCooldown.is_stopped() and not is_rolling:
		roll()
		
	if Input.is_action_just_pressed("attack") and $Sword.position.x<0 and not is_attacking:
		$Sword/AnimationPlayer.play("Attack_Left")
		is_attacking=true
		await get_tree().create_timer($Sword/AnimationPlayer.current_animation_length).timeout
		$Sword/AnimationPlayer.play("reset")
		is_attacking=false
		
	if Input.is_action_just_pressed("attack") and $Sword.position.x>0 and not is_attacking:
		$Sword/AnimationPlayer.play("Attack_Right")
		is_attacking=true
		await get_tree().create_timer($Sword/AnimationPlayer.current_animation_length).timeout
		$Sword/AnimationPlayer.play("reset")
		is_attacking=false

func roll():
	is_rolling = true
	$AnimatedSprite2D.play("ROLL")
	$RollTime.start()
	
	# Lock the roll direction at the start of the roll
	roll_direction = direction.normalized()
	if roll_direction == Vector2.ZERO:  # If no input, roll in facing direction
		roll_direction = Vector2.RIGHT if !$AnimatedSprite2D.flip_h else Vector2.LEFT
	print($AnimatedSprite2D.animation)
	# Wait for roll duration
	await $AnimatedSprite2D.animation_looped
	
	# Reset after roll
	is_rolling = false
	$RollCooldown.start()
	
	
	
