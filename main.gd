extends Node2D

@onready var ui: CanvasLayer = $UI
@onready var player: Player = $UI/Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _unhandled_input(event):
	player.handle_input(event)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
