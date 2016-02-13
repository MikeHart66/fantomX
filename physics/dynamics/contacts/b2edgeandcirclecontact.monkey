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
'* @
'*/
#end
Class EdgeAndCircleContactTypeFactory Extends ContactTypeFactory
    Method Create : b2Contact (allocator: Object)
        
        Return New b2EdgeAndCircleContact()
    End
    
    Method Destroy : void (contact:b2Contact, allocator: Object)
        
        '//
    End
End
Class b2EdgeAndCircleContact Extends b2Contact
    
    
    Method New()
        Super.New()
    End
    
    Method Reset : void (fixtureA:b2Fixture, fixtureB:b2Fixture)
        
        Super.Reset(fixtureA, fixtureB)
        '//b2Settings.B2Assert(m_shape1.m_type = b2Shape.e_circleShape)
        '//b2Settings.B2Assert(m_shape2.m_type = b2Shape.e_circleShape)
    End
    
    '//~b2EdgeAndCircleContact() {}
    Method Evaluate : void ()
        
        Local bA :b2Body = m_fixtureA.GetBody()
        Local bB :b2Body = m_fixtureB.GetBody()
        B2CollideEdgeAndCircle(m_manifold,
        b2EdgeShape(m_fixtureA.GetShape()), bA.m_xf,
        b2CircleShape(m_fixtureB.GetShape()), bB.m_xf)
    End
    Method B2CollideEdgeAndCircle : void (manifold: b2Manifold,
        edge: b2EdgeShape,
        xf1: b2Transform,
        circle: b2CircleShape,
        xf2: b2Transform)
        
        '//TODO_BORIS
        #rem
        '/*
        'manifold.m_pointCount = 0
        'Local tMat : b2Mat22
        'Local tVec : b2Vec2
        'Local dX :Float
        'Local dY :Float
        'Local tX :Float
        'Local tY :Float
        'Local tPoint :b2ManifoldPoint
        '//b2Vec2 c = b2Mul(xf2, circle->GetLocalPosition())
        'tMat = xf2.R
        'tVec = circle.m_r
        'Local cX :Float = xf2.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y)
        'Local cY :Float = xf2.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y)
        '//b2Vec2 cLocal = b2MulT(xf1, c)
        'tMat = xf1.R
        'tX = cX - xf1.position.x
        'tY = cY - xf1.position.y
        'Local cLocalX :Float = (tX * tMat.col1.x + tY * tMat.col1.y )
        'Local cLocalY :Float = (tX * tMat.col2.x + tY * tMat.col2.y )
        'Local n : b2Vec2 = edge.m_normal
        'Local v1 : b2Vec2 = edge.m_v1
        'Local v2 : b2Vec2 = edge.m_v2
        'Local radius :Float = circle.m_radius
        'Local separation :Float
        'Local dirDist :Float = (cLocalX - v1.x) * edge.m_direction.x +
        '(cLocalY - v1.y) * edge.m_direction.y
        'Local normalCalculated : Bool = False
        'if (dirDist <= 0)
        '
        'dX = cLocalX - v1.x
        'dY = cLocalY - v1.y
        'if (dX * edge.m_cornerDir1.x + dY * edge.m_cornerDir1.y < 0)
        '
        'return
        'End
        '
        'dX = cX - (xf1.position.x + (tMat.col1.x * v1.x + tMat.col2.x * v1.y))
        'dY = cY - (xf1.position.y + (tMat.col1.y * v1.x + tMat.col2.y * v1.y))
        'Else  if (dirDist >= edge.m_length)
        '
        '
        'dX = cLocalX - v2.x
        'dY = cLocalY - v2.y
        'if (dX * edge.m_cornerDir2.x + dY * edge.m_cornerDir2.y > 0)
        '
        'return
        'End
        '
        'dX = cX - (xf1.position.x + (tMat.col1.x * v2.x + tMat.col2.x * v2.y))
        'dY = cY - (xf1.position.y + (tMat.col1.y * v2.x + tMat.col2.y * v2.y))
        'Else
        '
        '
        'separation = (cLocalX - v1.x) * n.x + (cLocalY - v1.y) * n.y
        'if (separation > radius Or separation < -radius)
        '
        'return
        'End
        '
        'separation -= radius
        '//manifold.normal = b2Mul(xf1.R, n)
        'tMat = xf1.R
        'manifold.normal.x = (tMat.col1.x * n.x + tMat.col2.x * n.y)
        'manifold.normal.y = (tMat.col1.y * n.x + tMat.col2.y * n.y)
        'normalCalculated = True
        'End
        'if (Not(normalCalculated))
        '
        'Local distSqr :Float = dX * dX + dY * dY
        'if (distSqr > radius * radius)
        '
        'return
        'End
        'if (distSqr < Constants.EPSILON)
        '
        'separation = -radius
        'manifold.normal.x = (tMat.col1.x * n.x + tMat.col2.x * n.y)
        'manifold.normal.y = (tMat.col1.y * n.x + tMat.col2.y * n.y)
        'Else
        '
        '
        'distSqr = Sqrt(distSqr)
        'dX /= distSqr
        'dY /= distSqr
        'separation = distSqr - radius
        'manifold.normal.x = dX
        'manifold.normal.y = dY
        'End
        'End
        'tPoint = manifold.points.Get(0)
        'manifold.pointCount = 1
        'tPoint.id.key = 0
        'tPoint.separation = separation
        'cX = cX - radius * manifold.normal.x
        'cY = cY - radius * manifold.normal.y
        'tX = cX - xf1.position.x
        'tY = cY - xf1.position.y
        'tPoint.localPoint1.x = (tX * tMat.col1.x + tY * tMat.col1.y )
        'tPoint.localPoint1.y = (tX * tMat.col2.x + tY * tMat.col2.y )
        'tMat = xf2.R
        'tX = cX - xf2.position.x
        'tY = cY - xf2.position.y
        'tPoint.localPoint2.x = (tX * tMat.col1.x + tY * tMat.col1.y )
        'tPoint.localPoint2.y = (tX * tMat.col2.x + tY * tMat.col2.y )
        '*/
        #end
    End
End



