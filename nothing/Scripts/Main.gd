extends Node2D

var score = 0

@export var particle_scene: PackedScene;

@onready var field: Sprite2D = get_node("Field")

var is_pressed: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _spawn_particle_pair() -> void:
	var velocity = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	var mirror_velocity = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	var speed = 100
	var seconds = 2

	var middle = get_viewport().get_mouse_position()

	var particle_instance = particle_scene.instantiate() as Particle
	particle_instance.position = middle - velocity*speed*seconds
	particle_instance.direction = velocity
	particle_instance.speed = speed
	particle_instance.anti_particle = false
	add_child(particle_instance)


	var mirror_particle = particle_scene.instantiate() as Particle
	mirror_particle.position = middle - mirror_velocity*speed*seconds
	mirror_particle.direction = mirror_velocity
	mirror_particle.speed = speed
	mirror_particle.anti_particle = true
	add_child(mirror_particle)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		var position = get_viewport().get_mouse_position()
		var position_uv = position / get_viewport_rect().size
		
		if mouse_event.is_pressed():
			print(position_uv)
			field.material.set_shader_parameter("target", position_uv)
		
		if mouse_event.is_pressed() and !is_pressed:
			is_pressed = true
			
			_spawn_particle_pair()
		if event.is_released():
			is_pressed = false
			field.material.set_shader_parameter("target", Vector2(-1,-1))
