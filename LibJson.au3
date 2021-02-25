#include "LibDebug.au3"

Func ArrayAdd(ByRef $a, ByRef $s)
	ReDim $a[UBound($a) + 1]
	$a[UBound($a) - 1] = $s
EndFunc

Func Lex_String(ByRef $str)
	Local $string = ""
	Local $c
	If StringLeft($str, 1) = '"' Then
		$str = StringTrimLeft($str, 1)
	Else
		Return -1
	EndIf
	For $i = 1 To StringLen($str)
		$c = StringMid($str, $i, 1)
		If $c = '"' Then
			$str = StringTrimLeft($str, StringLen($string) + 1)
			Return $string
		Else
			$string &= $c
		EndIf
	Next
	c("Expected string-end quote")
	Exit -1
EndFunc

Func Lex_Number(ByRef $str)
	Local $number = ""
	Local $c
	For $i = 1 To StringLen($str)
		$c = StringMid($str, $i, 1)
		Switch $c
			Case "0","1","2","3","4","5","6","7","8","9","-","e","."
				$number &= $c
			Case Else
				ExitLoop
		EndSwitch
	Next
	$str = StringTrimLeft($str, StringLen($number))
	If StringLen($number) Then
		Return Number($number)
	Else
		Return -1
	EndIf
EndFunc

Func Lex_Bool(ByRef $str)
	Local $len = StringLen($str)
	If $len >= 4 And StringLeft($str, 4) = "true" Then
		$str = StringTrimLeft($str, 4)
		Return True
	ElseIf $len >= 5 And StringLeft($str, 5) = "false" Then
		$str = StringTrimLeft($str, 5)
		Return False
	EndIf
	Return -1
EndFunc

Func Lex_Null(ByRef $str)
	If StringLen($str) >= 4 And StringLeft($str, 4) = "null" Then
		$str = StringTrimLeft($str, 4)
		Return True
	EndIf
	Return -1
EndFunc

Func Lex($str)
	Local $token = []
	Local $rtn
	Local $first
	While StringLen($str)
		$rtn = Lex_String($str)
		If Not ($rtn == -1) Then
			ArrayAdd($token, $rtn)
			ContinueLoop
		EndIf
		$rtn = Lex_Number($str)
		If Not ($rtn == -1) Then
			ArrayAdd($token, $rtn)
			ContinueLoop
		EndIf
		$rtn = Lex_Bool($str)
		If Not ($rtn == -1) Then
			ArrayAdd($token, $rtn)
			ContinueLoop
		EndIf
		$rtn = Lex_Null($str)
		If Not ($rtn == -1) Then
			ArrayAdd($token, $rtn)
			ContinueLoop
		EndIf
		$first = StringLeft($str, 1)
		Switch $first
			Case " ", Chr(8), Chr(9), Chr(10), Chr(13)  ; character backspace, tab, newline, carriage return
				$str = StringTrimLeft($str, 1)
			Case ",", ":", "[", "]", "{", "}", '"'
				ArrayAdd($token, $first)
				$str = StringTrimLeft($str, 1)
			Case Else
				c("Unexpected character: $", 1, $first)
				Exit -1
		EndSwitch
	WEnd
	Return $token
EndFunc

Global $parsing_index = 0

Func Parse_Array(ByRef $tokens)
	Local $array = []
	Local $t = $tokens[$index]
	If $t == "]" Then
		$parsing_index += 1
		Return $array
	EndIf
	While 1
		Local $json = Parse($tokens)
		ArrayAdd($array, $json)
		$t = $tokens[$parsing_index]
		If $t == "]" Then
			$parsing_index += 1
			Return $array
		ElseIf Not($t == ",")
			c("Expected comma after object in array")
			Exit -1
		Else
			$parsing_index += 1
		EndIf
	WEnd
EndFunc

Func Parse_Object(ByRef $tokens)
	Local $object[] = []
	
EndFunc

Func Parse(ByRef $tokens = [], $root = False)
	If $root Then
		$parsing_index = 0
	EndIf
	Local $t = token[0]
	If $root And Not($t == "{") Then
		c("Root must be an object")
		Exit -1
	EndIf
	Switch $t
		Case "["
			$parsing_index += 1
			Return Parse_Array(tokens, 1)
		Case "{"
			$parsing_index += 1
			Return Parse_Object(tokens, 1)
		Case Else
			$parsing_index += 1
			Return $t
	EndSwitch
EndFunc

Global $HOLYSHITWTFISTHIS = '{"response_code":0,"results":[{"category":"Entertainment: Television","type":"multiple","difficulty":"easy","question":"In the TV show &quot;Cheers&quot;, Sam Malone was a former relief pitcher for which baseball team?","correct_answer":"Boston Red Sox","incorrect_answers":["New York Mets","Baltimore Orioles","Milwaukee Brewers"]},{"category":"Science: Computers","type":"multiple","difficulty":"easy","question":"Which company was established on April 1st, 1976 by Steve Jobs, Steve Wozniak and Ronald Wayne?","correct_answer":"Apple","incorrect_answers":["Microsoft","Atari","Commodore"]},{"category":"Science: Mathematics","type":"multiple","difficulty":"easy","question":"How is the number 9 represented as a binary number?","correct_answer":"1001","incorrect_answers":["1000","1110","1010"]},{"category":"Entertainment: Video Games","type":"multiple","difficulty":"easy","question":"What is the most expensive weapon in Counter-Strike: Global Offensive?","correct_answer":"Scar-20\/G3SG1","incorrect_answers":["M4A1","AWP","R8 Revolver"]},{"category":"Animals","type":"multiple","difficulty":"easy","question":"What is the scientific name for modern day humans?","correct_answer":"Homo Sapiens","incorrect_answers":["Homo Ergaster","Homo Erectus","Homo Neanderthalensis"]},{"category":"Entertainment: Television","type":"multiple","difficulty":"easy","question":"In which British seaside town was the BBC sitcom &quot;Fawlty Towers&quot; set?","correct_answer":"Torquay","incorrect_answers":["Blackpool","Bournemouth","Great Yarmouth"]},{"category":"Entertainment: Film","type":"multiple","difficulty":"easy","question":"This movie contains the quote, &quot;Houston, we have a problem.&quot;","correct_answer":"Apollo 13","incorrect_answers":["The Right Stuff","Capricorn One","Marooned"]},{"category":"Science: Computers","type":"multiple","difficulty":"easy","question":"In the programming language Java, which of these keywords would you put on a variable to make sure it doesn&#039;t get modified?","correct_answer":"Final","incorrect_answers":["Static","Private","Public"]},{"category":"Geography","type":"multiple","difficulty":"easy","question":"Which US state has the highest population?","correct_answer":"California","incorrect_answers":["New York","Texas","Florida"]},{"category":"Science: Computers","type":"multiple","difficulty":"easy","question":"What is the domain name for the country Tuvalu?","correct_answer":".tv","incorrect_answers":[".tu",".tt",".tl"]},{"category":"Entertainment: Japanese Anime & Manga","type":"multiple","difficulty":"easy","question":"What is the name of the corgi in Cowboy Bebop?","correct_answer":"Einstein","incorrect_answers":["Edward","Rocket","Joel"]},{"category":"Entertainment: Film","type":"multiple","difficulty":"easy","question":"Which of these movies did Jeff Bridges not star in?","correct_answer":"The Hateful Eight","incorrect_answers":["Tron: Legacy","The Giver","True Grit"]},{"category":"Entertainment: Video Games","type":"multiple","difficulty":"easy","question":"What is the protagonist&#039;s title given by the demons in DOOM (2016)?","correct_answer":"Doom Slayer","incorrect_answers":["Doom Guy","Doom Marine","Doom Reaper"]},{"category":"Entertainment: Japanese Anime & Manga","type":"multiple","difficulty":"easy","question":"Who is the true moon princess in Sailor Moon?","correct_answer":"Sailor Moon","incorrect_answers":["Sailor Venus","Sailor Mars","Sailor Jupiter"]},{"category":"Entertainment: Music","type":"multiple","difficulty":"easy","question":"Brian May was the guitarist for which band?","correct_answer":"Queen","incorrect_answers":["Pink Floyd","Rolling Stones","The Doors"]},{"category":"Entertainment: Japanese Anime & Manga","type":"boolean","difficulty":"easy","question":"No Game No Life first aired in 2014.","correct_answer":"True","incorrect_answers":["False"]},{"category":"Entertainment: Video Games","type":"multiple","difficulty":"easy","question":"In Undertale, what&#039;s the prize for answering correctly?","correct_answer":"More'
$HOLYSHITWTFISTHIS &= 'questions","incorrect_answers":["New car","Mercy","Money"]},{"category":"Entertainment: Video Games","type":"multiple","difficulty":"easy","question":"What is the default alias that Princess Garnet goes by in Final Fantasy IX?","correct_answer":"Dagger","incorrect_answers":["Dirk","Garnet","Quina"]},{"category":"Entertainment: Video Games","type":"multiple","difficulty":"easy","question":"What video game sparked controversy because of its hidden &quot;Hot Coffee&quot; minigame?","correct_answer":"Grand Theft Auto: San Andreas","incorrect_answers":["Grand Theft Auto: Vice City","Hitman: Blood Money","Cooking Mama"]},{"category":"Entertainment: Japanese Anime & Manga","type":"multiple","difficulty":"easy","question":"In the anime Seven Deadly Sins what is the name of one of the sins?","correct_answer":"Diane","incorrect_answers":["Sakura","Ayano","Sheska"]},{"category":"Entertainment: Music","type":"multiple","difficulty":"easy","question":"The 2016 song &quot;Starboy&quot; by Canadian singer The Weeknd features which prominent electronic artist?","correct_answer":"Daft Punk","incorrect_answers":["deadmau5","Disclosure","DJ Shadow"]},{"category":"Entertainment: Japanese Anime & Manga","type":"multiple","difficulty":"easy","question":"In &quot;A Certain Scientific Railgun&quot;, how many &quot;sisters&quot; did Accelerator have to kill to achieve the rumored level 6?","correct_answer":"20,000","incorrect_answers":["128","10,000","5,000"]},{"category":"Entertainment: Video Games","type":"multiple","difficulty":"easy","question":"Who are the original creators of Rachet &amp; Clank?","correct_answer":"Insomniac Games","incorrect_answers":["PixelTail Games","Rare","Bethesda"]},{"category":"Entertainment: Music","type":"multiple","difficulty":"easy","question":"Which Disney character sings the song &quot;A Dream is a Wish Your Heart Makes&quot;?","correct_answer":"Cinderella","incorrect_answers":["Belle","Snow White","Pocahontas"]},{"category":"Celebrities","type":"multiple","difficulty":"easy","question":"Which celebrity announced his presidency in 2015?","correct_answer":"Kanye West","incorrect_answers":["Donald Trump","Leonardo DiCaprio","Miley Cyrus"]},{"category":"Sports","type":"multiple","difficulty":"easy","question":"What team won the 2016 MLS Cup?","correct_answer":"Seattle Sounders","incorrect_answers":["Colorado Rapids","Toronto FC","Montreal Impact"]},{"category":"Entertainment: Board Games","type":"boolean","difficulty":"easy","question":"&quot;PAYDAY: The Heist&quot; is a sequel to the board game &quot;Payday&quot;.","correct_answer":"False","incorrect_answers":["True"]},{"category":"Entertainment: Film","type":"multiple","difficulty":"easy","question":"When does &quot;Rogue One: A Star Wars Story&quot; take place chronologically in the series?","correct_answer":"Between Episode 3 and 4","incorrect_answers":["After Episode 6","Before Episode 1","Between Episode 4 and 5"]},{"category":"Entertainment: Music","type":"multiple","difficulty":"easy","question":"What was the best selling album of 2015?","correct_answer":"Adele, 25","incorrect_answers":["Fetty Wap, Fetty Wap","Taylor Swift, 1989","Justin Bieber, Purpose"]},{"category":"Science & Nature","type":"multiple","difficulty":"easy","question":"What does LASER stand for?","correct_answer":"Light amplification by stimulated emission of radiation","incorrect_answers":["Lite analysing by stereo ecorazer","Light amplifier by standby energy of radio","Life antimatter by standing entry of '
$HOLYSHITWTFISTHIS &= 'range"]},{"category":"Sports","type":"multiple","difficulty":"easy","question":"What year did the New Orleans Saints win the Super Bowl?","correct_answer":"2010","incorrect_answers":["2008","2009","2011"]},{"category":"Entertainment: Music","type":"multiple","difficulty":"easy","question":"Who performed &quot;I Took A Pill In Ibiza&quot;?","correct_answer":"Mike Posner","incorrect_answers":["Avicii","Robbie Williams","Harry Styles"]},{"category":"Entertainment: Japanese Anime & Manga","type":"multiple","difficulty":"easy","question":"In Digimon, what is the Japanese name for the final evolutionary stage?","correct_answer":"Ultimate","incorrect_answers":["Mega","Adult","Champion"]},{"category":"Entertainment: Japanese Anime & Manga","type":"boolean","difficulty":"easy","question":"Kiznaiver is an adaptation of a manga.","correct_answer":"False","incorrect_answers":["True"]},{"category":"History","type":"boolean","difficulty":"easy","question":"Kublai Khan is the grandchild of Genghis Khan?","correct_answer":"True","incorrect_answers":["False"]},{"category":"Science: Mathematics","type":"boolean","difficulty":"easy","question":"The sum of any two odd integers is odd.","correct_answer":"False","incorrect_answers":["True"]},{"category":"General Knowledge","type":"boolean","difficulty":"easy","question":"Scotland voted to become an independent country during the referendum from September 2014.","correct_answer":"False","incorrect_answers":["True"]},{"category":"Entertainment: Video Games","type":"multiple","difficulty":"easy","question":"Which character in the &quot;Animal Crossing&quot; series uses the phrase &quot;zip zoom&quot; when talking to the player?","correct_answer":"Scoot","incorrect_answers":["Drake","Bill","Mallary"]},{"category":"Entertainment: Video Games","type":"multiple","difficulty":"easy","question":"Who created the &quot;Metal Gear&quot; Series?","correct_answer":"Hideo Kojima","incorrect_answers":["Hiroshi Yamauchi","Shigeru Miyamoto","Gunpei Yokoi"]},{"category":"Science: Computers","type":"multiple","difficulty":"easy","question":"Which programming language shares its name with an island in Indonesia?","correct_answer":"Java","incorrect_answers":["Python","C","Jakarta"]},{"category":"Mythology","type":"boolean","difficulty":"easy","question":"A wyvern is the same as a dragon.","correct_answer":"False","incorrect_answers":["True"]},{"category":"Entertainment: Television","type":"multiple","difficulty":"easy","question":"On the NBC show Community, whose catch-phrase was &quot;Pop! Pop!&quot;?","correct_answer":"Magnitude","incorrect_answers":["Star Burns","Leonard","Senoir Chang"]},{"category":"Animals","type":"boolean","difficulty":"easy","question":"Rabbits can see what&#039;s behind themselves without turning their heads.","correct_answer":"True","incorrect_answers":["False"]},{"category":"General Knowledge","type":"multiple","difficulty":"easy","question":"What is Cynophobia the fear of?","correct_answer":"Dogs","incorrect_answers":["Birds","Flying","Germs"]},{"category":"Sports","type":"multiple","difficulty":"easy","question":"When was the FC Schalke 04 founded?","correct_answer":"1904","incorrect_answers":["1909","2008","1999"]},{"category":"Entertainment: Cartoon & Animations","type":"multiple","difficulty":"easy","question":"In The Simpsons, which war did Seymour Skinner serve in the USA Army as a Green Beret?","correct_answer":"Vietnam War","incorrect_answers":["World War 2","World War 1","Cold War"]},{"category":"General Knowledge","type":"multiple","difficulty":"easy","question":"Which of the following is not the host of a program on NPR?","correct_answer":"Ben Shapiro","incorrect_answers":["Terry Gross","Ira Glass","Peter Sagal"]},{"category":"General Knowledge","type":"multiple","difficulty":"easy","question":"What is the famous Papa John&#039;s last '
$HOLYSHITWTFISTHIS &= 'name?","correct_answer":"Schnatter","incorrect_answers":["Chowder","Williams","ANDERSON"]},{"category":"Entertainment: Film","type":"multiple","difficulty":"easy","question":"Who plays Jack Burton in the movie &quot;Big Trouble in Little China?&quot;","correct_answer":"Kurt Russell","incorrect_answers":["Patrick Swayze","John Cusack","Harrison Ford"]},{"category":"General Knowledge","type":"multiple","difficulty":"easy","question":"What kind of aircraft was developed by Igor Sikorsky in the United States in 1942?","correct_answer":"Helicopter","incorrect_answers":["Stealth Blimp","Jet","Space Capsule"]}]}'

Global $timer = TimerInit()
Global $res = Lex($HOLYSHITWTFISTHIS)
c(TimerDiff($timer))
ca($res)
#include <Array.au3>
_ArrayDisplay($res)