Strict

#rem
	Script:			FlashObject.monkey
	Description:	This sample script shows some ways on how to flash an object 
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
' The custObject class extends the ftObject class and is
' used to create a custom object.
Class custObject Extends ftObject
	
	' Besides all the fields 
	Field renderTimer:Int = 60
	Field renderOn:Int = 1

	'------------------------------------------
	Method New()
		Self.SetColor(Rnd(50,255), Rnd(50,255), Rnd(50,255))
	End
	
	'------------------------------------------
	Method Update:Void(delta:Float=1.0)
		Super.Update(delta)
	End
	
	'------------------------------------------
	Method myUpdate:void()
		Self.renderTimer -= 1
		If Self.renderTimer < 0
			Self.renderTimer = 60
			Self.renderOn = 1 - Self.renderOn
		Endif
		
		If Self.renderOn = 1 Then
			Self.SetScale(1)
		Else
			Self.SetScale(-0.01,True)
		Endif
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
	
		' Seed the random number generator
		Seed = Millisecs()
		
		' Create an instance of the fantomX, which was created via the cEngine class
		fE = New cEngine
		
		' Create some objects
		Local obj1 := fE.CreateBox(100, 100, 150, 150, New custObject)
		obj1.ActivateRenderEvent()
		obj1.ActivateUpdateEvent(false)
		
		Local obj2 := fE.CreateBox(100, 100, 350, 150, New custObject)
		obj2.SetID(2)
		obj2.CreateTimer(0, 500, -1)
		obj2.ActivateUpdateEvent(false)
		
		Local obj3 := fE.CreateBox(100, 100, 150, 350, New custObject)
		obj3.CreateTransAlpha(0, 1000, False,1)
		obj3.ActivateUpdateEvent(false)
		
		Local obj4 := fE.CreateBox(100, 100, 350, 350, New custObject)
		
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
	'------------------------------------------
	Method OnObjectRender:Int(obj:ftObject)
		' This method is called when an object was being rendered
		Local o:custObject = custObject(obj)
		Local px:Float = o.GetPosX()
		Local py:Float = o.GetPosY()
		
		o.renderTimer -= 1
		If o.renderTimer < 0
			o.renderTimer = 60
			o.renderOn = 1 - o.renderOn
		Endif
		
		If o.renderOn = 1 Then
			Self.SetColor(255,150,150)
			Self.SetAlpha(1.0)
			Self.GetCanvas().DrawLine(px-51 , py-55, px+51, py-55) 'Top
			Self.GetCanvas().DrawLine(px-55 , py-51, px-55, py+51) 'Left
			Self.GetCanvas().DrawLine(px-51 , py+55, px+51, py+55) 'Bottom
			Self.GetCanvas().DrawLine(px+55 , py-51, px+55, py+51) 'Right
			_g.fE.RestoreColor()
			_g.fE.RestoreAlpha()
		Endif
		Return 0
	End
	'------------------------------------------
	Method OnObjectTimer:Int(timerId:Int, obj:ftObject)
		' This method is called when an objects' timer was being fired
		If obj.GetID() = 2 Then
			obj.SetAlpha(1-obj.GetAlpha())
		Endif
		Return 0
	End	
	'------------------------------------------
	Method OnObjectTransition:Int(transId:Int, obj:ftObject)
		' This method is called when an object finishes its transition
		obj.CreateTransAlpha(1.0-obj.GetAlpha(), 1000, False,1)
		Return 0
	End
	'------------------------------------------
	Method OnObjectUpdate:Int(obj:ftObject)
		' This method is called when an object finishes its update
		custObject(obj).myUpdate()
		Return 0
	End
End

'***************************************
Function Main:Int()
	' Create an instance of the cGame class and store it inside the global var '_g'
	_g = New cGame
	
	Return 0
End
