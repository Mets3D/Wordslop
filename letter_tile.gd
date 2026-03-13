class_name LetterTile
extends Label

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
var anim_state: String = "None"

@export var default_scale := Vector2.ONE
@export var default_color := Color(1,1,1)

@export var hover_scale := Vector2(1.15, 1.15)
@export var hover_color := Color(0.889, 0.704, 0.282, 1.0)
@export var hover_tween_time := 0.05

@export var click_color := Color(0.8, 0.773, 0.0, 1.0)
@export var click_scale := Vector2(2, 2)
@export var click_tween_time := 0.2

func _init(letter_str: String):
	text = letter_str.to_upper()
	size = DEFAULT_TILE_SIZE
	custom_minimum_size = DEFAULT_TILE_SIZE
	pivot_offset = size / 2.0
	score = LETTER_SCORES[letter_str]

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

func click_highlight() -> void:
	if self.anim_state == "CLICK":
		return
	self.anim_state = "CLICK"
	var tween = create_tween().set_parallel()
	tween.tween_property(self, "modulate", self.modulate, click_tween_time)
	tween.tween_property(self, "scale", self.scale, click_tween_time)
	self.modulate = click_color
	self.scale = click_scale

	await tween.finished
	tween.kill()
	self.anim_state = "NONE"

func _hover_start() -> void:
	if self.anim_state in ["HOVER_START", "HOVER_END"]:
		return
	self.anim_state = "HOVER_START"	

	var tween = create_tween().set_parallel()
	tween.tween_property(self, "scale", hover_scale, hover_tween_time)
	tween.tween_property(self, "modulate", hover_color, hover_tween_time)

	await tween.finished
	tween.kill()
	self.anim_state = "HOVERED"

func _hover_end() -> void:
	if self.anim_state in ["HOVER_END"]:
		return
	self.anim_state = "HOVER_END"	
	var tween = create_tween().set_parallel()
	tween.tween_property(self, "scale", default_scale, hover_tween_time)
	tween.tween_property(self, "modulate", default_color, hover_tween_time)

	await tween.finished
	tween.kill()
	self.anim_state = "NONE"

static func add_new_to_ui(letter_str: String, parent_node: Control) -> LetterTile:
	var letter_tile = LetterTile.new(letter_str)
	parent_node.add_child(letter_tile)
	return letter_tile
