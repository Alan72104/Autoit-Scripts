#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/pe /sf /mo /sv /rm
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <Array.au3>
#include <File.au3>
#include "..\LibDebug.au3"

Global $i = 0
Global $timer = 0
Global $full = 0
Global $slower = 0
Global Const $slowSpin[10] = [46,37,29,22,16,11,7,4,2,1]
Global $timerRun
If $CmdLine[0] > 0 Then 
	Global Const $runCount = $CmdLine[1]
Else
	Global Const $runCount = 1000
EndIf
Global $rewards[$runCount]
; Chance in 100
Global Const $item[10] = [10,15,15,8,2,14,12,10,8,6]
; Global Const $item = [8,10,6,7,10,12,10,8,2,10,8,5,3,1]
Global $inv[18] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
Global $timesRun = 0
Global Const $itemName[UBound($item)] = ["$10000","Supply Crate","Mega Crate","Spawner Crate","Cosmetic Crate", _
									"Mystery Box 1*","Mystery Box 2*","Mystery Box 3*","Mystery Box 4*","Mystery Box 5*"]
; Global Const $itemName[UBound($item)] = ["$10000","Supply Crate","Mega Crate","Spawner Crate","Command Crate","500 Points","1000 Points","2500 Points", _
									; "Cosmetic Crate","Mystery Box 1*","Mystery Box 2*","Mystery Box 3*","Mystery Box 4*","Mystery Box 5*"]
HotKeySet("{F7}", "Terminate")
HotKeySet("{F8}", "PrintResultAndSleep")

Func ArrayAdd(ByRef $a, $v)
	ReDim $a[UBound($a) + 1]
	$a[UBound($a) - 1] = $v
EndFunc

Func GetPrize()
	Local $prizes[0]
	Do 
		For $i= 0 To UBound($item) - 1
			If Random(1, 100, 1) <= $item[$i] Then
				ArrayAdd($prizes, $i)
			EndIf
		Next
	Until UBound($prizes) > 0
	Return $prizes[Random(0, UBound($prizes) - 1, 1)]
EndFunc

Func GenRewards()
	For $i = 0 To 17
		$inv[$i] = GetPrize()
	Next
EndFunc

Func RunOnce(ByRef $ele)
	GenRewards()
	$i = 0
	$timer = Random(42, 68, 1)
	$full = 0
	$slower = 0
	While 1
		If $i > 17 Then $i = 0
		If $full < $timer Then
			$spinSlot = $i
			$i += 1
		EndIf
		If $full >= $timer Then
			If _ArraySearch($slowSpin, $slower) > -1 Then
				$spinSlot = $i
				$i += 1
			EndIf
			If $full = $timer + 47 Then
				; SoundPlay(@ScriptDir & "\levelup.mp3")
			EndIf
			If $full >= $timer + 55 + 47 Then
				$rewards[$ele] = $inv[$spinSlot]
				ExitLoop
			EndIf
			$slower += 1
		EndIf
		$full += 1
	WEnd
EndFunc

Func PrintResult(ByRef $timesRun)
	c("Result of $ times running:", 1, $timesRun)
	For $i = 0 To UBound($item) - 1
		Local $count = UBound(_ArrayFindAll($rewards, $i, 0, $timesRun))
		c("Reward [$] - Count: $ Percentage: $", 1, $itemName[$i], $count, Round($count / $timesRun * 100, 1))
	Next
EndFunc

Func PrintResultAndSleep()
	PrintResult($timesRun)
	c("Sleeping for 5000 ms")
	Sleep(5000)
	c("Running")
EndFunc

Func Main()
	For $i = 0 To $runCount - 1
		$timerRun = TimerInit()
		RunOnce($i)
		c("$ times completed, took $ ms", 1, $i + 1, TimerDiff($timerRun))
		$timesRun += 1
	Next
	c("all completed")
	PrintResult($timesRun)
	c("press F7 to terminate and save the result to rewards.batch.txt")
	While 1
		Sleep(1000)
	WEnd
EndFunc

Main()

Func Terminate()
	ArrayAdd($rewards, iv("Result of $ times running:", $timesRun))
	For $i = 0 To UBound($item) - 1
		Local $count = UBound(_ArrayFindAll($rewards, $i, 0, $timesRun))
		ArrayAdd($rewards, iv("Reward [$] - Count: $ Percentage: $", $itemName[$i], $count, Round($count / $timesRun * 100, 1)))
	Next
	_FileWriteFromArray(@ScriptDir & "\rewards.batch.txt", $rewards)
    Exit 0
EndFunc