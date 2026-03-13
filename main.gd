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
	get_tree().root.size_changed.connect(on_viewport_size_changed)

func _unhandled_input(event):
	player.handle_input(event)

func on_viewport_size_changed():
	"""WIP UI scaling... I still need to learn more to make this even more flexible."""
	var window_size = player.ui_letter_hbox.get_parent_area_size()
	var separation = 20
	var min_size_x = LetterTile.DEFAULT_TILE_SIZE.x
	var num_letters = len(player.hand_tiles)
	var ideal_letter_box_width = num_letters * (min_size_x + separation) - separation
	while ideal_letter_box_width > window_size.x and separation > 4:
		separation -= 1
		ideal_letter_box_width = num_letters * (min_size_x + separation) - separation
	player.ui_letter_hbox.add_theme_constant_override('separation', separation)

	while ideal_letter_box_width > window_size.x and min_size_x > 20:
		min_size_x -= 1
		ideal_letter_box_width = num_letters * (min_size_x + separation) - separation

	var ratio = min_size_x / LetterTile.DEFAULT_TILE_SIZE.x
	var min_size_y = LetterTile.DEFAULT_TILE_SIZE.y * ratio
	for letter_tile in player.hand_tiles:
		letter_tile.custom_minimum_size = Vector2(min_size_x, min_size_y)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
