Strict

#rem
	Script:			JuggleSoccerBall.monkey
	Description:	Sample fantomX script that shows how to setup a little game
	Author: 		Michael Hartlef
	Version:      	2.0
#End

' Set the AutoSuspend functionality to TRUE so OnResume/OnSuspend are called
#MOJO_AUTO_SUSPEND_ENABLED=True

'Set to false to disable webaudio support for mojo audio, and to use older multimedia audio system instead.
#HTML5_WEBAUDIO_ENABLED=True

' Tell FantomX to import physics related classes/fields/methods
#FantomX_UsePhysics = True

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
	
	' Two fields that store the canvas width and height
	Field cw:Float
	Field ch:Float
	
	' The ball object
	Field ball:ftObject = Null
	
	' The physics scale
	Field physicsScale:Float = 60.0
	
	' Create a field that stores the instance of the ftBox2D class
	Field box2D:ftBox2D

	'------------------------------------------
	' This medthod sets up the physic world and buts a wall on each edge
	Method SetupPhysicsWorld:Void()
		' First create a new instance of tge ftBox2D class and assign your fantomX instance to it
		box2D = New ftBox2D(fE)
		' Now set the physics scale factor
		box2D.SetPhysicScale(physicsScale)
		' Let the class create now the world for you
		box2D.CreateWorld()
		' Set the gravity to the ball falls downwards
		box2D.SetGravity(0,4.0/(60/physicsScale))
		' With pressing the space key we want to see the debug drawing of box2D. 
		' So let's initialize it.
		box2D.InitDebugDraw()
		
		' Create the left wall
        box2D.CreateBox(10, ch, 0, ch/2)
        ' Create the right wall
        box2D.CreateBox(10, ch, cw, ch/2)
        ' And now the top wall
        box2D.CreateBox(cw, 10, cw/2, 0)
        ' Finally the bottom wall
        box2D.CreateBox(cw, 10, cw/2, ch)
	End
	'------------------------------------------
	' The method will setup the ball object we want to juggle in the air.
	Method SetupBall:Void()
		' First create the ftObject that represents the ball
		ball  = fE.CreateImage("ball.png",Rnd(40,cw-40), 240 )
		' Set the angle randomly
		ball.SetAngle(Rnd(0,360))
		' Set the radius of the ball to a half of its height
		ball.SetRadius(ball.GetHeight()/2)
		' Now create the physic object for the ball and connect it
		box2D.CreateObject(ball)
		' Set the bounciness to 0.3
		box2D.SetRestitution(ball, 0.3)
		' To be touchable, you need to set its touch mode
		ball.SetTouchMode(ftEngine.tmCircle)
		' To actually be able to touch a little under the ball, you need to raise its radius a little
		ball.SetRadius(14,True)
	End
	'------------------------------------------
	Method OnCreate:Int()
		' Create an instance of the fantomX, which was created via the cEngine class
		fE = New cEngine
		' Set the virtual canvas to 320x480 pixels and let it scale/center in letterbox mode
		fE.SetCanvasSize(320, 480, ftEngine.cmLetterbox)
		' Now determine and store the current canvas width and height
		cw = fE.GetCanvasWidth()
		ch = fE.GetCanvasHeight()
		' Load the soccerField image and place it in the center of the canvas
		Local soccerField := fE.CreateImage("field.png", cw/2, ch/2) 
		' Setup the physics world
		SetupPhysicsWorld()
		' Setup the ball and its physics object
		SetupBall()
		Return 0
	End
	'------------------------------------------
	Method OnUpdate:Int()
		' Determine the delta time and the update factor for the engine
		Local d:Float = Float(fE.CalcDeltaTime())/60.0
		' If the CLOSE key was hit, exit the app ... needed for GLFW and Android I think. 
		If KeyHit( KEY_CLOSE ) Then fE.ExitApp()
		
		' Determine the delta time and the update factor for the engine
		Local timeDelta:Float = Float(fE.CalcDeltaTime())/60.0
		' Check if the app is not suspended
		If fE.GetPaused() = False Then
			' Update the physics world
	        box2D.UpdateWorld(1/physicsScale, 8, 3)
			' Now do a touch check when the canvas was touched
			If TouchHit(0) Then 
				fE.TouchCheck(0)
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
		
			' Depending if the SPACE bar is pressed, render the ftObjects or the debug drawing of the box2D instance.
			If KeyDown(KEY_SPACE) Then
				fE.GetCanvas().PushMatrix
				fE.GetCanvas().Translate(fE.autofitX, fE.autofitY)
				box2D.RenderDebugDraw() 
				fE.GetCanvas().PopMatrix
			Else
				' Render all visible objects of the engine
				fE.Render()
			Endif

			' Now draw the current FPS value to the screen
			fE.SetColor(255, 255, 0)
			fE.GetCanvas().DrawText( "FPS= "+fE.GetFPS(),fE.GetLocalX(10), fE.GetLocalY(10))
			' Last, flip the previously drawn content to the screen, make it visible
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
		If obj = _g.ball Then	
			' Let the ftObject be updated by the connected physics object
			_g.box2D.UpdateObj(obj)
			'Local bd:b2Body = g.box2D.GetBody(obj)
		Endif
		Return 0
	End
	'------------------------------------------
	Method OnObjectTouch:Int(obj:ftObject, touchId:Int)
		' This method is called when a object was touched
		'Determine the position of the physics body of the object
		Local pos:Float[] = _g.box2D.GetPosition(obj)
		' Determine the Touch coordinates 
		Local tx:Float = _g.fE.GetTouchX()
		Local ty:Float = _g.fE.GetTouchY()
		' Calculate the force that is applied to the object
		Local fx:Float = ((pos[0]-tx)*10*(60/_g.physicsScale))
		Local fy:Float = ((pos[1]-ty)*15*(60/_g.physicsScale))
		' Now actually apply the force to the object
		_g.box2D.ApplyForce(obj, fx, fy, pos[0], pos[1])
		Return 0
	End
End

'***************************************
Function Main:Int()
	' Create an instance of the cGame class and store it inside the global var '_g'
	_g = New cGame
	
	Return 0
End


