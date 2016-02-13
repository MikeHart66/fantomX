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
'* Convex polygon. The vertices must be in CCW order for a right-handed
'* coordinate system with the z-axis coming out of the screen.
'* @see b2PolygonDef
'*/
#end
Class b2PolygonShape Extends b2Shape
    
'// Local position of the polygon centroid.
    Field m_centroid:b2Vec2        
    Field m_vertices:b2Vec2[]
    Field m_normals:b2Vec2[]
    Field m_depths:Float[]
    Field m_vertexCount:Int
        
    Method Copy : b2Shape ()
        Local s :b2PolygonShape = New b2PolygonShape()
        s.Set(Self)
        Return s
    End

    Method Set : void (other:b2Shape)
        Super.Set(other)

        If b2PolygonShape((other))
            Local other2 :b2PolygonShape = b2PolygonShape(other)
            m_centroid.SetV(other2.m_centroid)
            m_vertexCount = other2.m_vertexCount
            Reserve(m_vertexCount)

            For Local i:Int = 0 Until m_vertexCount
                m_vertices[i].SetV(other2.m_vertices[i])
                m_normals[i].SetV(other2.m_normals[i])
            End
        End
    End
    #rem
    '/**
    '* Copy vertices. This assumes the vertices define a convex polygon.
    '* assumed(It) that the the(exterior) the right of each edge.
    '*/
    #end
    Method SetAsArray : void (vertices:b2Vec2[], vertexCount:Float = 0)
        
        If (vertexCount = 0)
            vertexCount = vertices.Length
        End
        b2Settings.B2Assert(2 <= vertexCount)
        m_vertexCount = vertexCount
        Reserve(vertexCount)
        Local i :Int
        '// Copy vertices
        For Local i:Int = 0 Until m_vertexCount
            m_vertices[i].SetV(vertices[i])
        End
        
        '// Compute normals. Ensure the edges have non-zero length.
        For Local i:Int = 0 Until m_vertexCount
            Local i1 :Int = i
            Local i2 :Int =  0
            
            If( i + 1 < m_vertexCount  )
                i2 =  i + 1
            End
            
            Local edge:b2Vec2 = New b2Vec2()
            b2Math.SubtractVV(m_vertices[i2], m_vertices[i1],edge)
            b2Settings.B2Assert(edge.LengthSquared() > Constants.EPSILON )
            b2Math.CrossVF(edge, 1.0, m_normals[i])
            m_normals[i].Normalize()
        End
        
        '// Compute the polygon centroid
        m_centroid = ComputeCentroid(m_vertices, m_vertexCount)
    End
    
    Function AsArray : b2PolygonShape (vertices:b2Vec2[], vertexCount:Float)
        Local polygonShape :b2PolygonShape = New b2PolygonShape()
        polygonShape.SetAsArray(vertices, vertexCount)
        Return polygonShape
    End
    
'    #rem
'    '/**
'    '* Copy vertices. This assumes the vertices define a convex polygon.
'    '* assumed(It) that the the(exterior) the right of each edge.
'    '*/
'    #end
'    Method SetAsVector : void (vertices:FlashArray<b2Vec2>, vertexCount:Float = 0)
'        
'        If (vertexCount = 0)
'            vertexCount = vertices.Length
'        End
'        b2Settings.B2Assert(2 <= vertexCount)
'        m_vertexCount = vertexCount
'        Reserve(vertexCount)
'        Local i :Int
'        '// Copy vertices
'        For Local i:Int = 0 Until m_vertexCount
'            m_vertices[i].SetV(vertices.Get(i))
'        End
'        '// Compute normals. Ensure the edges have non-zero length.
'        For Local i:Int = 0 Until m_vertexCount
'            
'            Local i1 :Int = i
'            Local i2 :Int =  0
'            
'            If( i + 1 < m_vertexCount  )
'                i2 =  i + 1
'            End
'            
'            Local edge :b2Vec2 = b2Math.SubtractVV(m_vertices[i2], m_vertices[i1])
'            b2Settings.B2Assert(edge.LengthSquared() > Constants.EPSILON )
'            m_normals[i].SetV(b2Math.CrossVF(edge, 1.0))
'            m_normals[i].Normalize()
'        End
'        
'        '// Compute the polygon centroid
'        m_centroid = ComputeCentroid(m_vertices, m_vertexCount)
'    End
'    
'    Function AsVector : b2PolygonShape (vertices:FlashArray<b2Vec2>, vertexCount:Float)
'        Local polygonShape :b2PolygonShape = New b2PolygonShape()
'        polygonShape.SetAsVector(vertices, vertexCount)
'        Return polygonShape
'    End
'    
    #rem
    '/**
    '* Build vertices to represent an axis-aligned box.
    '* @param hx the half-width.
    '* @param hy the half-height.
    '*/
    #end
    Method SetAsBox : void (hx:Float, hy:Float)
        m_vertexCount = 4
        Reserve(4)
        m_vertices[0].Set(-hx, -hy)
        m_vertices[1].Set( hx, -hy)
        m_vertices[2].Set( hx,  hy)
        m_vertices[3].Set(-hx,  hy)
        m_normals[0].Set(0.0, -1.0)
        m_normals[1].Set(1.0, 0.0)
        m_normals[2].Set(0.0, 1.0)
        m_normals[3].Set(-1.0, 0.0)
        m_centroid.SetZero()
    End
    
    Function AsBox : b2PolygonShape (hx:Float, hy:Float)
        Local polygonShape :b2PolygonShape = New b2PolygonShape()
        polygonShape.SetAsBox(hx, hy)
        Return polygonShape
    End
    #rem
    '/**
    '* Build vertices to represent an oriented box.
    '* @param hx the half-width.
    '* @param hy the half-height.
    '* @param center the center of the box in local coordinates.
    '* @param angle the rotation of the box in local coordinates.
    '*/
    #end
    Global s_mat:b2Mat22 = New b2Mat22()
    Method SetAsOrientedBox : void (hx:Float, hy:Float, center:b2Vec2 = null, angle:Float = 0.0)
        
        m_vertexCount = 4
        Reserve(4)
        m_vertices[0].Set(-hx, -hy)
        m_vertices[1].Set( hx, -hy)
        m_vertices[2].Set( hx,  hy)
        m_vertices[3].Set(-hx,  hy)
        m_normals[0].Set(0.0, -1.0)
        m_normals[1].Set(1.0, 0.0)
        m_normals[2].Set(0.0, 1.0)
        m_normals[3].Set(-1.0, 0.0)
        m_centroid = center
        Local xf :b2Transform = New b2Transform()
        xf.position = center
        xf.R.Set(angle)
        '// Transform vertices and normals.
        For Local i:Int = 0 Until m_vertexCount
            b2Math.MulX(xf, m_vertices[i], m_vertices[i])
            b2Math.MulMV(xf.R, m_normals[i], m_normals[i])
        End
    End
    
    Function AsOrientedBox : b2PolygonShape (hx:Float, hy:Float, center:b2Vec2 = null, angle:Float = 0.0)
        Local polygonShape :b2PolygonShape = New b2PolygonShape()
        polygonShape.SetAsOrientedBox(hx, hy, center, angle)
        Return polygonShape
    End
    
    #rem
    '/**
    '* Set a(this) single edge.
    '*/
    #end
    Method SetAsEdge : void (v1:b2Vec2, v2:b2Vec2)
        m_vertexCount = 2
        Reserve(2)
        m_vertices[0].SetV(v1)
        m_vertices[1].SetV(v2)
        m_centroid.x = 0.5 * (v1.x + v2.x)
        m_centroid.y = 0.5 * (v1.y + v2.y)
        b2Math.SubtractVV(v2, v1, m_normals[0])
        b2Math.CrossVF(m_normals[0], 1.0, m_normals[0])
        m_normals[0].Normalize()
        m_normals[1].x = -m_normals[0].x
        m_normals[1].y = -m_normals[0].y
    End
    #rem
    '/**
    '* Set a(this) single edge.
    '*/
    #end
    Function AsEdge : b2PolygonShape (v1:b2Vec2, v2:b2Vec2)
        
        Local polygonShape :b2PolygonShape = New b2PolygonShape()
        polygonShape.SetAsEdge(v1, v2)
        Return polygonShape
    End
    #rem
    '/**
    '* @inheritDoc
    '*/
    #end
    Method TestPoint : Bool (xf:b2Transform, p:b2Vec2)
        
        Local tVec :b2Vec2
        '//b2Vec2 pLocal = b2MulT(xf.R, p - xf.position)
        Local tMat :b2Mat22 = xf.R
        Local tX :Float = p.x - xf.position.x
        Local tY :Float = p.y - xf.position.y
        Local pLocalX :Float = (tX*tMat.col1.x + tY*tMat.col1.y)
        Local pLocalY :Float = (tX*tMat.col2.x + tY*tMat.col2.y)
        For Local i:Int = 0 Until m_vertexCount
            
            '//float32 dot = b2Dot(m_normals.Get(i), pLocal - m_vertices.Get(i))
            tVec = m_vertices[i]
            tX = pLocalX - tVec.x
            tY = pLocalY - tVec.y
            tVec = m_normals[i]
            Local dot :Float = (tVec.x * tX + tVec.y * tY)
            If (dot > 0.0)
                
                Return False
            End
        End
        Return True
    End
    #rem
    '/**
    '* @inheritDoc
    '*/
    #end
    Method RayCast : Bool (output:b2RayCastOutput, input:b2RayCastInput, transform:b2Transform)
        
        Local lower :Float = 0.0
        Local upper :Float = input.maxFraction
        Local tX :Float
        Local tY :Float
        Local tMat :b2Mat22
        Local tVec :b2Vec2
        '// Put the ray into the polygons frame of reference. (AS3 Port Manual inlining follows)
        '//b2Vec2 p1 = b2MulT(transform.R, segment.p1 - transform.position)
        tX = input.p1.x - transform.position.x
        tY = input.p1.y - transform.position.y
        tMat = transform.R
        Local p1X :Float = (tX * tMat.col1.x + tY * tMat.col1.y)
        Local p1Y :Float = (tX * tMat.col2.x + tY * tMat.col2.y)
        '//b2Vec2 p2 = b2MulT(transform.R, segment.p2 - transform.position)
        tX = input.p2.x - transform.position.x
        tY = input.p2.y - transform.position.y
        tMat = transform.R
        Local p2X :Float = (tX * tMat.col1.x + tY * tMat.col1.y)
        Local p2Y :Float = (tX * tMat.col2.x + tY * tMat.col2.y)
        '//b2Vec2 d = p2 - p1
        Local dX :Float = p2X - p1X
        Local dY :Float = p2Y - p1Y
        Local index :Int = -1
        For Local i:Int = 0 Until m_vertexCount
            
            '// p = p1 + a * d
            '// dot(normal, p - v) = 0
            '// dot(normal, p1 - v) + a * dot(normal, d) = 0
            '//float32 numerator = b2Dot(m_normals.Get(i), m_vertices.Get(i) - p1)
            tVec = m_vertices[i]
            tX = tVec.x - p1X
            tY = tVec.y - p1Y
            tVec = m_normals[i]
            Local numerator :Float = (tVec.x*tX + tVec.y*tY)
            '//float32 denominator = b2Dot(m_normals.Get(i), d)
            Local denominator :Float = (tVec.x * dX + tVec.y * dY)
            If (denominator = 0.0)
                
                If (numerator < 0.0)
                    
                    Return False
                End
                
            Else
                
                
                '// Note: we want this predicate without division:
                '// lower < numerator / denominator, where denominator < 0
                '// Since denominator < 0, we have to flip the inequality:
                '// lower < numerator / denominator <=> denominator * lower > numerator.
                If (denominator < 0.0 And numerator < lower * denominator)
                    
                    '// Increase lower.
                    '// The segment enters this half-space.
                    lower = numerator / denominator
                    index = i
                Else  If (denominator > 0.0 And numerator < upper * denominator)
                    
                    
                    '// Decrease upper.
                    '// The segment exits this half-space.
                    upper = numerator / denominator
                End
            End
            If (upper < lower - Constants.EPSILON)
                
                Return False
            End
        End
        '//b2Settings.B2Assert(0.0 <= lower And lower <= input.maxLambda)
        If (index >= 0)
            
            output.fraction = lower
            '//output.normal = b2Mul(transform.R, m_normals.Get(index))
            tMat = transform.R
            tVec = m_normals[index]
            output.normal.x = (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y)
            output.normal.y = (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y)
            Return True
        End
        Return False
    End
    #rem
    '/**
    '* @inheritDoc
    '*/
    #end
    Method ComputeAABB : void (aabb:b2AABB, xf:b2Transform)
        
        '//var lower:b2Vec2 = b2Math.MulX(xf, m_vertices.Get(0))
        Local tMat :b2Mat22 = xf.R
        Local tVec :b2Vec2 = m_vertices[0]
        Local lowerX :Float = xf.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y)
        Local lowerY :Float = xf.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y)
        Local upperX :Float = lowerX
        Local upperY :Float = lowerY
        For Local i:Int = 1 Until m_vertexCount
            
            tVec = m_vertices[i]
            Local vX :Float = xf.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y)
            Local vY :Float = xf.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y)
            If( lowerX > vX  )
                lowerX = vX
            End
            
            If( lowerY > vY  )
                lowerY = vY
            End
            
            If( upperX < vX  )
                upperX = vX
            End
            
            If( upperY < vY  )
                upperY = vY
            End
        End
        aabb.lowerBound.x = lowerX - m_radius
        aabb.lowerBound.y = lowerY - m_radius
        aabb.upperBound.x = upperX + m_radius
        aabb.upperBound.y = upperY + m_radius
    End
    #rem
    '/**
    '* @inheritDoc
    '*/
    #end
    Method ComputeMass : void (massData:b2MassData, density:Float)
        
        '// Polygon mass, centroid, and inertia.
        '// Let rho be the polygon density in mass per unit area.
        '// Then:
        '// mass = rho * Int(dA)
        '// centroid.x = (1/mass) * rho * Int(x * dA)
        '// centroid.y = (1/mass) * rho * Int(y * dA)
        '// I = rho * Int((x*x + y*y) * dA)
        '//
        '// We can compute these integrals by summing all the integrals
        '// for each triangle of the polygon. To evaluate the integral
        '// for a single triangle, we make a change of variables to
        '// the (u,v) coordinates of the triangle:
        '// x = x0 + e1x * u + e2x * v
        '// y = y0 + e1y * u + e2y * v
        '// where 0 <= u And 0 <= v And u + v <= 1.0
        '//
        '// We integrate u from [0,1-v] and then v from [0,1].
        '// We also need to use the Jacobian of the transformation:
        '// D = cross(e1, e2)
        '//
        '// Simplification: triangle centroid = (1/3) * (p1 + p2 + p3)
        '//
        '// The rest of the handled(derivation) by computer algebra.
        '//b2Settings.B2Assert(m_vertexCount >= 2)
        '// A line segment has zero mass.
        If (m_vertexCount = 2)
            
            massData.center.x = 0.5 * (m_vertices[0].x + m_vertices[1].x)
            massData.center.y = 0.5 * (m_vertices[0].y + m_vertices[1].y)
            massData.mass = 0.0
            massData.I = 0.0
            Return
        End
        '//b2Vec2 center; center.Set(0.0f, 0.0f)
        Local centerX :Float = 0.0
        Local centerY :Float = 0.0
        Local area :Float = 0.0
        Local I :Float = 0.0
        '// the(pRef) reference point for forming triangles.
        '// Its location doesnt change the result (except for rounding error).
        '//b2Vec2 pRef(0.0f, 0.0f)
        Local p1X :Float = 0.0
        Local p1Y :Float = 0.0
        #rem
        '/*#if 0
        '// This code would put the reference point inside the polygon.
        'for (int32 i = 0
        'i < m_vertexCount
        '++i)
        '
        'pRef += m_vertices.Get(i)
        'End
        '
        'pRef *= 1.0f / count
        '#endif*/
        #end
        Local k_inv3 :Float = 1.0 / 3.0
        For Local i:Int = 0 Until m_vertexCount
            
            '// Triangle vertices.
            '//b2Vec2 p1 = pRef
            '//
            '//b2Vec2 p2 = m_vertices.Get(i)
            Local p2 :b2Vec2 = m_vertices[i]
            '//b2Vec2 p3 = i + 1 < m_vertexCount ? m_vertices.Get(i+1) : m_vertices.Get(0)
            Local p3 :b2Vec2 =  m_vertices[0]
            
            If( i + 1 < m_vertexCount  )
                p3 =  m_vertices[i+1]
            End
            '//b2Vec2 e1 = p2 - p1
            Local e1X :Float = p2.x - p1X
            Local e1Y :Float = p2.y - p1Y
            '//b2Vec2 e2 = p3 - p1
            Local e2X :Float = p3.x - p1X
            Local e2Y :Float = p3.y - p1Y
            '//float32 D = b2Cross(e1, e2)
            Local D :Float = e1X * e2Y - e1Y * e2X
            '//float32 triangleArea = 0.5f * D
            Local triangleArea :Float = 0.5 * D
            area += triangleArea
            '// Area weighted centroid
            '//center += triangleArea * k_inv3 * (p1 + p2 + p3)
            centerX += triangleArea * k_inv3 * (p1X + p2.x + p3.x)
            centerY += triangleArea * k_inv3 * (p1Y + p2.y + p3.y)
            '//float32 px = p1.x, py = p1.y
            Local px :Float = p1X
            Local py :Float = p1Y
            '//float32 ex1 = e1.x, ey1 = e1.y
            Local ex1 :Float = e1X
            Local ey1 :Float = e1Y
            '//float32 ex2 = e2.x, ey2 = e2.y
            Local ex2 :Float = e2X
            Local ey2 :Float = e2Y
            '//float32 intx2 = k_inv3 * (0.25f * (ex1*ex1 + ex2*ex1 + ex2*ex2) + (px*ex1 + px*ex2)) + 0.5f*px*px
            Local intx2 :Float = k_inv3 * (0.25 * (ex1*ex1 + ex2*ex1 + ex2*ex2) + (px*ex1 + px*ex2)) + 0.5*px*px
            '//float32 inty2 = k_inv3 * (0.25f * (ey1*ey1 + ey2*ey1 + ey2*ey2) + (py*ey1 + py*ey2)) + 0.5f*py*py
            Local inty2 :Float = k_inv3 * (0.25 * (ey1*ey1 + ey2*ey1 + ey2*ey2) + (py*ey1 + py*ey2)) + 0.5*py*py
            I += D * (intx2 + inty2)
        End
        '// Total mass
        massData.mass = density * area
        '// Center of mass
        '//b2Settings.B2Assert(area > Constants.EPSILON)
        '//center *= 1.0f / area
        centerX *= 1.0 / area
        centerY *= 1.0 / area
        '//massData->center = center
        massData.center.Set(centerX, centerY)
        '// Inertia tensor relative to the local origin.
        massData.I = density * I
    End
    #rem
    '/**
    '* @inheritDoc
    '*/
    #end
    Global sharedNormalL:b2Vec2 = New b2Vec2()
    Global tmpVec1:b2Vec2 = New b2Vec2()
    Global tmpVec2:b2Vec2 = New b2Vec2()
    Global tmpVec3:b2Vec2 = New b2Vec2()
    
    Method ComputeSubmergedArea:Float( normal:b2Vec2, offset:Float, xf:b2Transform, c:b2Vec2)
        
        '// Transform plane into shape co-ordinates
        Local normalL:b2Vec2 = sharedNormalL
        b2Math.MulTMV(xf.R, normal, normalL)
        
        Local offsetL :Float = offset - b2Math.Dot(normal, xf.position)
        Local diveCount :Int = 0
        Local intoIndex :Int = -1
        Local outoIndex :Int = -1
        Local lastSubmerged :Bool = False
        
        For Local i:Int = 0 Until m_vertexCount
            m_depths[i] = b2Math.Dot(normalL, m_vertices[i]) - offsetL
            Local isSubmerged :Bool = m_depths[i] < -Constants.EPSILON
            
            If (i > 0)
                If (isSubmerged)
                    If (Not(lastSubmerged))
                        intoIndex = i - 1
                        diveCount += 1
                    End
                Else
                    If (lastSubmerged)
                        outoIndex = i - 1
                        diveCount += 1
                    End
                End
            End
            
            lastSubmerged = isSubmerged
        End
        
        Select(diveCount)
            
            Case 0
                If (lastSubmerged )
                    '// Completely submerged
                    Local md :b2MassData = New b2MassData()
                    ComputeMass(md, 1)
                    b2Math.MulX(xf, md.center, c)
                    Return md.mass
                Else
                    '//Completely dry
                    Return 0
                End
                
            Case 1
                If (intoIndex = -1)
                    intoIndex = m_vertexCount - 1
                Else
                    outoIndex = m_vertexCount - 1
                End
            End
            
            Local intoIndex2 :Int = (intoIndex + 1) Mod m_vertexCount
            Local outoIndex2 :Int = (outoIndex + 1) Mod m_vertexCount
            Local intoLamdda :Float = (0 - m_depths[intoIndex]) / (m_depths[intoIndex2] - m_depths[intoIndex])
            Local outoLamdda :Float = (0 - m_depths[outoIndex]) / (m_depths[outoIndex2] - m_depths[outoIndex])
            
            Local intoVec:b2Vec2 = tmpVec1
            intoVec.x = m_vertices[intoIndex].x * (1 - intoLamdda) + m_vertices[intoIndex2].x * intoLamdda
            intoVec.y = m_vertices[intoIndex].y * (1 - intoLamdda) + m_vertices[intoIndex2].y * intoLamdda
            
            Local outoVec:b2Vec2 = tmpVec2
            outoVec.x = m_vertices[outoIndex].x * (1 - outoLamdda) + m_vertices[outoIndex2].x * outoLamdda
            outoVec.y = m_vertices[outoIndex].y * (1 - outoLamdda) + m_vertices[outoIndex2].y * outoLamdda
            
            '// Initialize accumulator
            Local area:Float = 0
            Local center:b2Vec2 = tmpVec3
            center.x = 0.0
            center.y = 0.0
            Local p2:b2Vec2 = m_vertices[intoIndex2]
            Local p3:b2Vec2
            '// An awkward loop from intoIndex2+1 to outIndex2
            Local i:Int = intoIndex2
            While (i <> outoIndex2)
                
                i = (i + 1) Mod m_vertexCount
                If(i = outoIndex2)
                    p3 = outoVec
                Else
                    p3 = m_vertices[i]
                End
                Local triangleArea :Float = 0.5 * ( (p2.x - intoVec.x) * (p3.y - intoVec.y) - (p2.y - intoVec.y) * (p3.x - intoVec.x) )
                area += triangleArea
                '// Area weighted centroid
                center.x += triangleArea * (intoVec.x + p2.x + p3.x) / 3
                center.y += triangleArea * (intoVec.y + p2.y + p3.y) / 3
                p2 = p3
            End
            '//Normalize and transform centroid
            center.Multiply(1 / area)
            b2Math.MulX(xf, center, c)
            Return area
        End
        #rem
        '/**
        '* Get the vertex count.
        '*/
        #end
        Method GetVertexCount : Int ()
            
            Return m_vertexCount
        End
        #rem
        '/**
        '* Get the vertices in local coordinates.
        '*/
        #end
        Method GetVertices : b2Vec2[] ()
            
            Return m_vertices
        End
        #rem
        '/**
        '* Get the edge normal vectors. one(There) for each vertex.
        '*/
        #end
        Method GetNormals : b2Vec2[] ()
            
            Return m_normals
        End
        #rem
        '/**
        '* Get the supporting vertex index in the given direction.
        '*/
        #end
        Method GetSupport : Int (d:b2Vec2)
            
            Local bestIndex :Int = 0
            Local bestValue :Float = m_vertices[0].x * d.x + m_vertices[0].y * d.y
            For Local i:Int = 1 Until m_vertexCount
                
                Local value :Float = m_vertices[i].x * d.x + m_vertices[i].y * d.y
                If (value > bestValue)
                    
                    bestIndex = i
                    bestValue = value
                End
            End
            
            Return bestIndex
        End
        Method GetSupportVertex : b2Vec2 (d:b2Vec2)
            
            Local bestIndex :Int = 0
            Local bestValue :Float = m_vertices[0].x * d.x + m_vertices[0].y * d.y
            For Local i:Int = 1 Until m_vertexCount
                
                Local value :Float = m_vertices[i].x * d.x + m_vertices[i].y * d.y
                If (value > bestValue)
                    
                    bestIndex = i
                    bestValue = value
                End
            End
            
            Return m_vertices[bestIndex]
        End
        '// TODO: Expose this
        Method Validate : Bool ()
            #rem
            '/*
            '// Ensure the convex(polygon).
            'for (int32 i = 0
            'i < m_vertexCount
            '++i)
            '
            'for (int32 j = 0
            '
            'j < m_vertexCount
            '
            '++j)
            '
            '// Dont check vertices on the current edge.
            'if (j = i Or j = (i + 1) Mod m_vertexCount)
            '
            'continue
            'End
            '// Your non(polygon)-convex (it has an indentation).
            '// Or your too(polygon) skinny.
            'float32 s = b2Dot(m_normals.Get(i), m_vertices.Get(j) - m_vertices.Get(i))
            'B2Assert(s < -b2_linearSlop)
            'End
            'End
            '// Ensure the counter(polygon)-clockwise.
            'For Local i:Int = 1 Until m_vertexCount
            '
            'Local cross :Float = b2Math.b2CrossVV(m_normals.Get(Int(i-1)), m_normals.Get(i))
            '// Keep ASinf happy.
            'cross = b2Math.b2Clamp(cross, -1.0, 1.0)
            '// You have consecutive edges that are almost parallel on your polygon.
            'Local angle :Float = ASinr(cross)
            '//b2Assert(angle > b2_angularSlop)
            'trace(angle > b2Settings.b2_angularSlop)
            'End
            '
            '*/
            #end
            Return False
        End
        
        '//--------------- Internals Below -------------------
        #rem
        '/**
        '* @
        '*/
        #end
        Method New()
            Super.New()
            '//b2Settings.B2Assert(def.type = e_polygonShape)
            m_type = e_polygonShape
            m_centroid = New b2Vec2()
            Reserve(4)
        End
        
        Method Reserve : void (count:Int)
            If m_vertices.Length = 0
                m_depths = New Float[count]
            End    
            If m_vertices.Length < count
                Local startLength:Int = m_vertices.Length 
                m_depths = m_depths.Resize(count)
                m_vertices = m_vertices.Resize(count)
                m_normals = m_normals.Resize(count)
                
                For Local i:Int = startLength Until count
                    m_vertices[i] = New b2Vec2()
                    m_normals[i] = New b2Vec2()
                End
            End            
        End
        
        
        #rem
        '/**
        '* Computes the centroid of the given polygon
        '* @param	vs		vector of b2Vec specifying a polygon
        '* @param	count	length of vs
        '* @return the polygon centroid
        '*/
        #end
        Function ComputeCentroid : b2Vec2 (vs:b2Vec2[], count:Int)
            
            '//b2Settings.B2Assert(count >= 3)
            '//b2Vec2 c; c.Set(0.0f, 0.0f)
            Local c :b2Vec2 = New b2Vec2()
            Local area :Float = 0.0
            '// the(pRef) reference point for forming triangles.
            '// Its location doesnt change the result (except for rounding error).
            '//b2Vec2 pRef(0.0f, 0.0f)
            Local p1X :Float = 0.0
            Local p1Y :Float = 0.0
            #rem
            '/*#if 0
            '// This code would put the reference point inside the polygon.
            'for (int32 i = 0
            'i < count
            '++i)
            '
            'pRef += vs.Get(i)
            'End
            '
            'pRef *= 1.0f / count
            '#endif*/
            #end
            Local inv3 :Float = 1.0 / 3.0
            For Local i:Int = 0 Until count
                
                '// Triangle vertices.
                '//b2Vec2 p1 = pRef
                '// 0.0, 0.0
                '//b2Vec2 p2 = vs.Get(i)
                Local p2 :b2Vec2 = vs[i]
                '//b2Vec2 p3 = i + 1 < count ? vs.Get(i+1) : vs.Get(0)
                Local p3 :b2Vec2 =  vs[0]
                
                If( i + 1 < count  )
                    p3 = vs[i+1]
                End
                '//b2Vec2 e1 = p2 - p1
                Local e1X :Float = p2.x - p1X
                Local e1Y :Float = p2.y - p1Y
                '//b2Vec2 e2 = p3 - p1
                Local e2X :Float = p3.x - p1X
                Local e2Y :Float = p3.y - p1Y
                '//float32 D = b2Cross(e1, e2)
                Local D :Float = (e1X * e2Y - e1Y * e2X)
                '//float32 triangleArea = 0.5f * D
                Local triangleArea :Float = 0.5 * D
                area += triangleArea
                '// Area weighted centroid
                '//c += triangleArea * inv3 * (p1 + p2 + p3)
                c.x += triangleArea * inv3 * (p1X + p2.x + p3.x)
                c.y += triangleArea * inv3 * (p1Y + p2.y + p3.y)
            End
            '// Centroid
            '//beSettings.B2Assert(area > Constants.EPSILON)
            '//c *= 1.0 / area
            c.x *= 1.0 / area
            c.y *= 1.0 / area
            Return c
        End
        #rem
        '/**
        '* Computes a polygons OBB
        '* @see http://www.geometrictools.com/Documentation/MinimumAreaRectangle.pdf
        '*/
        #end
        Function ComputeOBB : void (obb:b2OBB, vs:b2Vec2[], count:Int)
            Local i :Int
            Local p :b2Vec2[] = New b2Vec2[count + 1]
            For Local i:Int = 0 Until count
                p[i] = vs[i]
            End
            
            p[count] = p[0]
            Local minArea :Float = Constants.FMAX
            For Local i:Int = 1 Until count
                
                Local root :b2Vec2 = p[i-1]
                '//b2Vec2 ux = p.Get(i) - root
                Local uxX :Float = p[i].x - root.x
                Local uxY :Float = p[i].y - root.y
                '//var length:Float = ux.Normalize()
                Local length :Float = Sqrt(uxX*uxX + uxY*uxY)
                uxX /= length
                uxY /= length
                '//b2Settings.B2Assert(length > Constants.EPSILON)
                '//b2Vec2 uy(-ux.y, ux.x)
                Local uyX :Float = -uxY
                Local uyY :Float = uxX
                '//b2Vec2 lower(FLT_MAX, FLT_MAX)
                Local lowerX :Float = Constants.FMAX
                Local lowerY :Float = Constants.FMAX
                '//b2Vec2 upper(-FLT_MAX, -FLT_MAX)
                Local upperX :Float = -Constants.FMAX
                Local upperY :Float = -Constants.FMAX
                For Local j:Int = 0 Until count
                    
                    '//b2Vec2 d = p.Get(j) - root
                    Local dX :Float = p[j].x - root.x
                    Local dY :Float = p[j].y - root.y
                    '//b2Vec2 r
                    '//var rX:Float = b2Dot(ux, d)
                    Local rX :Float = (uxX*dX + uxY*dY)
                    '//var rY:Float = b2Dot(uy, d)
                    Local rY :Float = (uyX*dX + uyY*dY)
                    '//lower = b2Min(lower, r)
                    If (rX < lowerX)
                        lowerX = rX
                    End
                    If (rY < lowerY)
                        lowerY = rY
                    End
                    '//upper = b2Max(upper, r)
                    If (rX > upperX)
                        upperX = rX
                    End
                    If (rY > upperY)
                        upperY = rY
                    End
                End
                Local area :Float = (upperX - lowerX) * (upperY - lowerY)
                If (area < 0.95 * minArea)
                    
                    minArea = area
                    '//obb->R.col1 = ux
                    obb.R.col1.x = uxX
                    obb.R.col1.y = uxY
                    '//obb->R.col2 = uy
                    obb.R.col2.x = uyX
                    obb.R.col2.y = uyY
                    '//b2Vec2 center = 0.5f * (lower + upper)
                    Local centerX :Float = 0.5 * (lowerX + upperX)
                    Local centerY :Float = 0.5 * (lowerY + upperY)
                    '//obb->center = root + b2Mul(obb->R, center)
                    Local tMat :b2Mat22 = obb.R
                    obb.center.x = root.x + (tMat.col1.x * centerX + tMat.col2.x * centerY)
                    obb.center.y = root.y + (tMat.col1.y * centerX + tMat.col2.y * centerY)
                    '//obb->extents = 0.5f * (upper - lower)
                    obb.extents.x = 0.5 * (upperX - lowerX)
                    obb.extents.y = 0.5 * (upperY - lowerY)
                End
            End
            '//b2Settings.B2Assert(minArea < Constants.FMAX)
        End
    End
    
    
    
    
    
    
    
    
