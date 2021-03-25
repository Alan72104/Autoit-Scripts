#include "..\LibDebug.au3"
#include <FileConstants.au3>
#include <AutoItConstants.au3>

Global $frameCount = 6572
Global $hImage[$frameCount]
Global $ascii[$frameCount]
Global $asciiFilePath = @ScriptDir & "\ascii.txt"
Global $asciiFile
Global $frameTimer
Global $gdiStarted = False
Global $width = 160
Global $height = 120
Global $processCount = 4
Global $framePerProcess = Floor($frameCount / $processCount)
Global $extraFrame = $frameCount - $framePerProcess * $processCount
Global $pid[$processCount]
Global $processIsActive = False
Global $hasFinished[$processCount]
HotKeySet("{F7}", "Terminate")
OnAutoItExitRegister("Dispose")

Func Load()
	Local $hFile
	If Not FileExists($asciiFilePath) Then
		c("Creating ascii file")
		$processIsActive = True
		c("Spawning processes, count: $, frame per process: $, extra frame: $", 1, $processCount, $framePerProcess, $extraFrame)
		For $i = 0 To $processCount - 1
			$pid[$i] = Run(@AutoItExe & " ConvertToAscii.Batch.a3x " & _
										1 + $framePerProcess * $i & " " & _
										1 + $framePerProcess * $i + ($framePerProcess - 1) + ($i = $processCount - 1 ? $extraFrame : 0) & " " & _
										'"process' & $i + 1 & '.txt" ' & $width & " " & $height, @ScriptDir & "\", @SW_HIDE, $STDOUT_CHILD)
			c("Process $ spawned", 1, $i + 1)
		Next
		For $i = 0 To $processCount - 1
			$hasFinished[$i] = False
		Next
		Local $out = ""
		While 1
			For $i = 0 To $processCount - 1
				If Not $hasFinished[$i] Then
					$out = StdoutRead($pid[$i])
					If $out <> "" Then
						c("[Process" & $i + 1 & "] " & $out, False)
						If StringInStr($out, "Disposing completed") <> 0 Then
							$hasFinished[$i] = True
						EndIf
					EndIf
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
	Run("notepad.exe")
	Local $hNotepad = WinWaitActive("[CLASS:Notepad]")
	For $i = 5 To 1 Step -1
		c("STARTING IN $", 1, $i)
		ControlSetText($hNotepad, "", "Edit1", $28crlfs & "                                                            STARTING IN " & $i & "!!!!!")
		Sleep(1000)
	Next
	SoundPlay(@ScriptDir & "\BadApple.mp3")
	For $i = 0 To $frameCount - 1
		Do
		Until TimerDiff($frameTimer) >= (1 / 30) * 1000  ; 30 fps
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
				Local $hWnd = _WinGetHandleFromPid($pid[$i])
				If $hWnd <> -1 Then
					WinKill(c($hWnd))
					c("Process killed")
				EndIf
			EndIf
		Next
	EndIf
EndFunc

Func Terminate()
	Exit
EndFunc

Func _WinGetHandleFromPid($pid)
    Local $winList = WinList()
    For $i = 1 To $winList[0][0]
        If $pid = WinGetProcess($winList[$i][1]) Then
			ConsoleWrite("@@ " & $i & " | " & WinGetProcess($winList[$i][1]) & " | " & $winList[$i][0] & " | " & $winList[$i][1] & @CRLF)
            Return $winList[$i][1]
        EndIf
    Next
    Return -1
EndFunc