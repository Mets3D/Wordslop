@tool
class_name WordListHelper

const WORD_LIST = preload("res://resources/word_list_parsed.gd").WORD_LIST

static var _WORD_TREE: TrieNode

# Pre-processed at startup — keys are sorted letter strings, values are word arrays
static var _words_by_letters: Dictionary = {}

static func load_word_list(path) -> Array[String]:
	var word_list: Array[String] = []

	if not FileAccess.file_exists(path):
		push_error("Word list not found at %s" % path)
		return []

	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Failed to open %s" % path)
		return []

	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		if not line.is_empty():
			word_list.append(line.to_lower())

	file.close()

	return word_list

static func write_word_list():
	"""Loads word_list.txt and writes word_list_parsed.gd after applying some rules.
	This means you can add large datasets to word_list.txt without too much worry, then just
	run this function to get a trimmed result.
	"""
	var word_list = load_word_list("res://resources/word_list.txt")
	var path = "res://resources/word_list_parsed.gd"

	var file = FileAccess.open(path, FileAccess.WRITE)

	var regex_vetoed_characters = RegEx.create_from_string(r"&|\d+|\.|-|'|/")
	var regex_vowels = RegEx.create_from_string(r"[aeiouy]")

	file.store_line("const WORD_LIST: Array[String] = [")
	for word in word_list:
		if regex_vetoed_characters.search(word) == null and regex_vowels.search(word):
			var line = "\"%s\",".replace("%s", word)
			file.store_line(line)
	file.store_line("]")
	file.close()

static func prepare_game():
	_build_word_index()
	_build_word_tree()

static func is_valid_word(word: String) -> bool:
	return _WORD_TREE.search(word)

static func _build_word_tree() -> void:
	_WORD_TREE = TrieNode.new()
	for word in WORD_LIST:
		_WORD_TREE.insert(word)

static func _build_word_index() -> void:
	for word in WORD_LIST:
		var key = _letter_key(word)
		if not _words_by_letters.has(key):
			_words_by_letters[key] = []
		_words_by_letters[key].append(word)

static func find_valid_word_with_letters(letters: String, min_length=5) -> String:
	for key in _words_by_letters.keys():
		if _is_subset(key, letters):
			for word in _words_by_letters[key]:
				if word.length() >= min_length:
					return word
	return ""

static func _letter_key(word: String) -> String:
	# Collapse a word to its unique sorted letters, e.g. "apple" -> "aelp"
	var letters = Array(word.split(""))
	letters = letters.reduce(func(acc, l): 
		if l not in acc: acc.append(l)
		return acc
	, [])
	letters.sort()
	return "".join(letters)

static func _is_subset(required_letters: String, available_letters: String) -> bool:
	for ch in required_letters:
		if ch not in available_letters:
			return false
	return true

static var _best_word: String = ""

static func find_longest_word(available_letters: String) -> String:
	_best_word = ""
	_depth_first_search(_WORD_TREE, available_letters, "")
	return _best_word

static func _depth_first_search(node: TrieNode, available: String, current: String) -> void:
	if node.is_end_of_word and current.length() > _best_word.length():
		_best_word = current
	for ch in node.children:
		if ch in available:
			_depth_first_search(node.children[ch], available, current + ch)
