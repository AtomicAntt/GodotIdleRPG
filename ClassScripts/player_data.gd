class_name Player

const defaultLooks: Array[String] = [
	"res://GameAssets/Players/mPlayer_ [human].png",
	"res://GameAssets/Players/fPlayer_ [human].png",
	"res://GameAssets/Players/mPlayer_ [elf].png",
	"res://GameAssets/Players/fPlayer_ [elf].png",
	"res://GameAssets/Players/mPlayer_ [dwarf].png",
	"res://GameAssets/Players/fPlayer_ [dwarf].png"
]

var rng := RandomNumberGenerator.new()

var name: String
var level: int
var exp: int
var joinTime: int
var experienceRequired: int
var playerLook: String

func _init(name: String, level: int, exp: int, experienceRequired: int, joinTime: int, playerLook: String):
	self.name = name
	self.level = level
	self.exp = exp
	self.experienceRequired = experienceRequired
#	self.joinTime = Time.get_unix_time_from_datetime_dict(Time.get_datetime_dict_from_system())
	self.joinTime = joinTime
	self.playerLook = playerLook
	
	# If Player.new("", 1, 0, 20, -1, "") then you will get a brand new player with new stuff in them
	
	if name == "":
		self.name = UsernameGenerator.returnRandomUsername()
	if joinTime == -1:
		self.joinTime = Time.get_unix_time_from_datetime_dict(Time.get_datetime_dict_from_system())
	if playerLook == "":
		self.playerLook = defaultLooks[rng.randi_range(0, defaultLooks.size()-1)]
