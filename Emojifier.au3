#include <GUIConstantsEx.au3>

Global $aDigitToWordsTable = ["zero","one","two","three","four","five","six","seven","eight","nine"]
HotKeySet("{F4}", "Emojify")
HotKeySet("^{F4}", "Terminate")

Func Emojify()
	Local $hGui = GUICreate("Emojifier", 250, 70)
	Local $idInput1 = GUICtrlCreateInput("", 10, 10, 230, 20)
	Local $idButtonOk = GUICtrlCreateButton("Emojify", 75, 40, 100, 20)
	Local $idDummyOk = GUICtrlCreateDummy()
	Local $accelKeys[1][2] = [["{ENTER}", $idDummyOk]]
    GUISetAccelerators($accelKeys)  ; Make enter key fires the gui dummy control
	GUISetState(@SW_SHOW)
	While 1
		Switch GUIGetMsg()
			Case $idButtonOk, $idDummyOk
				Local $sConverted = ""
				Local $sChar
				Local $sOg = StringLower(GUICtrlRead($idInput1))
				For $i = 0 To StringLen($sOg) - 1
					$sChar = StringMid($sOg, $i + 1, 1) 
					If StringIsAlpha($sChar) Then
						$sConverted &= ":regional_indicator_" & $sChar & ":"
						If $i < StringLen($sOg) Then
							$sConverted &= " "
						EndIf
					ElseIf $sChar = " " Then
						$sConverted &= "    "
					ElseIf StringIsDigit($sChar) Then
						$sConverted &= ":" & $aDigitToWordsTable[$sChar] & ":"
					EndIf
				Next
				ClipPut($sConverted)
				ExitLoop
			Case $GUI_EVENT_CLOSE
				ExitLoop
		EndSwitch
	WEnd
	GUIDelete()
EndFunc

Func Terminate()
    Exit 0
EndFunc 

Func Main()
	While 1
		Sleep(1000)
	WEnd
EndFunc

Main()