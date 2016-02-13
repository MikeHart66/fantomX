#rem
	Title:        fantomX
	Description:  A 2D game framework for the Monkey programming language
	
	Author:       Michael Hartlef
	Contact:      michaelhartlef@gmail.com
	
	Website:      http://www.fantomgl.com
	
	License:      MIT
#End

Import fantomX
'Global dbXXX:Int = 0

'nav:<blockquote><nav><b>fantomX documentation</b> | <a href="index.html">Home</a> | <a href="classes.html">Classes</a> | <a href="3rdpartytools.html">3rd party tools</a> | <a href="examples.html">Examples</a> | <a href="changes.html">Changes</a></nav></blockquote>

'#DOCON#

#Rem
'header:The class [b]ftObject[/b] offers you a huge set of methods to deal with its object. And object can either be an (animated) image, a bitmap font text, a tile map, a primitive (circle, rectangle) or a zone (circle, rectangle). 
#End
'***************************************
Class ftObject
'#DOCOFF#
	Field xPos:Float = 0.0
	Field yPos:Float = 0.0
	Field zPos:Float = 0.0
	Field w:Float = 0.0
	Field h:Float = 0.0

'**---------------------------------------------------------------------------------------------------------------------------------------**
	Field x2:Float = 0.0								'Render -- case ftEngine.otLine
	Field y2:Float = 0.0								'Render -- case ftEngine.otLine
	Field verts:Float[]
'**---------------------------------------------------------------------------------------------------------------------------------------**


	Field rw:Float = 0.0
	Field rh:Float = 0.0
	Field rox:Float = 0.0
	Field roy:Float = 0.0
	
	Field angle:Float = 0.0
	Field scaleX:Float = 1.0
	Field scaleY:Float = 1.0
	Field radius:Float = 1.0
	Field friction:Float = 0.0
	
	Field speed:Float = 0.0
	Field speedX:Float = 0.0
	Field speedY:Float = 0.0
	Field speedSpin:Float = 0.0
	Field speedAngle:Float = 0.0
	Field speedMax:Float = 9999.0
	Field speedMin:Float = -9999.0
	
	Field engine:ftEngine = Null
	
	Field red:Float   = 255.0
	Field blue:Float  = 255.0
	Field green:Float = 255.0
	Field alpha:Float = 1.0
	Field blendMode:Int = BlendMode.Alpha 
	
	Field objImg:ftImage[1]
	
	Field frameCount:Float = 1
	Field frameStart:Float = 0
	Field frameEnd:Float = 0
	Field frameLength:Float = 0
	
	Field layer:ftLayer = Null
	Field layerNode:list.Node<ftObject> = Null 
	
	Field parentObj:ftObject = Null
	Field parentNode:list.Node<ftObject> = Null
	
 	Field timerList := New List<ftTimer>
	Field childObjList := New List<ftObject>
	Field transitionList := New List<ftTrans>

	Field marker:ftMarker = Null
	Field markerNode:list.Node<ftObject> = Null
	
	
	Field objFont:ftFont = Null
	
	Field id:Int = 0
	Field textMode:Int = 0
	Field name:String = ""
	Field text:String = ""
	Field tag:Int = 0
	Field type:Int = ftEngine.otImage
	Field groupID:Int = 0
	
	Field collType:Int = 0
	Field collScale:Float = 1.0
	Field collGroup:Int = 0
	Field collWith:Int[] = [0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0]
	Field colCheck:Bool = False
	
	Field isVisible:Bool = True
	Field isAnimated:Bool = False
	Field isActive:Bool = True
	Field isWrappingX:Bool = False
	Field isWrappingY:Bool = False
	Field touchMode:Int = 0
	Field isFlipH:Bool = False    'Up/Down     =Y
	Field isFlipV:Bool = False    'Left/Right  =X

	Field onDeleteEvent:Bool = False
	Field onRenderEvent:Bool = False
	Field onUpdateEvent:Bool = True
	
	Field x1c:Float = 0.0
	Field y1c:Float = 0.0
	Field x2c:Float = 0.0
	Field y2c:Float = 0.0
	Field x3c:Float = 0.0
	Field y3c:Float = 0.0
	Field x4c:Float = 0.0
	Field y4c:Float = 0.0

	Field deleted:Bool = False

	Field tileMap:ftTileMap = Null	
	Field dataObj:Object = Null
#If FantomX_UsePhysics = 1
	Field box2DBody:Object = Null
#Endif	
	Field objPathUpdAngle:Bool = False
	
	Field offAngle:Float = 0.0
	Field handleX:Float = 0.5
	Field handleY:Float = 0.5
	Field hOffX:Float = 0.0
	Field hOffY:Float = 0.0
	
	Field animMng:ftObjAnimMng = Null
	Field currImageIndex:Int = 1
	Field currImageFrame:Int = 1
	
	Field minX:Float
	Field minY:Float
	Field maxX:Float
	Field maxY:Float
	

'#DOCON#	
	'-----------------------------------------------------------------------------
#Rem
'summery:Activates the ftEngine.OnObjectDelete method to be called for an object when it will be removed through the Remove method with the direct flag.
'By default this flag is set OFF.
#End
'seeAlso:Remove
	Method ActivateDeleteEvent:Void (onOff:Bool = True )
		Self.onDeleteEvent = onOff
	End	
	'-----------------------------------------------------------------------------
#Rem
'summery:Activates the ftEngine.OnObjectRender method to be called for a visible object during the execution of the ftEngine.Render() method.
'By default this flag is set OFF.
#End
'seeAlso:ftEngine.Render,ftLayer.Render
	Method ActivateRenderEvent:Void (onOff:Bool = True )
		Self.onRenderEvent = onOff
	End	
	'-----------------------------------------------------------------------------
#Rem
'summery:Activates the ftEngine.OnObjectUpdate? method to be called for an active object during ftEngine.Update.
'By default this flag is set ON.
#End
'seeAlso:ftEngine.Update,ftEngine.OnObjectUpdate
	Method ActivateUpdateEvent:Void (onOff:Bool = True )
		Self.onUpdateEvent = onOff
	End	
	'----------------------------------------------------------
'summery:Add to an existing animation. Image and frame indexes start at 1.
	Method AddAnim:Void(animName:String, imgIndex:Int, _frameStart:Int = 1, _frameEnd:Int = 1)
		Local cc:Int = Self.objImg.Length()
#If CONFIG="debug"
		If cc < imgIndex Or imgIndex < 1 Then Error("~n~nError in file fantomX.cftObject, Method ftObject.AddAnim:Void(animName:String, imgIndex:Int, _frameStart:Int = 1, _frameEnd:Int = 1):~n~nimgIndex ("+imgIndex+") is out of bounds (1-"+cc+")")
#End
		Local ifc:Int = Self.objImg[imgIndex-1].img.Length()
#If CONFIG="debug"
		If  ifc < _frameEnd Or _frameStart < 1 Then Error("~n~nError in file fantomX.cftObject, Method ftObject.AddAnim:Void(animName:String, imgIndex:Int, _frameStart:Int = 1, _frameEnd:Int = 1):~n~nThe frame range ("+_frameStart+"-"+_frameEnd+") is out of bounds (1-"+ifc+")")
#End
		Self.animMng.AddAnim(animName, imgIndex, _frameStart, _frameEnd)
	End
	'----------------------------------------------------------
'summery:Add to an existing animation. Image and frame indexes start at 1.
	Method AddAnim:Void(animName:String, imgName:String, _frameStart:Int = 1, _frameEnd:Int = 1)
		Local imgIndex:Int = Self.GetImageIndex(imgName)
#If CONFIG="debug"
		If imgIndex < 1 Then Error("~n~nError in file fantomX.cftObject, Method ftObject.AddAnim:Void(animName:String, imgName:String, _frameStart:Int = 1, _frameEnd:Int = 1):~n~nThe image "+imgName+" was not loaded for this object.")
#End
		Local ifc:Int = Self.objImg[imgIndex-1].img.Length()
#If CONFIG="debug"
		If  ifc < _frameEnd Or _frameStart < 1 Then Error("~n~nError in file fantomX.cftObject, Method ftObject.AddAnim:Void(animName:String, imgName:String, _frameStart:Int = 1, _frameEnd:Int = 1):~n~nThe frame range ("+_frameStart+"-"+_frameEnd+") is out of bounds (1-"+ifc+")")
#end
		Self.animMng.AddAnim(animName, imgIndex, _frameStart, _frameEnd)
	End
	'----------------------------------------------------------
'changes:2.01:New flags parameter
'summery:Adds a single image (frame) to an object.
	Method AddImage:Void(filename:String, flags:Int=Image.Filter)
		Local currSize:Int = Self.objImg.Length()
		Self.objImg = Self.objImg.Resize(currSize + 1)
		currSize += 1
		Self.objImg[currSize-1] = Self.engine.imgMng.LoadImage(filename, 1, flags)
#If CONFIG="debug"
		If Self.objImg[currSize-1] = Null Then Error("~n~nError in file fantomX.cftObject, Method AddImage:Void(filename:String)~n~nImage "+filename+" not found!")
#End
	End
	'----------------------------------------------------------
'summery:Adds a single image (frame) to an object.
	Method AddImage:Void(image:Image)
		Local currSize:Int = Self.objImg.Length()
		Self.objImg = Self.objImg.Resize(currSize + 1)
		currSize += 1

		Self.objImg[currSize-1] = Self.engine.imgMng.LoadImage(image)
#If CONFIG="debug"
		If Self.objImg[currSize-1] = Null Then Error("~n~nError in file fantomX.cftObject, Method AddImage:Void(image:Image)~n~nCould not assign Image!")
#End
	End
	'----------------------------------------------------------
'summery:Adds a single image object (frame) to an object.
	Method AddImageObj:Void(imageObj:ftImage)
		Local currSize:Int = Self.objImg.Length()
		Self.objImg = Self.objImg.Resize(currSize + 1)
		currSize += 1

		Self.objImg[currSize-1] = imageObj
#If CONFIG="debug"
		If Self.objImg[currSize-1] = Null Then Error("~n~nError in file fantomX.cftObject, Method AddImageObj:Void(imageObj:ftImage)~n~nCould not assign Image!")
#End
	End
	'-----------------------------------------------------------------------------
'summery:Adds speed to the object. If an angle is given, the speed will be added in that direction. If not, then in the objects angle.
'seeAlso:SetSpeed,GetSpeed,SetMaxSpeed,SetMinSpeed
	Method AddSpeed:Void (sp:Float, ang:Float=9876.5)
	    Local a:Float
		
	    If ang = 9876.5 Then
	        a = angle
	    Else
	        a = ang
	    Endif

	    speedX = speedX + Sin(a) * sp
	    speedY = speedY - Cos(a) * sp
	
	    a= ATan2( speedY, speedX )+90.0
	    If a < 0.0 Then
	        a = a + 360.0
	    Else
	        If a > 360.0 Then
			    a = a - 360.0
	        Endif
	    Endif
	    speedAngle = a 
	    speed = Sqrt(speedX * speedX + speedY * speedY)
		If speed > speedMax Then speed = speedMax
	End
	'-----------------------------------------------------------------------------
'summery:Add an alpha transition to an existing transition.
'seeAlso:CreateTransAlpha
	Method AddTransAlpha:Void(trans:ftTrans, alpha:Float, relative:Int)
		trans.AddAlpha(alpha,Self,trans.duration, relative)
	End
	'-----------------------------------------------------------------------------
'summery:Add a position transition to an existing transition.
'seeAlso:CreateTransPos
	Method AddTransPos:Void(trans:ftTrans, xt:Float, yt:Float, relative:Int)
		trans.AddPos(xt, yt, Self, trans.duration, relative)
	End
	'-----------------------------------------------------------------------------
'summery:Add a rotation transition to an existing transition.
'seeAlso:CreateTransot
	Method AddTransRot:Void(trans:ftTrans, rot:Float, relative:Int)
		trans.AddRot(rot, Self, trans.duration, relative)
	End
	'-----------------------------------------------------------------------------
'summery:Add a scaling transition to an existing transition.
'seeAlso:CreateTransScale
	Method AddTransScale:Void(trans:ftTrans, sca:Float, relative:Int)
		trans.AddScale(sca, Self, trans.duration, relative)
	End
	'-----------------------------------------------------------------------------
'summery:Cancels all timers attached to an object.
'seeAlso:CreateTimer,PauseTimerAll,ResumeTimerAll
	Method CancelTimerAll:Void()
		For Local timer := Eachin timerList 
			timer.RemoveTimer()
		Next
	End
	'-----------------------------------------------------------------------------
'summery:Cancels all transitions attached to an object.
'seeAlso:PauseTransAll,ResumeTransAll
	Method CancelTransAll:Void()
		For Local trans := Eachin transitionList    
			trans.Cancel()
		Next
	End
	'-----------------------------------------------------------------------------
#Rem
'summery:Check if a collision has happened for this object.
The following collision types are valid at the moment:
[list]ftEngine.ctCircle   (Value = 0)
ftEngine.ctBox%   (Value = 1 -> rotated bounding box)
ftEngine.ctBound   (Value = 2 -> non-rotated bounding box)
ftEngine.ctLine   (Value = 3)[/list]
#End
'seeAlso:SetColWith,SetColType,SetColGroup,SetColScale
	Method CheckCollision:Bool(sp2:ftObject)
		If sp2.deleted = False And Self.deleted = False Then
			If sp2.collGroup > 0 And sp2.isActive Then
				If (Self.collWith[(sp2.collGroup-1)]>0) Then
					Select Self.collType
						Case ftEngine.ctCircle
							Select sp2.collType  
								Case ftEngine.ctLine
									Return ftColl_Circle2LineObj(Self, sp2)
								Case ftEngine.ctBox, ftEngine.ctBound
									Return ftColl_Circle2Box(Self, sp2)
								Default
									Return ftColl_Circle2Circle(Self, sp2)
							End
						Case ftEngine.ctBox
							Select sp2.collType  
								Case ftEngine.ctCircle
									Return ftColl_Box2Circle(Self, sp2)
								Default
									Return ftColl_Box2Box(Self, sp2)
							End
						Case ftEngine.ctBound
							Select sp2.collType  
								Case ftEngine.ctCircle
									Return ftColl_Box2Circle(Self, sp2)
								Case ftEngine.ctBox, ftEngine.ctLine
									Return ftColl_Box2Box(Self, sp2)
								Default
									Return ftColl_Bound2Bound(Self, sp2)
							End
						Case ftEngine.ctLine
							Select sp2.collType  
								Case ftEngine.ctCircle
									Return ftColl_Circle2LineObj(sp2, Self)
								Default
									Return ftColl_Box2Box(Self, sp2)
							End
						Default
							Return ftColl_Circle2Circle(Self, sp2)
					End
				Endif
			Endif
		Endif
		Return False
	End
	'-----------------------------------------------------------------------------
#Rem
'summery:Check if a touch has happened.
The following touch types are valid at the moment:
[list]ftEngine.tmCircle   (Value = 1)
ftEngine.tmBound   (Value = 2)
ftEngine.tmBox   (Value = 3)[/list]
#End
'seeAlso:GetTouchMode,SetTouchMode
	Method CheckTouchHit:Bool(px:Float, py:Float)
		Local txOff:Float = 0.0
		Local tyOff:Float = 0.0
		Local ret:Bool = False

		If deleted = False Then
			Select type

				Case ftEngine.otText
					Select textMode
						Case 0   'taTopLeft
							txOff = -(Float(Self.objFont.Length(Self.text))/2.0)*Self.scaleX
							tyOff = (Self.objFont.lineHeight/2.0*Self.scaleY)
							
				     	Case 1   'taTopCenter
							txOff = 0.0
							tyOff = (Self.objFont.lineHeight/2.0*Self.scaleY)
							
						Case 2   'taTopRight
							txOff = (Float(Self.objFont.Length(Self.text))/2.0)*Self.scaleX
							tyOff = (Self.objFont.lineHeight/2.0*Self.scaleY)
						
						Case 7   'taCenterLeft
							txOff = -(Float(Self.objFont.Length(Self.text))/2.0)*Self.scaleX
							tyOff = 0.0
							
				     	Case 3   'taCenterCenter
							txOff = 0.0
							tyOff = 0.0
							
						Case 4   'taCenterRight
							txOff = (Float(Self.objFont.Length(Self.text))/2.0)*Self.scaleX
							tyOff = 0.0
														
						Case 8   'taBottomLeft
							txOff = -(Float(Self.objFont.Length(Self.text))/2.0)*Self.scaleX
							tyOff = -(Self.objFont.lineHeight/2.0*Self.scaleY)
							
				     	Case 5   'taBottomCenter
							txOff = 0.0
							tyOff = -(Self.objFont.lineHeight/2.0*Self.scaleY)
							
						Case 6   'taBottomRight
							txOff = (Float(Self.objFont.Length(Self.text))/2.0)*Self.scaleX
							tyOff = -(Self.objFont.lineHeight/2.0*Self.scaleY)
						
					End
					
					Select Self.touchMode
				     	Case ftEngine.tmCircle
							ret = ftColl_PointInsideCircle(Self, px+txOff, py-tyOff)
						Case ftEngine.tmBound
							ret = ftColl_PointInsideBound(Self, px+txOff, py-tyOff)
						Case ftEngine.tmBox
							ret = ftColl_PointInsidePolygon(Self, px+txOff, py-tyOff)
					End
				Default
					Select Self.touchMode
				     	Case ftEngine.tmCircle
							ret = ftColl_PointInsideCircle(Self, px, py)
						Case ftEngine.tmBound
							ret = ftColl_PointInsideBound(Self, px, py)
						Case ftEngine.tmBox
							ret = ftColl_PointInsidePolygon(Self, px+txOff, py-tyOff)
					End
			End
		Endif

		Return ret
	End
'#DOCOFF#	
	'-----------------------------------------------------------------------------
	Method CleanupLists:Void()
		Local a:String
		For Local trans:ftTrans = Eachin Self.transitionList
			If trans.deleted Then trans.Cancel()
		Next

		For Local timer:ftTimer = Eachin Self.timerList
'Bug fix to prevent Error:1023 Stack overflow
	#If TARGET = "flash" Then
		 	_XWA(0)
	#End
			If timer.deleted Then timer.RemoveTimer()
		Next
	End
'#DOCON#
	'----------------------------------------------------------
'summery:Add a animation sequence to an object. This way an object becomes animated.
'seeAlso:AddAnim
	Method CreateAnim:Void(animName:String, imgIndex:Int, _frameStart:Int = 1, _frameEnd:Int = 1, _repeatCount:Int = -1)
		Local cc:Int = Self.objImg.Length()
#If CONFIG="debug"
		If cc < imgIndex Or imgIndex < 1 Then Error("~n~nError in file fantomX.cftObject, Method ftObject.CreateAnim:Void(animName:String, imgIndex:Int, _frameStart:Int = 1, _frameEnd:Int = 1):~n~nimgIndex ("+imgIndex+") is out of bounds (1-"+cc+")")
#End
		Local ifc:Int = Self.objImg[imgIndex-1].img.Length()
#If CONFIG="debug"
		If  ifc < _frameEnd Or _frameStart < 1 Then Error("~n~nError in file fantomX.cftObject, Method CreateAnim:Void(animName:String, imgIndex:Int, _frameStart:Int = 1, _frameEnd:Int = 1):~n~nThe frame range ("+_frameStart+"-"+_frameEnd+") is out of bounds (1-"+ifc+")")
#End
		If Self.animMng = Null Then
			Self.animMng = New ftObjAnimMng
			Self.animMng.animObj = Self
			Self.SetAnimated(True)
		Endif
		Self.animMng.CreateAnim(animName, imgIndex, _frameStart, _frameEnd)
		Self.SetAnimRepeatCount(_repeatCount)
	End
	'----------------------------------------------------------
'summery:Add a animation sequence to an object. This way an object becomes animated.
'seeAlso:AddAnim
	Method CreateAnim:Void(animName:String, imgName:String, _frameStart:Int = 1, _frameEnd:Int = 1, _repeatCount:Int = -1)
		Local imgIndex:Int = Self.GetImageIndex(imgName)
#If CONFIG="debug"
		If imgIndex < 1 Then Error("~n~nError in file fantomX.cftObject, Method ftObject.CreateAnim:Void(animName:String, imgName:String, _frameStart:Int = 1, _frameEnd:Int = 1):~n~nThe image "+imgName+" was not loaded for this object.")
#End
		Local ifc:Int = Self.objImg[imgIndex-1].img.Length()
#If CONFIG="debug"
		If  ifc < _frameEnd Or _frameStart < 1 Then Error("~n~nError in file fantomX.cftObject, Method CreateAnim:Void(animName:String, imgName:String, _frameStart:Int = 1, _frameEnd:Int = 1):~n~nThe frame range ("+_frameStart+"-"+_frameEnd+") is out of bounds (1-"+ifc+")")
#End
		If Self.animMng = Null Then
			Self.animMng = New ftObjAnimMng
			Self.animMng.animObj = Self
			Self.SetAnimated(True)
		Endif
		Self.animMng.CreateAnim(animName, imgIndex, _frameStart, _frameEnd)
		Self.SetAnimRepeatCount(_repeatCount)
	End
	'-----------------------------------------------------------------------------
#Rem
'summery:Create a timer for this object. 
'A repeatCount of -1 will let the timer run forever. The duration is the time in milliseconds, after which the [b]ftEngine.OnObjectTimer[/b] method is called.
#End
'seeAlso:
	Method CreateTimer:ftTimer(timerID:Int, duration:Int, repeatCount:Int = 0 )
		Local timer:ftTimer = New ftTimer
		timer.engine = Self.engine
		timer.currTime = Self.engine.time
		timer.duration = duration
		timer.id = timerID

		timer.intervall = duration
		timer.loop = repeatCount
		timer.obj = Self
		timer.timerNode = Self.timerList.AddLast(timer)
		Return timer
	End
	'-----------------------------------------------------------------------------
#Rem
'summery:Create an alpha transition.
'The duration is the time in milliseconds, the transition takes to complete. Only a transID > 0 will fire the [b]ftEngine.OnObjectTrans[/b] method.
#End
'seeAlso:AddTransAlpha
	Method CreateTransAlpha:ftTrans(transAlpha:Float, duration:Float, relative:Int, transId:Int=0 )
		Local trans:ftTrans = New ftTrans
		trans.engine = Self.engine
		trans.obj = Self
		trans.layer = Null
		trans.currTime = Self.engine.time
		trans.finishID = transId
		trans.duration = duration
		trans.AddAlpha(transAlpha,Self,duration, relative)
		
		trans.transNode = Self.transitionList.AddLast(trans)
		Return trans
	End
	'-----------------------------------------------------------------------------
#Rem
'summery:Create a position transition.
'The duration is the time in milliseconds, the transition takes to complete. Only a transID > 0 will fire the [b]ftEngine.OnObjectTrans[/b] method.
#End
'seeAlso:AddTransPos
	Method CreateTransPos:ftTrans(xt:Float, yt:Float, duration:Float, relative:Int, transId:Int=0 )
		Local trans:ftTrans = New ftTrans
		trans.engine = Self.engine
		trans.obj = Self
		trans.layer = Null
		trans.currTime = Self.engine.time
		trans.finishID = transId
		trans.duration = duration
		trans.AddPos(xt, yt, Self, duration, relative)
		trans.transNode = Self.transitionList.AddLast(trans)
		Return trans
	End
	'-----------------------------------------------------------------------------
#Rem
'summery:Create a rotation transition.
'The duration is the time in milliseconds, the transition takes to complete. Only a transID > 0 will fire the [b]ftEngine.OnObjectTrans[/b] method.
#End
'seeAlso:AddTransRot
	Method CreateTransRot:ftTrans(transRotation:Float, duration:Float, relative:Int, transId:Int=0 )
		Local trans:ftTrans = New ftTrans
		trans.engine = Self.engine
		trans.obj = Self
		trans.layer = Null
		trans.currTime = Self.engine.time
		trans.finishID = transId
		trans.duration = duration
		trans.AddRot(transRotation, Self, duration, relative )
		trans.transNode = Self.transitionList.AddLast(trans)
		Return trans
	End
	'-----------------------------------------------------------------------------
#Rem
'summery:Create a scaling transition.
'The duration is the time in milliseconds, the transition takes to complete. Only a transID > 0 will fire the [b]ftEngine.OnObjectTrans[/b] method.
#End
'seeAlso:AddTransScale
	Method CreateTransScale:ftTrans(transScale:Float, duration:Float, relative:Int, transId:Int=0 )
		Local trans:ftTrans = New ftTrans
		trans.engine = Self.engine
		trans.obj = Self
		trans.layer = Null
		trans.currTime = Self.engine.time
		trans.finishID = transId
		trans.duration = duration
		trans.AddScale(transScale, Self, duration, relative )
		trans.transNode = Self.transitionList.AddLast(trans)
		Return trans
	End
	'-----------------------------------------------------------------------------
'summery:Returns the active flag.
'seeAlso:SetActive
	Method GetActive:Bool()
		Return isActive
	End 
	'-----------------------------------------------------------------------------
'summery:Get the alpha value.
'seeAlso:SetAlpha
	Method GetAlpha:Float()
		Return alpha
	End 
	'-----------------------------------------------------------------------------
'summery:Get the angle the object is heading.
'seeAlso:SetAngle
	Method GetAngle:Float()
		Return angle
	End 
	'-----------------------------------------------------------------------------
'summery:Return the isAnimated flag.
'seeAlso:SetAnimated
	Method GetAnimated:Bool ()
		Return isAnimated
	End
	'-----------------------------------------------------------------------------
'summery:Get the number of frame from the active animation.
	Method GetAnimCount:Int ()
		Return Self.animMng.GetCurrAnimCount()
	End
	'-----------------------------------------------------------------------------
'summery:Get the current frame(time) of the active animation. It starts with 1.
'seeAlso:SetAnimFrame
	Method GetAnimFrame:Float ()
		Return Self.animMng.GetCurrAnimFrame()
	End
	'-----------------------------------------------------------------------------
'summery:Return the name from the active animation.
	Method GetAnimName:String ()
		Return Self.animMng.GetCurrAnimName()
	End
	'-----------------------------------------------------------------------------
'summery:Return the pause flag for the active animation of an animated object.
'seeAlso:SetAnimPaused
	Method GetAnimPaused:Bool ()
		Return Self.animMng.isAnimPaused
	End
	'-----------------------------------------------------------------------------
'summery:Get the frame time of the current animation.
'seeAlso:SetAnimTime
	Method GetAnimTime:Float ()
		Return Self.animMng.GetCurrAnimTime()
	End
	'-----------------------------------------------------------------------------
#rem
'summery:Get the blend mode of an object.
'Used are the regular mojo2 blend modes.
#end
'seeAlso:SetBlendMode
	Method GetBlendMode:Int ()
		Return Self.blendMode
	End
	'-----------------------------------------------------------------------------
'summery:Get the child object with the given index (Index starts with 1).
'seeAlso:GetParent,SetParent
	Method GetChild:ftObject (index:Int)
		Local c:Int
		Local cc:Int = childObjList.Count()
#If CONFIG="debug"
		If index < 1 Or index > cc Then Error ("~n~nError in file fantomX.cftObject, Method ftObject.GetChild():~n~nUsed index ("+index+") is out of bounds (1-"+cc+")")
#End
		For Local child := Eachin childObjList
			c += 1
			If c = index Then Return child
		Next
		Return Null
	End
	'-----------------------------------------------------------------------------
'summery:Returns the child count of an object.
	Method GetChildCount:Int ()
		Return childObjList.Count()
	End
	'-----------------------------------------------------------------------------
#rem
'summery:Returns the closest active object.
'If useRadius is set to FALSE, the distance between each object will be calculated from its position, 
'without taking its radius into the calculation.
#end
	Method GetClosestObj:ftObject (useRadius:Bool = True)
		Local dist:Float = 0.0
		Local tmpDist:Float = 0.0
		Local co:ftObject = Null
		Local obj:ftObject = Null
		For obj = Eachin Self.layer.objList
			If obj.isActive = True Then
				If obj <> Self Then 
					tmpDist = Self.GetTargetDist(obj, useRadius)
					If co = Null Then
						dist = tmpDist
						co = obj
					Else
						If tmpDist < dist Then
							dist = tmpDist
							co = obj
						Endif
					Endif
				Endif
			Endif
		Next
		Return co
	End	
	'-----------------------------------------------------------------------------
#rem
'summery:Returns the collision group of an object.
'A value of 0 means that collisions for this object are disabled.
#End
'seeAlso:SetColGroup,SetColWith,CheckCollision
	Method GetColGroup:Int ()
		Return collGroup
	End	
	'-----------------------------------------------------------------------------
'summery:Returns the color of an object in an array.
'seeAlso:SetColor
	Method GetColor:Float[]()
		Local c:Float[3]
		c[0] = Self.red
		c[1] = Self.green
		c[2] = Self.blue
		Return c
	End
	'-----------------------------------------------------------------------------
#rem
'summery:Returns the collision type of an object.
'Collision types can be:
[list][*]Const ctCircle% = 0
[*]Const ctBox% = 1   (this will check against the rotated box of the Object)
[*]Const ctBound% = 2   (This will check against the bounding box of the Object)
[*]Const ctLine% = 3[/list]
#End
'seeAlso:SetColType,SetColWith,CheckCollision
	Method GetColType:Int ()
		Return collType
	End	
	'-----------------------------------------------------------------------------
'summery:Returns the data object of this object.
'seeAlso:SetDataObj
	Method GetDataObj:Object ()
		Return dataObj
	End	
	'-----------------------------------------------------------------------------
#Rem
'summery:Returns an edge position (bottom,top,left,right) of the object.
'The edge parameter can have the following values:
'[list][*]1 = Bottom edge
[*]2 = Top edge
[*]3 = Left edge
[*]4 = Right edge[/list]
'
'If the relative flag is set, then you only get the distance in pixel towards that edge
#End
	Method GetEdge:Float(edge:Int=1, relative:Int = False )
		Local ret:Float = 0.0
		Local xp:Float = 0.0
		Local yp:Float = 0.0
		
		If relative = False Then 
			xp = Self.xPos
			yp = Self.yPos
		Endif
		Select edge
			Case 1		'Bottom
				ret = yp + ((h*Self.scaleY)/2.0)+Self.hOffY
			Case 2		'Top
				ret = yp - ((h*Self.scaleY)/2.0)+Self.hOffY
			Case 3		'Left
				ret = xp - ((w*Self.scaleX)/2.0)+Self.hOffX
			Case 4		'Right
				ret = xp + ((w*Self.scaleX)/2.0)+Self.hOffX
#If CONFIG="debug"
			Default		'Error
				Error ("~n~nError in file fantomX.cftObject, Method ftObject.GetEdge():~n~nUsed edge value ("+edge+") is out of bounds (1-4)")
#End
		End
		Return ret
	End 
	'-----------------------------------------------------------------------------
#Rem
'summery:Returns the horizontal and vertical FLIP flags in a Bool array.
'Index 0 contains the horizontal flag and index 1 of the returned array contains the vertical flag.
#End
'seeAlso:SetFlip,GetFlipH,GetFlipV
	Method GetFlip:Bool[]()
		Local f:Bool[2]
		f[0] = Self.isFlipH
	    f[1] = Self.isFlipV
		Return f
	End
	'-----------------------------------------------------------------------------
'summery:Returns the horizontal FLIP flag.
'seeAlso:SetFlipH,GetFlip,GetFlipV
	Method GetFlipH:Bool()
		Return Self.isFlipH
	End
	'-----------------------------------------------------------------------------
'summery:Returns the vetical FLIP flag.
'seeAlso:SetFlipV,GetFlip,GetFlipH
	Method GetFlipV:Bool()
		Return Self.isFlipV
	End
	'-----------------------------------------------------------------------------
'summery:Get the friction value.
'seeAlso:SetFriction
	Method GetFriction:Float()
		Return friction
	End 
	'-----------------------------------------------------------------------------
'summery:Returns the group ID of an object.
'seeAlso:SetGroupID
	Method GetGroupID:Int ()
		Return groupID
	End	
	'-----------------------------------------------------------------------------
#Rem
'summery:Get the height of an object.
The returned value is the stored height multiplied by the Y scale factor.
#End
'seeAlso:,SetHeight,GetWidth
	Method GetHeight:Float()
		Return h*scaleY
	End 
	'-----------------------------------------------------------------------------
'summery:Returns the ID of an object.
'seeAlso:SetID
	Method GetID:Int ()
		Return id
	End	
	'-----------------------------------------------------------------------------
'summery:Returns the Image of an object. The index starts with 1.
	Method GetImage:Image(index:Int = 1)
		Local cc:Int = Self.objImg.Length()
#If CONFIG="debug"
		If cc < index Or index < 1 Then Error("~n~nError in file fantomX.cftObject, Method ftObject.GetImage:Image(index:Int = 1):~n~nIndex ("+index+") is out of bounds (1-"+cc+")")
#End
		Return Self.objImg[index-1].GetImage()[0]
	End	
	'-----------------------------------------------------------------------------
'summery:Returns the number of images of an object. 
	Method GetImageCount:Int()
		Return Self.objImg.Length()
	End	
	'-----------------------------------------------------------------------------
'summery:Returns the number of subframe from an image of an object. Index starts with 1.
	Method GetImageFrameCount:Int(index:Int = 1)
		Local cc:Int = Self.objImg.Length()
#If CONFIG="debug"
		If cc < index Or index < 1 Then Error("~n~nError in file fantomX.cftObject, Method ftObject.GetImageFrameCount:Int(index:Int = 1):~n~nIndex ("+index+") is out of bounds (1-"+cc+")")
#End
		Return Self.objImg[index-1].img.Length()
	End	
	'-----------------------------------------------------------------------------
'summery:Returns the name from an image of an object. Index starts with 1.
	Method GetImagePath:String(index:Int = 1)
		Local cc:Int = Self.objImg.Length()
#If CONFIG="debug"
		If cc < index Or index < 1 Then Error("~n~nError in file fantomX.cftObject, Method ftObject.GetImageName:String(index:Int = 1):~n~nIndex ("+index+") is out of bounds (1-"+cc+")")
#End
		Return Self.objImg[index-1].GetPath()
	End	
	'-----------------------------------------------------------------------------
'summery:Returns the index of an image with a given name. Index starts with 1.
	Method GetImageIndex:Int(imgPath:String)
		Local ic:Int = Self.objImg.Length()
		Local idx:Int = 0
		For Local index:Int = 1 To ic
			If Self.objImg[index-1].GetPath()=imgPath Then
				idx = index
				Exit
			Endif
		Next
		Return idx
	End	
	'-----------------------------------------------------------------------------
'summery:Returns the ftImage of an object. The index starts with 1.
'seeAlso:SetImageObj
	Method GetImageObj:ftImage(index:Int = 1)
		Local cc:Int = Self.objImg.Length()
#If CONFIG="debug"
		If cc < index Or index < 1 Then Error("~n~nError in file fantomX.cftObject, Method ftObject.GetImageObj:Image(index:Int = 1):~n~nIndex ("+index+") is out of bounds (1-"+cc+")")
#End
		Return Self.objImg[index-1]
	End	
	'------------------------------------------
'summery:Get the objects layer.
'seeAlso:SetLayer
	Method GetLayer:ftLayer()
		Return Self.layer
	End
	'-----------------------------------------------------------------------------
#Rem
'summery:Returns the tile map object with the given index. Index starts with 1.
#End
'seeAlso:GetMapObjCount
	Method GetMapObj:ftMapObj (index:Int)
		Local c:Int
		Local cc:Int = tileMap.mapObjList.Count()
#If CONFIG="debug"
		If index < 1 Or index > cc Then Error ("~n~nError in file fantomX.cftObject, Method ftObject.GetMapObj():~n~nUsed index ("+index+") is out of bounds (1-"+cc+")")
#End
		For Local mapObj := Eachin tileMap.mapObjList
			c += 1
			If c = index Then Return mapObj
		Next
		Return Null
	End
	'-----------------------------------------------------------------------------
#Rem
'summery:Returns the number of tile map objects.
'The objects were stored when a Tiled compatible map was loaded.
#End
'seeAlso:GetMapObj
	Method GetMapObjCount:Int ()
		Return tileMap.mapObjList.Count()
	End

	'-----------------------------------------------------------------------------
'summery:Get the name of an object.
'seeAlso:SetName
	Method GetName:String ()
		Return name
	End
	'------------------------------------------
'summery:Get the parent object.
'seeAlso:SetParent
	Method GetParent:ftObject()
		Return Self.parentObj
	End
	'-----------------------------------------------------------------------------
'summery:Returns the objects X and Y position in a 2D Float array.
'seeAlso:SetPos,GetPosX,GetPosY,GetPosZ
	Method GetPos:Float[]()
		Local p:Float[2]
		p[0] = xPos
	    p[1] = yPos
		Return p		
	End
	'-----------------------------------------------------------------------------
'summery:Get the X position.
'seeAlso:SetPosX,GetPos,GetPosY,GetPosZ
	Method GetPosX:Float()
		Return xPos
	End 
	'-----------------------------------------------------------------------------
'summery:Get the Y position.
'seeAlso:SetPosY,GetPosX,GetPos,GetPosZ
	Method GetPosY:Float()
		Return yPos
	End 
	'-----------------------------------------------------------------------------
'summery:Get the Z position.
'seeAlso:SetPosZ,GetPosX,GetPosY,GetPos
	Method GetPosZ:Float()
		Return zPos
	End 
	'-----------------------------------------------------------------------------
'summery:Returns the radius of an object.
'seeAlso:SetRadius
	Method GetRadius:Float()
		Return radius*scaleX
	End 
	'-----------------------------------------------------------------------------
'summery:Get current scale factor of an object.
'seeAlso:SetScale,GetScaleX,GetScaleY
	Method GetScale:Float()
		Return scaleX
	End 
	'-----------------------------------------------------------------------------
'summery:Returns the X scale factor (width) of the object.
'seeAlso:SetScaleX,GetScale,GetScaleY
	Method GetScaleX:Float()
		Return scaleX
	End 
	'-----------------------------------------------------------------------------
'summery:Returns the Y scale factor (height) of the object.
'seeAlso:SetScaleY,GetScaleX,GetScale
	Method GetScaleY:Float()
		Return scaleY
	End 
	'-----------------------------------------------------------------------------
'summery:Get current linear speed of an object.
'seeAlso:SetSpeed,GetSpeedAngle
	Method GetSpeed:Float()
		Return speed
	End 
	'-----------------------------------------------------------------------------
'summery:Get the current speed angle.
'seeAlso:SetSpeedangle,GetSpeed
	Method GetSpeedAngle:Float()
		Return Self.speedAngle
	End 
	'-----------------------------------------------------------------------------
'summery:Get the max speed of an object.
'seeAlso:SetMaxSpeed
	Method GetSpeedMax:Float()
		Return speedMax
	End 
	'-----------------------------------------------------------------------------
'summery:Get the minimum speed of an object.
'seeAlso:SetMinSpeed
	Method GetSpeedMin:Float()
		Return speedMin
	End 
	'-----------------------------------------------------------------------------
'summery:Get the current X speed.
'seeAlso:SetSpeedX,GetSpeed,GetSpeedY,GetSpeedXY
	Method GetSpeedX:Float()
		Return speedX
	End 
	'-----------------------------------------------------------------------------
'summery:Get current the X and Y speed of a 2D Float array.
'seeAlso:SetSpeed,GetSpeed,GetSpeedX,GetSpeedY
	Method GetSpeedXY:Float[]()
		Local sp:Float[2]
		sp[0] = speedX
	    sp[1] = speedY
		Return sp		
	End
	'-----------------------------------------------------------------------------
'summery:Get the current Y speed.
'seeAlso:SetSpeedY,GetSpeed,GetSpeedXX
	Method GetSpeedY:Float()
		Return speedY
	End 
	'-----------------------------------------------------------------------------
'summery:Get the spin speed value.
'seeAlso:SetSpin
	Method GetSpin:Float()
		Return speedSpin
	End 
	'-----------------------------------------------------------------------------
'summery:Get the object tag value.
'seeAlso:SetTag
	Method GetTag:Int ()
		Return tag
	End	
	'-----------------------------------------------------------------------------
#rem
'summery:Returns the angle to a target object.
'If the relative flag is set, then the angle takes the object angle into account.
#End
'seeAlso:GetTargetDist
	Method GetTargetAngle:Float(targetObj:ftObject, relative:Int=False)
		Local xdiff:Float
		Local ydiff:Float 
		Local ang:Float
			
		xdiff = targetObj.xPos - xPos
		ydiff = targetObj.yPos - yPos
			
    	ang = ATan2( ydiff, xdiff )+90.0
		If ang < 0 Then 
			ang = 360.0 + ang
		Endif
		If relative=True Then
			ang -= Self.angle
			If ang > 180.0 Then
				ang -= 360.0
			Elseif ang < -180.0 Then
				ang += 360.0
			Endif
		Endif
		Return ang
	End
	'-----------------------------------------------------------------------------
#rem
'summery:Get the distance to a target object.
'Which the useRadius flag set, it will substract the radius of each object from the distance
#end
'seeAlso:GetTargetAngle
	Method GetTargetDist:Float(targetObj:ftObject, useRadius:Bool = False)
		Local xdiff:Float
		Local ydiff:Float 
		Local dist:Float
		
		xdiff = targetObj.xPos - xPos
		ydiff = targetObj.yPos - yPos
		
		dist = Sqrt(xdiff * xdiff + ydiff * ydiff)
		If useRadius = True Then
			dist = dist - Self.GetRadius() - targetObj.GetRadius()
		Endif
		
		Return dist
	End
	'-----------------------------------------------------------------------------
'summery:Get the text field of an object.
'seeAlso:SetText
	Method GetText:String ()
		Return text
	End
	'-----------------------------------------------------------------------------
#Rem
'summery:Returns the tile index at the given canvas coordinates, starting from zero.
#End
'seeAlso:SetTileID
	Method GetTileAt:Int(xp:Int,yp:Int)
		Return Self.tileMap.GetTileAt(xp,yp)
	End
	'-----------------------------------------------------------------------------
'summery:Returns the total number of tiles of a tilemap. 
	Method GetTileCount:Int()
		Return Self.tileMap.GetTileCount()
	End
	'-----------------------------------------------------------------------------
'summery:Returns the number of tiles in the X direction. 
	Method GetTileCountX:Int()
		Return Self.tileMap.GetTileCountX()
	End
	'-----------------------------------------------------------------------------
'summery:Returns the number of tiles in the Y direction. 
	Method GetTileCountY:Int()
		Return Self.tileMap.GetTileCountY()
	End
	'-----------------------------------------------------------------------------
#Rem
'summery:Returns the height of a tile with the given index. Index starts at 0. 
#End
'seeAlso:GetTileWidth
	Method GetTileHeight:Int(index:Int)
		Return Self.tileMap.GetTileHeight(index)
	End
	'-----------------------------------------------------------------------------
#Rem
'summery:Returns the ID of the tiles texture map, at the given index, starting from zero. 
It returns -1 if there is no tile.
#End
'seeAlso:SetTileID
	Method GetTileID:Int(index:Int)
		Return Self.tileMap.GetTileID(index)
	End
	'-----------------------------------------------------------------------------
#Rem
'summery:Returns the ID of the tiles texture map, at the given map row and column, starting from zero. 
It returns -1 if there is no tile.
#End
'seeAlso:SetTileID
	Method GetTileID:Int(column:Int, row:Int)
		Return Self.tileMap.GetTileID(column, row)
	End
	'-----------------------------------------------------------------------------
#Rem
'summery:Returns the ID of the tiles texture, at the given canvas coordinates, starting from zero.
It returns -1 if there is no tile.
#End
'seeAlso:SetTileIDAt
	Method GetTileIDAt:Int(xp:Int,yp:Int)
		Return Self.tileMap.GetTileIDAt(xp,yp)
	End
	'-----------------------------------------------------------------------------
'summery:Returns the tileMap of this object. 
	Method GetTileMap:ftTileMap()
		Return Self.tileMap
	End
	'-----------------------------------------------------------------------------
'summery:Returns the X position of a tile with the given index. Index starts with 0. 
'seeAlso:GetTilePosY
	Method GetTilePosX:Float(index:Int)
		Return Self.tileMap.GetTilePosX(index)
	End
	'-----------------------------------------------------------------------------
'summery:Returns the Y position of a tile with the given index. Index starts with 0. 
'seeAlso:GetTimePoX
	Method GetTilePosY:Float(index:Int)
		Return Self.tileMap.GetTilePosY(index)
	End
	'-----------------------------------------------------------------------------
'summery:Returns the width of a tile with the given index. Index starts at 0. 
'seeAlso:GetTileHeight
	Method GetTileWidth:Int(index:Int)
		Return Self.tileMap.GetTileWidth(index)
	End

	'-----------------------------------------------------------------------------
'summery:Returns the touchmode of an object.
'seeAlso:SetTouchMode,CheckTouchHit
	Method GetTouchMode:Int()
		Return touchMode
	End
	'-----------------------------------------------------------------------------
'summery:Returns the amount of active transitions of an object.
	Method GetTransitionCount:Int ()
		Return transitionList.Count()
	End
	'-----------------------------------------------------------------------------
#Rem
'summery:Returns the type of an object.
The value of the type of an object can be one of the following ones:
[list][*]ftEngine.otImage   (Value = 0)
[*]ftEngine. otText   (Value = 1)
[*]ftEngine.otCircle   (Value = 2)
[*]ftEngine.otBox   (Value = 3)
[*]ftEngine.otZoneBox   (Value = 4)
[*]ftEngine.otZoneCircle   (Value = 5)
[*]ftEngine.otTileMap   (Value = 6)
[*]ftEngine.otTextMulti   (Value = 7)
[*]ftEngine.otPoint   (Value = 8)
[*]ftEngine.otStickMan   (Value = 9)
[*]ftEngine.otOval   (Value = 10)
[*]ftEngine.otLine   (Value = 11)
[*]ftEngine.otPoly   (Value = 12)
[*]ftEngine.otPivot   (Value = 13)[/list]
#End
	Method GetType:Int ()
		Return self.type
	End
	'-----------------------------------------------------------------------------
'summery:Determines a 2D vector from the objects center calculated by the given distance and angle.
'seeAlso:GetVectorAngle,GetVectorDist
	Method GetVector:Float[](vecDistance:Float, vecAngle:Float, relative:Bool=False)
		Local v:Float[2]
		Local a:Float
		If relative = True Then
			a = angle + vecAngle
		Else
			a = vecAngle
		Endif
	    v[0] = xPos + Sin(a) * vecDistance
	    v[1] = yPos - Cos(a) * vecDistance
		Return v		
	End
	'-----------------------------------------------------------------------------
'summery:Get the angle from the objects center to the given vector.
'seeAlso:GetVectorDist,GetVector
	Method GetVectorAngle:Float(vecXPos:Float, vecYPos:Float, relative:Int=False)
		Local xdiff:Float
		Local ydiff:Float 
		Local dist:Float
		Local ang:Float
			
		xdiff = vecXPos - xPos
		ydiff = vecYPos - yPos
			
    	ang = ATan2( ydiff, xdiff )+90.0
		If ang < 0 Then 
			ang = 360.0 + ang
		Endif
		If relative=True Then
			ang -= Self.angle
			If ang > 180.0 Then
				ang -= 360.0
			Elseif ang < -180.0 Then
				ang += 360.0
			Endif
		Endif
		Return ang
	End
	'-----------------------------------------------------------------------------
'summery:Get the distance in pixel from the objects center to the given vector.
'seeAlso:GetVectorAngle,GetVector
	Method GetVectorDist:Float(vecXPos:Float, vecYPos:Float)
		Local xdiff:Float
		Local ydiff:Float 
		Local dist:Float
		
		xdiff = vecXPos - xPos
		ydiff = vecYPos - yPos
		
		dist = Sqrt(xdiff * xdiff + ydiff * ydiff)
		
		Return dist
	End
	'-----------------------------------------------------------------------------
'summery:Returns the visible flag.
'seeAlso:SetVisible
	Method GetVisible:Bool()
		Return isVisible
	End 
	'-----------------------------------------------------------------------------
#Rem
'summery:Returns the width of an object. 
The returned value is the stored width multiplied by the X scale factor.
#End
'seeAlso:SetWidth,GetHeight
	Method GetWidth:Float()
		Return w*scaleX
	End 
	'-----------------------------------------------------------------------------
'summery:Pause all timer of an object.
'seeAlso:CreateTimer,CancelTimerAll,ResumeTimerAll
	Method PauseTimerAll:Void()
		For Local timer := Eachin timerList 
			timer.SetPaused(True)
		Next
	End
	'-----------------------------------------------------------------------------
'summery:Pause all  transitions attached to an object.
'seeAlso:CancelTransAll,ResumeTransAll
	Method PauseTransAll:Void()
		For Local trans := Eachin transitionList    
			trans.SetPaused(True)
		Next
	End
	'------------------------------------------
'summery:Removes an object.
'seeAlso:ActivateDeleteEvent
	Method Remove:Void(directFlag:Bool = False)
		For Local child := Eachin childObjList
			child.Remove(directFlag)
		Next
		For Local trans := Eachin transitionList
			trans.Cancel()
		Next
		For Local timer := Eachin timerList
			timer.RemoveTimer()
		Next
		If directFlag = True Then
			If Self.parentObj <> Null Then
				Self.parentNode.Remove()
				Self.parentObj = Null
			Endif

			If Self.layer <> Null Then 
				Self.layerNode.Remove() 
				Self.layer = Null
			Endif

			If Self.marker <> Null Then 
				Self.markerNode.Remove() 
				Self.marker = Null
			Endif

			If Self.animMng <> Null Then 
				Self.animMng.RemoveAll() 
				Self.animMng = Null  
			Endif
			If Self.tileMap <> Null  
				Self.tileMap.Remove() 
			Endif

			If Self.onDeleteEvent = True Then engine.OnObjectDelete(Self)
			Self.engine.objectPool.Free(Self) 
			
		Else
			Self.deleted = True
		Endif

	End
	'------------------------------------------
'changes:2.01:Fixed layer scaling and object culling. 
'summery:Renders an object.
	Method Render:Void(xoff:Float=0.0, yoff:Float=0.0)
		Local txOff:Float
		Local tyOff:Float
		Local mAlpha:Float
		Local tempScaleX:Float
		Local tempScaleY:Float
		Local tilePos:Int
		Local tileIDx:Int
		Local tileSetIndex:Int
		Local tlxPos:Float
		Local tlyPos:Float
		Local tlW:Float
		Local tlH:Float
		Local tlW2:Float
		Local tlH2:Float
		Local ytY:Int
		Local ytX:Int
		Local _y:Int
		Local px:Float
		Local py:Float
		Local tmpFrame:Int
		Local drawAngle:Float
		Local _cw:Float
		Local _ch:Float
		Local layerScale:Float
		
		Local mxcl:Float
		Local mxcr:Float
		Local myct:Float
		Local mycb:Float

		If deleted = False Then
			layerScale = Self.GetLayer().GetScale()
			'Change alpha if needed
			mAlpha = Self.alpha * Self.layer.alpha
			If engine.alpha <> mAlpha Then 
				Self.engine.currentCanvas.SetAlpha(mAlpha)
				engine.alpha = mAlpha
			Endif
			
			'Change color if needed
			If engine.red <> Self.red Or engine.green <> Self.green Or engine.blue <> Self.blue Then 
				Self.engine.currentCanvas.SetColor(Self.red / 255.0, Self.green / 255.0, Self.blue / 255.0)
				engine.red = Self.red
				engine.green = Self.green
				engine.blue = Self.blue
			Endif
			
			'Change blendmode if needed
			If engine.blendMode <> Self.blendMode Then 
				Self.engine.currentCanvas.SetBlendMode(Self.blendMode)
				engine.blendMode = Self.blendMode
			Endif
			'If object is flipped, scale it accordingly
			If Self.isFlipV Then
				tempScaleY = Self.scaleY * -1 * layerScale
			Else
				tempScaleY = Self.scaleY * layerScale
			Endif 
			If Self.isFlipH Then
				tempScaleX = Self.scaleX * -1 * layerScale
			Else
				tempScaleX = Self.scaleX * layerScale
			Endif 
			
			px = (Self.hOffX + xPos) * layerScale + xoff
			py = (Self.hOffY + yPos) * layerScale + yoff
			
			mxcl = (Self.maxX * layerScale) + px + Self.w/2.0*Self.scaleX*layerScale
			mxcr = (Self.minX * layerScale) + px - Self.w/2.0*Self.scaleX*layerScale
			myct = (Self.maxY * layerScale) + py + Self.h/2.0*Self.scaleY*layerScale
			mycb = (Self.minY * layerScale) + py - Self.h/2.0*Self.scaleY*layerScale
			
			If type <> ftEngine.otTileMap
			
				'Draw the object according to its type
				If mxcl>=0 And  mxcr <= engine.canvasWidth
					If myct>=0 And  mycb <= engine.canvasHeight Then
					
					
						'Draw the object according to its type
						Select type
				
							Case ftEngine.otPivot
								' Draw nothing
								
							Case ftEngine.otPoint
								Self.engine.currentCanvas.DrawPoint xPos*layerScale + xoff, yPos*layerScale + yoff
			
							Case ftEngine.otStickMan
								Self.engine.currentCanvas.PushMatrix
								Self.engine.currentCanvas.Translate ((xPos*layerScale+xoff), (yPos*layerScale+yoff))
								Self.engine.currentCanvas.Rotate 360.0-angle
								Self.engine.currentCanvas.Scale (Self.scaleX*layerScale, Self.scaleY*layerScale)
								Self.engine.currentCanvas.DrawCircle (-w*(Self.handleX))+4, (-h*(Self.handleY))+4, 4						' o Head
								Self.engine.currentCanvas.DrawLine (-w*(Self.handleX))+4, (-h*(Self.handleY))+6,  (-w*(Self.handleX))+4, (-h*(Self.handleY))+25	' | Body	
								Self.engine.currentCanvas.DrawLine (-w*(Self.handleX))+4, (-h*(Self.handleY))+14, (-w*(Self.handleX))+8, (-h*(Self.handleY))+18	' \ Arm			
								Self.engine.currentCanvas.DrawLine (-w*(Self.handleX))+4, (-h*(Self.handleY))+25, (-w*(Self.handleX)),   (-h*(Self.handleY))+29	' / Leg			
								Self.engine.currentCanvas.DrawLine (-w*(Self.handleX))+4, (-h*(Self.handleY))+25, (-w*(Self.handleX))+8, (-h*(Self.handleY))+29	' \ Leg			
								Self.engine.currentCanvas.PopMatrix
			
							Case ftEngine.otOval
								Self.engine.currentCanvas.PushMatrix
								Self.engine.currentCanvas.Translate ((xPos*layerScale+xoff), (yPos*layerScale+yoff)) 
								Self.engine.currentCanvas.Rotate 360.0-angle
								Self.engine.currentCanvas.Scale (Self.scaleX*layerScale, Self.scaleY*layerScale)
								Self.engine.currentCanvas.DrawOval -w * (Self.handleX), -h * (Self.handleY), w, h
								Self.engine.currentCanvas.PopMatrix
			
							Case ftEngine.otLine
								Self.engine.currentCanvas.PushMatrix
								Self.engine.currentCanvas.Translate ((xPos*layerScale+xoff), (yPos*layerScale+yoff)) 
								Self.engine.currentCanvas.Rotate 360.0-angle+90.0
								Self.engine.currentCanvas.Scale (Self.scaleX*layerScale, Self.scaleY*layerScale)
								Self.engine.currentCanvas.DrawLine -w * (Self.handleX), 0, w - (w * Self.handleX), 0
								Self.engine.currentCanvas.PopMatrix
			
							Case ftEngine.otPoly
								Self.engine.currentCanvas.PushMatrix
								Self.engine.currentCanvas.Translate ((xPos*layerScale + xoff), (yPos*layerScale + yoff))
								Self.engine.currentCanvas.Rotate 360.0-angle
								Self.engine.currentCanvas.Scale (Self.scaleX*layerScale, Self.scaleY*layerScale)
								Self.engine.currentCanvas.DrawPoly (verts)
								Self.engine.currentCanvas.PopMatrix								
			
							Case ftEngine.otImage
								'px = Self.hOffX+xPos+xoff
								'py = Self.hOffY+yPos+yoff
								'If (maxX+px+w/2.0*scaleX)>=0 And (minX+px-w/2.0*scaleX) <= engine.canvasWidth Then
									'If (maxY+py+h/2.0*scaleY)>=0 And (minY+py-h/2.0*scaleY) <= engine.canvasHeight Then
										Self.engine.currentCanvas.PushMatrix
										Self.engine.currentCanvas.TranslateRotateScale( px, py, 360-angle+offAngle, tempScaleX, tempScaleY )
										Self.engine.currentCanvas.DrawRect(-Self.w/2.0, -Self.h/2.0, Self.objImg[Self.currImageIndex-1].img[Self.currImageFrame-1], rox, roy, rw, rh )
										Self.engine.currentCanvas.PopMatrix								
			
									'Endif
								'Endif
							Case ftEngine.otTileMap
#rem							
								_cw = engine.GetCanvasWidth()
								_ch = engine.GetCanvasHeight()
								tempScaleX = tempScaleX + Self.tileMap.tileModSX
								tempScaleY = tempScaleY + Self.tileMap.tileModSY
								
								tlW = Self.tileMap.tileSizeX * Self.scaleX
								tlH = Self.tileMap.tileSizeY * Self.scaleY
								tlW2 = tlW/2.0
								tlH2 = tlH/2.0
								drawAngle = 360.0-Self.angle
								
								'Determine the first and last x/y coordinate
								Local xFirst:Int = 1
								Local xLast:Int = Self.tileMap.tileCountX
								Local yFirst:Int = 1
								Local yLast:Int = Self.tileMap.tileCountY
								
								If Self.tileMap.tiles[0].tileType = 0
									'Determine the first x coordinates
									For ytX = 1 To Self.tileMap.tileCountX
										tlxPos = xoff+xPos+Self.tileMap.tiles[ytX-1].xOff * Self.scaleX
										If (tlxPos+tlW2)>=0 And (tlxPos-tlW2)<=_cw Then 
											xFirst = ytX
											Exit
										Endif
									Next
									
									'Determine the last X coordinates
									For ytX = (xFirst+1) To Self.tileMap.tileCountX
										tlxPos = xoff+xPos+Self.tileMap.tiles[ytX-1].xOff * Self.scaleX
										If (tlxPos+tlW2)<0 Or (tlxPos-tlW2)>_cw Then 
											xLast = ytX-1
											Exit
										Endif
									Next
									
									'Determine the first y coordinates
									For ytY = 1 To Self.tileMap.tileCountY
										tilePos = (ytY-1)*Self.tileMap.tileCountX
										tlyPos = yoff+yPos+Self.tileMap.tiles[tilePos].yOff * Self.scaleY
										If (tlyPos+tlH2)>=0 And (tlyPos-tlH2)<=_ch Then 
											yFirst = ytY
											Exit
										Endif
									Next
									
									'Determine the last Y coordinates
									For ytY = (yFirst+1) To Self.tileMap.tileCountY
										tilePos = (ytY-1)*Self.tileMap.tileCountX
										tlyPos = yoff+yPos+Self.tileMap.tiles[tilePos].yOff * Self.scaleY
										If (tlyPos+tlH2)<0 Or (tlyPos-tlH2)>_ch Then 
											yLast = ytY-1
											Exit
										Endif
									Next
									
								Endif
								
								' Now draw the map
								For ytY = yFirst To yLast
									For ytX = xFirst To xLast							
										tilePos = (ytX-1)+(ytY-1)*Self.tileMap.tileCountX
										tileSetIndex = Self.tileMap.tiles[tilePos].tileSetIndex
										tileIDx = Self.tileMap.tiles[tilePos].tileID
										If tileIDx >= 0
											tileIDx = tileIDx-Self.tileMap.tileSets[tileSetIndex].firstGID+1
										Endif
			
										If tileIDx <> - 1 Then
											tlxPos = xoff+xPos+Self.tileMap.tiles[tilePos].xOff * Self.scaleX + (Self.tileMap.tiles[tilePos].sizeX/2-Self.tileMap.tileSizeX/2)
											tlyPos = yoff+yPos+Self.tileMap.tiles[tilePos].yOff * Self.scaleY - (Self.tileMap.tiles[tilePos].sizeY/2-Self.tileMap.tileSizeY/2)
											
										    'DrawImageRect( Self.objImg[tileSetIndex].img, tlxPos, tlyPos, tileMap.tileSpacing, tileMap.tileSpacing, Self.tileMap.tileSets[tileSetIndex].tilewidth-tileMap.tileSpacing, Self.tileMap.tileSets[tileSetIndex].tileheight-tileMap.tileSpacing, drawAngle, tempScaleX, tempScaleY, tileIDx)										
										    Self.engine.currentCanvas.DrawImage( Self.objImg[tileSetIndex].img[tileIDx], tlxPos, tlyPos, drawAngle, tempScaleX, tempScaleY)										
										Endif
									Next
								Next	
			'dbXXX = 1		
#End				
							Case ftEngine.otCircle
								Self.engine.currentCanvas.PushMatrix
								Self.engine.currentCanvas.Translate ((xPos*layerScale+xoff), (yPos*layerScale+yoff)) 
								Self.engine.currentCanvas.Rotate 360.0-angle
								Self.engine.currentCanvas.Scale (Self.scaleX*layerScale, Self.scaleY*layerScale)
								Self.engine.currentCanvas.DrawCircle -w * (Self.handleX-0.5), -h * (Self.handleY-0.5), radius * Self.scaleX
								Self.engine.currentCanvas.PopMatrix
			
							Case ftEngine.otBox
								'px = Self.hOffX+xPos+xoff
								'py = Self.hOffY+yPos+yoff
								'If (maxX+px+w/2.0*scaleX)>=0 And (minX+px-w/2.0*scaleX) <= engine.canvasWidth Then
									'If (maxY+py+h/2.0*scaleY)>=0 And (minY+py-h/2.0*scaleY) <= engine.canvasHeight Then
									
										Self.engine.currentCanvas.PushMatrix
										Self.engine.currentCanvas.Translate ((xPos*layerScale+xoff), (yPos*layerScale+yoff)) 
										Self.engine.currentCanvas.Rotate 360.0-angle
										Self.engine.currentCanvas.Scale (Self.scaleX*layerScale, Self.scaleY*layerScale)
										Self.engine.currentCanvas.DrawRect -w*Self.handleX, -h*Self.handleY, w, h
										Self.engine.currentCanvas.PopMatrix
										
									'Endif
								'Endif
								
							Case ftEngine.otText
								Self.engine.currentCanvas.PushMatrix
								Self.engine.currentCanvas.Translate ((xPos*layerScale+xoff), (yPos*layerScale+yoff))
								Self.engine.currentCanvas.Rotate 360.0-angle
								Self.engine.currentCanvas.Scale (Self.scaleX*layerScale, Self.scaleY*layerScale)
								Select Self.textMode
									Case 0			'topLeft
										txOff = 0.0
										tyOff = 0.0
									Case 1			'topCenter
										txOff = -(Float(Self.objFont.Length(Self.text))/2.0) 
										tyOff = 0.0
									Case 2			'topRight
										txOff = -Self.objFont.Length(Self.text)
										tyOff = 0.0
										
									Case 7			'centerLeft
										txOff = 0.0
										tyOff = -(Float(Self.objFont.Height())/2.0) 
									Case 3			'centerCenter
										txOff = -(Float(Self.objFont.Length(Self.text))/2.0) 
										tyOff = -(Float(Self.objFont.Height())/2.0) 
									Case 4			'centerRight
										txOff = -Self.objFont.Length(Self.text)
										tyOff = -(Float(Self.objFont.Height())/2.0) 
										
									Case 8			'bottomLeft
										txOff = 0.0
										tyOff = -(Float(Self.objFont.Height())) 
									Case 5 			'bottomCenter
										txOff = -(Float(Self.objFont.Length(Self.text))/2.0) 
										tyOff = -(Float(Self.objFont.Height())) 
									Case 6			'bottomRight
										txOff = -Self.objFont.Length(Self.text)
										tyOff = -(Float(Self.objFont.Height())) 
								End
								objFont.Draw(text, txOff, tyOff)
								Self.engine.currentCanvas.PopMatrix
								
							Case ftEngine.otTextMulti
								Self.engine.currentCanvas.PushMatrix
								Self.engine.currentCanvas.Translate ((xPos*layerScale+xoff), (yPos*layerScale+yoff))
								Self.engine.currentCanvas.Rotate 360.0-angle
								Self.engine.currentCanvas.Scale (Self.scaleX*layerScale, Self.scaleY*layerScale)
								Local lines:String[] = Self.text.Split("~n")
								Local objFontHeight:Float = Self.objFont.Height()
								Local linesCount:Int = lines.Length()
								
								For _y = 1 To linesCount
			
									Select Self.textMode
										Case 0			'topLeft
											txOff = 0.0
											tyOff = 0.0 + (objFontHeight*(_y-1))
											
										Case 1			'topCenter
											txOff = -(Float(Self.objFont.Length(lines[_y-1]))/2.0) 
											tyOff = 0.0 + (objFontHeight*(_y-1))
											
										Case 2			'topRight
											txOff = -Self.objFont.Length(lines[_y-1])
											tyOff = 0.0 + (objFontHeight*(_y-1))
											
										Case 7			'centerLeft
											txOff = 0.0
											tyOff = -((objFontHeight*linesCount)/2.0)  + (objFontHeight*(_y-1))
											
										Case 3			'centerCenter
											txOff = -(Float(Self.objFont.Length(lines[_y-1]))/2.0) 
											tyOff = -((objFontHeight*linesCount)/2.0)  + (objFontHeight*(_y-1))
											 
										Case 4			'centerRight
											txOff = -Self.objFont.Length(lines[_y-1])
											tyOff = -((objFontHeight*linesCount)/2.0)  + (objFontHeight*(_y-1))
											
										Case 8			'bottomLeft
											txOff = 0.0
											tyOff = -(objFontHeight*linesCount) + (objFontHeight*(_y-1))
											
										Case 5 			'bottomCenter
											txOff = -(Float(Self.objFont.Length(lines[_y-1]))/2.0) 
											tyOff = -(objFontHeight*linesCount) + (objFontHeight*(_y-1)) 
											
										Case 6			'bottomRight
											txOff = -Self.objFont.Length(lines[_y-1])
											tyOff = -(objFontHeight*linesCount) + (objFontHeight*(_y-1)) 
											
									End
									objFont.Draw(lines[_y-1], txOff, tyOff)
								Next
								Self.engine.currentCanvas.PopMatrix
						End
					Endif
				Endif
			Else
				_cw = engine.GetCanvasWidth()
				_ch = engine.GetCanvasHeight()
				tempScaleX = tempScaleX + Self.tileMap.tileModSX * layerScale
				tempScaleY = tempScaleY + Self.tileMap.tileModSY * layerScale
				
				tlW = Self.tileMap.tileSizeX * Self.scaleX
				tlH = Self.tileMap.tileSizeY * Self.scaleY
				tlW2 = tlW/2.0
				tlH2 = tlH/2.0
				drawAngle = 360.0-Self.angle
				
				'Determine the first and last x/y coordinate
				Local xFirst:Int = 1
				Local xLast:Int = Self.tileMap.tileCountX
				Local yFirst:Int = 1
				Local yLast:Int = Self.tileMap.tileCountY
				
				If Self.tileMap.tiles[0].tileType = 0
					'Determine the first x coordinates
					For ytX = 1 To Self.tileMap.tileCountX
						tlxPos = xoff+xPos+Self.tileMap.tiles[ytX-1].xOff * Self.scaleX
						If (tlxPos+tlW2)>=0 And (tlxPos-tlW2)<=_cw Then 
							xFirst = ytX
							Exit
						Endif
					Next
					
					'Determine the last X coordinates
					For ytX = (xFirst+1) To Self.tileMap.tileCountX
						tlxPos = xoff+xPos+Self.tileMap.tiles[ytX-1].xOff * Self.scaleX
						If (tlxPos+tlW2)<0 Or (tlxPos-tlW2)>_cw Then 
							xLast = ytX-1
							Exit
						Endif
					Next
					
					'Determine the first y coordinates
					For ytY = 1 To Self.tileMap.tileCountY
						tilePos = (ytY-1)*Self.tileMap.tileCountX
						tlyPos = yoff+yPos+Self.tileMap.tiles[tilePos].yOff * Self.scaleY
						If (tlyPos+tlH2)>=0 And (tlyPos-tlH2)<=_ch Then 
							yFirst = ytY
							Exit
						Endif
					Next
					
					'Determine the last Y coordinates
					For ytY = (yFirst+1) To Self.tileMap.tileCountY
						tilePos = (ytY-1)*Self.tileMap.tileCountX
						tlyPos = yoff+yPos+Self.tileMap.tiles[tilePos].yOff * Self.scaleY
						If (tlyPos+tlH2)<0 Or (tlyPos-tlH2)>_ch Then 
							yLast = ytY-1
							Exit
						Endif
					Next
					
				Endif
				
				' Now draw the map
				For ytY = yFirst To yLast
					For ytX = xFirst To xLast							
						tilePos = (ytX-1)+(ytY-1)*Self.tileMap.tileCountX
						tileSetIndex = Self.tileMap.tiles[tilePos].tileSetIndex
						tileIDx = Self.tileMap.tiles[tilePos].tileID
						If tileIDx >= 0
							tileIDx = tileIDx-Self.tileMap.tileSets[tileSetIndex].firstGID+1
						Endif

						If tileIDx <> - 1 Then
							tlxPos = xoff+xPos+Self.tileMap.tiles[tilePos].xOff * Self.scaleX + (Self.tileMap.tiles[tilePos].sizeX/2-Self.tileMap.tileSizeX/2)
							tlyPos = yoff+yPos+Self.tileMap.tiles[tilePos].yOff * Self.scaleY - (Self.tileMap.tiles[tilePos].sizeY/2-Self.tileMap.tileSizeY/2)
							
						    'DrawImageRect( Self.objImg[tileSetIndex].img, tlxPos, tlyPos, tileMap.tileSpacing, tileMap.tileSpacing, Self.tileMap.tileSets[tileSetIndex].tilewidth-tileMap.tileSpacing, Self.tileMap.tileSets[tileSetIndex].tileheight-tileMap.tileSpacing, drawAngle, tempScaleX, tempScaleY, tileIDx)										
						    Self.engine.currentCanvas.DrawImage( Self.objImg[tileSetIndex].img[tileIDx], tlxPos, tlyPos, drawAngle, tempScaleX, tempScaleY)										
						Endif
					Next
				Next	
			'dbXXX = 1			
			Endif
			
			If Self.onRenderEvent = True Then engine.OnObjectRender(Self)
			For Local child := Eachin childObjList
				If child.isVisible And child.isActive Then child.Render(xoff, yoff)
			Next
		Endif
	End	
	'-----------------------------------------------------------------------------
'summery:Resume all paused timer of an object.
'seeAlso:PauseTimerAll,CancelTimerAll,CreateTimer
	Method ResumeTimerAll:Void()
		For Local timer := Eachin timerList 
			timer.SetPaused(False)
		Next
	End
	'-----------------------------------------------------------------------------
'summery:Resume all  transitions attached to an object.
'seeAlso:PauseTransAll,CancelTransAll
	Method ResumeTransAll:Void()
		For Local trans := Eachin transitionList    
			trans.SetPaused(False)
		Next
	End
	'-----------------------------------------------------------------------------
'changes:2.01:Add flag to affect children too.
'summery:Set the active flag.
'seeAlso:GetActive
	Method SetActive:Void (activeFlag:Bool = True, children:Bool = False )
		isActive = activeFlag
		If children = True
			For Local child := Eachin childObjList
				child.SetActive(activeFlag, children)
			Next
		Endif
	End
	'-----------------------------------------------------------------------------
'summery:Set the current active animation.
	Method SetActiveAnim:Void (animName:String)
		Self.animMng.SetActiveAnim(animName)
	End	
	'------------------------------------------
'summery:Set the alpha value of an object. (Ranging from 0.0 to 1.0)
'seeAlso:GetAlpha,SetColor
	Method SetAlpha:Void(newAlpha:Float, relative:Int=False)
		If relative=True Then
			alpha += newAlpha
		Else
			alpha = newAlpha
		Endif
		If alpha < 0.0 Then alpha = 0.0
		If alpha > 1.0 Then alpha = 1.0
	End
	'------------------------------------------
'summery:Set the objects angle.
'seeAlso:GetAngle
	Method SetAngle:Void (newAngle:Float, relative:Int = False )
		Local angDiff:Float
		If relative = True
			angDiff = newAngle
			angle = angle + newAngle
		Else
			angDiff = newAngle - angle
			angle = newAngle
		Endif
		For Local child := Eachin childObjList
			child._OrbitChild(angDiff)
			child.SetAngle(newAngle, relative)
		Next
		If Self.angle > 360.0 Self.angle = Self.angle - 360
		If Self.angle < 0.0 Self.angle = Self.angle + 360.0
		_RotateSpriteCol()
	End
	'------------------------------------------
#Rem
'summery:Set the objects angle offset manually. 
Normally it is set from loading an image from a sprite atlas where the image is already rotated.
#End
	Method SetAngleOffset:Void (angleOffset:Float )
		Self.offAngle = angleOffset
	End
	'-----------------------------------------------------------------------------
'summery:Turn the animation of an animated object on/off.
'seeAlso:GetAnimated
	Method SetAnimated:Void (animFlag:Bool = True )
		Self.isAnimated = animFlag
	End
	'-----------------------------------------------------------------------------
'summery:Set the current animation frame. The frame number starts with 1.
'seeAlso:GetAnimFrame
	Method SetAnimFrame:Void (frame:Float )
		Self.animMng.SetCurrAnimFrame(frame)
	End
	'-----------------------------------------------------------------------------
'summery:Set the pause flag for the animation of an animated object.
'seeAlso:GetAnimPaused
	Method SetAnimPaused:Void (pauseFlag:Bool = False )
		Self.animMng.isAnimPaused = pauseFlag
	End
	'-----------------------------------------------------------------------------
#Rem
'summery:Set the repeat count of the current animation.
'The default value of -1 means it runs forever. A value greater than 0 describes how many times the animation repeats itself.
#End
	Method SetAnimRepeatCount:Void (repeatCount:Int = -1)
		Self.animMng.SetCurrAnimRepeatCount(repeatCount)
	End
	'-----------------------------------------------------------------------------
#Rem
'summery:Set the factor for the animation frame time.
'The default value is 10.0. The higher the value is, the longer a frame is displayed.
#End
'seeAlso:GetAnimTime
	Method SetAnimTime:Void (time:Float = 10.0 )
		Self.animMng.SetCurrAnimTime(time)
	End
	'-----------------------------------------------------------------------------
'changes:2.0:Changed regarding usable mojo2 blend modes.
#rem
'summery:Set the blend mode of an object. It uses the regular blend modes of mojo2.
'Bendmodes can be:
[list][*]BlendMode.Opaque:=0
[*]BlendMode.Alpha:=1
[*]BlendMode.Additive:=2
[*]BlendMode.Multiply:=3
[*]BlendMode.Multiply2:=4[/list]
#end
'seeAlso:GetBlendMode
	Method SetBlendMode:Void (blendmode:Int = BlendMode.Opaque)
#If CONFIG="debug"
		If blendmode < BlendMode.Opaque Or blendmode > BlendMode.Multiply2 Then Error ("~n~nError in file fantomX.cftObject, Method ftObject.SetBlendMode(blendmode:Int = BlendMode.Opaque):~n~nUsed mode "+blendmode+" is wrong. Must be 0 or 4")
#End
		Self.blendMode = blendmode
	End
	'-----------------------------------------------------------------------------
#Rem
'summery:Set the objects collision group. 
A value of 0 will disable the collision, a value between 1 and 32 will set the collision group.
#End
'seeAlso:GetColGroup
	Method SetColGroup:Void (collisionGroup:Int)
#If CONFIG="debug"
		Local cc:Int = Self.collWith.Length()
		If collisionGroup < 0 Or collisionGroup > cc Then Error ("~n~nError in file fantomX.cftObject, Method ftObject.SetColGroup(collisionGroup:Int):~n~nUsed index is wrong. Bounds are 0-"+cc+".")
#End
		Self.collGroup = collisionGroup
	End
	'-----------------------------------------------------------------------------
'summery:Set the color of an object.
'seeAlso:SetAlpha,GetColor
	Method SetColor:Void(cRed:Float, cGreen:Float, cBlue:Float)
		Self.red = cRed
		Self.green = cGreen
		Self.blue = cBlue
	End
	'-----------------------------------------------------------------------------
#Rem
'summery:Sets the collision scale factor of an object.
'The collision scale affects the calculation of the collision type objects (circle, bounding box, rotated box)
#End
	Method SetColScale:Void (colScale:Float = 1.0)
		Self.collScale = colScale
		_RotateSpriteCol()
	End
	'-----------------------------------------------------------------------------
#Rem
'summery:Set the collision type of an object.
'Collision types can be:
[list][*]Const ctCircle% = 0
[*]Const ctBox% = 1   (this will check against the rotated box of the object)
[*]Const ctBound% = 2   (This will check against the bounding box of the object)
[*]Const ctLine% = 3[/list]
#End
'seeAlso:GetColType
	Method SetColType:Void (colltype:Int)
		Self.collType = colltype
	End
	'-----------------------------------------------------------------------------
#Rem
'summery:Set with which collision groups an object can collide.
'Indexes go from 1 to 32.
#End
	Method SetColWith:Void (startIndex:Int, endIndex:Int, boolFlag:Bool)
		Local cc:Int = Self.collWith.Length()
#If CONFIG="debug"
		If startIndex < 1 Or endIndex > cc Or startIndex > endIndex Then Error ("~n~nError in file fantomX.cftObject, Method ftObject.SetColWith(startIndex:Int, endIndex:Int, boolFlag:Bool):~n~nUsed index is wrong. Bounds are 1-"+cc+".")
#End
		For Local i:Int = (startIndex-1) To (endIndex-1)
			Self.collWith[i] = boolFlag
		Next
		If boolFlag = True Then
			Self.colCheck = True
		Else
			Self.colCheck = False
			For Local i:Int = 0 To cc
				If collWith[i] = True Then
					Self.colCheck = True
					Exit
				Endif
			Next
		Endif
	End
	'-----------------------------------------------------------------------------
#Rem
'summery:Set with which collision group an object can collide.
'Indexes go from 1 to 32.
#End
	Method SetColWith:Void (index:Int,boolFlag:Int)
		Local cc:Int = Self.collWith.Length()
#If CONFIG="debug"
		If index < 1 Or index > cc Then Error ("~n~nError in file fantomX.cftObject, Method ftObject.SetColWith(index, boolFlag):~n~nUsed index ("+index+") is out of bounds (1-"+cc+")")
#End
		collWith[index-1] = boolFlag
		If boolFlag = True Then
			Self.colCheck = True
		Else
			Self.colCheck = False
			For Local i:Int = 0 To (cc-1)
				If collWith[i] = True Then
					Self.colCheck = True
					Exit
				Endif
			Next
		Endif
	End
	'----------------------------------------------------------
'summery:Sets the current image and frame of the object to be drawn. Image index and frame index start with 1.
	Method SetCurrImage:Void(index:Int, _frameIndex:Int)
		currImageIndex = index
		currImageFrame = _frameIndex
#If CONFIG="debug"
		Local ic:Int = Self.objImg.Length()
		If ic < index Or index < 1 Then Error("~n~nError in file fantomX.cftObject, Method SetCurrImage:Void(index:Int, _frameIndex:Int):~n~nIndex ("+index+") is out of bounds (1-"+ic+")")

		Local ifc:Int = Self.objImg[index-1].img.Length()
		If  ifc < _frameIndex Or _frameIndex < 1 Then Error("~n~nError in file fantomX.cftObject, Method SetCurrImage:Void(index:Int, _frameIndex:Int):~n~n_frameIndex ("+_frameIndex+") is out of bounds (1-"+ifc+")")
#End
	End
	'-----------------------------------------------------------------------------
'summery:Sets the data object of this object.
'seeAlso:GetDataObj
	Method SetDataObj:Void (obj:Object)
		Self.dataObj = obj
	End	
	'-----------------------------------------------------------------------------
'summery:Activate horizontal and vertical image flip.
'seeAlso:GetFlip
	Method SetFlip:Void (vf:Bool,hf:Bool)
		Self.isFlipV = vf
		Self.isFlipH = hf
	End
	'-----------------------------------------------------------------------------
'summery:Activate horizontal image flip.
'seeAlso:GetFlipH
	Method SetFlipH:Void (hf:Bool)
		Self.isFlipH = hf
	End
	'-----------------------------------------------------------------------------
'summery:Activate vertical image flip.
'seeAlso:GetFlipV
	Method SetFlipV:Void (vf:Bool)
		Self.isFlipV = vf
	End
	'-----------------------------------------------------------------------------
'summery:Set the objects friction.
'seeAlso:GetFriction
	Method SetFriction:Void (newFriction:Float, relative:Int = False )
		If relative = True
			friction += newFriction
		Else
			friction = newFriction
		Endif
	End	
	'-----------------------------------------------------------------------------
'summery:Set the objects group ID.
'seeAlso:GetGroupID
	Method SetGroupID:Void (groupId:Int)
		Self.groupID = groupId
	End	
	'-----------------------------------------------------------------------------
#Rem
'summery:Set the handle/hotspot of an object.
'The handle determines the relative position of the objects hotspot (images, primitives). 
'A handle of 0.5/0.5 is in the center of the object. A handle of 0.0/0.0 is at the top left corner.
#End
	Method SetHandle:Void (hx:Float, hy:Float )
		Self.handleX = hx
		Self.handleY = hy
		'_RotateSpriteCol(Self)
		_RotateSpriteCol()
	End	
	'-----------------------------------------------------------------------------
#Rem
'summery:Set the height of an object.
The stored height is the result of the given parameter divided by the current Y scale factor.
#End
'seeAlso:GetHeight,SetWidth
	Method SetHeight:Void (height:Float )
		Self.h = height/scaleY
		_RotateSpriteCol()
	End	
	'-----------------------------------------------------------------------------
'summery:Set the object ID.
'seeAlso:GetID
	Method SetID:Void (i:Int )
		Self.id = i
	End	
	'----------------------------------------------------------
'changes:2.01:New flags parameter
'summery:Sets a single image (frame) of an object at the given index. Index starts at 1.
'seeAlso:GetImage
	Method SetImage:Void(index:Int, filename:String, flags:Int=Image.Filter)
#If CONFIG="debug"
		If Self.objImg.Length() < (index) Then Error("~n~nError in file fantomX.cftObject, Method ftObject.SetImage(index:Int, filename:String):~n~nIndex ("+index+") is out of bounds (1-"+Self.objImg.Length()+")")
#End
		Self.objImg[index-1] = Self.engine.imgMng.LoadImage(filename, 1, flags)
#If CONFIG="debug"
		If Self.objImg[index-1] = Null Then Error("~n~nError in file fantomX.cftObject, Method ftObject.SetImage(index:Int, filename:String):~n~nImage "+filename+" not found!")
#End
	End
	'----------------------------------------------------------
'seeAlso:GetImage
'summery:Sets a single image (frame) of an object at the given index. Index starts at 1.
	Method SetImage:Void(index:Int, image:Image)
#If CONFIG="debug"
		If Self.objImg.Length() < (index) Then Error("~n~nError in file fantomX.cftObject, Method ftObject.SetImage(index:Int, image:Image):~n~nIndex ("+index+") is out of bounds (1-"+Self.objImg.Length()+")")
#End
		Self.objImg[index-1] = Self.engine.imgMng.LoadImage(image)
#If CONFIG="debug"
		If Self.objImg[index-1] = Null Then Error("~n~nError in file fantomX.cftObject, Method ftObject.SetImage(index:Int, image:Image):~n~nCould not assign the image!")
#End
	End
	'----------------------------------------------------------
'seeAlso:GetImageObj
'summery:Sets a single image object (frame) of an object at the given index. Index starts at 1.
	Method SetImageObj:Void(index:Int, imageObj:ftImage)
#If CONFIG="debug"
		If Self.objImg.Length() < (index) Then Error("~n~nError in file fantomX.cftObject, Method ftObject.SetImageObj(index:Int, imageObj:ftImage):~n~nIndex ("+index+") is out of bounds (1-"+Self.objImg.Length()+")")
#End
		Self.objImg[index-1] = imageObj
#If CONFIG="debug"
		If Self.objImg[index-1] = Null Then Error("~n~nError in file fantomX.cftObject, Method ftObject.SetImageObj(index:Int, imageObj:ftImage):~n~nCould not assign the image object!")
#End
	End
	'------------------------------------------
'summery:Set the layer of an object.
'seeAlso:GetLayer
	Method SetLayer:Void(newLayer:ftLayer)
		If Self.layer <> Null Then
			Self.layerNode.Remove()
		Endif
		
		If newLayer <> Null Then
			Self.layerNode = newLayer.objList.AddLast(Self)     '1.2.1
		Endif
		Self.layer = newLayer
	End
	'-----------------------------------------------------------------------------
'summery:Set the maximum speed of an object.
'seeAlso:GetSpeedMax
	Method SetMaxSpeed:Void (maxSpeed:Float )
		Self.speedMax = maxSpeed
	End
	'-----------------------------------------------------------------------------
'summery:Set the minimum speed of an object.
'seeAlso:GetSpeedMin
	Method SetMinSpeed:Void (minSpeed:Float )
		Self.speedMin = minSpeed
	End
	'-----------------------------------------------------------------------------
'summery:Set the name of an object.
'seeAlso:GetName
	Method SetName:Void (newName:String )
		Self.name = newName
	End	
	'------------------------------------------
'summery:Set the parent of an object.
'seeAlso:GetParent
	Method SetParent:Void(newParent:ftObject)
		If Self.parentObj <> Null Then
			Self.parentNode.Remove()
			Self.parentNode = Null
		Endif
		If newParent <> Null Then
			Self.parentNode = newParent.childObjList.AddLast(Self)
		Endif
		Self.parentObj = newParent
	End
	'-----------------------------------------------------------------------------
'summery:Set the objects X/Y position.
'seeAlso:GetPos
	Method SetPos:Void (x:Float, y:Float, relative:Int = False )
		Local xd:Float
		Local yd:Float
		If relative = True Then
			For Local child := Eachin childObjList
				child.SetPos(x, y, relative)
			Next
		Else
			For Local child := Eachin childObjList
				xd = Self.xPos - child.xPos
				yd = Self.yPos - child.yPos
				child.SetPos(x-xd, y-yd, relative)
			Next
		Endif
		If relative = True
			xPos = xPos + x
			yPos = yPos + y
		Else
			xPos = x
			yPos = y
		Endif
	End
	'-----------------------------------------------------------------------------
'summery:Set the X-position of an object.
'seeAlso:GetPosX
	Method SetPosX:Void (x:Float, relative:Int = False )
		Local xd:Float
		If relative = True Then
			For Local child := Eachin childObjList
				child.SetPosX(x, relative)
			Next
		Else
			For Local child := Eachin childObjList
				xd = Self.xPos - child.xPos
				child.SetPosX(x-xd, relative)
			Next
		Endif
		If relative = True
			xPos = xPos + x
		Else
			xPos = x
		Endif
	End
	'-----------------------------------------------------------------------------
'summery:Set the Y-position of an object.
'seeAlso:GetPosY
	Method SetPosY:Void (y:Float, relative:Int = False )
		Local yd:Float
		If relative = True Then
			For Local child := Eachin childObjList
				child.SetPosY(y, relative)
			Next
		Else
			For Local child := Eachin childObjList
				yd = Self.yPos - child.yPos
				child.SetPosY(y-yd, relative)
			Next
		Endif
		If relative = True
			yPos = yPos + y
		Else
			yPos = y
		Endif
	End
	'-----------------------------------------------------------------------------
'summery:Set the Z-position of an object.
'seeAlso:GetPosZ
	Method SetPosZ:Void (z:Float, relative:Int = False )
		Local zd:Float
		If relative = True Then
			For Local child := Eachin childObjList
				child.SetPosZ(z, relative)
			Next
		Else
			For Local child := Eachin childObjList
				zd = Self.zPos - child.zPos
				child.SetPosZ(z-zd, relative)
			Next
		Endif
		If relative = True
			zPos = zPos + z
		Else
			zPos = z
		Endif
	End
	'-----------------------------------------------------------------------------
'summery:Set the radius of an object.
'seeAlso:GetRadius
	Method SetRadius:Void (newRadius:Float, relative:Int = False )
		If relative = True
			radius += newRadius/scaleX
		Else
			radius = newRadius/scaleX
		Endif
	End	
	'-----------------------------------------------------------------------------
'summery:Sets the area of an objects texture that is to be drawn.
	Method SetRenderArea:Void (renderOffsetX:Float, renderOffsetY:Float, renderWidth:Float, renderHeight:Float)
		If renderOffsetX + renderWidth <= w Then
			rox = renderOffsetX
			rw = renderWidth
		Else
			rox = 0.0
			rw = w
		Endif
		If renderOffsetY + renderHeight <= h Then
			roy = renderOffsetY
			rh = renderHeight
		Else
			roy = 0.0
			rh = h
		Endif
	End
	'-----------------------------------------------------------------------------
'summery:Set the scale of an object.
'seeAlso:GetScale
	Method SetScale:Void (newScale:Float, relative:Int = False )
		Local sd:Float
		If relative = True Then
			For Local child := Eachin childObjList
				child.SetScale(newScale, relative)
			Next
		Else
			For Local child := Eachin childObjList
				sd = Self.scaleX - child.scaleX
				child.SetScale(newScale-sd, relative)
			Next
		Endif
		If relative = True
			scaleX += newScale
			scaleY += newScale
		Else
			scaleX = newScale
			scaleY = newScale
		Endif
		_RotateSpriteCol()
	End
	'-----------------------------------------------------------------------------
'summery:Sets the X scale factor (width) of the object.
'seeAlso:GetScaleX
	Method SetScaleX:Void (newScale:Float, relative:Int = False )
		Local sd:Float
		If relative = True Then
			For Local child := Eachin childObjList
				child.SetScaleX(newScale, relative)
			Next
		Else
			For Local child := Eachin childObjList
				sd = Self.scaleX - child.scaleX
				child.SetScaleX(newScale-sd, relative)
			Next
		Endif
		If relative = True
			scaleX += newScale
		Else
			scaleX = newScale
		Endif
		_RotateSpriteCol()
	End
	'-----------------------------------------------------------------------------
'summery:Sets the Y scale factor (height) of the object.
'seeAlso:GetScaleY
	Method SetScaleY:Void (newScale:Float, relative:Int = False )
		Local sd:Float
		If relative = True Then
			For Local child := Eachin childObjList
				child.SetScaleY(newScale, relative)
			Next
		Else
			For Local child := Eachin childObjList
				sd = Self.scaleY - child.scaleY
				child.SetScaleY(newScale-sd, relative)
			Next
		Endif
		If relative = True
			scaleY += newScale
		Else
			scaleY = newScale
		Endif
		_RotateSpriteCol()
	End
	'-----------------------------------------------------------------------------
'summery:Set the speed of an object. If an angle is given, the speed will be added in that direction. If not, then in the objects angle.
'seeAlso:GetSpeed
	Method SetSpeed:Void (newSpeed:Float, ang:Float=9876.5)
	    Local a:Float
	    Local a2:Float
	
	    If ang = 9876.5 Then
	        a = Self.angle
	    Else
	        a = ang
	    Endif
	    a2 = a
		If newSpeed > speedMax Then newSpeed = speedMax
		If newSpeed < speedMin Then newSpeed = speedMin
	
	    speedX = Sin(a) * newSpeed
	    speedY = -Cos(a) * newSpeed
	
	    a= ATan2( speedY, speedX )+90.0
	    If a < 0.0 Then
	        a = a + 360.0
	    Else
	        If a > 360.0 Then
	            a = a - 360.0
	        Endif
	    Endif
	    speedAngle = a2 
	    speed = newSpeed
		If speed > speedMax Then speed = speedMax
	End 
	'-----------------------------------------------------------------------------
'summery:Set the objects speed angle.
'seeAlso:GetSpeedAngle
	Method SetSpeedAngle:Void (newAngle:Float)
		If newAngle < 0.0 Then
	     	newAngle = newAngle + 360.0
		Else
    		If newAngle > 360.0 Then
         		newAngle = newAngle - 360.0
    		Endif
		Endif
		speedX =  Sin(newAngle) * Self.speed
		speedY = -Cos(newAngle) * Self.speed
		speedAngle = newAngle
	End 
	'-----------------------------------------------------------------------------
'summery:Set the objects X speed.
'seeAlso:GetSpeedX
	Method SetSpeedX:Void (newSpeed:Float)
    	Local a:Float
    	speedX = Min(newSpeed, speedMax)
    	a = ATan2( speedY, speedX ) + 90.0
    	If a < 0.0 Then
        	a = a + 360.0
    	Else
	     	If a > 360.0 Then
	          	a = a - 360.0
	     	Endif
    	Endif
		speedAngle = a 
		speed = Sqrt(speedX * speedX + speedY * speedY)
		If speed > speedMax Then speed = speedMax
	End 
	'-----------------------------------------------------------------------------
'summery:Set the objects Y speed.
'seeAlso:GetSpeedY
	Method SetSpeedY:Void (newSpeed:Float)
    	Local a:Float
    	speedY = Min(newSpeed,speedMax)
    	a = ATan2( speedY, speedX )+90.0
    	If a < 0.0 Then
        	a = a + 360.0
    	Else
	     	If a > 360.0 Then
	          	a = a - 360.0
	     	Endif
    	Endif
		speedAngle = a 
		speed = Sqrt(speedX * speedX + speedY * speedY)
		If speed > speedMax Then speed = speedMax
	End 
	'-----------------------------------------------------------------------------
'summery:Set the objects spin speed.
'seeAlso:GetSpin
	Method SetSpin:Void (newSpin:Float, relative:Int = False )
		If relative = True
			speedSpin = speedSpin + newSpin
		Else
			speedSpin = newSpin
		Endif
	End	
	'-----------------------------------------------------------------------------
'summery:Set the objects tag field.
'seeAlso:GetTag
	Method SetTag:Void (t:Int )
		Self.tag = t
	End	
	'-----------------------------------------------------------------------------
'summery:Set the text of an object.
'seeAlso:GetText
	Method SetText:Void (t:String )
		Local linLen:Int
		text = t
		Local lines:String[] = t.Split("~n")
		linLen = lines.Length()
		If (Self.type = ftEngine.otText Or Self.type = ftEngine.otTextMulti) Then
			If linLen <= 1 And 
				Self.type = ftEngine.otText
				w = Self.objFont.Length(t)
			Else
				Self.type = ftEngine.otTextMulti
				Self.w = 0.0
				For Local _y:Int = 1 To linLen
					w = Max(Self.w, Float(Self.objFont.Length(lines[_y-1])))
				Next
			Endif
			Self.h = Self.objFont.lineHeight * linLen
			Self.rh = Self.h
			Self.rw = Self.w
			Self.radius = Max(Self.h, Self.w)/2.0
		Endif
	End	
	'-----------------------------------------------------------------------------
'summery:Sets the ID of the tiles texture map, at the given map row and column, starting from zero.
'seeAlso:GetTileID
	Method SetTileID:Void(column:Int, row:Int, id:Int)
		Self.tileMap.SetTileID(column, row, id)
	End
	
	'-----------------------------------------------------------------------------
'summery:Sets the ID of the tiles texture, at the given canvas coordinates, starting from zero.
'seeAlso:GetTileIDAt
	Method SetTileIDAt:Void(xp:Int,yp:Int, id:Int=-1)
		Local left2:Float, right2:Float, top2:Float, bottom2:Float
		Local tlW:Float, tlH:Float, tlxPos:Float, tlyPos:Float
		Local ytX:Int, ytY:Int, tilePos:Int, tileIDx:Int
		
		Local _cw:Float = engine.GetCanvasWidth()
		Local _ch:Float = engine.GetCanvasHeight()
		
		Local xoff:Float = Self.layer.xPos-Self.engine.camX
		Local yoff:Float = Self.layer.yPos-Self.engine.camY
		
		tlW = Self.tileMap.tileSizeX * Self.scaleX
		tlH = Self.tileMap.tileSizeY * Self.scaleY
		Local tlW2:Float = tlW/2.0
		Local tlH2:Float = tlH/2.0
		
		'Determine the first and last xCoordinate
		Local xFirst:Int = 1
		Local xLast:Int = Self.tileMap.tileCountX
		If Self.tileMap.tiles[0].tileType = 0
			For ytX = 1 To Self.tileMap.tileCountX
				tlxPos = xoff+xPos+Self.tileMap.tiles[ytX-1].xOff * Self.scaleX
				If (tlxPos+tlW2)>=0.0 And (tlxPos-tlW2)<=_cw Then 
					xFirst = ytX
					Exit
				Endif
			Next
			
			For ytX = (xFirst+1) To Self.tileMap.tileCountX
				tlxPos = xoff+xPos+Self.tileMap.tiles[ytX-1].xOff * Self.scaleX
				If (tlxPos+tlW2)<0.0 Or (tlxPos-tlW2)>_cw Then 
					xLast = ytX-1
					Exit
				Endif
			Next
		Endif
		'Determine the first and last yCoordinate
		Local yFirst:Int = 1
		Local yLast:Int = Self.tileMap.tileCountY
		If Self.tileMap.tiles[0].tileType = 0
			For ytY = 1 To Self.tileMap.tileCountY
				tilePos = (ytY-1)*Self.tileMap.tileCountX
				tlyPos = yoff+yPos+Self.tileMap.tiles[tilePos].yOff * Self.scaleY
				If (tlyPos+tlH2)>=0.0 And (tlyPos-tlH2)<=_ch Then 
					yFirst = ytY
					Exit
				Endif
			Next
			
			For ytY = (yFirst+1) To Self.tileMap.tileCountY
				tilePos = (ytY-1)*Self.tileMap.tileCountX
				tlyPos = yoff+yPos+Self.tileMap.tiles[tilePos].yOff * Self.scaleY
				If (tlyPos+tlH2)<0.0 Or (tlyPos-tlH2)>_ch Then 
					yLast = ytY-1
					Exit
				Endif
			Next
		Endif
		For ytY = yFirst To yLast
			For ytX = xFirst To xLast							
				tilePos = (ytX-1)+(ytY-1)*Self.tileMap.tileCountX
				tileIDx = Self.tileMap.tiles[tilePos].tileID

				tlxPos = Self.xPos + Self.tileMap.tiles[tilePos].xOff * Self.scaleX
				tlyPos = Self.yPos + Self.tileMap.tiles[tilePos].yOff * Self.scaleY
				left2   = tlxPos - (tlW)/2.0
				right2  = left2 + tlW
				top2    = tlyPos - (tlH)/2.0
				bottom2 = top2 + tlH
				If (yp < top2) Then Continue
				If (yp > bottom2) Then Continue
				If (xp < left2) Then Continue
				If (xp > right2) Then Continue
				Self.tileMap.tiles[tilePos].tileID = id
				If id > -1
					Self.tileMap.tiles[tilePos].tileSetIndex = Self.tileMap.GetTileSetIndex(id+1)

					Self.tileMap.tiles[tilePos].sizeX = Self.tileMap.tileSets[Self.tileMap.tiles[tilePos].tileSetIndex].tilewidth 
					Self.tileMap.tiles[tilePos].sizeY = Self.tileMap.tileSets[Self.tileMap.tiles[tilePos].tileSetIndex].tileheight 
				Endif
				Return 
			Next
		Next	
	End

	'-----------------------------------------------------------------------------
'summery:Sets the tile scale modification factors which are used during rendering.
	Method SetTileSModXY:Void(xMod:Float, yMod:Float)
		Self.tileMap.SetTileSModXY(xMod, yMod)
	End
	'-----------------------------------------------------------------------------
#Rem
'summery:Set the objects touch mode.
'Touch modes can be:
[list][*]Const tmCircle% = 1
[*]Const tmBound% = 2    (This will check against the bounding box of the object)
[*]Const tmBox% = 3    (this will check against the rotated box of the object)[/list]
#End
'seeAlso:GetTouchMode,CheckTouchHit
	Method SetTouchMode:Void (touch:Int)
		touchMode = touch
	End
	'-----------------------------------------------------------------------------
'summery:Set if an object will wrap around the screen borders automatically.
'seeAlso:SetWrapScreenX,SetWrapScreenY
	Method SetWrapScreen:Void (ws:Bool )
		Self.isWrappingX = ws
		Self.isWrappingY = ws
	End	
	'-----------------------------------------------------------------------------
'summery:Set if an object will wrap around the left/right screen borders automatically.
'seeAlso:SetWrapScreen,SetWrapScreenY
	Method SetWrapScreenX:Void (wsx:Bool )
		Self.isWrappingX = wsx
	End	
	'-----------------------------------------------------------------------------
'summery:Set if an object will wrap around the top/bottom screen borders automatically.
'seeAlso:SetWrapScreen,SetWrapScreenX
	Method SetWrapScreenY:Void (wsy:Bool )
		Self.isWrappingY = wsy
	End	
'-----------------------------------------------------------------------------
'changes:2.01:Add flag to affect children too.
'summery:Set if an object is visible.
'seeAlso:GetVisible
	Method SetVisible:Void (visible:Bool = True, children:Bool = False  )
		isVisible = visible
		If children = True
			For Local child := Eachin childObjList
				child.SetVisible(visible, children)
			Next
		Endif
	End
	'-----------------------------------------------------------------------------
#Rem
'summery:Set the width of an object.
The stored width is the result of the given parameter divided by the current X scale factor.
#End
'seeAlso:GetWidth,SetHeight
	Method SetWidth:Void (width:Float )
		Self.w = width/scaleX
		_RotateSpriteCol()
	End	
'#DOCOFF#	
	'-----------------------------------------------------------------------------
	Method _Init:ftObject()
		xPos = 0.0
		yPos = 0.0
		zPos = 0.0
		w = 0.0
		h = 0.0

		x2 = 0.0								'Render -- case ftEngine.otLine
		y2 = 0.0								'Render -- case ftEngine.otLine
		'verts = verts.Resize(0)
		verts = []
		rw = 0.0
		rh = 0.0
		rox = 0.0
		roy = 0.0
	
		angle = 0.0
		scaleX = 1.0
		scaleY = 1.0
		radius = 1.0
		friction = 0.0
	
		speed = 0.0
		speedX = 0.0
		speedY = 0.0
		speedSpin = 0.0
		speedAngle = 0.0
		speedMax = 9999.0
		speedMin = -9999.0
	
		engine = Null
	
		red = 255.0
		blue  = 255.0
		green = 255.0
		alpha = 1.0
		blendMode = BlendMode.Alpha 
			
		'objImg = objImg.Resize(0)
		objImg = []
			
		frameCount = 1
		frameStart = 0
		frameEnd = 0
		frameLength = 0
			
		layer = Null
		layerNode = Null
			
		parentObj = Null
		parentNode = Null
			
		marker = Null
		markerNode = Null
			
		objFont = Null
			
		id = 0
		textMode = 0
		name = ""
		text = ""
		tag = 0
		type = ftEngine.otImage
		groupID = 0
			
		collType = 0
		collScale = 1.0
		collGroup = 0
		collWith = [0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0]
		colCheck = False
			
		isVisible = True
		isAnimated = False
		isActive = True
		isWrappingX = False
		isWrappingY = False
		touchMode = 0
		isFlipH = False 
		isFlipV = False   
		
		onDeleteEvent = False
		onRenderEvent = False
		onUpdateEvent = True
			
		x1c = 0.0
		y1c = 0.0
		x2c = 0.0
		y2c = 0.0
		x3c = 0.0
		y3c = 0.0
		x4c = 0.0
		y4c = 0.0
		
		deleted = False
		If tileMap <> Null
			tileMap.Remove()
		Endif

		dataObj = Null
#If FantomX_UsePhysics = 1
		box2DBody = Null
#Endif			
		objPathUpdAngle = False
			
		offAngle = 0.0
		handleX = 0.5
		handleY = 0.5
		hOffX = 0.0
		hOffY = 0.0
			
		animMng = Null
		currImageIndex = 1
		currImageFrame = 1
			
		minX = 0.0
		minY = 0.0
		maxX = 0.0
		maxY = 0.0
		
		Return Self
	End
	'-----------------------------------------------------------------------------
	Method _IsObjAt:Bool(px:Float, py:Float)
		Local txOff:Float = 0.0
		Local tyOff:Float = 0.0
		Local ret:Bool = False

		If deleted = False Then
			Select type

				Case ftEngine.otText
					Select textMode
						Case 0   'taTopLeft
							txOff = -(Float(Self.objFont.Length(Self.text))/2.0)*Self.scaleX
							tyOff = (Self.objFont.lineHeight/2.0*Self.scaleY)
							
				     	Case 1   'taTopCenter
							txOff = 0.0
							tyOff = (Self.objFont.lineHeight/2.0*Self.scaleY)
							
						Case 2   'taTopRight
							txOff = (Float(Self.objFont.Length(Self.text))/2.0)*Self.scaleX
							tyOff = (Self.objFont.lineHeight/2.0*Self.scaleY)
						
						Case 7   'taCenterLeft
							txOff = -(Float(Self.objFont.Length(Self.text))/2.0)*Self.scaleX
							tyOff = 0.0
							
				     	Case 3   'taCenterCenter
							txOff = 0.0
							tyOff = 0.0
							
						Case 4   'taCenterRight
							txOff = (Float(Self.objFont.Length(Self.text))/2.0)*Self.scaleX
							tyOff = 0.0
														
						Case 8   'taBottomLeft
							txOff = -(Float(Self.objFont.Length(Self.text))/2.0)*Self.scaleX
							tyOff = -(Self.objFont.lineHeight/2.0*Self.scaleY)
							
				     	Case 5   'taBottomCenter
							txOff = 0.0
							tyOff = -(Self.objFont.lineHeight/2.0*Self.scaleY)
							
						Case 6   'taBottomRight
							txOff = (Float(Self.objFont.Length(Self.text))/2.0)*Self.scaleX
							tyOff = -(Self.objFont.lineHeight/2.0*Self.scaleY)
						
					End
					
					Select Self.touchMode
				     	Case ftEngine.tmCircle
							ret = ftColl_PointInsideCircle(Self, px+txOff, py-tyOff)
						Case ftEngine.tmBox
							ret = ftColl_PointInsidePolygon(Self, px+txOff, py-tyOff)
						Default
							ret = ftColl_PointInsideBound(Self, px+txOff, py-tyOff)
					End
				Default
					Select Self.touchMode
				     	Case ftEngine.tmCircle
							ret = ftColl_PointInsideCircle(Self, px, py)
						Case ftEngine.tmBox
							ret = ftColl_PointInsidePolygon(Self, px+txOff, py-tyOff)
						Default
							ret = ftColl_PointInsideBound(Self, px, py)
					End
			End
		Endif

		Return ret
	End
	'-----------------------------------------------------------------------------
	Method _OrbitChild:Int (angDiff:Float)
		Local childAngle:Float = Self.parentObj.GetTargetAngle(Self)
		Local childDist:Float = Self.parentObj.GetTargetDist(Self)
		Local vec:Float[] = Self.parentObj.GetVector(childDist, childAngle + angDiff)
		Self.SetPos(vec[0],vec[1])
		Return 0
	End
	
	'-----------------------------------------------------------------------------
	Method _RotateSpriteCol:Void()
		Local cx:Float
		Local cy:Float
		Local SinVal:Float
		Local CosVal:Float
		Local xSinVal:Float
		Local ySinVal:Float
		Local xCosVal:Float
		Local yCosVal:Float
		Local ang:Float

		Self.hOffX = (0.5-Self.handleX)*w*Self.scaleX
		Self.hOffY = (0.5-Self.handleY)*h*Self.scaleY

		ang = (Self.angle + Self.offAngle)
		SinVal = Sin(ang)
		CosVal = Cos(ang)

		cx = -Self.w/2.0*Self.scaleX
		cy =  Self.h/2.0*Self.scaleY
    
		If Self.isFlipV = True Then cy *= -1
		If Self.isFlipH = True Then cx *= -1


		xCosVal = cx * CosVal
		yCosVal = cy * CosVal
		xSinVal = cx * SinVal
		ySinVal = cy * SinVal

		Self.x1c=(xCosVal)-(ySinVal)+Self.hOffX
		Self.y1c=(yCosVal)+(xSinVal)+Self.hOffY

		'x = x * -1
		Self.x2c=(-xCosVal)-( ySinVal)+Self.hOffX
		Self.y2c=( yCosVal)+(-xSinVal)+Self.hOffY

		'y = y * -1
		Self.x3c=(-xCosVal)-(-ySinVal)+Self.hOffX
		Self.y3c=(-yCosVal)+(-xSinVal)+Self.hOffY

		'x = x * -1
		Self.x4c=( xCosVal)-(-ySinVal)+Self.hOffX
		Self.y4c=(-yCosVal)+( xSinVal)+Self.hOffY

		Self.minX = Min(Min(Self.x1c, Self.x2c), Min(Self.x3c, Self.x4c))
		Self.minY = Min(Min(Self.y1c, Self.y2c), Min(Self.y3c, Self.y4c))
		Self.maxX = Max(Max(Self.x1c, Self.x2c), Max(Self.x3c, Self.x4c))
		Self.maxY = Max(Max(Self.y1c, Self.y2c), Max(Self.y3c, Self.y4c))
	End
	'-----------------------------------------------------------------------------
	Method _WrapScreenX:Void()
		If xPos < 0.0  
			Self.SetPos(engine.canvasWidth,0.0,True)
		Elseif xPos > engine.canvasWidth  
			Self.SetPos(-engine.canvasWidth,0.0,True)
		Endif
	End
	'-----------------------------------------------------------------------------
	Method _WrapScreenY:Void()
		If yPos < 0.0  
			Self.SetPos(0.0,engine.canvasHeight,True)
		Elseif yPos > engine.canvasHeight  
			Self.SetPos(0.0,-engine.canvasHeight,True)
		Endif
	End

'#DOCON#	
	'------------------------------------------
'summery:Update an object with the given updatespeed factor.
	Method Update:Void(delta:Float=1.0)

		If isActive = True And deleted = False Then
			If engine.isPaused = False Then
				If isAnimated = True And Self.animMng.isAnimPaused = False
					Self.animMng.UpdateCurrAnim(delta* engine.timeScale)
				Endif
	
			    Local currSpeed:Float = speed
			    Local currFriction:Float = friction * delta * engine.timeScale

			    If currSpeed > 0.0 
				    currSpeed = currSpeed - currFriction
				    If currSpeed < currFriction  
				    	speed  = 0.0
					    speedX = 0.0
					    speedY = 0.0
					Else
					    speed  = currSpeed
					    speedX = Sin(speedAngle) * currSpeed
					    speedY = -Cos(speedAngle) * currSpeed
						Self.SetPos(speedX * delta * engine.timeScale, speedY * delta * engine.timeScale, True)	
					Endif
				Elseif currSpeed < 0.0
			    	currSpeed = currSpeed + currFriction
				    If currSpeed > currFriction  
					    speed  = 0.0
					    speedX = 0.0
					    speedY = 0.0
					Else
					    speed  = currSpeed
					    speedX = Sin(speedAngle) * currSpeed
					    speedY = -Cos(speedAngle) * currSpeed
						Self.SetPos(speedX * delta * engine.timeScale, speedY * delta * engine.timeScale, True)	
					Endif
				Endif
			    If speedSpin  <> 0.0 
			        Local absSpeedSpin:Float = speedSpin
			        If absSpeedSpin < 0 Then absSpeedSpin = absSpeedSpin * -1.0
			        If absSpeedSpin < currFriction 
			            speedSpin = 0.0
			        Else
			           If speedSpin > 0.0 
			                speedSpin = speedSpin - currFriction
			           Else
			                speedSpin = speedSpin + currFriction
			           Endif
			           Self.SetAngle(speedSpin * delta * engine.timeScale, True)
			        Endif
			    Endif
	
				If Self.isWrappingX Then Self._WrapScreenX()
				If Self.isWrappingY Then Self._WrapScreenY()
			Endif
			For Local child := Eachin childObjList 
				If child.isActive Then child.Update(delta)
			Next
			For Local trans:ftTrans = Eachin transitionList
				trans.Update()
			Next
			For Local timer:ftTimer = Eachin timerList
				timer.Update()
			Next
			If engine.isPaused = False Then
				If Self.onUpdateEvent = True Then engine.OnObjectUpdate(Self)
			Endif
		Endif
		Self.CleanupLists()
		
	End
  '*****************************************************************

End


#rem
footer:This fantomX framework is released under the MIT license:
[quote]Copyright (c) 2011-2016 Michael Hartlef

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the software, and to permit persons to whom the software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
[/quote]
#end