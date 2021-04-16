#include <GDIPlus.au3>
#include <GUIConstantsEx.au3>
#include <WinAPISys.au3>
#include <WindowsConstants.au3>
#include "..\LibDebug.au3"
#include "osu!trisMusicPlayer.vars.au3"
#include "Bass.au3"

; HotKeySet("{F6}", "TogglePause")
HotKeySet("{F7}", "Terminate")
; HotKeySet("{F8}", "plus")
; HotKeySet("^{F8}", "subt")
; HotKeySet("{F9}", "plus2")
; HotKeySet("^{F9}", "subt2")
; HotKeySet("{F10}", "plus3")
; HotKeySet("^{F10}", "subt3")

; AdlibRegister("UpdateTitle", 300)
SRandom(@MSEC)

Func plus()
	$triVelocityMultiplier += 1
EndFunc
Func subt()
	$triVelocityMultiplier -= 1
EndFunc
Func plus2()
	$effectPixels += 1
EndFunc
Func subt2()
	$effectPixels -= 1
EndFunc
Func plus3()
	$effectCycleTime += 5
EndFunc
Func subt3()
	$effectCycleTime -= 5
EndFunc

Func GenerateTriangle()
	$tris[$tris[0][0] + 1][$TRIX] = Random(-30, $width + 30, 1)
	$tris[$tris[0][0] + 1][$TRIY] = Random($height + 125, $height + 150, 1)
	$tris[$tris[0][0] + 1][$TRISCALE] = Random(50, 150)
	$tris[$tris[0][0] + 1][$TRISHADE] = Random(0, 9, 1)
	$tris[0][0] += 1
EndFunc

Func RemoveTriangle($ele)
	If $ele = $maxTriAmount Then
	Else
		For $i = $ele To $tris[0][0] - 1
			$tris[$i][$TRIX] = $tris[$i + 1][$TRIX]
			$tris[$i][$TRIY] = $tris[$i + 1][$TRIY]
			$tris[$i][$TRISCALE] = $tris[$i + 1][$TRISCALE]
			$tris[$i][$TRISHADE] = $tris[$i + 1][$TRISHADE]
		Next
	EndIf
	$tris[0][0] -= 1
EndFunc 

Func GenerateParticle()
	$particles[$particles[0][0] + 1][$PARTICLEX] = Random(40, $width - 40, 1)
	$particles[$particles[0][0] + 1][$PARTICLEY] = 0
	$particles[$particles[0][0] + 1][$PARTICLEVX] = Random(-0.5, 0.5)
	$particles[$particles[0][0] + 1][$PARTICLEVY] = Random(0.5, 1)
	$particles[$particles[0][0] + 1][$PARTICLELIFE] = Random(0, 50, 1)
	$particles[0][0] += 1
EndFunc

Func RemoveParticle($ele)
	If $ele = $maxParticleAmount Then
	Else
		For $i = $ele To $particles[0][0] - 1
			$particles[$i][$PARTICLEX] = $particles[$i + 1][$PARTICLEX]
			$particles[$i][$PARTICLEY] = $particles[$i + 1][$PARTICLEY]
			$particles[$i][$PARTICLEVX] = $particles[$i + 1][$PARTICLEVX]
			$particles[$i][$PARTICLEVY] = $particles[$i + 1][$PARTICLEVY]
			$particles[$i][$PARTICLELIFE] = $particles[$i + 1][$PARTICLELIFE]
		Next
	EndIf
	$particles[0][0] -= 1
EndFunc

Global $audioLevelsum
Func AudioLevelAdd(ByRef $value)
	$aAudioLevel[$audioLevelIndex] = $value
	$audioLevelIndex += 1
	If $audioLevelIndex = $audioLevelMaxIndex Then 
		$audioLevelIndex = 0
	EndIf
	$audioLevelsum = 0
	For $i = 0 To $audioLevelMaxIndex - 1
		$audioLevelsum += $aAudioLevel[$i]
	Next
	$audioLevelAverage = $audioLevelsum / $audioLevelMaxIndex
EndFunc

; Global $hTimerUpdate
; Global $nTimerUpdate = 0
Func Update()
	; $hTimerUpdate = TimerInit()
	$playing = _BASS_ChannelIsActive($hAudioStream)
	$channelLevel = $playing ? _Bass_ChannelGetLevel($hAudioStream) : 0
	$currentAudioLevel = (BitShift($channelLevel, 16) + BitAND($channelLevel, 0xFFFF)) / 2
	AudioLevelAdd($currentAudioLevel)
	If $currentAudioLevel > $audioLevelAverage + 500 And TimerDiff($hTimerBeat) > 50 Then
		$beat = True
		$triVelocityMultiplier += 15
		$hTimerBeat = TimerInit()
	Else
		$beat = False
	EndIf
	$deleteCount = 0
	For $i = 1 To $tris[0][0]
		If $tris[$i - $deleteCount][$TRIY] < 0 Then
			RemoveTriangle($i - $deleteCount)
			$deleteCount += 1
		EndIf
	Next
	While $tris[0][0] < $maxTriAmount
		GenerateTriangle()
	WEnd
	If $triVelocityMultiplier > $triVelocityMultiplierMin Then
		$triVelocityMultiplier -= ($triVelocityMultiplier - $triVelocityMultiplierMin) / 3
	EndIf
	For $i = 1 To $tris[0][0]
		$tris[$i][$TRIY] +=  -(($tris[$i][$TRISCALE] / 50 - 1) * (0.5 / 2) + 0.5) * $triVelocityMultiplier
	Next
	; $deleteCount = 0
	; For $i = 1 To $particles[0][0]
		; If $particles[$i][$PARTICLELIFE] > $maxParticleLife Then
			; RemoveParticle($i - $deleteCount)
			; $deleteCount += 1
		; EndIf
	; Next
	; While $particles[0][0] < $maxParticleAmount
		; GenerateParticle()
	; WEnd
	; For $i = 1 To $particles[0][0]
		; $particles[$i][$PARTICLEX] += 3 * $particles[$i][$PARTICLEVX]
		; $particles[$i][$PARTICLEY] += 3 * $particles[$i][$PARTICLEVY]
		; $particles[$i][$PARTICLELIFE] += 1
	; Next
	; $nTimerUpdate = TimerDiff($hTimerUpdate)
EndFunc

; Global $hTimerDraw
; Global $nTimerDraw = 0
Func Draw()
	Local Static $triBuffer[4][2] = [[3, 0x00], [-50.0, 150.0], [300.0, 500.0], [550.0, 150.0]]
	; $hTimerDraw = TimerInit()
	_GDIPlus_GraphicsClear($hFrameBuffer, $bgColorARGB)
	For $i = 1 To $tris[0][0]
		     ; 3
		    ; / \
		   ; /   \
		; 1 ------- 2
		$triBuffer[1][0] = $tris[$i][$TRIX]
		$triBuffer[1][1] = $tris[$i][$TRIY]
		$triBuffer[2][0] = $tris[$i][$TRIX] + $tris[$i][$TRISCALE]
		$triBuffer[2][1] = $tris[$i][$TRIY]
		$triBuffer[3][0] = $tris[$i][$TRIX] + $tris[$i][$TRISCALE] / 2
		$triBuffer[3][1] = $tris[$i][$TRIY] - $tris[$i][$TRISCALE]
		_GDIPlus_GraphicsFillPolygon($hFrameBuffer, $triBuffer, $hBrushTris[$tris[$i][$TRISHADE]])
	Next
	; For $i = 1 to $particles[0][0]
		; _GDIPlus_GraphicsFillEllipse($hFrameBuffer, $particles[$i][$PARTICLEX], $height - $particles[$i][$PARTICLEY], 5, 5, $hBrushParticle)
	; Next
	; $nTimerDraw = TimerDiff($hTimerDraw)
	_GDIPlus_GraphicsFillRect($hFrameBuffer, 5, $height - 5 - 5, _
											$currentAudioLevel / 32768 * 50, 5, $hBrushRed)
	_GDIPlus_GraphicsFillRect($hFrameBuffer, 5 + $audioLevelAverage / 32768 * 50, $height - 5 - 5, _
											2, 5, $hBrushGreen)
	_GDIPlus_GraphicsDrawString($hFrameBuffer, "FPS: " & Round(1000 / $smoothedFrameTime, 1), 150, $height - 15)
EndFunc

; Global $hTimerSwapbuffer
; Global $nTimerSwapbuffer = 0
Func FrameBufferTransfer()
	; $hTimerSwapbuffer = TimerInit()
	_GDIPlus_GraphicsDrawImage($hGraphics, $frameBuffer, 0, 0)
	; $nTimerSwapbuffer = TimerDiff($hTimerSwapbuffer)
EndFunc

Global $nTimerFrame = 0
Func Main()
	_DebugOn()
	_GDIPlus_Startup()
	$hGui = GUICreate($title, $width, $height, Default, Default, Default)
	; $hGui = GUICreate($title, $width, $height, Default, Default, $WS_POPUP, $WS_EX_TOPMOST)
	$hGraphics = _GDIPlus_GraphicsCreateFromHWND($hGui) 
	CreateBrushes()
    GUISetBkColor($bgColorRGB, $hGui)
	$frameBuffer = _GDIPlus_BitmapCreateFromGraphics($width, $height, $hGraphics)
	$hFrameBuffer = _GDIPlus_ImageGetGraphicsContext($frameBuffer)
	_BASS_Startup(@Scriptdir & "\bass.dll")
	_Bass_Init(0)
	$hDllCallback = DllCallbackRegister('WndProc', 'ptr', 'hwnd;uint;wparam;lparam')
	$pDllCallback = DllCallbackGetPtr($hDllCallback)
	$wndprocPreviousValue = _WinAPI_SetWindowLong($hGui, $GWL_WNDPROC, $pDllCallback)
	_WinAPI_DragAcceptFiles($hGui, True)
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

Func LoadAudioAndPlay($filePath)
	If $playing Then
		_BASS_ChannelStop($hAudioStream)
		_BASS_StreamFree($hAudioStream)
	EndIf
	$hAudioStream = _BASS_StreamCreateFile(False, $filePath, 0, 0, 0)
	_Bass_ChannelPlay($hAudioStream, 0)
	$playing = True
EndFunc

; WindowProc callback function that processes messages sent to the window
Func WndProc($hWnd, $idMsg, $wParam, $lParam)
	Switch $idMsg
		Case $WM_DROPFILES
			Local $fileList = _WinAPI_DragQueryFileEx($wParam, 1)
			; Only accept .mp3 file here (case insensitive)
			If StringRight($fileList[1], 4) = ".mp3" Then
				LoadAudioAndPlay($fileList[1])  ; The first element is file amount
			EndIf
			_WinAPI_DragFinish($wParam)
			Return 0
	EndSwitch
	Return _WinAPI_CallWindowProc($wndprocPreviousValue, $hWnd, $idMsg, $wParam, $lParam)
EndFunc

Func CreateBrushes()
	$hBrushRed = _GDIPlus_BrushCreateSolid(0xFFFF0000)
	$hBrushGreen = _GDIPlus_BrushCreateSolid(0xFF00FF00)
	#cs normal tinting and shading
	Local $shadedColor
	Local $r = BitAND(BitShift($bgColorRGB, 16), 0xFF)
	Local $g = BitAND(BitShift($bgColorRGB, 8), 0xFF)
	Local $b = BitAND($bgColorRGB, 0xFF)
	For $i = 0 To 9  ; Create 2 shades + og color + 7 tints of brushes
		$shadedColor = Round($r + (255 - $r) * ($i - 2) / 30) * 256 * 256 + _
					   Round($g + (255 - $g) * ($i - 2) / 30) * 256 + _
					   Round($b + (255 - $b) * ($i - 2) / 30)
		$hBrushTris[$i] = _GDIPlus_BrushCreateSolid(0xFF000000 + $shadedColor)
	Next
	#ce
	; Gradient colors
	Local $shadedColor
	Local $ogR = BitAND(BitShift($bgColorRGB, 16), 0xFF)
	Local $ogG = BitAND(BitShift($bgColorRGB, 8), 0xFF)
	Local $ogB = BitAND($bgColorRGB, 0xFF)
	Local $toR = 0x39
	Local $toG = 0x4D
	Local $toB = 0xDE
	For $i = 0 To 9
		$shadedColor = Round($ogR + ($toR - $ogR) * $i / 10) * 256 * 256 + _
					   Round($ogG + ($toG - $ogG) * $i / 10) * 256 + _
					   Round($ogB + ($toB - $ogB) * $i / 10)
		$hBrushTris[$i] = _GDIPlus_BrushCreateSolid(0xFF000000 + $shadedColor)
	Next
	$hBrushParticle = _GDIPlus_BrushCreateSolid(0x40FF6D1F)
EndFunc

Func UpdateTitle()
	; WinSetTitle($hGui, "", $title & " | FPS: " & Round(1000 / $smoothedFrameTime, 1) & _
									; " | $triVmul: " & $triVelocityMultiplier)
	cv(1, 'smoothedFrameTime', 'nTimerUpdate', 'nTimerDraw', 'nTimerSwapbuffer')
EndFunc

Func GdiPlusClose()
	_GDIPlus_BrushDispose($hBrushRed)
	For $i = 0 To 9
		_GDIPlus_BrushDispose($hBrushTris[$i])
	Next
	_GDIPlus_BrushDispose($hBrushParticle)
	_GDIPlus_BitmapDispose($frameBuffer)
    _GDIPlus_GraphicsDispose($hGraphics)
    _GDIPlus_Shutdown()
EndFunc

Func Terminate()
	_Bass_Free()
	GdiPlusClose()
	_WinAPI_SetWindowLong($hGui, $GWL_WNDPROC, $wndprocPreviousValue)
	DllCallbackFree($hDllCallback)
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