#include <GDIPlus.au3>
#include <GUIConstantsEx.au3>
#include <AutoItConstants.au3>

; ================================================================================================================== ;
; __/\\\\\\\\\\\\\\\__/\\\\\\\\\\\\\\\__/\\\\\\\\\\\\\\\____/\\\\\\\\\______/\\\\\\\\\\\_____/\\\\\\\\\\\___________ ;
; __\///////\\\/////__\/\\\///////////__\///////\\\/////___/\\\///////\\\___\/////\\\///____/\\\/////////\\\________ ;
; _________\/\\\_______\/\\\___________________\/\\\_______\/\\\_____\/\\\_______\/\\\______\//\\\______\///________ ;
; __________\/\\\_______\/\\\\\\\\\\\___________\/\\\_______\/\\\\\\\\\\\/________\/\\\_______\////\\\______________ ;
; ___________\/\\\_______\/\\\///////____________\/\\\_______\/\\\//////\\\________\/\\\__________\////\\\__________ ;
; ____________\/\\\_______\/\\\___________________\/\\\_______\/\\\____\//\\\_______\/\\\_____________\////\\\______ ;
; _____________\/\\\_______\/\\\___________________\/\\\_______\/\\\_____\//\\\______\/\\\______/\\\______\//\\\____ ;
; ______________\/\\\_______\/\\\\\\\\\\\\\\\_______\/\\\_______\/\\\______\//\\\__/\\\\\\\\\\\_\///\\\\\\\\\\\/____ ;
; _______________\///________\///////////////________\///________\///________\///__\///////////____\///////////_____ ;
; ================================================================================================================== ;

Global $g_bPaused = False
Global Const $debug = True
Global Const $height = 22
Global Const $width = 10
Global Const $scale = 32
Global Const $offsetBoard = [10, 10]
Global Const $offsetNextPiece = [10, 10]
Global Const $offsetScore = []
Global Const $offsetHelp = 0
Global Const $bgColor = 0x309DDB
Global $hGui
Global $hGraphics
Global $hBrush[8]
Global Enum $enumBrushGray, $enumBrushLightBlue, $enumBrushBlue, $enumBrushOrange, $enumBrushYellow, $enumBrushGreen, $enumBrushPurple, $enumBrushRed
Global $hPen[2]
Global Enum $enumPenGuiFrame, $enumPenBoardFrame
Global $board[1]
Global $piece[5] = [False, 0, 0, 0, 0]
Global Enum $enumPieceFalling, $enumPieceType, $enumPieceX, $enumPieceY, $enumPieceRotation
Global Const $pieces = [ _
	[[4,0,0,0],[0,0,0,0],[1,1,1,1],[0,0,0,0],[0,0,0,0]], _  ; 0
	[[3,0,0],  [1,0,0],  [1,1,1],  [0,0,0]], _              ; 1
	[[3,0,0],  [0,0,1],  [1,1,1],  [0,0,0]], _              ; 2
	[[2,0],    [1,1],    [1,1]], _                          ; 3
	[[3,0,0],  [0,1,1],  [1,1,0],  [0,0,0]], _              ; 4
	[[3,0,0],  [0,1,0],  [1,1,1],  [0,0,0]], _              ; 5
	[[3,0,0],  [1,1,0],  [0,1,1],  [0,0,0]]]                ; 6
Global $aPiece[1][1]
Global $aPieceRotatingPH[1][1]
HotKeySet("{F6}", "TogglePause")
HotKeySet("{F7}", "Terminate")
HotKeySet("{UP}", "PieceTryRotate")
HotKeySet("{LEFT}", "PieceTryGoLeft")
HotKeySet("{RIGHT}", "PieceTryGoRight")
HotKeySet("{DOWN}", "PieceTryGoDown")

; ==================================================
; Various function parts
; ==================================================

Func BrushInit()
	$hBrush[$enumBrushGray] = _GDIPlus_BrushCreateSolid(0xFF303030)       ; 0
	$hBrush[$enumBrushLightBlue] = _GDIPlus_BrushCreateSolid(0xFF00F0F0)  ; 1
	$hBrush[$enumBrushBlue] = _GDIPlus_BrushCreateSolid(0xFF0000F0)       ; 2
	$hBrush[$enumBrushOrange] = _GDIPlus_BrushCreateSolid(0xFFF0A000)     ; 3
	$hBrush[$enumBrushYellow] = _GDIPlus_BrushCreateSolid(0xFFF0F000)     ; 4
	$hBrush[$enumBrushGreen] = _GDIPlus_BrushCreateSolid(0xFF00F000)      ; 5
	$hBrush[$enumBrushPurple] = _GDIPlus_BrushCreateSolid(0xFFA000F0)     ; 6
	$hBrush[$enumBrushRed] = _GDIPlus_BrushCreateSolid(0xFFF00000)        ; 7
EndFunc

Func PenInit()
	$hPen[$enumPenGuiFrame] = _GDIPlus_PenCreate(0xFF008080 , 3)  ; Width = 3
	$hPen[$enumPenBoardFrame] = _GDIPlus_PenCreate(0xFF000000, 3)  ; Width = 3
EndFunc

Func DrawBoard()
	If $debug Then ConsoleWrite("[BOARD] Drawing board" & @CRLF)
	For $y = 0 To $height - 1
		For $x = 0 To $width - 1
			DrawBlock($x, $y, $board[$y * $width + $x])
			; _GDIPlus_GraphicsFillRect($hGraphics, $x * $scale, $y * $scale, $scale, $scale, $hBrush[$board[$y * $width + $x]])
		Next
	Next
	If $debug Then ConsoleWrite("[BOARD] Drawing board | SUCCESS" & @CRLF)
EndFunc

Func DrawPiece()
	If $debug Then ConsoleWrite("[BOARD] Drawing piece" & @CRLF)
	If $piece[$enumPieceFalling] Then  ; Do draw if piece is falling
		Local $l = $pieces[$piece[$enumPieceType]][0][0]  ; Piece side length
		For $y = 0 To $l - 1
			For $x = 0 To $l - 1
				If $aPiece[$y][$x] <> 0 Then  ; Do draw only when the block isn't empty
					DrawBlock($piece[$enumPieceX] + $x, $piece[$enumPieceY] + $y, $piece[$enumPieceType] + 1)
					If $debug Then ConsoleWrite("[BOARD] Drawing piece | SUCCESS PIECE: $aPiece[" & $y & "][" & $x & "] COLOR: " & $piece[$enumPieceType] + 1 & @CRLF)
				EndIf
			Next
		Next
	EndIf
EndFunc

Func DrawGuiFrame()
	Local $guiSize = WinGetClientSize($hGui)
	_GDIPlus_GraphicsDrawLine($hGraphics, 1, 1, $guiSize[0] - 1, 1, $hPen[$enumPenGuiFrame])
	_GDIPlus_GraphicsDrawLine($hGraphics, 1, 1, 1, $guiSize[0] - 1, $hPen[$enumPenGuiFrame])
	_GDIPlus_GraphicsDrawLine($hGraphics, $guiSize[0] - 1, 1, $guiSize[0] - 1, 1, $hPen[$enumPenGuiFrame])
	_GDIPlus_GraphicsDrawLine($hGraphics, 1, $guiSize[1] - 1, $guiSize[0] - 1, $guiSize[1] - 1, $hPen[$enumPenGuiFrame])
EndFunc

Func DrawBoardFrame()
	For $c = 0 To $width
		_GDIPlus_GraphicsDrawLine($hGraphics, $offsetBoard[0] + $c * ($scale + 3) + 1, $offsetBoard[1] + 1, $offsetBoard[0] + $c * ($scale + 3) + 1, $offsetBoard[1] + $height * ($scale + 3) + 1, $hPen[$enumPenBoardFrame])
	Next
	For $r = 0 To $height
		_GDIPlus_GraphicsDrawLine($hGraphics, $offsetBoard[0] + 1, $offsetBoard[1] + $r * ($scale + 3) + 1, $offsetBoard[0] + $width * ($scale + 3) + 1, $offsetBoard[1] + $r * ($scale + 3) + 1, $hPen[$enumPenBoardFrame])
	Next
EndFunc

Func DrawBlock($blockX, $blockY, $color)
	_GDIPlus_GraphicsFillRect($hGraphics, $offsetBoard[0] + 3 * ($blockX + 1) + $blockX * $scale, _  ; <== Drawing X pos
		$offsetBoard[1] + 3 * ($blockY + 1) + $blockY * $scale, _  ; <== Drawing Y pos
		$scale, $scale, $hBrush[$color])
EndFunc

Func PieceTryRotate()
	If $debug Then ConsoleWrite("[PIECE] Trying to rotate CURRENT: " & $piece[$enumPieceRotation] & @CRLF)
	If $piece[$enumPieceRotation] < 3 Then
		Local $phPieceRotation = $piece[$enumPieceRotation] + 1
		RotatePiece($piece[$enumPieceType], $phPieceRotation, 1)
		If Not CheckCollision($piece[$enumPieceX], $piece[$enumPieceY], 1) Then
			$piece[$enumPieceRotation] += 1
			RotatePiece($piece[$enumPieceType], $phPieceRotation)
			If $debug Then ConsoleWrite("[PIECE] Trying to rotate SUCCESS NEW: " & $piece[$enumPieceRotation] & @CRLF)
		EndIf
	Else
		RotatePiece($piece[$enumPieceType], 0, 1)
		If Not CheckCollision($piece[$enumPieceX], $piece[$enumPieceY], 1) Then
			$piece[$enumPieceRotation] = 0
			RotatePiece($piece[$enumPieceType], 0)
			If $debug Then ConsoleWrite("[PIECE] Trying to rotate SUCCESS NEW: " & $piece[$enumPieceRotation] & @CRLF)
		EndIf
	EndIf
EndFunc

Func PieceTryGoLeft()
	If $debug Then ConsoleWrite("[PIECE] Trying to go left" & @CRLF)
	If Not CheckCollision($piece[$enumPieceX] - 1, $piece[$enumPieceY]) Then
		$piece[$enumPieceX] -= 1
		If $debug Then ConsoleWrite("[PIECE] Trying to go left | SUCCESS" & @CRLF)
	EndIf
EndFunc

Func PieceTryGoRight()
	If $debug Then ConsoleWrite("[PIECE] Trying to go right" & @CRLF)
	If Not CheckCollision($piece[$enumPieceX] + 1, $piece[$enumPieceY]) Then
		$piece[$enumPieceX] += 1
		If $debug Then ConsoleWrite("[PIECE] Trying to go right | SUCCESS" & @CRLF)
	EndIf
EndFunc

Func PieceTryGoDown()
	If $debug Then ConsoleWrite("[PIECE] Trying to go down" & @CRLF)
	If Not CheckCollision($piece[$enumPieceX], $piece[$enumPieceY] + 1) Then
		$piece[$enumPieceY] += 1
		If $debug Then ConsoleWrite("[PIECE] Trying to go down | SUCCESS" & @CRLF)
	Else
		SetPieceDropped()
	EndIf
EndFunc

Func GenerateNewPiece($pieceType = -1)
	If $debug Then ConsoleWrite("[MAIN] Generating new piece" & @CRLF)
	$piece[$enumPieceFalling] = True
	If $pieceType = -1 Then $piece[$enumPieceType] = Random(0, 6, 1)
	$piece[$enumPieceX] = 0
	$piece[$enumPieceY] = 0
	$piece[$enumPieceRotation] = 0
	SetPieceArray($piece[$enumPieceType])
	SetPieceArray($piece[$enumPieceType], 1)
	If $debug Then ConsoleWrite("[MAIN] Generated new piece | PIECETYPE: " & $piece[$enumPieceType] & @CRLF)
EndFunc

Func SetPieceArray(ByRef $pieceType, $isTryingToRotate = 0)
	Local $l = $pieces[$pieceType][0][0]
	If $isTryingToRotate Then
		ReDim $aPieceRotatingPH[$l][$l]
		For $y = 0 To $l - 1
			For $x = 0 To $l - 1
				$aPieceRotatingPH[$y][$x] = $pieces[$pieceType][$y + 1][$x]
			Next
		Next
	Else
		ReDim $aPiece[$l][$l]
		For $y = 0 To $l - 1
			For $x = 0 To $l - 1
				$aPiece[$y][$x] = $pieces[$pieceType][$y + 1][$x]
			Next
		Next
	EndIf
EndFunc

Func SetPieceDropped()
	If $debug Then ConsoleWrite("[PIECE] Setting dropped" & @CRLF)
	$piece[$enumPieceFalling] = False
	Local $l = $pieces[$enumPieceType][0][0]
	Local $boardPos = 0
	For $y = 0 To $l - 1
		For $x = 0 To $l - 1
			ConsoleWrite("[PIECE] Setting dropped | CHECKING PIECE: $aPiece["& $y & "][" & $x & "]" & @CRLF)
			If $aPiece[$y][$x] <> 0 Then
				$boardPos = ($piece[$enumPieceY] + $y) * $width + $piece[$enumPieceX] + $x
				$board[$boardPos] = $piece[$enumPieceType] + 1
				If $debug Then ConsoleWrite("[PIECE] Setting dropped | SUCCESS PIECE: $aPiece["& $y & "][" & $x & "] TO BOARD: $board[" & $boardPos & "]" & @CRLF)
			EndIf
		Next
	Next
	If $debug Then ConsoleWrite("[PIECE] Setting dropped | SUCCESS ALL" & @CRLF)
	RemoveFullLines()
EndFunc

Func RemoveFullLines()
	If $debug Then ConsoleWrite("[PIECE] Removing full lines" & @CRLF)
	Local $numFullLines = 0
	Local $lineIsFull = True
	For $y = $height - 1 To 0 Step -1
		$lineIsFull = True 
		For $x = 0 To $width - 1
			If $board[$y * $width + $x] = 0 Then $lineIsFull = False
			ExitLoop
		Next
		If $lineIsFull Then
			For $x = 0 To $width - 1
				If $y = 0 Then
					$board[$y * $width + $x] = 0
				Else
					$board[$y * $width + $x] = $board[($y - 1) * $width + $x]
				EndIf
			Next
			If $debug Then ConsoleWrite("[PIECE] Removing full lines | SUCCESS LINE: " & $y + 1 & @CRLF)
		EndIf
	Next
EndFunc

Func RotatePiece(ByRef $pieceType, $rotation, $isTryingToRotate = 0)
	Local $l = $pieces[$pieceType][0][0]
	If $isTryingToRotate Then
		Switch $rotation
			Case 0
				SetPieceArray($pieceType, 1)
			Case 1  ; Rotate clockwise
				For $y = 0 To $l - 1
					For $x = 0 To $l - 1
						$aPieceRotatingPH[$x][$l - 1 - $y] = $pieces[$pieceType][$y + 1][$x]
					Next
				Next
			Case 2  ; Rotate clockwise twice
				For $y = 0 To $l - 1
					For $x = 0 To $l - 1
						$aPieceRotatingPH[$l - 1 - $y][$l - 1 - $x] = $pieces[$pieceType][$y + 1][$x]
					Next
				Next
			Case 3  ; Rotate counter clockwise
				For $y = 0 To $l - 1
					For $x = 0 To $l - 1
						$aPieceRotatingPH[$l - 1 - $x][$y] = $pieces[$pieceType][$y + 1][$x]
					Next
				Next
		EndSwitch
	Else
		Switch $rotation
			Case 0
				SetPieceArray($pieceType)
			Case 1  ; Rotate clockwise
				For $y = 0 To $l - 1
					For $x = 0 To $l - 1
						$aPiece[$x][$l - 1 - $y] = $pieces[$pieceType][$y + 1][$x]
					Next
				Next
			Case 2  ; Rotate clockwise twice
				For $y = 0 To $l - 1
					For $x = 0 To $l - 1
						$aPiece[$l - 1 - $y][$l - 1 - $x] = $pieces[$pieceType][$y + 1][$x]
					Next
				Next
			Case 3  ; Rotate counter clockwise
				For $y = 0 To $l - 1
					For $x = 0 To $l - 1
						$aPiece[$l - 1 - $x][$y] = $pieces[$pieceType][$y + 1][$x]
					Next
				Next
		EndSwitch
	EndIf
EndFunc

Func CheckCollision($startX, $startY, $isTryingToRotate = 0)
	If $debug Then ConsoleWrite("[PIECE] Checking collision | ISTRYINGTOROTATE: " & $isTryingToRotate & @CRLF)
	Local $l = $pieces[$piece[$enumPieceType]][0][0]
	If $isTryingToRotate Then
		For $y = 0 To $l - 1
			For $x = 0 To $l - 1
				If $aPieceRotatingPH[$y][$x] <> 0 Then
					If $startY + $y > $height - 1 Or _
						$startX + $x < 0 Or _
						$startX + $x > $width - 1 Or _
						$board[($startY + $y) * $width + ($startX + $x)] <> 0 _
					Then
						If $debug Then ConsoleWrite("[PIECE] Checking collision | SUCCESS ISTRYINGTOROTATE: 1 COLLIDE: 1" & @CRLF)
						Return 1
					EndIf
				EndIf
			Next
		Next
	Else
		For $y = 0 To $l - 1
			For $x = 0 To $l - 1
				If $aPiece[$y][$x] <> 0 Then
					If $startY + $y > $height - 1 Or _
						$startX + $x < 0 Or _
						$startX + $x > $width - 1 Or _
						$board[($startY + $y) * $width + ($startX + $x)] <> 0 _
					Then
						If $debug Then ConsoleWrite("[PIECE] Checking collision | SUCCESS ISTRYINGTOROTATE: 0 COLLIDE: 1" & @CRLF)
						Return 1
					EndIf
				EndIf
			Next
		Next
	EndIf
	If $debug Then ConsoleWrite("[PIECE] Checking collision | SUCCESS ISTRYINGTOROTATE: " & $isTryingToRotate & " COLLIDE: 0" & @CRLF)
	Return 0
EndFunc

Func VarDump()
	Local $cout = ""
	$cout &= "$aPiece=["
	For $i = 0 To UBound($aPiece) - 1
		$cout &= "["
		For $j = 0 To UBound($aPiece, 2) - 1
			$cout &= $aPiece[$i][$j]
			If $j < UBound($aPiece, 2) - 1 Then $cout &= ","
		Next
		$cout &= "]"
		If $i < UBound($aPiece) - 1 Then $cout &= ","
	Next
	$cout &= "]"
	$cout &= @CRLF & "$board=[" & @CRLF
	For $i = 0 To UBound($board) - 1
		$cout &= $board[$i]
		If $i < UBound($board) - 1 Then $cout &= ","
		If Mod($i, $width) = 9 Then $cout &= @CRLF
	Next
	$cout &= "]"
	ConsoleWrite("[MAIN] Array dump | " & $cout & @CRLF)
EndFunc

; ==================================================
; Main part
; ==================================================

Func Main()
	_GDIPlus_Startup()
	$hGui = GUICreate("Autoit Tetris by Alan72104", 500, 1000, Default, Default, Default)  ; , $WS_EX_TOPMOST)
	GUISetBkColor($bgColor, $hGui)
    GUISetState(@SW_SHOW)
	$hGraphics = _GDIPlus_GraphicsCreateFromHWND($hGui)
	BrushInit()
	ReDim $board[$width * $height]  ; Resize the board array
	For $y = 0 To $height - 1
		For $x = 0 To $width - 1
			$board[$y * $width + $x] = 0
		Next
	Next
	DrawGuiFrame()
	DrawBoardFrame()
	GenerateNewPiece()
	Do
		DrawBoard()
		DrawPiece()
		If $piece[$enumPieceFalling] Then
			PieceTryGoDown()
		Else
			GenerateNewPiece()
		EndIf
		; If $debug Then VarDump()
		Sleep(300)
	Until GUIGetMsg() = $GUI_EVENT_CLOSE
	GdiPlusClose()
    GUIDelete($hGUI)
EndFunc

Main()

; ==================================================
; Pausing parts
; ==================================================

Func GdiPlusClose()
	For $i  = 0 To UBound($hBrush) - 1
		_GDIPlus_BrushDispose($hBrush[$i])
	Next
	For $i  = 0 To UBound($hPen) - 1
		_GDIPlus_PenDispose($hPen[$i])
	Next
    _GDIPlus_GraphicsDispose($hGraphics)
    _GDIPlus_Shutdown()
EndFunc

Func Terminate()
	GdiPlusClose()
    GUIDelete($hGUI)
    Exit 0
EndFunc

Func TogglePause()
    $g_bPaused = Not $g_bPaused
    While $g_bPaused
        Sleep (500)
        ToolTip ('Script is "Paused"', @desktopWidth / 2, @desktopHeight / 2, Default, Default, $TIP_CENTER)
    WEnd
    ToolTip("")
EndFunc