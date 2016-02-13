Strict

#rem
	Script:			MouseJoint.monkey
	'Description:	Sample script on how to use a Box2D mouse joint with fantomX 
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
	
	' Create a field that stores the instance of the ftBox2D class
	Field box2D:ftBox2D
	
	' Create a field to store the crate object
	Field crate:ftObject = Null
	
	' Now we need a field for the mouse joint
	Field mjoint:b2MouseJoint = Null
	
	' The physics scale
	Field physicsScale:Float = 60.0
	
	' Next create a field to store the physic world object
	Field world:b2World
	
	' As the mouse joint needs to bodies, create one for the ground of the world
	Field ground:b2Body

	'------------------------------------------
	Method SpawnCrate:Void()
		' Create the crate object
		crate  = fE.CreateImage("cratesmall.png",Rnd(30,cw-10), Rnd(30,100))
		' Set its angle randomly
		crate.SetAngle(Rnd(0,360))
		' Scale the crate randomly
		crate.SetScale(Rnd(0.7)+0.3)
		' Set the collision type of the crate to "rotated box"
		crate.SetColType(ftEngine.ctBox)
		' Now create the physics object for the crate
		box2D.CreateObject(crate)
		' Set friction and restitution (bounce) of the crate
		'box2D.SetDensity(crate, 1.3)
		box2D.SetFriction(crate, 0.3)
		box2D.SetRestitution(crate, 0.2)
		
		' Make the crate touchable
		crate.SetTouchMode(ftEngine.tmBound)
	End

	'------------------------------------------
	' This medthod sets up the physic world and buts a wall on each edge
	Method SetupPhysics:Void()
		' First create a new instance of tge ftBox2D class and assign your fantomX instance to it
		box2D = New ftBox2D(fE)
		' Now set the physics scale factor
		box2D.SetPhysicScale(physicsScale)
		' Let the box2D class create now the world for you
		world = box2D.CreateWorld()
		' Set the gravity of the world
		box2D.SetGravity(0,10)
		' With pressing the space key we want to see the debug drawing of box2D. 
		' So let's initialize it.
		box2D.InitDebugDraw()
		
		' Create the left wall
        box2D.CreateBox(10, ch, 0, ch/2)
        ' Create the right wall
        box2D.CreateBox(10, ch, cw, ch/2)
        ' And now the top wall
        box2D.CreateBox(cw, 10, cw/2, 0)
        ' Finally create the bottom wall and store it inside the ground field
        ground = box2D.CreateBox(cw, 10, cw/2, ch)
	End
	'------------------------------------------
	Method OnCreate:Int()
		' Create an instance of the fantomX, which was created via the cEngine class
		fE = New cEngine
		' Set the Seed value via the current Millisecs value 
		Seed = Millisecs()
		' Now determine and store the current canvas width and height
		cw = fE.GetCanvasWidth()
		ch = fE.GetCanvasHeight()
		
		' Setup the physics world
		SetupPhysics()
		
		' Setup the crate which we can drag around
		SpawnCrate()
		Return 0
	End
	'------------------------------------------
	Method OnUpdate:Int()
		' If the ESCAPE key was pressed, exit the app
		If KeyHit(KEY_ESCAPE) Then fE.ExitApp
		
		' Determine the delta time and the update factor for the engine
		Local timeDelta:Float = Float(fE.CalcDeltaTime())/60.0
		' Check if the app is not suspended
		If fE.GetPaused() = False Then
			' Update the physics world
	        box2D.UpdateWorld((timeDelta*4.0)/physicsScale)
			' Update all objects of the engine
			fE.Update(timeDelta)
		Endif
		' Check if the canvas is touched
		If TouchDown(0) Then
			' If no mouse joint exists, do a touch check
			If mjoint= Null Then
				fE.TouchCheck(0)
			Else
				' If there is an existing mouse joint...
				' determine and store the current touch coordinates
				Local target:b2Vec2 = New b2Vec2
				target.x = fE.GetTouchX()/physicsScale
				target.y = _g.fE.GetTouchY()/physicsScale
				' Set the target of the mouse joint by the coordinates
				mjoint.SetTarget(target)
			Endif
		Else
			' if the canvas was not touched and a mouse joint exists
			If mjoint<> Null Then
				' destroy the mouse joint
				world.DestroyJoint(mjoint)
				mjoint = Null
			Endif
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
		If obj = _g.crate Then	
			' Let the ftObject be updated by the connected physics object
			_g.box2D.UpdateObj(obj)
		Endif
		Return 0
	End
	
	'------------------------------------------
	Method OnObjectTouch:Int(obj:ftObject, touchId:Int)
		' This method is called when a object was touched
		' Check if no mouse joint is existing right now
		If _g.mjoint = Null Then
			' Create a mouse joint 
			_g.mjoint = _g.box2D.CreateMouseJoint(_g.ground, _g.box2D.GetBody(obj), _g.fE.GetTouchX(), _g.fE.GetTouchY(), 100)
		End
		Return 0
	End
End

'***************************************
Function Main:Int()
	' Create an instance of the cGame class and store it inside the global var '_g'
	_g = New cGame
	
	Return 0
End
