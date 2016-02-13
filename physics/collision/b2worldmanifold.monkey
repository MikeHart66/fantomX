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


#rem
'/**
'* used(This) to compute the current state of a contact manifold.
'*/
#end
Class b2WorldManifold
    
    Method New()
        
        m_points = New b2Vec2[b2Settings.b2_maxManifoldPoints]
        For Local i:Int = 0 Until b2Settings.b2_maxManifoldPoints
            m_points[i] = New b2Vec2()
        End
    End
    #rem
    '/**
    '* Evaluate the manifold with supplied transforms. This assumes
    '* modest motion from the original state. This does not change the
    '* point count, impulses, etc. The radii must come from the shapes
    '* that generated the manifold.
    '*/
    #end
    Method Initialize : void (manifold:b2Manifold,
        xfA:b2Transform, radiusA:Float,
        xfB:b2Transform, radiusB:Float)
        
        If (manifold.m_pointCount = 0)
            Return
        End
        
        Local i :Int
        Local tVec :b2Vec2
        Local tMat :b2Mat22
        Local normalX :Float
        Local normalY :Float
        Local planePointX :Float
        Local planePointY :Float
        Local clipPointX :Float
        Local clipPointY :Float
        
        Select(manifold.m_type)
            
            Case b2Manifold.e_circles
                
                '//var pointA:b2Vec2 = b2Math.b2MulX(xfA, manifold.m_localPoint)
                tMat = xfA.R
                tVec = manifold.m_localPoint
                Local pointAX :Float = xfA.position.x + tMat.col1.x * tVec.x + tMat.col2.x * tVec.y
                Local pointAY :Float = xfA.position.y + tMat.col1.y * tVec.x + tMat.col2.y * tVec.y
                '//var pointB:b2Vec2 = b2Math.b2MulX(xfB, manifold.m_points.Get(0).m_localPoint)
                tMat = xfB.R
                tVec = manifold.m_points[0].m_localPoint
                Local pointBX :Float = xfB.position.x + tMat.col1.x * tVec.x + tMat.col2.x * tVec.y
                Local pointBY :Float = xfB.position.y + tMat.col1.y * tVec.x + tMat.col2.y * tVec.y
                Local dX :Float = pointBX - pointAX
                Local dY :Float = pointBY - pointAY
                Local d2 :Float = dX * dX + dY * dY
                If (d2 > Constants.EPSILON * Constants.EPSILON)
                    Local d :Float = Sqrt(d2)
                    m_normal.x = dX/d
                    m_normal.y = dY/d
                Else
                    m_normal.x = 1
                    m_normal.y = 0
                End
                
                '//b2Vec2 cA = pointA + radiusA * m_normal
                Local cAX :Float = pointAX + radiusA * m_normal.x
                Local cAY :Float = pointAY + radiusA * m_normal.y
                '//b2Vec2 cB = pointB - radiusB * m_normal
                Local cBX :Float = pointBX - radiusB * m_normal.x
                Local cBY :Float = pointBY - radiusB * m_normal.y
                m_points[0].x = 0.5 * (cAX + cBX)
                m_points[0].y = 0.5 * (cAY + cBY)
                
            Case b2Manifold.e_faceA
                
                '//normal = b2Math.b2MulMV(xfA.R, manifold.m_localPlaneNormal)
                tMat = xfA.R
                tVec = manifold.m_localPlaneNormal
                normalX = tMat.col1.x * tVec.x + tMat.col2.x * tVec.y
                normalY = tMat.col1.y * tVec.x + tMat.col2.y * tVec.y
                '//planePoint = b2Math.b2MulX(xfA, manifold.m_localPoint)
                tMat = xfA.R
                tVec = manifold.m_localPoint
                planePointX = xfA.position.x + tMat.col1.x * tVec.x + tMat.col2.x * tVec.y
                planePointY = xfA.position.y + tMat.col1.y * tVec.x + tMat.col2.y * tVec.y
                '// Ensure normal points from A to B
                m_normal.x = normalX
                m_normal.y = normalY
                For Local i:Int = 0 Until manifold.m_pointCount
                    
                    '//clipPoint = b2Math.b2MulX(xfB, manifold.m_points.Get(i).m_localPoint)
                    tMat = xfB.R
                    tVec = manifold.m_points[i].m_localPoint
                    clipPointX = xfB.position.x + tMat.col1.x * tVec.x + tMat.col2.x * tVec.y
                    clipPointY = xfB.position.y + tMat.col1.y * tVec.x + tMat.col2.y * tVec.y
                    '//b2Vec2 cA = clipPoint + (radiusA - b2Dot(clipPoint - planePoint, normal)) * normal
                    '//b2Vec2 cB = clipPoint - radiusB * normal
                    '//m_points.Set( i,  0.5f * (cA + cB) )
                    m_points[i].x = clipPointX + 0.5 * (radiusA - (clipPointX - planePointX) * normalX - (clipPointY - planePointY) * normalY - radiusB ) * normalX
                    m_points[i].y = clipPointY + 0.5 * (radiusA - (clipPointX - planePointX) * normalX - (clipPointY - planePointY) * normalY - radiusB ) * normalY
                End
            Case b2Manifold.e_faceB
                
                '//normal = b2Math.b2MulMV(xfB.R, manifold.m_localPlaneNormal)
                tMat = xfB.R
                tVec = manifold.m_localPlaneNormal
                normalX = tMat.col1.x * tVec.x + tMat.col2.x * tVec.y
                normalY = tMat.col1.y * tVec.x + tMat.col2.y * tVec.y
                '//planePoint = b2Math.b2MulX(xfB, manifold.m_localPoint)
                tMat = xfB.R
                tVec = manifold.m_localPoint
                planePointX = xfB.position.x + tMat.col1.x * tVec.x + tMat.col2.x * tVec.y
                planePointY = xfB.position.y + tMat.col1.y * tVec.x + tMat.col2.y * tVec.y
                '// Ensure normal points from A to B
                m_normal.x = -normalX
                m_normal.y = -normalY
                For Local i:Int = 0 Until manifold.m_pointCount
                    
                    '//clipPoint = b2Math.b2MulX(xfA, manifold.m_points.Get(i).m_localPoint)
                    tMat = xfA.R
                    tVec = manifold.m_points[i].m_localPoint
                    clipPointX = xfA.position.x + tMat.col1.x * tVec.x + tMat.col2.x * tVec.y
                    clipPointY = xfA.position.y + tMat.col1.y * tVec.x + tMat.col2.y * tVec.y
                    '//b2Vec2 cA = clipPoint - radiusA * normal
                    '//b2Vec2 cB = clipPoint + (radiusB - b2Dot(clipPoint - planePoint, normal)) * normal
                    '//m_points.Set( i,  0.5f * (cA + cB) )
                    m_points[i].x = clipPointX + 0.5 * (radiusB - (clipPointX - planePointX) * normalX - (clipPointY - planePointY) * normalY - radiusA ) * normalX
                    m_points[i].y = clipPointY + 0.5 * (radiusB - (clipPointX - planePointX) * normalX - (clipPointY - planePointY) * normalY - radiusA ) * normalY
                End
            End
        End
        #rem
        '/**
        '* world vector pointing from A to B
        '*/
        #end
        Field m_normal:b2Vec2 = New b2Vec2()
        
        #rem
        '/**
        '* world contact point (point of intersection)
        '*/
        #end
        Field m_points:b2Vec2[]
        
    End
    
