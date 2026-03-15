class_name Player
extends Node


var score_ui: Label
var typed_word_ui: HBoxContainer
var hand_ui: HBoxContainer
var score: int

var NUM_LETTERS = 12
var hand_tiles: Array[LetterTile] = []
const WORD_LIST = preload("res://resources/word_list_parsed.gd").WORD_LIST

func _init(ui_hand: HBoxContainer, ui_typed_word: HBoxContainer, ui_score: Label):
	hand_ui = ui_hand
	typed_word_ui = ui_typed_word
	score_ui = ui_score
	score = 0

func new_hand_letters(num_letters: int) -> Array[LetterTile]:
	clear_hand()

	var chosen_letters = get_random_letters__min_1_vowel(num_letters)
	for i in range(num_letters):
		var new_tile = LetterTile.add_new_to_ui(chosen_letters[i], self.hand_ui, self)
		new_tile.player = self
		hand_tiles.append(new_tile)
	return hand_tiles

func clear_hand():
	"""Remove all tiles from the player's hand."""
	for letter_tile in hand_tiles:
		letter_tile.queue_free()
	hand_tiles.clear()

func get_random_letters__min_1_vowel(num_letters: int) -> Array[String]:
	"""Return some random unique letters with at least 1 vowel.
	NOTE: Additional rules could be added, like not providing a Q without a U.
	"""
	var shuffled_alphabet = LetterTile.ALPHABET.duplicate()
	var chosen_letters: Array[String] = []
	while not chosen_letters.any(func(l): return l in LetterTile.VOWELS):
		chosen_letters.clear()
		shuffled_alphabet.shuffle()
		for i in range(num_letters):
			chosen_letters.append(shuffled_alphabet[i])
	return chosen_letters

func handle_input(event):
	if event.is_action_pressed("ui_accept"):  # Space/Enter
		submit_typed_word()
		return

	if event.is_action_pressed("ui_text_backspace", true):
		backspace()
		return

	if event.as_text() in LetterTile.ALPHABET:
		type_letter(event)

func type_letter(event):
	for hand_tile: LetterTile in hand_tiles:
		if event.is_pressed() and (event.as_text() == hand_tile.text):
			hand_tile.click_tile()
	refresh_letter_states()

func refresh_letter_states():
	var word = get_typed_word()
	# Find longest valid word by removing letters from the end until finding one.
	while len(word) > 0:
		if word in WORD_LIST:
			break
		# Remove last letter
		word = word.left(-1)
	var typed_letter_tiles = typed_word_ui.get_children()
	for i in range(len(typed_letter_tiles)):
		var state
		if i < len(word):
			typed_letter_tiles[i].makes_a_word = true
			state = LetterTile.VisualState.WORD_PREVIEW_CORRECT
		else:
			typed_letter_tiles[i].makes_a_word = false
			state = LetterTile.VisualState.NO_HOVER
		typed_letter_tiles[i].set_visual_state(state)

func backspace():
	if len(typed_word_ui.get_children()) > 0:
		var last = typed_word_ui.get_child(-1)
		typed_word_ui.remove_child(last)
		last.queue_free()
		refresh_letter_states()

func submit_typed_word():
	if is_typed_word_valid():
		var word_score = 0
		for letter_tile in typed_word_ui.get_children():
			word_score += letter_tile.score
			letter_tile._tween_submit_success()
		score += word_score
		score_ui.text = str(score).pad_zeros(5)
		new_hand_letters(NUM_LETTERS)
	else:
		for letter_tile in typed_word_ui.get_children():
			letter_tile._tween_error()

func is_typed_word_valid() -> bool:
	var typed_word = get_typed_word()
	return typed_word in WORD_LIST

func get_typed_word() -> String:
	var word = ""
	for letter_tile: Label in self.typed_word_ui.get_children():
		word += letter_tile.text
	return word.to_lower()
