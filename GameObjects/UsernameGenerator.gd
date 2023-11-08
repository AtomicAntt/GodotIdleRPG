extends Node

"""
Let's make a list of features and their details.

1: username modifiers
	- append type
		- numbers
		- common suffix
		- prefix
		- frames
	- alter type
		- letter substitution
			- leetspeak
			- common edgy k z substitution
			- netspeak
			- repeated letters

2: username
	- word combination
	- made-up word
	- bot username
	- repetitive words
	- real name

3: capitalization
	- PascalCase
	- camelCase
	- snake_case
	- ALL CAPS
	- lowercase

Now, let's decide on our criteria for generating usernames.
1. 0-2 modifiers.
2. 1 type of username
3. 1 type of capitalization

First, let's generate a list of features of our new username.
Then we'll generate the base username as an array.
Afterwards, we'll apply modifiers.
Lastly, we'll apply the capitalization and concatenate the elements
in the array to output a username as a string.

Things to note:
	- caller needs to check for uniqueness against name database
	- no special characters besides space and underscore

"""


enum NameBaseTypes{
	WORD,
	COMBINE,
	REALNAME,
	BOT,
	IMAGINARY
}

var NameBaseChances: Dictionary = { # make these add up to 1.0
	NameBaseTypes.COMBINE: 0.4,
	NameBaseTypes.IMAGINARY: 0.34,
	NameBaseTypes.WORD: 0.2,
	NameBaseTypes.REALNAME: 0.05,
	NameBaseTypes.BOT: 0.01,
}

enum NameFormatTypes{
	LOWERCASE,
	PASCALCASE,
	CAMELCASE,
	SNAKECASE,
	UPPERCASE,
}

var NameFormatChances: Dictionary = {
	NameFormatTypes.LOWERCASE: 0.35,
	NameFormatTypes.PASCALCASE: 0.35,
	NameFormatTypes.SNAKECASE: 0.15,
	NameFormatTypes.CAMELCASE: 0.15,
}

enum NameModifierTypes{
	NONE,
	SUBSTITUTION,
	FRAMES,
	NUMBER,
	SUFFIX,
	PREFIX,
	DUPE,
	REPEAT
}

var NameModifierChances: Dictionary = {
	NameModifierTypes.NONE: 0.7,
	NameModifierTypes.NUMBER: 0.12,
	NameModifierTypes.SUBSTITUTION: 0.07,
	NameModifierTypes.FRAMES: 0.02,
	NameModifierTypes.SUFFIX: 0.03,
	NameModifierTypes.PREFIX: 0.03,
	NameModifierTypes.DUPE: 0.02,
	NameModifierTypes.REPEAT: 0.01
}

var bannedCharactersForData: Array = [' ', '.', '-', '_', "'"]

var adjectivesDataFilePath: String = "res://GameAssets/jsonFiles/adjectives.json"
var adjectivesArray: Array

var nounsDataFilePath: String = "res://GameAssets/jsonFiles/nouns.json"
var nounsArray: Array

var suffixDataFilePath: String = "res://GameAssets/jsonFiles/suffix.json"
var suffixArray: Array

var prefixDataFilePath: String = "res://GameAssets/jsonFiles/prefix.json"
var prefixArray: Array

var firstNamesDataFilePath: String = "res://GameAssets/jsonFiles/first-names.json"
var firstNamesArray: Array

var rng := RandomNumberGenerator.new()

func _ready() -> void:
#	jsonTestCase()
#	modifierTestCases()
#	usernameTestCases()
	loadJsonFiles(adjectivesDataFilePath, adjectivesArray)
	loadJsonFiles(nounsDataFilePath, nounsArray)
	loadJsonFiles(suffixDataFilePath, suffixArray)
	loadJsonFiles(prefixDataFilePath, prefixArray)
	loadJsonFiles(firstNamesDataFilePath, firstNamesArray)
	
#	print("I will now proceed to print 100 usernames:")
#	for i in range(100):
#		print(str(i) + ":" + returnRandomUsername())
#	pass

# most important function that the game may call to give a player the username
func returnRandomUsername() -> String:
	
	var nameBaseType: NameBaseTypes = selectRandomType(NameBaseChances)
	var usernameArray: Array = returnNameBaseType(nameBaseType) 
	var username: String # end result
	
	var nameModifiedType: NameModifierTypes
	if nameBaseType != NameBaseTypes.BOT: # bots dont put frames or the alike
		nameModifiedType= selectRandomType(NameModifierChances)
		username = returnModified(nameModifiedType, usernameArray)
	else:
		username = "".join(PackedStringArray(usernameArray))
	
	# substitution always have lower case modifier
	if nameModifiedType != NameModifierTypes.SUBSTITUTION:
		var nameFormatType: NameFormatTypes = selectRandomType(NameFormatChances)
		username = returnFormatted(nameFormatType, username)
	else:
		username = username.to_lower()

	return username

func returnNameBaseType(nameBaseType: int) -> Array:
#	print("name base type: " +str(nameBaseType))
#	print(NameBaseTypes.BOT)
#	print(NameBaseTypes.COMBINE)
	match nameBaseType:
		NameBaseTypes.WORD:
			return [getRandomNoun()]
		NameBaseTypes.COMBINE:
			return combine()
		NameBaseTypes.REALNAME:
			return name()
		NameBaseTypes.BOT:
			return bot()
		NameBaseTypes.IMAGINARY:
			return imaginary()
	print("This should never happen: returning empty array in returnNameBaseType()")
	return []

func returnModified(nameModifiedType: int, words: Array) -> String:
	var modifiedString: String = ""
	match nameModifiedType:
		NameModifierTypes.NONE:
			modifiedString = "".join(PackedStringArray(words))
		NameModifierTypes.SUBSTITUTION:
			modifiedString = "".join(PackedStringArray(substitution(words)))
		NameModifierTypes.FRAMES:
			modifiedString = "".join(PackedStringArray(frames(words)))
		NameModifierTypes.NUMBER:
			modifiedString = "".join(PackedStringArray(number(words)))
		NameModifierTypes.SUFFIX:
			modifiedString = "".join(PackedStringArray(suffix(words)))
		NameModifierTypes.PREFIX:
			modifiedString = "".join(PackedStringArray(prefix(words)))
		NameModifierTypes.DUPE:
			modifiedString = "".join(PackedStringArray(dupe(words)))
		NameModifierTypes.REPEAT:
			modifiedString = "".join(PackedStringArray(repeat(words)))
	return modifiedString
		
func returnFormatted(nameFormatType: int, string: String) -> String:
	var modifiedString: String = ""
	match nameFormatType:
		NameFormatTypes.LOWERCASE:
			modifiedString = string.to_lower()
		NameFormatTypes.PASCALCASE:
			modifiedString = string.to_pascal_case()
		NameFormatTypes.CAMELCASE:
			modifiedString = string.to_camel_case()
		NameFormatTypes.SNAKECASE:
			modifiedString = string.to_snake_case()
		NameFormatTypes.UPPERCASE:
			modifiedString = string.to_upper()
	return modifiedString

#Technecially returns the enum value
func selectRandomType(dictionary: Dictionary) -> int: 
	# Let us assume the chances in dictionary add up to 1.0
	var randomValue = rng.randf()
	
	var currentWeight = 0.0
	for type in dictionary:
		currentWeight += dictionary[type]
		if randomValue <= currentWeight:
			return type
	print("The weight possibly does not add up to 1.0 in selectRandomType(), so it did not choose a random type")
	return 0

# in case json files contain chars like '-' or '.' that are not allowed
func stringContainsBannedCharacter(string: String) -> bool:
	for character in bannedCharactersForData:
		if string.contains(character):
			return true
	return false

func loadJsonFiles(filePath: String, arrayToFill: Array) -> void:
	if FileAccess.file_exists(filePath):
		var dataFile = FileAccess.open(filePath, FileAccess.READ)
		var parsedResult = JSON.parse_string(dataFile.get_as_text())

		if parsedResult is Array:
			for item in parsedResult:
				if not stringContainsBannedCharacter(item):
					arrayToFill.append(item)
		else:
			print("Error reading file!")
			
	else:
		print("File does not exist")

## Applies frame modifier to given username.
## ex. xXShadowbladeXx
func frames(array : Array):
	rng.randomize()
	# load and replace frameTypes with json if wanted
	var frameTypes = ["xX", "x0x", "o0", "x0", "xx0", "xX0", "xxx", "xXx", "xxX"]
	var frame = frameTypes[rng.randi_range(0, frameTypes.size() - 1)]
	array.insert(0, frame)
	var invertFrame = ""
	for i in frame:
		invertFrame = i + invertFrame
	array.append(invertFrame)
	return array

## Applies common letter substitutions to given username.
## ex. CaramelArts -> KaramelArtz
func substitution(array : Array):
	rng.randomize()
	var type = rng.randi_range(0,2)
	match type:
		# front c and end s replacement
		0:
			return edge(array)
		# leetspeak replacement
		1:
			return leetspeak(array)
		# modified netspeak
		2:
			return netspeak(array)
	return array

## Applies front c and end s replacement to given username.
func edge(array : Array):
	for i in range(0, array.size()):
		if array[i][0] == "c":
			array[i][0] = "k"
		if array[i][array[i].length() - 1] == "s":
			array[i][array[i].length() - 1] = "z"
	return array

## Applies leetspeak to given username.
func leetspeak(array : Array):
	for i in range(0, array.size()):
		if rng.randi_range(0,1):
			array[i] = array[i].replace("er", "or")
		# guaranteed
		array[i] = array[i].replace("e", "3")
		array[i] = array[i].replace("o", "0")
		# optional
		if rng.randi_range(0,1):
			array[i] = array[i].replace("ck", "x")
		if rng.randi_range(0,1):
			array[i] = array[i].replace("l", "1")
		if rng.randi_range(0,1):
			array[i] = array[i].replace("t", "7")
	return array

## Applies modified netspeak to given username.
func netspeak(array : Array):
	for i in range(0, array.size()):
		array[i] = array[i].replace("ate", "8")
		array[i] = array[i].replace("eat", "8")
		array[i] = array[i].replace("be", "b")
		array[i] = array[i].replace("you", "u")
		array[i] = array[i].replace("oh", "o")
		array[i] = array[i].replace("er", "ah")
		array[i] = array[i].replace("ea", "ee")
		array[i] = array[i].replace("see", "c")
		array[i] = array[i].replace("are", "r")
		array[i] = array[i].replace("why", "y")
		array[i] = array[i].replace("ex", "x")
	return array

## Randomly generates a number tag to be appended
## on the given username, ranging from 1-6 digits
## in length.
func number(array : Array):
	rng.randomize()
	# decide length of number tag
	var i = rng.randi_range(0, 10)
	var j = 0
	if i < 3:
		j = 2
	elif i < 6:
		j = 3
	elif i < 7:
		j = 1
	elif i < 8:
		j = 4
	elif i < 9:
		j = 5
	else:
		j = 6
	var tag = ""
	for _k in range (0, j):
		tag += str(rng.randi_range(0, 9))
	array.append(tag)
	return array

## Appends a common suffix to the provided username.
func suffix(array : Array):
	rng.randomize()
	# decide suffix
	var suffixTypes = ["chan", "senpai", "god", "owo", "uwu", "0w0", "fanboy", "fangirl", "lover", "enjoyer", "gamer"]
	var suffix = suffixTypes[rng.randi_range(0, suffixTypes.size() - 1)]
	array.append(suffix)
	return array

## Appends a common prefix to the provided username.
func prefix(array : Array):
	rng.randomize()
	# decide prefix
	var prefixTypes = ["master", "mr", "mister", "madame", "mommy", "miss", "ms"]
	var prefix = prefixTypes[rng.randi_range(0, prefixTypes.size() - 1)]
	array.insert(0, prefix)
	return array
	
func dupe(array : Array):
	rng.randomize()
	var location = rng.randi_range(0, array.size() - 1)
	var i = rng.randi_range(0,1)
	for _k in range(0, rng.randi_range(1,4)):
		if i:
			array[location] = array[location] + array[location][array[location].length() - 1]
		else:
			array[location] = array[location][0] + array[location]
	return array

## Combine words to create a username.
func combine():
	rng.randomize()
#	var adjectives = adjectivesArray
#	var words = nounsArray
#	var joiner = ["in", "at", "from", "until", "of", "within", "withinthe", "the", "on"]
	var array = []
#	if rng.randi_range(0,1):
	# A-W or W-W
	if rng.randi_range(0,1):
#		array.append(adjectives[rng.randi_range(0, adjectives.size() - 1)])
		array.append(getRandomAdjective())
	else:
#		array.append(words[rng.randi_range(0, words.size() - 1)])
		array.append(getRandomNoun())
#	var word = words[rng.randi_range(0, words.size() - 1)]
	var word = getRandomNoun()
	while word == array[0]:
#		word = words[rng.randi_range(0, words.size() - 1)]
		word = getRandomNoun()
	array.append(word)
#	else:
#		# W-J-A or W-J-W
#		array.append(words[rng.randi_range(0, words.size() - 1)])
#		array.append(joiner[rng.randi_range(0, joiner.size() - 1)])
#		if rng.randi_range(0,1):
#			array.append(adjectives[rng.randi_range(0, adjectives.size() - 1)])
#		else:
#			var word = words[rng.randi_range(0, words.size() - 1)]
#			while word == array[0]:
#				word = words[rng.randi_range(0, words.size() - 1)]
#			array.append(word)
	return array

## Generate a string formatted like a fake word.
func imaginary():
	rng.randomize()
	var consonants = ["b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "q", "r", "s", "t", "v", "w", "x", "y", "z", "th", "fr", "bl", "br", "cl", "cr", "dr", "fl", "str", "spl", "spr", "gl", "gr", "pl", "pr", "sl", "sp", "sm", "st"]
	var vowels = ["a", "e", "i", "o", "u", "ia", "ai", "ay", "ea", "oa", "oi", "io"]
	var endings = ["st", "lk", "st", "lt", "ft", "ps", "ts", "mp", "nd"]
	var array = []
	if rng.randi_range(0,1):
		array.append(consonants[rng.randi_range(0, consonants.size() - 1)])
	array.append(vowels[rng.randi_range(0, vowels.size() - 1)])
	vowels += ["y", "oo", "ae", "ie", "ee"]
	array.append(consonants[rng.randi_range(0, consonants.size() - 1)])
	if rng.randi_range(0,1):
		array.append(vowels[rng.randi_range(0, vowels.size() - 1)])
		array.append(consonants[rng.randi_range(0, consonants.size() - 1)])
	array.append(vowels[rng.randi_range(0, vowels.size() - 1)])
	if rng.randi_range(0,1):
		array.append(endings[rng.randi_range(0, endings.size() - 1)])
#	return ["".join(PackedStringArray(array))]
	return array

## Generate a random string of letters and numbers
func bot():
	rng.randomize()
	var letters = ["b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "q", "r", "s", "t", "v", "w", "x", "y", "z", "a", "e", "i", "o", "u"]
	var numbers = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
	var array = []
	for i in range (0, rng.randi_range(8, 12)):
		if rng.randi_range(0,1):
			array.append(letters[rng.randi_range(0, letters.size() - 1)])
		else:
			array.append(numbers[rng.randi_range(0, numbers.size() - 1)])
#	return ["".join(PackedStringArray(array))]
	return array

## Select a random word and repeat it twice or thrice.
func repeat(words: Array):
#	var words = ["bees", "cats", "cars", "objects"]
	var word = words[rng.randi_range(0, words.size() - 1)]
	var array = []
	for i in range (0, rng.randi_range(2, 3)):
		array.append(word)
	return array

## Select a random first name and last name.
func name():
#	var firstNames = ["anthony", "mary", "john", "bob"]
	var firstNames = firstNamesArray
	var lastNames = ["doe", "adams", "lee", "white"]
	var array = []
	var firstName = firstNames[rng.randi_range(0, firstNames.size() - 1)]
	var lastName = lastNames[rng.randi_range(0, lastNames.size() - 1)]
	if rng.randi_range(0,1):
		array.append(firstName)
	else:
		array.append(firstName[0])
	if rng.randi_range(0,1):
		var middleName = firstNames[rng.randi_range(0, firstNames.size() - 1)]
		while middleName == firstName:
			middleName = firstNames[rng.randi_range(0, firstNames.size() - 1)]
		if rng.randi_range(0,1):
			array.append(middleName)
		else:
			array.append(middleName[0])
	if rng.randi_range(0,1):
		array.append(lastName)
	else:
		array.append(lastName[0])
	return array

#func name():
#	var firstNames = ["anthony", "mary", "john", "bob"]
#	var lastNames = ["doe", "adams", "lee", "white"]
#	var array = []
#	array.append(firstNames[rng.randi_range(0, firstNames.size() - 1)])
#	array.append(lastNames[rng.randi_range(0, lastNames.size() - 1)])
#	return array

func getRandomNoun() -> String:
#	return nounsArray[rng.randi_range(0, nounsArray.size()-1)].to_lower()
	return nounsArray[rng.randi_range(0, nounsArray.size()-1)].capitalize()
	

func getRandomAdjective() -> String:
#	return adjectivesArray[rng.randi_range(0, adjectivesArray.size()-1)].to_lower()
	return adjectivesArray[rng.randi_range(0, adjectivesArray.size()-1)]
	

func jsonTestCase():
#	print("Adjectives:\n")
	loadJsonFiles(adjectivesDataFilePath, adjectivesArray)
#	for i in range(100):
#		print(adjectivesArray[rng.randi_range(0, adjectivesArray.size()-1)])
#
#	print("Nouns:\n")
	loadJsonFiles(nounsDataFilePath, nounsArray)
#	for i in range(100):
#		print(nounsArray[rng.randi_range(0, nounsArray.size()-1)])
	
	print("dupe test cases:\n")
	for i in range(100):
		print("".join(PackedStringArray(dupe([getRandomNoun()]))))
	print("frames test cases\n")
	for i in range(100):
		print("".join(PackedStringArray(frames([getRandomAdjective(), getRandomNoun()]))))
	print("combine test cases\n")
	for i in range(100):
		print("".join(PackedStringArray(combine())))
#	print("substitution test cases\n")
#	for i in range(100):
#		print("".join(PackedStringArray(substitution([getRandomAdjective(), getRandomNoun()]))))

func modifierTestCases():
	#frames()
	print("This is a test of frames():")
	print("".join(PackedStringArray(frames(["edgy", "username"]))))
	print("".join(PackedStringArray(frames(["dark", "rune", "wizard"]))))
	print("".join(PackedStringArray(frames(["exelsior"]))))
	
#	print(frames(["dark", "rune", "wizard"]).join(""))
#	print(frames(["exelsior"]).join(""))

	print("\n")
	
	#substitution()
	print("This is a test of substitution():")
	print("".join(PackedStringArray(substitution(["carrot", "cakes"]))))
#	print(PoolStringArray(substitution(["leet", "hacker"])).join(""))
#	print(PoolStringArray(substitution(["cool", "excel", "bros"])).join(""))
	print("".join(PackedStringArray(substitution(["leet", "hacker"]))))
	print("".join(PackedStringArray(substitution(["cool", "excel", "bros"]))))
	print("\n")
	
	#number()
	print("This is a test of number():")
	print("".join(PackedStringArray(number(["lovely", "letty"]))))
	print("".join(PackedStringArray(number(["me", "smart"]))))
	print("".join(PackedStringArray(number(["hi", "im", "mary"]))))
	
#	print(PoolStringArray(number(["lovely", "letty"])).join(""))
#	print(PoolStringArray(number(["me", "smart"])).join(""))
#	print(PoolStringArray(number(["hi", "im", "mary"])).join(""))
	print("\n")
	
	#suffix()
	print("This is a test of suffix():")
	print("".join(PackedStringArray(suffix(["omg", "kitty"]))))
	print("".join(PackedStringArray(suffix(["glowing", "green"]))))
	print("".join(PackedStringArray(suffix(["lol", "cat"]))))
	
#	print(PoolStringArray(suffix(["omg", "kitty"])).join(""))
#	print(PoolStringArray(suffix(["glowing", "green"])).join(""))
#	print(PoolStringArray(suffix(["lol", "cat"])).join(""))
	print("\n")
	
	#prefix()
	print("This is a test of prefix():")
	print("".join(PackedStringArray(prefix(["hella", "hot"]))))
	print("".join(PackedStringArray(prefix(["purple", "giraffe"]))))
	print("".join(PackedStringArray(prefix(["orange", "squeezer"]))))
	
	
#	print(PoolStringArray(prefix(["hella", "hot"])).join(""))
#	print(PoolStringArray(prefix(["purple", "giraffe"])).join(""))
#	print(PoolStringArray(prefix(["orange", "squeezer"])).join(""))
	print("\n")
	
	#dupe()
	print("This is a test of dupe():")
	print("".join(PackedStringArray(dupe(["extra", "pizza"]))))
	print("".join(PackedStringArray(dupe(["carbs", "time"]))))
	print("".join(PackedStringArray(dupe(["office", "user"]))))
	
	
#	print(PoolStringArray(dupe(["extra", "pizza"])).join(""))
#	print(PoolStringArray(dupe(["carbs", "time"])).join(""))
#	print(PoolStringArray(dupe(["office", "user"])).join(""))
	print("\n")
	
	#combinations
	print("This is a test of combined modifiers:")
	print("".join(PackedStringArray(frames(edge(["blade", "of", "shadows"])))))
	print("".join(PackedStringArray(suffix(leetspeak(["image", "real"])))))
	print("".join(PackedStringArray(number(netspeak(["2617", "late", "loveyou"])))))
	
	
#	print(PoolStringArray(frames(edge(["blade", "of", "shadows"]))).join(""))
#	print(PoolStringArray(suffix(leetspeak(["image", "real"]))).join(""))
#	print(PoolStringArray(number(netspeak(["2617", "late", "loveyou"]))).join(""))
	print("\n")

func usernameTestCases():
	#combine()
	print("This is a test of combine():")
	print("".join(PackedStringArray(combine())))
	print("".join(PackedStringArray(combine())))
	print("".join(PackedStringArray(combine())))
	
#	print(PoolStringArray(combine()).join(""))
#	print(PoolStringArray(combine()).join(""))
#	print(PoolStringArray(combine()).join(""))
	print("\n")
	
	#imaginary()
	print("This is a test of imaginary():")
	for i in range(100):
		print("".join(PackedStringArray(imaginary())))
#	print("".join(PackedStringArray(imaginary())))
#	print("".join(PackedStringArray(imaginary())))
	
#	print(PoolStringArray(imaginary()).join(""))
#	print(PoolStringArray(imaginary()).join(""))
#	print(PoolStringArray(imaginary()).join(""))
	print("\n")
	
	#bot()
	print("This is a test of bot():")
	print("".join(PackedStringArray(bot())))
	print("".join(PackedStringArray(bot())))
	print("".join(PackedStringArray(bot())))
	
#	print(PoolStringArray(bot()).join(""))
#	print(PoolStringArray(bot()).join(""))
#	print(PoolStringArray(bot()).join(""))
	print("\n")
	
	#repeat()
	print("This is a test of repeat():")
#	print("".join(PackedStringArray(repeat())))
#	print("".join(PackedStringArray(repeat())))
#	print("".join(PackedStringArray(repeat())))

#	print(PoolStringArray(repeat()).join(""))
#	print(PoolStringArray(repeat()).join(""))
#	print(PoolStringArray(repeat()).join(""))
	print("\n")
	
	#name()
	print("This is a test of name():")
	print("".join(PackedStringArray(name())))
	print("".join(PackedStringArray(name())))
	print("".join(PackedStringArray(name())))	
#	print(PoolStringArray(name()).join(""))
#	print(PoolStringArray(name()).join(""))
#	print(PoolStringArray(name()).join(""))
	print("\n")
