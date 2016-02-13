Strict

#rem
	Script:			MultiTileSets.monkey
	Description:	Example script on how to use tilemaps with more than one tile set
	Author: 		Michael Hartlef
	Version:      	2.0
#end

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

	Field tm:ftObject
	
	Field layerMap:ftLayer
	Field layerGUI:ftLayer
	Field txtInfo1:ftObject
	Field txtInfo2:ftObject
	Field txtInfo3:ftObject
	Field objCircle:ftObject
	
	Field tileMap:ftTileMap
	'------------------------------------------
	Method OnCreate:Int()
		Local c:Int

		' Create an instance of the fantomX, which was created via the cEngine class
		fE = New cEngine
		
		'fE.SetCanvasSize(160,240)
		
		'Load the tile map created by Tiled
		tm = fE.CreateTileMap("maps/test_ortho_2tilesets.json", 24, 24 )

		tileMap = tm.GetTileMap()
		
		' Load a bitmap font
		Local font:ftFont = fE.LoadFont("font.txt")

		' Set and create some layers
		layerMap = fE.GetDefaultLayer()
		layerGUI = fE.CreateLayer()
		' Set the GUI flag of the GUI layer so it isn't effected by the camera
		layerGUI.SetGUI(True)
		
		' Create a circle, representing some kind of map object
		fE.SetDefaultLayer(layerGUI)
	
		' Create some info text objects
		fE.SetDefaultLayer(layerGUI)
		txtInfo1 = fE.CreateText(font,"FPS: 60",10,fE.GetCanvasHeight()-10, fE.taBottomLeft)
		txtInfo1.SetTouchMode(ftEngine.tmBound)
		txtInfo1.SetName("txtInfo1")

		txtInfo2 = fE.CreateText(font,"0:0=0",fE.GetCanvasWidth()-10,fE.GetCanvasHeight()-10, fE.taBottomRight)
		txtInfo2.SetTouchMode(ftEngine.tmBound)
		txtInfo2.SetName("txtInfo2")
		
		Return 0
	End
	'------------------------------------------
	Method OnUpdate:Int()
		' If the CLOSE key was hit, exit the app ... needed for GLFW and Android I think. 
		If KeyHit( KEY_CLOSE ) Then fE.ExitApp()
		
		' Determine the delta time and the update factor for the engine
		Local timeDelta:Float = Float(fE.CalcDeltaTime())/60.0

		' Determine the current touch/mouse coordinates
		Local x:Int = fE.GetTouchX()
		Local y:Int = fE.GetTouchY()
		
		' Check if the engine is paused
		If fE.GetPaused() = False Then
		
			' Update all objects of the engine
			fE.Update(Float(timeDelta))
			
			'Remove a tile when you click left with the mouse
			If MouseHit( MOUSE_LEFT ) Then
				' Do a touchcheck, if object is hit, engine.onObjectTouch is called.
				fE.TouchCheck()
				' Remove the tile 
				tm.SetTileIDAt(x ,y,-1)
			Endif
			
			'Set a random tile when you do a right mouse click
			If MouseHit( MOUSE_RIGHT ) Then
				tm.SetTileIDAt(x, y, Rnd(0,3))
			Endif
			
			'Move the camera with the cursor keys
			If KeyDown(KEY_LEFT) Then fE.SetCamX(-5*timeDelta,True)
			If KeyDown(KEY_RIGHT) Then fE.SetCamX(5*timeDelta,True)
			If KeyDown(KEY_UP) Then fE.SetCamY(-5*timeDelta,True)
			If KeyDown(KEY_DOWN) Then fE.SetCamY(5*timeDelta,True)
			
			'Update the info text objects
			txtInfo1.SetText("FPS:"+fE.GetFPS())
			txtInfo2.SetText(x+":"+y+"  tileID="+tm.GetTileIDAt(x,y))
			
		Endif
		Return 0
	End
	'------------------------------------------
	Method OnRender:Int()
		Local x:Float
		Local y:Float
		Local xp:Float
		Local yp:Float
		Local xOff:Float
		Local yOff:Float
		Local tsX:Float
		Local tsY:Float
		' Check if the engine is not paused
		If fE.GetPaused() = False Then
			' Clear the screen 
			fE.Clear( 40,40,40)
			
			' Render all visible objects of the engine
			fE.Render()
			
			xp = tm.GetPosX()
			yp = tm.GetPosY()
			tsX = tileMap.tileSizeX
			tsY = tileMap.tileSizeY
			xOff = tsX * 1/2.0
			yOff = tsY * 1/2.0
			For y = 0 To tileMap.tileCountY-1
				For x = 0 To tileMap.tileCountX-1
					'Vertical
					fE.GetCanvas().DrawLine( xp+x*tsX-xOff, yp+y*tsY-yOff, xp+ x   *tsX-xOff, yp+(y+1)*tsY-yOff )
					'Horizontal
					fE.GetCanvas().DrawLine( xp+x*tsX-xOff, yp+y*tsY-yOff, xp+(x+1)*tsX-xOff, yp+ y   *tsY-yOff )
				Next
			Next
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
End

'***************************************
Function Main:Int()
	' Create an instance of the cGame class and store it inside the global var '_g'
	_g = New cGame
	
	Return 0
End

