Strict

#rem
	Script:			ParentChild.monkey
	Description:	Sample script to show how to use parent/child relationships.
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
	
	' Create a field field that hold the parent 
	Field parent:ftObject = Null

	'------------------------------------------
	Method SpawnChild:Void()
		' Create the child, it's a box
		Local child := fE.CreateBox(20, 20, fE.GetCanvasWidth()*(Rnd(0.5)+0.25), fE.GetCanvasHeight()*(Rnd(0.5)+0.25))

		' Connect the child to the parent
		child.SetParent(parent)
		
		' Set a random color for the child
		child.SetColor(Rnd(255), Rnd(255), Rnd(255))
	End
	'------------------------------------------
	Method OnCreate:Int()
		' Create an instance of the fantomX, which was created via the cEngine class
		fE = New cEngine
		
		' Seed the random number generator
		Seed = Millisecs()
		
		' Create the parent
		parent = fE.CreateBox(40,40,fE.GetCanvasWidth()/2,fE.GetCanvasHeight()/2)
		parent.SetSpin(5)
		' Create the child and set its parent
		SpawnChild()
		Return 0
	End
	'------------------------------------------
	Method OnUpdate:Int()
		' If the CLOSE key was hit, exit the app ... needed for GLFW and Android I think. 
		If KeyHit( KEY_CLOSE ) Then fE.ExitApp()
		
		' Determine the delta time and the update factor for the engine
		Local timeDelta:Float = Float(fE.CalcDeltaTime())/60.0

		Local child:ftObject = Null

		If fE.GetPaused() = False Then
	
			' If the parent has children, get the first child		
			If parent.GetChildCount()>0 Then
				child = parent.GetChild(1)
			Endif
			
			' Set the parents position accordingly to the mouse coordinates
			parent.SetPos(fE.GetTouchX(), fE.GetTouchY())
			
			' If there is a child, check for the P-Key and disconnect it from the parent
			If child <> Null Then 
				If KeyHit(KEY_P) Then
					If child.GetParent() <> Null Then
						child.SetParent(Null)
					Endif
				Endif
			Endif		
			' If the N-Key was hit, spawn another child
			If KeyHit(KEY_N) Then
				SpawnChild()
			Endif
			' If the Q-Key was hit, scale the parent upwards
			If KeyDown(KEY_Q) Then
				parent.SetScale(0.02,True)
			Endif
			' If the W-Key was hit, scale the parent downpwards
			If KeyDown(KEY_W) Then
				parent.SetScale(-0.02,True)
			Endif
			' If left mouse button was pressed, rotate the parent
			If MouseDown(MOUSE_LEFT)
				parent.SetAngle(2,True)
			Endif
			' If right mouse button was pressed, rotate the parent
			If MouseDown(MOUSE_RIGHT)
				parent.SetAngle(-2,True)
			Endif
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
	' No On.. callback methods are used in this example
End

'***************************************
Function Main:Int()
	' Create an instance of the cGame class and store it inside the global var '_g'
	_g = New cGame
	
	Return 0
End

