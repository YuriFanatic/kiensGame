extends CharacterBody3D

@export var animation_tree: AnimationTree

var speed
const WALK_SPEED = 10.0
const DASH_SPEED = 100.0
const JUMP_VELOCITY = 6
const SENSITIVITY = 0.001

@onready var gun_view = $SubViewportContainer/SubViewport/gunView


var crouched: bool = false
var crouch_blocked: bool = false

@export_category("Crouch Parametres")
@export var enable_crouch: bool = true
@export var crouch_toggle: bool = false
@export var crouch_collision: ShapeCast3D
@export_range(0.0,3.0) var crouch_speed_reduction = 2.0
@export_range(0.0,0.50) var crouch_blend_speed = .2
enum {GROUND_CROUCH = -1, STANDING = 0, AIR_CROUCH = 1}

# head bob variables
const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var t_bob = 0.0

# fov variables
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

signal playerHit

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var head = $head
@onready var camera = $head/Camera3D
@onready var crosshair = $SubViewportContainer/crosshair
@onready var hitmarker = $SubViewportContainer/hitmarker

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$SubViewportContainer/SubViewport.size = DisplayServer.window_get_size()
	
	crosshair.position.x = get_viewport().size.x / 2 - 32
	crosshair.position.y = get_viewport().size.y / 2 - 32
	hitmarker.position.x = get_viewport().size.x / 2 - 32
	hitmarker.position.y = get_viewport().size.y / 2 - 32
	
#interprets mouse input and limits vertical rotation
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
		gun_view.sway(Vector2(event.relative.x, event.relative.y))

	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			
	if enable_crouch:
		if event.is_action_pressed("crouch"):
			crouch()
		if event.is_action_released("crouch"):
			if !crouch_toggle and crouched:
				crouch()
				
func crouch() -> void:
	var Blend
	if !crouch_collision.is_colliding():
		if crouched:
			Blend = STANDING
		else:
			speed = WALK_SPEED
			
			if is_on_floor():
				Blend = GROUND_CROUCH
			else:
				Blend = AIR_CROUCH
		var blend_tween = get_tree().create_tween()
		blend_tween.tween_property(animation_tree,"parameters/Crouch_Blend/blend_amount",Blend,crouch_blend_speed)
		crouched = !crouched
	else:
		crouch_blocked = true

func _physics_process(delta):
	$SubViewportContainer/SubViewport/gunView.global_transform = camera.global_transform
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	# handle dash
	if Input.is_action_just_pressed("ability"):
		speed = DASH_SPEED
	else:
		speed = WALK_SPEED
		
	# handle crouching under stuff
	if crouched and crouch_blocked:
		if !crouch_collision.is_colliding():
			crouch_blocked = false
			if !Input.is_action_pressed("crouch") and !crouch_toggle:
				crouch()

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
	
		
	#head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, WALK_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	# camera.fov = lerp(camera.fov, target_fov, delta * 8.0)

	move_and_slide()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y - sin(time* BOB_FREQ) * BOB_AMP
	return pos

func hit():
	emit_signal("playerHit")

#func _shoot_revolver():
	
