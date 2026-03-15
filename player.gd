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

	type_letter(event)

func type_letter(event):
	for hand_tile: LetterTile in hand_tiles:
		if event.is_pressed() and (event.as_text() == hand_tile.text):
			hand_tile.click_tile()
	var is_valid_word = is_typed_word_valid()
	for letter_tile: LetterTile in self.typed_word_ui.get_children():
		if is_valid_word:
			# TODO: This breaks for the last typed letter, since it tweens to its default color...
			letter_tile.modulate = Color(0.534, 0.97, 0.752, 1.0)
		else:
			letter_tile.modulate = Color(1.0, 1.0, 1.0, 1.0)

func backspace():
	if len(self.typed_word_ui.get_children()) > 0:
		self.typed_word_ui.get_child(-1).queue_free()

func submit_typed_word():
	if is_typed_word_valid():
		var word_score = 0
		new_hand_letters(NUM_LETTERS)
		for letter_tile in self.typed_word_ui.get_children():
			word_score += letter_tile.score
			letter_tile._tween_submit_success()
		self.score += word_score
		self.score_ui.text = str(self.score).pad_zeros(5)
	else:
		for letter_tile in self.typed_word_ui.get_children():
			letter_tile._tween_error()

func is_typed_word_valid() -> bool:
	var typed_word = get_typed_word()
	return typed_word in WORD_LIST

func get_typed_word() -> String:
	var word = ""
	for letter_tile: Label in self.typed_word_ui.get_children():
		word += letter_tile.text
	return word.to_lower()
