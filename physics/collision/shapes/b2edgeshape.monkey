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
'* An edge shape.
'* @
'* @see b2EdgeChainDef
'*/
#end
Class b2EdgeShape Extends b2Shape
    #rem
    '/**
    '* Returns False. Edges cannot contain points.
    '*/
    #end
    Method TestPoint : Bool (transform:b2Transform, p:b2Vec2)
        
        Return False
    End
    #rem
    '/**
    '* @inheritDoc
    '*/
    #end
    Method RayCast : Bool (output:b2RayCastOutput, input:b2RayCastInput, transform:b2Transform)
        
        Local tMat :b2Mat22
        Local rX :Float = input.p2.x - input.p1.x
        Local rY :Float = input.p2.y - input.p1.y
        '//b2Vec2 v1 = b2Mul(transform, m_v1)
        tMat = transform.R
        Local v1X :Float = transform.position.x + (tMat.col1.x * m_v1.x + tMat.col2.x * m_v1.y)
        Local v1Y :Float = transform.position.y + (tMat.col1.y * m_v1.x + tMat.col2.y * m_v1.y)
        '//b2Vec2 n = b2Cross(d, 1.0)
        Local nX :Float = transform.position.y + (tMat.col1.y * m_v2.x + tMat.col2.y * m_v2.y) - v1Y
        Local nY :Float = -(transform.position.x + (tMat.col1.x * m_v2.x + tMat.col2.x * m_v2.y) - v1X)
        Local k_slop :Float = 100.0 * Constants.EPSILON
        Local denom :Float = -(rX * nX + rY * nY)
        '// Cull back facing collision and ignore parallel segments.
        If (denom > k_slop)
            
            '// Does the segment intersect the infinite line associated with this segment?
            Local bX :Float = input.p1.x - v1X
            Local bY :Float = input.p1.y - v1Y
            Local a :Float = (bX * nX + bY * nY)
            If (0.0 <= a And a <= input.maxFraction * denom)
                
                Local mu2 :Float = -rX * bY + rY * bX
                '// Does the segment intersect this segment?
                If (-k_slop * denom <= mu2 And mu2 <= denom * (1.0 + k_slop))
                    
                    a /= denom
                    output.fraction = a
                    Local nLen :Float = Sqrt(nX * nX + nY * nY)
                    output.normal.x = nX / nLen
                    output.normal.y = nY / nLen
                    Return True
                End
            End
        End
        Return False
    End
    #rem
    '/**
    '* @inheritDoc
    '*/
    #end
    Method ComputeAABB : void (aabb:b2AABB, transform:b2Transform)
        
        Local tMat :b2Mat22 = transform.R
        '//b2Vec2 v1 = b2Mul(transform, m_v1)
        Local v1X :Float = transform.position.x + (tMat.col1.x * m_v1.x + tMat.col2.x * m_v1.y)
        Local v1Y :Float = transform.position.y + (tMat.col1.y * m_v1.x + tMat.col2.y * m_v1.y)
        '//b2Vec2 v2 = b2Mul(transform, m_v2)
        Local v2X :Float = transform.position.x + (tMat.col1.x * m_v2.x + tMat.col2.x * m_v2.y)
        Local v2Y :Float = transform.position.y + (tMat.col1.y * m_v2.x + tMat.col2.y * m_v2.y)
        If (v1X < v2X)
            
            aabb.lowerBound.x = v1X
            aabb.upperBound.x = v2X
        Else
            
            aabb.lowerBound.x = v2X
            aabb.upperBound.x = v1X
        End
        
        If (v1Y < v2Y)
            
            aabb.lowerBound.y = v1Y
            aabb.upperBound.y = v2Y
        Else
            
            aabb.lowerBound.y = v2Y
            aabb.upperBound.y = v1Y
        End
    End
    #rem
    '/**
    '* @inheritDoc
    '*/
    #end
    Method ComputeMass : void (massData:b2MassData, density:Float)
        
        massData.mass = 0
        massData.center.SetV(m_v1)
        massData.I = 0
    End
    #rem
    '/**
    '* @inheritDoc
    '*/
    #end
    Global sharedV0:b2Vec2 = New b2Vec2()
    Global sharedV1:b2Vec2 = New b2Vec2()
    Global sharedV2:b2Vec2 = New b2Vec2()
    
    Method ComputeSubmergedArea : Float (
        normal:b2Vec2,
        offset:Float,
        xf:b2Transform,
        c:b2Vec2)
        
        '// Note that independant(v0) of any details of the specific edge
        '// We are relying on v0 being consistent between multiple edges of the same body
        '//b2Vec2 v0 = offset * normal
        Local v0 :b2Vec2 = sharedV0
        v0.x = normal.x * offset
        v0.y = normal.y * offset
        Local v1 :b2Vec2 = sharedV1
        b2Math.MulX(xf, m_v1, v1)
        Local v2 :b2Vec2 = sharedV2
        b2Math.MulX(xf, m_v2, v1)
        Local d1 :Float = b2Math.Dot(normal, v1) - offset
        Local d2 :Float = b2Math.Dot(normal, v2) - offset
        If (d1 > 0)
            
            If (d2 > 0)
                
                Return 0
            Else
                
                '//v1 = -d2 / (d1 - d2) * v1 + d1 / (d1 - d2) * v2
                v1.x = -d2 / (d1 - d2) * v1.x + d1 / (d1 - d2) * v2.x
                v1.y = -d2 / (d1 - d2) * v1.y + d1 / (d1 - d2) * v2.y
            End
            
        Else
            
            If (d2 > 0)
                
                '//v2 = -d2 / (d1 - d2) * v1 + d1 / (d1 - d2) * v2
                v2.x = -d2 / (d1 - d2) * v1.x + d1 / (d1 - d2) * v2.x
                v2.y = -d2 / (d1 - d2) * v1.y + d1 / (d1 - d2) * v2.y
            Else
                
                '// Nothing
            End
        End
        
        '// v0,v1,v2 represents a fully submerged triangle
        '// Area weighted centroid
        c.x = (v0.x + v1.x + v2.x) / 3
        c.y = (v0.y + v1.y + v2.y) / 3
        '//b2Vec2 e1 = v1 - v0
        '//b2Vec2 e2 = v2 - v0
        '//return 0.5f * b2Cross(e1, e2)
        Return 0.5 * ( (v1.x - v0.x) * (v2.y - v0.y) - (v1.y - v0.y) * (v2.x - v0.x) )
    End
    #rem
    '/**
    '* Get the distance from vertex1 to vertex2.0
    '*/
    #end
    Method GetLength : Float ()
        
        Return m_length
    End
    #rem
    '/**
    '* Get the local position of vertex1 in parent body.
    '*/
    #end
    Method GetVertex1 : b2Vec2 ()
        
        Return m_v1
    End
    #rem
    '/**
    '* Get the local position of vertex2 in parent body.
    '*/
    #end
    Method GetVertex2 : b2Vec2 ()
        
        Return m_v2
    End
    #rem
    '/**
    '* Get a core vertex in local coordinates. These vertices
    '* represent a smaller edge used(that) for time of impact
    '* computations.
    '*/
    #end
    Method GetCoreVertex1 : b2Vec2 ()
        
        Return m_coreV1
    End
    #rem
    '/**
    '* Get a core vertex in local coordinates. These vertices
    '* represent a smaller edge used(that) for time of impact
    '* computations.
    '*/
    #end
    Method GetCoreVertex2 : b2Vec2 ()
        
        Return m_coreV2
    End
    #rem
    '/**
    '* Get a perpendicular unit vector, pointing
    '* from the solid side to the empty side.
    '*/
    #end
    Method GetNormalVector : b2Vec2 ()
        
        Return m_normal
    End
    #rem
    '/**
    '* Get a parallel unit vector, pointing
    '* from vertex1 to vertex2.0
    '*/
    #end
    Method GetDirectionVector : b2Vec2 ()
        
        Return m_direction
    End
    #rem
    '/**
    '* Returns a unit vector halfway between
    '* m_direction and m_prevEdge.m_direction.
    '*/
    #end
    Method GetCorner1Vector : b2Vec2 ()
        
        Return m_cornerDir1
    End
    #rem
    '/**
    '* Returns a unit vector halfway between
    '* m_direction and m_nextEdge.m_direction.
    '*/
    #end
    Method GetCorner2Vector : b2Vec2 ()
        
        Return m_cornerDir2
    End
    #rem
    '/**
    '* Returns True if the first corner of this edge
    '* bends towards the solid side.
    '*/
    #end
    Method Corner1IsConvex : Bool ()
        
        Return m_cornerConvex1
    End
    #rem
    '/**
    '* Returns True if the second corner of this edge
    '* bends towards the solid side.
    '*/
    #end
    Method Corner2IsConvex : Bool ()
        
        Return m_cornerConvex2
    End
    #rem
    '/**
    '* Get the first vertex and apply the supplied transform.
    '*/
    #end
    Method GetFirstVertex : b2Vec2 (xf: b2Transform)
        
        '//return b2Mul(xf, m_coreV1)
        Local tMat :b2Mat22 = xf.R
        Return New b2Vec2(xf.position.x + (tMat.col1.x * m_coreV1.x + tMat.col2.x * m_coreV1.y),
        xf.position.y + (tMat.col1.y * m_coreV1.x + tMat.col2.y * m_coreV1.y))
    End
    #rem
    '/**
    '* Get the nextItem edge in the chain.
    '*/
    #end
    Method GetNextEdge : b2EdgeShape ()
        
        Return m_nextEdge
    End
    #rem
    '/**
    '* Get the previous edge in the chain.
    '*/
    #end
    Method GetPrevEdge : b2EdgeShape ()
        
        Return m_prevEdge
    End
    Field s_supportVec:b2Vec2 = New b2Vec2()
    #rem
    '/**
    '* Get the support point in the given world direction.
    '* Use the supplied transform.
    '*/
    #end
    Method Support : b2Vec2 (xf:b2Transform, dX:Float, dY:Float)
        
        Local tMat :b2Mat22 = xf.R
        '//b2Vec2 v1 = b2Mul(xf, m_coreV1)
        Local v1X :Float = xf.position.x + (tMat.col1.x * m_coreV1.x + tMat.col2.x * m_coreV1.y)
        Local v1Y :Float = xf.position.y + (tMat.col1.y * m_coreV1.x + tMat.col2.y * m_coreV1.y)
        '//b2Vec2 v2 = b2Mul(xf, m_coreV2)
        Local v2X :Float = xf.position.x + (tMat.col1.x * m_coreV2.x + tMat.col2.x * m_coreV2.y)
        Local v2Y :Float = xf.position.y + (tMat.col1.y * m_coreV2.x + tMat.col2.y * m_coreV2.y)
        If ((v1X * dX + v1Y * dY) > (v2X * dX + v2Y * dY))
            
            s_supportVec.x = v1X
            s_supportVec.y = v1Y
        Else
            
            s_supportVec.x = v2X
            s_supportVec.y = v2Y
        End
        
        Return s_supportVec
    End
    
    Method Copy : b2Shape ()
        Local s :b2EdgeShape = New b2EdgeShape(Self.m_v1.Copy(),Self.m_v2.Copy())
        Return s
    End

    
    '//--------------- Internals Below -------------------
    #rem
    '/**
    '* @
    '*/
    #end
    Method New(v1: b2Vec2, v2: b2Vec2)
        
        Super.New()
        m_type = e_edgeShape
        m_prevEdge = null
        m_nextEdge = null
        m_v1 = v1
        m_v2 = v2
        m_direction.Set(m_v2.x - m_v1.x, m_v2.y - m_v1.y)
        m_length = m_direction.Normalize()
        m_normal.Set(m_direction.y, -m_direction.x)
        m_coreV1.Set(-b2Settings.b2_toiSlop * (m_normal.x - m_direction.x) + m_v1.x,
        -b2Settings.b2_toiSlop * (m_normal.y - m_direction.y) + m_v1.y)
        m_coreV2.Set(-b2Settings.b2_toiSlop * (m_normal.x + m_direction.x) + m_v2.x,
        -b2Settings.b2_toiSlop * (m_normal.y + m_direction.y) + m_v2.y)
        m_cornerDir1 = m_normal
        m_cornerDir2.Set(-m_normal.x, -m_normal.y)
    End
    #rem
    '/**
    '* @
    '*/
    #end
    Method SetPrevEdge : void (edge: b2EdgeShape, core: b2Vec2, cornerDir: b2Vec2, convex: Bool)
        
        m_prevEdge = edge
        m_coreV1 = core
        m_cornerDir1 = cornerDir
        m_cornerConvex1 = convex
    End
    #rem
    '/**
    '* @
    '*/
    #end
    Method SetNextEdge : void (edge: b2EdgeShape, core: b2Vec2, cornerDir: b2Vec2, convex: Bool)
        
        m_nextEdge = edge
        m_coreV2 = core
        m_cornerDir2 = cornerDir
        m_cornerConvex2 = convex
    End
    
    Field m_v1:b2Vec2 = New b2Vec2()
    
    Field m_v2:b2Vec2 = New b2Vec2()
    
    Field m_coreV1:b2Vec2 = New b2Vec2()
    
    Field m_coreV2:b2Vec2 = New b2Vec2()
    
    Field m_length:Float
    
    Field m_normal:b2Vec2 = New b2Vec2()
    
    Field m_direction:b2Vec2 = New b2Vec2()
    
    Field m_cornerDir1:b2Vec2 = New b2Vec2()
    
    Field m_cornerDir2:b2Vec2 = New b2Vec2()
    
    Field m_cornerConvex1:Bool
    
    Field m_cornerConvex2:Bool
    
    Field m_nextEdge:b2EdgeShape
    
    Field m_prevEdge:b2EdgeShape
End
