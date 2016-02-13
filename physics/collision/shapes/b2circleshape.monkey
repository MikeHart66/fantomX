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
'* A circle shape.
'* @see b2CircleDef
'*/
#end
Class b2CircleShape Extends b2Shape
    
    Method Copy : b2Shape ()
        Local s :b2Shape = New b2CircleShape(Self.m_radius)
        s.Set(Self)
        Return s
    End
    
    Method Set : void (other:b2Shape)
        Super.Set(other)
        If b2CircleShape((other))
            Local other2 :b2CircleShape = b2CircleShape(other)
            m_p.SetV(other2.m_p)
        End
    End
    #rem
    '/**
    '* @inheritDoc
    '*/
    #end
    Method TestPoint : Bool (transform:b2Transform, p:b2Vec2)
        
        '//b2Vec2 center = transform.position + b2Mul(transform.R, m_p)
        Local tMat :b2Mat22 = transform.R
        Local dX :Float = transform.position.x + (tMat.col1.x * m_p.x + tMat.col2.x * m_p.y)
        Local dY :Float = transform.position.y + (tMat.col1.y * m_p.x + tMat.col2.y * m_p.y)
        '//b2Vec2 d = p - center
        dX = p.x - dX
        dY = p.y - dY
        '//return b2Dot(d, d) <= m_radius * m_radius
        Return (dX*dX + dY*dY) <= m_radius * m_radius
    End
    #rem
    '/**
    '* @inheritDoc
    '*/
    #end
    Method RayCast : Bool (output:b2RayCastOutput, input:b2RayCastInput, transform:b2Transform)
        
        '//b2Vec2 position = transform.position + b2Mul(transform.R, m_p)
        Local tMat :b2Mat22 = transform.R
        Local positionX :Float = transform.position.x + (tMat.col1.x * m_p.x + tMat.col2.x * m_p.y)
        Local positionY :Float = transform.position.y + (tMat.col1.y * m_p.x + tMat.col2.y * m_p.y)
        '//b2Vec2 s = input.p1 - position
        Local sX :Float = input.p1.x - positionX
        Local sY :Float = input.p1.y - positionY
        '//float32 b = b2Dot(s, s) - m_radius * m_radius
        Local b :Float = (sX*sX + sY*sY) - m_radius * m_radius
        #rem
        '/*// Does the segment start inside the circle?
        'if (b < 0.0)
        '
        'output.fraction = 0
        'output.hit = e_startsInsideCollide
        'return
        'End
        '*/
        '
        '
        #end
        '// Solve quadratic equation.
        '//b2Vec2 r = input.p2 - input.p1
        Local rX :Float = input.p2.x - input.p1.x
        Local rY :Float = input.p2.y - input.p1.y
        '//float32 c =  b2Dot(s, r)
        Local c :Float =  (sX*rX + sY*rY)
        '//float32 rr = b2Dot(r, r)
        Local rr :Float = (rX*rX + rY*rY)
        Local sigma :Float = c * c - rr * b
        '// Check for negative discriminant and short segment.
        If (sigma < 0.0 Or rr < Constants.EPSILON)
            
            Return False
        End
        '// Find the point of intersection of the line with the circle.
        Local a :Float = -(c + Sqrt(sigma))
        '// Is the intersection point on the segment?
        If (0.0 <= a And a <= input.maxFraction * rr)
            
            a /= rr
            output.fraction = a
            '// manual  of: output.normal = s + a * r
            output.normal.x = sX + a * rX
            output.normal.y = sY + a * rY
            output.normal.Normalize()
            Return True
        End
        Return False
    End
    #rem
    '/**
    '* @inheritDoc
    '*/
    #end
    Method ComputeAABB : void (aabb:b2AABB, transform:b2Transform)
        
        '//b2Vec2 p = transform.position + b2Mul(transform.R, m_p)
        Local tMat :b2Mat22 = transform.R
        Local pX :Float = transform.position.x + (tMat.col1.x * m_p.x + tMat.col2.x * m_p.y)
        Local pY :Float = transform.position.y + (tMat.col1.y * m_p.x + tMat.col2.y * m_p.y)
        aabb.lowerBound.Set(pX - m_radius, pY - m_radius)
        aabb.upperBound.Set(pX + m_radius, pY + m_radius)
    End
    #rem
    '/**
    '* @inheritDoc
    '*/
    #end
    Method ComputeMass : void (massData:b2MassData, density:Float)
        
        massData.mass = density * b2Settings.b2_pi * m_radius * m_radius
        massData.center.SetV(m_p)
        '// inertia about the local origin
        '//massData.I = massData.mass * (0.5 * m_radius * m_radius + b2Dot(m_p, m_p))
        massData.I = massData.mass * (0.5 * m_radius * m_radius + (m_p.x*m_p.x + m_p.y*m_p.y))
    End
    #rem
    '/**
    '* @inheritDoc
    '*/
    #end
    Global sharedP:b2Vec2 = New b2Vec2()
    
    Method ComputeSubmergedArea:Float( normal:b2Vec2, offset:Float, xf:b2Transform, c:b2Vec2)
        Local p :b2Vec2 = sharedP
        b2Math.MulX(xf, m_p, p)
        Local l :Float = -(b2Math.Dot(normal, p) - offset)
        If (l < -m_radius + Constants.EPSILON)
            
            '//Completely dry
            Return 0
        End
        
        If (l > m_radius)
            
            '//Completely wet
            c.SetV(p)
            Return Constants.PI * m_radius * m_radius
        End
        '//Magic
        Local r2 :Float = m_radius * m_radius
        Local l2 :Float = l * l
        Local area :Float = r2 *( ASinr(l / m_radius) + Constants.PI / 2) + l * Sqrt( r2 - l2 )
        Local com :Float = -2 / 3 * Pow(r2 - l2, 1.5) / area
        c.x = p.x + normal.x * com
        c.y = p.y + normal.y * com
        Return area
    End
    #rem
    '/**
    '* Get the local position of this circle in its parent body.
    '*/
    #end
    Method GetLocalPosition : b2Vec2 ()
        
        Return m_p
    End
    #rem
    '/**
    '* Set the local position of this circle in its parent body.
    '*/
    #end
    Method SetLocalPosition : void (position:b2Vec2)
        
        m_p.SetV(position)
    End
    #rem
    '/**
    '* Get the radius of the circle
    '*/
    #end
    Method GetRadius : Float ()
        
        Return m_radius
    End
    #rem
    '/**
    '* Set the radius of the circle
    '*/
    #end
    Method SetRadius : void (radius:Float)
        
        m_radius = radius
    End
    
    Method New(radius:Float = 0.0)
        Super.New()
        m_type = e_circleShape
        m_radius = radius
    End
    '// Local position in parent body
    Field m_p:b2Vec2 = New b2Vec2()
    
End

