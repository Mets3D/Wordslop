@tool
class_name WordEvaluator
extends HBoxContainer

@export var sum_tiles_ui: Label
@export var multiplier_ui: Label
@export var word_total_ui: Label

var word_total: int

var player: Player

const WORD_LENGTH_MULTIPLIERS: Dictionary[int, int] = {
	0: 0,
	1: 0,
	2: 0,
	3: 1,
	4: 1,
	5: 2,
	6: 3,
	7: 5,
	8: 8,
	9: 10,
	10: 12,
	11: 15,
	12: 20,
	13: 30,
	14: 40,
	15: 50,
}

func update() -> int:
	"""Update score preview based on current typed tiles."""
	var tile_sum = 0
	var valid_tiles: Array[LetterTile] = player.get_valid_word_tiles()
	
	self.visible = len(valid_tiles) > 1

	for tile: LetterTile in valid_tiles:
		tile_sum += tile.score

	sum_tiles_ui.text = str(tile_sum)

	var multiplier: int = WORD_LENGTH_MULTIPLIERS[len(valid_tiles)]

	multiplier_ui.text = str(multiplier)

	word_total = tile_sum * multiplier
	word_total_ui.text = str(word_total)

	return word_total
