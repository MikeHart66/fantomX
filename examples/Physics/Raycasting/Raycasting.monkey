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
	
	' Create a field that stores the instance of the cB2D class
	Field box2D:cB2D

	' Create a field to store the laser object
	Field laser:ftObject = Null
	
	' Create a field to store
	Field hitPoint:ftObject = Null
	
	' Now we need a field for the mouse joint
	Field mjoint:b2MouseJoint = Null
	
	' The physics scale
	Field physicsScale:Float = 60.0
	
	' Next create a field to store the physic world object
	Field world:b2World
	
	' As the mouse joint needs to bodies, create one for the ground of the world
	Field ground:b2Body

	'------------------------------------------
	Method SpawnBall:Void()
		' Create the crate object and set its ID to a value we call work with during the update callback of each ball
		Local ball:ftObject  = fE.CreateImage("ball.png",Rnd(30,cw-10), Rnd(30,100))
		ball.SetID(222)
		'ball.SetRadius(ball.GetHeight()/2)
		
		' Set its angle randomly
		ball.SetAngle(Rnd(0,360))

		' Set its scale randomly
		ball.SetScale(Rnd(3,20)/10.0)

		' Set the collision type of the ball to "circle"
		ball.SetColType(ftEngine.ctCircle)

		' Now create the physics object for the ball
		Local body:b2Body = box2D.CreateObject(ball)
		' Set friction and restitution (bounce) of the ball
		box2D.SetFriction(ball, 0.3)
		box2D.SetRestitution(ball, 0.4)
		
		' Make the ball touchable
		ball.SetTouchMode(ftEngine.tmCircle)

	End

	'------------------------------------------
	Method SpawnCrate:Void()
		' Create the crate object and set its ID to a value we call work with during the update callback of each crate
		Local crate:ftObject  = fE.CreateImage("cratesmall.png",Rnd(30,cw-10), Rnd(30,100))
		crate.SetID(222)
		
		' Set its angle randomly
		crate.SetAngle(Rnd(0,360))

		' Set its scale randomly
		crate.SetScale(Rnd(5,15)/10.0)

		' Set the collision type of the crate to "rotated box"
		crate.SetColType(ftEngine.ctBox)

		' Now create the physics object for the crate
		Local body:b2Body = box2D.CreateObject(crate)
		' Set friction and restitution (bounce) of the crate
		box2D.SetFriction(crate, 0.3)
		box2D.SetRestitution(crate, 0.2)
		
		' Make the crate touchable
		crate.SetTouchMode(ftEngine.tmBound)

	End

	'------------------------------------------
	' This medthod sets up the physic world and buts a wall on each edge
	Method SetupPhysics:Void()
		' First create a new instance of tge ftBox2D class and assign your fantomX instance to it
		box2D = New cB2D(fE)
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
		
		' Setup 4 crates which we can drag around
		For Local c1:Int = 1 To 4
			SpawnCrate()
		Next
		' Setup 4 balls which we can drag around
		For Local c2:Int = 1 To 4
			SpawnBall()
		Next
		
		'Setup the laser
		laser = fE.CreateLine(cw/2, ch/4, cw/2, ch/4*3-20)
		laser.SetPos(cw/2, ch/2)
		laser.SetHandle(0,0)
		
		' Setup the hitpoint and its reflection normal
		hitPoint = fE.CreateCircle(5, cw/2, ch/2)
		hitPoint.SetColor(255,0,0)
		Local reflectionNormal:= fE.CreateLine(cw/2, ch/2, cw/2+50, ch/2)
		reflectionNormal.SetPos(cw/2, ch/2)
		reflectionNormal.SetHandle(0,0)
		reflectionNormal.SetAngle(0)
		reflectionNormal.SetParent(hitPoint)
		reflectionNormal.SetColor(0,255,0)
		
		' Print some info text
		Print ("Use the cursor keys to control the laser beam.")
		Print ("You can also drag the crates around")
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

		
		' Control the laser angle
		If KeyDown(KEY_LEFT) Then laser.SetAngle(-0.5, True)
		If KeyDown(KEY_RIGHT) Then laser.SetAngle(0.5, True)
		If KeyHit(KEY_UP) Then
			hitPoint.SetPos(cw/2, ch/2) 
			laser.SetAngle(0)
		Endif
		' Determine the "end-point" of the laser
		Local tv:Float[] = laser.GetVector(laser.w, laser.angle)
		' Now do a raycast, if not successfull, resset the position of the hitpoint 
		If Not box2D.RayCast(laser.xPos, laser.yPos, tv[0], tv[1]) = True Then 
			hitPoint.SetPos(cw/2, ch/2)
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
		If obj.GetID() = 222 Then	_g.box2D.UpdateObj(obj)
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
Class cB2D Extends ftBox2D
	'------------------------------------------
'summery:This method creates a new ftbox2D instance and connects it with the given ftEngine
	Method New(eng:ftEngine)
		Super.New(eng)
	End
	'------------------------------------------
'summery:This callback method is called when a raycast was successful.
	Method OnRayCast:Void (rayFraction:Float, rayVec:b2Vec2, hitNormal:b2Vec2, hitPoint:b2Vec2, nextPoint:b2Vec2, fixture:b2Fixture, obj:ftObject)
		' Set the position of the hitpoint
		_g.hitPoint.SetPos(hitPoint.x, hitPoint.y)
		' Determine the angle from the hitpoint to the next/reflected point of the ray 
		Local ha := _g.hitPoint.GetVectorAngle(nextPoint.x, nextPoint.y)
		' The the angle of the hitpoint
		_g.hitPoint.SetAngle(ha)
		' Set the color of the ftObject that was hit to red
		obj.SetColor(255,0,0)
	End
End

'***************************************
Function Main:Int()
	' Create an instance of the cGame class and store it inside the global var '_g'
	_g = New cGame
	
	Return 0
End
