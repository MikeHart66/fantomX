Strict

#rem
	Script:			SortObjects.monkey
	Description:	Sample script that shows how so sort objects inside a layer
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
	
	' Create a field for a new layer
	Field myLayer:ftLayer
	
	' Create a field for a player controllable circle object
	Field myCircle:ftObject

	'------------------------------------------
	Method OnCreate:Int()
		' Create an instance of the fantomX, which was created via the cEngine class
		fE = New cEngine
		
		' Create the myLayer layer and set it as the default layer for new objects
		myLayer = fE.CreateLayer()
		fE.SetDefaultLayer(myLayer)

		' Create a yellow circle that moves with the mouse cursor
		myCircle = fE.CreateCircle(30, fE.GetCanvasWidth()/2, fE.GetCanvasHeight()/2)
		myCircle.SetColor(255,255,0)
				
		' Create a red box that doesn't move
		Local myBox := fE.CreateBox(130, 20, fE.GetCanvasWidth()/2, fE.GetCanvasHeight()/2)
		myBox.SetColor(255,0,0)

		
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
		
			' Move the circle to the mouse position
			myCircle.SetPos(fE.GetTouchX(), fE.GetTouchY())
		
			' Update all objects of the engine
			fE.Update(timeDelta)
			
			' Sort all objects in the myLayer layer.
			myLayer.SortObjects()
			
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
	Method OnObjectSort:Int(obj1:ftObject, obj2:ftObject)
		' This method is called when objects are compared during a sort of its layer list
		
		' We compare the bottom (yPos+Height/2) of each object, the ones with a smaller result will
		' be sort infront of the other object and so appear behind the over object.
		If (obj1.yPos + obj1.GetHeight()/2) < (obj2.yPos + obj2.GetHeight()/2) Then 
			Return False
		Else
			Return True
		Endif
	End	
End

'***************************************
Function Main:Int()
	' Create an instance of the cGame class and store it inside the global var '_g'
	_g = New cGame
	
	Return 0
End

