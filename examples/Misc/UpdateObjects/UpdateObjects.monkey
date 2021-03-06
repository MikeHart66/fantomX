Strict

#rem
	Script:			UpdateObjects.monkey
	Description:	Sample script to show how to update objects based on their category
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
	
	' Define a constant for a timer	
	Const engineTimer:Int = 1
	
	' Define 2 constants to identify each type of object
	Const ENEMY:Int = 100
	Const GOODGUY:Int = 101

	'------------------------------------------
	Method SpawnObject:Void()
		' Create a simple circle
		Local tmpObj := fE.CreateCircle(20,fE.GetCanvasWidth()-20,Rnd(20,fE.GetCanvasHeight()-20))
		' Give it a random speed facing left
		tmpObj.SetSpeed(Rnd(5,10),270)
		' Give it a random size
		tmpObj.SetScale(Rnd(0.2,1.0))
		' Now create a timer to spawn the next object
		fE.CreateTimer(engineTimer, Rnd(200,1000))
		
		' Tag the object with a 50% chance to be a GOODGUY or an ENEMY, and give it a color.
		If Rnd(10)>5
			tmpObj.SetTag(ENEMY)
		Else
			tmpObj.SetTag(GOODGUY)
			tmpObj.SetColor(255,0,255)
		Endif
	End
	'------------------------------------------
	Method OnCreate:Int()
		' Create an instance of the fantomX, which was created via the cEngine class
		fE = New cEngine
		
		' Create a timer without a connection to an object which creates new circles at every second
		fE.CreateTimer(engineTimer, 500)
		
		' Create tweo lines to mark where each object type will be removed
		fE.CreateLine(20,0,20,fE.GetCanvasHeight())
		fE.CreateLine(200,0,200,fE.GetCanvasHeight())

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
			fE.Clear( 0,255,0)
		
			' Render all visible objects of the engine
			fE.Render()
			
			' Now draw the current FPS value to the screen
			fE.SetColor(255, 255, 0)
			fE.GetCanvas().DrawText( "FPS= "+fE.GetFPS(),fE.GetLocalX(10), fE.GetLocalY(10))
			' Draw some debugging info on the screen
			fE.GetCanvas().DrawText("ObjCount: "+ fE.GetObjCount(), 20,40)

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
	Method OnObjectUpdate:Int(obj:ftObject)
		' This method is called when an object finishes its update. You can deactivate the event via ftObject.ActivateUpdateEvent.
		
		' Remove the enemy object depending on its tag and X-Position
		If obj.GetTag()=_g.ENEMY And obj.GetPosX() < 20
			obj.Remove()
		Endif
		' Remove the GOODGUY object depending on its tag and X-Position
		If obj.GetTag()=_g.GOODGUY And obj.GetPosX() < 200
			obj.Remove()
		Endif
		Return 0
	End
    '------------------------------------------
	Method OnTimer:Int(timerId:Int)
		' This method is called when an engine timer was being fired.
		If timerId = _g.engineTimer
			_g.SpawnObject()
		Endif
		Return 0
	End	
End

'***************************************
Function Main:Int()
	' Create an instance of the cGame class and store it inside the global var '_g'
	_g = New cGame
	
	Return 0
End

