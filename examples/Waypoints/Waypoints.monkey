
Strict

#rem
	Script:			Waypoints.monkey
	Description:	Example script on how to use waypoints 
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
	
	' Create a field for a waypoint path
	Field path:ftPath
	
	' Create a path marker, that object that runs along a path
	Field mk:ftMarker

	'------------------------------------------
	Method OnCreate:Int()
		' Create an instance of the fantomX, which was created via the cEngine class
		fE = New cEngine
		
		' Now set the virtual canvas size
		fE.SetCanvasSize(800,600)
		
		' Now create a path with its origin at the center of the canvas
	    path = fE.CreatePath(fE.GetCanvasWidth()/2, fE.GetCanvasHeight()/2)
	    
		' Create 4 waypoints
		path.AddWP( -150,-150, True)
		path.AddWP( 150,-150, True)
		path.AddWP( 150,150, True)
		path.AddWP( -150,150, True)
		
		' Create a marker
		mk = path.CreateMarker()
		
		' Connect a new image object to the marker
		mk.ConnectObj(fE.CreateImage("CarSprite.png",0,0))
		
		' Let the marker circle around the path
		mk.SetMoveMode(path.mmCircle)
		
		' Set its interpolation mode to CatMull Rom spline
		mk.SetInterpolationMode(path.imCatmull)

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
			' Update all path marker and their connected objects
			path.UpdateAllMarker(timeDelta*10)

			' Scale the path when you press the Q or A key
			If KeyDown(KEY_Q) Then 
				path.SetScale(-0.01,-0.01,True)
			Endif
			If KeyDown(KEY_A) Then 
				path.SetScale(0.01,0.01,True)
			Endif

			' Move the path when you press the UP/DOWN key
			If KeyDown(KEY_UP) Then 
				path.SetPos(0,-1,True)
			Endif
			If KeyDown(KEY_DOWN) Then 
				path.SetPos(0,1,True)
			Endif

			' Turn the path when you press the RIGHT/LEFT key
			If KeyDown(KEY_RIGHT) Then 
				path.SetAngle(0.5,True)
			Endif
			If KeyDown(KEY_LEFT) Then 
				path.SetAngle(-0.5,True)
			Endif

		Endif
		' End the app when you press the ESCAPE key		
		If KeyHit(KEY_ESCAPE) Then fE.ExitApp
		Return 0
	End
	'------------------------------------------
	Method OnRender:Int()
		' Check if the engine is not paused
		If fE.GetPaused() = False Then
			' Clear the screen 
			fE.Clear( 0,0,55)
		
			' Render all visible objects of the engine
			fE.Render()
			
			' Now draw the current FPS value to the screen
			fE.SetColor(255, 255, 0)
			fE.GetCanvas().DrawText( "FPS= "+fE.GetFPS(),fE.GetLocalX(10), fE.GetLocalY(10))

			' Render the waypoints of the path
			fE.SetColor(0,0,255)
			path.RenderAllWP()
			
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
	Method OnMarkerCircle:Int(marker:ftMarker, obj:ftObject)
		' This method is called, when a path marker reaches the end of the path and is about to do another circle.
		Print ("One round is finished")
		Return 0
	End
	

End

'***************************************
Function Main:Int()
	' Create an instance of the cGame class and store it inside the global var '_g'
	_g = New cGame
	
	Return 0
End
