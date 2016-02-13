Strict

#rem
	Script:			DynamicMap.monkey
	Description:	Example script on how to self build a (dynamic) map.
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

	Field tileMap:ftObject
	Field atlas:Image
	'------------------------------------------
	Method OnCreate:Int()
		Local c:Int
		'Create an instance of the fantomX
		fE = New cEngine

		' Set the canvas size of a usual Android canvas
		fE.SetCanvasSize(320,480)
		
		'Define the tile size and how many tiles the map will have in each direction
		Local tileWidth:Int = 32
		Local tileHeight:Int = 32
		Local tileCountX:Int = 1000
		Local tileCountY:Int = 1000
		
		
		' Load the sprite sheet that contains the tiles of our map. 
		atlas = Image.Load("tilesheet.png" )
		If atlas = Null Then Print ("atlas = null")
		
		' Now create an empty tile map
		tileMap = fE.CreateTileMap(atlas, tileWidth, tileHeight, tileCountX , tileCountY, tileWidth/2.0, tileHeight/2.0 )
		
		' Next randomly build the map
		For Local yt:Int = 1 To tileCountY
			For local xt:Int = 1 To tileCountX
				tileMap.SetTileID(xt-1, yt-1, Rnd(0,15) )
			Next
		Next
	
		' Now add a text for the console
		Print "Use the cursor keys to move the map, and the mouse buttons to delete or randomly set a map tile."
		Return 0
	End
	'------------------------------------------
	Method OnUpdate:Int()
		Local d:Float = Float(fE.CalcDeltaTime())/60.0
		If fE.GetPaused() = False Then
			
			fE.Update(Float(d))
			'Remove a tile when you click left with the mouse
			If MouseHit( MOUSE_LEFT ) Then
				tileMap.SetTileIDAt(fE.GetTouchX(),fE.GetTouchY(),-1)
			Endif
			'Set a random tile
			If MouseHit( MOUSE_RIGHT ) Then
				tileMap.SetTileIDAt(fE.GetTouchX(),fE.GetTouchY(),Rnd(0,15))
			Endif
			'Move the camera with the cursor keys
			If KeyDown(KEY_LEFT) Then fE.SetCamX(-1,True)
			If KeyDown(KEY_RIGHT) Then fE.SetCamX(1,True)
			If KeyDown(KEY_UP) Then fE.SetCamY(-1,True)
			If KeyDown(KEY_DOWN) Then fE.SetCamY(1,True)
		Endif
		Return 0
	End
	'------------------------------------------
	Method OnRender:Int()
		Local x:Int = fE.GetTouchX()
		Local y:Int = fE.GetTouchY()
		' Check if the engine is not paused
		If fE.GetPaused() = False Then
			' Clear the screen 
			fE.Clear( 0,0,50)
		
			' Render all visible objects of the engine
			fE.Render()
			
			' Now draw the current FPS value to the screen
			'fE.SetColor(255, 255, 0)
			fE.GetCanvas().DrawText( "FPS= "+fE.GetFPS(),fE.GetLocalX(10, False), fE.GetLocalY(10, False))

			' Print the tile ID under the mouse cursor
			fE.GetCanvas().DrawText("Tile unter mouse at "+x+":"+y+" = "+tileMap.GetTileIDAt(x,y),fE.GetLocalX(10, False),fE.GetLocalY(30, False))
		
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
