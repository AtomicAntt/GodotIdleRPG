class_name Player

var name: String
var level: int
var exp: int
var joinTime: int

func _init(name: String, level: int, exp: int, joinTime: int):
	self.name = name
	self.level = level
	self.exp = exp
	self.joinTime = Time.get_unix_time_from_datetime_dict(Time.get_datetime_dict_from_system())

 
