class_name WordListHelper

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
