extends Node2D

@export var dmg = 25

func _on_body_entered(body: Node) -> void:
	if body.get_parent().name.begins_with("Player"):
		body.get_parent().damage(dmg)
