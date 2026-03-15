class_name LetterTile
extends Label

const Globals = preload("res://main.gd")

const ALPHABET: Array[String] = [
	"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L",
	"M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"
]
const LETTER_SCORES := {
	"A": 1, "B": 3, "C": 3, "D": 2, "E": 1,
	"F": 4, "G": 2, "H": 4, "I": 1, "J": 8,
	"K": 5, "L": 1, "M": 3, "N": 1, "O": 1,
	"P": 3, "Q": 10,"R": 1, "S": 1, "T": 1,
	"U": 1, "V": 4, "W": 4, "X": 8, "Y": 4,
	"Z": 10
}
const VOWELS: Array[String] = ["A", "E", "I", "O", "U", "Y"]
const SPACING := 12
const DEFAULT_TILE_SIZE := Vector2(65, 100)
var score: int = 1

var player: Player

enum VisualState {
	NO_HOVER,
	HOVER,

	# States that LetterTiles in the typed word can be in
	WORD_SUBMIT_INCORRECT,
	WORD_SUBMIT_CORRECT,
	WORD_PREVIEW_CORRECT,

	# States that LetterTiles in the player's hand can be in
	CLICK_ERROR,
	CLICK_SUCCESS,
}


var _is_hovered: bool = false
var is_hovered: bool:
	set(value):
		_is_hovered = value
		if _is_hovered:
			rest_position = position
			visual_state = VisualState.HOVER
		else:
			visual_state = VisualState.NO_HOVER
	get:
		return _is_hovered

var _is_scoring: bool
var is_scoring: bool:
	set(value):
		_is_scoring = value
		if value:
			visual_state = VisualState.WORD_PREVIEW_CORRECT
		else:
			visual_state = VisualState.NO_HOVER
	get:
		return _is_scoring

### VISUAL PROPERTIES.
var _visual_state: VisualState
var visual_state: VisualState:
	set(value):
		_visual_state = value
		_tween_active_stop()
		__start_state_animation()
	get:
		return _visual_state

var active_tween: Tween

var rest_position: Vector2

var default_scale := Vector2.ONE
var default_color := Color(1,1,1)

var hover_scale := Vector2(1.15, 1.15)
var hover_color := Color(0.889, 0.704, 0.282, 1.0)
var hover_tween_time := 0.05
var hover_offset := -10

var click_color := Color(0.8, 0.773, 0.0, 1.0)
var click_scale := Vector2(2, 2)
var click_tween_time := 0.2

var error_click_color := Color(0.882, 0.144, 0.275, 1.0)
var error_click_scale := Vector2(1.1, 1.1)

var success_color := Color(0.26, 0.72, 0.0, 1.0)
var success_scale := hover_scale

var correct_color := Color(0.534, 0.97, 0.752, 1.0)

func _init(letter_str: String, owner_player: Player):
	text = letter_str.to_upper()
	size = DEFAULT_TILE_SIZE
	custom_minimum_size = DEFAULT_TILE_SIZE
	pivot_offset = size / 2.0
	score = LETTER_SCORES[letter_str]
	player = owner_player

	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment   = VERTICAL_ALIGNMENT_CENTER

	add_theme_font_size_override("font_size", 48)
	add_theme_color_override("font_color", Color.WHITE)

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.2, 0.2, 0.8)
	style.border_width_left   = 3
	style.border_width_right  = 3
	style.border_width_top    = 3
	style.border_width_bottom = 3
	style.border_color = Color.GRAY
	style.corner_radius_top_left     = 8
	style.corner_radius_top_right    = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_bottom_left  = 8
	style.content_margin_left   = 10
	style.content_margin_right  = 10
	style.content_margin_top    = 10
	style.content_margin_bottom = 10

	add_theme_stylebox_override("normal", style)
	modulate = Color(1,1,1,1)

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_STOP   # important — makes it receive mouse events
	mouse_default_cursor_shape = CURSOR_POINTING_HAND   # optional: hand cursor
	mouse_entered.connect(_hover_start)
	mouse_exited.connect(_hover_end)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			click_tile()
			accept_event()

func _hover_start():
	is_hovered = true

func _hover_end():
	is_hovered = false

func click_tile() -> void:
	"""Do whatever should happen when the tile is activated.
	If this tile is in the player's hand, it should be added to the typed letters.
	If this tile is in the typed letters, it should be removed from there.
	"""
	var parent = self.get_parent_control()
	if parent == player.typed_word_ui:
		# Remove this typed letter from the typed word.
		player.typed_word_ui.remove_child(self)
		queue_free()
		player.refresh_letter_states()
		return

	if parent == player.hand_ui:
		if len(player.typed_word_ui.get_children()) >= Globals.MAX_WORD_LENGTH:
			visual_state = VisualState.CLICK_ERROR
		else:
			# Add a copy of this letter tile to the typed word.
			var new_tile = add_new_to_ui(self.text, player.typed_word_ui, player)
			new_tile.visual_state = VisualState.CLICK_SUCCESS
			visual_state = VisualState.CLICK_SUCCESS

func submit(success: bool) -> Tween:
	if success:
		visual_state = VisualState.WORD_SUBMIT_CORRECT
	else:
		visual_state = VisualState.CLICK_ERROR
	return active_tween

func __start_state_animation() -> void:
	active_tween = create_tween()
	active_tween.set_parallel(true)
	
	var goal_color = correct_color if is_scoring else default_color
	goal_color = hover_color if is_hovered else goal_color
	var goal_scale = hover_scale if is_hovered else default_scale

	print(self.text, VisualState.get(visual_state))

	match visual_state:
		VisualState.NO_HOVER:
			active_tween.tween_property(self, "modulate", goal_color, hover_tween_time)
			active_tween.tween_property(self, "scale", goal_scale, hover_tween_time)
			active_tween.tween_property(self, "position:y", rest_position.y, hover_tween_time)

		VisualState.HOVER:
			active_tween.tween_property(self, "modulate", hover_color, hover_tween_time)
			active_tween.tween_property(self, "scale", hover_scale, hover_tween_time)
			active_tween.tween_property(self, "position:y", rest_position.y - 8, hover_tween_time)

		VisualState.WORD_SUBMIT_INCORRECT, VisualState.CLICK_ERROR:
			active_tween.tween_property(self, "modulate", goal_color, click_tween_time)
			active_tween.tween_property(self, "scale", goal_scale, click_tween_time)
			self.modulate = error_click_color
			self.scale = error_click_scale

		VisualState.WORD_SUBMIT_CORRECT:
			active_tween.tween_property(self, "modulate", success_color, click_tween_time)
			active_tween.tween_property(self, "scale", success_scale, click_tween_time)
			await active_tween.finished
			active_tween.kill()
			queue_free()

		VisualState.WORD_PREVIEW_CORRECT:
			active_tween.tween_property(self, "modulate", correct_color, click_tween_time)

		VisualState.CLICK_SUCCESS:
			active_tween.tween_property(self, "modulate", goal_color, click_tween_time)
			active_tween.tween_property(self, "scale", goal_scale, click_tween_time)
			self.modulate = click_color
			self.scale = click_scale

	await active_tween.finished
	visual_state = VisualState.HOVER if is_hovered else VisualState.NO_HOVER
	_tween_active_stop()

func _tween_active_stop() -> void:
	if active_tween:
		active_tween.kill()
		active_tween = null

static func add_new_to_ui(letter_str: String, parent_node: Control, owner_player: Player) -> LetterTile:
	"""Add a new LetterTile instance to the passed UI element, eg. the player's hand or the typed word.
	Return the new LetterTile."""
	var letter_tile = LetterTile.new(letter_str, owner_player)
	parent_node.add_child(letter_tile)
	return letter_tile
