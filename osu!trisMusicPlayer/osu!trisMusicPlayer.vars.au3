Global Const $width = 1080; / 4 * 3
Global Const $height = $width / 16 * 9
Global Const $title = "osu!tris"
Global $g_bPaused = False
Global $hGui
Global Const $bgColorRGB = 0x121543
Global Const $bgColorARGB = 0xFF000000 + $bgColorRGB
Global $hGraphics
Global $frameBuffer
Global $hFrameBuffer
Global $hBrushTris[10]
Global $hBrushRed, $hBrushGreen, $hBrushParticle
Global $deleteCount = 0
Global Const $maxTriAmount = 100
Global Enum $TRIX, $TRIY, $TRISCALE, $TRISHADE
Global $tris[$maxTriAmount + 1][4] = [ _
									 [2    ,  0x00, 0x00,0x00], _
									 [115.0, 250.0, 52.7,   2], _
									 [137.0, 367.0, 88.9,   7]]
Global $triVelocityMultiplier = 3.9
Global Const $triVelocityMultiplierMin = 1
Global $hTimerBeat, $hTimerFrame, $hTimerEffect
Global $smoothedFrameTime = 0.0
Global Const $frameTimeSmoothingRatio = 0.3
Global Const $osuWhiteBgEnable = False
Global $hAudioStream
Global $channelDataBuffer
Global $currentAudioLevel = 0
Global $channelLevel
Global $beat = False
Global Const $useSystemSoundLevel = True
Global $audioLevelIndex = 0
Global Const $audioLevelMaxIndex = 15
Global $aAudioLevel[$audioLevelMaxIndex]
Global $audioLevelAverage = 0
Global $hDllCallback
Global $wndprocPreviousValue
Global $playing = False