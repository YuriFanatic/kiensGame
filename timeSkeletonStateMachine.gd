extends CharacterBody3D

# list of states
enum {
	IDLE,
	ATTACK,
	STUNNED
}

var state = IDLE
var player = null
var target
var zigzag_time = 30000000.0
var rng = RandomNumberGenerator.new()
var health = 200
const TURN_SPEED = 10
const SPEED = 4.0

signal skeleton_hit

@export var player_path : NodePath

@onready var nav_agent = $NavigationAgent3D

@onready var raycast = $RayCast3D
@onready var ap = $AnimationPlayer
@onready var eyes = $eyes
@onready var shootTimer = $shootTimer
@onready var strafeTimer = $strafeTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_node(player_path)
	
	
# if player enters sight range look at player
func _on_sight_range_body_entered(body):
		if body.is_in_group("Player"):
			state = ATTACK
			target = body
			shootTimer.start()


func _on_sight_range_body_exited(body):
	state = IDLE
	shootTimer.stop()
	
	
func _on_shoot_timer_timeout():
	if raycast.is_colliding():
		var hit = raycast.get_collider()
		if hit.is_in_group("Player"):
			player.hit()
			print("hit")
	
func _on_strafe_timer_timeout():
	# adds sideways strafing
	#print("time!")
	#var start_dir = eyes.transform.origin - player.transform.origin
	#var rand_start_zigzag_time = rng.randf_range(0.0, 3.0)
	#var t = sign(fposmod(rand_start_zigzag_time + Time.get_ticks_msec() / (1000.0 * zigzag_time), 2.0) - 1.0)
	#var side_vec = global_transform.basis.x * t
	#velocity = (velocity + side_vec).normalized() * SPEED
	pass
	
	

func _process(delta):
	

	match state:
		IDLE:
			ap.play("idle")
		
		ATTACK:
			ap.play("idle")
			# eyes will look at player 
			eyes.look_at(Vector3(target.global_transform.origin), Vector3.UP)
			rotate_y(deg_to_rad(eyes.rotation.y * TURN_SPEED))
			
			#go towards player
			velocity = Vector3.ZERO
			nav_agent.set_target_position(player.global_transform.origin)
			var next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
			
		
				
			
				
			move_and_slide()
			
		
		STUNNED:
			ap.play("run")
			


