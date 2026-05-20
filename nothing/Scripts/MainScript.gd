extends Node2D
class_name MainScript

var escaped_particles: float = 0:
	set(value):
		escaped_particles = value
		escaped_score_label.text = "Escaped Particles: " + str(escaped_particles)
var annihilated_particles: float = 0:
	set(value):
		annihilated_particles = value
		annihilated_score_label.text = "Annihilated Particles: " + str(annihilated_particles)

var points_per_annihilation: float = 0.0

@export var particle_scene: PackedScene
@export var anti_particle_scene: PackedScene

@onready var field: Sprite2D = get_node("Field")

@onready var particle_area: Node2D = get_node("Particles")

@onready var escaped_score_label: RichTextLabel = get_node("Scores/EscapedScoreLabel")
@onready var annihilated_score_label: RichTextLabel = get_node("Scores/AnnihilatedScoreLabel")
@onready var spawn_rate_label: RichTextLabel = get_node("Scores/SpawnRateLabel")

@onready var upgradeTree: Control = get_node("UpgradeTree")

@onready var winText: RichTextLabel = get_node("WinText")
@onready var tutorialText: RichTextLabel = get_node("TutorialText")


var in_menu: bool = false
var is_pressed: bool = false

var base_strength: float = 0.0:
	set(value):
		base_strength = value
		field.set_instance_shader_parameter("Strength", base_strength)
var base_scale: float = 2.5:
	set(value):
		base_scale = value
		field.set_instance_shader_parameter("Scale", base_scale)
var target_scale: float = 2.5

var spawntime: float = 0.0
var spawn_per_second:float = 0.0:
	set(value):
		spawn_per_second = value
		spawn_rate_label.text = "Particle Pairs Rate: " + str(round_to_dec(estimated_spawn_per_second,2)) + "/s"
		if value != 0.0:
			max_spawntime = 1/value
		else:
			max_spawntime = INF

var estimated_spawn_per_second: float = 0.0:
	set(value):
		estimated_spawn_per_second = value
		spawn_rate_label.text = "Particle Pairs Rate: " + str(round_to_dec(estimated_spawn_per_second,2)) + "/s"

var click_times: Array[float] = []

var max_spawntime: float = INF

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	winText.visible = false
	tutorialText.visible = true
	#add_escaped_particles(0)
	#add_annihilated_particles(0)


func get_currency(t: Enums.CostType) -> float:
	match t:
		Enums.CostType.ESCAPED: 
			return escaped_particles
		Enums.CostType.ANNIHILATED: 
			return annihilated_particles
		_:
			return -1.0

func add_currency(t: Enums.CostType, value: float):
	match t:
		Enums.CostType.ESCAPED: 
			escaped_particles += value
		Enums.CostType.ANNIHILATED: 
			annihilated_particles += value

func win():
	print("Congratulations, you won!")
	winText.visible = true

func apply_upgrade(t: Enums.UpgradeType, value: float) -> void:
	print(t, Enums.UpgradeType.SPAWN_PER_SECOND)
	match t:
		Enums.UpgradeType.SPAWN_PER_SECOND: 
			spawn_per_second += value
			base_strength += value/10
			print("spawn per second now: " + str(spawn_per_second))
		Enums.UpgradeType.ANNIHILATION_POINTS: 
			points_per_annihilation += value
		Enums.UpgradeType.WIN:
			win()

func get_upgrade(t: Enums.UpgradeType) -> float:
	match t:
		Enums.UpgradeType.SPAWN_PER_SECOND: 
			return spawn_per_second
		Enums.UpgradeType.ANNIHILATION_POINTS: 
			return points_per_annihilation
		Enums.UpgradeType.WIN:
			return -1.0
		_:
			return -1.0

func add_particle(particle: Node2D):
	particle_area.add_child(particle)

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
	add_particle(particle_instance)


	var mirror_particle = anti_particle_scene.instantiate() as Particle
	mirror_particle.position = particle_position - mirror_velocity*speed*seconds
	mirror_particle.direction = mirror_velocity
	mirror_particle.speed = speed
	mirror_particle.anti_particle = true
	mirror_particle.base_color = Color(0.936, 0.165, 0.341, 1.0)
	mirror_particle.main_scene = self
	add_particle(mirror_particle)


func _process(delta: float) -> void:
	spawntime += delta
	if max_spawntime > 0.0 and max_spawntime != INF:
		while spawntime/max_spawntime >= 1.0:
			var particle_position = Vector2(randf_range(0, 1), randf_range(0, 1)) * get_viewport_rect().size
			_spawn_particle_pair(particle_position)
			spawntime = max(spawntime - max_spawntime, 0)
			
		
	if base_scale < target_scale:
		base_scale += (target_scale - base_scale) * delta
		field.set_instance_shader_parameter("Scale", base_scale)
	
	if click_times.size() > 0:
		var cur_time = Time.get_ticks_msec() / 1000
		var num_seconds_to_smooth = 3.0
		while  click_times.size() > 0 and  cur_time - click_times[0] > num_seconds_to_smooth:
			click_times.pop_front()
		
		estimated_spawn_per_second = spawn_per_second + click_times.size() / num_seconds_to_smooth
		
	
func add_escaped_particles(s: float) -> void:
	escaped_particles += s
	escaped_score_label.text = "Escaped Particles: " + str(escaped_particles)

func add_annihilated_particles(s: float) -> void:
	annihilated_particles += s
	annihilated_score_label.text = "Annihilated Particles: " + str(annihilated_particles)
	
	if tutorialText.visible:
		tutorialText.text = "Great job! \n The particles self annihilated, leaving nothing behind \n In this game we collect that nothing to use for upgrades \n When you have collected 10 nothings, head to the upgrade menu"

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		var particle_position = get_viewport().get_mouse_position()
		var position_uv = particle_position / get_viewport_rect().size
		
		particle_position += Vector2(randf_range(-1, 1), randf_range(-1, 1)) * 20
		#if mouse_event.is_pressed():
			#field.material.set_shader_parameter("target", position_uv)
			#field.set_instance_shader_parameter("Strength", base_strength * 2.0)
			
		
		if mouse_event.is_pressed() and !is_pressed and !in_menu:
			is_pressed = true
			#base_strength += 0.01
			#target_scale += 0.01
			click_times.append(Time.get_ticks_msec() / 1000)
			_spawn_particle_pair(particle_position)
			
			
		if event.is_released():
			is_pressed = false
			#field.material.set_shader_parameter("target", Vector2(-1,-1))
			#field.set_instance_shader_parameter("Strength", base_strength)
			#field.set_instance_shader_parameter("Scale", base_scale)


func _on_upgrade_menu_button_button_down() -> void:
	upgradeTree.visible = !upgradeTree.visible
	in_menu = upgradeTree.visible
	tutorialText.visible = false
