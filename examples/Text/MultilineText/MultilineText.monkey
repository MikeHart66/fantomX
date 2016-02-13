Strict

#rem
	Script:			MultilineText.monkey
	Description:	Sample fantomX script, that shows how to use multiline text objects 
	Author: 		Michael Hartlef
	Version:      	2.0
#End

' Set the AutoSuspend functionality to TRUE so OnResume/OnSuspend are called
#MOJO_AUTO_SUSPEND_ENABLED=True

'Set to false to disable webaudio support for mojo audio, and to use older multimedia audio system instead.
#HTML5_WEBAUDIO_ENABLED=True

' Import the fantomX framework which imports mojo2 itself
Import fantomX

' The _g variable holds an instance to the cGame class
Global _g:cGame


'***************************************
Class cGame Extends App
	' Create a field to store the instance of the cEngine class, which is an instance
	' of the ftEngine class itself
	Field fE:cEngine
	
	' Create a field for the default scene and layer of the engine
	Field defLayer:ftLayer
	Field defScene:ftScene
	
	'------------------------------------------
	Method OnCreate:Int()
		' Create an instance of the fantomX, which was created via the cEngine class
		fE = New cEngine
		
		' Store the width and height of the canvas
		Local cw:Int = 1280
		Local ch:Int = 900
		
		' Set virtual canvas size
		fE.SetCanvasSize(cw, ch)

		' Load a bitmap font
		Local font:ftFont = fE.LoadFont("font.txt")
		
		' Create to small boxes to define a cross hair
		Local b1:=fE.CreateBox(cw,3,cw/2,ch/2)
		Local b2:=fE.CreateBox(3,ch,cw/2,ch/2)
		
		' Create some multi line text objects
		Local multitxt_TL:ftObject = fE.CreateText(font,"Hello World!~nMonkey is awesome~ntextAlignMode = taTopLeft",cw/2,ch/2, fE.taTopLeft)
		'Local multitxt_CL:ftObject = fE.CreateText(font,"Hello World!~nMonkey is awesome~ntextAlignMode = taCenterLeft",cw/2,ch/2, fE.taCenterLeft)
		Local multitxt_BL:ftObject = fE.CreateText(font,"Hello World!~nMonkey is awesome~ntextAlignMode = taBottomLeft",cw/2,ch/2, fE.taBottomLeft)
		
		'Local multitxt_TR:ftObject = fE.CreateText(font,"Hello World!~nMonkey is awesome~ntextAlignMode = taTopRight",cw/2,ch/2, fE.taTopRight)
		Local multitxt_CR:ftObject = fE.CreateText(font,"Hello World!~nMonkey is awesome~ntextAlignMode = taCenterRight",cw/2,ch/2, fE.taCenterRight)
		'Local multitxt_BR:ftObject = fE.CreateText(font,"Hello World!~nMonkey is awesome~ntextAlignMode = taBottomRight",cw/2,ch/2, fE.taBottomRight)
		
		'Local multitxt_TC:ftObject = fE.CreateText(font,"Hello World!~nMonkey is awesome~ntextAlignMode = taTopCenter",cw/2,ch/2, fE.taTopCenter)
		'Local multitxt_CC:ftObject = fE.CreateText(font,"Hello World!~nMonkey is awesome~ntextAlignMode = taCenterCenter",cw/2,ch/2, fE.taCenterCenter)
		'Local multitxt_BT:ftObject = fE.CreateText(font,"Hello World!~nMonkey is awesome~ntextAlignMode = taBottomCenter",cw/2,ch/2, fE.taBottomCenter)
		Return 0
	End
	'------------------------------------------
	Method OnUpdate:Int()
		' If the CLOSE key was hit, exit the app ... needed for GLFW and Android I think. 
		If KeyHit( KEY_CLOSE ) Then fE.ExitApp()
		
		' Determine the delta time and the update factor for the engine
		Local timeDelta:Float = Float(fE.CalcDeltaTime())/60.0

		' Update all objects of the engine
		If fE.GetPaused() = False Then
			fE.Update(timeDelta)
		Endif
		Return 0
	End
	'------------------------------------------
	Method OnRender:Int()
		' Check if the engine is not paused
		If fE.GetPaused() = False Then
			' Clear the screen 
			fE.Clear( 0,0,155)
		
			' Render all visible objects of the engine
			fE.Render()
			
			' Now draw the current FPS value to the screen
			fE.SetColor(255, 255, 0)
			fE.GetCanvas().DrawText( "FPS= "+fE.GetFPS(),fE.GetLocalX(10), fE.GetLocalY(10))

			' Last, flip the previously drawn content to the screen, make it visible
			fE.RenderFlush()			
		Endif
		Return 0
	End
	'------------------------------------------
	Method OnLoading:Int()
		' If loading of assets in OnCreate takes longer, render a simple loading screen
		fE.RenderLoadingBar()
		
		Return 0
	End
	'------------------------------------------
	Method OnResume:Int()
		' Set the pause flag of the engine to FALSE so objects, timers and transitions are updated again
		fE.SetPaused(False)
		
		Return 0
	End
	'------------------------------------------
	Method OnSuspend:Int()
		' Set the pause flag of the engine to TRUE so objects, timers and transitions are paused (not updated)
		fE.SetPaused(True)
		
		Return 0
	End
End	

'***************************************
Class cEngine Extends ftEngine
	' No On.. callback methods are used in this example
End


'***************************************
Function Main:Int()
	' Create an instance of the cGame class and store it inside the global var '_g'
	_g = New cGame
	Return 0
End
