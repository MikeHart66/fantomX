Strict

#Rem
	Script:			ObjectMovement.monkey
	Description:	Sample script that shows how to control your objects at runtime 
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
	
	' Create a field to store the canon object so we can handle it directly
	Field canon:ftObject
	
	' Create two fields that store the width and height of the canvas
	Field cw:Float
	Field ch:Float
	
	Field once:Bool = False

	'------------------------------------------
	' The SpawnShot method will create a new shot. It sets its ID , positions it 
	' infront of the canon and set its speed and heading reagrding the angle of the 
	' canon.
	Method SpawnShot:Int()
	    ' Determine the current angle of the canon
		Local curAngle:Float = canon.GetAngle()
		
		' Determine the vector that is 50 pixels away infront of the canon
		Local pos:Float[] = canon.GetVector(50,curAngle)
		
		' Create a shot in the middle of the screen
		Local shot:ftObject = fE.CreateCircle(5,pos[0], pos[1])
		
		' Set the speed and the angle of the shot
		shot.SetSpeed(-10, curAngle)
		
		' Set a random color for the shot
		shot.SetColor(Rnd(255),Rnd(255),Rnd(255))
		
		' Set its ID to 222 so we can detect it during the OnObjectUdpate event
		shot.SetID(222)
		
		once = false
		Return 0
	End
	'------------------------------------------
	Method OnCreate:Int()
		' Create an instance of the fantomX, which was created via the cEngine class
		fE = New cEngine
		
		' Determine and store the width and height of the canvas
		cw = fE.GetCanvasWidth()
		ch = fE.GetCanvasHeight()
		
		' Create the canon in the middle of the screen
		canon = fE.CreateBox(20,60, cw/2, ch/2 )
		
		' Color the canon blue
		canon.SetColor(0,0,255)
		
		' Set the ID of the canon so it won't be detected as a shot later
		canon.SetID(111)
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
		
			' If the LEFT key was pressed, turn the canon by 2 degrees left
			If KeyDown(KEY_LEFT) Then canon.SetAngle(-2,True)
			
			' If the RIGHT key was pressed, turn the canon by 2 degrees right
			If KeyDown(KEY_RIGHT) Then canon.SetAngle(2,True)
			
			' If the SPACE key was pressed, spwan a new shot
			If KeyHit(KEY_SPACE) Then SpawnShot()
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
	Method OnObjectUpdate:Int(obj:ftObject)
		' This method is called when an object finishes its update. You can deactivate the event via ftObject.ActivateUpdateEvent.

		' Determine if the object is a shot
		If obj.GetID() = 222 Then
		
		    ' If the shot, reaches the top or bottom, set its speed to zero
			If obj.GetPosY() < 40  Or obj.GetPosY() > (_g.ch-40) Then obj.SetSpeed(0)
			
			' If the shot reaches the left or right border, remove the object
			If obj.GetPosX() < 40  Or obj.GetPosX() > (_g.cw-40) Then obj.Remove()
			
			' Slowly fade out the object
			'obj.SetAlpha(obj.GetAlpha()-0.01)
			
			If _g.once = False And obj.GetSpeed() <> 0.0 Then
				_g.once = True
				Print("angle:"+obj.GetSpeedAngle()+"  speed:"+obj.GetSpeed()+"   objcount:"+_g.fE.GetObjCount())
			Endif
			
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
