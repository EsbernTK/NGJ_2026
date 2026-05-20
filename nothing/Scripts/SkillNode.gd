extends TextureButton
class_name SkillNode

# Variables
@onready var SkillLevel: Label = $SkillLevel
@onready var SkillBranch: Line2D = $SkillBranch
@onready var HoverTextLabel: Label = $HoverTextLabel
@onready var HoverTextLabelRect: ColorRect = $HoverTextLabel/ColorRect
@export var MaxLevel: int = 3
@export var HoverText: String = ""
@export var upgradeType: Enums.UpgradeType = Enums.UpgradeType.NONE
@export var upgradevalues: Array[float] = [0]
@export var costType: Enums.CostType = Enums.CostType.NONE
@export var costs: Array[float] = [0]

var costText:
	get():
		if level < MaxLevel:
			return "Cost: " + Enums.CostNames[costType] + ": " + str(costs[level])
		else:
			return "Done"
		
		
func set_hover_text_label():
	HoverTextLabel.text = HoverText + " " + upgradeText + "\n " + costText
		
var upgradeText: String:
	get():
		var cur_value = main.get_upgrade(upgradeType)
		if cur_value == -1:
			return ""
		if level < MaxLevel:
			var new_value = cur_value + upgradevalues[level]
			return str(cur_value) + " -> " + str(new_value)
		else:
			return str(cur_value)
		

@onready var main : MainScript = get_tree().root.get_child(1)

var level: int = 0:
	set(value):
		level = value
		SkillLevel.text = str(level) + "/" + str(MaxLevel)			
		set_hover_text_label()
	
		
# Ready function
func _ready() -> void:
	set_hover_text_label()
	SkillLevel.text = str(level) + "/" + str(MaxLevel)
	var parent = get_parent() 
	if parent is SkillNode:
		SkillBranch.default_color = Color(0, 1, 1)
		#SkillBranch.add_point(self.global_position + self.size/2)
		SkillBranch.add_point(self.size/2)
		var rel_pos = parent.global_position - self.global_position + parent.size/2
		SkillBranch.add_point(rel_pos)
		disabled = true
		visible = false
		
	if costs.size() != MaxLevel and costs.size() == 1:
		for i in range(MaxLevel-1):
			costs.append(costs[0])
			
	if upgradevalues.size() != MaxLevel and upgradevalues.size() == 1:
		for i in range(MaxLevel-1):
			upgradevalues.append(upgradevalues[0])
		
# Function to handle skill activation
func _on_pressed() -> void:
	
	if level < MaxLevel and main.get_currency(costType) >= costs[level]:
		main.apply_upgrade(upgradeType, upgradevalues[level])
		main.add_currency(costType, -costs[level])
		level = min(level + 1, MaxLevel)
		SkillLevel.text = str(level) + "/" + str(MaxLevel)
		self.modulate = Color(0.397, 0.72, 0.371, 1.0)
		SkillBranch.default_color = Color(1, 1, 1)
		var skills = get_children()
		for skill in skills:
			if skill is SkillNode:
				skill.disabled = false
				skill.visible = true
				skill.set_hover_text_label()
			


func _on_mouse_entered() -> void:
	HoverTextLabel.visible = true


func _on_mouse_exited() -> void:
	HoverTextLabel.visible = false


func _on_hover_text_label_resized() -> void:
	HoverTextLabelRect.size = HoverTextLabel.size + Vector2(10, 10)
	HoverTextLabel.position = -HoverTextLabel.size/2 + Vector2(size.x/2, -size.y/2)
	
