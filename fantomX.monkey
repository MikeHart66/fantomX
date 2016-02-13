#rem
	'Title:        fantomX
	'Description:  A 2D game framework for the Monkey X programming language
	
	'Author:       Michael Hartlef
	'Contact:      michaelhartlef@gmail.com
	
	'Website:      http://www.fantomgl.com
	
	'Version:      2.01
	'License:      MIT
#End

#Rem
'header:The module [b]fantomX[/b] is a 2D game framework which supplies you with huge set of game object related functionalities. 
To use fantomX in your game, simply add "Import fantomX" at the top of your program.
#End

Import mojo2
Import brl.pool

'If TARGET="html5"
Import "data/ftLoadingBar.png"
Import "data/ftOrientation_changeP.png"
Import "data/ftOrientation_changeL.png"
'End

Import reflection
'#REFLECTION_FILTER+="|fantomX.cftView"
#REFLECTION_FILTER+="|fantomX*"

'Import fantomX.src.cftAds
'Import fantomX.src.cftAnalytics
Import fantomX.cftAStar
#If FantomX_UsePhysics = 1
	Import fantomX.cftBox2D
#Endif
'Import fantomX.cftCamera
Import fantomX.cftCollisions
Import fantomX.cftEngine
Import fantomX.cftFont
Import fantomX.cftFunctions
Import fantomX.cftGui
Import fantomX.cftHighscore
'Import fantomX.src.cftIAP
Import fantomX.cftImageMng
'Import fantomX.src.cftIni
'Import fantomX.src.cftJson
Import fantomX.cftKeyMapping
Import fantomX.cftLayer
Import fantomX.cftLocalization
Import fantomX.cftMisc
'Import fantomX.src.cftMultiplayer
Import fantomX.cftObject
Import fantomX.cftObjAnimMng
'Import fantomX.src.cftParticles
Import fantomX.cftRGBA
Import fantomX.cftScene
Import fantomX.cftSound
Import fantomX.cftSpriteAtlas
'Import fantomX.src.cftSteamIntegration
Import fantomX.cftSwipe
Import fantomX.cftTileMap
Import fantomX.cftTimer
Import fantomX.cftTrans
Import fantomX.cftVec2D
Import fantomX.cftWaypoints
'Import fantomX.src.cftXml
Import fantomX.json


'-OUTPUTNAME#index.html
'#INCLFILE#docInclude/introduction.txt
'-INCLFILE#docInclude/classes.txt
'-INCLFILE#docInclude/3rdpartytools.txt
'-INCLFILE#docInclude/examples.txt
'-INCLFILE#docInclude/changes.txt
#rem
footer:This fantomX framework is released under the MIT license:
[quote]Copyright (c) 2011-2016 Michael Hartlef

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the software, and to permit persons to whom the software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
[/quote]
#end