#include <GDIPlus.au3>
#include <GUIConstantsEx.au3>
#include <WinAPISys.au3>
#include <WindowsConstants.au3>
#include "..\LibDebug.au3"
#include "osu!tris.vars.au3"
#include "Bass.au3"

; HotKeySet("{F6}", "TogglePause")  ; F6 - Pause the whole thing
HotKeySet("{F7}", "Terminate")    ; F7 - Exit
; HotKeySet("{F8}", "plus")         ; F8 - Increase triangle speed
; HotKeySet("^{F8}", "subt")        ; Ctrl+F8 - Decrease triangle speed
; HotKeySet("{F9}", "plus2")        ; F9 - Increase effect scale - if effect is applied
; HotKeySet("^{F9}", "subt2")       ; Ctrl+F9 - Decrease effect scale - if effect is applied
; HotKeySet("{F10}", "plus3")       ; F10 - Increase effect speed - if effect is applied
; HotKeySet("^{F10}", "subt3")      ; Ctrl+F10 - Decrease effect speed - if effect is applied

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
	; $tris[$tris[0][0] + 1][$TRISCALE] = Random($width / 10, $width / 4)
	$tris[$tris[0][0] + 1][$TRISHADE] = Random(0, 9, 1)
	$tris[0][0] += 1
EndFunc

Func RemoveTriangle($ele)
	If $ele = $maxTriAmount Then
		; Don't set things back to 0 due to performance reason
	Else
		For $i = $ele To $tris[0][0] - 1
			$tris[$i][$TRIX] = $tris[$i + 1][$TRIX]
			$tris[$i][$TRIY] = $tris[$i + 1][$TRIY]
			$tris[$i][$TRISCALE] = $tris[$i + 1][$TRISCALE]
			$tris[$i][$TRISHADE] = $tris[$i + 1][$TRISHADE]
			; Don't set things back to 0 due to perfoxrmance reason
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
	$aAudioLevel[$audioLevelIndex] = $value  ; Add the value into array
	$audioLevelIndex += 1  ; Current index plus 1
	If $audioLevelIndex = $audioLevelMaxIndex Then  ; Return to 0 when cur. index reach max
		$audioLevelIndex = 0
	EndIf
	$audioLevelsum = 0  ; Reset sum
	For $i = 0 To $audioLevelMaxIndex - 1 ; Add each array element together
		$audioLevelsum += $aAudioLevel[$i]
	Next
	$audioLevelAverage = $audioLevelsum / $audioLevelMaxIndex  ; Set the average
EndFunc

; Global $hTimerUpdate
; Global $nTimerUpdate = 0
Func Update()
	; $hTimerUpdate = TimerInit()
	$channelLevel = _Bass_ChannelGetLevel($hAudioStream)  ; 32 bits returned, high part is left channel, low part is right channel
	$currentAudioLevel = (BitShift($channelLevel, 16) + BitAND($channelLevel, 0xFFFF)) / 2
	AudioLevelAdd($currentAudioLevel)
	If $currentAudioLevel > $audioLevelAverage + 500 And TimerDiff($hTimerBeat) > 100 Then
		$beat = True
		$triVelocityMultiplier += 15
		; $triVelocityMultiplier += $currentAudioLevel / 32767 * 35
		$hTimerBeat = TimerInit()
	Else
		$beat = False
	EndIf
	$deleteCount = 0
	For $i = 1 To $tris[0][0]  ; Delete triangles that exceed the range
		If $tris[$i - $deleteCount][$TRIY] < 0 Then
			RemoveTriangle($i - $deleteCount)
			$deleteCount += 1
		EndIf
	Next
	While $tris[0][0] < $maxTriAmount  ; Generate triangles until count is reached
		GenerateTriangle()
	WEnd
	If $triVelocityMultiplier > $triVelocityMultiplierMin Then
		$triVelocityMultiplier -= ($triVelocityMultiplier - $triVelocityMultiplierMin) / 3
	EndIf
	For $i = 1 To $tris[0][0]  ; Apply movement
		$tris[$i][$TRIY] +=  -(($tris[$i][$TRISCALE] / 50 - 1) * (0.5 / 2) + 0.5) * $triVelocityMultiplier
	Next
	$deleteCount = 0
	For $i = 1 To $particles[0][0]  ; Delete particles that reach it's life
		If $particles[$i][$PARTICLELIFE] > $maxParticleLife Then
			RemoveParticle($i - $deleteCount)
			$deleteCount += 1
		EndIf
	Next
	While $particles[0][0] < $maxParticleAmount
		GenerateParticle()
	WEnd
	For $i = 1 To $particles[0][0]
		$particles[$i][$PARTICLEX] += 3 * $particles[$i][$PARTICLEVX]
		$particles[$i][$PARTICLEY] += 3 * $particles[$i][$PARTICLEVY]
		$particles[$i][$PARTICLELIFE] += 1
	Next
	; $nTimerUpdate = TimerDiff($hTimerUpdate)
EndFunc

; Global $hTimerDraw
; Global $nTimerDraw = 0
Func Draw()
	Local Static $triBuffer[4][2] = [[3, ""], [-50.0, 150.0], [300.0, 500.0], [550.0, 150.0]]
	; $hTimerDraw = TimerInit()
	_GDIPlus_GraphicsClear($hFrameBuffer, $bgColorARGB)
	; Draw the triangles
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
	; Draw the particles
	For $i = 1 to $particles[0][0]
		_GDIPlus_GraphicsFillEllipse($hFrameBuffer, $particles[$i][$PARTICLEX], $height - $particles[$i][$PARTICLEY], 5, 5, $hBrushParticle)
	Next
	; Draw the osu! text and circle
	If $applyEffectAndLogo Then
		_GDIPlus_GraphicsDrawImageRect($hFrameBuffer, $osuLogo, $effectPixels, $effectPixels, $width - 2 * $effectPixels, $height - 2 * $effectPixels)
	EndIf
	; $nTimerDraw = TimerDiff($hTimerDraw)
	; Current audio level and average value
	_GDIPlus_GraphicsFillRect($hFrameBuffer, 5, $height - 5 - 5, _
											$currentAudioLevel / 32768 * 50, 5, $hBrushRed)
	_GDIPlus_GraphicsFillRect($hFrameBuffer, 5 + $audioLevelAverage / 32768 * 50, $height - 5 - 5, _
											2, 5, $hBrushGreen)
	; Current FPS
	_GDIPlus_GraphicsDrawString($hFrameBuffer, "FPS: " & Round(1000 / $smoothedFrameTime, 1), 150, $height - 15)
	; _GDIPlus_GraphicsDrawString($hFrameBuffer, "VelocityMultiplier: " & Round($triVelocityMultiplier, 1), 300, $height - 15)
EndFunc

; Why do we want/need frame buffer?
; A frame buffer holds the "unfinished" frame data we're still drawing onto,
; While keeping the actual screen clean/untouched from different drawing steps

; Global $hTimerSwapbuffer
; Global $nTimerSwapbuffer = 0
Func FrameBufferTransfer()
	; $hTimerSwapbuffer = TimerInit()
	; Draw the framebuffer onto the screen,
	; Also apply the time based zoom-in zoom-out effect
	If $applyEffectAndLogo Then
		$effectLast = TimerDiff($hTimerEffect)
		$effectElapsed = Mod($effectLast, $effectCycleTime)  ; Remove repeating parts of the elapsed time
		If $effectElapsed <= $effectCycleTime * $effectZoomInRatio Then  ; Zoom in part
			$effectOffset = -1 * $effectElapsed / $effectMillisPerPixel
		Else  ; Zoom out part
			$effectOffset = -$effectPixels + ($effectElapsed - $effectCycleTime * $effectZoomInRatio) / $effectMillisPerPixel
		EndIf
		_GDIPlus_GraphicsDrawImageRect($hGraphics, $frameBuffer, 0 + $effectOffset, 0 + $effectOffset, _
																$width + 2 * Abs($effectOffset), $height + 2 * Abs($effectOffset))
		If $effectLast > $effectCycleTime Then
		$hTimerEffect = TimerInit()
		EndIf
	Else
		_GDIPlus_GraphicsDrawImage($hGraphics, $frameBuffer, 0, 0)
	EndIf
	; $nTimerSwapbuffer = TimerDiff($hTimerSwapbuffer)
EndFunc

Global $nTimerFrame = 0
Func Main()
	_DebugOn()
	_GDIPlus_Startup()  ; Start GDI library
	$hGui = GUICreate($title, $width, $height, Default, Default, Default)  ; Create GUI
	; $hGui = GUICreate($title, $width, $height, Default, Default, $WS_POPUP, $WS_EX_TOPMOST)
	$hGraphics = _GDIPlus_GraphicsCreateFromHWND($hGui) 
	CreateBrushes()
    GUISetBkColor($bgColorRGB, $hGui)
	$frameBuffer = _GDIPlus_BitmapCreateFromGraphics($width, $height, $hGraphics)  ; Create framebuffer bitmap
	$hFrameBuffer = _GDIPlus_ImageGetGraphicsContext($frameBuffer)  ; Get the handle to the context of the bitmap in order to pass it to other drawing funcs
	If $osuWhiteBgEnable Then ; Create logo bitmap from the file
		$osuLogo = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\osu!logo with bg.png")
	Else
		$osuLogo = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\osu!logo.png")
	EndIf
	; GUIRegisterMsg($WM_SIZE, "WM_SIZE")  ; TODO: Dynamic resizing
	_BASS_Startup(@Scriptdir & "\bass.dll")  ; Start bass library
	_Bass_Init(0)
	If $useSystemSoundLevel Then
		_BASS_RecordInit(-1)
		$hAudioStream = _BASS_RecordStart(48000, 2, 0, 0)
		_BASS_ChannelPlay($hAudioStream, 0)
	Else
		LoadAudioAndPlay(@Scriptdir & "\music.mp3")
		_BASS_ChannelSetPosition($hAudioStream, _BASS_ChannelGetLength($hAudioStream, $BASS_POS_BYTE) / 100 * 80, $BASS_POS_BYTE)
	EndIf
	$hDllCallback = DllCallbackRegister('WndProc', 'ptr', 'hwnd;uint;wparam;lparam')
	$pDllCallback = DllCallbackGetPtr($hDllCallback)
	$wndprocPreviousValue = _WinAPI_SetWindowLong($hGui, $GWL_WNDPROC, $pDllCallback)
	_WinAPI_DragAcceptFiles($hGui, True)  ; Enable drag and drop for the gui
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
	If _BASS_ChannelIsActive($hAudioStream) Then
		_BASS_RecordFree()
		_BASS_ChannelStop($hAudioStream)
		_BASS_StreamFree($hAudioStream)
	EndIf
	$hAudioStream = _BASS_StreamCreateFile(0, $filePath, 0, 0, $BASS_SAMPLE_LOOP)
	_Bass_ChannelPlay($hAudioStream, 0)
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
	_GDIPlus_BitmapDispose($osuLogo)
    _GDIPlus_GraphicsDispose($hGraphics)
    _GDIPlus_Shutdown()
EndFunc

Func Terminate()
	_BASS_RecordFree()
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