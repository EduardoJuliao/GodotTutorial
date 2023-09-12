extends Area2D

# @export allows you to set its value in the inspector
@export var speed = 400;
var screen_size;

signal hit

func start(pos):
	position = pos;
	show();
	$CollisionShape2D.disabled = false;

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size;
	hide();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	controlMovement(delta);

func controlMovement(delta):
	var velocity = getMovementVector();
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed;
		$AnimatedSprite2D.play(); # $ is shorthand to get_node(), it would be the same as get_node("AnimatedSprite2D").play()
	else:
		$AnimatedSprite2D.stop();
		
	controlAnimations(velocity);
	
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)

func getMovementVector():
	var velocity = Vector2.ZERO; #The player's movement vector.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1;
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1;
	if Input.is_action_pressed("move_down"):
		velocity.y += 1;
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1;
		
	return velocity;
	
func controlAnimations(velocity):
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk";
		$AnimatedSprite2D.flip_v = false;
		$AnimatedSprite2D.flip_h = velocity.x <0;
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "up";
		$AnimatedSprite2D.flip_v = velocity.y > 0;


func _on_body_entered(body):
	hide(); #player disapers after being hit.
	hit.emit();
	# Must be deferred as we can't change physics propertis on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true);
