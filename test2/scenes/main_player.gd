extends CharacterBody2D

enum CharacterState {
	IDLE,
	MOVING,
	CARRYING_KNIFE,
	CHOPPING_MEAT
}

var move_speed : float = 100
var character_state : CharacterState = CharacterState.IDLE
var original_position : Vector2
var target_position : Vector2
var carrying_knife : bool = false
var chop_count : int = 0

const MOVE_SPEED = 200

@onready var raycast : RayCast2D = $RayCast

func _ready():
	raycast.set_enabled(false)
	original_position = global_position  # Lưu vị trí ban đầu
	set_process(true)

func _process(delta):
	match character_state:
		CharacterState.IDLE:
			if not carrying_knife:
				if raycast.is_colliding():
					var body = raycast.get_collider()
					if body is StaticBody2D and body.name == "Meat":
						target_position = body.global_position
						moveTowards(target_position)
						character_state = CharacterState.MOVING
				else:
					raycast.set_enabled(true)
					if global_position.distance_to(original_position) > 10:
						moveTowards(original_position)  # Quay lại vị trí ban đầu

		CharacterState.MOVING:
			if global_position.distance_to(target_position) < 10:
				character_state = CharacterState.CARRYING_KNIFE
				spawnKnife()
			else:
				moveTowards(target_position)

func moveTowards(target_position):
	var direction = (target_position - global_position).normalized()
	var velocity = direction * MOVE_SPEED
	move_and_slide()

func spawnKnife():
	var knife_scene = preload("res://scenes/knife.tscn")
	var knife = knife_scene.instance()
	knife.global_position = global_position
	get_tree().get_root().add_child(knife)

func startChoppingMeat():
	var bodies = get_slide_collision_count()
	for i in range(bodies):
		var body = get_slide_collision(i)
		if body is StaticBody2D and body.name == "Meat":
			character_state = CharacterState.CHOPPING_MEAT

func chopMeat():
	pass

func _on_RayCast2D_body_entered(body):
	if body is StaticBody2D and body.name == "Meat":
		carrying_knife = true
		chop_count += 1
