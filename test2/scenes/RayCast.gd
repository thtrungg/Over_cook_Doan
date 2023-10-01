extends RayCast2D

var character_body : CharacterBody2D

func _ready():
	connect("body_entered", self, "_on_RayCast2D_body_entered")

func _on_RayCast2D_body_entered(body):
	# Kiểm tra xem va chạm có phải là Node Meat không.
	if body is StaticBody2D and body.name == "Meat":
		# Lấy vị trí của Meat và gửi nó đến CharacterBody2D để điều hướng.
		character_body.navigate_to_meat(body.global_position)

func set_character_body(character):
	character_body = character
