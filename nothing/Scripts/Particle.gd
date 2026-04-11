extends Node2D
class_name Particle


# Export variables for particle properties
@export var lifetime: float = 2.0  # Lifetime of the particle in seconds
@export var up_ramp = 0.1
@export var initial_size = 0.1
@export var speed: float = 100.0  # Speed of the particle in pixels per second
@export var direction: Vector2 = Vector2(0, 1)  # Direction of movement (default is downwards)
@export var anti_particle: bool = false  #is antiparticle

@export var base_color: Color = Color(1.0, 1.0, 1.0, 1.0)

@export var flash: PackedScene



var main_scene: Main

var time_alive: float = 0.0  # Time the particle has been alive

var viewport_size: Vector2

var sprite: Sprite2D

var is_coliding: bool = false



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Particle created")
	viewport_size = get_viewport_rect().size
	sprite = get_node("Sprite2D")
	var texture = sprite.texture as GradientTexture2D
	texture.gradient.set_color(0, base_color)
	scale = Vector2(initial_size, initial_size)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += direction * delta * speed  # Move in the specified direction at the specified speed

	# Check if the particle has moved off-screen
	var margin = 0.1
	var top_margin = 1 + margin
	
	if position.y > viewport_size.y*top_margin or position.x < -viewport_size.x*margin or position.x > viewport_size.x*top_margin or position.y < -viewport_size.y*margin:
		main_scene.add_escaped_particles(1)
		print("Particle removed")
		queue_free()
		
	
	time_alive += delta
	var du = time_alive / up_ramp
	if du < 1.0:
		scale = Vector2(du, du)
	else:
		scale = Vector2(1, 1)
	
	#if time_alive >= lifetime:
	#	queue_free()  # Remove the particle from the scene after its lifetime expires


func _on_area_2d_area_entered(area: Area2D) -> void:
	# Check if the entered area belongs to another Particle instance.
	var other_particle := area.get_parent() as Particle
	if other_particle == null or other_particle == self:
		return

	if anti_particle != other_particle.anti_particle and !is_coliding and !other_particle.is_coliding:
		is_coliding = true
		other_particle.is_coliding = true
		queue_free()  # Remove the particle on collision with another particle
		other_particle.queue_free()
		
		if flash != null:
			var middle = (other_particle.position - position)*0.5 + position
			var flash_instance = flash.instantiate()
			flash_instance.position = middle
			main_scene.add_child(flash_instance)
		
