#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Change2CUI=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
Global $0[11]
Global Const $1 = "struct;uint Mask;int Item;int SubItem;uint State;uint StateMask;ptr Text;int TextMax;int Image;lparam Param;" & "int Indent;int GroupID;uint Columns;ptr pColumns;ptr piColFmt;int iGroup;endstruct"
#Au3Stripper_Ignore_Funcs=__ArrayDisplay_SortCallBack
Func __ArrayDisplay_SortCallBack($2, $3, $4)
If $0[3] = $0[4] Then
If Not $0[7] Then
$0[5] *= -1
$0[7] = 1
EndIf
Else
$0[7] = 1
EndIf
$0[6] = $0[3]
Local $5 = _a($4, $2, $0[3])
Local $6 = _a($4, $3, $0[3])
If $0[8] = 1 Then
If(StringIsFloat($5) Or StringIsInt($5)) Then $5 = Number($5)
If(StringIsFloat($6) Or StringIsInt($6)) Then $6 = Number($6)
EndIf
Local $7
If $0[8] < 2 Then
$7 = 0
If $5 < $6 Then
$7 = -1
ElseIf $5 > $6 Then
$7 = 1
EndIf
Else
$7 = DllCall('shlwapi.dll', 'int', 'StrCmpLogicalW', 'wstr', $5, 'wstr', $6)[0]
EndIf
$7 = $7 * $0[5]
Return $7
EndFunc
Func _a($4, $8, $9 = 0)
Local $a = DllStructCreate("wchar Text[4096]")
Local $b = DllStructGetPtr($a)
Local $c = DllStructCreate($1)
DllStructSetData($c, "SubItem", $9)
DllStructSetData($c, "TextMax", 4096)
DllStructSetData($c, "Text", $b)
If IsHWnd($4) Then
DllCall("user32.dll", "lresult", "SendMessageW", "hwnd", $4, "uint", 0x1073, "wparam", $8, "struct*", $c)
Else
Local $d = DllStructGetPtr($c)
GUICtrlSendMsg($4, 0x1073, $8, $d)
EndIf
Return DllStructGetData($a, "Text")
EndFunc
Func _n(Const ByRef $e, $f, $g = 0, $h = 0, $i = 0, $j = 0, $9 = 0, $k = False)
If $g = Default Then $g = 0
If $h = Default Then $h = 0
If $i = Default Then $i = 0
If $j = Default Then $j = 0
If $9 = Default Then $9 = 0
If $k = Default Then $k = False
$g = _x($e, $f, $g, $h, $i, $j, 1, $9, $k)
If @error Then Return SetError(@error, 0, -1)
Local $8 = 0, $l[UBound($e,($k ? 2 : 1))]
Do
$l[$8] = $g
$8 += 1
$g = _x($e, $f, $g + 1, $h, $i, $j, 1, $9, $k)
Until @error
ReDim $l[$8]
Return $l
EndFunc
Func _x(Const ByRef $e, $f, $g = 0, $h = 0, $i = 0, $j = 0, $m = 1, $9 = -1, $k = False)
If $g = Default Then $g = 0
If $h = Default Then $h = 0
If $i = Default Then $i = 0
If $j = Default Then $j = 0
If $m = Default Then $m = 1
If $9 = Default Then $9 = -1
If $k = Default Then $k = False
If Not IsArray($e) Then Return SetError(1, 0, -1)
Local $n = UBound($e) - 1
If $n = -1 Then Return SetError(3, 0, -1)
Local $o = UBound($e, 2) - 1
Local $p = False
If $j = 2 Then
$j = 0
$p = True
EndIf
If $k Then
If UBound($e, 0) = 1 Then Return SetError(5, 0, -1)
If $h < 1 Or $h > $o Then $h = $o
If $g < 0 Then $g = 0
If $g > $h Then Return SetError(4, 0, -1)
Else
If $h < 1 Or $h > $n Then $h = $n
If $g < 0 Then $g = 0
If $g > $h Then Return SetError(4, 0, -1)
EndIf
Local $q = 1
If Not $m Then
Local $r = $g
$g = $h
$h = $r
$q = -1
EndIf
Switch UBound($e, 0)
Case 1
If Not $j Then
If Not $i Then
For $s = $g To $h Step $q
If $p And VarGetType($e[$s]) <> VarGetType($f) Then ContinueLoop
If $e[$s] = $f Then Return $s
Next
Else
For $s = $g To $h Step $q
If $p And VarGetType($e[$s]) <> VarGetType($f) Then ContinueLoop
If $e[$s] == $f Then Return $s
Next
EndIf
Else
For $s = $g To $h Step $q
If $j = 3 Then
If StringRegExp($e[$s], $f) Then Return $s
Else
If StringInStr($e[$s], $f, $i) > 0 Then Return $s
EndIf
Next
EndIf
Case 2
Local $t
If $k Then
$t = $n
If $9 > $t Then $9 = $t
If $9 < 0 Then
$9 = 0
Else
$t = $9
EndIf
Else
$t = $o
If $9 > $t Then $9 = $t
If $9 < 0 Then
$9 = 0
Else
$t = $9
EndIf
EndIf
For $u = $9 To $t
If Not $j Then
If Not $i Then
For $s = $g To $h Step $q
If $k Then
If $p And VarGetType($e[$u][$s]) <> VarGetType($f) Then ContinueLoop
If $e[$u][$s] = $f Then Return $s
Else
If $p And VarGetType($e[$s][$u]) <> VarGetType($f) Then ContinueLoop
If $e[$s][$u] = $f Then Return $s
EndIf
Next
Else
For $s = $g To $h Step $q
If $k Then
If $p And VarGetType($e[$u][$s]) <> VarGetType($f) Then ContinueLoop
If $e[$u][$s] == $f Then Return $s
Else
If $p And VarGetType($e[$s][$u]) <> VarGetType($f) Then ContinueLoop
If $e[$s][$u] == $f Then Return $s
EndIf
Next
EndIf
Else
For $s = $g To $h Step $q
If $j = 3 Then
If $k Then
If StringRegExp($e[$u][$s], $f) Then Return $s
Else
If StringRegExp($e[$s][$u], $f) Then Return $s
EndIf
Else
If $k Then
If StringInStr($e[$u][$s], $f, $i) > 0 Then Return $s
Else
If StringInStr($e[$s][$u], $f, $i) > 0 Then Return $s
EndIf
EndIf
Next
EndIf
Next
Case Else
Return SetError(2, 0, -1)
EndSwitch
Return SetError(6, 0, -1)
EndFunc
Func _1r($v, Const ByRef $e, $w = Default, $x = Default, $y = "|")
Local $0z = 0
If Not IsArray($e) Then Return SetError(2, 0, $0z)
Local $10 = UBound($e, 0)
If $10 > 2 Then Return SetError(4, 0, 0)
Local $11 = UBound($e) - 1
If $x = Default Or $x > $11 Then $x = $11
If $w < 0 Or $w = Default Then $w = 0
If $w > $x Then Return SetError(5, 0, $0z)
If $y = Default Then $y = "|"
Local $12 = $v
If IsString($v) Then
$12 = FileOpen($v, 2)
If $12 = -1 Then Return SetError(1, 0, $0z)
EndIf
Local $13 = 0
$0z = 1
Switch $10
Case 1
For $s = $w To $x
If Not FileWrite($12, $e[$s] & @CRLF) Then
$13 = 3
$0z = 0
ExitLoop
EndIf
Next
Case 2
Local $14 = ""
For $s = $w To $x
$14 = $e[$s][0]
For $u = 1 To UBound($e, 2) - 1
$14 &= $y & $e[$s][$u]
Next
If Not FileWrite($12, $14 & @CRLF) Then
$13 = 3
$0z = 0
ExitLoop
EndIf
Next
EndSwitch
If IsString($v) Then FileClose($12)
Return SetError($13, 0, $0z)
EndFunc
Global $15 = True
Func _22($16 = "", $17 = True, $v1 = 0x0, $v2 = 0x0, $v3 = 0x0, _
							$v4 = 0x0, $v5 = 0x0, $v6 = 0x0, _
							$v7 = 0x0, $v8 = 0x0, $v9 = 0x0, $v10 = 0x0)
If Not $15 Then
Return
EndIf
If @NumParams > 2 Then
$16 = StringReplace($16, "$$", "@PH@")
$16 = StringReplace($16, "$", "@PH2@")
For $s = 1 To @NumParams - 2
$16 = StringReplace($16, "@PH2@", Eval("v" & $s), 1)
If @extended = 0 Then ExitLoop
Next
$16 = StringReplace($16, "@PH@", "$")
$16 = StringReplace($16, "@PH2@", "$")
EndIf
If $17 Then
ConsoleWrite($16 & @CRLF)
Else
ConsoleWrite($16)
EndIf
If @NumParams = 1 Then
Return $16
EndIf
EndFunc
Func _23($16 = "", $v1 = 0x0, $v2 = 0x0, $v3 = 0x0, _
							$v4 = 0x0, $v5 = 0x0, $v6 = 0x0, _
							$v7 = 0x0, $v8 = 0x0, $v9 = 0x0, $v10 = 0x0)
If @NumParams > 1 Then
$16 = StringReplace($16, "$$", "@PH@")
$16 = StringReplace($16, "$", "@PH2@")
For $s = 1 To @NumParams - 1
$16 = StringReplace($16, "@PH2@", Eval("v" & $s), 1)
If @extended = 0 Then ExitLoop
Next
$16 = StringReplace($16, "@PH@", "$")
EndIf
Return $16
EndFunc
Global $s = 0
Global $1j = 0
Global $1k = 0
Global $1l = 0
Global Const $1m[10] = [46,37,29,22,16,11,7,4,2,1]
Global $1n
If $cmdline[0] > 0 Then
Global Const $1o = $cmdline[1]
Else
Global Const $1o = 1000
EndIf
Global $1p[$1o]
Global Const $1q[10] = [10,15,15,8,2,14,12,10,8,6]
Global $1r[18] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
Global $1s = 0
Global Const $1t[UBound($1q)] = ["$10000","Supply Crate","Mega Crate","Spawner Crate","Cosmetic Crate", "Mystery Box 1*","Mystery Box 2*","Mystery Box 3*","Mystery Box 4*","Mystery Box 5*"]
HotKeySet("{F7}", "_2f")
HotKeySet("{F8}", "_2d")
Func _28(ByRef $1u, $1v)
ReDim $1u[UBound($1u) + 1]
$1u[UBound($1u) - 1] = $1v
EndFunc
Func _29()
Local $1w[0]
Do
For $s= 0 To UBound($1q) - 1
If Random(1, 100, 1) <= $1q[$s] Then
_28($1w, $s)
EndIf
Next
Until UBound($1w) > 0
Return $1w[Random(0, UBound($1w) - 1, 1)]
EndFunc
Func _2a()
For $s = 0 To 17
$1r[$s] = _29()
Next
EndFunc
Func _2b(ByRef $1x)
_2a()
$s = 0
$1j = Random(42, 68, 1)
$1k = 0
$1l = 0
While 1
If $s > 17 Then $s = 0
If $1k < $1j Then
$1y = $s
$s += 1
EndIf
If $1k >= $1j Then
If _x($1m, $1l) > -1 Then
$1y = $s
$s += 1
EndIf
If $1k = $1j + 47 Then
EndIf
If $1k >= $1j + 55 + 47 Then
$1p[$1x] = $1r[$1y]
ExitLoop
EndIf
$1l += 1
EndIf
$1k += 1
WEnd
EndFunc
Func _2c(ByRef $1s)
_22("Result of $ times running:", 1, $1s)
For $s = 0 To UBound($1q) - 1
Local $1z = UBound(_n($1p, $s, 0, $1s))
_22("Reward [$] - Count: $ Percentage: $", 1, $1t[$s], $1z, Round($1z / $1s * 100, 1))
Next
EndFunc
Func _2d()
_2c($1s)
_22("Sleeping for 5000 ms")
Sleep(5000)
_22("Running")
EndFunc
Func _2e()
For $s = 0 To $1o - 1
$1n = TimerInit()
_2b($s)
_22("$ times completed, took $ ms", 1, $s + 1, TimerDiff($1n))
$1s += 1
Next
_22("all completed")
_2c($1s)
_22("press F7 to terminate and save the result to rewards.batch.txt")
While 1
Sleep(1000)
WEnd
EndFunc
_2e()
Func _2f()
_28($1p, _23("Result of $ times running:", $1s))
For $s = 0 To UBound($1q) - 1
Local $1z = UBound(_n($1p, $s, 0, $1s))
_28($1p, _23("Reward [$] - Count: $ Percentage: $", $1t[$s], $1z, Round($1z / $1s * 100, 1)))
Next
_1r(@ScriptDir & "\rewards.batch.txt", $1p)
Exit 0
EndFunc
