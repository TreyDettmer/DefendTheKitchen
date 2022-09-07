extends Node

onready var line = $Line2D;

func _on_Enemy_pathChanged(path):
	line.points = path;
