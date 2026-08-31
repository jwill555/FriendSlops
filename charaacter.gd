extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export var camera : Camera3D

var cameraTweening = false

var camLocked = false

@onready var yPivot = $YPivot
@onready var xPivot = $YPivot/XPivot

func _ready() -> void:
	set_multiplayer_authority(int(name))
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if is_multiplayer_authority():
		camera.current = true

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		yPivot.rotate_y(-event.relative.x * 0.01)
		xPivot.rotate_x(-event.relative.y * 0.01)
		#var inputVelocity = Input.get_last_mouse_velocity()
		#if inputVelocity.x > 100:
			#$Pivot.rotation_degrees.y -= 5
		#elif inputVelocity.x < -100:
			#$Pivot.rotation_degrees.y += 5
		#if inputVelocity.y > 100:
			#$Pivot.rotation_degrees.x -= 1
		#elif inputVelocity.y < -100:
			#$Pivot.rotation_degrees.x += 1
		#


func _physics_process(delta: float) -> void:
	
	if is_multiplayer_authority():
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta
		if Input.is_action_just_pressed("escape"):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			camLocked = true
		
		
		# Handle jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_back")
		var direction = (yPivot.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
			SetFov(80)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
			ResetFov()
		move_and_slide()
	



func SetFov(value):
	if cameraTweening == false:
		cameraTweening = true
		var tween = TweenManager.TweenProperty(camera,"fov",value,0.2,Tween.TRANS_LINEAR)
		await tween.finished
		cameraTweening = false

func ResetFov():
	if cameraTweening == false:
		cameraTweening = true
		var tween = TweenManager.TweenProperty(camera,"fov",70,0.2,Tween.TRANS_LINEAR)
		await tween.finished
		cameraTweening = false
