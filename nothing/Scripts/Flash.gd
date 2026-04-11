extends Node2D


@export var lifetime = 0.5
@export var up_ramp = 0.1
@export var down_ramp = 0.2

var life = 0.0

@onready var sprite = get_node("Sprite2D")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scale = Vector2(0.1, 0.1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	life += delta
	var dl = life/lifetime
	var du = life/up_ramp
	var dd = (life - down_ramp) / down_ramp
	
	if du < 1.0:
		scale = Vector2(du, du)
	elif dd > 0 and dd < 1:
		scale = Vector2(1-dd, 1-dd)
		
	if life >= lifetime:
		queue_free()
