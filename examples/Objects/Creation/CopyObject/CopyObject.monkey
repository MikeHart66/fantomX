Strict

#Rem
	Script:			CopyObject.monkey
	Description:	Sample script that shows how to copy an object with most of its parameters at runtime  
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
' The cGame class controls the app
Class cGame Extends App
	' Create a field to store the instance of the cEngine class, which is an instance
	' of the ftEngine class itself
	Field fE:cEngine

	' Create two fields that store the width and height of the canvas
	Field cw:Float
	Field ch:Float

	'------------------------------------------
	Method OnCreate:Int()
		' Create an instance of the fantomX, which was created via the cEngine class
		fE = New cEngine
		
		' Determine and store the width and height of the canvas
		cw = fE.GetCanvasWidth()
		ch = fE.GetCanvasHeight()
		
		' Create the 1st object in the middle of the screen
		Local obj1 := fE.CreateBox(20,20, cw/2, ch/2 )

		' Create a child object slightly in the middle of the screen and assign it to the 1st object
		Local childObj1 := fE.CreateBox(10,10, cw/2+40, ch/2+40 )
		childObj1.SetParent(obj1)

		' Copy the 1st object, which creates the 2nd object
		Local obj2 := fE.CopyObject(obj1)
		
		' Set the speed and angle of the 1st object. The second object will stand still
		obj1.SetSpeed(10,Rnd(360))		
		
		' Let the 2nd object spin and scale it up by a factor of 3
		obj2.SetSpin(10)		
		obj2.SetScale(3)

		' Let the 1st object wrap around the screen edges.
		obj1.SetWrapScreen(True)
		Return 0
	End
	'------------------------------------------
	Method OnUpdate:Int()
		' If the CLOSE key was hit, exit the app ... needed for GLFW and Android I think. 
		If KeyHit( KEY_CLOSE ) Then fE.ExitApp()
		
		' Determine the delta time and the update factor for the engine
		Local timeDelta:Float = Float(fE.CalcDeltaTime())/60.0

		' Check if the engine is not paused
		If fE.GetPaused() = False Then
			' Update all objects of the engine
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
	'------------------------------------------
	' No On.. callback methods are used in this example
End

'***************************************
Function Main:Int()
	' Create an instance of the cGame class and store it inside the global var '_g'
	_g = New cGame
	
	Return 0
End
