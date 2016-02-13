Strict

#rem
	Script:			ObjectTransitionImage.monkey
	Description:	Sample script that shows how to use transitions to transform image objects
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
	
	' Create a field to store the transition
	Field trans:ftTrans
	
	' Create a constant for the transition ID. 
	' This will be used to identify the transition in the ftEngine.OnObjectTransition handler method.
	Const transDone:Int = 1
	
	'------------------------------------------
	Method OnCreate:Int()
		' Create an instance of the fantomX, which was created via the cEngine class
		fE = New cEngine
		'fE.SetCanvasSize(480,320)
		' Create a box object we want to transition
		Local tmpBox := fE.CreateBox(128,128,-100,fE.GetCanvasHeight()/4.0)
		tmpBox.SetTag(1)
		
		' Create the image object we want to transition
		Local tmpImage := fE.CreateImage("image.png", -100, (fE.GetCanvasHeight()/4.0)*3)
		tmpImage.SetTag(1)
		' Scale the image up to 150%
		tmpImage.SetScale(1.5)

		' Now start a transition to the other side of the canvas and store it
		trans = tmpBox.CreateTransPos(fE.GetCanvasWidth()+200, 0, 6000 ,True, transDone)
		' Set the equation type of the transition
		trans.SetType("Cubic")
		' Set the ease type pf the transition
		trans.SetEase("EaseInOut")
		
		
		trans = tmpImage.CreateTransPos(fE.GetCanvasWidth()+200, 0, 6000 ,True, transDone)
		' Set the equation type of the transition
		trans.SetType("Cubic")
		' Set the ease type pf the transition
		trans.SetEase("EaseInOut")
		' Print a little info message
		'Print ("Press the <P> key to pause/resume the transition")
		
		'fE.SetPaused(True)
		
		Return 0
	End
	'------------------------------------------
	Method OnUpdate:Int()
		' If the CLOSE key was hit, exit the app ... needed for GLFW and Android I think. 
		If KeyHit( KEY_CLOSE ) Then fE.ExitApp()
		
		' Determine the delta time and the update factor for the engine
		Local timeDelta:Float = Float(fE.CalcDeltaTime())/60.0

		If KeyHit(KEY_P) = True Then 
			If fE.GetPaused()=True Then
				fE.SetPaused(False)
			Else
				fE.SetPaused(True)
			Endif
		Endif
	
		fE.Update(timeDelta)

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
	Method OnObjectTransition:Int(transId:Int, obj:ftObject)
		' This method is called when an object finishes its transition
		If transId = _g.transDone Then
			' Negate the Tag value of the object
			obj.SetTag(obj.GetTag()*-1)
			' Start a new transtion for this object
			_g.trans = obj.CreateTransPos((_g.fE.GetCanvasWidth() + 200) * obj.GetTag(), 0, 6000 ,True, _g.transDone)
			' Set the equation type of the transition
			_g.trans.SetType("Cubic")
			' Set the ease type pf the transition
			_g.trans.SetEase("EaseInOut")
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
