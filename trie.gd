# https://en.wikipedia.org/wiki/Trie

class_name TrieNode

var children: Dictionary = {}  # String -> TrieNode
var is_end_of_word: bool = false

func insert(word: String) -> void:
	var node = self
	for ch in word:
		if not node.children.has(ch):
			node.children[ch] = TrieNode.new()
		node = node.children[ch]
	node.is_end_of_word = true

func search(word: String) -> bool:
	var node = self
	for ch in word:
		if not node.children.has(ch):
			return false
		node = node.children[ch]
	return node.is_end_of_word
