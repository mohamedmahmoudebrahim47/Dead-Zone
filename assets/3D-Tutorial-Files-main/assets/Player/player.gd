extends CharacterBody3D

var SPEED = 8.0
var JUMP_VELOCITY = 4.5
var gravity = -9.8
var sensitivity = 0.001
var health = 5
@onready var head: Node3D = $head
@onready var camera_3d: Camera3D = $head/Camera3D



@onready var weapon_raycast: Node3D = $head/Camera3D/weapon/RayCast3D
@onready var weapon_animation: AnimationPlayer = $head/Camera3D/weapon/AnimationPlayer
var bullets_left = 50
var bullet = preload("res://assets/3D-Tutorial-Files-main/assets/Player/bullet.tscn")

var can_shoot = true

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Force the variables to have real numbers on launch
	SPEED = 8.0
	JUMP_VELOCITY = 4.5
	gravity = -9.8
	sensitivity = 0.004
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * sensitivity)
		camera_3d.rotate_x(-event.relative.y * sensitivity)
		camera_3d.rotation.x = clamp(camera_3d.rotation.x, deg_to_rad(-40), deg_to_rad(60))
	pass

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	$head/Camera3D/Label.text = str(bullets_left) + " / 50"
	$head/Camera3D/Label2.text = str(health) + " /5"
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_pressed("shoot") and bullets_left > 0 and can_shoot:
		weapon_animation.play("shoot")
		shoot()

	if Input.is_action_just_pressed("reload"):
		weapon_animation.play("reload")
		bullets_left = 50
	
	if health == 0:
		get_tree().reload_current_scene()
		
 	# Count active zombies in the scene
	var zombie_count = 0
	for child in get_parent().get_children():
		if "Zombie" in child.name:
			zombie_count += 1
			
	
	# Win condition
	if zombie_count == 0:
		$head/Camera3D/Label.text = "WINNER WINNER ZOMBIES KILLER! Press Enter to Restart"
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if Input.is_key_pressed(KEY_ENTER) or Input.is_key_pressed(KEY_KP_ENTER):
			get_tree().reload_current_scene()
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "Right", "Up", "Down")
	var direction := (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()



func damage():
	health = max(0, health - 1)
	if health == 0:
	
		pass





func shoot():
	bullets_left -= 1
	can_shoot = false # Lock shooting immediately
	
	var bullet_instance = bullet.instantiate()
	bullet_instance.position = weapon_raycast.global_position
	bullet_instance.transform.basis = weapon_raycast.global_transform.basis
	get_parent().add_child(bullet_instance)
	
	# Wait for 0.2 seconds before letting the player shoot again
	await get_tree().create_timer(0.2).timeout
	can_shoot = true
	
	pass
