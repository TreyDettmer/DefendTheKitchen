extends KinematicBody2D


export var speed = 400.0;
var screen_size = Vector2.ZERO;
var direction = Vector2.ZERO;
var aimDirection = Vector2.ZERO;
var foods = {
	"pizza" : preload("res://Pizza.tscn")
}



func _ready():
	screen_size = get_viewport_rect().size;


func _process(_delta):
	GetInput();

func GetInput():
	direction = Vector2.ZERO;
	if Input.is_action_pressed("move_right"):
		direction.x += 1;
	if Input.is_action_pressed("move_left"):
		direction.x -= 1;
	if Input.is_action_pressed("move_down"):
		direction.y += 1;
	if Input.is_action_pressed("move_up"):
		direction.y -= 1;
	aimDirection = (get_global_mouse_position() - global_position).normalized();
	if Input.is_action_just_pressed("mouse_click"):
		ThrowFood();
		

func _physics_process(_delta):
	var _newVelocity = move_and_slide(direction * speed)
	# keep player within screen
	position.x = clamp(position.x,0,screen_size.x);
	position.y = clamp(position.y,0,screen_size.y);

func ThrowFood():
	var b = foods["pizza"].instance();
	b.direction = aimDirection;
	owner.add_child(b);
	b.global_position = global_position;
	
