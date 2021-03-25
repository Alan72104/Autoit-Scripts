#include "..\LibDebug.au3"
#include <GDIPlus.au3>
#include <Misc.au3>

Global $frameCount = 6572
Global $hImage[$frameCount]
Global $ascii[$frameCount]
Global $asciiFilePath = @ScriptDir & "\ascii.txt"
Global $asciiFile
Global $frameTimer
Global $gdiStarted = False
HotKeySet("{F7}", "Terminate")
OnAutoItExitRegister("Dispose")

Func Load()
	Local $hFile
	If Not FileExists($asciiFilePath) Then
		c("Creating ascii file")
		$gdiStarted = True
		_GDIPlus_Startup()
		For $i = 0 To $frameCount - 1
			$hImage[$i] = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\img\" & $i + 1 & ".jpeg")
		Next
		$hFile = FileOpen($asciiFilePath, $FO_OVERWRITE)
		FileWrite($hFile, "")
		FileClose($hFile)
		For $i = 0 To $frameCount - 1
			If Mod($i, 50) = 0 Then
				Local $t = TimerInit()
			EndIf
			$asciiFile &= _GDIPlus_Image2AscII($hImage[$i])
			$asciiFile &= @CRLF
			If Mod($i, 50) = 49 Then
				c("50 Frames created, took $ ms, $ frames left", 1, TimerDiff($t), $frameCount - $i + 1)
			EndIf
		Next
		c("Ascii file created successfully, writing file")
		$hFile = FileOpen($asciiFilePath, $FO_OVERWRITE)
		FileWrite($hFile, $asciiFile)
		FileClose($hFile)
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

Func Dispose()
	If Not $gdiStarted Then
		Return
	EndIf
	c("Disposing")
	Local $t = TimerInit()
	For $e In $hImage
		_GDIPlus_ImageDispose($e)
	Next
	_GDIPlus_Shutdown()
	c("Disposing completed, took $ ms", 1, TimerDiff($t))
EndFunc

Main()

Func _GDIPlus_Image2AscII($hImage)
	Local Static $aCharacters = StringSplit("$@B%8&WM#*oahkbdpqwmZO0QLCJUYXzcvunxrjft/\|()1{}[]?-_+~<>i!lI;:,""^`'. ", "", $STR_NOCOUNT)
	; Local Static $aCharacters[18] = ['#','@','&','$','%','*','!','"','+','=','_','-','~',';',':',',','.',Chr(160)]
	Local $iWidth = _GDIPlus_ImageGetWidth($hImage)
	Local $iHeight = _GDIPlus_ImageGetHeight($hImage)
	Local $iWidthAdapted, $iHeightAdapted, $iCoeff = 1.62
	If $iHeight >= $iWidth Then
		$iWidthAdapted = Int((80 * ($iWidth/$iHeight)) * $iCoeff)
		$iHeightAdapted = 80
	Else
		$iWidthAdapted = 130
		$iHeightAdapted = Int((130 * ($iHeight/$iWidth)) / $iCoeff)
	EndIf
	Local $hBitmap_Scaled = _GDIPlus_ImageResize($hImage, $iWidthAdapted, $iHeightAdapted)
	Local $hBitmap = _GDIPlus_BitmapCreateFromScan0($iWidthAdapted, $iHeightAdapted)
	Local $hContext = _GDIPlus_ImageGetGraphicsContext($hBitmap)
	_GDIPlus_GraphicsSetSmoothingMode($hContext, $GDIP_SMOOTHINGMODE_ANTIALIAS8X8)
	_GDIPlus_GraphicsSetCompositingMode($hContext, $GDIP_COMPOSITINGMODESOURCEOVER)
	_GDIPlus_GraphicsSetCompositingQuality($hContext, $GDIP_COMPOSITINGQUALITYASSUMELINEAR)
	_GDIPlus_GraphicsSetInterpolationMode($hContext, $GDIP_INTERPOLATIONMODE_NEARESTNEIGHBOR)
	_GDIPlus_GraphicsSetPixelOffsetMode($hContext, $GDIP_PIXELOFFSETMODE_HIGHQUALITY)
	Local $hEffect1 = _GDIPlus_EffectCreateBrightnessContrast(0, 0)
	_GDIPlus_BitmapApplyEffect($hBitmap_Scaled, $hEffect1)
	Local $hEffect2 = _GDIPlus_EffectCreateHueSaturationLightness(0, 0, 0)
	_GDIPlus_BitmapApplyEffect($hBitmap_Scaled, $hEffect2)
	Local $hIA = _GDIPlus_ImageAttributesCreate()
	Local $tColorMatrix
	Local $iGamma = 0/50
	If $iGamma Then _GDIPlus_ImageAttributesSetGamma($hIA, 0, True, $iGamma) ; values from 0 to 2
	_GDIPlus_GraphicsDrawImageRectRect($hContext, $hBitmap_Scaled, 0, 0, $iWidthAdapted, $iHeightAdapted, 0, 0, $iWidthAdapted, $iHeightAdapted, $hIA)
	Local $tBitmapData = _GDIPlus_BitmapLockBits($hBitmap, 0, 0, $iWidthAdapted, $iHeightAdapted, $GDIP_ILMREAD, $GDIP_PXF32RGB)
	Local $iScan0 = DllStructGetData($tBitmapData, 'Scan0')
	Local $tPixel = DllStructCreate('int[' & $iWidthAdapted * $iHeightAdapted & '];', $iScan0)
	Local $iColor
	Local $aChars[$iWidthAdapted + 1][ $iHeightAdapted + 1]
	Local $sString = '', $iRowOffset
	For $iY = 0 To $iHeightAdapted - 1
		$iRowOffset = $iY * $iWidthAdapted + 1
		For $iX = 0 To $iWidthAdapted - 1
			$iColor = DllStructGetData($tPixel, 1, $iRowOffset + $iX)
			$aChars[$iX][$iY] = $aCharacters[Int(_GDIPlus_ColorGetLuminosity($iColor) / (255 / UBound($aCharacters) + 0.1))]
			$sString &= $aChars[$iX][$iY]
		Next
		$sString &= @CRLF
	Next
	_GDIPlus_BitmapUnlockBits($hBitmap, $tBitmapData)
	_GDIPlus_EffectDispose($hEffect2)
	_GDIPlus_EffectDispose($hEffect1)
	_GDIPlus_GraphicsDispose($hContext)
	_GDIPlus_BitmapDispose($hBitmap)
	_GDIPlus_BitmapDispose($hBitmap_Scaled)
	Return $sString
EndFunc

Func _GDIPlus_ColorGetLuminosity($iColor)
	Return(BitAND(BitShift($iColor, 16), 0xFF) * 0.299) _  ; R
			+ (BitAND(BitShift($iColor, 8), 0xFF) * 0.587) _  ; G
			+ (BitAND($iColor, 0xFF) * 0.114)  ; B
EndFunc

Func _GDIPlus_ImageAttributesSetGamma ( $hImageAttributes, $iColorAdjustType = 0, $fEnable = False, $nGamma = 0 )
	Local $aResult = DllCall ( $__g_hGDIPDll, 'uint', 'GdipSetImageAttributesGamma', 'hwnd', $hImageAttributes, 'int', $iColorAdjustType, 'int', $fEnable, 'float', $nGamma )
	If @error Then Return SetError ( @error, @extended, False )
	Return $aResult[0] = 0
EndFunc

Func Terminate()
	Exit
EndFunc