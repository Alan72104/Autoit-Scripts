#include <GDIPlus.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include "LibDebug.au3"

Global Const $width = 1920
Global Const $height = $width / 16 * 9
Global $g_bPaused = False
Global $hGui
Global Const $title = "Sorting - Alan72104"
GlobaL $hGraphics
Global Const $bgColorARGB = 0xFF000000
Global $frameBuffer
Global $hFrameBuffer
Global $brushRed
Global $brushWhite
Global $hTimerFrame, $nTimerFrame, $hTimerUpdate, $nTimerUpdate, $hTimerDraw, $nTimerDraw, $hTimerSwapbuffer, $nTimerSwapBuffer
Global $smoothedFrameTime
Global Const $frameTimeSmoothingRatio = 0.3
Global Const $arrayLength = 2000
Global $array[$arrayLength]
HotKeySet("{F6}", "TogglePause")
HotKeySet("{F7}", "Terminate")

AdlibRegister("Debug", 300)

Func CreateArray()
	Local $timer = TimerInit()
	For $i = 0 To $arrayLength - 1
		$array[$i] = Random(0, $height, 1)
	Next
	c("Created an array of length $, took $ ms", 1, $arrayLength, TimerDiff($timer))
EndFunc

Func Update()
	$hTimerUpdate = TimerInit()
	Local Static $i =1
	If $i < $arrayLength Then
		For $j = 0 To $arrayLength - $i - 1
			If $array[$j] > $array[$j + 1] Then
				Swap($array[$j], $array[$j + 1])
			EndIf
		Next
		$i += 1
	EndIf
	$nTimerUpdate = TimerDiff($hTimerUpdate)
EndFunc

Func Draw()
	; Local Static $elementWidth = ($width - ($arrayLength + 1)) / $arrayLength
	Local Static $elementWidth = $width / $arrayLength
	$hTimerDraw = TimerInit()
	_GDIPlus_GraphicsClear($hFrameBuffer, $bgColorARGB)
	For $i = 0 To $arrayLength - 1
		; _GDIPlus_GraphicsFillRect($hFrameBuffer, 1 + $i + $i * $elementWidth, $height - $array[$i], _
												; $elementWidth, $array[$i], $brushWhite)
		_GDIPlus_GraphicsFillRect($hFrameBuffer, 1 + $i * $elementWidth, $height - $array[$i], _
												$elementWidth, $array[$i], $brushWhite)
	Next
	$nTimerDraw = TimerDiff($hTimerDraw)
EndFunc

Func FrameBufferTransfer()
	$hTimerSwapbuffer = TimerInit()
	_GDIPlus_GraphicsDrawImage($hGraphics, $frameBuffer, 0, 0)
	$nTimerSwapBuffer = TimerDiff($hTimerSwapbuffer)
EndFunc

Func Main()
	_DebugOn()
	_GDIPlus_Startup()
	$hGui = GUICreate($title, $width, $height)
	; $hGui = GUICreate($title, $width, $height, Default, Default, Default, $WS_EX_TOPMOST)
    GUISetBkColor($bgColorARGB - 0xFF000000, $hGui)
	$hGraphics = _GDIPlus_GraphicsCreateFromHWND($hGui) 
	$frameBuffer = _GDIPlus_BitmapCreateFromGraphics($width, $height, $hGraphics)
	$hFrameBuffer = _GDIPlus_ImageGetGraphicsContext($frameBuffer)
	$brushRed = _GDIPlus_BrushCreateSolid(0xFFFF0000)     
	$brushWhite = _GDIPlus_BrushCreateSolid(0xFFFFFFFF)
	CreateArray()
	GUISetState(@SW_SHOW)
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
	cv(1, 'nTimerFrame', 'nTimerUpdate', 'nTimerDraw', 'nTimerSwapBuffer')
EndFunc

Func Swap(ByRef $a, ByRef $b)
	Local $t = $a
	$a = $b
	$b = $t
EndFunc

Func GdiPlusClose()
	_GDIPlus_BrushDispose($brushRed)
	_GDIPlus_BrushDispose($brushWhite)
	_GDIPlus_BitmapDispose($frameBuffer)
    _GDIPlus_GraphicsDispose($hGraphics)
    _GDIPlus_Shutdown()
EndFunc

Func Terminate()
	GdiPlusClose()
    GUIDelete($hGui)
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