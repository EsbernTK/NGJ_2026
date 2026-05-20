extends Node

enum UpgradeType {SPAWN_PER_SECOND, ANNIHILATION_POINTS, NONE, WIN}
enum CostType {ESCAPED, ANNIHILATED, NONE}

var CostNames: Dictionary[CostType, String] = {
	CostType.ESCAPED: "Escaped Particles",
	CostType.ANNIHILATED: "Annihilated Particles",
	CostType.NONE: "BAD UPGRADE"
}
