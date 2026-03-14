extends Node2D

@onready var ui: CanvasLayer = $UI
@onready var player_hand_ui: HBoxContainer = $UI/Letters_HBox
@onready var typed_word_ui: HBoxContainer = $UI/TypedWord_HBox
@onready var score_ui: Label = $UI/Score
var player: Player = null
const MAX_WORD_LENGTH = 15

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = Player.new(player_hand_ui, typed_word_ui, score_ui)
	player.new_hand_letters(player.NUM_LETTERS)

func _unhandled_input(event):
	player.handle_input(event)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
