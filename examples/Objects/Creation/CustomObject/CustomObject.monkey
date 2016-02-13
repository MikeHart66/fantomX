Strict

#rem
	Script:			ExtendedObject.monkey
	Description:	Sample script that shows how To extend the Object class 
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
' This is the extended ftObject class 
Class myObject Extends ftObject
	Field mySpinSpeed:Float = -5.0
	Field xfactor:Float = 10.0
	'------------------------------------------
	Method New()
		' In its constructor, set the spin property to turn left
		Self.SetSpin(mySpinSpeed)
		
		' Deactivate the OnObjectUpdate event call as 
		' we handle things inside the classes own Update method
		Self.ActivateUpdateEvent(False)
	End
	'------------------------------------------
	Method Update:Void(speed:Float = 1.0)
		' Call the Update method of the base class 	
		Super.Update(speed)
		
		' Raise the objects scale factors
		Self.SetScale(0.01,True)
	End
End

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
		
		' Create a new box object on the right side with the base ftObject class
		Local obj := fE.CreateBox(20,120,fE.GetCanvasWidth()/4*3, fE.GetCanvasHeight()/2)
		
		' Let the object spin by a factor of 10 at each Update call
		obj.SetSpin(10)
		
		' Set its speed property to 2
		obj.SetSpeed(2)
		
		' Now create another box object on the left side, but this 
		' time create the object within the method call an use the myObject class
		Local obj2 := fE.CreateBox(20,120,fE.GetCanvasWidth()/4, fE.GetCanvasHeight()/2, New myObject)
		
		' Set its speed to -2
		obj2.SetSpeed(-2)
		
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
		fE.SetPaused(false)
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
	Method OnObjectUpdate:Int(obj:ftObject)
		' This method is called when an object finishes its update
		obj.SetPos(1,0,True)
		Return 0
	End
End

'***************************************
Function Main:Int()
	' Create an instance of the cGame class and store it inside the global var '_g'
	_g = New cGame
	
	Return 0
End
