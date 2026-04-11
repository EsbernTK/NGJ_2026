extends TextureButton
class_name SkillNode

enum UpgradeType {SPAWNRATE, ANNIHILATION_POINTS, NONE}
# Variables
@onready var SkillLevel: Label = $SkillLevel
@onready var SkillBranch: Line2D = $SkillBranch
@export var MaxLevel: int = 3
@export var HoverText: String = ""
@export var type: UpgradeType = UpgradeType.NONE

var level: int = 0:
	set(value):
		level = value
		SkillLevel.text = str(level) + "/" + str(MaxLevel)
# Ready function
func _ready() -> void:
	SkillLevel.text = str(level) + "/" + str(MaxLevel)
	var parent = get_parent() 
	if parent is SkillNode:
		SkillBranch.default_color = Color(0, 1, 1)
		#SkillBranch.add_point(self.global_position + self.size/2)
		SkillBranch.add_point(self.size/2)
		var rel_pos = parent.global_position - self.global_position + parent.size/2
		SkillBranch.add_point(rel_pos)
# Function to handle skill activation
func _on_pressed() -> void:
	level = min(level + 1, MaxLevel)
	SkillLevel.text = str(level) + "/" + str(MaxLevel)
	self.modulate = Color(0.397, 0.72, 0.371, 1.0)
	SkillBranch.default_color = Color(1, 1, 1)
	var skills = get_children()
	for skill in skills:
		if skill is SkillNode and level == MaxLevel:
			skill.disabled = false
