#rem
	Title:        fantomX
	Description:  A 2D game framework for the Monkey programming language
	
	Author:       Michael Hartlef
	Contact:      michaelhartlef@gmail.com
	
	Website:      http://www.fantomgl.com
	
	License:      MIT
#End

'nav:<blockquote><nav><b>fantomX documentation</b> | <a href="index.html">Home</a> | <a href="classes.html">Classes</a> | <a href="3rdpartytools.html">3rd party tools</a> | <a href="examples.html">Examples</a> | <a href="changes.html">Changes</a></nav></blockquote>
'header:The cftCamera module adds multiple cameras/windows to fantomX.

'#DOCON#

Import fantomX


'***************************************
#Rem
'summery:The class [b]ftCamera[/b] represents a window on the mojo2 canvas. 
#End
Class ftCamera
'#DOCOFF#
	Field engine:ftEngine = Null
	Field camNode:list.Node<ftCamera> = Null
	Field xPos:Float = 0.0
	Field yPos:Float = 0.0
	Field top:Int = 0
	Field left:Int = 0
	Field width:Int = 0
	Field height:Int = 0
	'------------------------------------------
	Method CalcLetterbox:Void( vwidth:Float,vheight:Float,devrect:Int[],vprect:Int[] )
	
		Local vaspect:=vwidth/vheight
		Local daspect:=Float(devrect[2])/devrect[3]

		If daspect>vaspect
			vprect[2]=devrect[3]*vaspect
			vprect[3]=devrect[3]
			vprect[0]=(devrect[2]-vprect[2])/2+devrect[0]
			vprect[1]=devrect[1]
		Else
			vprect[2]=devrect[2]
			vprect[3]=devrect[2]/vaspect
			vprect[0]=devrect[0]
			vprect[1]=(devrect[3]-vprect[3])/2+devrect[1]
		Endif
	
	End
	'------------------------------------------
'summery:Removes this view.
	Method Remove:Void()
		If Self.engine <> Null Then
			Self.camNode.Remove()     
			Self.engine = Null
		Endif
	End
	'------------------------------------------
'summery:Set the position of the camera.
	Method SetPos:Void(x:Float, y:Float, relative:Int = False )
		If relative = True
			Self.xPos += x
			Self.yPos += y
		Else
			Self.xPos = x
			Self.yPos = y
		Endif
	End
	'------------------------------------------
'summery:Set the X-position of the camera.
	Method SetPosX:Void(x:Float, relative:Int = False )
		If relative = True
			Self.xPos += x
		Else
			Self.xPos = x
		Endif
	End
	'------------------------------------------
'summery:Set the Y-position of the camera.
	Method SetPosY:Void(y:Float, relative:Int = False )
		If relative = True
			Self.yPos += y
		Else
			Self.yPos = y
		Endif
	End
	'------------------------------------------
'summery:Removes this view.
	Method SetDimensions:Void(cleft:Int, ctop:Int, cwidth:Int, cheight:Int)
		Self.top = ctop
		Self.left = cleft
		Self.width = cwidth
		Self.height = cheight
	End
	'------------------------------------------
'summery:Use this camera and setup the render according to its values.
	Method Use:Void()
		'Local vprect:Int[4]
		Self.engine.currCamera = Self
		Self.engine.camX = Self.xPos
		Self.engine.camY = Self.yPos
		'CalcLetterbox( Self.width, Self.height, [Self.left, Self.top, Self.right, Self.bottom] ,vprect )
		'Self.engine.currentCanvas.SetViewport vprect[0],vprect[1],vprect[2],vprect[3]
		'Self.engine.currentCanvas.SetViewport Self.left*Self.engine.scaleX+Self.engine.autofitX*1, Self.top*Self.engine.scaleY+Self.engine.autofitY*1, Self.width*Self.engine.scaleX+Self.engine.autofitX, Self.height*Self.engine.scaleY+Self.engine.autofitY
		'Self.engine.currentCanvas.SetProjection2d (0,Self.width*Self.engine.scaleX+Self.engine.autofitX*0,0,Self.height*Self.engine.scaleY+Self.engine.autofitY*0)

	End
'#DOCON#	
End
'***************************************
#Rem
'summery:The class [b]ftCameraMng[/b] manages alls cameras created by fantomX. 
#End
Class ftCameraMng
'#DOCOFF#
	Field engine:ftEngine = Null
	Field camList := New List<ftCamera>
	Field engineNode:list.Node<ftCameraMng> = Null
'#DOCON#	
	'------------------------------------------
'summery:Creates a new view with a new canvas.
	Method CreateCamera:ftCamera()
		Local newCam:ftCamera = New ftCamera
		newCam.camNode = camList.AddLast(newCam)
		newCam.engine = Self.engine
		newCam.SetDimensions(0,0, DeviceWidth(),DeviceHeight())
		Return newCam
	End	
	'------------------------------------------
'summery:Removes all cameras.
	Method RemoveAllCameras:Void()
		For Local cam:ftCamera = Eachin camList.Backwards()
			cam.Remove()
		Next
	End
End


#rem
footer:This fantomX framework is released under the MIT license:
[quote]Copyright (c) 2011-2016 Michael Hartlef

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the software, and to permit persons to whom the software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
[/quote]
#end