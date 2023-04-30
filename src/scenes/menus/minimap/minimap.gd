extends TileMap

@export var source_map: TileMap
@export var player: Node2D

@onready var player_indicator = $PlayerIndicator
@onready var source_id = tile_set.get_source_id(0)


func _ready():
	if source_map:
		for tile in source_map.get_used_cells(0):
			set_cell(0, tile, source_id, Vector2.ZERO)


func _process(_delta):
	if player:
		var tile = source_map.local_to_map(source_map.to_local(player.global_position))
		var pos = map_to_local(tile)
		player_indicator.position = pos
