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
	text = str(score).pad_zeros(5)
	_tween_score_flash()
	return added_score

func _tween_score_flash():
	"""Visual feedback to be used when score counter increases."""
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale:y", 1.0, 0.2)
	scale.y = 2
