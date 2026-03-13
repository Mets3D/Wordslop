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

### ANIMATION - These should probably be moved to an inherited class (or interface)

var active_tweens: Dictionary = {}
var is_hovered: bool = false
@export var default_scale := Vector2.ONE
@export var default_color := Color(1,1,1)

@export var hover_scale := Vector2(1.15, 1.15)
@export var hover_color := Color(0.889, 0.704, 0.282, 1.0)
@export var hover_tween_time := 0.05

@export var click_color := Color(0.8, 0.773, 0.0, 1.0)
@export var click_scale := Vector2(2, 2)
@export var click_tween_time := 0.2

@export var error_click_color := Color(0.882, 0.144, 0.275, 1.0)
@export var error_click_scale := Vector2(1.1, 1.1)


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

func click_tile() -> void:
	if "CLICK" in active_tweens:
		active_tweens["CLICK"].kill()
		active_tweens.erase("CLICK")

	var tween = create_tween().set_parallel()
	active_tweens["CLICK"] = tween
	var goal_color = hover_color if is_hovered else default_color
	var goal_scale = hover_scale if is_hovered else default_scale
	tween.tween_property(self, "modulate", goal_color, click_tween_time)
	tween.tween_property(self, "scale", goal_scale, click_tween_time)
	var parent = self.get_parent_control()
	if parent == player.typed_word_ui:
		# Remove this typed letter from the typed word.
		queue_free()
	elif parent == player.hand_ui:
		if len(player.typed_word_ui.get_children()) >= Globals.MAX_WORD_LENGTH:
			self.modulate = error_click_color
			self.scale = error_click_scale
		else:
			add_new_to_ui(self.text, player.typed_word_ui, player)

			self.modulate = click_color
			self.scale = click_scale

	await tween.finished
	tween.kill()
	active_tweens.erase("CLICK")
	if goal_color == hover_color and not is_hovered:
		_hover_end()

func _hover_start() -> void:
	is_hovered = true
	if "HOVER_START" in active_tweens or "HOVER_END" in active_tweens:
		return

	var tween = create_tween().set_parallel()
	active_tweens["HOVER_START"] = tween
	tween.tween_property(self, "scale", hover_scale, hover_tween_time)
	tween.tween_property(self, "modulate", hover_color, hover_tween_time)

	await tween.finished
	tween.kill()
	active_tweens.erase("HOVER_START")

func _hover_end() -> void:
	is_hovered = false
	if "HOVER_END" in active_tweens:
		return
	var click_tween = active_tweens.get("CLICK")
	if click_tween:
		click_tween.kill()
		active_tweens.erase("CLICK")
	var tween = create_tween().set_parallel()
	active_tweens["HOVER_END"] = tween
	tween.tween_property(self, "scale", default_scale, hover_tween_time)
	tween.tween_property(self, "modulate", default_color, hover_tween_time)

	await tween.finished
	tween.kill()
	active_tweens.erase("HOVER_END")

static func add_new_to_ui(letter_str: String, parent_node: Control, player: Player) -> LetterTile:
	var letter_tile = LetterTile.new(letter_str, player)
	parent_node.add_child(letter_tile)
	return letter_tile
