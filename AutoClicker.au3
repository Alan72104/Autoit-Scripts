#RequireAdmin
#include <AutoItConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include "LibRealisticDelay.au3"

Global $g_bPaused = False
Global $delayTime = 500
Global $mouseClickActive = False
Global $mouseClickStatus = "Off"
Global $mouseClickButton = "left"
Global $customSendActive = False
Global $customSendStatus = "Off"
Global $customSendButton = "{SPACE}"
Global $hTimer = TimerInit()
Global $rand, $rand2, $rand3
Global $tooltipMsg[3]
$tooltipMsg[0] = "                  AutoClicker Running. F7 to End."
$tooltipMsg[1] = "AutoClicker Initializing"
$tooltipMsg[2] = "By Alan72104"
Global $tooltipScreenW = @desktopwidth
Global $tooltipScreenH = 0
HotKeySet("{F7}", "Terminate")
HotKeySet("{F8}", "TogglePause")
HotKeySet("{F9}", "ChangeMouseStatus")
HotKeySet("^{F9}", "ChangemouseClickButton")
HotKeySet("{F10}", "ChangeSendStatus")
HotKeySet("^{F10}", "ChangeSendButton")
HotKeySet("\", "IncreaseDelayTime")
HotKeySet("^\", "DecreaseDelayTime")

; ==================================================
; Options
; ==================================================

Global $realisticDelayModeEnable = False
Opt("SendKeyDownDelay", 50)

; ==================================================
; Various function parts
; ==================================================

Func ChangeMouseStatus() 
	$mouseClickActive = Not $mouseClickActive
	$customSendActive = False
	$customSendStatus = "Off"
	If $mouseClickActive Then
		$mouseClickStatus = "On"
	Else
		$mouseClickStatus = "Off"
	EndIf
	UpdateTooltip()
EndFunc

Func ChangemouseClickButton()
	If $mouseClickButton == "left" Then
		$mouseClickButton = "right"
	ElseIf $mouseClickButton == "right" Then
		$mouseClickButton = "left"
	EndIf
	UpdateTooltip()
EndFunc

Func ChangeSendStatus()
	$customSendActive = Not $customSendActive
	$mouseClickActive = False
	$mouseClickStatus = "Off"
	If $customSendActive Then
		$customSendStatus = "On"
	Else
		$customSendStatus = "Off"
	EndIf
	UpdateTooltip()
EndFunc

Func ChangeSendButton()
	$gui = GUICreate("Select custom key",220,170)
	$combo2 = GUICtrlCreateCombo("",10,10,200,30)
	GUICtrlSetData(-1,"{TAB}|{UP}|{DOWN}|{LEFT}|{RIGHT}|{ENTER}|{NUMPADENTER}|{LSHIFT}|{RSHIFT}|{LCTRL}|{RCTRL}|{LALT}|{RALT}|{LWIN}|{RWIN}|{BACKSPACE}|{DELETE}|{HOME}|{END}|{INSERT}|{PGUP}|{PGDN}|{PRINTSCREEN}") ;|{a}|{b}|{c}|{d}|{e}|{f}|{g}|{h}|{i}|{j}|{k}|{l}|{m}|{n}|{o}|{p}|{q}|{r}|{s}|{t}|{u}|{v}|{w}|{x}|{y}|{z}
	GUICtrlCreateLabel("Select or a type a key to autotype.",10,60,200,30,$SS_CENTER)
	GUICtrlCreateLabel("If you need help finding the key,",10,70,200,30,$SS_CENTER)
	$hyperlink = GUICtrlCreateLabel("Click this!",10,80,200,30,$SS_CENTER)
	GUICtrlCreateLabel("AutoClicker by Alan72104.",10,150,200,30,$SS_CENTER)
	$button = GUICtrlCreateButton("Done",10,36,200,20)
	GUISetState()
	While 1
		$msg = GUIGetMsg()
		Switch $msg
			Case $GUI_EVENT_CLOSE
				GUIDelete($gui)
				ExitLoop
			Case $button
				$customSendButton = GUICtrlRead($combo2)
				GUIDelete($gui)
				ExitLoop
		EndSwitch
	WEnd
	UpdateTooltip()
EndFunc

Func IncreaseDelayTime()
	$delayTime += 50
	UpdateTooltip()
EndFunc

Func DecreaseDelayTime()
	If $delayTime > 50 Then  ; Negative dalay time?
		$delayTime -= 50
	EndIf
	UpdateTooltip()
EndFunc

Func UpdateTooltip()
	$tooltipMsg[1] = "F9/F10 to change status. - M/K: " & $mouseClickButton & "/" & $customSendButton & " " & $mouseClickStatus & "/" & $customSendStatus
	$tooltipMsg[2] = '                "\" to change delay time. - ' & $delayTime & "ms"
EndFunc

Func Terminate()
	Tooltip("")
    Exit 0
EndFunc 

Func TogglePause()
    $g_bPaused = Not $g_bPaused
    While $g_bPaused
        Sleep(500)
        ToolTip('Script is "Paused"', 960, 540)
    WEnd
    ToolTip("")
EndFunc

; ==================================================
; Main part
; ==================================================

Func Main()
	UpdateTooltip()
	While 1
		If TimerDiff($hTimer) >= 1000 Then    ; Only draw tooltip again after 1 second or more
			ToolTip($tooltipMsg[0] & @CRLF & $tooltipMsg[1] & @CRLF & $tooltipMsg[2], $tooltipScreenW - 300, $tooltipScreenH + 10)
			$hTimer = TimerInit()
		EndIf
		If $mouseClickActive Then MouseClick($mouseClickButton)
		If $customSendActive Then Send($customSendButton)
		If $realisticDelayModeEnable Then
			sleep(_RealisticDelayType1($delayTime, Default, Default, 8))
		Else
			Sleep($delayTime)
		EndIf
	WEnd
EndFunc

Main()