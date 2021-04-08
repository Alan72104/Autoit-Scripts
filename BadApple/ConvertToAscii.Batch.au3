#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Outfile_type=a3x
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Tidy_Stop_OnError=n
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/pe /sf /sv
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include "..\LibDebug.au3"
#include <GDIPlus.au3>

If $CmdLine[0] <> 5 Then
	Exit MsgBox($MB_SYSTEMMODAL, "Error", "Param amount must be 5!")
EndIf

Global $startNum = $CmdLine[1]
Global $endNum = $CmdLine[2]
Global $filePath = @ScriptDir & "\" & $CmdLine[3]
Global $iWidthNew = $CmdLine[4]
Global $iHeightNew = $CmdLine[5]

Global $hImage[$endNum - $startNum + 1]
Global $hFile
Global $file = ""
Global $t = 0
Global $tLastFrame = 0
Global $timer = 0
Global $hBmp
Global $hCtx
OnAutoItExitRegister("Dispose")

Func Main()
	c("Starting, start: $, end: $, file: ""$"", width: $, height: $", 1, $startNum, $endNum, $filePath, $iWidthNew, $iHeightNew)
	_GDIPlus_Startup()
	InitConvertingBase()
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
		If Mod($i, 25) = 0 Or $i = 0 Then
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

Func InitConvertingBase()
	$hBmp = __GDIPlus_BitmapCreateFromScan0($iWidthNew, $iHeightNew)
	$hCtx = __GDIPlus_ImageGetGraphicsContext($hBmp)
	__GDIPlus_GraphicsSetSmoothingMode($hCtx, $GDIP_SMOOTHINGMODE_ANTIALIAS8X8)
	__GDIPlus_GraphicsSetCompositingMode($hCtx, $GDIP_COMPOSITINGMODESOURCEOVER)
	__GDIPlus_GraphicsSetCompositingQuality($hCtx, $GDIP_COMPOSITINGQUALITYASSUMELINEAR)
	__GDIPlus_GraphicsSetInterpolationMode($hCtx, $GDIP_INTERPOLATIONMODE_NEARESTNEIGHBOR)
	__GDIPlus_GraphicsSetPixelOffsetMode($hCtx, $GDIP_PIXELOFFSETMODE_HIGHQUALITY)
EndFunc

Func Dispose()
	c("Disposing")
	$t = TimerInit()
	_GDIPlus_GraphicsDispose($hCtx)
	_GDIPlus_BitmapDispose($hBmp)
	For $e In $hImage
		_GDIPlus_ImageDispose($e)
	Next
	_GDIPlus_Shutdown()
	c("Disposing completed, took $ ms", 1, TimerDiff($t))
EndFunc

Func _GDIPlus_Image2AscII($hImg)
	Local Static $aChars = StringSplit("$@B%8&WM#*oahkbdpqwmZO0QLCJUYXzcvunxrjft/\|()1{}[]?-_+~<>i!lI;:,""^`'. ", "", $STR_NOCOUNT)
	Local Static $iWidth = __GDIPlus_ImageGetWidth($hImg)
	Local Static $iHeight = __GDIPlus_ImageGetHeight($hImg)
	Local Static $iWidthNew = $CmdLine[4]
	Local Static $iHeightNew = $CmdLine[5]
	Local $hBmpScaled = __GDIPlus_ImageResize($hImg, $iWidthNew, $iHeightNew)
	Local Static $hiaEmpty = __GDIPlus_ImageAttributesCreate()
	__GDIPlus_GraphicsDrawImageRectRect($hCtx, $hBmpScaled, 0, 0, $iWidthNew, $iHeightNew, 0, 0, $iWidthNew, $iHeightNew)
	Local $tbmpData = __GDIPlus_BitmapLockBits($hBmp, 0, 0, $iWidthNew, $iHeightNew)
	Local $iScan0 = DllStructGetData($tbmpData, 'Scan0')
	Local $tPixel = DllStructCreate('int[' & $iWidthNew * $iHeightNew & '];', $iScan0)
	Local $iColor
	; Local $aChars[$iWidthNew + 1][$iHeightNew + 1]
	Local $sString = '', $iRowOffset
	For $iY = 0 To $iHeightNew - 1
		$iRowOffset = $iY * $iWidthNew + 1
		For $iX = 0 To $iWidthNew - 1
			$iColor = DllStructGetData($tPixel, 1, $iRowOffset + $iX)
			$sString &= $aChars[Int(_GDIPlus_ColorGetLuminosity($iColor) / (255 / UBound($aChars) + 0.1))]
		Next
		$sString &= @CRLF
	Next
	_GDIPlus_BitmapUnlockBits($hBmp, $tbmpData)
	_GDIPlus_BitmapDispose($hBmpScaled)
	Return $sString
EndFunc

Func __GDIPlus_ImageGetHeight($hImage)
	Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipGetImageHeight", "handle", $hImage, "uint*", 0)
	Return $aResult[2]
EndFunc

Func __GDIPlus_ImageGetWidth($hImage)
	Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipGetImageWidth", "handle", $hImage, "uint*", -1)
	Return $aResult[2]
EndFunc

Func __GDIPlus_ImageResize($hImage, $iNewWidth, $iNewHeight)
	Local $hBitmap = __GDIPlus_BitmapCreateFromScan0($iNewWidth, $iNewHeight)
	Local $hBmpCtx = __GDIPlus_ImageGetGraphicsContext($hBitmap)
	_GDIPlus_GraphicsSetInterpolationMode($hBmpCtx, $GDIP_INTERPOLATIONMODE_HIGHQUALITYBICUBIC)
	_GDIPlus_GraphicsDrawImageRect($hBmpCtx, $hImage, 0, 0, $iNewWidth, $iNewHeight)
	_GDIPlus_GraphicsDispose($hBmpCtx)
	Return $hBitmap
EndFunc

Func __GDIPlus_BitmapCreateFromScan0($iWidth, $iHeight)
	Local $aResult = DllCall($__g_hGDIPDll, "uint", "GdipCreateBitmapFromScan0", "int", $iWidth, "int", $iHeight, "int", 0, "int", $GDIP_PXF32ARGB, "struct*", 0, "handle*", 0)
	Return $aResult[6]
EndFunc

Func __GDIPlus_ImageGetGraphicsContext($hImage)
	Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipGetImageGraphicsContext", "handle", $hImage, "handle*", 0)
	Return $aResult[2]
EndFunc

Func __GDIPlus_GraphicsSetSmoothingMode($hGraphics, $iSmooth)
	If $iSmooth < $GDIP_SMOOTHINGMODE_DEFAULT Or $iSmooth > $GDIP_SMOOTHINGMODE_ANTIALIAS8X8 Then $iSmooth = $GDIP_SMOOTHINGMODE_DEFAULT
	Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipSetSmoothingMode", "handle", $hGraphics, "int", $iSmooth)
	Return True
EndFunc

Func __GDIPlus_GraphicsSetInterpolationMode($hGraphics, $iInterpolationMode)
	Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipSetInterpolationMode", "handle", $hGraphics, "int", $iInterpolationMode)
	Return True
EndFunc

Func __GDIPlus_GraphicsSetCompositingMode($hGraphics, $iCompositionMode)
	Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipSetCompositingMode", "handle", $hGraphics, "int", $iCompositionMode)
	Return True
EndFunc

Func __GDIPlus_GraphicsSetCompositingQuality($hGraphics, $iCompositionQuality)
	Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipSetCompositingQuality", "handle", $hGraphics, "int", $iCompositionQuality)
	Return True
EndFunc

Func __GDIPlus_GraphicsSetPixelOffsetMode($hGraphics, $iPixelOffsetMode)
	Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipSetPixelOffsetMode", "handle", $hGraphics, "int", $iPixelOffsetMode)
	Return True
EndFunc

Func __GDIPlus_BitmapLockBits($hBitmap, $iLeft, $iTop, $iWidth, $iHeight)
	Local $tData = DllStructCreate($tagGDIPBITMAPDATA)
	Local $tRECT = DllStructCreate($tagRECT)
	DllStructSetData($tRECT, "Left", $iLeft)
	DllStructSetData($tRECT, "Top", $iTop)
	DllStructSetData($tRECT, "Right", $iWidth)
	DllStructSetData($tRECT, "Bottom", $iHeight)
	Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipBitmapLockBits", "handle", $hBitmap, "struct*", $tRECT, "uint", $GDIP_ILMREAD, "int", $GDIP_PXF32RGB, "struct*", $tData)
	Return $tData
EndFunc


Func __GDIPlus_ImageAttributesCreate()
	Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipCreateImageAttributes", "handle*", 0)
	Return $aResult[1]
EndFunc

Func __GDIPlus_GraphicsDrawImageRectRect($hGraphics, $hImage, $nSrcX, $nSrcY, $nSrcWidth, $nSrcHeight, $nDstX, $nDstY, $nDstWidth, $nDstHeight)
	Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipDrawImageRectRect", "handle", $hGraphics, "handle", $hImage, _
			"float", $nDstX, "float", $nDstY, "float", $nDstWidth, "float", $nDstHeight, _
			"float", $nSrcX, "float", $nSrcY, "float", $nSrcWidth, "float", $nSrcHeight, _
			"int", 2, "handle", 0, "ptr", 0, "ptr", 0)
	Return True
EndFunc

Func _GDIPlus_ColorGetLuminosity($iColor)
	Return(BitAND(BitShift($iColor, 16), 0xFF) * 0.299) _  ; R
			+ (BitAND(BitShift($iColor, 8), 0xFF) * 0.587) _  ; G
			+ (BitAND($iColor, 0xFF) * 0.114)  ; B
EndFunc

Func _GDIPlus_ImageAttributesSetGamma ( $hImageAttributes, $iColorAdjustType = 0, $fEnable = False, $nGamma = 0 )
	Local $aResult = DllCall ( $__g_hGDIPDll, 'uint', 'GdipSetImageAttributesGamma', 'hwnd', $hImageAttributes, 'int', $iColorAdjustType, 'int', $fEnable, 'float', $nGamma )
	Return $aResult[0] = 0
EndFunc