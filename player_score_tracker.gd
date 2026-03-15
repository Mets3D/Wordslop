@tool
class_name PlayerScoreTracker
extends Label

var player: Player
var _score: int = 0
var score: int:
	set(value):
		_score = value
		text = str(_score).pad_zeros(5)
	get:
		return _score

func add_score(added_score: int):
	score += added_score
	_tween_score_flash()

func _tween_score_flash():
	"""Visual feedback to be used when score counter increases."""
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale:y", 1.0, 0.2)
	scale.y = 2
