Strict

#rem
	Script:			Test.monkey
	Description:	Basic fantomX script for testing purpose
	Author: 		Michael Hartlef
	Version:      	2.0
#End

' Set the AutoSuspend functionality to TRUE so OnResume/OnSuspend are called
#MOJO_AUTO_SUSPEND_ENABLED=True

'Set to false to disable webaudio support for mojo audio, and to use older multimedia audio system instead.
#HTML5_WEBAUDIO_ENABLED=True
#MOJO_IMAGE_FILTERING_ENABLED=False

' Tell FantomX to import physics related classes/fields/methods
#FantomX_UsePhysics = False

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
	
	' Create a field for the default scene and layer of the engine
	Field defLayer:ftLayer
	Field defScene:ftScene
	Field camDefault:ftCamera
	Field cam0:ftCamera
	Field cam1:ftCamera

	
	Field cW:Int
	Field cH:Int
	'------------------------------------------
	Method OnClose:Int()
		fE.ExitApp()
		Return 0
	End
	'------------------------------------------
	Method OnBack:Int()
		Return 0
	End
	'------------------------------------------
	Method OnCreate:Int()
		' Create an instance of the fantomX, which was created via the cEngine class
		fE = New cEngine
		
		'Set the virtual size of the canvas
		fE.SetCanvasSize(640,960)

		cW = fE.GetCanvasWidth()
		cH = fE.GetCanvasHeight()

		camDefault = fE.GetCamera()
		cam0 = fE.CreateCamera()
		cam1 = fE.CreateCamera()

		camDefault.SetDimensions(0, 0, DeviceWidth(), DeviceHeight())
		cam0.SetDimensions(0, 0, DeviceWidth()/2.0, DeviceHeight())
		cam1.SetDimensions(DeviceWidth()/2.0, 0, DeviceWidth()/2.0, DeviceHeight())

		
		' Get the default scene of the engine
		defScene = fE.GetDefaultScene()

		' Get the default layer of the engine
		defLayer = fE.GetDefaultLayer()

		For Local x:= 16 To fE.GetCanvasWidth() Step 32
			Local block := fE.CreateImage("ground.png",x,fE.GetCanvasHeight()-16)
			block.SetAngle(Int(Rnd(0,4))*90)
		Next
		

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
			
			If KeyDown(KEY_RIGHT) Then cam0.SetPosX( 0.5, True)
			If KeyDown(KEY_LEFT)  Then cam0.SetPosX(-0.5, True)
			If KeyHit(KEY_SPACE)
				Print(fE.autofitX+":"+fE.autofitY+"      "+fE.scaleX+":"+fE.scaleY)
			Endif
			cam1.Use()
		Endif
		Return 0
	End
	'------------------------------------------
	Method OnRender:Int()
		' Check if the engine is not paused
		If fE.GetPaused() = False Then
			fE.GetCanvas().SetScissor(0,0,10000.0, 10000.0)
			fE.GetCanvas().SetViewport (0,0,DeviceWidth(), DeviceHeight())
			fE.GetCanvas().SetProjection2d (0,DeviceWidth()-1,0, DeviceHeight()-1)
			camDefault.Use()
			fE.Clear( 255,0,255)
			
			If KeyDown(KEY_A)
				cam0.Use()
				fE.GetCanvas().SetViewport (0, 0, DeviceWidth()/2.0, DeviceHeight())
				fE.GetCanvas().SetProjection2d (0, DeviceWidth()/2.0-1.0, 0, DeviceHeight()-1)
			Endif
			' Clear the screen 
			fE.Clear( 200,200,0)
			' Render all visible objects of the engine
			fE.Render()
			' Now draw the current FPS value to the screen
			fE.SetColor(255, 255, 255)
			fE.GetCanvas().DrawText( "FPS= "+fE.GetFPS(),fE.GetLocalX(10, False), fE.GetLocalY(10, False))
			' Last, flip the previously drawn content to the screen, make it visible
			fE.GetCanvas().DrawText( "X/Y= "+Int(fE.GetTouchX(0, False))+":"+Int(fE.GetTouchY(0, False)),fE.GetLocalX(10, False), fE.GetLocalY(25, False))

			If KeyDown(KEY_A)
				cam1.Use()
				' Clear the screen 
				fE.GetCanvas().SetViewport (DeviceWidth()/2.0, 0, DeviceWidth()/2.0, DeviceHeight()/2.0)
				fE.GetCanvas().SetProjection2d (0, DeviceWidth()/2.0-1.0, 0, (DeviceHeight()-1.0))
				fE.Clear( 0,200,200)
				' Render all visible objects of the engine
				fE.Render()
				' Now draw the current FPS value to the screen
				fE.SetColor(255, 255, 255)
				fE.GetCanvas().DrawText( "FPS= "+fE.GetFPS(),fE.GetLocalX(10, False), fE.GetLocalY(10, False))
				' Last, flip the previously drawn content to the screen, make it visible
				fE.GetCanvas().DrawText( "X/Y= "+Int(fE.GetTouchX(0, False))+":"+Int(fE.GetTouchY(0, False)),fE.GetLocalX(10, False), fE.GetLocalY(25, False))
			Endif			

			fE.RenderFlush()			
		Else
			fE.GetCanvas().DrawText("**** PAUSED ****",fE.GetLocalX(fE.GetCanvasWidth()/2.0),fE.GetLocalY(fE.GetCanvasHeight()/2.0),0.5, 0.5)
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
	Method OnLayerTransition:Int(transId:Int, layer:ftLayer)
		' This method is called when a layer finishes its transition
		Return 0
	End
	'------------------------------------------
	Method OnLayerUpdate:Int(layer:ftLayer)
		' This method is called when a layer finishes its update
		Return 0
	End	
	'------------------------------------------
	Method OnObjectAnim:Int(obj:ftObject)
		'This Method is called when an animation of an object (obj) has finished one loop.
		Return 0
	End
	'------------------------------------------
	Method OnObjectCollision:Int(obj:ftObject, obj2:ftObject)
		' This method is called when an object collided with another object
		Return 0
	End
	'------------------------------------------
	Method OnObjectDelete:Int(obj:ftObject)
		' This method is called when an object is removed. You need to activate the event via ftObject.ActivateDeleteEvent.
		Return 0
	End
	'------------------------------------------
	Method OnObjectRender:Int(obj:ftObject)
		' This method is called when an object was being rendered. You need to activate the event via ftObject.ActivateRenderEvent.
		Return 0
	End
	'------------------------------------------
	Method OnObjectSort:Int(obj1:ftObject, obj2:ftObject)
		' This method is called when objects are compared during a sort of its layer list
		Return 0
	End	
	'------------------------------------------
	Method OnObjectTimer:Int(timerId:Int, obj:ftObject)
		' This method is called when an objects' timer was being fired.
		Return 0
	End	
	'------------------------------------------
	Method OnObjectTouch:Int(obj:ftObject, touchId:Int)
		' This method is called when an object was touched
		Return 0
	End
	'------------------------------------------
	Method OnObjectTransition:Int(transId:Int, obj:ftObject)
		' This method is called when an object finishes its transition and the transition has an ID > 0.
		Return 0
	End
	'------------------------------------------
	Method OnObjectUpdate:Int(obj:ftObject)
		' This method is called when an object finishes its update. You can deactivate the event via ftObject.ActivateUpdateEvent.
		Return 0
	End
	'------------------------------------------
	Method OnMarkerBounce:Int(marker:ftMarker, obj:ftObject)
		' This method is called, when a path marker reaches the end of the path and is about to bounce backwards.
		Return 0
	End
	'------------------------------------------
	Method OnMarkerCircle:Int(marker:ftMarker, obj:ftObject)
		' This method is called, when a path marker reaches the end of the path and is about to do another circle.
		Return 0
	End
	'------------------------------------------
	Method OnMarkerStop:Int(marker:ftMarker, obj:ftObject)
		' This method is called, when a path marker reaches the end of the path and stops there.
		Return 0
	End
	'------------------------------------------
	Method OnMarkerWarp:Int(marker:ftMarker, obj:ftObject)
		' This method is called, when a path marker reaches the end of the path and is about to warp to the start to go on.
		Return 0
	End
	'------------------------------------------
	Method OnMarkerWP:Int(marker:ftMarker, obj:ftObject)
		' This method is called, when a path marker reaches a waypoint of its path.
		Return 0
	End
	'------------------------------------------
	Method OnSwipeDone:Int(touchIndex:Int, sAngle:Float, sDist:Float, sSpeed:Float)
		' This method is called when a swipe gesture was detected
		Return 0
	End
    '------------------------------------------
	Method OnTimer:Int(timerId:Int)
		' This method is called when an engine timer was being fired.
		Return 0
	End	
End

'***************************************
Function Main:Int()
	' Create an instance of the cGame class and store it inside the global var '_g'
	_g = New cGame
	
	Return 0
End

