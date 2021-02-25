#include <Array.au3>
#include <File.au3>
#include <GDIPlus.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include "..\LibDebug.au3"

Global Const $width = 551
Global Const $height = 252
Global $g_bPaused = False
Global $hGui
Global Const $title = "Crate Simulator"
GlobaL $hGraphics
Global Const $bgColorARGB = 0xFFFFFFFF
Global $frameBuffer
Global $hFrameBuffer
Global $hTimerFrame, $nTimerFrame, $hTimerUpdate
Global $smoothedFrameTime
Global Const $frameTimeSmoothingRatio = 0.3
Global $crate, $itemBox, $itemKey, $itemMoney, $itemGlass  ; Item image
Global Enum $EMPTY,$MONEY,$SUPPLY,$MEGA,$SPAWNER,$COSMETIC,$BOX1,$BOX2,$BOX3,$BOX4,$BOX5
;  chance, name
Global $item = [[10,"$10000"],[15,"Supply Crate"],[15,"Mega Crate"],[8,"Spawner Crate"],[2,"Cosmetic Crate"], _
					[14,"Mystery Box 1*"],[12,"Mystery Box 2*"],[10,"Mystery Box 3*"],[8,"Mystery Box 4*"],[6,"Mystery Box 5*"]]
;  x, y, item
Global $inv[18][3] = [[0,0,0],[1,0,0],[2,0,0],[3,0,0],[4,0,0],[5,0,0],[6,0,0],[6,1,0],[6,2,0],[6,3,0],[5,3,0],[4,3,0],[3,3,0],[2,3,0],[1,3,0],[0,3,0],[0,2,0],[0,1,0]]
Global $selected = False
Global $selectedSlot = 0
Global $penWhite, $brushWhite
Global $spinSlot = 0
Global $spinning = False
Global $spinRestart = False
Global $rewards[0]
Global $autoRestart = False
Global $timer = Random(42, 68, 1)
Global $full = 0
Global $slower = 0
Global $slowSpin[10] = [46,37,29,22,16,11,7,4,2,1]
HotKeySet("{F6}", "TogglePause")
HotKeySet("{F7}", "Terminate")
; HotKeySet("{F8}", "GenRewards")
HotKeySet("{NUMPAD7}", "SelectPrev")
HotKeySet("{NUMPAD8}", "SelectNext")
HotKeySet("{NUMPAD9}", "SwitchSelect")
HotKeySet("{NUMPAD3}", "RestartSpin")
HotKeySet("{NUMPAD2}", "AutoRestartSwitch")

; AdlibRegister("Debug", 300)

Func SelectPrev()
	$selectedSlot -= 1
	If $selectedSlot < 0 Then $selectedSlot = 17
EndFunc
Func SelectNext()
	$selectedSlot += 1
	If $selectedSlot > 17 Then $selectedSlot = 0
EndFunc
Func SwitchSelect()
	$selected = Not $selected
EndFunc
Func RestartSpin()
	$spinRestart = True
EndFunc
Func AutoRestartSwitch()
	$autoRestart = Not $autoRestart
EndFunc

Func ArrayAdd(ByRef $a, $v)
	ReDim $a[UBound($a) + 1]
	$a[UBound($a) - 1] = $v
EndFunc

Func GetPrize()
	Local $prizes[0]
	Do 
		For $i= 0 To UBound($item) - 1
			If Random(1, 100, 1) <= $item[$i][0] Then
				ArrayAdd($prizes, $i)
			EndIf
		Next
	Until UBound($prizes) > 0
	Return $prizes[Random(0, UBound($prizes) - 1, 1)]
EndFunc

Func GenRewards()
	For $i = 0 To 17
		$inv[$i][2] = GetPrize() + 1
	Next
EndFunc

Global $runCount = 0
Func Update()
	Local Static $i = 0
	Local Static $timerRun = TimerInit()
	If $spinRestart = True Then
		GenRewards()
		$i = 0
		$timer = Random(42, 68, 1)
		$full = 0
		$slower = 0
		$spinRestart = False
		$spinning = True
	EndIf
	If $spinning Then
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
				SoundPlay(@ScriptDir & "\levelup.mp3")
			EndIf
			If $full >= $timer + 55 + 47 Then
				ArrayAdd($rewards, $inv[$spinSlot][2] - 1)
				$spinning = False
				If $autoRestart Then $spinRestart = True
				$runCount += 1
				c("$ times completed, took $ ms", 1, $runCount, TimerDiff($timerRun))
				$timerRun = TimerInit()
			EndIf
			$slower += 1
		EndIf
		$full += 1
	EndIf
EndFunc

Func Draw()
	_GDIPlus_GraphicsClear($hFrameBuffer, $bgColorARGB)
	_GDIPlus_GraphicsDrawImage($hFrameBuffer, $crate, 0, 0)
	For $i = 0 to 17
		Switch $inv[$i][2]
			Case 0
			Case $BOX1,$BOX2,$BOX3,$BOX4,$BOX5
				_GDIPlus_GraphicsDrawImage($hFrameBuffer, $itemBox, 51 + (4 + 32) * $inv[$i][0], 72 + (4 + 32) * $inv[$i][1])
			Case $SUPPLY,$MEGA,$SPAWNER,$COSMETIC
				_GDIPlus_GraphicsDrawImage($hFrameBuffer, $itemKey, 51 + (4 + 32) * $inv[$i][0], 72 + (4 + 32) * $inv[$i][1])
			Case $MONEY
				_GDIPlus_GraphicsDrawImage($hFrameBuffer, $itemMoney, 51 + (4 + 32) * $inv[$i][0], 72 + (4 + 32) * $inv[$i][1])
		EndSwitch
	Next
	If $spinning Then
		_GDIPlus_GraphicsDrawImage($hFrameBuffer, $itemGlass, 51 + (4 + 32) * $inv[$spinSlot][0], 72 + (4 + 32) * $inv[$spinSlot][1])
	EndIf
	If $selected Then
		_GDIPlus_GraphicsDrawRect($hFrameBuffer, 51 + (4 + 32) * $inv[$selectedSlot][0], 72 + (4 + 32) * $inv[$selectedSlot][1], 31, 31, $penWhite)
		_GDIPlus_GraphicsDrawString($hFrameBuffer, "selected: " & $item[$inv[$selectedSlot][2] - 1][1], 351 + 10, 10)
	EndIf
	For $i = 0 To 4
		If UBound($rewards) - $i > 0 Then
			Switch $rewards[UBound($rewards) - 1 - $i] + 1
				Case $BOX1,$BOX2,$BOX3,$BOX4,$BOX5
					_GDIPlus_GraphicsDrawImage($hFrameBuffer, $itemBox, 351 + 10 + $i * (5 + 32), 30)
				Case $SUPPLY,$MEGA,$SPAWNER,$COSMETIC
					_GDIPlus_GraphicsDrawImage($hFrameBuffer, $itemKey, 351 + 10 + $i * (5 + 32), 30)
				Case $MONEY
					_GDIPlus_GraphicsDrawImage($hFrameBuffer, $itemMoney, 351 + 10 + $i * (5 + 32), 30)
			EndSwitch
		Else
			ExitLoop
		EndIf
	Next
	_GDIPlus_GraphicsDrawString($hFrameBuffer, "Count      %", 351 + 10 + 100, 65)
	For $i = 0 To UBound($item) - 1
		Local $count = UBound(_ArrayFindAll($rewards, $i))
		_GDIPlus_GraphicsDrawString($hFrameBuffer, $item[$i][1], 351 + 10, 80 + $i * 15)
		_GDIPlus_GraphicsDrawString($hFrameBuffer, $count, 351 + 10 + 100, 80 + $i * 15)
		_GDIPlus_GraphicsDrawString($hFrameBuffer, Round($count / UBound($rewards) * 100, 1) & "%", 351 + 10 + 140, 80 + $i * 15)
	Next
	If $autoRestart Then _GDIPlus_GraphicsDrawString($hFrameBuffer, "AutoRestart On", 351 + 10, 80 + UBound($item) * 15 + 2, "Arial", 8)
	_GDIPlus_GraphicsDrawString($hFrameBuffer, "Total: " & UBound($rewards), 351 + 10 + 100, 80 + UBound($item) * 15)
EndFunc

Func FrameBufferTransfer()
	_GDIPlus_GraphicsDrawImage($hGraphics, $frameBuffer, 0, 0)
EndFunc

Func Main()
	_DebugOn()
	_GDIPlus_Startup()
	; $hGui = GUICreate($title, $width, $height)
	$hGui = GUICreate($title, $width, $height, Default, Default, Default, $WS_EX_TOPMOST)
    GUISetBkColor($bgColorARGB - 0xFF000000, $hGui)
	$hGraphics = _GDIPlus_GraphicsCreateFromHWND($hGui) 
	$frameBuffer = _GDIPlus_BitmapCreateFromGraphics($width, $height, $hGraphics)
	$hFrameBuffer = _GDIPlus_ImageGetGraphicsContext($frameBuffer)
	If @Compiled Then
		FileInstall("crate.png", @ScriptDir & "\crate.png")
		FileInstall("itemBox.png", @ScriptDir & "\itemBox.png")
		FileInstall("itemKey.png", @ScriptDir & "\itemKey.png")
		FileInstall("itemMoney.png", @ScriptDir & "\itemMoney.png")
		FileInstall("itemGlass.png", @ScriptDir & "\itemGlass.png")
	EndIf
	$crate = _GDIPlus_BitmapCreateFromFile(@ScriptDir & "\crate.png")
	$itemBox = _GDIPlus_BitmapCreateFromFile(@ScriptDir & "\itemBox.png")
	$itemKey = _GDIPlus_BitmapCreateFromFile(@ScriptDir & "\itemKey.png")
	$itemMoney = _GDIPlus_BitmapCreateFromFile(@ScriptDir & "\itemMoney.png")
	$itemGlass = _GDIPlus_BitmapCreateFromFile(@ScriptDir & "\itemGlass.png")
	$penWhite = _GDIPlus_PenCreate(0xFFFFFFFF, 1)
	$brushWhite = _GDIPlus_BrushCreateSolid(0xFFFFFFFF)
	GUISetState(@SW_SHOW)
	GenRewards()
	While 1
		$hTimerFrame = TimerInit()
		Update()
		Draw()
		FrameBufferTransfer()
		$nTimerFrame = TimerDiff($hTimerFrame)
		$smoothedFrameTime = ($smoothedFrameTime * (1 - $frameTimeSmoothingRatio)) + $nTimerFrame * $frameTimeSmoothingRatio
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				Terminate()
		EndSwitch
	WEnd
EndFunc

Main()

Func Debug()
	c($smoothedFrameTime)
EndFunc

Func GdiPlusClose()
	_GDIPlus_BitmapDispose($frameBuffer)
    _GDIPlus_GraphicsDispose($hGraphics)
    _GDIPlus_Shutdown()
EndFunc

Func Terminate()
	GdiPlusClose()
    GUIDelete($hGui)
	_FileWriteFromArray(@ScriptDir & "\rewards.txt", $rewards)
    Exit 0
EndFunc

Func TogglePause()
    $g_bPaused = Not $g_bPaused
    While $g_bPaused
        Sleep(500)
        ToolTip('Script is "Paused"', @desktopWidth / 2, @desktopHeight / 2, Default, Default, $TIP_CENTER)
    WEnd
	ToolTip("")
EndFunc