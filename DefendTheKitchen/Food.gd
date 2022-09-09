extends KinematicBody2D

var direction = Vector2.ZERO;
export var speed = 1000.0;
export var rotationSpeed = 2.0;
var screen_size = Vector2.ZERO;


func _ready():
	screen_size = get_viewport_rect().size;

func _process(_delta):
	if position.x > screen_size.x or position.x < 0 or position.y > screen_size.y or position.y < 0:
		destroy();
	
func start():
	pass
	
func destroy():
	queue_free();
