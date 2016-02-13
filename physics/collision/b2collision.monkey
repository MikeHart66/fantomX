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
Class b2Collision
    '// Null feature
    Const b2_nullFeature:Int = $000000ff
    '//UCHAR_MAX
    '// Sutherland-Hodgman clipping.
    Function ClipSegmentToLine : Int (vOut:ClipVertex[], vIn:ClipVertex[], normal:b2Vec2, offset:Float)
        
        Local cv :ClipVertex
        '// Start with no output points
        Local numOut :Int = 0
        cv = vIn[0]
        Local vIn0 :b2Vec2 = cv.v
        cv = vIn[1]
        Local vIn1 :b2Vec2 = cv.v
        '// Calculate the distance of end points to the line
        Local distance0 :Float = normal.x * vIn0.x + normal.y * vIn0.y - offset
        Local distance1 :Float = normal.x * vIn1.x + normal.y * vIn1.y - offset
        '// If the points are behind the plane
        If (distance0 <= 0.0)
            vOut[numOut].Set(vIn[0])
            numOut += 1
        End
        If (distance1 <= 0.0)
            vOut[numOut].Set(vIn[1])
            numOut += 1
        End
        '// If the points are on different sides of the plane
        If (distance0 * distance1 < 0.0)
            
            '// Find intersection point of edge and plane
            Local interp :Float = distance0 / (distance0 - distance1)
            '// expanded for performance
            '// vOut.Get(numOut).v = vIn.Get(0).v + interp * (vIn.Get(1).v - vIn.Get(0).v)
            cv = vOut[numOut]
            Local tVec :b2Vec2 = cv.v
            tVec.x = vIn0.x + interp * (vIn1.x - vIn0.x)
            tVec.y = vIn0.y + interp * (vIn1.y - vIn0.y)
            cv = vOut[numOut]
            Local cv2 : ClipVertex
            If (distance0 > 0.0)
                
                cv2 = vIn[0]
                cv.id = cv2.id
            Else
                
                
                cv2 = vIn[1]
                cv.id = cv2.id
            End
            
            numOut += 1
            
        End
        Return numOut
    End
    '// Find the separation between poly1 and poly2 for a give edge normal on poly1.0
    Function EdgeSeparation : Float (	poly1:b2PolygonShape, xf1:b2Transform, edge1:Int,
        poly2:b2PolygonShape, xf2:b2Transform)
        
        Local count1 :Int = poly1.m_vertexCount
        Local vertices1:b2Vec2[] = poly1.m_vertices
        Local normals1:b2Vec2[] = poly1.m_normals
        Local count2 :Int = poly2.m_vertexCount
        Local vertices2:b2Vec2[] = poly2.m_vertices
        '//b2Assert(0 <= edge1 And edge1 < count1)
        Local tMat :b2Mat22
        Local tVec :b2Vec2
        '// Convert normal from poly1s frame into poly2s frame.
        '//b2Vec2 normal1World = b2Mul(xf1.R, normals1.Get(edge1))
        tMat = xf1.R
        tVec = normals1[edge1]
        Local normal1WorldX :Float = (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y)
        Local normal1WorldY :Float = (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y)
        '//b2Vec2 normal1 = b2MulT(xf2.R, normal1World)
        tMat = xf2.R
        Local normal1X :Float = (tMat.col1.x * normal1WorldX + tMat.col1.y * normal1WorldY)
        Local normal1Y :Float = (tMat.col2.x * normal1WorldX + tMat.col2.y * normal1WorldY)
        '// Find support vertex on poly2 for -normal.
        Local index :Int = 0
        Local minDot :Float = Constants.FMAX
        
        For Local i:Int = 0 Until count2
            '//float32 dot = b2Dot(poly2->m_vertices.Get(i), normal1)
            tVec = vertices2[i]
            Local dot :Float = tVec.x * normal1X + tVec.y * normal1Y
        
            If (dot < minDot)
                minDot = dot
                index = i
            End
        End
        '//b2Vec2 v1 = b2Mul(xf1, vertices1.Get(edge1))
        tVec = vertices1[edge1]
        tMat = xf1.R
        Local v1X :Float = xf1.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y)
        Local v1Y :Float = xf1.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y)
        '//b2Vec2 v2 = b2Mul(xf2, vertices2.Get(index))
        tVec = vertices2[index]
        tMat = xf2.R
        Local v2X :Float = xf2.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y)
        Local v2Y :Float = xf2.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y)
        '//var separation:Float = b2Math.b2Dot( b2Math.SubtractVV( v2, v1 ) , normal)
        v2X -= v1X
        v2Y -= v1Y
        '//float32 separation = b2Dot(v2 - v1, normal1World)
        Local separation :Float = v2X * normal1WorldX + v2Y * normal1WorldY
        Return separation
    End
    
    '// Find the max separation between poly1 and poly2 using edge normals
    '// from poly1.0
    Function FindMaxSeparation : Float (edgeIndex:Int[],
        poly1:b2PolygonShape, xf1:b2Transform,
        poly2:b2PolygonShape, xf2:b2Transform)
        
        Local count1:Int = poly1.m_vertexCount
        Local normals1:b2Vec2[] = poly1.m_normals
        Local tVec :b2Vec2
        Local tMat :b2Mat22
        '// Vector pointing from the centroid of poly1 to the centroid of poly2.0
        '//b2Vec2 d = b2Mul(xf2, poly2->m_centroid) - b2Mul(xf1, poly1->m_centroid)
        tMat = xf2.R
        tVec = poly2.m_centroid
        Local dX :Float = xf2.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y)
        Local dY :Float = xf2.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y)
        tMat = xf1.R
        tVec = poly1.m_centroid
        dX -= xf1.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y)
        dY -= xf1.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y)
        '//b2Vec2 dLocal1 = b2MulT(xf1.R, d)
        Local dLocal1X :Float = (dX * xf1.R.col1.x + dY * xf1.R.col1.y)
        Local dLocal1Y :Float = (dX * xf1.R.col2.x + dY * xf1.R.col2.y)
        '// Get support a(vertex) hint for our search
        Local edge :Int = 0
        Local maxDot :Float = -Constants.FMAX
        
        For Local i:Int = 0 Until count1
            '//var dot:Float = b2Math.b2Dot(normals1.Get(i), dLocal1)
            tVec = normals1[i]
            Local dot :Float = (tVec.x * dLocal1X + tVec.y * dLocal1Y)
            If (dot > maxDot)
                maxDot = dot
                edge = i
            End
        End
        '// Get the separation for the edge normal.
        Local s :Float = EdgeSeparation(poly1, xf1, edge, poly2, xf2)
        '// Check the separation for the previous edge normal.
        Local prevEdge:Int =  count1 - 1
        
        If( edge - 1 >= 0  )
            prevEdge =  edge - 1
        End
        
        Local sPrev :Float = EdgeSeparation(poly1, xf1, prevEdge, poly2, xf2)
        '// Check the separation for the nextItem edge normal.
        Local nextEdge :Int =  0
        
        If( edge + 1 < count1  )
            nextEdge =  edge + 1
        End
        
        Local sNext :Float = EdgeSeparation(poly1, xf1, nextEdge, poly2, xf2)
        '// Find the best edge and the search direction.
        Local bestEdge :Int
        Local bestSeparation :Float
        Local increment :Int
        
        If (sPrev > s And sPrev > sNext)
            increment = -1
            bestEdge = prevEdge
            bestSeparation = sPrev
        Else  If (sNext > s)
            increment = 1
            bestEdge = nextEdge
            bestSeparation = sNext
        Else
            '// pointer out
            edgeIndex[0] = edge
            Return s
        End
        
        '// Perform a local search for the best edge normal.
        While (True)
            If (increment = -1)
                If( bestEdge - 1 >= 0  )
                    edge = bestEdge - 1
                Else
                    edge = count1 - 1
                End
                
            Else
                If( bestEdge + 1 < count1  )
                    edge = bestEdge + 1
                Else
                    edge = 0
                End
            End
            
            s = EdgeSeparation(poly1, xf1, edge, poly2, xf2)
            If (s > bestSeparation)
                
                bestEdge = edge
                bestSeparation = s
            Else
                Exit
            End
        End
        '// pointer out
        edgeIndex[0] = bestEdge
        Return bestSeparation
    End
    
    Function FindIncidentEdge : void (c:ClipVertex[],
        poly1:b2PolygonShape, xf1:b2Transform, edge1:Int,
        poly2:b2PolygonShape, xf2:b2Transform)
        
        Local count1:Int = poly1.m_vertexCount
        Local normals1:b2Vec2[] = poly1.m_normals
        Local count2:Int = poly2.m_vertexCount
        Local vertices2:b2Vec2[] = poly2.m_vertices
        Local normals2:b2Vec2[] = poly2.m_normals
        '//b2Assert(0 <= edge1 And edge1 < count1)
        Local tMat :b2Mat22
        Local tVec :b2Vec2
        '// Get the normal of the reference edge in poly2s frame.
        '//b2Vec2 normal1 = b2MulT(xf2.R, b2Mul(xf1.R, normals1.Get(edge1)))
        tMat = xf1.R
        tVec = normals1[edge1]
        Local normal1X :Float = (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y)
        Local normal1Y :Float = (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y)
        tMat = xf2.R
        Local tX :Float = (tMat.col1.x * normal1X + tMat.col1.y * normal1Y)
        normal1Y = 		(tMat.col2.x * normal1X + tMat.col2.y * normal1Y)
        normal1X = tX
        '// Find the incident edge on poly2.0
        Local index :Int = 0
        Local minDot :Float = Constants.FMAX
        
        For Local i:Int = 0 Until count2
            '//var dot:Float = b2Dot(normal1, normals2.Get(i))
            tVec = normals2[i]
            Local dot :Float = (normal1X * tVec.x + normal1Y * tVec.y)
            If (dot < minDot)
                minDot = dot
                index = i
            End
        End
        Local tClip :ClipVertex
        '// Build the clip vertices for the incident edge.
        Local i1 :Int = index
        Local i2 :Int =  0
        
        If( i1 + 1 < count2  )
            i2 =  i1 + 1
        End
        tClip = c[0]
        '//c.Get(0).v = b2Mul(xf2, vertices2.Get(i1))
        tVec = vertices2[i1]
        tMat = xf2.R
        tClip.v.x = xf2.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y)
        tClip.v.y = xf2.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y)
        tClip.id.features.ReferenceEdge = edge1
        tClip.id.features.IncidentEdge = i1
        tClip.id.features.IncidentVertex = 0
        tClip = c[1]
        '//c.Get(1).v = b2Mul(xf2, vertices2.Get(i2))
        tVec = vertices2[i2]
        tMat = xf2.R
        tClip.v.x = xf2.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y)
        tClip.v.y = xf2.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y)
        tClip.id.features.ReferenceEdge = edge1
        tClip.id.features.IncidentEdge = i2
        tClip.id.features.IncidentVertex = 1
    End
    
    Function MakeClipPointVector : ClipVertex[] ()
        Return [New ClipVertex(),New ClipVertex()]
    End
    
    Global s_incidentEdge:ClipVertex[] = MakeClipPointVector()
    Global s_clipPoints1:ClipVertex[] = MakeClipPointVector()
    Global s_clipPoints2:ClipVertex[] = MakeClipPointVector()
    Global s_edgeAO:Int[] = New Int[1]
    Global s_edgeBO:Int[] = New Int[1]
    Global s_localTangent:b2Vec2 = New b2Vec2()
    Global s_localNormal:b2Vec2 = New b2Vec2()
    Global s_planePoint:b2Vec2 = New b2Vec2()
    Global s_normal:b2Vec2 = New b2Vec2()
    Global s_tangent:b2Vec2 = New b2Vec2()
    Global s_tangent2:b2Vec2 = New b2Vec2()
    Global s_v11:b2Vec2 = New b2Vec2()
    Global s_v12:b2Vec2 = New b2Vec2()
    '// Find edge normal of max separation on A - return if separating found(axis)
    '// Find edge normal of max separation on B - return if separation found(axis)
    '// Choose reference min(edge)(minA, minB)
    '// Find incident edge
    '// Clip
    Global b2CollidePolyTempVec:b2Vec2 = New b2Vec2()
    '// The normal points from 1 to 2
    Function CollidePolygons : void (manifold:b2Manifold,
        polyA:b2PolygonShape, xfA:b2Transform,
        polyB:b2PolygonShape, xfB:b2Transform)
        
        Local cv : ClipVertex
        manifold.m_pointCount = 0
        Local totalRadius :Float = polyA.m_radius + polyB.m_radius
        Local edgeA:Int = 0
        s_edgeAO[0] = edgeA
        Local separationA :Float = FindMaxSeparation(s_edgeAO, polyA, xfA, polyB, xfB)
        edgeA = s_edgeAO[0]
        If (separationA > totalRadius)
            Return
        End
        Local edgeB:Int = 0
        s_edgeBO[0] = edgeB
        Local separationB :Float = FindMaxSeparation(s_edgeBO, polyB, xfB, polyA, xfA)
        edgeB = s_edgeBO[0]
        If (separationB > totalRadius)
            Return
        End
        Local poly1 :b2PolygonShape
        '// reference poly
        Local poly2 :b2PolygonShape
        '// incident poly
        Local xf1 :b2Transform
        Local xf2 :b2Transform
        Local edge1 :Int
        '// reference edge
        Local flip :Int
        const k_relativeTol:Float = 0.98
        const k_absoluteTol:Float = 0.001
        Local tMat :b2Mat22
        If (separationB > k_relativeTol * separationA + k_absoluteTol)
            poly1 = polyB
            poly2 = polyA
            xf1 = xfB
            xf2 = xfA
            edge1 = edgeB
            manifold.m_type = b2Manifold.e_faceB
            flip = 1
        Else
            poly1 = polyA
            poly2 = polyB
            xf1 = xfA
            xf2 = xfB
            edge1 = edgeA
            manifold.m_type = b2Manifold.e_faceA
            flip = 0
        End
        
        Local incidentEdge:ClipVertex[] = s_incidentEdge
        FindIncidentEdge(incidentEdge, poly1, xf1, edge1, poly2, xf2)
        Local count1 :Int = poly1.m_vertexCount
        Local vertices1:b2Vec2[] = poly1.m_vertices
        Local local_v11 :b2Vec2 = vertices1[edge1]
        Local local_v12 :b2Vec2
        
        If (edge1 + 1 < count1)
            local_v12 = vertices1[edge1+1]
        Else
            local_v12 = vertices1[0]
        End
        
        Local localTangent :b2Vec2 = s_localTangent
        localTangent.x = local_v12.x - local_v11.x
        localTangent.y = local_v12.y - local_v11.y
        localTangent.Normalize()
        Local localNormal :b2Vec2 = s_localNormal
        localNormal.x = localTangent.y
        localNormal.y = -localTangent.x
        Local planePoint :b2Vec2 = s_planePoint
        planePoint.x = 0.5 * (local_v11.x + local_v12.x)
        planePoint.y = 0.5 * (local_v11.y + local_v12.y)
        Local tangent :b2Vec2 = s_tangent
        '//tangent = b2Math.b2MulMV(xf1.R, localTangent)
        tMat = xf1.R
        tangent.x = (tMat.col1.x * localTangent.x + tMat.col2.x * localTangent.y)
        tangent.y = (tMat.col1.y * localTangent.x + tMat.col2.y * localTangent.y)
        Local tangent2 :b2Vec2 = s_tangent2
        tangent2.x = - tangent.x
        tangent2.y = - tangent.y
        Local normal :b2Vec2 = s_normal
        normal.x = tangent.y
        normal.y = -tangent.x
        '//v11 = b2Math.MulX(xf1, local_v11)
        '//v12 = b2Math.MulX(xf1, local_v12)
        Local v11 :b2Vec2 = s_v11
        Local v12 :b2Vec2 = s_v12
        v11.x = xf1.position.x + (tMat.col1.x * local_v11.x + tMat.col2.x * local_v11.y)
        v11.y = xf1.position.y + (tMat.col1.y * local_v11.x + tMat.col2.y * local_v11.y)
        v12.x = xf1.position.x + (tMat.col1.x * local_v12.x + tMat.col2.x * local_v12.y)
        v12.y = xf1.position.y + (tMat.col1.y * local_v12.x + tMat.col2.y * local_v12.y)
        '// Face offset
        Local frontOffset :Float = normal.x * v11.x + normal.y * v11.y
        '// Side offsets, extended by polytope skin thickness
        Local sideOffset1 :Float = -tangent.x * v11.x - tangent.y * v11.y + totalRadius
        Local sideOffset2 :Float = tangent.x * v12.x + tangent.y * v12.y + totalRadius
        '// Clip incident edge against extruded edge1 side edges.
        Local clipPoints1:ClipVertex[] = s_clipPoints1
        Local clipPoints2:ClipVertex[] = s_clipPoints2
        Local np :Int
        '// Clip to box side 1
        '//np = ClipSegmentToLine(clipPoints1, incidentEdge, -tangent, sideOffset1)
        np = ClipSegmentToLine(clipPoints1, incidentEdge, tangent2, sideOffset1)
        If (np < 2)
            Return
        End
        '// Clip to negative box side 1
        np = ClipSegmentToLine(clipPoints2, clipPoints1,  tangent, sideOffset2)
        If (np < 2)
            Return
        End
        '// Now clipPoints2 contains the clipped points.
        manifold.m_localPlaneNormal.SetV(localNormal)
        manifold.m_localPoint.SetV(planePoint)
        Local pointCount:Int = 0
        
        For Local i:Int = 0 Until b2Settings.b2_maxManifoldPoints
            cv = clipPoints2[i]
            Local separation :Float = normal.x * cv.v.x + normal.y * cv.v.y - frontOffset
            If (separation <= totalRadius)
                Local cp :b2ManifoldPoint = manifold.m_points[ pointCount ]
                '//cp.m_localPoint = b2Math.b2MulXT(xf2, cv.v)
                tMat = xf2.R
                Local tX :Float = cv.v.x - xf2.position.x
                Local tY :Float = cv.v.y - xf2.position.y
                cp.m_localPoint.x = (tX * tMat.col1.x + tY * tMat.col1.y )
                cp.m_localPoint.y = (tX * tMat.col2.x + tY * tMat.col2.y )
                cp.m_id.Set(cv.id)
                cp.m_id.features.Flip = flip
                pointCount += 1
                
            End
        End
        manifold.m_pointCount = pointCount
    End
    
    Function CollideCircles : void (
        manifold:b2Manifold,
        circle1:b2CircleShape, xf1:b2Transform,
        circle2:b2CircleShape, xf2:b2Transform)
        
        manifold.m_pointCount = 0
        Local tMat :b2Mat22
        Local tVec :b2Vec2
        '//b2Vec2 p1 = b2Mul(xf1, circle1->m_p)
        tMat = xf1.R
        tVec = circle1.m_p
        Local p1X :Float = xf1.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y)
        Local p1Y :Float = xf1.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y)
        '//b2Vec2 p2 = b2Mul(xf2, circle2->m_p)
        tMat = xf2.R
        tVec = circle2.m_p
        Local p2X :Float = xf2.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y)
        Local p2Y :Float = xf2.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y)
        '//b2Vec2 d = p2 - p1
        Local dX :Float = p2X - p1X
        Local dY :Float = p2Y - p1Y
        '//var distSqr:Float = b2Math.b2Dot(d, d)
        Local distSqr :Float = dX * dX + dY * dY
        Local radius :Float = circle1.m_radius + circle2.m_radius
        If (distSqr > radius * radius)
            Return
        End
        
        manifold.m_type = b2Manifold.e_circles
        manifold.m_localPoint.SetV(circle1.m_p)
        manifold.m_localPlaneNormal.SetZero()
        manifold.m_pointCount = 1
        manifold.m_points[0].m_localPoint.SetV(circle2.m_p)
        manifold.m_points[0].m_id.Key = 0
    End
    
    Function CollidePolygonAndCircle : void (
        manifold:b2Manifold,
        polygon:b2PolygonShape, xf1:b2Transform,
        circle:b2CircleShape, xf2:b2Transform)
        
        manifold.m_pointCount = 0
        Local tPoint :b2ManifoldPoint
        Local dX :Float
        Local dY :Float
        Local positionX :Float
        Local positionY :Float
        Local tVec :b2Vec2
        Local tMat :b2Mat22
        '// Compute circle position in the frame of the polygon.
        '//b2Vec2 c = b2Mul(xf2, circle->m_localPosition)
        tMat = xf2.R
        tVec = circle.m_p
        Local cX :Float = xf2.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y)
        Local cY :Float = xf2.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y)
        '//b2Vec2 cLocal = b2MulT(xf1, c)
        dX = cX - xf1.position.x
        dY = cY - xf1.position.y
        tMat = xf1.R
        Local cLocalX :Float = (dX * tMat.col1.x + dY * tMat.col1.y)
        Local cLocalY :Float = (dX * tMat.col2.x + dY * tMat.col2.y)
        Local dist :Float
        '// Find the min separating edge.
        Local normalIndex :Int = 0
        Local separation :Float = -Constants.FMAX
        Local radius :Float = polygon.m_radius + circle.m_radius
        Local vertexCount :Int = polygon.m_vertexCount
        Local vertices:b2Vec2[] = polygon.m_vertices
        Local normals:b2Vec2[] = polygon.m_normals
        
        For Local i:Int = 0 Until vertexCount
            '//float32 s = b2Dot(normals.Get(i), cLocal - vertices.Get(i))
            tVec = vertices[i]
            dX = cLocalX-tVec.x
            dY = cLocalY-tVec.y
            tVec = normals[i]
            Local s :Float = tVec.x * dX + tVec.y * dY
    
            If (s > radius)
                '// Early out.
                Return
            End
    
            If (s > separation)
                separation = s
                normalIndex = i
            End
        End
        
        '// Vertices that subtend the incident face
        Local vertIndex1 :Int = normalIndex
        Local vertIndex2 :Int = 0
        
        If( vertIndex1 + 1 < vertexCount )
            vertIndex2 = vertIndex1 + 1
        End
        
        Local v1 :b2Vec2 = vertices[vertIndex1]
        Local v2 :b2Vec2 = vertices[vertIndex2]
    
        '// If the inside(center) the polygon ...
        If (separation < Constants.EPSILON)
            manifold.m_pointCount = 1
            manifold.m_type = b2Manifold.e_faceA
            manifold.m_localPlaneNormal.SetV(normals[normalIndex])
            manifold.m_localPoint.x = 0.5 * (v1.x + v2.x)
            manifold.m_localPoint.y = 0.5 * (v1.y + v2.y)
            manifold.m_points[0].m_localPoint.SetV(circle.m_p)
            manifold.m_points[0].m_id.Key = 0
            Return
        End
        '// Project the circle center onto the edge segment.
        Local u1 :Float = (cLocalX - v1.x) * (v2.x - v1.x) + (cLocalY - v1.y) * (v2.y - v1.y)
        Local u2 :Float = (cLocalX - v2.x) * (v1.x - v2.x) + (cLocalY - v2.y) * (v1.y - v2.y)
        
        If (u1 <= 0.0)
            If ((cLocalX-v1.x)*(cLocalX-v1.x)+(cLocalY-v1.y)*(cLocalY-v1.y) > radius * radius)
                Return
            End
            manifold.m_pointCount = 1
            manifold.m_type = b2Manifold.e_faceA
            manifold.m_localPlaneNormal.x = cLocalX - v1.x
            manifold.m_localPlaneNormal.y = cLocalY - v1.y
            manifold.m_localPlaneNormal.Normalize()
            manifold.m_localPoint.SetV(v1)
            manifold.m_points[0].m_localPoint.SetV(circle.m_p)
            manifold.m_points[0].m_id.Key = 0
        Else  If (u2 <= 0)
            If ((cLocalX-v2.x)*(cLocalX-v2.x)+(cLocalY-v2.y)*(cLocalY-v2.y) > radius * radius)
                Return
            End
            manifold.m_pointCount = 1
            manifold.m_type = b2Manifold.e_faceA
            manifold.m_localPlaneNormal.x = cLocalX - v2.x
            manifold.m_localPlaneNormal.y = cLocalY - v2.y
            manifold.m_localPlaneNormal.Normalize()
            manifold.m_localPoint.SetV(v2)
            manifold.m_points[0].m_localPoint.SetV(circle.m_p)
            manifold.m_points[0].m_id.Key = 0
        Else
            Local faceCenterX :Float = 0.5 * (v1.x + v2.x)
            Local faceCenterY :Float = 0.5 * (v1.y + v2.y)
            separation = (cLocalX - faceCenterX) * normals[vertIndex1].x + (cLocalY - faceCenterY) * normals[vertIndex1].y
            If (separation > radius)
                Return
            End
            manifold.m_pointCount = 1
            manifold.m_type = b2Manifold.e_faceA
            manifold.m_localPlaneNormal.x = normals[vertIndex1].x
            manifold.m_localPlaneNormal.y = normals[vertIndex1].y
            manifold.m_localPlaneNormal.Normalize()
            manifold.m_localPoint.Set(faceCenterX,faceCenterY)
            manifold.m_points[0].m_localPoint.SetV(circle.m_p)
            manifold.m_points[0].m_id.Key = 0
        End
    End
    
    Function TestOverlap : Bool (a:b2AABB, b:b2AABB)
        Local t1 :b2Vec2 = b.lowerBound
        Local t2 :b2Vec2 = a.upperBound
        '//d1 = b2Math.SubtractVV(b.lowerBound, a.upperBound)
        Local d1X :Float = t1.x - t2.x
        Local d1Y :Float = t1.y - t2.y
        '//d2 = b2Math.SubtractVV(a.lowerBound, b.upperBound)
        t1 = a.lowerBound
        t2 = b.upperBound
        Local d2X :Float = t1.x - t2.x
        Local d2Y :Float = t1.y - t2.y
        If (d1X > 0.0 Or d1Y > 0.0)
            Return False
        End
        If (d2X > 0.0 Or d2Y > 0.0)
            Return False
        End
        Return True
    End
End


