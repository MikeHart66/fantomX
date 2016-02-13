Strict

#rem
	Script:			MultiClass.monkey
	Description:	This sample script shows how to split your project into several classes and files
	Author: 		Michael Hartlef
	Version:      	2.0
#End

' Set the AutoSuspend functionality to TRUE so OnResume/OnSuspend are called
#MOJO_AUTO_SUSPEND_ENABLED=True

'Set to false to disable webaudio support for mojo audio, and to use older multimedia audio system instead.
#HTML5_WEBAUDIO_ENABLED=True

' Import the fantomX framework which imports mojo2 itself
Import fantomX
Import gameClass
Import engineClass
Import setupClass
Import customObjClass

' The _g variable holds an instance to the cGame class
Global _g:cGame


'***************************************
Function Main:Int()
	' Create an instance of the cGame class and store it inside the global var '_g'
	_g = New cGame
	
	Return 0
End


