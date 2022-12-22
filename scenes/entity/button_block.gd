tool

extends "res://addons/level_block/level_block_node.gd"

func interact():
	if east_face == 7:
		self.east_face = 8
	elif east_face == 8:
		self.east_face = 7
