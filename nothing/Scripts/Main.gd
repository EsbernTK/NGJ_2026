extends Node2D
class_name Main

var escaped_particles: int = 0
var annihilated_particles: int = 0

@export var particle_scene: PackedScene
@export var anti_particle_scene: PackedScene

@onready var field: Sprite2D = get_node("Field")

@onready var escaped_score_label: RichTextLabel = get_node("Scores/EscapedScoreLabel")
@onready var annihilated_score_label: RichTextLabel = get_node("Scores/AnnihilatedScoreLabel")

var is_pressed: bool = false

var base_strength: float = 0.0
var base_scale: float = 2.5
var target_scale: float = 2.5

var spawntime: float = 0.0
var spawn_per_second:float = 60.0
var max_spawntime: float = 1 / spawn_per_second

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_escaped_particles(0)
	pass # Replace with function body.


func _spawn_particle_pair(particle_position: Vector2) -> void:
	var velocity = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	var mirror_velocity = -velocity #Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	var speed = 100
	var seconds = 2 * (randf() + 1)/2

	var particle_instance = particle_scene.instantiate() as Particle
	particle_instance.position = particle_position - velocity*speed*seconds
	particle_instance.direction = velocity
	particle_instance.speed = speed
	particle_instance.anti_particle = false
	particle_instance.base_color = Color(0.385, 0.756, 0.948, 1.0)
	particle_instance.main_scene = self
	add_child(particle_instance)


	var mirror_particle = anti_particle_scene.instantiate() as Particle
	mirror_particle.position = particle_position - mirror_velocity*speed*seconds
	mirror_particle.direction = mirror_velocity
	mirror_particle.speed = speed
	mirror_particle.anti_particle = true
	mirror_particle.base_color = Color(0.936, 0.165, 0.341, 1.0)
	mirror_particle.main_scene = self
	add_child(mirror_particle)


func _process(delta: float) -> void:
	spawntime += delta
	if max_spawntime > 0.0:
		while spawntime/max_spawntime >= 1.0:
			var particle_position = Vector2(randf_range(0, 1), randf_range(0, 1)) * get_viewport_rect().size
			_spawn_particle_pair(particle_position)
			spawntime = max(spawntime - max_spawntime, 0)
			
		
	if base_scale < target_scale:
		base_scale += (target_scale - base_scale) * delta
		field.set_instance_shader_parameter("Scale", base_scale)
		
	
func add_escaped_particles(s: int) -> void:
	escaped_particles += s
	escaped_score_label.text = "Escaped Particles: " + str(escaped_particles)

func add_annihilated_particles(s: int) -> void:
	annihilated_particles += s
	annihilated_score_label.text = "Annihilated Particles: " + str(annihilated_particles)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		var particle_position = get_viewport().get_mouse_position()
		var position_uv = particle_position / get_viewport_rect().size
		
		particle_position += Vector2(randf_range(-1, 1), randf_range(-1, 1)) * 20
		#if mouse_event.is_pressed():
			#field.material.set_shader_parameter("target", position_uv)
			#field.set_instance_shader_parameter("Strength", base_strength * 2.0)
		
		if mouse_event.is_pressed() and !is_pressed:
			is_pressed = true
			base_strength += 0.01
			target_scale += 0.01
			
			_spawn_particle_pair(particle_position)
		if event.is_released():
			is_pressed = false
			#field.material.set_shader_parameter("target", Vector2(-1,-1))
			field.set_instance_shader_parameter("Strength", base_strength)
			field.set_instance_shader_parameter("Scale", base_scale)
