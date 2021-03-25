#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Outfile_type=a3x
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include "..\LibDebug.au3"
#include <GDIPlus.au3>

If $CmdLine[0] <> 5 Then
	Exit MsgBox($MB_SYSTEMMODAL, "Error", "Param amount must be 5!")
EndIf

Global $startNum = $CmdLine[1]
Global $endNum = $CmdLine[2]
Global $filePath = @ScriptDir & "\" & $CmdLine[3]
Global $iWidthAdapted = $CmdLine[4]
Global $iHeightAdapted = $CmdLine[5]

Global $hImage[$endNum - $startNum + 1]
Global $hFile
Global $file = ""
Global $t = 0
Global $tLastFrame = 0
Global $timer = 0
OnAutoItExitRegister("Dispose")

Func Main()
	c("Starting, start: $, end: $, file: ""$"", width: $, height: $", 1, $startNum, $endNum, $filePath, $iWidthAdapted, $iHeightAdapted)
	_GDIPlus_Startup()
	c("Loading all image files")
	For $i = 0 To $endNum - $startNum
		$hImage[$i] = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\img\" & $i + $startNum & ".jpeg")
	Next
	c("Image files loaded")
	c("Creating file")
	$hFile = FileOpen($filePath, $FO_OVERWRITE)
	FileWrite($hFile, "")
	FileClose($hFile)
	c("File created")
	c("Converting")
	$timer = TimerInit()
	For $i = 0 To $endNum - $startNum
		If Mod($i, 25) = 0 Then
			$t = TimerInit()
			$tLastFrame = $i
		EndIf
		$file &= _GDIPlus_Image2AscII($hImage[$i])
		$file &= @CRLF
		If Mod($i, 25) = 24 Or $i = $endNum - $startNum Then
			c("$ frames converted, took $ ms, $ frames left", 1, $i - $tLastFrame + 1, TimerDiff($t), $endNum - $startNum - $i)
		EndIf
	Next
	c("All iamges converted successfully, took $ ms, writing file", 1, TimerDiff($timer))
	$hFile = FileOpen($filePath, $FO_OVERWRITE)
	FileWrite($hFile, $file)
	FileClose($hFile)
EndFunc

Main()

Func Dispose()
	c("Disposing")
	$t = TimerInit()
	For $e In $hImage
		_GDIPlus_ImageDispose($e)
	Next
	_GDIPlus_Shutdown()
	c("Disposing completed, took $ ms", 1, TimerDiff($t))
EndFunc

Func _GDIPlus_Image2AscII($hImage)
	Local Static $aCharacters = StringSplit("$@B%8&WM#*oahkbdpqwmZO0QLCJUYXzcvunxrjft/\|()1{}[]?-_+~<>i!lI;:,""^`'. ", "", $STR_NOCOUNT)
	; Local Static $aCharacters[18] = ['#','@','&','$','%','*','!','"','+','=','_','-','~',';',':',',','.',Chr(160)]
	Local $iWidth = _GDIPlus_ImageGetWidth($hImage)
	Local $iHeight = _GDIPlus_ImageGetHeight($hImage)
	Local $iCoeff = 1.62
	; If $iHeight >= $iWidth Then
		; $iWidthAdapted = Int((80 * ($iWidth/$iHeight)) * $iCoeff)
		; $iHeightAdapted = 80
	; Else
		; $iWidthAdapted = 130
		; $iHeightAdapted = Int((130 * ($iHeight/$iWidth)) / $iCoeff)
	; EndIf
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