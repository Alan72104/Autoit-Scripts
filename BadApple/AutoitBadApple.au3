#include "..\LibDebug.au3"
#include <FileConstants.au3>
#include <AutoItConstants.au3>

Global Const $songName = "BadApple"
; Global Const $songName = "lagtrain"
Global Const $width = 180
Global Const $height = 100
Global Const $frameCount = 6572
; Global Const $frameCount = 3777
Global Const $fps = 30
; Global Const $fps = 15

Global $hImage[$frameCount]
Global $ascii[$frameCount]
Global $asciiFilePath = @ScriptDir & "\" & $width & "x" & $height & $songName & ".txt"
Global $asciiFile
Global $audioFilePath = @ScriptDir & "\" & $songName & ".mp3"
Global $frameTimer
Global $gdiStarted = False
Global $processCount = 3
Global $framePerProcess = Floor($frameCount / $processCount)
Global $extraFrame = $frameCount - $framePerProcess * $processCount
Global $pid[$processCount]
Global $processIsActive = False
Global $hasFinished[$processCount]
Global $npPid = 0
HotKeySet("{F7}", "Terminate")
OnAutoItExitRegister("Dispose")

Func Load()
	Local $hFile
	If Not FileExists($asciiFilePath) Then
		c("Creating ascii file")
		$processIsActive = True
		c("Spawning processes, count: $, frame per process: $, extra frame: $", 1, $processCount, $framePerProcess, $extraFrame)
		For $i = 0 To $processCount - 1
			$pid[$i] = Run(@AutoItExe & " ConvertToAscii.Batch.a3x" & " " & _
										1 + $framePerProcess * $i & " " & _
										1 + $framePerProcess * $i + ($framePerProcess - 1) + ($i = $processCount - 1 ? $extraFrame : 0) & " " & _
										"process" & $i + 1 & ".txt" & " " & _
										$width & " " & _
										$height, _
										@ScriptDir & "\", @SW_HIDE, $STDOUT_CHILD)
			c("Process $ spawned", 1, $i + 1)
		Next
		For $i = 0 To $processCount - 1
			$hasFinished[$i] = False
		Next
		Local $out[0]
		While 1
			For $i = 0 To $processCount - 1
				If Not $hasFinished[$i] Then
					$out = StringSplit(StdoutRead($pid[$i]), @CRLF, $STR_ENTIRESPLIT + $STR_NOCOUNT)
					For $ele In $out
						If $ele <> "" Then
							c("[Process" & $i + 1 & "] " & $ele)
							If StringInStr($ele, "Disposing completed") <> 0 Then
								$hasFinished[$i] = True
								ExitLoop
							EndIf
						EndIf
					Next
				EndIf
			Next
			For $i = 0 To $processCount - 1
				If Not $hasFinished[$i] Then ExitLoop
				If $i = $processCount - 1 Then ExitLoop 2
			Next
		WEnd
		$processIsActive = False
		c("Converting finished")
		c("Concating files")
		Local $processFiles[$processCount]
		Local $file
		For $i = 1 To $processCount
			$hFile = FileOpen(@ScriptDir & "\process" & $i & ".txt", $FO_READ)
			$file &= FileRead($hFile)
			FileClose($hFile)
		Next
		$hFile = FileOpen($asciiFilePath, $FO_OVERWRITE)
		FileWrite($hFile, $file)
		FileClose($hFile)
		c("Concating finished")
	EndIf
	c("Loading ascii file")
	Local $t = TimerInit()
	Local $line = ""
	Local $frame = ""
	$hFile = FileOpen($asciiFilePath, $FO_READ)
	For $i = 0 To $frameCount - 1
		$frame = ""
		While 1
			$line = FileReadLine($hFile)
			If $line = "" Then
				ExitLoop
			EndIf
			$frame &= $line & @CRLF
		WEnd
		$ascii[$i] = $frame
	Next
	FileClose($hFile)
	c("Loading completed, took $ ms", 1, TimerDiff($t))
EndFunc

Global $28crlfs = @CRLF&@CRLF&@CRLF&@CRLF&@CRLF&@CRLF&@CRLF&@CRLF&@CRLF&@CRLF&@CRLF&@CRLF&@CRLF&@CRLF&@CRLF&@CRLF&@CRLF&@CRLF&@CRLF&@CRLF&@CRLF&@CRLF&@CRLF&@CRLF&@CRLF&@CRLF&@CRLF&@CRLF

Func Main()
	Load()
	$npPid = Run("notepad.exe")
	Local $hNotepad = WinWaitActive("[CLASS:Notepad]")
	For $i = 5 To 1 Step -1
		c("STARTING IN $", 1, $i)
		ControlSetText($hNotepad, "", "Edit1", $28crlfs & "                                                            STARTING IN " & $i & "!!!!!")
		Sleep(1000)
	Next
	SoundPlay($audioFilePath)
	For $i = 0 To $frameCount - 1
		Do
		Until TimerDiff($frameTimer) >= (1 / $fps) * 1000
		$frameTimer = TimerInit()
		ControlSetText($hNotepad, "", "Edit1", $ascii[$i])
	Next
	Sleep(1000)
	ControlSetText($hNotepad, "", "Edit1", $28crlfs & "                                                            Thanks")
	Sleep(800)
	ControlSetText($hNotepad, "", "Edit1", $28crlfs & "                                                            Thanks"       & @CRLF & _
													  "                                                             For")
	Sleep(800)
	ControlSetText($hNotepad, "", "Edit1", $28crlfs & "                                                            Thanks"       & @CRLF & _
													  "                                                             For"         & @CRLF & _
													  "                                                         Watching!!!!!")
EndFunc

Main()

Func Dispose()
	If $processIsActive Then
		For $i = 0 To $processCount - 1
			If Not $hasFinished[$i] Then
				ProcessClose($pid[$i])
				c("Process killed")
			EndIf
		Next
	EndIf
	For $i = 0 To $processCount
		If FileExists(@ScriptDir & "\process" & $i + 1 & ".txt") Then
			FileDelete(@ScriptDir & "\process" & $i + 1 & ".txt")
		EndIf
	Next
	If $npPid <> 0 Then
		ProcessClose($npPid)
		c("Notepad killed")
	EndIf
EndFunc

Func Terminate()
	Exit
EndFunc