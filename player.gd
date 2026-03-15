@tool
class_name Player
extends Node

@export var score_tracker: PlayerScoreTracker
@export var typed_word_ui: HBoxContainer
@export var hand_ui: HBoxContainer
@export var word_evaluator: WordEvaluator

var NUM_LETTERS = 12
var hand_tiles: Array[LetterTile] = []
var await_submit = false # Flag to prevent re-submitting during the submit animation (by spamming Enter key)

func _ready():
	assert ((score_tracker and typed_word_ui and hand_ui and word_evaluator), "UI elements not specified for player.")
	score_tracker.player = self
	word_evaluator.player = self
	typed_word_ui.child_order_changed.connect(refresh_letter_states)

	new_hand_letters(NUM_LETTERS)

	if Engine.is_editor_hint():
		"""Preview a word typed in inside the editor."""
		WordListHelper._build_word_index()
		var editor_word: String = WordListHelper.find_valid_word_with_letters(get_typed_word_str(hand_ui))
		for letter in editor_word.split(""):
			type_letter(letter)

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
	if event.is_action_pressed("ui_accept") and not await_submit:  # Space/Enter
		attempt_word_submit()
		return

	if event.is_action_pressed("ui_text_backspace", true):
		backspace()
		return

	if event.is_pressed() and event.as_text() in LetterTile.ALPHABET:
		type_letter(event.as_text())

func type_letter(letter: String):
	for hand_tile: LetterTile in hand_tiles:
		if letter.to_lower() == hand_tile.text.to_lower():
			hand_tile.click_tile()

func get_valid_word_tiles() -> Array[LetterTile]:
	"""Return only those tiles which make a valid word (so excludes excess tiles).
	"""
	var tiles: Array[LetterTile] = []
	for tile: LetterTile in get_typed_letter_tiles():
		if tile.is_scoring:
			tiles.append(tile)
	return tiles

func refresh_letter_states():
	var word = get_typed_word_str()
	# Find longest valid word by removing letters from the end until finding one.
	while len(word) > 0:
		if WordListHelper.is_valid_word(word):
			break
		# Remove last letter
		word = word.left(-1)
	var typed_letter_tiles: Array[LetterTile] = get_typed_letter_tiles()
	for i in range(len(typed_letter_tiles)):
		typed_letter_tiles[i].is_scoring = i<len(word)

	word_evaluator.update()

func backspace():
	"""Remove the right-most typed letter."""
	if len(get_typed_letter_tiles()) > 0:
		var last = typed_word_ui.get_child(-1)
		typed_word_ui.remove_child(last)
		last.queue_free()

func attempt_word_submit():
	"""Try to submit the currently typed word, which may succeed or fail."""
	if is_typed_word_valid():
		# Flash the typed letters which contribute to the valid word green, 
		# and then destroy them.
		var submit_tween: Tween
		for letter_tile in get_typed_letter_tiles():
			submit_tween = letter_tile.submit(letter_tile.is_scoring)

		# Add the typed word's score to the player score.
		score_tracker.add_score(word_evaluator.word_total)

		# Get a fresh hand of letters to play with.
		new_hand_letters(NUM_LETTERS)

		# Don't allow re-submitting until submit animation is finished.
		await_submit = true
		await submit_tween.finished
		await_submit = false
	else:
		for letter_tile: LetterTile in get_typed_letter_tiles():
			# Flash the typed word in red to indicate failure to submit.
			letter_tile.submit(false)

func is_typed_word_valid() -> bool:
	return WordListHelper.is_valid_word(get_typed_word_str())

func get_typed_letter_tiles(parent: Control = null) -> Array[LetterTile]:
	if parent == null:
		parent = typed_word_ui
	var tiles: Array[LetterTile]
	tiles.assign(parent.get_children())
	return tiles

func get_typed_word_str(parent: Control = null) -> String:
	"""Lowercase, to match our word database."""
	if parent == null:
		parent = typed_word_ui
	var word = ""
	for letter_tile: Label in get_typed_letter_tiles(parent):
		word += letter_tile.text
	return word.to_lower()
