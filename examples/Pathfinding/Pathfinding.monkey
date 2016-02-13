Strict

#rem
	Script:			PathFinding.monkey
	Description:	Sample fantomX script that shows how to do A* pathfinding in the fantomX
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
	
	' Create a field to store the instance of an AStar path finding grid
	Field grid:ftAStar = Null
	
	' Create 3 fields for the start, end and closest node
	Field closeNode:ftGridNode = Null
	Field startNode:ftGridNode = Null
	Field endNode:ftGridNode = Null
	
	' Create a field that stores the distance of a calculated path
	Field dist:Float = 0.0
	
	' Create constants to define the space between each node
	Const nsX:Int = 20
	Const nsY:Int = 20
	

	'------------------------------------------
	Method SetupGrid:Void()
		Local cw:Int, ch:Int, i:Int
		
		' Determine the node count for is axxis
		cw = fE.GetCanvasWidth()/nsX
		ch = fE.GetCanvasHeight()/nsY
		
		i = 0
		For Local y := 1 To ch-1
			For Local x := 1 To cw-1
				' Create a new node
				i += 1
				Local node := grid.AddNode(i, x*nsX, y*nsY)
				
				' Depending on its position in the grid, connect it to its surrounding nodes
				If y > 1 Then
					grid.ConnectByID(i-(cw-1), i, true)
					If x > 1 And Rnd(10)>7 Then grid.ConnectByID(i-(cw), i, True)
					If x < (cw-1) And Rnd(10)>7 Then grid.ConnectByID(i-(cw-2), i, True)
				Endif
				If x > 1 Then
					grid.ConnectByID(i-1, i, true)
				Endif
				
				' Set a node randomly as being blocked
				If Rnd(10)>7 Then node.SetBlock(True)
			Next
		Next
		Print ("NodeCount="+i)
	End
	'------------------------------------------
	Method OnCreate:Int()
		' Create an instance of the fantomX, which was created via the cEngine class
		fE = New cEngine
		' Create a new grid
		grid = New ftAStar
		grid.engine = fE
		
		' Setup the grid
		SetupGrid()
		
		' Print some info messages inside the text area (or console)
		Print ("Press left mouse button to define the start node...")
		Print ("... and right mouse button to define the end node.")
		Print ("")
		Print ("Press -S- to save a grid to the local storage...")
		Print ("... and -L- to load it back from the local storage.")
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
			
			' Determine the closest node to the mouse coordinates
			closeNode = grid.FindClosestNode(fE.GetTouchX(), fE.GetTouchY())
			
			' Define the start node and calculate a new path
			If MouseHit( MOUSE_LEFT ) And closeNode <> Null Then
				startNode = closeNode
				If endNode <> Null Then
					dist = grid.FindPath(startNode.GetIndex(), endNode.GetIndex())
					Print("Pathtime = " + grid.pathTime+ " milliseconds")
				Endif
			Endif
	
			' Define the end node and calculate a new path
			If MouseHit( MOUSE_RIGHT ) And closeNode <> Null Then
				endNode = closeNode
				If startNode <> Null Then
					dist = grid.FindPath(startNode.GetIndex(), endNode.GetIndex())
					Print("Pathtime = " + grid.pathTime + " milliseconds")
				Endif
			Endif
			
			' Store the current grid when the S key was pressed
			If KeyHit(KEY_S) Then
				Local gss:= grid.SaveToString()
				SaveState(gss)
				Print "Grid was saved."
			Endif
	
	
			' Load a saved grid when the L key was pressed
			If KeyHit(KEY_L) Then 
				Local gls:= LoadState()
				grid.LoadFromString(gls)
				Print "Finish loading."
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
		
			' Render all visible objects of the engine
			fE.Render()
			
			fE.SetColor(200,200,200)
			' Render the grid
			grid.Render(4)
			
			' Now render the closest, start and end nodes
			fE.SetColor(255,0,255)
			If closeNode <> Null Then fE.GetCanvas().DrawCircle(closeNode.GetPosX(),closeNode.GetPosY(),5)
			fE.SetColor(0,255,0)
			If startNode <> Null Then fE.GetCanvas().DrawCircle(startNode.GetPosX(),startNode.GetPosY(),5)
			fE.SetColor(255,0,0)
			If endNode <> Null Then fE.GetCanvas().DrawCircle(endNode.GetPosX(),endNode.GetPosY(),5)
			
			' Display the distance of the last path found
			fE.SetColor(255,255,0)
			fE.GetCanvas().DrawText("Dist = "+dist,20,20)
			
			' If a path was found, display its route
			If grid.GetPathNodeCount()> 0 Then
				fE.GetCanvas().DrawText("Path node nodecount = "+grid.GetPathNodeCount(),20,40)
				fE.SetColor(80,80,255)
				For Local pi:= 1 To grid.GetPathNodeCount()-1
					Local p1:= grid.GetPathNode(pi)
					Local p2:= grid.GetPathNode(pi+1)
					fE.GetCanvas().DrawLine( p1.GetPosX(),p1.GetPosY(), p2.GetPosX(),p2.GetPosY() )
				Next
			Endif
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
	' No On.. callback methods are used in this example
End

'***************************************
Function Main:Int()
	' Create an instance of the cGame class and store it inside the global var '_g'
	_g = New cGame
	
	Return 0
End

