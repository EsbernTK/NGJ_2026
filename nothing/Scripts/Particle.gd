extends Node2D
class_name Particle


# Export variables for particle properties
@export var lifetime: float = 2.0  # Lifetime of the particle in seconds
@export var speed: float = 100.0  # Speed of the particle in pixels per second
@export var direction: Vector2 = Vector2(0, 1)  # Direction of movement (default is downwards)
@export var anti_particle: bool = false  #is antiparticle

var time_alive: float = 0.0  # Time the particle has been alive

var viewport_size: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Particle created")
	viewport_size = get_viewport_rect().size
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += direction * delta * speed  # Move in the specified direction at the specified speed

	# Check if the particle has moved off-screen

	if position.y > viewport_size.y or position.x < 0 or position.x > viewport_size.x or position.y < 0:
		queue_free()
		print("Particle removed")
	
	time_alive += delta
	#if time_alive >= lifetime:
	#	queue_free()  # Remove the particle from the scene after its lifetime expires


func _on_area_2d_area_entered(area: Area2D) -> void:
	# Check if the entered area belongs to another Particle instance.
	var other_particle := area.get_parent() as Particle
	if other_particle == null or other_particle == self:
		return

	print("Particle collided with particle")
	if anti_particle != other_particle.anti_particle:
		queue_free()  # Remove the particle on collision with another particle
