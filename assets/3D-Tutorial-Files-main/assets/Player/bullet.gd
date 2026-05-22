extends Area3D


var speed = 10


func _ready() -> void:
	# This multiplies the bullet's size by 2 on all axes when it spawns
	scale = Vector3(10.0, 10.0, 5.0)



func _process(delta: float) -> void:
	
	position += transform.basis * Vector3(0, 0, -speed) * delta
	
	pass


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemy"):
		body.queue_free()
	queue_free()
	
	pass # Replace with function body.


func _on_timer_timeout() -> void:
	queue_free()
	pass # Replace with function body.
