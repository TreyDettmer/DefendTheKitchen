extends KinematicBody2D

onready var navigationAgent = $NavigationAgent2D;

signal pathChanged(path);

export (NodePath) var playerNodePath;
var player = null;
var velocity = Vector2.ZERO;
export var maxSpeed = 1.0;

func _ready():
	player = get_node(playerNodePath);
	navigationAgent.set_target_location(player.global_position);
	navigationAgent.max_speed = maxSpeed;


func _process(delta):
	CalculateMovement(delta);
		

func CalculateMovement(delta):
	if player != null:
		# move towards the player
		navigationAgent.set_target_location(player.global_position);
		var moveDirection = position.direction_to(navigationAgent.get_next_location());
		velocity = moveDirection * maxSpeed * delta;
		navigationAgent.set_velocity(velocity);

# signal called by set_velocity() method of navigationAgent
func _on_NavigationAgent2D_velocity_computed(safe_velocity):
	velocity = safe_velocity;
	var _newVelocity = move_and_slide(velocity);

# emit information needed to draw enemy's desired path
func _on_NavigationAgent2D_path_changed():
	emit_signal("pathChanged",navigationAgent.get_nav_path());
