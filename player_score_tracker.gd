class_name PlayerScoreTracker
extends Label

var score_ui: Label
var player: Player
var score := 0
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

func _init(owning_player: Player, ui_score: Label):
	score_ui = ui_score
	player = owning_player

static func calc_score_for_tiles(letter_tiles: Array[LetterTile]) -> int:
	"""Return the total score value of the given set of tiles."""
	var word_score = 0
	for letter_tile: LetterTile in letter_tiles:
		word_score += letter_tile.score
	var multiplier: int = WORD_LENGTH_MULTIPLIERS[len(letter_tiles)]
	return word_score * multiplier

func score_letter_tiles(letter_tiles: Array[LetterTile]) -> int:
	"""Add total score value of the given set of tiles to current score.
	Return the amount added.
	"""
	var added_score = calc_score_for_tiles(letter_tiles)
	score += added_score
	score_ui.text = str(score).pad_zeros(5)
	
	return added_score
