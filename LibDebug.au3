#include-once
#include <StringConstants.au3>

Global $_LD_Debug = True

Func _DebugOff()
	$_LD_Debug = False
EndFunc

Func _DebugOn()
	$_LD_Debug = True
EndFunc

; Consoleout
; Automatically replaces $ to variables given
; Escape $ using $$
Func c($s = "", $nl = True, $v1 = 0x0, $v2 = 0x0, $v3 = 0x0, _
							$v4 = 0x0, $v5 = 0x0, $v6 = 0x0, _
							$v7 = 0x0, $v8 = 0x0, $v9 = 0x0, $v10 = 0x0)
	If Not $_LD_Debug Then
		Return
	EndIf
	If @NumParams > 2 Then
		$s = StringReplace($s, "$$", "@PH@")
		$s = StringReplace($s, "$", "@PH2@")
		For $i = 1 To @NumParams - 2
			$s = StringReplace($s, "@PH2@", Eval("v" & $i), 1)
			If @extended = 0 Then ExitLoop
		Next
		$s = StringReplace($s, "@PH@", "$")
	EndIf
	If $nl Then
		$s &= @CRLF
	EndIf
	ConsoleWrite($s)
	If @NumParams = 1 Then
		Return $s
	EndIf
EndFunc	

; Insert variable
; Returns a string with all given variables inserted into
Func iv($s = "", $v1 = 0x0, $v2 = 0x0, $v3 = 0x0, _
				$v4 = 0x0, $v5 = 0x0, $v6 = 0x0, _
				$v7 = 0x0, $v8 = 0x0, $v9 = 0x0, $v10 = 0x0)
	If @NumParams > 1 Then
		$s = StringReplace($s, "$$", "@PH@")
		$s = StringReplace($s, "$", "@PH2@")
		For $i = 1 To @NumParams - 1
			$s = StringReplace($s, "@PH2@", Eval("v" & $i), 1)
			If @extended = 0 Then ExitLoop
		Next
		$s = StringReplace($s, "@PH@", "$")
	EndIf
	Return $s
EndFunc

; Consoleout Line
Func cl()
	If Not $_LD_Debug Then
		Return
	EndIf
	ConsoleWrite(@CRLF)
EndFunc

; Consoleout Variable
; Only accepts the name of variable without the $ as string
Func cv($nl = True, $v1 = 0x0, $v2 = 0x0, $v3 = 0x0, $v4 = 0x0, $v5 = 0x0, _
						$v6 = 0x0, $v7 = 0x0, $v8 = 0x0, $v9 = 0x0, $v10 = 0x0)
	If Not $_LD_Debug Then
		Return
	EndIf
	Local $s = ""
	For $i = 1 To @NumParams - 1
		$s &= "$" & Eval("v" & $i) & " = " & Eval(Eval("v" & $i))
		If $i < @NumParams - 1 Then
			$s &= " | "
		EndIf
	Next
	If $nl Then
		$s &= @CRLF
	EndIf
	ConsoleWrite($s)
EndFunc

; Consoleout Array
Func ca($a = [], $nl = True)
	Local $s = "["
	Switch UBound($a, 0)
		Case 1
			For $i = 0 To UBound($a) - 1
				If IsString($a[$i]) Then
					$s &= '"'
				EndIf
				$s &= $a[$i]
				If IsString($a[$i]) Then
					$s &= '"'
				EndIf
				If $i < UBound($a) - 1 Then
					$s &= ", "
				EndIf
			Next
		Case 2
			For $i = 0 To UBound($a, 1) - 1
				$s &= "["
				For $j = 0 To UBound($a, 2) - 1
					If IsString($a[$i]) Then
						$s &= '"'
					EndIf
					$s &= $a[$i][$j]
					If IsString($a[$i]) Then
						$s &= '"'
					EndIf
					If $j < UBound($a, 2) - 1 Then
						$s &= ", "
					EndIf
				Next
				$s &= "]"
				If $i < UBound($a, 1) -1 Then
					$s &= ", "
				EndIf
			Next
	EndSwitch
	$s &= "]"
	If $nl Then
		$s &= @CRLF
	EndIf
	ConsoleWrite($s)
EndFunc

; Consoleout Error
Func ce($nl = True)
	$nl ? ConsoleWrite(@ERROR & @CRLF) : ConsoleWrite(@ERROR)
EndFunc