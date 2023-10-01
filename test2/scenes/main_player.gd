extends CharacterBody2D

enum CharacterState {
	IDLE,
	MOVING,
	CARRYING_KNIFE,
	CHOPPING_MEAT
}

var move_speed : float = 100
var character_state : CharacterState = CharacterState.IDLE
var knife_scene : PackedScene = preload("res://scenes/knife.tscn")
var meat_scene : PackedScene = preload("res://scenes/meat.tscn")

var chop_count : int = 0

@onready var raycast : RayCast2D = $RayCast

var MOVE_SPEED : float = 200
var original_position : Vector2

func _ready():
	raycast.set_enabled(false)
	original_position = global_position  # Lưu vị trí ban đầu của CharacterBody2D
	set_process(true)

func _process(delta):
	var carrying_knife : bool = false
	match character_state:
		CharacterState.IDLE:
			if not carrying_knife:
				if raycast.is_colliding():
					var target_meat = raycast.get_collider()
					moveTowards(target_meat.global_position)
				else:
					raycast.set_enabled(true)
					if global_position.distance_to(original_position) > 10:
						# Nếu CharacterBody2D đã đi xa so với vị trí ban đầu, quay lại vị trí ban đầu
						moveTowards(original_position)
		CharacterState.MOVING:
			if global_position.distance_to(raycast.global_position) < 10:
				character_state = CharacterState.CARRYING_KNIFE
				spawnKnife()
			else:
				moveTowards(raycast.global_position)
		CharacterState.CARRYING_KNIFE:
			if Input.is_action_pressed("chop"):
				startChoppingMeat()
		CharacterState.CHOPPING_MEAT:
			if chop_count < 3:
				chopMeat()
			else:
				var slice_scene = preload("res://scenes/slice.tscn").instance()
				slice_scene.global_position = raycast.get_collision_point()
				get_tree().get_root().add_child(slice_scene)
				chop_count = 0
				character_state = CharacterState.IDLE
				carrying_knife = false

func moveTowards(target_position):
	var direction = (target_position - global_position).normalized()
	var velocity = direction * MOVE_SPEED
	move_and_slide()

func spawnKnife():
	var knife = knife_scene.instance()
	knife.global_position = global_position
	add_child(knife)

func startChoppingMeat():
	var bodies = get_slide_collision_count()
	for i in range(bodies):
		var body = get_slide_collision(i)
		if body is StaticBody2D and body.name == "Meat":
			var meat_instance = meat_scene.instance()
			meat_instance.global_position = body.global_position
			get_tree().get_root().add_child(meat_instance)
			body.queue_free()
			chop_count += 1

func chopMeat():
	pass
