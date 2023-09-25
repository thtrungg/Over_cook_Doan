extends CharacterBody2D

@export var movement_speed: float = 100.0

var current_state = IDLE
var dir = Vector2.RIGHT

@export var movement_taget: Node2D
@export var navigatiton_agent: NavigationAgent2D

func _ready():
	randomize()
	navigatiton_agent.path_desired_distance = 4.0
	navigatiton_agent.target_desired_distance = 4.0
	
	call_deferred("actor_setup")
	
func actor_setup():
	await get_tree().physics_frame
	
	set_movement_target(movement_taget.position)
	
func set_movement_target(target_point: Vector2):
	navigatiton_agent.target_position = target_point

 
 
enum {
	IDLE,
	WALK,
	NEW_DIR,
	BACK_IDLE,
	BACK_WALK
}


func  _physics_process(delta):
	if navigatiton_agent.is_navigation_finished():
		return
		
	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2  = navigatiton_agent.get_next_path_position()
	
	var new_velocity: Vector2 = next_path_position - current_agent_position
	new_velocity = new_velocity.normalized()
	new_velocity = new_velocity * movement_speed
	
	velocity = new_velocity
	
	if current_state == 0:
		$AnimatedSprite2D.play("idle")
	elif current_state != 0:
		$AnimatedSprite2D.play("walk")
		#applies movement
	move_and_slide() 
	
	
	match current_state:
		IDLE:
			pass
		WALK:
			walk(delta)

func walk(delta):
	if dir.x == -1:
		$AnimatedSprite2D.flip_h = false
	elif dir.x == 1:
		$AnimatedSprite2D.flip_h = true
	elif dir.y == -1:
		$AnimatedSprite2D.play("back_walk")


