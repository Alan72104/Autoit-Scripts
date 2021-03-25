#NoTrayIcon

;~ http://www.autoitscript.com/autoit3/scite/docs/SciTE4AutoIt3/directives-available.html
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=C:\Ascii1.ico
#AutoIt3Wrapper_Outfile=Bitmap2AscII.exe
;~ #AutoIt3Wrapper_Version=Beta
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_Res_Comment=Convert Images to AscII Art.
#AutoIt3Wrapper_Res_Description=Bitmap2AscII
#AutoIt3Wrapper_Res_Fileversion=1.0.1.6
#AutoIt3Wrapper_Res_LegalCopyright=wakillon 2015
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#AutoIt3Wrapper_Res_Field=Created by|wakillon
#AutoIt3Wrapper_Res_Field=AutoIt Version|%AutoItVer%
#AutoIt3Wrapper_Res_Field=Compile date|%longdate% %time%
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6
#AutoIt3Wrapper_Run_After=del "%scriptfile%_stripped.au3"
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/so /pe /rm
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#Region  ;************ Includes ************
#Include <GUIConstantsEx.au3>
#include <GDIPlus.au3>
#include <Color.au3>
#EndRegion ;************ Includes ************

Opt('GUIOnEventMode', 1)
Opt('MustDeclareVars', 1)
Opt('GUICloseOnESC', 0)

#Region ------ Global Variables ------------------------------
Global $sVersion = _ScriptGetVersion()
Global $sSoftTitle = 'Bitmap2AscII v' & $sVersion & ' by wakillon'
Global $hGui, $idPic, $idLabelTitle, $idLabelDragTxt, $idButtonSave, $idLabelTxt, $idEditTxt, $idLabelRescale, $idSliderRescale, $idLabelMatrixFilter, $idRadioFilterNone, $idRadioFilterGray, $idRadioFilterBaW, $idLabelSaveType
Global $idLabelHue, $idSliderHue, $idLabelSaturation, $idSliderSaturation, $idButtonReset, $idButtonAbout, $idButtonOpen, $idButtonExit, $idLabelGamma, $idSliderGamma
Global $idSliderBrigthness, $idSliderContrast, $idComboCaractersCount, $idLabelContrast, $idLabelBrigthness, $aPosBak, $iAdlib, $iAbout
Global $idRadioTxt, $idRadioHtml, $idRadioImage
Global $aPicPos[4] = [20, 20, 400, 400]
Global $sTempDir = @TempDir & '\Bitmap2AscII'
Global $hImage, $sAscII = ''
Global $aCharacters[10] = [ '#', '@', '%', '*', '+', '=', '-', ':', '.', Chr(160) ] ; no-break space is used instead of space Chr(32).
Global $hGuiAbout, $hImageAb, $hGraphicAb, $hBitmapAb, $hBackBufferAb, $hBmpCtxtAb, $hBitmapAb2, $hFamilyAb, $hFontAb, $hCollectionAb, $hFormatAb, $hBrushAb, $tLayout, $hIAAb, $hEffectAb, $hUfmodDll, $xmfile

; uFMOD constants :

Global Const $XM_MEMORY         = 1
Global Const $XM_FILE           = 2
Global Const $XM_NOLOOP         = 8
Global Const $uFMOD_MIN_VOL     = 0
Global Const $uFMOD_MAX_VOL     = 25
Global Const $uFMOD_DEFAULT_VOL = 25
#EndRegion --- Global Variables ------------------------------

AutoItWinSetTitle('B1tmap2Asc11')
If _ScriptIsAlreadyRunning () Then Exit MsgBox(262144+16, 'Exiting', $sSoftTitle & ' is Already Running !', 4)
_GDIPlus_Startup()
_Gui()

#Region ------ Main Loop ------------------------------
While 1
	If $iAbout = 1 Then _GuiAbout()
	Sleep(250)
WEnd
#EndRegion --- Main Loop ------------------------------

Func _About()
	_GuiCtrlPicButton_SimulateAction($hGui, $idButtonAbout)
	$iAbout = 1
EndFunc ;==> _About()

Func _AboutExit()
	$iAbout = 0
EndFunc ;==> _AboutExit()

Func _ArrayAddEx(ByRef $avArray, $vValue)
	If Not IsArray($avArray) Then Return SetError(1, 0, -1)
	If UBound($avArray, 0) <> 1 Then Return SetError(2, 0, -1)
	Local $iUBound = UBound($avArray)
	ReDim $avArray[$iUBound + 1]
	$avArray[$iUBound] = $vValue
	Return $iUBound
EndFunc ;==> _ArrayAddEx()

Func _Base64Decode($input_string) ; by trancexx
	Local $struct = DllStructCreate('int')
	Local $a_Call = DllCall('Crypt32.dll', 'int', 'CryptStringToBinary', 'str', $input_string, 'int', 0, 'int', 1, 'ptr', 0, 'ptr', DllStructGetPtr($struct, 1), 'ptr', 0, 'ptr', 0)
	If @error Or Not $a_Call[0] Then Return SetError(1, 0, '')
	Local $a = DllStructCreate('byte[' & DllStructGetData($struct, 1) & ']')
	$a_Call = DllCall('Crypt32.dll', 'int', 'CryptStringToBinary', 'str', $input_string, 'int', 0, 'int', 1, 'ptr', DllStructGetPtr($a), 'ptr', DllStructGetPtr($struct, 1), 'ptr', 0, 'ptr', 0)
	If @error Or Not $a_Call[0] Then Return SetError(2, 0, '')
	Return DllStructGetData($a, 1)
EndFunc ;==> _Base64Decode()

Func _CharactersCountSet()
	Local $iCount = GUICtrlRead($idComboCaractersCount)
	$aCharacters = 0
	Switch $iCount
		Case 18
			Dim $aCharacters[18] = [ '#', '@', '&', '$', '%', '*', '!', '"', '+', '=', '_', '-', '~', ';', ':', ',', '.', Chr(160) ]
		Case 16
			Dim $aCharacters[16] = [ '#', '@', '&', '$', '%', '*', '+', '=', '_', '-', '~', ';', ':', ',', '.', Chr(160) ]
		Case 14
			Dim $aCharacters[14] = [ '#', '@', '&', '$', '%', '*', '+', '=', '-', '~', ';', ',', '.', Chr(160) ]
		Case 12
			Dim $aCharacters[12] = [ '#', '@', '&', '$', '%', '*', '+', '=', '-', ':', '.', Chr(160) ]
		Case 10
			Dim $aCharacters[10] = [ '#', '@', '%', '*', '+', '=', '-', ':', '.', Chr(160) ]
		Case 8
			Dim $aCharacters[8] = [ '#', 'B', 'V', 'i', '+', '=', ';', '.' ]
		Case 6
			Dim $aCharacters[6] = [ '#', 'B', 'i', '+', ';', '.' ]
		Case 4
			Dim $aCharacters[4] = [ '#', 'i', '+', '.' ]
		Case 2
			Dim $aCharacters[2] = [ '#', '.' ]
	EndSwitch
	_ImageSet()
EndFunc ;==> _CharactersCountSet()

Func _Exit()
	If @GUI_CtrlId = $idButtonExit Then
		_GuiCtrlPicButton_SimulateAction($hGui, $idButtonExit)
		Sleep(250)
	EndIf
	If $hImage <> 0 Then _GDIPlus_ImageDispose($hImage)
	_GDIPlus_Shutdown()
	GUIDelete($hGui)
	DirRemove($sTempDir, 1)
	If $hUfmodDll Then
		_uFMOD_StopSong()
		_uFMOD_Shutdown()
	EndIf
	Exit
EndFunc ;==> _Exit()

Func _FileGeneratePath($sExt)
	Local $sTempPath
	If Not FileExists($sTempDir) Then DirCreate($sTempDir)
	Do
		$sTempPath = $sTempDir & '\' & @YEAR & '-' & @MON & '-' & @MDAY & '-' & @HOUR & @MIN & @SEC & @MSEC & '.' & $sExt
	Until Not FileExists($sTempPath)
	Return $sTempPath
EndFunc ;==> _FileGeneratePath()

Func _FileGetFullNameByFullPath($sFullPath)
	Local $aFileName = StringSplit($sFullPath, '\')
	If Not @error Then Return $aFileName[$aFileName[0]]
EndFunc ;==> _FileGetFullNameByFullPath()

Func _FileSelect()
	_GuiCtrlPicButton_SimulateAction($hGui, $idButtonOpen)
	Local $sFileOpenDialog = FileOpenDialog('Select a Picture', @WorkingDir & '\', 'Image Files (*.bmp;*.gif;*.jpg;*.tiff)', 1, '', $hGui)
	If @error Then Return
	Local $aType = _PicGetType($sFileOpenDialog)
	If Not @error And $aType[1] <> '' Then
		Local $sThumb = _Pic2Thumb($sFileOpenDialog, 'jpg')
		_GuiCtrlSetPic($sThumb, $idPic, $aPicPos)
		ControlSetText($hGui, '', $idLabelTitle, _FileGetFullNameByFullPath($sFileOpenDialog))
		GUICtrlSetData($idLabelDragTxt, '')
		GUICtrlSetData($idLabelTxt, '')
		If $hImage <> 0 Then _GDIPlus_ImageDispose($hImage)
		$hImage = _GDIPlus_ImageLoadFromFile($sThumb)
		GUICtrlSetBkColor($idEditTxt, 0xFFFFFF)
		GUICtrlSetTip($idEditTxt, 'Click for open in Notepad')
		_GDIPlus_Image2AscII($hImage)
		Local $aDim = _SaveAsImage('', $sAscII, 1)
		If IsArray($aDim) Then ControlSetText($hGui, '', $idLabelRescale, 'Image Rescale : x1 [' & $aDim[0] & 'x' & $aDim[1] & ']')
		GUICtrlSetData($idSliderRescale, 1*100)
	Else
		MsgBox(262144+16, 'Error', 'Filetype not supported !', 5)
		Return
	EndIf
EndFunc ;==> _FileSelect()

Func _GammaLabelSetValue()
	Local $iGamma = GUICtrlRead($idSliderGamma)/50
	ControlSetText($hGui, '', $idLabelGamma, 'Gamma Level : ' & $iGamma)
	If $hImage <> 0 Then _GDIPlus_Image2AscII($hImage)
EndFunc ;==> _GammaLabelSetValue()

Func _GDIPlus_ColorGetLuminosity($iColor)
	Return(_ColorGetRed($iColor)* 0.299) +(_ColorGetGreen($iColor)* 0.587) +(_ColorGetBlue($iColor)* 0.114)
EndFunc ;==> _GDIPlus_ColorGetLuminosity()

Func _GDIPlus_ColorMatrixCreateBlackAndWhite()
	Local $aMatrix[25] = [ 1.5, 1.5, 1.5, 0, 0, 1.5, 1.5, 1.5, 0, 0, 1.5, 1.5, 1.5, 0, 0, 0, 0, 0, 1, 0, -1, -1, -1, 0, 1 ]
	Local $tBAWColorMatrix = _GDIPlus_ColorMatrixCreate()
	For $i = 0 To 24
		DllStructSetData($tBAWColorMatrix, 'm', $aMatrix[$i], $i+1)
	Next
	$aMatrix = 0
	Return $tBAWColorMatrix
EndFunc ;==> _GDIPlus_ColorMatrixCreateBlackAndWhite()

Func _GDIPlus_DeletePrivateFontCollection($hFontCollection)
	Local $aRet = DllCall($__g_hGDIPDll, 'uint', 'GdipDeletePrivateFontCollection', 'hwnd*', $hFontCollection)
	If @error Then Return SetError(@error, @extended, False)
	Return $aRet[0] = 0
EndFunc ;==> _GDIPlus_DeletePrivateFontCollection()

Func _GDIPlus_Image2AscII($hImage)
	Local $iWidth = _GDIPlus_ImageGetWidth($hImage)
	Local $iHeight = _GDIPlus_ImageGetHeight($hImage)
	Local $iWidthAdapted, $iHeightAdapted, $iCoeff = 1.62
	If $iHeight >= $iWidth Then
		$iWidthAdapted = Int(( 80 *($iWidth/$iHeight))*$iCoeff)
		$iHeightAdapted = 80
	Else
		$iWidthAdapted = 130
		$iHeightAdapted = Int(( 130 *($iHeight/$iWidth))/$iCoeff)
	EndIf
	Local $hBitmap_Scaled = _GDIPlus_ImageResize($hImage, $iWidthAdapted, $iHeightAdapted) ; resize and enlarge image.
	Local $hBitmap = _GDIPlus_BitmapCreateFromScan0($iWidthAdapted, $iHeightAdapted)
	Local $hContext = _GDIPlus_ImageGetGraphicsContext($hBitmap)
	_GDIPlus_GraphicsSetSmoothingMode($hContext, $GDIP_SMOOTHINGMODE_ANTIALIAS8X8)
	_GDIPlus_GraphicsSetCompositingMode($hContext, $GDIP_COMPOSITINGMODESOURCEOVER)
	_GDIPlus_GraphicsSetCompositingQuality($hContext, $GDIP_COMPOSITINGQUALITYASSUMELINEAR)
	_GDIPlus_GraphicsSetInterpolationMode($hContext, $GDIP_INTERPOLATIONMODE_NEARESTNEIGHBOR)
	_GDIPlus_GraphicsSetPixelOffsetMode($hContext, $GDIP_PIXELOFFSETMODE_HIGHQUALITY)
	Local $hEffect1 = _GDIPlus_EffectCreateBrightnessContrast(GUICtrlRead($idSliderBrigthness), GUICtrlRead($idSliderContrast))
	_GDIPlus_BitmapApplyEffect($hBitmap_Scaled, $hEffect1)
	Local $hEffect2 = _GDIPlus_EffectCreateHueSaturationLightness(GUICtrlRead($idSliderHue), GUICtrlRead($idSliderSaturation), 0)
	_GDIPlus_BitmapApplyEffect($hBitmap_Scaled, $hEffect2)
	Local $hIA = _GDIPlus_ImageAttributesCreate()
	Local $tColorMatrix
	Select
		Case _IsChecked($idRadioFilterGray)
			$tColorMatrix = _GDIPlus_ColorMatrixCreateGrayScale()
			_GDIPlus_ImageAttributesSetColorMatrix($hIA, 0, True, $tColorMatrix)
		Case _IsChecked($idRadioFilterBaW)
			$tColorMatrix = _GDIPlus_ColorMatrixCreateBlackAndWhite()
			_GDIPlus_ImageAttributesSetColorMatrix($hIA, 0, True, $tColorMatrix)
	EndSelect
	Local $iGamma = GUICtrlRead($idSliderGamma)/50
	If $iGamma Then _GDIPlus_ImageAttributesSetGamma($hIA, 0, True, $iGamma) ; values from 0 to 2

	_GDIPlus_GraphicsDrawImageRectRect($hContext, $hBitmap_Scaled, 0, 0, $iWidthAdapted, $iHeightAdapted, 0, 0, $iWidthAdapted, $iHeightAdapted, $hIA)
	Local $tBitmapData = _GDIPlus_BitmapLockBits($hBitmap, 0, 0, $iWidthAdapted, $iHeightAdapted, $GDIP_ILMREAD, $GDIP_PXF32RGB)
	Local $iScan0 = DllStructGetData($tBitmapData, 'Scan0')
	Local $tPixel = DllStructCreate('int[' & $iWidthAdapted * $iHeightAdapted & '];', $iScan0)
	Local $iColor
	Local $aChars[$iWidthAdapted +1][ $iHeightAdapted +1]
	Local $sString = '', $iRowOffset
	For $iY = 0 To $iHeightAdapted - 1
		$iRowOffset = $iY * $iWidthAdapted + 1
		For $iX = 0 To $iWidthAdapted - 1
			$iColor = DllStructGetData($tPixel, 1, $iRowOffset + $iX)
			$aChars[$iX][$iY] = $aCharacters[ Int(_GDIPlus_ColorGetLuminosity($iColor)/( 255/UBound($aCharacters) + 0.1)) ]
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
	ControlSetText($hGui, '', $idEditTxt, $sString)
	GUICtrlSetState($idEditTxt, $GUI_SHOW)
	$tPixel = 0
	$tBitmapData = 0
	$sAscII = $sString
EndFunc ;==> _GDIPlus_Image2AscII()

Func _GDIPlus_ImageAttributesSetGamma($hImageAttributes, $iColorAdjustType = 0, $fEnable = False, $nGamma = 0)
	Local $aResult = DllCall($__g_hGDIPDll, 'uint', 'GdipSetImageAttributesGamma', 'hwnd', $hImageAttributes, 'int', $iColorAdjustType, 'int', $fEnable, 'float', $nGamma)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0] = 0
EndFunc ;==> _GDIPlus_ImageAttributesSetGamma()

Func _GDIPlus_NewPrivateFontCollection()
	Local $aRet = DllCall($__g_hGDIPDll, 'uint', 'GdipNewPrivateFontCollection', 'int*', 0)
	If @error Then Return SetError(@error, @extended, False)
	Return $aRet[1]
EndFunc ;==> _GDIPlus_NewPrivateFontCollection()

Func _GDIPlus_PrivateCollectionAddMemoryFont($hCollection, $pMemory, $iLength)
	Local $aRet = DllCall($__g_hGDIPDll, 'uint', 'GdipPrivateAddMemoryFont', 'hwnd', $hCollection, 'ptr', $pMemory, 'int', $iLength)
	If @error Then Return SetError(@error, @extended, False)
	Return $aRet[0] = 0
EndFunc ;==> _GDIPlus_PrivateCollectionAddMemoryFont()

Func _Gui()
	Local $BkColor = 0x444444
	$hGui = GUICreate($sSoftTitle, 870, 700, -1, -1, -1, 0x00000010) ; $WS_EX_ACCEPTFILES
	GUISetBkColor($BkColor)
	GUISetOnEvent(-3, '_Exit') ; $GUI_EVENT_CLOSE
	GUISetOnEvent($GUI_EVENT_PRIMARYDOWN, '_TextOpenInNotepad')
	GUISetOnEvent(-13, '_GuiGetDroppedItem')
	Ascii1Ico('Ascii1.ico', 'C:')
	GUISetIcon('C:\Ascii1.ico')
	GUICtrlCreateLabel('', 13, 13, 414, 414, 0x00040000) ; $WS_THICKFRAME
	GUICtrlSetState(-1, $GUI_DISABLE)
	$idLabelDragTxt = GUICtrlCreateLabel("Drag'n drop" & @CRLF & @CRLF & 'a picture here !', 20, 140, 400, 100, 0x1) ; $SS_CENTER
	GUICtrlSetFont (-1, 20, 800)
	GUICtrlSetColor(-1, 0xFFFFFF)
	$idPic = GUICtrlCreatePic('', 20, 20, 400, 400)
	GUICtrlSetState(-1, 8) ; $GUI_DROPACCEPTED
	GUICtrlCreateLabel('', 430+13, 13, 414, 414, 0x00040000) ; $WS_THICKFRAME
	GUICtrlSetState(-1, $GUI_DISABLE)
	$idEditTxt = GUICtrlCreateEdit('', 450, 20, 400, 400, BitOR(0x1000, 0x0800)) ; $ES_WANTRETURN $ES_READONLY
	GUICtrlSetFont(-1, 4, 400, 0, 'Lucida Console', 5)
	GUICtrlSetCursor(-1, 0)
	GUICtrlSetOnEvent(-1, '_TextOpenInNotepad')
	GUICtrlSetBkColor(-1, $BkColor)
	$idLabelBrigthness = GUICtrlCreateLabel('Brigthness Level : 0', 20, 440, 170, 20)
	GUICtrlSetFont(-1, 10, 700, 1)
	GUICtrlSetColor(-1, 0xFFFFFF)
	$idSliderBrigthness = GUICtrlCreateSlider(20, 460, 400, 20, BitOR(0x0004, 0x0010)) ; $TBS_TOP $TBS_NOTICKS
	GUICtrlSetLimit(-1, 255, -255)
	GUICtrlSetData(-1, 0)
	GUICtrlSetOnEvent(-1, '_ImageSet')
	GUICtrlSetBkColor(-1, $BkColor)
	$idLabelContrast = GUICtrlCreateLabel('Contrast Level : 0', 20, 490, 170, 20)
	GUICtrlSetFont(-1, 10, 700, 1)
	GUICtrlSetColor(-1, 0xFFFFFF)
	$idSliderContrast = GUICtrlCreateSlider(20, 510, 400, 20, BitOR(0x0004, 0x0010)) ; $TBS_TOP $TBS_NOTICKS
	GUICtrlSetLimit(-1, 100, -100)
	GUICtrlSetData(-1, 0)
	GUICtrlSetOnEvent(-1, '_ImageSet')
	GUICtrlSetBkColor(-1, $BkColor)
	$idLabelHue = GUICtrlCreateLabel('Hue Level : 0', 20, 540, 170, 20)
	GUICtrlSetFont(-1, 10, 700, 1)
	GUICtrlSetColor(-1, 0xFFFFFF)
	$idSliderHue = GUICtrlCreateSlider(20, 560, 400, 20, BitOR(0x0004, 0x0010)) ; $TBS_TOP $TBS_NOTICKS
	GUICtrlSetLimit(-1, 180, -180)
	GUICtrlSetData(-1, 0)
	GUICtrlSetOnEvent(-1, '_ImageSet')
	GUICtrlSetBkColor(-1, $BkColor)
	$idLabelSaturation = GUICtrlCreateLabel('Saturation Level : 0', 20, 590, 170, 20)
	GUICtrlSetFont(-1, 10, 700, 1)
	GUICtrlSetColor(-1, 0xFFFFFF)
	$idSliderSaturation = GUICtrlCreateSlider(20, 610, 400, 20, BitOR(0x0004, 0x0010)) ; $TBS_TOP $TBS_NOTICKS
	GUICtrlSetLimit(-1, 100, -100)
	GUICtrlSetData(-1, 0)
	GUICtrlSetOnEvent(-1, '_ImageSet')
	GUICtrlSetBkColor(-1, $BkColor)
	$idLabelGamma = GUICtrlCreateLabel('Gamma Level : 0', 20, 640, 300, 20)
	GUICtrlSetFont(-1, 10, 700, 1)
	GUICtrlSetColor(-1, 0xFFFFFF)
	$idSliderGamma = GUICtrlCreateSlider(20, 660, 400, 20, BitOR(0x0004, 0x0010)) ; $TBS_TOP $TBS_NOTICKS
	GUICtrlSetLimit(-1, 100, 0)
	GUICtrlSetData(-1, 0)
	GUICtrlSetOnEvent(-1, '_GammaLabelSetValue')
	GUICtrlSetBkColor(-1, $BkColor)
	$idLabelTitle = GUICtrlCreateLabel('', 440, 440, 400, 20, 0x01)
	GUICtrlSetFont(-1, 10, 700, 1)
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlCreateLabel('Characters Count', 440, 490, 120, 20)
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetFont(-1, 10, 700, 1)
	$idComboCaractersCount = GUICtrlCreateCombo('', 440, 510, 110, 15, 0x3, 0x1000) ; $CBS_DROPDOWNLIST $WS_EX_RIGHT
	GUICtrlSetData(-1, '18|16|14|12|10|08|06|04|02', '10') ; default 10
	GUICtrlSetOnEvent(-1, '_CharactersCountSet')
	GUICtrlSetFont(-1, 10, 700, 1)
	$idLabelMatrixFilter = GUICtrlCreateLabel('Matrix Filter', 440, 540, 170, 20)
	GUICtrlSetFont(-1, 10, 700, 1)
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUIStartGroup()
	$idRadioFilterNone = GUICtrlCreateRadio(' None', 440, 560, 55, 20)
	GUICtrlSetState(-1, $GUI_CHECKED)
	GUICtrlSetFont(-1, 10, 700, 1)
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetOnEvent(-1, '_ImageSet')
	DllCall('UxTheme.dll', 'int', 'SetWindowTheme', 'hwnd', GUICtrlGetHandle($idRadioFilterNone), 'wstr', 0, 'wstr', 0)
	$idRadioFilterGray = GUICtrlCreateRadio(' GrayScale', 510, 560, 90, 20)
	GUICtrlSetFont(-1, 10, 700, 1)
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetOnEvent(-1, '_ImageSet')
	DllCall('UxTheme.dll', 'int', 'SetWindowTheme', 'hwnd', GUICtrlGetHandle($idRadioFilterGray), 'wstr', 0, 'wstr', 0)
	$idRadioFilterBaW = GUICtrlCreateRadio(' Black&&White', 610, 560, 105, 20)
	GUICtrlSetFont(-1, 10, 700, 1)
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetOnEvent(-1, '_ImageSet')
	DllCall('UxTheme.dll', 'int', 'SetWindowTheme', 'hwnd', GUICtrlGetHandle($idRadioFilterBaW), 'wstr', 0, 'wstr', 0)
	GUIStartGroup()
	$idLabelSaveType = GUICtrlCreateLabel('Save Type', 440, 590, 300, 20)
	GUICtrlSetFont(-1, 10, 700, 1)
	GUICtrlSetColor(-1, 0xFFFFFF)
	$idRadioTxt = GUICtrlCreateRadio(' Text', 440, 610, 60, 20)
	GUICtrlSetState(-1, $GUI_CHECKED)
	GUICtrlSetFont(-1, 10, 700, 1)
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetOnEvent(-1, '_RescaleCtrlsSetState')
	DllCall('UxTheme.dll', 'int', 'SetWindowTheme', 'hwnd', GUICtrlGetHandle($idRadioTxt), 'wstr', 0, 'wstr', 0)
	$idRadioHtml = GUICtrlCreateRadio(' Html', 510, 610, 60, 20)
	GUICtrlSetFont(-1, 10, 700, 1)
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetOnEvent(-1, '_RescaleCtrlsSetState')
	DllCall('UxTheme.dll', 'int', 'SetWindowTheme', 'hwnd', GUICtrlGetHandle($idRadioHtml), 'wstr', 0, 'wstr', 0)
	$idRadioImage = GUICtrlCreateRadio(' Image', 580, 610, 70, 20)
	GUICtrlSetFont(-1, 10, 700, 1)
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetOnEvent(-1, '_RescaleCtrlsSetState')
	DllCall('UxTheme.dll', 'int', 'SetWindowTheme', 'hwnd', GUICtrlGetHandle($idRadioImage), 'wstr', 0, 'wstr', 0)
	$idLabelRescale = GUICtrlCreateLabel('Image Rescale : x1', 440, 640, 300, 20)
	GUICtrlSetFont(-1, 10, 700, 1)
	GUICtrlSetColor(-1, 0xFFFFFF)
	$idSliderRescale = GUICtrlCreateSlider(440, 660, 300, 20, BitOR(0x0004, 0x0010)) ; $TBS_TOP $TBS_NOTICKS
	GUICtrlSetLimit(-1, 2.1*100, 0.1*100)
	GUICtrlSetData(-1, 1*100)
	GUICtrlSetOnEvent(-1, '_RescaleLabelSetValue')
	GUICtrlSetBkColor(-1, $BkColor)
	Buttonopengif('ButtonOpen.gif', $sTempDir, 1)
	$idButtonOpen = GUICtrlCreatePic($sTempDir & '\ButtonOpen.gif', 750, 500, 104, 22)
	GUICtrlSetOnEvent(-1, '_FileSelect')
	ButtonResetGif('ButtonReset.gif', $sTempDir, 1)
	$idButtonReset = GUICtrlCreatePic($sTempDir & '\ButtonReset.gif', 750, 540, 104, 22)
	GUICtrlSetOnEvent(-1, '_Reset')
	ButtonAboutGif('ButtonAbout.gif', $sTempDir, 1)
	$idButtonAbout = GUICtrlCreatePic($sTempDir & '\ButtonAbout.gif', 750, 580, 104, 22)
	GUICtrlSetOnEvent(-1, '_About')
	ButtonSaveAsgif('ButtonSaveAs.gif', $sTempDir, 1)
	$idButtonSave = GUICtrlCreatePic($sTempDir & '\ButtonSaveAs.gif', 750, 620, 104, 22)
	GUICtrlSetOnEvent(-1, '_SaveAs')
	Buttonexitgif('ButtonExit.gif', $sTempDir, 1)
	$idButtonExit = GUICtrlCreatePic($sTempDir & '\ButtonExit.gif', 750, 660, 104, 22)
	GUICtrlSetOnEvent(-1, '_Exit')
	_RescaleCtrlsSetState()
	GUISetState(@SW_SHOW)
EndFunc ;==> _Gui()

Func _GuiAbout()
	$hUfmodDll = _uFMOD_Startup()
	$xmfile = Smurfesquexm() ; 'Smurf-Esque.xm'
	_uFMOD_PlaySong($xmfile, 1)
	Local $sText = 'Bitmap2AscII by wakillon   easily convert your picture to a AscII art text, html or image   Thanks To the Autoit Community   Hope you like it !'
	; Load Background Image to memory.
	$hImageAb = _GDIPlus_BitmapCreateFromMemory(AvatarsMixJpg())
	Local $iWidth = _GDIPlus_ImageGetWidth($hImageAb)
	Local $iHeight = _GDIPlus_ImageGetHeight($hImageAb)
	$hEffectAb = _GDIPlus_EffectCreateBlur(6, True)
	$hImageAb = _GDIPlus_BitmapCreateApplyEffectEx($hImageAb, $hEffectAb) ; Background image is a bit blurred.
	; Create Gui.
	$hGuiAbout = GUICreate('About', $iWidth, $iHeight, -1, -1, 0x80000000, 0x00000008, $hGui) ; $WS_POPUP $WS_EX_TOPMOST
	GUISetBkColor(0x000000)
	GUISetOnEvent(-7, '_AboutExit') ; $GUI_EVENT_PRIMARYDOWN
	GUISetOnEvent(-3, '_AboutExit')
	$hGraphicAb = _GDIPlus_GraphicsCreateFromHWND($hGuiAbout)
	$hBitmapAb = _GDIPlus_BitmapCreateFromGraphics($iWidth, $iHeight, $hGraphicAb)
	$hBackBufferAb = _GDIPlus_ImageGetGraphicsContext($hBitmapAb)
	; Load Font to memory.
	$hCollectionAb = _GDIPlus_NewPrivateFontCollection()
	Local $bFont = HeadlineOneTtfFont()
	Local $tFont = DllStructCreate('byte[' & BinaryLen($bFont) & ']')
	DllStructSetData($tFont, 1, $bFont)
	_GDIPlus_PrivateCollectionAddMemoryFont($hCollectionAb, DllStructGetPtr($tFont), DllStructGetSize($tFont))
	$tFont = 0
	$bFont = 0
	$hFamilyAb = _GDIPlus_FontFamilyCreate('Headline one', $hCollectionAb) ; "Headline one" font display only uppercase characters.(http://www.dafont.com/fr/headline-hplhs.font)
	Local $iFontSize = 277 ; adjust font size
	Local $iStringWidth
	$hFontAb = _GDIPlus_FontCreate($hFamilyAb, $iFontSize, 1)
	$hFormatAb = _GDIPlus_StringFormatCreate()
	Local $iFontHeight = _GDIPlus_FontGetHeight($hFontAb, $hGraphicAb)
	; Get "spaces" string Width, who will be placed before and after the Text.
	$tLayout = _GDIPlus_RectFCreate(0,($iHeight -$iFontHeight)/2 +10, $iStringWidth, $iFontHeight)
	Local $sSpace = Chr(1) ; chr(32) can not be used cause _GDIPlus_GraphicsDrawStringEx trim them on the right.
	Local $aInfo = _GDIPlus_GraphicsMeasureString($hGraphicAb, $sSpace, $hFontAb, $tLayout, $hFormatAb)
	Local $iSpaceWidth = DllStructGetData($aInfo[0], 'Width')
	Local $j = 1, $iSpeed = 15, $iPos
	Do
		$sSpace &= Chr(1)
		$j+=1
	Until $j*$iSpaceWidth >= $iWidth
	$sText = $sSpace & $sText & $sSpace
	; Get the total Text string width.
	$aInfo = _GDIPlus_GraphicsMeasureString($hGraphicAb, $sText, $hFontAb, $tLayout, $hFormatAb)
	$iStringWidth = DllStructGetData($aInfo[0], 'Width')
	$tLayout = _GDIPlus_RectFCreate(0,($iHeight -$iFontHeight)/2 +10, $iStringWidth, $iFontHeight)
	; Create transparent text on black background.
	$hBrushAb = _GDIPlus_HatchBrushCreate(17, 0xFFFFFFFF, 0x00000000)
	$hBitmapAb2 = _GDIPlus_BitmapCreateFromScan0($iStringWidth, $iFontHeight)
	$hBmpCtxtAb = _GDIPlus_ImageGetGraphicsContext($hBitmapAb2)
	_GDIPlus_GraphicsClear($hBmpCtxtAb, 0xFF000000) ; clear bitmap with black color.
	_GDIPlus_GraphicsSetSmoothingMode($hBmpCtxtAb, 2)
	_GDIPlus_GraphicsSetCompositingQuality($hBmpCtxtAb, 2)
	_GDIPlus_GraphicsSetInterpolationMode($hBmpCtxtAb, 7)
	_GDIPlus_GraphicsSetTextRenderingHint($hBmpCtxtAb, 5)
	_GDIPlus_GraphicsDrawStringEx($hBmpCtxtAb, $sText, $hFontAb, $tLayout, $hFormatAb, $hBrushAb)
	$hIAAb = _GDIPlus_ImageAttributesCreate()
	_GDIPlus_ImageAttributesSetColorKeys($hIAAb, 0, True, 0xFFFFFFFF, 0xFFFFFFFF) ; replace white color by transparent color.
	GUISetState(@SW_SHOW , $hGuiAbout)
	GUISetState(@SW_HIDE , $hGui)
	While 1
		_GDIPlus_GraphicsDrawImageRect($hBackBufferAb, $hImageAb, 0, 0, $iWidth, $iHeight)
		_GDIPlus_GraphicsDrawImageRectRect($hBackBufferAb, $hBitmapAb2, $iPos, 0, $iWidth, $iHeight, 0, 0, $iWidth, $iHeight, $hIAAb)
		_GDIPlus_GraphicsDrawImageRect($hGraphicAb, $hBitmapAb, 0, 0, $iWidth, $iHeight)
		$iPos += $iSpeed
		If $iPos > $iStringWidth - $iWidth Then $iPos = 0
		Sleep(10)
		If Not $iAbout Then ExitLoop
	Wend
	_GDIPlus_ImageAttributesDispose($hIAAb)
	_GDIPlus_BrushDispose($hBrushAb)
	_GDIPlus_StringFormatDispose($hFormatAb)
	_GDIPlus_FontDispose($hFontAb)
	_GDIPlus_FontFamilyDispose($hFamilyAb)
	_GDIPlus_DeletePrivateFontCollection($hCollectionAb)
	_GDIPlus_GraphicsDispose($hBackBufferAb)
	_GDIPlus_BitmapDispose($hBitmapAb2)
	_GDIPlus_GraphicsDispose($hBmpCtxtAb)
	_GDIPlus_BitmapDispose($hBitmapAb)
	_GDIPlus_GraphicsDispose($hGraphicAb)
	_GDIPlus_EffectDispose($hEffectAb)
	_GDIPlus_ImageDispose($hImageAb)
	GUIDelete($hGuiAbout)
	GUISetState(@SW_SHOW , $hGui)
	_uFMOD_FadeOut()
	_uFMOD_StopSong()
	_uFMOD_Shutdown()
EndFunc ;==> _GuiAbout()

Func _GuiCtrlPicButton_RestorePos()
	If Not _IsPressedEx('01') Then ; wait left mouse button is not pressed.
		If IsArray($aPosBak) Then
			GUICtrlSetPos($aPosBak[4], $aPosBak[0], $aPosBak[1], $aPosBak[2], $aPosBak[3])
			$aPosBak = 0
		EndIf
		$iAdlib = 0
		AdlibUnRegister('_GuiCtrlPicButton_RestorePos')
	EndIf
EndFunc ;==> _GuiCtrlPicButton_RestorePos()

Func _GuiCtrlPicButton_SimulateAction($hWnd, $iCtrlId, $iFlag=1)
	If $iAdlib = 1 Then Return
	Local $aPos = ControlGetPos($hWnd, '', $iCtrlId)
	If Not @error Then
		GUICtrlSetPos($iCtrlId, $aPos[0]+$iFlag, $aPos[1]+$iFlag, $aPos[2]-2*$iFlag, $aPos[3]-2*$iFlag)
		$aPosBak = $aPos
		_ArrayAddEx($aPosBak, $iCtrlId)
		AdlibRegister('_GuiCtrlPicButton_RestorePos', 150)
		$iAdlib = 1
	EndIf
	$aPos = 0
EndFunc ;==> _GuiCtrlPicButton_SimulateAction()

Func _GuiCtrlSetPic($sPicPath, $IdCtrl, $aPos)
	If Not FileExists($sPicPath) Then Return SetError(1, 0, 0)
	If FileGetSize($sPicPath) = 0 Then Return SetError(2, 0, 0)
	GUICtrlSetState($IdCtrl, $GUI_HIDE)
	GUICtrlSetState($idEditTxt, $GUI_HIDE)
	Local $aPicSize = _PicGetDimension($sPicPath)
	If @error Then Return SetError(3, 0, 0)
	GUICtrlSetData($IdCtrl, '')
	Local $iLeft, $iTop, $iWidth, $iHeight, $iRatio
	If $aPicSize[0] > $aPicSize[1] Then
		$iRatio = $aPicSize[1]/ $aPicSize[0]
		$iLeft = $aPos[0]
		$iTop = $aPos[1]+($aPos[3] - $aPos[3]*$iRatio)/2
		$iWidth = $aPos[2]
		$iHeight = $aPos[3]*$iRatio
	ElseIf $aPicSize[0] < $aPicSize[1] Then
		$iRatio = $aPicSize[0]/ $aPicSize[1]
		$iLeft = $aPos[0]+($aPos[2] - $aPos[2]*$iRatio)/2
		$iTop = $aPos[1]
		$iWidth = $aPos[2]*$iRatio
		$iHeight = $aPos[3]
	Else
		$iLeft = $aPos[0]
		$iTop = $aPos[1]
		$iWidth = $aPos[2]
		$iHeight = $aPos[3]
	EndIf
	GUICtrlSetPos($IdCtrl, $iLeft, $iTop, $iWidth, $iHeight)
	; Set Edit Control Position.
	GUICtrlSetPos($idEditTxt, $iLeft+430, $iTop, $iWidth, $iHeight)
	GUICtrlSetImage($IdCtrl, $sPicPath)
	GUICtrlSetState($IdCtrl, $GUI_SHOW)
EndFunc ;==> _GuiCtrlSetPic()

Func _GuiGetDroppedItem()
	Local $aType = _PicGetType(@GUI_DRAGFILE)
	If Not @error And $aType[1] <> '' Then
		Local $sThumb = _Pic2Thumb(@GUI_DRAGFILE, 'jpg')
		_GuiCtrlSetPic($sThumb, $idPic, $aPicPos)
		ControlSetText($hGui, '', $idLabelTitle, _FileGetFullNameByFullPath(@GUI_DRAGFILE))
		GUICtrlSetData($idLabelDragTxt, '')
		GUICtrlSetData($idLabelTxt, '')
		If $hImage <> 0 Then _GDIPlus_ImageDispose($hImage)
		$hImage = _GDIPlus_ImageLoadFromFile($sThumb)
		GUICtrlSetBkColor($idEditTxt, 0xFFFFFF)
		GUICtrlSetTip($idEditTxt, 'Click for open in Notepad')
		_GDIPlus_Image2AscII($hImage)
		Local $aDim = _SaveAsImage('', $sAscII, 1)
		If IsArray($aDim) Then ControlSetText($hGui, '', $idLabelRescale, 'Image Rescale : x1 [' & $aDim[0] & 'x' & $aDim[1] & ']')
		GUICtrlSetData($idSliderRescale, 1*100)
	Else
		MsgBox(262144+16, 'Error', 'Filetype not supported !', 5)
		Return
	EndIf
EndFunc ;==> _GuiGetDroppedItem()

Func _ImageSet()
	ControlSetText($hGui, '', $idLabelBrigthness, 'Brigthness Level : ' & GUICtrlRead($idSliderBrigthness))
	ControlSetText($hGui, '', $idLabelContrast, 'Contrast Level : ' & GUICtrlRead($idSliderContrast))
	ControlSetText($hGui, '', $idLabelHue, 'Hue Level : ' & GUICtrlRead($idSliderHue))
	ControlSetText($hGui, '', $idLabelSaturation, 'Saturation Level : ' & GUICtrlRead($idSliderSaturation))
	If $hImage <> 0 Then _GDIPlus_Image2AscII($hImage)
EndFunc ;==> _ImageSet()

Func _IsChecked($idCtrl)
	Return BitAND(GUICtrlRead($idCtrl), $GUI_CHECKED) = $GUI_CHECKED
EndFunc ;==> _IsChecked ()

Func _IsPressedEx($sHexKey)
	Local $aRet = DllCall('user32.dll', 'short', 'GetAsyncKeyState', 'int', '0x' & $sHexKey)
	If @error Then Return SetError(@error, @extended, False)
	Return BitAND($aRet[0], 0x8000) <> 0
EndFunc ;==> _IsPressedEx()

Func _LzntDecompress($bBinary); by trancexx
	$bBinary = Binary($bBinary)
	Local $tInput = DllStructCreate('byte[' & BinaryLen($bBinary) & ']')
	DllStructSetData($tInput, 1, $bBinary)
	Local $tBuffer = DllStructCreate('byte[' & 16*DllStructGetSize($tInput) & ']')
	Local $a_Call = DllCall('ntdll.dll', 'int', 'RtlDecompressBuffer', 'ushort', 2, 'ptr', DllStructGetPtr($tBuffer), 'dword', DllStructGetSize($tBuffer), 'ptr', DllStructGetPtr($tInput), 'dword', DllStructGetSize($tInput), 'dword*', 0)
	If @error Or $a_Call[0] Then Return SetError(1, 0, '')
	Local $tOutput = DllStructCreate('byte[' & $a_Call[6] & ']', DllStructGetPtr($tBuffer))
	Return SetError(0, 0, DllStructGetData($tOutput, 1))
EndFunc ;==> _LzntDecompress()

Func _Min($nNum1, $nNum2)
	If(Not IsNumber($nNum1)) Then Return SetError(1, 0, 0)
	If(Not IsNumber($nNum2)) Then Return SetError(2, 0, 0)
	If $nNum1 > $nNum2 Then
		Return $nNum2
	Else
		Return $nNum1
	EndIf
EndFunc ;==> _Min()

Func _Pic2Thumb($sPicPath, $sType = 'jpg')
	If Not FileExists($sPicPath) Then Return SetError(1, 0, 0)
	If Not FileGetSize($sPicPath) Then Return SetError(2, 0, 0)
	Local $sTmpFile = _FileGeneratePath($sType)
	Local $aDim = _PicGetDimension($sPicPath)
	Local $Ratio = $aDim[0]/$aDim[1]
	Local $iWidth = $aDim[0], $iHeight = $aDim[1]
;~  ReSize to Pic Control Size.
	If $iWidth >= $iHeight Then
		$iWidth = _Min(400, $aDim[0])
		If $iWidth <> $aDim[0] Then $iHeight = $iWidth / $Ratio
	Else
		$iHeight = _Min(400, $aDim[1])
		If $iHeight <> $aDim[1] Then $iWidth = $iHeight * $Ratio
	EndIf
	Local $hImage2 = _GDIPlus_ImageLoadFromFile($sPicPath)
	Local $hBitmap = _WinAPI_CreateBitmap($iWidth, $iHeight, 1, 32)
	Local $hImage1 = _GDIPlus_BitmapCreateFromHBITMAP($hBitmap)
	Local $hGraphic = _GDIPlus_ImageGetGraphicsContext($hImage1)
	_GDIPlus_GraphicsDrawImageRect($hGraphic, $hImage2, 0, 0, $iWidth, $iHeight)
	Local $CLSID = _GDIPlus_EncodersGetCLSID($sType)
	_GDIPlus_ImageSaveToFileEx($hImage1, $sTmpFile, $CLSID)
	_GDIPlus_ImageDispose($hImage1)
	_GDIPlus_ImageDispose($hImage2)
	_GDIPlus_GraphicsDispose($hGraphic)
	_WinAPI_DeleteObject($hBitmap)
	Return SetError(Not FileGetSize($sTmpFile), 0, $sTmpFile)
EndFunc ;==> _Pic2Thumb()

Func _PicGetDimension($sPicPath)
	If Not FileExists($sPicPath) Then Return SetError(-1)
	Local $hImage = _GDIPlus_ImageLoadFromFile($sPicPath)
	Local $aRet[2]
	$aRet[0] = _GDIPlus_ImageGetWidth($hImage)
	$aRet[1] = _GDIPlus_ImageGetHeight($hImage)
	_GDIPlus_ImageDispose($hImage)
	If $aRet[0] And $aRet[1] Then Return $aRet
	Return SetError(1, 0, 0)
EndFunc ;==> _PicGetDimension()

Func _PicGetType($sFilePath)
	If Not FileExists($sFilePath) Then Return SetError(-1, 0, '')
	If FileGetSize($sFilePath) = 0 Then Return SetError(2, 0, '')
	Local $hFile, $Binary
	$hFile = FileOpen($sFilePath, 16)
	If $hFile = -1 Then Return SetError(3, 0, '')
	$Binary = FileRead($hFile)
	FileClose($hFile)
	Local $sString = StringTrimLeft($Binary, 2)
	Local $sStringLeft = StringReplace(StringTrimLeft(StringLeft($Binary, 14), 2), '00', '') ; get 7 bit header part.
	Local $sStringLeft12 = StringLeft($sStringLeft, 12)
	Local $sStringLeft8 = StringLeft($sStringLeft, 8)
	Local $sStringLeft6 = StringLeft($sStringLeft, 6)
	Local $sStringLeft4 = StringLeft($sStringLeft, 4)
	Local $aOut[2]
	Select
		Case $sStringLeft12 = '474946383961' ; GIF 89A Bitmap      GIF Graphics interchange format file
			$aOut[0] = 'GIF 89A Bitmap'
			$aOut[1] = 'GIF'
		Case $sStringLeft12 = '474946383761' ; GIF 87A Bitmap      GIF Graphics interchange format file
			$aOut[0] = 'GIF 87A Bitmap'
			$aOut[1] = 'GIF'
		Case $sStringLeft8 = 'FFD8FFE0'   ; JFIF, JPE, JPEG, JPG   JPEG/JFIF graphics file
			$aOut[0] = 'JPEG/JFIF graphics file'
			$aOut[1] = 'JPG'
		Case $sStringLeft8 = 'FFD8FFE1'   ; JPG            Standard JPEG/Exif
			$aOut[0] = 'Standard JPEG/Exif'
			$aOut[1] = 'JPG'
		Case $sStringLeft8 = 'FFD8FFE2'   ; JPG            Canon EOS 1D JPEG file
			$aOut[0] = 'Canon EOS 1D JPEG file'
			$aOut[1] = 'JPG'
		Case $sStringLeft8 = 'FFD8FFE3'   ; JPG            Samsung D500 JPEG file
			$aOut[0] = 'Samsung D500 JPEG file'
			$aOut[1] = 'JPG'
		Case $sStringLeft8 = 'FFD8FFE8'   ; JPG            Still Picture Interchange File Format (SPIFF)
			$aOut[0] = 'Still Picture Interchange File Format (SPIFF)'
			$aOut[1] = 'JPG'
		Case $sStringLeft8 = 'FFD8FFDB'   ; JPG            Samsung D807 JPEG file
			$aOut[0] = 'Samsung D807 JPEG file'
			$aOut[1] = 'JPG'
		Case $sStringLeft4 = 'FFD8'     ; JPG
			$aOut[0] = 'JPEG file'
			$aOut[1] = 'JPG'
		Case $sStringLeft4 = '424D'     ; BMP, DIB         Windows (or device-independent) bitmap image
			$aOut[0] = 'Windows Bitmap BMP'
			$aOut[1] = 'BMP'
		Case $sStringLeft8 = '89504E47'   ; PNG
			$aOut[0] = 'Portable Network Graphics PNG'
			$aOut[1] = 'PNG'
		Case $sStringLeft6 = '492049'    ; TIF, TIFF          Tagged Image File Format file
			$aOut[0] = 'Tagged Image File Format file'
			$aOut[1] = 'TIFF'
		Case $sStringLeft8 = '49492A00'   ; TIF, TIFF          Tagged Image File Format file (little endian, i.e., LSB first in the byte; Intel)
			$aOut[0] = 'Tagged Image File Format file little endian'
			$aOut[1] = 'TIFF'
		Case $sStringLeft6 = '4D4D2A'    ; TIF, TIFF          Tagged Image File Format file (big endian, i.e., LSB last in the byte; Motorola)
			$aOut[0] = 'Tagged Image File Format file big endian'
			$aOut[1] = 'TIFF'
		Case $sStringLeft6 = '4D4D2B'    ; TIF, TIFF          BigTIFF files; Tagged Image File Format files >4 GB
			$aOut[0] = 'BigTIFF files'
			$aOut[1] = 'TIFF'
	EndSelect
	If $aOut[1] = 'GIF' Then
		StringReplace($sString, '0021F904', '0021F904')        ; differenciate gifs and animated gifs
		If @extended > 1 Then $aOut[0] = 'Animated ' & $aOut[0]
	EndIf
	Return $aOut
EndFunc ;==> _PicGetType()

Func _RescaleCtrlsSetState()
	Select
		Case _IsChecked($idRadioTxt)
			GUICtrlSetState($idLabelRescale, $GUI_DISABLE)
			GUICtrlSetState($idSliderRescale, $GUI_DISABLE)
		Case _IsChecked($idRadioHtml)
			GUICtrlSetState($idLabelRescale, $GUI_DISABLE)
			GUICtrlSetState($idSliderRescale, $GUI_DISABLE)
		Case _IsChecked($idRadioImage)
			GUICtrlSetState($idLabelRescale, $GUI_ENABLE)
			GUICtrlSetState($idSliderRescale, $GUI_ENABLE)
	EndSelect
EndFunc ;==> _RescaleCtrlsSetState()

Func _RescaleLabelSetValue()
	Local $iScale = GUICtrlRead($idSliderRescale)/100
	If Not $sAscII Then Return ControlSetText($hGui, '', $idLabelRescale, 'Image Rescale : x' & $iScale)
	Local $aDim = _SaveAsImage('', $sAscII, $iScale)
	If IsArray($aDim) Then ControlSetText($hGui, '', $idLabelRescale, 'Image Rescale : x' & $iScale & ' [' & $aDim[0] & 'x' & $aDim[1] & ']')
EndFunc ;==> _RescaleLabelSetValue()

Func _Reset()
	_GuiCtrlPicButton_SimulateAction($hGui, $idButtonReset)
	GUICtrlSetData($idSliderGamma, 0)
	GUICtrlSetData($idSliderSaturation, 0)
	GUICtrlSetData($idSliderHue, 0)
	GUICtrlSetData($idSliderContrast, 0)
	GUICtrlSetData($idSliderBrigthness, 0)
	GUICtrlSetData($idComboCaractersCount, '')
	GUICtrlSetData($idComboCaractersCount, '18|16|14|12|10|08|06|04|02', '10') ; default 10
	GUICtrlSetState($idRadioTxt, $GUI_CHECKED)
	GUICtrlSetState($idRadioFilterNone, $GUI_CHECKED)
	_GammaLabelSetValue()
	_CharactersCountSet()
	_ImageSet()
	_RescaleCtrlsSetState()
	Local $aDim = _SaveAsImage('', $sAscII, 1)
	If IsArray($aDim) Then ControlSetText($hGui, '', $idLabelRescale, 'Image Rescale : x1 [' & $aDim[0] & 'x' & $aDim[1] & ']')
	GUICtrlSetData($idSliderRescale, 1*100)
	_RescaleLabelSetValue()
EndFunc ;==> _Reset()

Func _SaveAs()
	_GuiCtrlPicButton_SimulateAction($hGui, $idButtonSave)
	If Not $hImage Then Return
	If Not $sAscII Then Return
	Local $sFileSaveDialog
	Select
		Case _IsChecked($idRadioTxt)
			$sFileSaveDialog = FileSaveDialog('SaveAsText', @WorkingDir, 'Text (*.txt)', 2+16, 'AscII.txt', $hGui)
			If Not @error Then _SaveAsText($sFileSaveDialog, $sAscII)
		Case _IsChecked($idRadioHtml)
			$sFileSaveDialog = FileSaveDialog('SaveAsHtml', @WorkingDir, 'Html (*.Html)', 2+16, 'AscII.html', $hGui)
			If Not @error Then _SaveAsHtml($sFileSaveDialog, $sAscII)
		Case _IsChecked($idRadioImage)
			$sFileSaveDialog = FileSaveDialog('SaveAsImage', @WorkingDir, 'Image Files (*.bmp;*.gif;*.jpg;*.png;*.tiff)', 2+16, 'AscII.jpg', $hGui)
			If Not @error Then _SaveAsImage($sFileSaveDialog, $sAscII, GUICtrlRead($idSliderRescale)/100)
	EndSelect
EndFunc ;==> _SaveAs()

Func _SaveAsHtml($sFilePath, $sTxt)
	Local $hFile = FileOpen($sFilePath, 2+8)
	FileWriteLine($hFile, '<!DOCTYPE html>')
	FileWriteLine($hFile, '<html>')
	FileWriteLine($hFile, '<head>')
	FileWriteLine($hFile, '<style>')
	FileWriteLine($hFile, 'p.small {')
	FileWriteLine($hFile, 'line-height: 50%;') ; set space between lines.
	FileWriteLine($hFile, '}')
	FileWriteLine($hFile, 'p.big {')
	FileWriteLine($hFile, 'line-height: 100%;')
	FileWriteLine($hFile, '}')
	FileWriteLine($hFile, '</style>')
	FileWriteLine($hFile, '</head>')
	FileWriteLine($hFile, '<body>')
	FileWriteLine($hFile, '<p class="small" style="font-size:8px"><font face="Lucida Console" color="black">') ; set font to paragraph.
	$sTxt = StringReplace($sTxt, @CRLF, '</br>' & @CRLF & '<br>')
	FileWriteLine($hFile, '<br>' & StringTrimRight($sTxt, 4))
	FileWriteLine($hFile, '</p>') ; end of paragraph
	FileWriteLine($hFile, '</body>')
	FileWriteLine($hFile, '</html>')
	FileClose($hFile)
EndFunc ;==> _SaveAsHtml()

Func _SaveAsImage($sFilePath, $sTxt, $iScale=1)
	If Not $sTxt Then Return
	Local $hBrush, $hFormat, $hFamily, $hFont, $tLayout, $aInfo
	Local $hBitmap = _GDIPlus_BitmapCreateFromScan0(10^4, 10^4) ; 10000 pixels
	Local $hGraphic = _GDIPlus_ImageGetGraphicsContext($hBitmap)
	_GDIPlus_GraphicsSetSmoothingMode($hGraphic, $GDIP_SMOOTHINGMODE_ANTIALIAS8X8)
	_GDIPlus_GraphicsSetCompositingMode($hGraphic, $GDIP_COMPOSITINGMODESOURCEOVER)
	_GDIPlus_GraphicsSetCompositingQuality($hGraphic, $GDIP_COMPOSITINGQUALITYASSUMELINEAR)
	_GDIPlus_GraphicsSetInterpolationMode($hGraphic, $GDIP_INTERPOLATIONMODE_NEARESTNEIGHBOR)
	_GDIPlus_GraphicsSetPixelOffsetMode($hGraphic, $GDIP_PIXELOFFSETMODE_HIGHQUALITY)
	_GDIPlus_GraphicsClear($hGraphic, 0xFFFFFFFF)
	$hBrush = _GDIPlus_BrushCreateSolid(0xFF000000)
	$hFormat = _GDIPlus_StringFormatCreate()
	$hFamily = _GDIPlus_FontFamilyCreate('Lucida Console')
	$hFont = _GDIPlus_FontCreate($hFamily, 8)
	$tLayout = _GDIPlus_RectFCreate()
	Local $iTextWidth, $iTextHeight
	$aInfo = _GDIPlus_GraphicsMeasureString($hGraphic, $sTxt, $hFont, $tLayout, $hFormat)
	If IsArray($aInfo) Then
		$iTextWidth = Ceiling(DllStructGetData($aInfo[0], 'Width'))
		$iTextHeight = Ceiling(DllStructGetData($aInfo[0], 'Height'))
		_GDIPlus_GraphicsDrawStringEx($hGraphic, $sTxt, $hFont, $aInfo[0], $hFormat, $hBrush)
	EndIf
	Local $hBitmap2 = _GDIPlus_BitmapCreateFromScan0($iTextWidth, $iTextHeight)
	Local $hGraphic2 = _GDIPlus_ImageGetGraphicsContext($hBitmap2)
	_GDIPlus_GraphicsClear($hGraphic2, 0xFFFFFFFF)
	_GDIPlus_GraphicsSetSmoothingMode($hGraphic2, $GDIP_SMOOTHINGMODE_ANTIALIAS8X8)
	_GDIPlus_GraphicsSetCompositingMode($hGraphic2, $GDIP_COMPOSITINGMODESOURCEOVER)
	_GDIPlus_GraphicsSetCompositingQuality($hGraphic2, $GDIP_COMPOSITINGQUALITYASSUMELINEAR)
	_GDIPlus_GraphicsSetInterpolationMode($hGraphic2, $GDIP_INTERPOLATIONMODE_NEARESTNEIGHBOR)
	_GDIPlus_GraphicsSetPixelOffsetMode($hGraphic2, $GDIP_PIXELOFFSETMODE_HIGHQUALITY)
	; crop the bitmap
	_GDIPlus_GraphicsDrawImageRectRect($hGraphic2, $hBitmap, 0, 0, $iTextWidth, $iTextHeight, 0, 0, $iTextWidth, $iTextHeight)
	Local $hBitmap_Scaled = _GDIPlus_ImageScale($hBitmap2, $iScale, $iScale)
	Local $aRet[2]
	If $sFilePath Then
		_GDIPlus_ImageSaveToFile($hBitmap_Scaled, $sFilePath)
	Else
		$aRet[0] = _GDIPlus_ImageGetWidth($hBitmap_Scaled)
		$aRet[1] = _GDIPlus_ImageGetHeight($hBitmap_Scaled)
	EndIf
	_GDIPlus_FontDispose($hFont)
	_GDIPlus_FontFamilyDispose($hFamily)
	_GDIPlus_StringFormatDispose($hFormat)
	_GDIPlus_BrushDispose($hBrush)
	_GDIPlus_BitmapDispose($hBitmap_Scaled)
	_GDIPlus_GraphicsDispose($hGraphic2)
	_GDIPlus_BitmapDispose($hBitmap2)
	_GDIPlus_GraphicsDispose($hGraphic)
	_GDIPlus_BitmapDispose($hBitmap)
	If Not $sFilePath Then
		Return $aRet ; return infos.
	Else
		Return FileGetSize($sFilePath) <> 0 ; return fileexists.
	EndIf
EndFunc ;==> _SaveAsImage()

Func _SaveAsText($sFilePath, $sTxt)
	Local $hFile = FileOpen($sFilePath, 2+8)
	FileWrite($hFile, $sTxt)
	FileClose($hFile)
EndFunc ;==> _SaveAsText()

Func _ScriptGetVersion()
	Local $sFileVersion
	If @Compiled Then
		$sFileVersion = FileGetVersion(@ScriptFullPath, 'FileVersion')
	Else
		$sFileVersion = _StringBetween(FileRead(@ScriptFullPath), '#AutoIt3Wrapper_Res_Fileversion=', @CR)
		If Not @error Then
			$sFileVersion = $sFileVersion[0]
		Else
			$sFileVersion = '0.0.0.0'
		EndIf
	EndIf
	Return $sFileVersion
EndFunc ;==> _ScriptGetVersion()

Func _ScriptIsAlreadyRunning()
	Local $aWinList = WinList(AutoItWinGetTitle ())
	If Not @error Then Return UBound($aWinList) -1 > 1
EndFunc ;==> _ScriptIsAlreadyRunning()

Func _StringBetween($s_String, $s_Start, $s_End, $v_Case= -1)
	Local $s_case = ''
	If $v_Case = Default Or $v_Case = -1 Then $s_case = '(?i)'
	Local $s_pattern_escape = '(\.|\||\*|\?|\+|\(|\)|\{|\}|\[|\]|\^|\$|\\)'
	$s_Start = StringRegExpReplace($s_Start, $s_pattern_escape, '\\$1')
	$s_End = StringRegExpReplace($s_End, $s_pattern_escape, '\\$1')
	If $s_Start = '' Then $s_Start = '\A'
	If $s_End = '' Then $s_End = '\z'
	Local $a_ret = StringRegExp($s_String, '(?s)' & $s_case & $s_Start & '(.*?)' & $s_End, 3)
	If @error Then Return SetError(1, 0, 0)
	Return $a_ret
EndFunc ;==> _StringBetween()

Func _TextOpenInNotepad() ; open text in Notepad with "Lucida Console" Font with a size of 8.
	If Not $sAscII Then Return
	Local $aCursorInfos = GUIGetCursorInfo($hGui)
	If Not @error And $aCursorInfos[4] = $idEditTxt Then
		Local $sTmp = _FileGeneratePath('txt')
		Local $hFile = FileOpen($sTmp, 2+8)
		FileWrite($hFile, $sAscII)
		FileClose($hFile)
		; detect user font choice.
		Local $sUserFontName = RegRead('HKCU\Software\Microsoft\Notepad', 'lfFaceName')
		Local $iUserFontSize = RegRead('HKCU\Software\Microsoft\Notepad', 'iPointSize')
		; set temporarily wanted font.
		RegWrite('HKCU\Software\Microsoft\Notepad', 'lfFaceName', 'REG_SZ', 'Lucida Console')
		RegWrite('HKCU\Software\Microsoft\Notepad', 'iPointSize', 'REG_DWORD', 8*10)
		Local $iPid = Run('notepad "' & $sTmp & '"')
		ProcessWait($iPid, 2)
		; restore user font choice.
		RegWrite('HKCU\Software\Microsoft\Notepad', 'lfFaceName', 'REG_SZ', $sUserFontName)
		RegWrite('HKCU\Software\Microsoft\Notepad', 'iPointSize', 'REG_DWORD', $iUserFontSize)
	EndIf
EndFunc ;==> _TextOpenInNotepad()

Func _uFMOD_FadeOut($iVol = $uFMOD_DEFAULT_VOL)
	For $i = $iVol To 0 Step -1
		_uFMOD_SetVolume($i)
		Sleep(200)
	Next
EndFunc ;==> _uFMOD_FadeOut()

Func _uFMOD_PlaySong($Xm, $iLoop=1)
	Local $aRet, $tXm
	If $iLoop Then
		$iLoop = 0
	Else
		$iLoop = $XM_NOLOOP
	EndIf
	If Not IsBinary($Xm) Then
		If Not FileExists($Xm) Then Return SetError(-1, 0, 0)
		$aRet = DllCall($hUfmodDll, 'int', 'uFMOD_PlaySong', 'STR', $xmfile, 'uint', 0, 'uint', $XM_FILE + $iLoop)
		If @error Or Not $aRet[0] Then Return SetError(2, 0, 0)
	Else
		$tXm = DllStructCreate('byte[' & BinaryLen($Xm) & ']')
		DllStructSetData($tXm, 1, $Xm)
		$aRet = DllCall($hUfmodDll, 'int', 'uFMOD_PlaySong', 'ptr', DllStructGetPtr($tXm), 'int', DllStructGetSize($tXm), 'int', $XM_MEMORY + $iLoop)
		If @error Or Not $aRet[0] Then Return SetError(3, 0, 0)
		$tXm = 0
	EndIf
	Return 1
EndFunc ;==> _uFMOD_PlaySong()

Func _uFMOD_SetVolume($iVol = $uFMOD_DEFAULT_VOL)
	If $iVol < $uFMOD_MIN_VOL Then $iVol = $uFMOD_MIN_VOL
	If $iVol > $uFMOD_MAX_VOL Then $iVol = $uFMOD_MAX_VOL
	Local $aRet = DllCall($hUfmodDll, 'int', 'uFMOD_SetVolume', 'int', $iVol)
	If @error Or Not $aRet[0] Then Return SetError(1, 0, 0)
	Return 1
EndFunc ;==> _uFMOD_SetVolume()

Func _uFMOD_Shutdown()
	_uFMOD_StopSong()
	DllClose($hUfmodDll)
	$hUfmodDll = 0
EndFunc ;==> _uFMOD_Shutdown()

Func _uFMOD_Startup()
	UfmodDll('ufmod.dll', $sTempDir)
	Local $hOpen = DllOpen($sTempDir & '\ufmod.dll')
	If $hOpen = -1 Then Return SetError(1, 0, 0)
	Return SetError(0, 0, $hOpen)
EndFunc ;==> _uFMOD_Startup()

Func _uFMOD_StopSong()
	Local $aRet = DllCall($hUfmodDll, 'int', 'uFMOD_PlaySong', 'ptr', 0, 'int', 0, 'int', 0)
	If @error Or Not $aRet[0] Then Return SetError(1, 0, 0)
	Return 1
EndFunc ;==> _uFMOD_StopSong()

Func Ascii1Ico($sFileName, $sOutputDirPath, $iOverWrite=0) ; Code Generated by BinaryToAu3Kompressor.
	Local $sFileBin = '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'
	$sFileBin = Binary(_Base64Decode($sFileBin))
	$sFileBin = Binary(_LzntDecompress($sFileBin))
	If Not FileExists($sOutputDirPath) Then DirCreate($sOutputDirPath)
	If StringRight($sOutputDirPath, 1) <> '\' Then $sOutputDirPath &= '\'
	Local $sFilePath = $sOutputDirPath & $sFileName
	If FileExists($sFilePath) Then
		If $iOverWrite = 1 Then
			If Not Filedelete($sFilePath) Then Return SetError(2, 0, $sFileBin)
		Else
			Return SetError(0, 0, $sFileBin)
		EndIf
	EndIf
	Local $hFile = FileOpen($sFilePath, 16+2)
	If $hFile = -1 Then Return SetError(3, 0, $sFileBin)
	FileWrite($hFile, $sFileBin)
	FileClose($hFile)
	Return SetError(0, 0, $sFileBin)
EndFunc ;==> Ascii1Ico()

Func AvatarsMixJpg () ; Code Generated by BinaryToAu3Kompressor.
	Local $sFileBin = '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'
	$sFileBin &= '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'
	$sFileBin &= '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'
	$sFileBin &= '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'
	$sFileBin &= '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'
	$sFileBin &= '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'
	$sFileBin &= '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'
	$sFileBin &= '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'
	$sFileBin &= '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'
	$sFileBin &= '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'
	$sFileBin &= 'iXbrYm3TQjRCBGdTQYaMKkX/AOnb1j/Aw0+Iu6rFlTDxnlyNc/dRLFRNlyqFHIjHUtZpZ2lm32B3VtZuVl0y0VAihiAvZKikVEd3OoXorOXUyMnJHVXDCnU7QetaGmhFAHiIryCo+uhWITK+baEhlXdUMZUpNFydVuLj+VLiooRC9+SdoXyfNHtpdnDEse5QWO6op5Ixrc2DlSmuovbUXpbR5IkBypHrlG86nee2i8qPtHv4ugF71h/ox6qySLmWvgs3zjVsuYdTaimEWH7niYhFyrnXLSCVxJJblMFtfzcaShQXZ8gPVpRnxMnnY1FGeUirr6/0MwFYi9vg/wA6kwsul9VYb1PQaaCZdnih4vRIOtfZRJbLGujX0UCpMUBdFfLGPb5qIijjW2p5AsPLeo8VLFseC422oTcJ5Ou3QvFw19cetSb3qGXCRCZUFtnflXvSR4vgfG50Pi9dJGMCMFhY81sx5V666n+Ya4L+rR+qlXoTDoPWab+ug1wgnycR+VcITwMkqPMTmBolALRwMdPNxJb/AOYT86v10Am+llxE3mFd4ltc2ocu56aJjbk1Mp53c7escb4aQa2uFbxhQdcNHmG423UxA5INg3yuNJMoz7PLm7L0XOrnRF66LZ83Kvfr7aULdjWCdcqZrq2YnnVZ1icD5TmlEQygad7fcPRXDX0o9a1pbiFGjQPRSeSpWGUKzk6PahLDHDroy5vvp0YL+zyqRdlFyRb4X+VbMhNpytzaC5pUZIdiuurasaOXIB8nPpUSNvVQD/gYZcPBJOwmuRGt+g1pwRjsi7u8NUE7cGYwZi2bvJ0r4lP9ma+Jz/ZmntgcQTbojNd8wOKAyeNGamMsMkQMduUtuni2WMhEg6D0ij3JjEnT5GMTN/7t9FbYCJTvyhj+dLJj5O7WU3EdssY/20ABYDoHFwqy8FY2ZJMS7K6QkgivA3CH2BoMvAnCBZdQDCbUSeBOEBIddITa9Fn4Ex4diWOWA2rwLwh9gakQcDY+7Lb4A1wdHIhSRcOgZWFiDakx2FxSQyFckiy3tputapM2Jwaa6cpjf7qlj7obEyzMGdsuUaC2grPLhIJG63jBNZYYkiXqRbcS4fBoJJdsr2LZdNaAbCpf6YUbYVPtlop3IgPR39aGbCxaf661YYWP7da+KRfbrUmJxsCRxGAoCsgbW44wHBuNVZTYjyGuXiJ5F+SW0PoqwFhxq0ShgFtvtTFMNGAdPh15K9VfFYvtloZ8PGG+lFYSMYdNjES5G1XfXxWP7Vak2sShpd9nGnVXCXB8SKcRM4KDPvFx7K+LRfbLXxaL7ZaF8NH9stfFo/tlo/3aL7ZaCdzR3+mWhaCP7ZeLKXUHqvWYnStOSO2rHQ1nxM6Qr+0avh8Qk3zTWLnhKiWOMspYXF6IcYYjrEW/76/4Uf8AJ/nX/CfY/wA6/wCE+x/nX/CfY/zog9zBx/pfzoYnE5dptGXkCw0/wecK5wrnCucK1dR56+EX01zx/gRT4xZWSR8g2S31tXwWM+zHtr4LGfZj218FjPsx7a+Cxn2Y9tfBYz7Me2vgsZ9mPbU0ODSdWiXOdqoH58avLmyscoyIW9VJLisGY8O/ShzPH85berdSyROskZ3MpuOJm6hevif4n8q+J/ifyr4n+J/Kvin4n8q+J/iV8U/EpE7ltmYDn/4EeJxiytHI+zGyFze1/wAqgxkAcRTC65xrxXNSqs3Ki5wOlqTDrIZJiwQqmuQkX14p8LhEnWSFczbVQBvt10wDZCRzh0U2JweMlnl3lZTr5jTYfEF80fJJtr6K78zJrptRe9MFDgjr3GmRtyaAtuUddAQRjaeNId5rhK2h2DbqQK2/U+WtaCjUnQUMQ3TMYx5hxBhuG+h9M/8AgztiEywRtkVuljQwscXdWK3suawTy0FxeCMafLhbNbzUmIicSQuMyuOkViYlF0aPRM1jfrNYR+kryvL01hJY8vcm1C4jTUA9PEmfQMcoPbxRxfLBPooVsF1YDM37I6OLA/Wf+0/p8IfQD+KnnxEgiiXexopgR3LD8theQ/kKbujFTzDpDyG1cExhJmRoe+kvzWy35V9T1VDisbG2FhxhKy3sRHJfklrdY0v2CrjUVL8w0P0sP9Ivr/wMH9aH8DVwZ9H+Z4tmvPlOzXz1iEaSZ80w3nst+dQDCu7r3SoOc9NjxcLfRH+PjGLaUKxO7pNZhiDrr11s9tzqW1jfW44uEj/oNS5hbUnTdSxoMztoBTnao0sFgi9bW1NQwrvidfSd/rqQqvJE+QHstpQ7dKH0z+vjljw2KineI2kWNwcvlqDgufEZMXLay5TYX3XNbbF4iPDRXtnlawpXRg6MLhgdDx6AKo6BUmMxHxvEMZ3c9vRTCTlVjMHI2ZcNOQvkOtI40UmmwLZFgLkxHNdrsb+iirDMp0INWp4pVzRuLEVLwXj7yzRi8M/66PoJ7eukMEQklRMxDm2WsRLs2MEMV9Ov+hS4jFfHMV3+TsvuHmFhXWawP1n/ALT+nwh9XH8VEI390hNo16/2qjji2as5y55myovaawOKx+PjxOG2q7SGNCF7PNe1T4krO4jAOXDc869FTxYkWgdOVm6O2k4LxDZlZb4dj0da/mPPUvzD6qH6H7XFh/pF9f8AgYP60P4Grgz6P8zxQBTyonzn2UZcrIL5gGHTbSsHKT/xajynW/Fwt9Ef4+OMJHtAugN6d8JdJBoQp303KWWccqQk0qHRgOLhIf6DVG5HTaohe3JbUeSpsQ7XUliq+XprI264qZsapMWe/KP9bqVP2qA/1n9dYgYUhcSY22ZbcGtpXC2E4YxDS4jDyhdnIbutx6q4WwJxmW6KsUkzWUdLIT17q4LxByTpFpiMQpumbxPLlrA4bu5ZZturBsOwcIvjE+apO48SsaYbC2hnkN+jkmnl4ZlaTakPBtTd8tuninggwQmTMVVRE17dd6gC+MLfdVvurheLKVvIr5ujdamwULyTy9YGgNESrk8XyUjTTCV9xA1yny9PE0q99UeJ00gAjilYbPl65Om49VTxRTmDIc7PFoQD0W7aaPlJFJJey7rDQXPVUe3bahWYKToR2sOLA/Wf+08fdk8W0Z75ntfLUs8Sw2teKdbc7qvx8NbCEYmXuUWiZcwbljS1RYnCFuDjILvhplzZD2VssSlr8yRea/krYSDurAnQwt0fN9lB8NO2W4vkbKynqNSYebMYnFmAa16Ga94XE0Uny1B/oGjHtFEkiHKnTuoa1b9BrVh/pF9f+BgvrQ/gauDPo/zNSup5R0FK0nK2fS27z0kqdOmb2VhkB5HdCHL28XC30R/j4rHdU8Yc2zZEHlpSIXcAWulQyAFI+bIrdVGXxE3dvFj1UXYwtYU5kjyrvBO+ofI3q45pBYOeSvlpTv3mh9M/FguFsHLJhpJVMEjxMVJtu/rsotHDLOxOpVS168G4v7BvZV5cLNF8+MiuD+DZZZHwmfO0ZbkhRqdKtxKy8lWF7VKuFfbYdm3LzYrDce2spL5NwePr7axgDASuqrr02FGSKNefbtPXTztEsWoYKvT0ViB4qlbWtby1eaaOIdbsBRgGKSd35No9RUsk+HaW2+YSdXUOmji48I6bc6IAVaUdHnq4gyB++KJN2/01s1d4MUz5QycyMfnQ2vCGOxXz57D0CsAq7u6ek38U8eKTDscsVjby9FJwZBhzDOrHOhjsq9o4+HHcyBRhBfYtlbnjcahhGxhgciIBwXy9F731pO7IYJkyFHb5Y8nRr200+BzYjD7zHvdPbQnw0pikHSOnsPXWFEvBzSZjlleJt3kpQXXERA5rBsrL5ekUMNgzEWYcrJJra3T8ryUNP0Saw/0i+viwowMmxmml+EtfQC9MsmVMfD8Kg8b9ocf9n8HMO7v8yTfsh7aEuMbPiY5DEz/K6R66wf1ofwNXBn0f5mu54tUjPKPbUEMUavNO9hm3eeplbZsyta8RuPvqBujbJ6+Lhb6I/wAfHIzXy5jrR2Urcg9N'
	$sFileBin &= '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'
	$sFileBin &= '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'
	$sFileBin &= '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'
	$sFileBin &= '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'
	$sFileBin &= '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'
	$sFileBin &= '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'
	$sFileBin &= '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'
	$sFileBin &= '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'
	$sFileBin &= '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'
	$sFileBin &= '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'
	$sFileBin &= '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'
	$sFileBin &= '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'
	$sFileBin &= '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'
	$sFileBin &= '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'
	$sFileBin &= 'H8FMcp8rJpc4xJRm+iuJZnI3Py/rGvuoLjgLziKghDZ6+GMGVy4c4BxINxtjgCr674wA9mvSTh8s13tc5sw3fkrpcUnTvXhoAJO01QBPgwFSoiURS1QFStSiI5eAdZvKcsTCSZVQEEOpzXR95UcSAiChurYebMET5aQ6v1OMVQHIbHgmKLx9iSHm+MuMGTN0G6Oe8p/AAZNhR+sfpHZokQdimneKX8uann15yfW2201BHBEEnLJRp2b+Rjs1J1tIBSJtKgiLnBHAj+c4ZPOgvn/6x4ntCYLY8nrvJSJPSx0GlE0iraZB/wBYw0HbKi351hehgFETgBdnN7zvBMNH3BHwinp4YDUjxflYB8ADoyx57iiUU+8I+DLDIzaDQ4DDADmaadQ0XnjnDxFo1XKnxbk4hDhgUoq4xYa+ANCiiTWonrBGUSoQp9oCXZw8Y6K1OqdHIBr3lhsAN2PnGyBFRfCecKI0RMHVbweL9mHXSFj7XgM0lhbz0nrIPUdF2lrPCfzjDkQXpwbiSgD0Ry5PZ7w6nOzT+zm2tAYEEzUvv1r5HGehhz2BVvFKLvCayjVb27y6V3oBiACFjkfY6PQfjCNr6lNCI4GtBhuc4gefv/djhidzSIiSQtQHEBS5oCbwCbrqVMV28c/+2Ez1AaCCIxLC3abX8XfiZwVqOdkXzzkIEEFLecA0ADbsmgK0Rz3jIHulcg32VeBvjNRsiHuVV4G02agYJjSDa/Yc5rakBXzceKg/5LBD0D1rmYwF/tl2f7HJcdlU/Fi8gogZy44w21MKgBGt8nNwH0ghSOHj0MkOuMIb3LIexxhU7GCjt1VKv8Y8sV58oBEOQUf4c37VEaCmwKq5rUve0DYWaId33jpyC5BSIkB0xcUn55k41jSCqL0KpnqYmCcKBoIsHn5wLAJZjY7n5TF3DlqIvAGK3rtwRrpihaQ26HHHCTr4tYFSfea2R2H+kMIj6xTIQ8gPvEbDNQeieAoeRxwg5gHmcItDyT7L0+HDEQd1ZyboTfrCOY0/6cldO5vyc+c2mDm+ldu8BsAAQDoDo9Y7HO84nO3FdqhHgXwDs2UYPrdPZrGEBHnS6VxdZdi+Vjj2otBTXnHwm7uHyYpRAJya8+ecqJKXlMHWHz8Uhhs3/GGMTuic4t4qFgfOLNJ44ToL1gKHqUH3+sYAmw/sYYGBoAPa/wDCcibHjFpGpvRIg+I+3GKNyrfsODoQBQ74F+Rgu2hnyhq/q81yQ/GluUmY+gMD0YUqC64m0rrwTZlFgq8YJryDklvA/hyAo6I8NldZU5fr/vHE11zB/N/F0kgGtApG+sfqMjsY0kiaOBqZB9viqdjxlLbyA6AI+H38cgQAAQDr+j/8nx6WTPgSd3OOWYD+d9f7hJwRLU8Yo3ljpzKskvxk4041BHnjDAOeM9Kc8arlqJFRavIgRrhuNJj9g4RaJ1JM4DORPk19g42/Q4q89B+sBl7oz6NT9YC3XByhIpgRRjAyCF9Xm4QY90GP5yplvF+mERQyiMRxRo2qVVV22vLUhwGLVvIoE9i4+ET2ImDJIXi4D/ta/hPp36sR48dz5xmIVERzrRcvqco8YyisWVRoKtdKBqE5D8e7Ux56BjXby842oJQRrbwJziFTcgh/OKdSk9OSj86vwyzkNJwcOeVubsAaLgas1jXePyjVV3V3cEASahBc/wAD6zqO3YeHMrS8Xf3zX3fM1ztbDrGWkQcAIAZCw1sf184X5dVWe19IxaFtVLvnL8/xl+cvz/GX5/jL8/xl+c5jGNREC0EGa4yQXgQfm6aBtAf/AOKkn11//9k='
	$sFileBin = Binary(_Base64Decode($sFileBin))
	Return SetError(@error, 0, $sFileBin)
EndFunc ;==> AvatarsMixJpg()

Func ButtonAboutGif($sFileName, $sOutputDirPath, $iOverWrite=0) ; Code Generated by BinaryToAu3Kompressor.
	Local $sFileBin = 'R0lGODlhaAAWAPYAAEREREVFRUZGRkdHR0hISElJSUtLS0xMTE5OTk9PT1FRUVJSUlNTU1VVVVZWVlhYWFlZWVxcXF9fX2JiYmZmZmlpaWpqamxsbG1tbW9vb3FxcXNzc3V1dXZ2dnd3d3h4eHl5eXp6ent7e3x8fH5+fn9/f4CAgIGBgYODg4WFhYaGhoiIiI6OjpKSkpWVlZiYmJqamp6enqKioqWlpaenp6mpqaurq66urrGxsbOzs7W1tbi4uLq6ury8vL6+vsDAwMHBwcLCwsPDw8TExMbGxsfHx8jIyMrKysvLy83Nzc7Ozs/Pz9DQ0NHR0dLS0tPT09TU1NXV1dbW1tfX19jY2NnZ2dra2tvb29zc3N3d3d7e3t/f3+Dg4OHh4eLi4uTk5OXl5ebm5ujo6Onp6erq6uvr6+zs7O3t7e7u7u/v7/Dw8PHx8fLy8vPz8/T09PX19fb29vf39/j4+Pn5+fv7+wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH+GiJDcmVhdGVkIHdpdGggQ2hpbXBseS5jb20iACH5BAkAAHUALAAAAABoABYAAAf/gACCABc2P0KIiYqLjI2Oj5CRkpM/LxCDggc6R2NvdJ+goaKjpKWmp6ipqnJdPySDB0FYcnO1tre4ubq7vL2+v8C3bkEhgjpXccnKy8zNzs/Q0dLT1M5oQAgWR21u3d7f4OHfOScnOeDl4urr7O3u4U8nNl5r9fb3+Pn3aSsSgiz3TAjSR7CgPhMmDCokCEbHDzJoIkqcSLHiRCMkDhQooICNxFcA4FgcSbIiyJIoLZYBIsSMy5cwY8qMCaMCgBIaAPB4CdLICRMxrsDcUgNFCRQ0tvAkEZMEUzNOBfF4OrOqVTOIxmjdyrWrV65YRDgAMIQFAA1mtIoQ5EKBgAAP/4ZoxZKCA4QBAQZEQKJWENe1AMYAxvS1sGGtiMIoXsy4sWPGODgAaMBGhwEBWBQXw5QJShgZHAxwRhAlzGY2i0+H4QwA9ePXsBF9mU27tu3btVX4a5FmSQQAMMB8+SAIAxU1TfytAFPiAQDjyJWDIU5ADW3iAKxjV8PdOu7v4BF1GU++vPnz5Il4EC0DhocMACCI6eJBEBUzX7oQT0AGxAAA9+VHHAJk1FdAGuTVBwCCCiKI3oMQkoeIFhRWaOGFGFYYg02sASCEFh0IggYXWiwRIgFmjBAAACOWeOIZIRZwBoVHhMgiiCJmqOOOFiJyxY9ABinkkD9K0cFYHZ6whf9kACxxRRIswLeAGTD85ySU8CEAlV9WBIHCBYKYcYWNYhJp5plAIlLFmmy26eaba96ggQAARFHGnWXoAMAAWGwgiAQcbICBAgCkQEYSlwAqKKGG0lAAACFssAEFogFQRhUqrDjDBnB26imbiEgh6qiklmqqqLoBsMEYVYy6QwMA0MAkZwpE4YUUPSDA2QJT3Goja2NIwYOug5xq7LGiCuFDE0806+yz0Ebb7AQA6OAFtDUAQMEVguRwAQEEbLBEGFI0SwQKCBCAAApShBFFsy48IIABHPQgiBjN2oAkAPhK66+/TvzgAhFMFGzwwQgnbLAXYUyR8BRheMGEYlN0oRiCF08c/EQWYIQBhhYZG3zFFx5z0W4YBktBsmIKt+xyETM84EMSStRs880456zzzjz37PPPQO+sQ04h+HAEEkgnrfTSTDft9NNQRy311EzjUAOdqvogBBFFGOH112CHLfbYZJdt9tlop11EEDrUwAAmCJBwwyGT1G333Xjb/cMMcwoSCAA7'
	$sFileBin = Binary(_Base64Decode($sFileBin))
	If Not FileExists($sOutputDirPath) Then DirCreate($sOutputDirPath)
	If StringRight($sOutputDirPath, 1) <> '\' Then $sOutputDirPath &= '\'
	Local $sFilePath = $sOutputDirPath & $sFileName
	If FileExists($sFilePath) Then
		If $iOverWrite = 1 Then
			If Not Filedelete($sFilePath) Then Return SetError(2, 0, $sFileBin)
		Else
			Return SetError(0, 0, $sFileBin)
		EndIf
	EndIf
	Local $hFile = FileOpen($sFilePath, 16+2)
	If $hFile = -1 Then Return SetError(3, 0, $sFileBin)
	FileWrite($hFile, $sFileBin)
	FileClose($hFile)
	Return SetError(0, 0, $sFileBin)
EndFunc ;==> ButtonAboutGif()

Func Buttonexitgif($sFileName, $sOutputDirPath, $iOverWrite=0) ; Code Generated by BinaryToAu3Kompressor.
	Local $sFileBin = '0x47494638396168001600F600004444444545454646464949494A4A4A4B4B4B4D4D4D4E4E4E5252525454545555555656565757575959596060606363636666666868686A6A6A6C6C6C6F6F6F7171717272727373737474747575757676767878787B7B7B7D7D7D7E7E7E7F7F7F8080808181818484849292929696969A9A9AA0A0A0A3A3A3A5A5A5A7A7A7A9A9A9ADADADB0B0B0B3B3B3B6B6B6B8B8B8BABABABDBDBDBEBEBEC0C0C0C1C1C1C2C2C2C3C3C3C6C6C6C7C7C7C8C8C8C9C9C9CACACACBCBCBCDCDCDCECECED0D0D0D1D1D1D2D2D2D3D3D3D4D4D4D6D6D6D8D8D8D9D9D9DBDBDBDCDCDCDEDEDEE1E1E1E2E2E2E3E3E3E4E4E4E5E5E5E6E6E6E8E8E8E9E9E9EAEAEAEBEBEBECECECEEEEEEEFEFEFF0F0F0F1F1F1F2F2F2F3F3F3F4F4F4F5F5F5F6F6F6F7F7F7F8F8F8F9F9F9FBFBFB00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021FE1A22437265617465642077697468204368696D706C792E636F6D220021F90409000062002C00000000680016000007FF80008200132B333688898A8B8C8D8E8F9091929333250D8382062E3B515C619FA0A1A2A3A4A5A6A7A8A9AA5F4A331E830635485F60B5B6B7B8B9BABBBCBDBEBFC0B75B351C822D475EC9CACBCCCDCECFD0D1D2D3D4CE553407123A5A5BDDDEDFE0E1E2E021E5E6E5E3DFE8E9ECEDEE5B42212B4B58F5F6F7F8F9FAF9209898FBF6FA01A8070204C08308013A7131434A958710234A9C4871E22B7F82BA548498B1CAC58D2043569C42C30695932853AA5CC9926507415C62CA04D26144CA111D5450E9D021264F41303AB41C4A9428A22848932A5DCAB469D36200B42C7DE2004003A43038240020026A14A8989C8A1D2B16D193B368D3AA5DCB962DD4AC1CFFE29E1DA2008009231F20007840C584A02C4F30026E4BB8305B444C122B5ECCB8B163C71B300A4ABC82008113160A1C305205EA152691015C19FDF9B1E9D38E112959CDBAB5EBD7B06187C66865350600102EBDA8025A50EDD0B5630B1F3E1C5192E3C8932B5FCE9CB906411493ACD080405003DE499E03A8921D7AF3EFE0C3233A42BEBCF9F3E8D3A7BF0D800AFA1B19AA5E8800600479F6EEB5BB57CFBF7F7F44460428E080041668A0811708E2C2050C5E60C410214810800146C43040003218912000531821420000A0E0E081249648222244A4A8E28A2CB6E8A28B1548064009141C00400A501411230342C408401444C060E3202F1669649136C40084B0104C36E9E493504619A58C50143301144730491F0843080205932B2C30C897529669269441CC40C20D3FB4E9E69B70C629E79C6DFD90C4134ABCA9C41349FC70969B443481D69C84162A270E283410430F3E34EAE8A390462AE9A494566AE9A5984EDA428C1CC4B0030FA0862AEAA8A4966AEAA9A8A6AAEAAAA4B2A08200825C20830D37E090C3ADB8E6AAEBAEBCF6EAEBAFC0062B2C0E35B4A0C256831CD081219334EBECB3D03E3B030A15C00A4020003B'
	If Not FileExists($sOutputDirPath) Then DirCreate($sOutputDirPath)
	If StringRight($sOutputDirPath, 1) <> '\' Then $sOutputDirPath &= '\'
	Local $sFilePath = $sOutputDirPath & $sFileName
	If FileExists($sFilePath) Then
		If $iOverWrite = 1 Then
			If Not Filedelete($sFilePath) Then Return SetError(2, 0, $sFileBin)
		Else
			Return SetError(0, 0, $sFileBin)
		EndIf
	EndIf
	Local $hFile = FileOpen($sFilePath, 16+2)
	If $hFile = -1 Then Return SetError(3, 0, $sFileBin)
	FileWrite($hFile, $sFileBin)
	FileClose($hFile)
	Return SetError(0, 0, $sFileBin)
EndFunc ;==> Buttonexitgif()

Func Buttonopengif($sFileName, $sOutputDirPath, $iOverWrite=0) ; Code Generated by BinaryToAu3Kompressor.
	Local $sFileBin = 'R0lGODlhaAAWAPYAAEREREVFRUZGRkdHR0hISElJSUpKSktLS0xMTE1NTU5OTk9PT1FRUVJSUlNTU1VVVVdXV1lZWVpaWltbW1xcXF1dXV5eXmBgYGJiYmVlZWhoaGtra21tbW5ubm9vb3BwcHFxcXNzc3V1dXd3d3h4eHl5eXt7e3x8fH19fX5+fn9/f4GBgYODg4WFhYiIiIqKio6OjpOTk5qamqCgoKWlpaioqKurq62tra6urrGxsbS0tLa2tri4uLq6ury8vL6+vsDAwMHBwcLCwsPDw8TExMbGxsfHx8jIyMrKysvLy8zMzM3Nzc7Ozs/Pz9DQ0NHR0dLS0tPT09TU1NXV1dbW1tfX19jY2NnZ2dra2tvb29zc3N3d3d/f3+Dg4OHh4eLi4uPj4+Tk5OXl5ebm5ujo6Onp6erq6uvr6+zs7O3t7e7u7u/v7/Dw8PHx8fPz8/T09PX19ff39/j4+Pn5+fv7+wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH+GiJDcmVhdGVkIHdpdGggQ2hpbXBseS5jb20iACH5BAkAAHUALAAAAABoABYAAAf/gACCABs3QEOIiYqLjI2Oj5CRkpNAMhKDggg7SGVwdJ+goaKjpKWmp6ipqnJeQCmDCEJacnO1tre4ubq7vL2+v8C3b0ImgjpZccnKy8zNzs/Q0dLT1M5qQQobSG5v3d7f4OHhYzkxLS0xOWLi7O3u7/DiUSs2X233+Pn6+/tPLSQWEggQkMCCD34IEypcyHCfmB1AzKiZSLGixYsWubTgQACTIAI5MIocSbKkSYtnggxBw7Kly5cwYd4QUQBACindoIQAYMAKGhQokMhYsUJGFpdfbLRYwYIGlpZAmcxgoeKFjphYs8ZEVKar169gw4aFQcGmGzZnulbJAACGmWIA/zQwEBAAApGuGkdMKBBggAQgXeFyeDAggAETYhMrDotojOPHkCNLlnwiAQAnaiCL+QCgQhq4HhFIGUNDxAKPBpSMAe1RxuTXsCMjAkO7tu3buHGbCACAzRjbX0gAKKBGOAAOVtg8uQDAhZgVEQCYwMFjBwwAI8QYj2BkTZoSACKYyU2+vG1EXtKrX8++fXsXvNewXzJi+Jr6AHyC8SJ8gZkSHXnE0xn4LZFGGPwBIEAa7jXo4HqIcCHhhBRWaKGFMyAAgBIVysBBZ2ngp0YXXDRRHwFopMCbgACEKIgaXkiIXxoX1mgjhYhkoeOOPPboo49LROdBEjoWEYMIDwDwgv8ZIgjSRBZLwNABAA2gMUNHT6BxxhdTBMFSkwCgsSOYYv5o5pk7InLFmmy26eabcN7QEQYbhBDCBkkeQAUYOwFwgQghcMAAAC2Y4UQFAGBg550XZHBFn2ewCSmclFbaJiJUZKrpppx26ikVNBgg4AE9kGEFCCwyMMUXVBDRAItioApAGZrKSuunuOY6xA9PROHrr8AGK+ywURjxQgUEEFDBC1CQcUUUnAGgwwbJhtDEGFT4qkQMFhAgQAUtFEFGFIKM+2u5xKarLhRAxFCEE/DGK++89NYLbxRbgOEYGFtEAe+UAIxRhReOdeFvvE9ooe9vW0wBr2PzQmzvxBMbQUNuBD8swcTGHHfs8ccgh8yxB4KIIfLJKKesMhM6oGrCD0gkIfPMNNds8804z5wsGDn37PPPQOdQgwCChPDDEEUYccTSTDft9NNQR31EelJXbfXVVRshhA41OICJAijgcMgkZJdt9tllA0EDCEQDEAgAOw=='
	$sFileBin = Binary(_Base64Decode($sFileBin))
	If Not FileExists($sOutputDirPath) Then DirCreate($sOutputDirPath)
	If StringRight($sOutputDirPath, 1) <> '\' Then $sOutputDirPath &= '\'
	Local $sFilePath = $sOutputDirPath & $sFileName
	If FileExists($sFilePath) Then
		If $iOverWrite = 1 Then
			If Not Filedelete($sFilePath) Then Return SetError(2, 0, $sFileBin)
		Else
			Return SetError(0, 0, $sFileBin)
		EndIf
	EndIf
	Local $hFile = FileOpen($sFilePath, 16+2)
	If $hFile = -1 Then Return SetError(3, 0, $sFileBin)
	FileWrite($hFile, $sFileBin)
	FileClose($hFile)
	Return SetError(0, 0, $sFileBin)
EndFunc ;==> Buttonopengif()

Func ButtonResetGif($sFileName, $sOutputDirPath, $iOverWrite=0) ; Code Generated by BinaryToAu3Kompressor.
	Local $sFileBin = 'R0lGODlhaAAWAPYAAEREREVFRUZGRkdHR0hISElJSUpKSktLS0xMTE1NTU5OTk9PT1BQUFJSUlNTU1ZWVlhYWFpaWltbW1xcXF1dXV5eXl9fX2FhYWNjY2RkZGtra25ubnFxcXNzc3V1dXZ2dnd3d3l5eXp6ent7e35+fn9/f4CAgIGBgYODg4WFhYeHh4mJiYuLi4yMjI6OjpCQkJeXl6CgoKSkpKampqqqqqysrK6urrKysrS0tLe3t7q6ur29vb+/v8HBwcLCwsPDw8TExMbGxsfHx8jIyMnJycvLy8rKyszMzM3Nzc7OztDQ0NHR0dLS0tPT09TU1NXV1dbW1tnZ2dra2tvb29zc3N3d3d7e3t/f3+Dg4OHh4eLi4uPj4+Tk5OXl5ebm5ufn5+jo6Onp6erq6uvr6+zs7O3t7e7u7u/v7/Dw8PHx8fLy8vPz8/T09Pb29vf39/j4+Pr6+vv7+wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH+GiJDcmVhdGVkIHdpdGggQ2hpbXBseS5jb20iACH5BAkAAHIALAAAAABoABYAAAf/gACCABo1PT+IiYqLjI2Oj5CRkpM9MBGDggg4RmFtcZ+goaKjpKWmp6ipqm9ZPSSDCD5Ub3C1tre4ubq7vL2+v8C3bD4igjhTbsnKy8zNzs/Q0dLT1M5mPQoaRGts3d7f4OHdJ+TkKTA73OLr7O3u7+xNJzVaafb3+Pn69yaYAAMMSKDZR7CgwTQmTBxcqK8Ljh5izEicSLGixYmv/Al6cbGjx49mMoIcWXHMITIoU6pcyVJlxjYwxfRDkAallhoqTKCQISUlFxstTJRwQQNKyps5d/ZESSKjDhIto0pNiSiM1atYs2rFOkLQmjBabpQAQODrFRUfJBQIMCACD6sw/0BQOBAgAAIJQ8KcTbu27dswXf1tHUzYKiIviBMrXsxYcTEAOkSIAIGBkBovMzws8GfgiJcRDjQCAJN5M6bOiDVebsy6NaItsGPLnk1bdgjRDIiU2XLi0ggbOXK4AACiywpBN4o8SUJDA5reAH4HH158y20AaLKjqc29+xZEWcKLH0++/HgQohNA4ZIlBAHRBsYc2UzgwYMLNr6QcQ9/TBb0AJxh3oAEjoeIFQgmqOCCDCr4gSASiUGDAgCkgIUVJAQgGgBlWNFDZYMEMAOGGorW4YMAmNHgiiwqiMgUMMYo44w0yuiBIGTEyAIAB3AxRQzvLUHGGFo80QNKLuDghP8VO9hw2wNZAAmAkEQaidIUKOZY45ZcxohIFGCGKeaYZIrZgSBjhDkDAwDwEIUSFABwQQd0amBBBlF0sMAFG4CgAnoEhAGnnHR2YCeeUaig4QwdlOnoo2EiAsWklFZq6aWVciBIGJT2cIkLU0ABRAOideGDaB5wOmqpUOhA4SCYxirrpD/ssEQTuOaq66686ioIGLriAAAFV+B6xAsVECAABSoEAWwOKkwgAAEVuICFFsYiqyyzzuJawwODANvruOMyUUkQSqSr7rrstssuYuw+4cUW6i5BxRaIbVHFE+k6UQW+81KxRL335ruvuusl5u7CDAshAwQ7IJHExBRXbPFaxRhnrPHGHHfsccY4aCrCDkYUYfLJKKes8sost+zyyzDHrPINNAggSAc8/BCEEEP07PPPQAct9NBEF2300UgL4QMONIQ2iAIk2JDzJFRXbfXVVfMwAwc2AxAIADs='
	$sFileBin = Binary(_Base64Decode($sFileBin))
	If Not FileExists($sOutputDirPath) Then DirCreate($sOutputDirPath)
	If StringRight($sOutputDirPath, 1) <> '\' Then $sOutputDirPath &= '\'
	Local $sFilePath = $sOutputDirPath & $sFileName
	If FileExists($sFilePath) Then
		If $iOverWrite = 1 Then
			If Not Filedelete($sFilePath) Then Return SetError(2, 0, $sFileBin)
		Else
			Return SetError(0, 0, $sFileBin)
		EndIf
	EndIf
	Local $hFile = FileOpen($sFilePath, 16+2)
	If $hFile = -1 Then Return SetError(3, 0, $sFileBin)
	FileWrite($hFile, $sFileBin)
	FileClose($hFile)
	Return SetError(0, 0, $sFileBin)
EndFunc ;==> ButtonResetGif()

Func ButtonSaveAsgif($sFileName, $sOutputDirPath, $iOverWrite=0) ; Code Generated by BinaryToAu3Kompressor.
	Local $sFileBin = 'R0lGODlhaAAWAPYAAERERMPDw0RERM7Ozvf398vLy8jIyPn5+fv7+/T09PHx8e7u7uzs7Obm5tDQ0Onp6dPT097e3uPj49bW1uHh4dvb29nZ2UhISOLi4nNzc1ZWVkZGRkVFRejo6Jqamuvr64aGhrOzs3d3d1tbW2pqal5eXlBQUGFhYbm5uaioqHFxcUdHR8DAwNHR0XV1dX19fXt7e42NjX5+ftXV1VpaWtzc3FRUVLS0tJCQkL+/v7Gxsaurq729vV9fX+Xl5aSkpEpKSt/f32RkZJaWloeHh9ra2p2dncbGxsHBwbe3t05OTu3t7erq6oGBgd3d3bW1tUxMTNfX125ubszMzGhoaICAgMfHx6+vr3Z2dq6urmxsbH9/f6CgoJiYmPX19fLy8u/v7+Dg4NjY2MnJyaqqqk9PT3x8fMLCwk1NTUtLS6Kioru7u/j4+PPz84qKiuTk5ISEhNTU1M/Pz83NzcrKysTExIyMjKWlpWZmZpOTk4KCgvDw8Ofn59LS0sXFxaysrCH+GiJDcmVhdGVkIHdpdGggQ2hpbXBseS5jb20iACH5BAkAAAAALAAAAABoABYAAAf/gAKCAlp/LAGIiYqLjI2Oj5CRkpMsXTSDglBPdA9eCJ+goaKjpKWmp6ipqmwULDKDUGc1bAe1tre4ubq7vL2+v8C3CWcwgjcVBMnKy8zNzs/Q0dLT1M4LSEokY20J3d7f4N4ORiBwRFw64err7OohTU0h7fP0EE07GAr6+/z9+wZVpJhYseGCDTf+Eipc2A8MkR6CYjCcONHHExZMFmjcyLHjRhwkMA1q47GkyZMcDbyAcuGCiS8oY6L8gCQAg5s4c+rMKQONgB1fvGAIIcXLTZUvtuBIcnPIizE5x7zIcxPDDhBV9PwootNDyC0qBKzB+SaLnSpbYpCZsLOtW0QP/+LKnUt3Lg5BcsTEZbJEQdwhIQVwUCLjAQ8TAp7I9SqAShAQWEZc4LCCRg65NWBoEFAnhgAVDOJ6EFEiDQcOUEYYqMuaNaIGsGPLni27BWINJ8yEKDI78CAPEqgIcMGkQQUYNn5acVFGJJApsHW4EKDhy5M0G2rARi5SUAfa4GkjkkC+vPnz51kgFmRCCAryEVKAIIMCxQ8BIx6oIehEwpUMHFzQgQeXwHAFCkl4JoIPEoBQggA4gCHHCAJ4wCARgoRQwAwDkKHFHuiFiB4iFJRo4okopljED5sJcsEaFHDhwghAcDDIBUvMcYkRGIAAERxgmHFBdwIA8cERIqQhgP8ao0khAA0dUDBFcxdogNsVfDCQ4pYpIhLBl2CGKeaYEQTxRgoyKIEfBiK0KNISEbyAHwRY+ORHBzLYSOQSRvgmUgBfsiAEJhykQOahYiJSwaKMNupoo27sgIQYFViQQxcCXMCECDai0IABIQjCQAUhIPZDSDQwEIQRQ7bAwAcYzIBEaFi4KVITQcRwQxwR8JCFCNRR8OiwjyJiwbHIJqtsshmgUQIVGUQL0QkfeGBjF0So0OIHFsxwwmcPetCBBQ48eEK0GWjRAx5XqLCBADN8IO8HNwiwQg0ZlHGCFCKAAOwFDywr8LKITGDwwQgnjLAORAqgQwMtDNrdAwYPscL/xRtEEYTBdawnUggQZRDwwSgkl0IARLpAscIsJxwADy1AIPPMNNdMMxcynABEkS6g0EEREExRxQUbCBGqAB3MbIYgLnQww8xT4FAC0SWAcEQHgyaBQc0pNFZBEiCMUFAJMYSxtc1o09wHC0Mc4cDbcMctt9xiRICBDw34EMYEcLcQAWwYRAFb3E7AFobcLdQgAWwSODGDAxg0EMXcgmPgQBz9MV5DC3N3LrcVLPIwxwCkl2766ainrvrqrLfu+uuq3xAWDDzQUcDtuOeu++689+7778AHL/zuOqTwrgAZ5BDAEVYY4Pzz0Ecv/fTUV2/99dhnb8UZN6SQ3CBKvJCFD/KTlG/++eibn8Md7goSCAA7'
	$sFileBin = Binary(_Base64Decode($sFileBin))
	If Not FileExists($sOutputDirPath) Then DirCreate($sOutputDirPath)
	If StringRight($sOutputDirPath, 1) <> '\' Then $sOutputDirPath &= '\'
	Local $sFilePath = $sOutputDirPath & $sFileName
	If FileExists($sFilePath) Then
		If $iOverWrite = 1 Then
			If Not Filedelete($sFilePath) Then Return SetError(2, 0, $sFileBin)
		Else
			Return SetError(0, 0, $sFileBin)
		EndIf
	EndIf
	Local $hFile = FileOpen($sFilePath, 16+2)
	If $hFile = -1 Then Return SetError(3, 0, $sFileBin)
	FileWrite($hFile, $sFileBin)
	FileClose($hFile)
	Return SetError(0, 0, $sFileBin)
EndFunc ;==> ButtonSaveAsgif()

Func HeadlineOneTtfFont() ; Code Generated by BinaryToAu3Kompressor.
	Local $sFileBin = 'Jb4AAAEAAAAOADAAAAMAsE9TLzIAgndvuAAAaowBAKhOY21hcKulAFNEAABiNAAAAAJQY3Z0ICszQGCLAAAExAAM+gBmcGdtgzPCTwUAFrAAXhRnbHlmAPSuQx4AAAnoAAAAVIxoZG14AGX33qsAAGSEAAAABghoZWFkUOaaJnQAvtwAXjYCaAAgF14T9QAABGsUAA8kaG10eICbMALlAABfAD8AAXBsb2NhAA0gtpoAAF4AMwF0AG1heHAA1AS9BQAvOAAvIG5hbWUQrGCqAwAL7AAAAAPDcG9zdAm/QApaAABhWAAT2gBwcmVwCo0UlRUAj8AADygAAxUBAiMABQMAxgBjBAkBAAgYATWEBQIACgGCUoQFAwBgAcKEBSAEACQBboQFBQAISgJHhAUGACACHqGCogEAgSiDBQEADAQBKYQFAgAFAU1BhAUDADABkoQFBBAAEgFchAUFACUEAiKEBQYAEAKR8YAUAQQJhFODBYNTgwX/g1ODBYNTgwWDU4MFg1ODBQGCU6kyMDAyIGIAeSBBbmRyZXcAIExlbWFuLiAARGlnaXRpemUAZCBmcm9tIHYAaW50YWdlIGMAb3BpZXMgb2YAIHRoZSBUb3IAb250byBTdGEAciBleGNsdXMAaXZlbHkgZm8CcgIISFBMSFMuUACpADKAkzBAASAQAGIAeUABQQBuAABkAHIAZQB3RUADTMABbQBhwAQuQUADRABpAGfAAHRVwAB6QAZkwARmwApvUcAIIAB2QAVuwAZhVcAIZcADY8AFcMAEZVQAc0ADb0AKIEAHaF3CBlTAA8ENwQtvwANTRcINckACZQB4QA5s1AB1QA1pwBRlwALBJUZmQgxHEEgAUEAnSAlADi5IgKpsaW5lUCBPbmVABGVAEmT3QA1BI0EKT8EBwjsHDYkMR8NCFQ6JGk1hY4BcZSBkaWEgRoFXZ3IAYXBoZXIgNC5QMS40INAUTUAUY4sESIFLacADIABGBj66Z8AGYQBJgTQBNzSAWRoxwAA0Qh38IzEwL7A5LzAynxCYEDFgQ/gvADlgAGBEBRzgG1MmAwMUJzNAAQAsdkUAILADJUUjYWgAGCNoYEQt//cAAZMDJgM4AJwAAIp6ZUtVmKQA7OY1qFdZ8psA3JpzePnlisUAOWCsC0DruaQAsF0OgU7kyIkAuyF56TW5inEAQawgwNh/dhoA4oHLbEUBLbQArSMLi8L5JM0Adw0VNPmHlGMAGg6t8B2V8zQAZZhZpf5EjvIAC570OIarChMApyMioMRLc/0ADyGJUzr+5XQAjRFtnABtv/kAWp3AfUkcOb8ArlBJjvqoJWAAXPjxn3w+8KgAmEt6yRW/jloAPNfhMcFyc+IAEpewCU6mg2gAvhAjjNE/cMkA5lmRgQeuuhAATjjLmFuIEGAA+177nsqvHM8AXM/17zTvNu8AdYAKJ5i+OigAsIiR6NDRKhYAbDoVmrOzUjcAy9BpPiVHtdIAGDwlUMmIY6EA41mf6kB+5Q0AgIM9BqXmJfYAFMZkF7h3mTkAgKgmCIgtpskARXTeVmzzAZoAtHxtMx+s2hIAOnd8GO6S1XoAfy4GvpxJLNwApXs3ruPVYHAAHwi+gWF8LxEA24RHM72bgrQAdTMHqo9EO7QAapRd7ac69yYAjoYmr6lbVMQA8iqoUyDG7ygArkRctO7daHUAAvbKim4ZFa8AoCoomrDigdIA0SMnY2ItDdwAqyQTGT39s5gAQ0Ln55qGC2gA9ieK0FE+hRsAgwxlpkBm9wcAlas/VM37XNYAxUme+wWZ5ngAqO1AmMo/Np8A7//dzxIecgIAC+KqjEki9LUA13Vy6B2c8GAADGA9UA6hQuEAh6+pQkymrpcAwXNvHvjAS2UAPgSu5gupJlIA/LwgmWaOCSQA7+RMhTEp0NYAaXngVLfHLHUAzQotyWB+COkAk4xubidcB5AAVvD6idsodc4A+GuLUz/20pkAQ1mbWapp/7gAzZoUlDZF3a8APY5QdN4RafkA2ZyPPyGfmJAAkUlvta+Q6bUAmD1end28gFIAIc3YcHFf2/oAu3EvGN36BLQAKDzf30UlpfAAhjD2BMdERf0AqbzEWmrH/CcATkIj7dXDClgAODvdt3tTo/4A3GNwFvuxiiQAHt//eZD3TqUA6j2G0kpr5hIAa/oXbbpfZN4ACIzxPpjZM1EAsLlE3Np7bvUA653aXSJdE20AYLy0np2Qv0EAWqOEkqtwQR0A0v1QmAQDuOMAYawYVea5NpwAcLETOdHhZoAACy6uyUN0zlsARdEBcKMOG8sAEnze632OuHAAFVBXoKfx55MAkXMgHcaTYiQATIboe5PtfdEAwWOg4l6B+2kAZhELjbk+KLYAzlppgu+tghEAMDTAxEYF3ycAvqpvVwD68SQATEgisMjZSnEA4PIohkwV66sAgi4Ons7e/+4AMz8BH0AR68AAiSBxFR/xrZwAJX6FG3iC7WQA1Ctk1LM64x8ApTBHuqJimjIAVvo11/JCY+gAD5m+PB6bEIwA2TtC3r8AFnIAWEKqgqi7DXoAIxjJhVll6QAAnKsxC+08mrUAS1j79plrAB0A7IKeKUCR96YAj2YMArqfVzcA0qt0RePawnMAaOyM8r3CjRMAw3MGPSmszxQALylBzexoZ1IAy/e+li94ijcApqB9DqFr5xwAiZZsdtgmlI4AdiMsXqDFXncAwRohwWxmBBEAh4RyZitUG6gAaujukc8gYcYADGOHSyvu3pEAT3+vX9joUDgA/yyTyQFwt1wAJM/GLzhYT9EAnn6q6CeEoDgAWbb/RdHGXH8AoH8JTXmBS8EAznguO0Df73oAeKTKwb5oLkQAjtynu1E3yM0AblVQ8+KUbkoABuOIhzQA0+4AeIEPNIq1dVYAE4ivoDUQ4T8Ae9ASWoWCCrYAzEQuzVduywUAYIzxK5HKSkoE5eDAix2ilfNpALsiFcRpxCGlAMJVW7Xvx3FOAB3j/neRVxT4AJIoAA0CdwAAgEAJAwMCAgFwgwABjbgB/4VFaCJEJgCxBARRAAUFi1AA8II/MAK2A2bwgAAHAFZAIAEICABACQIHBAQBAAAGBQQDAgUEBYAABwYFAQIBAJUAAQBGdi83GABAPzwvPBD9IQABCC88/cAA/TwAMSAwAUlouYCJCEkAaGGwQFJYOBEAN7kACP/AOFkAMxEhESUzESMAPwF3/sf6+gNAZvyaPwLpsAczAP/yANIDIgAcAAAtAElAGAEuAC5ALwAqCggsACYkHRIQAB8AoBgWAgEQNQc/8AGNAgAAMADkBhAALukGAi7hBhMUBwYHBkAjIgcGJyYTADcANjU0NzAzMhUAFBYRFCMiJiMCIjABNDMyNzYXABbQAQgPBBIKgBoVCRQBAhFBEwABF2gXBRYXSYQKGbAAGkshE8APQM4cB0ZvFMABAgAXJY4LFyJliwAvEQINSer+GgAKAhg5ORICAVQVJBGdICACPRANFAFwpUdAFwEpKUAAKgAgHxUMCwAAIwUGBBklEQJkAR9HFC/9NA3lEx+UACn5DCnxDAEW8QwEJyKADD0BNDYz1BY3gAwHQg4ngAwyAQA2NxYVFAE8AQAPAgoIPQMMAQAKCAQfQA2eEgHhAAoCDgcFICFALwJ5FFULEAwTQAYyKZsFCIAAhogUAmURAQlGJQEBEAEBFYYwDCv/+xAB9QM/IHuDAJUAQEMBhIRAhQAAgHpZV09BMjAAFQl3dXRtbGYAZV1bPTwsKyMAIQ8NBwYAfE0ASxsZBRcEQzYANANEagVjYT8AA19yLm8FKUYQHQABPPQOLy/9gDw8Lxc8/QFBAHwXPNQcCgChHQQAFBE8tACEGRGEEhHCDx1hACAnJjU0NTAAIyLANwYVFBcUkBE2AQHUETMwFxY3NjcGNpAgBAEyBzY1AwGwHyM2FhUwERRR4QE1EzQAATegFhWAFDMyMzYzMuIFJAciYAAzMuAAFSdoNDU0kCMXQAYB'
	$sFileBin &= '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'
	$sFileBin &= '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'
	$sFileBin &= 'ZlklBiMycQIiAhM0UhmwgdELFwIwkAwWASQBGQYAilQhDwUCEhUCVwBWAwICAwEWQGgYAQwSAoAoFkAB/AEAHAMQGQsACQos4/dgFwEEEiOxKwj/8QIZBXBxTFJxTU1ATgAAPyMQLyclDgoACAQAR0U3AivoKRkD4AoveJwVC7kkaC8ATTkLTUVm86w3CUAtNTRzmwcOASN/gX8iJlJyNBtBr0Qn8C8TJ9BLwRoDDhcSMAwDCQgEeBABcwEEBQQACAsNBAQdHC0AAQkGCgsMAwXBUDoBEHUQAtB8oBgAAwg2PAoIC1cACAUGByU6BhEAaQ4EBAYUEQQADAEBAxYaQiwAR0QFFREkYHMAHRkGARwvcmoADRQV7ygaAiIAO2198c8TCQcCC+AtFh/+5RkZAHbGFQEcra3+AuJQHfn/6wFyAyJAUHlOQBxTeSoMACwcEA4uBAAygDAiAyACFgawEhcYToEr3B0c73hZASY7VzchERXAd/EA8FwmEydwr0ERM14zMoESFzIBsE1yAQQQMDUSEAUhLATArRkRHAgkBRRROQUCCxgAKTIEDgQyFAgABQcCBBQiOxUAAww0/NAaAwgACAMSlr4PFRUgeXhDFAUQEwEYIoywThFKGDHCFfJARhsfUeMXoDoCAP///+wBOAMkEAAPABryvRsbQAAcABkREAQPAAAWFQQHBhMFC2gCCwIGTi+kkjEAANGlDgYAG6kOG0MheqA4FQMRcCHQapANATgAoFMkIiwkSU4AJC5/HB8OERwAlKgqJ1cBz20ALiYhKmr+UgHAlTs8/msh8GbgQQ2QTzlw2TDEAENAFQABLS1ALgAnIAAjGBcPABECDDAKAAEPulcpGA8A+i15CS0Eg/B0YBeVkTAXzfEJBzAp0UQnJtFlwZEB0BgBOUAvNg0CAAsjRw0CESlcEDsxNnfAgAsLCgAECwQGAQEKBQAIGAcMAbJJKCAdDlu2EFCFAQwEAxZghQMjJTh/CEMeFyEqAQoGS0iOCQSQkQ0X8AwFEP+CATwQQygANAAAW0AiATU1QAI2EIMwKikkIx0ABgAaBA8NCggABRMuBSYVEyb4AgEjdl1Rqj3HdA7QeP15DjVGOVE3cDWgkJEmA9fPYCUwOsEOsV4yF4AZhIQBkBk8DRg6FApXAgKwqxNAPwYJEwADGiMbHpedAQB2CQcTJSUjsAAxL1UBEBQBCoADAxISFwgBIDQAJAkoAQEtM08AAdmlmP5EAYFALg8LSf5/cJ8CEVBg8AFbkJItAD0BsA4jAT4+QD8AADo4MAwKNjQmAB8ADgQXFi4EgAIyBRsbAhShHh4WtVKTkqhgB0gWAD49uQ4+1GDk9MLUtR3/vAATNDMyNzIXFgAVBxQHBgcGFQgUFxYAYBQDNAcgBiMiFTABeDcyADc2AVYFDxNiAAsCBTUHBQcBAAs2MQwCEjdfAD4rLwEdFBkIAAgTFS+GLAoFAAkOBQcWCAwJABYBAgMbRFOXAAICAxOddxoBAAYEARwDAhIBABodMMUxIxkJAAMDAgMGEymeAGUCNkIDARGwABwBAQEWIAAAAAH/+v/0AVQDACwAOQBcQCIBADo6QDsAMCknABINOTMyLSslACQcGxUHABAPAAQJIAIDAAEHAEZ2LzcYAD8/oAEv/TwuCAAAAgUAMTABSWi5AAcAADpJaGGwQFIAWDgRN7kAOv8gwDhZJRQA3ScmADc0NzYyNjMyAB0BFDMyPwE2QCcmJyY9AQAKNwg2FxYACgcGJyKANSY3NiYjIoAGAYKMAVRaUkcyNQACAQEUXQoKJwAfAgIBNVkJNQArLlhIKygLHQhQDQEAaA4nNTIAMjWyWGY3O14AECQVBBoxSDEAOBk0WAs+M1UAWzY7AgEzME8AYw8BAwMPFzkAFSlCNB85NTUEQjOBf/z/8wFYAAMkACEAR0AXAAEiIkAjABQSAAYEAhgJCAAeQBwCCwABGAV6PKIBDnUYACIJdSIBdVQBFIB0IoDlEwFnJgA1AzQjIjEmNUIUgH42MzYXAP0BAFcRBxcWDhUCAAskTg0BDEoQAAICBAQOfLkOAAECAqoOAQ/9AHsQAQUGARACAIUOAQ0LNCITIBoBARI+QCsAAwVAa2FAKx4AUkAdAAEfH0AgABcaABkVExEKCQAKAAAaBQ0cDw0CEAUAAQnGLDwQ/Y48Ay4DLwQuCQAfCS4aHwIuAwAsQWk1ETQANjMwMzIVFBEEAjUAajURJjMyABYBYQIZK2h1ACMYBwZrEQEpACQBDmMZAxH9AJU6LEw4JGcCAFoICw8i/uv+AOsHTk4CQBQCBUArD8BWlAMoACQAAD5AEwElJUAAJgAZDQAhAhBAAgcGAAENxCg8o4CTSCYNACVJJiVCJqQGB4AMKwHAJgNAjMMAkIBRHgEXFoDSgI4BwlUWAZEfHyUVAAMMehADFCIfABgBCgcsRRAFAAMVDwQEBAMKAAsJBgMOSCgTAAMPrNv+/oATABN/AQr4jgcMAAEVDtxEEBE+QG5kHhECBUEtAxD/9QJjQC0+AEgAQBkBPz9AQAAANCYOHQA9LixAIQQfAhcIwC4dccUuPD8XQVcBhcQvHXQAP8kvP8cvQYNBACOSImABDgHEAQIngCtQMR4BE4IZEwBEMwvAXkMbEsBiNjMWAgBgFSVDBAMMKUA4DQIQFwPgGQcADg8FDjI0DgIAHBwvEQIPaxEABigBBQQDBh4AAw8hITECDhpAAQUIAwohoIEsADsMAxOm0/6IABYRAQUFAQ6iAMcUEyeTnR8CAAYFARCkowEZAKkUAij+sgsMEGEBAhRAAIX2DwATQAEvCxMBAgIB4WPy/+8BlwMIJQA9oCEYAT4+AEA/Ai4OPDgkgB4aAjQmAhaAfTwBGoVNJGTCIaQhGgCaPqkhPmKBwJ0jIiBNw6chIQA2IyI1IoGBPA/hgWEARTzBZgcGAwYBwDyQBxEEOBIcAB8JDhwIAwQIAAcYBwEGCwp8ABcCP04GDAdkASCdCEQgEgkGHwAHBQQFDhkIFAApPhYFFW4KBgAgFhAHDgIEGwA0ZB0iLF8UAwILoGoEBJjmESJAFQEyCgoLoKYCABwUdhsQOVwbASBxEkT+8xgXegFgIPf/9wFgAy0EACoiQisrQCwpAB8pFBAOBAgEACclGQMXAgoAjAEUhSDgQS88/WltaBQAK2kgKyRCIAAXAeAZBzYnIic2Ny40YSHCoIceN0AgFRRAAV4RIywKwJ4BIAETDnUUwJ0DKQBFAg0ILjAcBAAKEggEAQcIEQAGFyE7FAMGLQBtijAJHZzaHgABAQMZqtIIFAiX0AehngIZLVYgJSUtVheBCBoFAyGJIDsBVgMmADAAAFZAIAExMUAAMgAtKxYUKRgAEhALABwEJCjABR4iAiAeob4HoLg/EP0gv0i+xqAxKRzCMSW+JgciJwAbwTr0NRPgOiPhoYEBojuBHRgHMAeBOkEBAVYOAAm9aw4BAwIFAAmBAwMDCTwsAB0CAwETImxtAB0aAgMFDoMGiAsbYiDdDAoQ4LMADRwZEA0OGQEgAd4MCgtAHBsTEB4jCRXgGwICAgAZJR81/g4dASADBQEXJKMd7wAouwMiorwZo7wHFgAEIA8NAwAEBQAcHAIUEgABFqvmkaEcF2A4AMQbFrC8IhOhGwYVA4LUFxTEFRbCezUSA8AbwJMBQFy6AQsUGAoBAAsQGgwBAgYOBlJgoqD0CEFXEwKE6g/QNRT9jQ9wGkABEwoTEgawOQIAHgFSAZ4KCAwQAgIQJDALF//0EADRAyfQU0xAGwHTUxYABB4MChoAGAUhEAUGIyHKApBICsYZEP2gXrAnxYgLCr9UWRMCcWliXkw0McBF0Bg0EzAAJ24wMAHAGmIZ0aUKMgwCMAELKg2AFUIMAwIw/q7+YmQKcgxXAQAX+BoPAQ4JEaFzDAACAArQJZewCwAgACsAS0AaAQgsLEDgMyMODCcAIRcAHRsCFRSUBAOwVhfECxc8'
	$sFileBin &= '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'
	$sFileBin &= '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'
	$sFileBin &= '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'
	$sFileBin &= 'BAcAAA5IBwBzoAqgDggGBDQBBeMLBG/gCyABAINhDgQhB0IIBoYJ4wt2AxsHSAbACRHgCw9NCOMLBgkH3+ELARJgBgMAwCoHwAChBleBCSEHQwMKgQMEdwMcVAhN4QsIgFRT4QsFb6AO4QsAFgFMBsIK6AsH5WQIBkMIBwrAAuULcQOAHghTBwcDBOALyBFYCeQLCgiDI+ML9gchC0AICMAA4KZiCCEHMSEIBwcLggN3AyAJBFgH4FQJAAASXc/iC6AO5AsAEgUHYAUBANdgG4EAYQMDYAAKowDQAR4MYAHxBb8BswEiCV2x9AUTYgrwBVENC/IFBwEP+gWQAAYGCAcE3WAACwALIgTzBQW/AbUBACQKYggIBAQKMbB2ZwoAUAXQBQsJ49ER8wUICQghBmAhgAAzgAPAAggIMQQBBAgIcAkNCQhgLr8BtQEmxApn9AUVbAvxBVAH+gz0BQagKmAFAQDyBVEKsgkxBAcMoQAyBA70BQO/AbMBKAtsCQkFwAULAAAWcvEFURMMDQrCFwAPBggICnvyBWAhCtACNQSQCSEECY4J9AW/AbUBKgty9AXIF3cM8gUNCfkFYAWTAQDyBQkJ4BIJBGAAI5EPEQQJCg9gAQUGY78BtQEsDHfxBZB6GOZ88gVQEw4LsTjwBaAwnfcFC2AA4AwxBAgOAQvJIQQKEPABBga/AbUBYC0MfAoK8gWAbVQB8JYFAAECvAKKheAAj3MAAcUAMpKEh6BtDwABAEFsdHPwZ4AgICIDaf9+8IUOaXBxk3gwAN8RUX9QXw889XAB6NECuQzJ8VJncQD/8v+CdhTxAjGNArR7EYpyBBRaKPAB8gCcnX9cEgFcrAPlsHMBAALQdkDQdgoAcG+VsAEB'
	$sFileBin = Binary(_Base64Decode($sFileBin))
	$sFileBin = Binary(_LzntDecompress($sFileBin))
	Return SetError(@error, 0, $sFileBin)
EndFunc ;==> HeadlineOneTtfFont()

Func Smurfesquexm() ; Code Generated by BinaryToAu3Kompressor.
	Local $sFileBin = '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'
	$sFileBin &= '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'
	$sFileBin &= '/bEFYZ9A6gbWcAzABQBAR3khAFdGRYWZ13KQAAWOcgC9Q8w0BO4SLwmdY86rhQCD+IdDBmqAHAACLytZPiCgBgAZ4/1AGqYAMALQQREyzh0D4AAAYKIT6wAibJoA2AB4s+nsWScAgFBGhBe78WUAahqgZTOCPSAAz1Oy7v3kXCMAgToDBSq6up8Aj02zLkMAALdACUAA2B0LgAbPADEAx99a3v8SAJ9f2s76jC75ACOrShmOAFOtkA/xIOAhLQz0WxkAfWwAI+AuT+EA/wEP4xlvsvLIVoSmEA6//lAFBwA0+QdAAPRhdJATcY8A/gK/xhjyy2AAkQnr63yd3ElmmQERAQAa5q8PsDYGANom2jrSYKbuAHzrNRLRP0SaAGP+goCnWQDcBCT6gDnkHOgYAFLYwEieYvMCgaNh7wDWOwCuTaUdQwCu7yKie4bLaCCuvlsseTEGNsoD5DzpJmCgAH+U7gBMswCOwAwlAwD6KsqPrw+1S6BB7hOtU9AB/vA7ANUr/tcrAAC/AEHi6jToGP6vAED1HuKfbAaBABEZIDJ3DLthALFkjwYp4AHwAOdInwFJymqCAEExjhFCrUEVgKoDCvMM/PiQBwBC2/cH+utWqgB/o00frisMEQAj2fCPgfCPswAc11TARu6RgQDP5UzPDiPn7gAr8O0CIQCBZAAbzy7q3PA3AwDZAKhYtA79zwBJA415vNHVOhAgq4JyQB8379oCFABDOcr9F+kxANkuy/1KtkgRAPqtMWjFxRVIAIGTIpf/TtZTAAYA8yQaBefPKErWKiBEJJIM8g4CAKAmAMb/4UfNAPcCxgkD4wboAAXX0v1UrCjbAP0G+g/xAD7CAfAFKNgx+uEUcwB+JDILp1qwU4DTEhsJwzoXABkA87p4jhl48qUATcJiv+tWAMMA+hgQG/DrASQA1vU12CjHCyIADM/Z/jXFDfMACLr/Uodb7NAAItgRJYNUNuUAsPr4PPL9IqIA/SbaABH7/fcAACkA6u0JL8sALhzo/d0/GOIAAzW/Uhje+AgA1EI46aNrKq8AMyahXdb6/zQAwzgFnWMAuSMAJPQM3xIP1v8A8Ov7ERkPzfwAFu3eMZNn94UAS+rVOuvhR48ABgvVHeNB8OIA7TFPgxoJ2gYA+gBO/L9LB/sAqlsjrTVGdWQAYXH3VQg1w+MA/x4f1CwO1Q4ADxnw7SPKHf8AIPMm76V3v+sAJuAdM77XWLMALdPsP8niKAIAyB7hPa73XdsA0DLYB9Ms9CQA6bZe3DGk6rwAtMv5JdZG+74AFsIpNtzgeb8A2Q4lzyIPK8cARfq6IQcnvR8A9AYMJNmwX+4A6A4NCenCiuMArORALQPuH+MA6VDOEhztGeIAOrkJDMAoAxUAyvoP6e3/AxYA3gn0IKJL9gAAHcIOEdg/9QIA3BDb+04B1xtQ/QPvJNSNLQsAIP4tL3gPAA8ADwAPAA8ADwAHDwAveDoAIrGwIAAAABUwIQAkAAYKCAAGHAAGQAABlpEAci0gLQsAIC0HXiD2//8AAAAEABuIAP/lAAz/AA8GG0ohGWgoAAMHARZeAa8CII8Ama+1uX6AAQ6AAQpwg7ngnbmACP7+Bv6BuS0AEOAIBALBjwX+/vz8/MAAgwAPCgBEBkEBQXMgZSBhACB0IHNhcnNhgHBhcmlsbGEDeT8BawIIFS4FCNqDYhAgMAAzNyBmb3IgdABoZSBwZW9wbAZl/yDtIHNtdXJmEGluZyDAQ2wgbxAgbiBnCwh0ICBEaCCASyAgd4AIdgVAAnMLCG9mICBwA8AOQVRzIHUgciAGZX8xCghtYWlsIBR0b8oIPgkEdGltAGVsb3JkQGNoAGVlcmZ1bC5jBG9tBQQ='
	$sFileBin = Binary(_Base64Decode($sFileBin))
	$sFileBin = Binary(_LzntDecompress($sFileBin))
	Return SetError(0, 0, $sFileBin)
EndFunc ;==> Smurfesquexm()

Func UfmodDll($sFileName, $sOutputDirPath, $iOverWrite=0) ; Code Generated by BinaryToAu3Kompressor.
	Local $sFileBin = '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'
	$sFileBin &= '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'
	$sFileBin &= 'BQdIg2YKABsCw5BHEBWFFfuAFQNQA8OJ8wBWV4t0JBAxwBAPtpYKcDGNezYASnglsIB0FkoAdA2ygCsXD7YC0jF86zeLFynCAOvxOQcZ0iHCQI1CwOsmiyAQgwDhf4P5QYPQ/xAxwSWB4TzBweoACA+2gaQVABBAGdIx0CnQcAUMJXE8r5AAhguQAIXAAHQMV5eLQzL3AOr3/5KXX8H6AAYBUxKLUzJCoDnCfgGSUAINEYsAB4lTMvbcgAsCAUAA3ACJB4tzAAL2Awh0RIN+ACwAdCeJ8SsNADRAABDB6QcZAP+D54CNfD5AAFdqC4l7AlnzAKWJTtSJTuCJAE7kXo1+LItESCQMq5ClVgiAtqsBUbdWFDHJ/sn2AAMCdEaLQwoDAEMOicLB4AgpEND3LQwQBffSIQDQPQDwDwB+BQK4YQD3Y0L3Y0YAweoDi0YEiRYEiddQC/mJRgyJQMgrRgT377EAEID2AwR0Q7+A4A9Ai0MWKfiZYQ8pAMeLQ07B/wWDAOgg9+8DQxaZAXEFiz45yInKlyRzBoID+pJAwYlWIAz20PcudAQBdABhi0sGMdIDSwASjUIofkX2BQJKIAkBdQu4kHcA2gD38THS6zEAuAASAAArQwYAA0MSUNsEJNgEDeywFtnA2fzcAOnZydnw2ejeAMHZ/d3Z2A3wAXAB2xwkWLtErIAAAPfziUYcQQDgGF9ewgigCg8ADwD/DwAPAA8ADwAPAA8ADwAPAAcPAA8AAAD0MAAAClAxAAAYMAAoMAA8VTAASDAAVjAAZDAAbFUwAHowAIYwAJgwAKitMAC4MAABAOhwAP4wAKAMMgAAJDAANDAAak4wANj0AZiwBQUAyqsxAfAA1DgBXrACPPgAP38Jfwl/CX8Jfwl7Cc4CAFdhaXRGb3JTAGluZ2xlT2JqAGVjdAAbAENsAG9zZUhhbmRsAGUASgBDcmVhEHRlVGhgAGQAACCHAlNldMMAUHIAaW9yaXR5AJkAAUhlYXBBbGwwb2MAm7IAMwMAAAKd0gBEZXN0cm8AeQCWAlNsZWUIcAA0NAVGaWxlYEEAGAJSwASxAAAMAGrRBaEAUG9pbgB0ZXIAAKMARgBpbmRSZXNvdQRyY9ACxwFMb2EB9gAAAJUCU2l6CGVvZhcBS0VSTgBFTDMyLmRsbAAAAKwAd2F2ZYhPdXRCDQAAtfUAAEdldFBvc2l0CGlvbhATAAKzAHdhdmVPdXRPQHBlbgC6AATQUAByZXBhcmVIZYBhZGVyAAC7BVwAUmVzZXQAAMBRBTxVbnALpMEFMlcAcml0ZQAAV0kATk1NLmRsbAAhCQDbMpJKAQ7yMqgAAAEABwkEA5gADwq8AAPgAAOqEAAACqYAA7oAAwARAAAKMAAHmgADFBIAACqeAAeBAAP8ACcOM6gAAB0AAysAAzoAA6pNAANZAANoAAN1AAMBAWECAAMABAAFAAAGAAcACAB1EGZtb2QCk3VGTQBPRF9HZXRSbxh3T3IBYIYIU3RhhHRzBwdUaW1liQYEdGwFB0p1bXAygFBhdHRlcm4ECRBQYXVzBQ9QbGFgeVNvbmcEBwCgdYGGJFNldFZvbIEHC3kAwFHEgQEwFDAYADAcMCAwJDAoADAsMDUwjzCUADChMK4wuzDFADDLMNswATEUADEgMSgxRTFOADFeMW0xczGHADGeMekx+zEAADIdMiwyMTI+ADJ1Mn4yhDKkADK3MsUy3zLrADLzMgMzJTM4ADM+M1gzYDNmADNsM30ziDOWADOnM7gzzjPWADPlM/Mz/DMEADRkNGs0yzTeADTlNP00OjVeADVrNXs1YDYtADc4N3U3gjecADdNOGU4zTivADq4OuE6qzvoADvKPPw8Qj3sAD31PSs+LT8AECAAANjAMHEwkwAwlzCbMJ8wowAwpzCrMK8wswQwt8AvvzDDMMdBwDDPMNMw10Ay3wAw4zDnMOsw7wAw8zD3MPsw/wAwAzEHMQsxDwAxEzG5Mr0ywQFAL8kyzTLRMtUAMtky3TLhMuUAMuky7TLxMuQAM5A0rDSwNLQANLg0vDTANMQANMg0zDTQNNQANNg03DTgNOQANOg07DTwNPQANPg0/DQANQQANQg1DDUQNRQANRg1HDUgNeMANRY2GjYeNiIANiY2KjYuNjIANjY2OjY+NkIANkY2SjZONoMAN+c3OTjMOO/4OAc5v3Y/AB8AHwAfAP8fAB8AHwAfAB8AHwAfAB8ADx8AHwAfAAMA'
	$sFileBin = Binary(_Base64Decode($sFileBin))
	$sFileBin = Binary(_LzntDecompress($sFileBin))
	If Not FileExists($sOutputDirPath) Then DirCreate($sOutputDirPath)
	If StringRight($sOutputDirPath, 1) <> '\' Then $sOutputDirPath &= '\'
	Local $sFilePath = $sOutputDirPath & $sFileName
	If FileExists($sFilePath) Then
		If $iOverWrite = 1 Then
			If Not Filedelete($sFilePath) Then Return SetError(2, 0, $sFileBin)
		Else
			Return SetError(0, 0, $sFileBin)
		EndIf
	EndIf
	Local $hFile = FileOpen($sFilePath, 16+2)
	If $hFile = -1 Then Return SetError(3, 0, $sFileBin)
	FileWrite($hFile, $sFileBin)
	FileClose($hFile)
	Return SetError(0, 0, $sFileBin)
EndFunc ;==> UfmodDll()