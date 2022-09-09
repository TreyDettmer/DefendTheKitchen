extends KinematicBody2D

onready var navigationAgent = $NavigationAgent2D;

signal pathChanged(path);

export (NodePath) var playerNodePath;
var player = null;
var velocity = Vector2.ZERO;
export var maxSpeed = 1.0;
# since we aren't currently changing the sprite to make the enemy look fatter, we just change the size of the sprite
export var damageSpriteScaleFactor = 1.25;
var isDead = false;
var healthPoints = 3;

func _ready():
	player = get_node(playerNodePath);
	navigationAgent.set_target_location(player.global_position);
	navigationAgent.max_speed = maxSpeed;


func _process(delta):
	if isDead:
		return;
	CalculateMovement(delta);
		

func CalculateMovement(_delta):
	if player != null:
		# move towards the player
		navigationAgent.set_target_location(player.global_position);
		var moveDirection = position.direction_to(navigationAgent.get_next_location());
		velocity = moveDirection * maxSpeed;
		navigationAgent.set_velocity(velocity);
		
		
		
func takeDamage(damage):
	if not isDead:
		healthPoints -= damage;
		# increase size of enemy
		$AnimatedSprite.scale *= damageSpriteScaleFactor;
		$CollisionShape2D.shape.radius *= damageSpriteScaleFactor;
		if healthPoints <= 0:
			die();
func die():
	if not isDead:
		isDead = true;
		queue_free();

# signal called by set_velocity() method of navigationAgent
func _on_NavigationAgent2D_velocity_computed(safe_velocity):
	velocity = safe_velocity;
	var _velocity = move_and_slide(velocity);
	for index in get_slide_count():
		var collision := get_slide_collision(index);
		var body := collision.collider;

# emit information needed to draw enemy's desired path
func _on_NavigationAgent2D_path_changed():
	emit_signal("pathChanged",navigationAgent.get_nav_path());
