Strict

#rem
	Script:			TexturePacker.monkey
	Description:	Example script on how To use packed texture images created by the tool TexturePacker 
	Author: 		Michael Hartlef
	Version:      	2.0
#end

' Set the AutoSuspend functionality to TRUE so OnResume/OnSuspend are called
#MOJO_AUTO_SUSPEND_ENABLED=True

'Set to false to disable webaudio support for mojo audio, and to use older multimedia audio system instead.
#HTML5_WEBAUDIO_ENABLED=True

' Import the fantomX framework which imports mojo2 itself
Import fantomX

' The _g variable holds an instance to the cGame class
Global _g:cGame

'***************************************
' The cGame class controls the app
Class cGame Extends App
	' Create a field to store the instance of the cEngine class, which is an instance
	' of the ftEngine class itself
	Field fE:cEngine

	'------------------------------------------
	Method OnCreate:Int()
		' Create an instance of the fantomX, which was created via the cEngine class
		fE = New cEngine
		
		' Set the virtual canvas size to 320x480 and the canvas scale mode to letter box
		fE.SetCanvasSize(320,480,ftEngine.cmLetterbox)
		
		' Load the packed texture atlas
		Local tpatlas:Image = Image.Load("td_spritesheet.png")
		
		' Load the packed texture atlas via ftSpriteAtlas class
		Local tpatlas2:ftSpriteAtlas = New ftSpriteAtlas
		tpatlas2.Load("td_spritesheet.png", "td_spritesheet.txt")
		
		' Create several objects
		Local myObject0:ftObject = fE.CreateBox(fE.GetCanvasWidth(), fE.GetCanvasHeight(), fE.GetCanvasWidth()/2, fE.GetCanvasHeight()/2) 
		myObject0.SetColor(0,0,155)
		
		Local myObject1:ftObject = fE.CreateImage(tpatlas, "td_spritesheet.txt", "gold", 0, 0) 
		Local myObject2:ftObject = fE.CreateImage(tpatlas2.GetImage("gold"), fE.GetCanvasWidth(), 0) 
		Local myObject3:ftObject = fE.CreateImage(tpatlas2.GetImage("gold"), 0, fE.GetCanvasHeight()) 
		Local myObject4:ftObject = fE.CreateImage(tpatlas, "td_spritesheet.txt", "gold", fE.GetCanvasWidth(), fE.GetCanvasHeight()) 
		
		Local myObject5:ftObject = fE.CreateImage(tpatlas, "td_spritesheet.txt", "turretbase", fE.GetCanvasWidth()/2, fE.GetCanvasHeight()/2) 
		myObject5.SetSpin(1)
		
		Local myObject5b:ftObject = fE.CreateImage(tpatlas2.GetImage("turretbase"), fE.GetCanvasWidth()/2, fE.GetCanvasHeight()/2) 
		'Set the render area of an Object
		myObject5b.SetRenderArea(0,0,64,64)
		'Set its color
		myObject5b.SetColor(205,50,205)
		'Make it spin automatically 
		myObject5b.SetSpin(-1)
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
			fE.Clear( 0,0,0)
		
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
' The cEngine class extends the ftEngine class to override the On... methods
Class cEngine Extends ftEngine
	' No On.. callback methods are used in this example
End

'***************************************
Function Main:Int()
	' Create an instance of the cGame class and store it inside the global var '_g'
	_g = New cGame
	
	Return 0
End

