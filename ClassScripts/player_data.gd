class_name Player

var name: String
var level: int
var exp: int
var joinTime: int
var experienceRequired: int

func _init(name: String, level: int, exp: int, experienceRequired: int, joinTime: int):
	self.name = name
	self.level = level
	self.exp = exp
	self.experienceRequired = experienceRequired
#	self.joinTime = Time.get_unix_time_from_datetime_dict(Time.get_datetime_dict_from_system())
	self.joinTime = joinTime
	
	# If Player.new("", 1, 0, 20, -1) then you will get a brand new player with new stuff in them
	
	if name == "":
		self.name = UsernameGenerator.returnRandomUsername()
	if joinTime == -1:
		self.joinTime = Time.get_unix_time_from_datetime_dict(Time.get_datetime_dict_from_system())
