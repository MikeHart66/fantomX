#rem
	Title:        fantomX
	Description:  A 2D game framework for the Monkey programming language
	
	Author:       Michael Hartlef
	Contact:      michaelhartlef@gmail.com
	
	Website:      http://www.fantomgl.com
	
	License:      MIT
#End

Import fantomX

'#DOCON#
'nav:<blockquote><nav><b>fantomX documentation</b> | <a href="index.html">Home</a> | <a href="classes.html">Classes</a> | <a href="3rdpartytools.html">3rd party tools</a> | <a href="examples.html">Examples</a> | <a href="changes.html">Changes</a></nav></blockquote>
'header:The module cftCollisions is a collection of several of several collision dectection functions. these are utilized mostly inside the ftObject class to determine if a collision has happened.

'-----------------------------------------------------------------------------
Function ftColl_Bound2Bound:Bool(obj1:ftObject, obj2:ftObject)
	Local left1:Float
	Local left2:Float
	Local right1:Float
	Local right2:Float
	Local top1:Float
	Local top2:Float
	Local bottom1:Float
	Local bottom2:Float
	Local h:Float
	Local w:Float
	
	Local wxs1:Float = obj1.w * obj1.scaleX * obj1.collScale
	Local hys1:Float = obj1.h * obj1.scaleY * obj1.collScale
	Local wxs2:Float = obj2.w * obj2.scaleX * obj2.collScale
	Local hys2:Float = obj2.h * obj2.scaleY * obj2.collScale

	left1   = obj1.xPos + obj1.handleOffX - wxs1/2.0
	right1  = left1 + wxs1

	left2   = obj2.xPos + obj2.handleOffX - wxs2/2.0
	right2  = left2 + wxs2

	If (right1 < left2) Then Return False
	If (left1 > right2) Then Return False

	top1    = obj1.yPos + obj1.handleOffY - hys1/2.0
	bottom1 = top1 + hys1
	
	top2    = obj2.yPos + obj2.handleOffY - hys2/2.0
	bottom2 = top2 + hys2


	If (bottom1 < top2) Then Return False
	If (top1 > bottom2) Then Return False
	Return True
End

'-----------------------------------------------------------------------------
Function ftColl_IsBetween:Bool(v:Float,l:Float,h:Float)
	If v >= l And v <= h Then Return True
	Return False
End

'-----------------------------------------------------------------------------
Function ftColl_IsIn:Bool(p:ftVec2Dp, a:ftVec2Dp, b:ftVec2Dp, d:ftVec2Dp)
	Local v:ftVec2Dp = New ftVec2Dp
	Local v1:ftVec2Dp = New ftVec2Dp
	Local v2:ftVec2Dp = New ftVec2Dp
	
	v.x = p.x - a.x
	v.y = p.y - a.y
	v1.x = b.x - a.x
	v1.y = b.y - a.y
	v2.x = d.x - a.x
	v2.y = d.y - a.y
	
	If ftColl_IsBetween(ftColl_Vec2DotProduct(v, v1), 0, ftColl_Vec2DotProduct(v1, v1)) And ftColl_IsBetween(ftColl_Vec2DotProduct(v, v2), 0, ftColl_Vec2DotProduct(v2, v2)) Then Return True
	Return False
End

'-----------------------------------------------------------------------------
Function ftColl_Box2Box:Bool(pSpriteA:ftObject, pSpriteB:ftObject)
	' -- Corner points
	Local ap1:ftVec2Dp = New ftVec2Dp
	Local ap2:ftVec2Dp = New ftVec2Dp 
	Local ap3:ftVec2Dp = New ftVec2Dp 
	Local ap4:ftVec2Dp = New ftVec2Dp
	Local bp1:ftVec2Dp = New ftVec2Dp
	Local bp2:ftVec2Dp = New ftVec2Dp 
	Local bp3:ftVec2Dp = New ftVec2Dp 
	Local bp4:ftVec2Dp = New ftVec2Dp
		
	Local a1p1:ftVec2Dp = New ftVec2Dp
	Local a1p2:ftVec2Dp = New ftVec2Dp
	Local a2p1:ftVec2Dp = New ftVec2Dp
	Local a2p2:ftVec2Dp = New ftVec2Dp
	Local a3p1:ftVec2Dp = New ftVec2Dp
	Local a3p2:ftVec2Dp = New ftVec2Dp
	Local a4p1:ftVec2Dp = New ftVec2Dp
	Local a4p2:ftVec2Dp = New ftVec2Dp

	Local b1p1:ftVec2Dp = New ftVec2Dp
	Local b1p2:ftVec2Dp = New ftVec2Dp
	Local b2p1:ftVec2Dp = New ftVec2Dp
	Local b2p2:ftVec2Dp = New ftVec2Dp
	Local b3p1:ftVec2Dp = New ftVec2Dp
	Local b3p2:ftVec2Dp = New ftVec2Dp
	Local b4p1:ftVec2Dp = New ftVec2Dp
	Local b4p2:ftVec2Dp = New ftVec2Dp

	' -- Each rectangle defined by 4 lines - 0..3
	Local a:tLine2D[] = [New tLine2D,New tLine2D,New tLine2D,New tLine2D]
	Local b:tLine2D[] = [New tLine2D,New tLine2D,New tLine2D,New tLine2D]
	Local la:tLine2D = New tLine2D
		
	Local lb:tLine2D = New tLine2D
		
	If ftColl_Circle2CircleInBox(pSpriteA  , pSpriteB) = False Then Return False

	' -- Sprite A
	ap1.x = pSpriteA.x1c * pSpriteA.collScale + pSpriteA.xPos
	ap1.y = pSpriteA.y1c * pSpriteA.collScale + pSpriteA.yPos
		
	ap2.x = pSpriteA.x2c * pSpriteA.collScale + pSpriteA.xPos
	ap2.y = pSpriteA.y2c * pSpriteA.collScale + pSpriteA.yPos
		
	ap3.x = pSpriteA.x3c * pSpriteA.collScale + pSpriteA.xPos
	ap3.y = pSpriteA.y3c * pSpriteA.collScale + pSpriteA.yPos
		
	ap4.x = pSpriteA.x4c * pSpriteA.collScale + pSpriteA.xPos
	ap4.y = pSpriteA.y4c * pSpriteA.collScale + pSpriteA.yPos
		
	
	' -- Sprite B
	bp1.x = pSpriteB.x1c * pSpriteB.collScale + pSpriteB.xPos
	bp1.y = pSpriteB.y1c * pSpriteB.collScale + pSpriteB.yPos
		
	bp2.x = pSpriteB.x2c * pSpriteB.collScale + pSpriteB.xPos
	bp2.y = pSpriteB.y2c * pSpriteB.collScale + pSpriteB.yPos
	
	bp3.x = pSpriteB.x3c * pSpriteB.collScale + pSpriteB.xPos
	bp3.y = pSpriteB.y3c * pSpriteB.collScale + pSpriteB.yPos
	
	bp4.x = pSpriteB.x4c * pSpriteB.collScale + pSpriteB.xPos
	bp4.y = pSpriteB.y4c * pSpriteB.collScale + pSpriteB.yPos


	' -- Test for corners inside first - faster
	If ftColl_IsIn(bp1, ap1, ap2, ap4) Then Return True
	If ftColl_IsIn(bp2, ap1, ap2, ap4) Then Return True
	If ftColl_IsIn(bp3, ap1, ap2, ap4) Then Return True
	If ftColl_IsIn(bp4, ap1, ap2, ap4) Then Return True
	
	If ftColl_IsIn(ap1, bp1, bp2, bp4) Then Return True
	If ftColl_IsIn(ap2, bp1, bp2, bp4) Then Return True
	If ftColl_IsIn(ap3, bp1, bp2, bp4) Then Return True
	If ftColl_IsIn(ap4, bp1, bp2, bp4) Then Return True
	
	
	' -- Getting pointers
	a1p1 = a[0].p1
	a1p2 = a[0].p2
	
	a2p1 = a[1].p1
	a2p2 = a[1].p2
	
	a3p1 = a[2].p1
	a3p2 = a[2].p2
	
	a4p1 = a[3].p1
	a4p2 = a[3].p2
		
	b1p1 = b[0].p1
	b1p2 = b[0].p2
	
	b2p1 = b[1].p1
	b2p2 = b[1].p2
	
	b3p1 = b[2].p1
	b3p2 = b[2].p2
	
	b4p1 = b[3].p1
	b4p2 = b[3].p2

	' -- Box A
	a1p1.x = ap1.x
	a1p1.y = ap1.y
	a1p2.x = ap2.x
	a1p2.y = ap2.y
	
	a2p1.x = ap2.x
	a2p1.y = ap2.y
	a2p2.x = ap3.x
	a2p2.y = ap3.y
	
	a3p1.x = ap3.x
	a3p1.y = ap3.y
	a3p2.x = ap4.x
	a3p2.y = ap4.y
	
	a4p1.x = ap4.x
	a4p1.y = ap4.y
	a4p2.x = ap1.x
	a4p2.y = ap1.y
		
	' -- Box B
	b1p1.x = bp1.x
	b1p1.y = bp1.y
	b1p2.x = bp2.x
	b1p2.y = bp2.y
	
	b2p1.x = bp2.x
	b2p1.y = bp2.y
	b2p2.x = bp3.x
	b2p2.y = bp3.y
	
	b3p1.x = bp3.x
	b3p1.y = bp3.y
	b3p2.x = bp4.x
	b3p2.y = bp4.y
	
	b4p1.x = bp4.x
	b4p1.y = bp4.y
	b4p2.x = bp1.x
	b4p2.y = bp1.y
	
	' -- Test for edge intersection
	For Local i:Int = 0 To 3
		For Local j:Int = 0 To 3
	   		la = a[i]
	   		lb = b[j]
	   		If ftColl_CrossDistance(la, lb, 0) <> -1 Then
	     		Return True
	   		Endif
		Next
	Next
	Return False
End

'-----------------------------------------------------------------------------
Function ftColl_Box2Circle:Bool(obj2:ftObject, obj1:ftObject)
	Local rf:Float
	Local obj1X:Float
	Local obj1Y:Float
	Local bp1:ftVec2Dp = New ftVec2Dp
	Local bp2:ftVec2Dp = New ftVec2Dp
	Local bp3:ftVec2Dp = New ftVec2Dp
	Local bp4:ftVec2Dp = New ftVec2Dp	

	obj1X = obj1.xPos + obj1.handleOffX
	obj1Y = obj1.yPos + obj1.handleOffY
	
	If ftColl_PointInsidePolygon(obj2, obj1X, obj1Y) Then Return True
	
	rf = obj1.radius * obj1.scaleX * obj1.collScale
	bp1.x = obj2.x1c * obj2.collScale + obj2.xPos
	bp1.y = obj2.y1c * obj2.collScale + obj2.yPos
	bp2.x = obj2.x2c * obj2.collScale + obj2.xPos
	bp2.y = obj2.y2c * obj2.collScale + obj2.yPos
	bp3.x = obj2.x3c * obj2.collScale + obj2.xPos
	bp3.y = obj2.y3c * obj2.collScale + obj2.yPos
	bp4.x = obj2.x4c * obj2.collScale + obj2.xPos
	bp4.y = obj2.y4c * obj2.collScale + obj2.yPos

	If ftColl_Line2Circle(bp1.x, bp1.y, bp2.x, bp2.y, obj1X, obj1Y, rf) Then Return True
	If ftColl_Line2Circle(bp2.x, bp2.y, bp3.x, bp3.y, obj1X, obj1Y, rf) Then Return True
	If ftColl_Line2Circle(bp3.x, bp3.y, bp4.x, bp4.y, obj1X, obj1Y, rf) Then Return True
	If ftColl_Line2Circle(bp4.x, bp4.y, bp1.x, bp1.y, obj1X, obj1Y, rf) Then Return True

	Return False
End
	  
'-----------------------------------------------------------------------------
Function ftColl_Circle2Box:Bool(obj1:ftObject, obj2:ftObject)
	Local rf:Float
	Local obj1X:Float
	Local obj1Y:Float
	Local bp1:ftVec2Dp = New ftVec2Dp
	Local bp2:ftVec2Dp = New ftVec2Dp
	Local bp3:ftVec2Dp = New ftVec2Dp
	Local bp4:ftVec2Dp = New ftVec2Dp
	
	obj1X = obj1.xPos + obj1.handleOffX
	obj1Y = obj1.yPos + obj1.handleOffY

	If ftColl_PointInsidePolygon(obj2, obj1X, obj1Y) Then Return True

	rf = obj1.radius * obj1.scaleX * obj1.collScale
	bp1.x = obj2.x1c * obj2.collScale + obj2.xPos
	bp1.y = obj2.y1c * obj2.collScale + obj2.yPos
	bp2.x = obj2.x2c * obj2.collScale + obj2.xPos
	bp2.y = obj2.y2c * obj2.collScale + obj2.yPos
	bp3.x = obj2.x3c * obj2.collScale + obj2.xPos
	bp3.y = obj2.y3c * obj2.collScale + obj2.yPos
	bp4.x = obj2.x4c * obj2.collScale + obj2.xPos
	bp4.y = obj2.y4c * obj2.collScale + obj2.yPos

	If ftColl_Line2Circle(bp1.x, bp1.y, bp2.x, bp2.y, obj1X, obj1Y, rf) Then Return True
	If ftColl_Line2Circle(bp2.x, bp2.y, bp3.x, bp3.y, obj1X, obj1Y, rf) Then Return True
	If ftColl_Line2Circle(bp3.x, bp3.y, bp4.x, bp4.y, obj1X, obj1Y, rf) Then Return True
	If ftColl_Line2Circle(bp4.x, bp4.y, bp1.x, bp1.y, obj1X, obj1Y, rf) Then Return True
	Return False
End


'-----------------------------------------------------------------------------
Function ftColl_Circle2Circle:Bool(obj1:ftObject, obj2:ftObject)
	Local xf:Float
	Local yf:Float
	Local rf:Float
	
	xf = (obj1.xPos + obj1.handleOffX) - (obj2.xPos + obj2.handleOffX)
	xf *= xf
	yf = (obj1.yPos + obj1.handleOffY) - (obj2.yPos + obj2.handleOffY)
	yf *= yf
	rf = ( obj1.radius * obj1.scaleX  * obj1.collScale) + ( obj2.radius * obj2.scaleX * obj2.collScale )
	rf *= rf
	If (xf+yf) < rf Then Return True
	Return False
End
	
'-----------------------------------------------------------------------------
Function ftColl_Circle2CircleInBox:Bool(obj1:ftObject, obj2:ftObject)
	Local xf:Float
	Local yf:Float
	Local rf:Float
	
	xf = (obj1.xPos + obj1.handleOffX) - (obj2.xPos + obj2.handleOffX)
	xf *= xf
	yf = (obj1.yPos + obj1.handleOffY) - (obj2.yPos + obj2.handleOffY)
	yf *= yf
	rf = ((obj1.radius * obj1.scaleX  * obj1.collScale) + (obj2.radius * obj2.scaleX * obj2.collScale)) * 1.42
	rf *= rf
	If (xf+yf) < rf Then Return True
	Return False
End

'-----------------------------------------------------------------------------
Function ftColl_Circle2LineObj:Bool(obj1:ftObject, obj2:ftObject)
	Local rf:Float
	Local obj1X:Float
	Local obj1Y:Float
	Local bp1:ftVec2Dp = New ftVec2Dp
	Local bp2:ftVec2Dp = New ftVec2Dp
	      
	obj1X = obj1.xPos + obj1.handleOffX
	obj1Y = obj1.yPos + obj1.handleOffY
	rf = obj1.radius * obj1.scaleX * obj1.collScale
	bp1.x = obj2.x1c * obj2.collScale + obj2.xPos
	bp1.y = obj2.y1c * obj2.collScale + obj2.yPos
	bp2.x = obj2.x2c * obj2.collScale + obj2.xPos
	bp2.y = obj2.y2c * obj2.collScale + obj2.yPos
	If ftColl_Line2Circle(bp1.x, bp1.y, bp2.x, bp2.y, obj1X, obj1Y, rf) Then Return True
	Return False
End

'-----------------------------------------------------------------------------
Function ftColl_CrossDistance:Float(l1:tLine2D, l2:tLine2D, safetyZone:Float)
	'  returns distance between p1 and crossing of two lines, -1 when no cross found
	Local result:Float  '  cross not found
	Local q2:Float
	Local t2:Float
	Local t:Float
	Local k1:Float
	Local k2:Float
	Local xp:Float
	Local yp:Float
	Local minx1:Float
	Local maxx1:Float
	Local miny1:Float
	Local maxy1:Float
	Local minx2:Float
	Local maxx2:Float
	Local miny2:Float
	Local maxy2:Float
	Local tmp:Float
	Local q1:Float
	Local p1start:ftVec2Dp = New ftVec2Dp
	Local p1end:ftVec2Dp = New ftVec2Dp
	Local p2start:ftVec2Dp = New ftVec2Dp
	Local p2end:ftVec2Dp = New ftVec2Dp

	result = -1
	p1start.x = l1.p1.x
	p1start.y = l1.p1.y
	p1end.x = l1.p2.x
	p1end.y = l1.p2.y
	p2start.x = l2.p1.x
	p2start.y = l2.p1.y
	p2end.x = l2.p2.x
	p2end.y = l2.p2.y
	t = p1end.x - p1start.x

	If t <> 0 Then
		k1 = (p1end.y - p1start.y) / t
	Else
		k1 = 100000.0 
	Endif
	
	q1 = p1start.x - (k1 * p1start.x)
	t = p2end.x - p2start.x

	If t <> 0 Then
		k2 = (p2end.y - p2start.y) / t
	Else
		k2 = 100000.0 
	Endif

	q2 = p2start.y - (k2 * p2start.x)
	t2 = k2 - k1
	
	If Abs(t2) < 0.0001 Then
		yp = 100000.0
		xp = 100000.0
	Else
		yp = (q1*k2-q2*k1) / t2
		xp = (q1-q2) / t2
	Endif

	'  special cases
	If (p1end.x - p1start.x) = 0 Then
		xp = p1start.x
		yp = k2*xp+q2
	Endif

	If (p2end.x - p2start.x) = 0 Then
		xp = p2start.x
		yp = k1*xp+q1
	Endif
	'  end of special cases

	minx1 = Min(p1start.x, p1end.x)
	maxx1 = Max(p1start.x, p1end.x)
	miny1 = Min(p1start.y, p1end.y)
	maxy1 = Max(p1start.y, p1end.y)
	minx2 = Min(p2start.x, p2end.x)
	maxx2 = Max(p2start.x, p2end.x)
	miny2 = Min(p2start.y, p2end.y)
	maxy2 = Max(p2start.y, p2end.y)

	If  xp + safetyZone < minx1  Or
			xp - safetyZone > maxx1  Or
			yp + safetyZone < miny1  Or
			yp - safetyZone > maxy1  Or
			xp + safetyZone < minx2  Or
			xp - safetyZone > maxx2  Or
			yp + safetyZone < miny2  Or
			yp - safetyZone > maxy2  Then
		result = -1.0
	Else
		tmp = (xp-p1start.x)*(xp-p1start.x)
		tmp = tmp + ((yp-p1start.y)*(yp-p1start.y))
		tmp = Sqrt(tmp)
		result = tmp
	Endif

	Return result

End

'-----------------------------------------------------------------------------
Function ftColl_Line2Circle:Bool(x1:Float, y1:Float, x2:Float, y2:Float, px:Float, py:Float, r:Float)
	Local sx:Float
	Local sy:Float
	Local cx:Float
	Local cy:Float
	Local q:Float
	
	sx = x2 - x1
	sy = y2 - y1
	q = (((px-x1) * (x2-x1)) + ((py - y1) * (y2-y1))) / ((sx*sx) + (sy*sy))
	If q < 0.0 Then q = 0.0
	If q > 1.0 Then q = 1.0
	cx = ((1-q) * x1) + (q*x2)
	cy = ((1-q) * y1) + (q*y2)
	Return (ftColl_PointToPointDist(px,py,cx,cy) < r)
    'Return (ftColl_PointToPointDist_Square(px,py,cx,cy) < (r*r))
End

'-----------------------------------------------------------------------------
Function ftColl_Line2Line( x0:Float, y0:Float , x1:Float, y1:Float,x2:Float ,y2:Float, x3:Float, y3:Float )
	Local n:Float=(y0-y2)*(x3-x2)-(x0-x2)*(y3-y2)
	Local d:Float=(x1-x0)*(y3-y2)-(y1-y0)*(x3-x2)
		
	If Abs(d) < 0.0001 
		' Lines are parallel!
		Return False
	Else
		' Lines might cross!
		Local Sn:Float=(y0-y2)*(x1-x0)-(x0-x2)*(y1-y0)
		Local AB:Float=n/d
		If AB>0.0 And AB<1.0
			Local CD:Float=Sn/d
			If CD>0.0 And CD<1.0
				' Intersection Point
				Local X=x0+AB*(x1-x0)
		       	Local Y=y0+AB*(y1-y0)
				Return True
			End If
		End If
		' Lines didn't cross, because the intersection was beyond the end points of the lines
	Endif
	' Lines do Not cross!
	Return False
End

'-----------------------------------------------------------------------------
Function ftColl_PointInsideBound:Bool(obj:ftObject, px:Float, py:Float)
	Local t:Float
	Local b:Float
	Local l:Float
	Local r:Float
	Local hys:Float
	Local wxs:Float
	
	wxs = obj.w * obj.scaleX * obj.collScale
	hys = obj.h * obj.scaleY * obj.collScale
	l =  obj.xPos + obj.handleOffX - (wxs/2.0)
	r =  l + wxs
	t =  obj.yPos + obj.handleOffY  - (hys/2.0)
	b += t + hys
	If px < l Or px > r Or py < t Or py > b Then Return False
	Return True
End

'-----------------------------------------------------------------------------
Function ftColl_PointInsideCircle:Bool(obj:ftObject, _px:Float, _py:Float)
	Local xf:Float
	Local yf:Float
	Local rf:Float
	
	xf = (obj.xPos + obj.handleOffX - _px)
	xf = (xf * xf)
	yf = (obj.yPos + obj.handleOffY - _py)
	yf = (yf * yf)
	rf = (obj.radius * obj.scaleX * obj.collScale)
	rf = (rf * rf)
	If ((xf+yf) <= rf) Then Return True
	Return False
End

'-----------------------------------------------------------------------------
Function ftColl_PointInsidePolygon:Bool(obj:ftObject, px:Float, py:Float)
	Local cx:Float
	Local cy:Float
	Local SinVal:Float
	Local CosVal:Float
	Local t:Float
	Local b:Float
	Local l:Float
	Local r:Float
	Local hys:Float
	Local wxs:Float
	
	SinVal = Sin(-obj.angle)
	CosVal = Cos(-obj.angle)
	cx = px - obj.xPos
	cy = py - obj.yPos
	px =(cx*CosVal) - (cy*SinVal) + obj.xPos
	py =(cy*CosVal) + (cx*SinVal) + obj.yPos
	wxs = obj.w * obj.scaleX * obj.collScale
	hys = obj.h * obj.scaleY * obj.collScale
	l =  obj.xPos + obj.handleOffX - (wxs/2.0)
	r =  l + wxs
	t =  obj.yPos + obj.handleOffY - (hys/2.0)
	b += t + hys
	If px < l Or px > r Or py < t Or py > b Then Return False
	Return True
End
'-----------------------------------------------------------------------------
Function ftColl_PointToPointDist:Float( x1:Float, y1:Float, x2:Float, y2:Float )
	Local dx:Float
	Local dy:Float
	
	dx = x1 - x2
	dy = y1 - y2
    Return Sqrt((dx*dx) + (dy*dy))
End	

'-----------------------------------------------------------------------------
Function ftColl_PointToPointDist_Square:Float( x1:Float, y1:Float, x2:Float, y2:Float )
	Local dx:Float
	Local dy:Float
	
	dx = x1 - x2
	dy = y1 - y2
	Return (dx*dx) + (dy*dy)
End	

'-----------------------------------------------------------------------------
Function ftColl_Vec2DotProduct:Float(v1:ftVec2Dp, v2:ftVec2Dp)
	Return (v1.x*v2.x + v1.y*v2.y)
End



#rem
footer:This fantomX framework is released under the MIT license:
[quote]Copyright (c) 2011-2016 Michael Hartlef

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the software, and to permit persons to whom the software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
[/quote]
#end	