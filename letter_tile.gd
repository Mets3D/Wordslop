class_name LetterTile extends Label

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

func _init(letter_str: String):
	text = letter_str.to_upper()
	size = DEFAULT_TILE_SIZE
	custom_minimum_size = DEFAULT_TILE_SIZE
	pivot_offset = size / 2.0
	var score: int = LETTER_SCORES[letter_str]

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

func click_highlight() -> void:
	var tween = create_tween()
	tween.set_parallel()

	self.modulate = Color.YELLOW
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)
	self.scale = Vector2(2, 2)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.2)

static func add_new_to_ui(letter_str: String, parent_node: Control) -> LetterTile:
	var letter_tile = LetterTile.new(letter_str)
	parent_node.add_child(letter_tile)
	return letter_tile
