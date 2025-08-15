extends Node2D
@onready var static_body_2d: StaticBody2D = $StaticBody2D

var angle = 20.0
var amplitude = 1.0
var speed = 5
var time = 0
func _physics_process(delta: float) -> void:
	time += delta
	angle = amplitude * sin(speed * time)
	static_body_2d.rotation = angle
