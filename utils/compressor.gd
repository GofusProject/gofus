# Compressor.gd
# Handles compression/decompression of cell data

extends Node

# =========================
# CONSTANTS
# =========================

const HASH: Array = [
	'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
	'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
	'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
	'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
	'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '-', '_'
]

var HASH_DICT: Dictionary = {}

# =========================
# INITIALIZATION
# =========================

func _init() -> void:
	print("[Compressor] Initializing...")
	_build_hash_dict()
	print("[Compressor] Ready")

## Build hash dictionary for fast character lookup
func _build_hash_dict() -> void:
	for i in range(HASH.size()):
		HASH_DICT[HASH[i]] = i

# =========================
# HASH CONVERSION
# =========================

## Convert character to numeric value using HASH table
func get_int_by_hashed_value(c: String) -> int:
	if c.length() != 1:
		push_error("[Compressor] Character must be single char, got: " + c)
		return -1
	if not HASH_DICT.has(c):
		push_error("[Compressor] Invalid character not in HASH table: " + c)
		return -1
	return HASH_DICT[c]

# =========================
# DECOMPRESSION
# =========================

## Apply decompression algorithm to cell data
## Parse single cell data (10 characters) into cell properties dictionary
## Flow: Compressed string → Uncompressed string
func uncompress_cell_data(cell_data: String, cell_id: int) -> Dictionary:
	if cell_data.length() != 10:
		push_error("[Compressor] Cell %d: Expected 10 chars, got %d" % [cell_id, cell_data.length()])
		return {}
	
	# Convert characters to byte array
	var bytes: Array = []
	for i in range(10):
		var byte_val: int = get_int_by_hashed_value(cell_data[i])
		if byte_val == -1:
			push_error("[Compressor] Cell %d: Invalid character '%s' at position %d" % [cell_id, cell_data[i], i])
			return {}
		bytes.append(byte_val)
	
	# Extract cell properties using bit masks (matching Compressor.uncompressCell)
	var cell: Dictionary = {}
	
	# Basic properties
	cell.num = cell_id
	cell.raw_data = cell_data
	

	cell.is_active = ((bytes[0] & 0x20) >> 5) != 0
	cell.line_of_sight = (bytes[0] & 1) != 0
	cell.movement = (bytes[2] & 0x38) >> 3
	cell.is_walkable = (cell.movement != 0
		and cell_data != "bhGaeaaaaa"
		and cell_data != "Hhaaeaaaaa")
	# Derived property: Is cell targetable for combat?
	cell.is_targetable = cell.is_active and cell.is_walkable


	cell.cell_slope = (bytes[4] & 0x3C) >> 2
	cell.cell_level = bytes[1] & 0x0F


	cell.ground_tile_id = ((bytes[0] & 0x18) << 6) + ((bytes[2] & 7) << 6) + bytes[3]
	cell.ground_tile_rot = (bytes[1] & 0x30) >> 4
	cell.is_ground_tile_flip = ((bytes[4] & 2) >> 1) != 0
	
	cell.object1_id = ((bytes[0] & 4) << 11) + ((bytes[4] & 1) << 12) + (bytes[5] << 6) + bytes[6]
	cell.object1_rot = (bytes[7] & 0x30) >> 4
	cell.is_object1_flip = ((bytes[7] & 8) >> 3) != 0

	cell.is_object2_flip = ((bytes[7] & 4) >> 2) != 0
	cell.object2_id = ((bytes[0] & 2) << 12) + ((bytes[7] & 1) << 12) + (bytes[8] << 6) + bytes[9]
	cell.is_object2_interactive = ((bytes[7] & 2) >> 1) != 0
	cell.object = cell.object2_id if cell.is_object2_interactive else -1

	# External object layer (initially empty)
	cell.object_external = ""
	cell.is_object_external_interactive = false
	

	cell.permanent_level = 0
	

	
	return cell
