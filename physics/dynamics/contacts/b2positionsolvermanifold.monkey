Strict
#rem
'/*
'* Copyright (c) 2011, Damian Sinclair
'*
'* This is a port of Box2D by Erin Catto (box2d.org).
'* It is translated from the Flash port: Box2DFlash, by BorisTheBrave (http://www.box2dflash.org/).
'* Box2DFlash also credits Matt Bush and John Nesky as contributors.
'*
'* All rights reserved.
'* Redistribution and use in source and binary forms, with or without
'* modification, are permitted provided that the following conditions are met:
'*
'*   - Redistributions of source code must retain the above copyright
'*     notice, this list of conditions and the following disclaimer.
'*   - Redistributions in binary form must reproduce the above copyright
'*     notice, this list of conditions and the following disclaimer in the
'*     documentation and/or other materials provided with the distribution.
'*
'* THIS SOFTWARE IS PROVIDED BY THE MONKEYBOX2D PROJECT CONTRIBUTORS "AS IS" AND
'* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
'* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
'* DISCLAIMED. IN NO EVENT SHALL THE MONKEYBOX2D PROJECT CONTRIBUTORS BE LIABLE
'* FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
'* DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
'* SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
'* CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
'* LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
'* OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
'* DAMAGE.
'*/
#end
Import fantomX



Class b2PositionSolverManifold
    
    Global circlePointA:b2Vec2 = New b2Vec2()
    Global circlePointB:b2Vec2 = New b2Vec2()
    
    Field m_normal:b2Vec2
    Field m_points:b2Vec2[]
    Field m_separations:Float[]
    
    Method New()
        m_normal = New b2Vec2()
        m_separations = New Float[b2Settings.b2_maxManifoldPoints]
        m_points = New b2Vec2[b2Settings.b2_maxManifoldPoints]
        For Local i:Int = 0 Until m_points.Length
            m_points[i] = New b2Vec2()
        End
    End
    
    Method Initialize : void (cc:b2ContactConstraint)
        
#If CONFIG = "debug"
        b2Settings.B2Assert(cc.pointCount > 0)
#End
        Local i :Int
        Local pointCount:Int = cc.pointCount
        Local clipPointX :Float
        Local clipPointY :Float
        Local tTrans :b2Transform
        Local tMat :b2Mat22
        Local tVec :b2Vec2
        Local tmpPos:b2Vec2
        Local planePointX :Float
        Local planePointY :Float
        
        Select(cc.type)
            
            Case b2Manifold.e_circles
                '//var pointA:b2Vec2 = cc.bodyA.GetWorldPoint(cc.localPoint)
                tTrans = cc.bodyA.m_xf
                tMat = tTrans.R
                tVec = cc.localPoint
                tmpPos = tTrans.position
                
                Local pointAX :Float = tmpPos.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y)
                Local pointAY :Float = tmpPos.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y)
                
                '//var pointB:b2Vec2 = cc.bodyB.GetWorldPoint(cc.points.Get(0).localPoint)
                tTrans = cc.bodyB.m_xf
                tMat = tTrans.R
                tVec = cc.points[0].localPoint
                tmpPos = tTrans.position
                
                Local pointBX :Float = tmpPos.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y)
                Local pointBY :Float = tmpPos.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y)
                Local dX :Float = pointBX - pointAX
                Local dY :Float = pointBY - pointAY
                Local d2 :Float = dX * dX + dY * dY
        
                If (d2 > Constants.EPSILON*Constants.EPSILON)
                    Local d :Float = Sqrt(d2)
                    m_normal.x = dX/d
                    m_normal.y = dY/d
                Else
                    m_normal.x = 1.0
                    m_normal.y = 0.0
                End
                
                m_points[0].x = 0.5 * (pointAX + pointBX)
                m_points[0].y = 0.5 * (pointAY + pointBY)
                m_separations[0] =  dX * m_normal.x + dY * m_normal.y - cc.radius
                
            Case b2Manifold.e_faceA
                
                '//m_normal = cc.bodyA.GetWorldVector(cc.localPlaneNormal)
                tTrans = cc.bodyA.m_xf
                tMat = tTrans.R
                tVec = cc.localPlaneNormal
                tmpPos = tTrans.position
                Local tMatCol1:b2Vec2 = tMat.col1
                Local tMatCol2:b2Vec2 = tMat.col2
                Local mc1X:Float = tMatCol1.x
                Local mc1Y:Float = tMatCol1.y
                Local mc2X:Float = tMatCol2.x
                Local mc2Y:Float = tMatCol2.y
                
                m_normal.x = mc1X * tVec.x + mc2X * tVec.y
                m_normal.y = mc1Y * tVec.x + mc2Y * tVec.y
                '//planePoint = cc.bodyA.GetWorldPoint(cc.localPoint)
                
                tVec = cc.localPoint
                
                planePointX = tmpPos.x + (mc1X * tVec.x + mc2X * tVec.y)
                planePointY = tmpPos.y + (mc1Y * tVec.x + mc2Y * tVec.y)
                
                tTrans = cc.bodyB.m_xf
                tMat = tTrans.R
                tmpPos = tTrans.position
                tMatCol1 = tMat.col1
                tMatCol2 = tMat.col2
                Local normX:Float = m_normal.x
                Local normY:Float = m_normal.y
                Local ccRad:Float = cc.radius
                mc1X = tMatCol1.x
                mc1Y = tMatCol1.y
                mc2X = tMatCol2.x
                mc2Y = tMatCol2.y
                Local tmpX:Float = tmpPos.x
                Local tmpY:Float = tmpPos.y
                
                For Local i:Int = 0 Until pointCount
                    '//clipPoint = cc.bodyB.GetWorldPoint(cc.points.Get(i).localPoint)
                    tVec = cc.points[i].localPoint
                    clipPointX = tmpX + (mc1X * tVec.x + mc2X * tVec.y)
                    clipPointY = tmpY + (mc1Y * tVec.x + mc2Y * tVec.y)
                    m_separations[i] = (clipPointX - planePointX) * normX + (clipPointY - planePointY) * normY - ccRad
                    m_points[i].x = clipPointX
                    m_points[i].y = clipPointY
                End
                
            Case b2Manifold.e_faceB
                
                '//m_normal = cc.bodyB.GetWorldVector(cc.localPlaneNormal)
                tTrans = cc.bodyB.m_xf
                tMat = tTrans.R
                tmpPos = tTrans.position
                tVec = cc.localPlaneNormal
                Local tMatCol1:b2Vec2 = tMat.col1
                Local tMatCol2:b2Vec2 = tMat.col2
                Local mc1X:Float = tMatCol1.x
                Local mc1Y:Float = tMatCol1.y
                Local mc2X:Float = tMatCol2.x
                Local mc2Y:Float = tMatCol2.y
                m_normal.x = mc1X * tVec.x + mc2X * tVec.y
                m_normal.y = mc1Y * tVec.x + mc2Y * tVec.y
                '//planePoint = cc.bodyB.GetWorldPoint(cc.localPoint)
                tVec = cc.localPoint
                planePointX = tmpPos.x + (mc1X * tVec.x + mc2X * tVec.y)
                planePointY = tmpPos.y + (mc1Y * tVec.x + mc2Y * tVec.y)
                
                tTrans = cc.bodyA.m_xf
                tMat = tTrans.R
                tmpPos = tTrans.position
                tMatCol1 = tMat.col1
                tMatCol2 = tMat.col2
                Local normX:Float = m_normal.x
                Local normY:Float = m_normal.y
                Local ccRad:Float = cc.radius
                mc1X = tMatCol1.x
                mc1Y = tMatCol1.y
                mc2X = tMatCol2.x
                mc2Y = tMatCol2.y
                Local tmpX:Float = tmpPos.x
                Local tmpY:Float = tmpPos.y
                
                For Local i:Int = 0 Until pointCount
                    '//clipPoint = cc.bodyA.GetWorldPoint(cc.points.Get(i).localPoint)
                    tVec = cc.points[i].localPoint
                    clipPointX = tmpX + (mc1X * tVec.x + mc2X * tVec.y)
                    clipPointY = tmpY + (mc1Y * tVec.x + mc2Y * tVec.y)
                    m_separations[i] = (clipPointX - planePointX) * normX + (clipPointY - planePointY) * normY - ccRad
                    m_points[i].x = clipPointX
                    m_points[i].y = clipPointY
                End
                '// Ensure normal points from A to B
                m_normal.x *= -1
                m_normal.y *= -1
            End
        End
    End
    
    
