Strict

#rem
	Script:			Buttons.monkey
	Description:	fantomX sample script that shows how to use the custom gui button object
	Author: 		Michael Hartlef
	Version:      	2.0
#End

' Set the AutoSuspend functionality to TRUE so OnResume/OnSuspend are called
#MOJO_AUTO_SUSPEND_ENABLED=True
#MOJO_IMAGE_FILTERING_ENABLED=False

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
	
	' Create a field for the default scene and layer of the engine
	Field defLayer:ftLayer
	Field defScene:ftScene
	
	Field guiMng:ftGuiMng = Null

	Field guiBtn:ftGuiButton = Null
	
	Field font1:ftFont

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
		SetUpdateRate(0)
		fE = New cEngine
		fE.SetCanvasSize(640,480)
		
		font1 = fE.LoadFont("font_20")

		guiMng = fE.CreateGUI()
		guiMng.font1 = font1

		
		guiBtn = guiMng.CreateButton("guiButton.png")
		guiBtn.SetPos(fE.GetCanvasWidth()/2, fE.GetCanvasHeight()-guiBtn.GetHeight()/2.0-20.0)
		guiBtn.SetSmoothness(0.90)
		

		' Get the default scene of the engine
		defScene = fE.GetDefaultScene()

		' Get the default layer of the engine
		defLayer = fE.GetDefaultLayer()

		Return 0
	End
	'------------------------------------------
	Method OnUpdate:Int()
		' If the CLOSE key was hit, exit the app ... needed for GLFW and Android I think. 
		If KeyHit( KEY_ESCAPE ) Then fE.ExitApp()
		
		' Determine the delta time and the update factor for the engine
		Local timeDelta:Float = Float(fE.CalcDeltaTime())/60.0

		' Update all objects of the engine
		If fE.GetPaused() = False Then
			'Print(" ")
			'Print("-----------------------------")
			'Print("Method OnUpdate guiMng")
			'guiMng.Update()

			'Print("Method OnUpdate fE")
			fE.Update(timeDelta)
			
			For Local index:Int = 0 To 3
				'Print("Method OnUpdate TouchCheck #"+index)
				If TouchDown(index) Then fE.TouchCheck(index)
			Next
			
		Endif
		
		
		Return 0
	End

	'------------------------------------------
	Method OnRender:Int()
		' Check if the engine is not paused
		If fE.GetPaused() = False Then
			' Clear the screen 
			fE.Clear( 200,0,0)
		
			' Render all visible objects of the engine
			fE.Render()
			
			' Now draw the current FPS value to the screen
			fE.SetAlpha(1.0)
			fE.SetColor(255, 255, 0)
			fE.GetCanvas().DrawText( "FPS= "+fE.GetFPS(),fE.GetLocalX(10), fE.GetLocalY(10))

			If guiBtn.GetPressed()=True
				fE.GetCanvas().DrawText(">>> Button Pressed <<<",fE.GetLocalX(fE.GetCanvasWidth()/2.0),fE.GetLocalY(fE.GetCanvasHeight()/2.0),0.5, 0.5)
				'Print ("OnRender Button pressed")
			Else
				fE.GetCanvas().DrawText(">>> Button not pressed <<<",fE.GetLocalX(fE.GetCanvasWidth()/2.0),fE.GetLocalY(fE.GetCanvasHeight()/2.0),0.5, 0.5)
				'Print ("OnRender Button not pressed")
			Endif

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
	Method OnObjectTouch:Int(obj:ftObject, touchId:Int)
	
		' This method is called when an object was touched
		Local timeDelta:Float = Float(Self.GetDeltaTime())/60.0
		Select obj 
			Case _g.guiBtn
				If _g.guiBtn.GetPressed()=True
					Print("OnObjectTouch GetPressed TRUE")		
				Else
					Print("OnObjectTouch GetPressed FALSE")		
				Endif
		End
		Return True
	End
End

'***************************************
Function Main:Int()
	' Create an instance of the cGame class and store it inside the global var '_g'
	_g = New cGame
	
	Return 0
End


