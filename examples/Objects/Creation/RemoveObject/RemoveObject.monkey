Strict

#rem
	Script:			RemoveObject.monkey
	Description:	Sampe script that shows how to remove objects 
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
' The game class controls the app
Class cGame Extends App
    ' Create a field to store the instance of the cEngine class, which is an instance
    ' of the ftEngine class itself
	Field fE:cEngine
	
	Field delCount:Int = 0
	Field layerNo:Int =1
	Field layer2:ftLayer
	Field layer1:ftLayer
	
	'------------------------------------------
	Method SpawnObjects:Void(anz:Int=100)
		If layerNo = 1 Then
			fE.SetDefaultLayer(layer1)
			layerNo = 2
		Else
			fE.SetDefaultLayer(layer2)
			layerNo = 1
		Endif
		For Local i:=1 To anz
			'Local obj := fE.CreateCircle(10,Rnd(fE.GetCanvasWidth()), Rnd(fE.GetCanvasHeight()))
			Local obj := fE.CreateImage("cratesmall.png",Rnd(fE.GetCanvasWidth()), Rnd(fE.GetCanvasHeight()))
			For Local i:=1 To 3
				'Local obj2 := fE.CreateCircle(5,Rnd(fE.GetCanvasWidth()), Rnd(fE.GetCanvasHeight()))
				Local obj2 := fE.CreateImage("cratesmall.png",Rnd(fE.GetCanvasWidth()), Rnd(fE.GetCanvasHeight()))
				obj2.SetParent(obj)
				obj2.SetScale(Rnd(0.5)+0.5)
			Next
		Next
	End
	'------------------------------------------
	Method OnCreate:Int()
		' Create an instance of the fantomX, which was created via the cEngine class
		fE = New cEngine
		
		layer1 = fE.GetDefaultLayer()
		layer2 = fE.CreateLayer()
		
		SpawnObjects()
		Return 0
	End
	'------------------------------------------
	Method OnUpdate:Int()
		' Determine the delta time and the update factor for the engine
		Local d:Float = Float(fE.CalcDeltaTime())/60.0
		
		' Check if the app is not suspended
		If fE.GetPaused() = False Then
			' Update all objects of the engine
			delCount = 0
			fE.Update(d)
			SpawnObjects()
		Endif
		Return 0
	End
	'------------------------------------------
	Method OnRender:Int()
		' Check if the app is not suspended
		If fE.GetPaused() = False Then
			' Clear the screen 
			fE.Clear( 0,0,0)
		
			' Render all visible objects of the engine
			fE.Render()
			' Now draw the current FPS value to the screen
			fE.SetColor(255, 255, 0)
			fE.GetCanvas().DrawText( "FPS= "+fE.GetFPS(), fE.GetLocalX(10), fE.GetLocalY(10))
		    ' Draw the current object count of each layer
			fE.GetCanvas().DrawText("objects1="+layer1.GetObjCount(), fE.GetLocalX(20), fE.GetLocalY(20))
			fE.GetCanvas().DrawText("objects2="+layer2.GetObjCount(), fE.GetLocalX(20), fE.GetLocalY(40))
			' Last, flip the previously drawn content to the screen, make it visible
			fE.RenderFlush()

		Endif
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
		_g.delCount = _g.delCount + 1
		If _g.delCount < 10001 Then obj.Remove()
		
		Return 0
	End

End

'***************************************
Function Main:Int()
	' Create an instance of the cGame class and store it inside the global var '_g'
	_g = New cGame
	
	Return 0
End
