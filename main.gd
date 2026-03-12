extends Node2D

@onready var ui: CanvasLayer = $UI
@onready var ui_letter_hbox: HBoxContainer = $UI/Letters_HBox
@onready var ui_typed_word: HBoxContainer = $UI/TypedWord_HBox
const WORD_LIST = preload("res://resources/word_list_parsed.gd").WORD_LIST
var NUM_LETTERS = 12

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Player.new_hand_letters(NUM_LETTERS, ui_letter_hbox)
	WordListHelper.write_word_list()
	get_tree().root.size_changed.connect(on_viewport_size_changed)

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):  # Space/Enter
		var typed_word = get_typed_word()
		if typed_word in WORD_LIST:
			Player.new_hand_letters(NUM_LETTERS, ui_letter_hbox)
			for child in ui_typed_word.get_children():
				child.queue_free()
			print(typed_word, " is apparently a real word, gj.")
		else:
			print(typed_word, " not in word list...?")

	if event.is_action_pressed("ui_text_backspace") and len(ui_typed_word.get_children()) > 0:
		ui_typed_word.get_child(-1).queue_free()
	
	for letter in Player.hand_tiles:
		if event.is_pressed() and (event.as_text() == letter.text):
			letter.click_highlight()
			LetterTile.add_new_to_ui(event.as_text(), ui_typed_word)

func get_typed_word() -> String:
	var word = ""
	for letter_tile: Label in ui_typed_word.get_children():
		word += letter_tile.text
	return word.to_lower()

func on_viewport_size_changed():
	"""WIP UI scaling... I still need to learn more to make this even more flexible."""
	var window_size = ui_letter_hbox.get_parent_area_size()
	var separation = 20
	var min_size_x = LetterTile.DEFAULT_TILE_SIZE.x
	var ideal_letter_box_width = NUM_LETTERS * (min_size_x + separation) - separation
	while ideal_letter_box_width > window_size.x and separation > 4:
		separation -= 1
		ideal_letter_box_width = NUM_LETTERS * (min_size_x + separation) - separation
	ui_letter_hbox.add_theme_constant_override('separation', separation)

	while ideal_letter_box_width > window_size.x and min_size_x > 20:
		min_size_x -= 1
		ideal_letter_box_width = NUM_LETTERS * (min_size_x + separation) - separation

	var ratio = min_size_x / LetterTile.DEFAULT_TILE_SIZE.x
	var min_size_y = LetterTile.DEFAULT_TILE_SIZE.y * ratio
	for letter in Player.hand_tiles:
		letter.custom_minimum_size = Vector2(min_size_x, min_size_y)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
