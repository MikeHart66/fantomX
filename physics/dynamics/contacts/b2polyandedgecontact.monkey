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
Class PolyAndEdgeContactTypeFactory Extends ContactTypeFactory
    Method Create : b2Contact (allocator: Object)
        
        Return New b2PolyAndEdgeContact()
    End
    
    Method Destroy : void (contact:b2Contact, allocator: Object)
        
    End
End
Class b2PolyAndEdgeContact Extends b2Contact
    
    Method New()
        Super.New()
    End
    
    Method Reset : void (fixtureA:b2Fixture, fixtureB:b2Fixture)
        
        Super.Reset(fixtureA, fixtureB)
#If CONFIG = "debug"
        b2Settings.B2Assert(fixtureA.GetType() = b2Shape.e_polygonShape)
        b2Settings.B2Assert(fixtureB.GetType() = b2Shape.e_edgeShape)
#End
    End
    
    '//~b2PolyAndEdgeContact() {}
    Method Evaluate : void ()
        
        Local bA :b2Body = m_fixtureA.GetBody()
        Local bB :b2Body = m_fixtureB.GetBody()
        B2CollidePolyAndEdge(m_manifold,
        b2PolygonShape(m_fixtureA.GetShape()), bA.m_xf,
        b2EdgeShape(m_fixtureB.GetShape()), bB.m_xf)
    End
    Method B2CollidePolyAndEdge : void (manifold: b2Manifold,
        polygon: b2PolygonShape,
        xf1: b2Transform,
        edge: b2EdgeShape,
        xf2: b2Transform)
        
        '//TODO_BORIS
        #rem
        '/*
        'manifold.pointCount = 0
        'Local tMat : b2Mat22
        'Local tVec1 : b2Vec2
        'Local tVec2 : b2Vec2
        'Local tX :Float
        'Local tY :Float
        'Local tPoint :b2ManifoldPoint
        'Local ratio :Float
        '//b2Vec2 v1 = b2Mul(xf2, edge->GetVertex1())
        'tMat = xf2.R
        'tVec1 = edge.m_v1
        'Local v1X :Float = xf2.position.x + (tMat.col1.x * tVec1.x + tMat.col2.x * tVec1.y)
        'Local v1Y :Float = xf2.position.y + (tMat.col1.y * tVec1.x + tMat.col2.y * tVec1.y)
        '//b2Vec2 v2 = b2Mul(xf2, edge->GetVertex2())
        'tVec1 = edge.m_v2
        'Local v2X :Float = xf2.position.x + (tMat.col1.x * tVec1.x + tMat.col2.x * tVec1.y)
        'Local v2Y :Float = xf2.position.y + (tMat.col1.y * tVec1.x + tMat.col2.y * tVec1.y)
        '//b2Vec2 n = b2Mul(xf2.R, edge->GetNormalVector())
        'tVec1 = edge.m_normal
        'Local nX :Float = (tMat.col1.x * tVec1.x + tMat.col2.x * tVec1.y)
        'Local nY :Float = (tMat.col1.y * tVec1.x + tMat.col2.y * tVec1.y)
        '//b2Vec2 v1Local = b2MulT(xf1, v1)
        'tMat = xf1.R
        'tX = v1X - xf1.position.x
        'tY = v1Y - xf1.position.y
        'Local v1LocalX :Float = (tX * tMat.col1.x + tY * tMat.col1.y )
        'Local v1LocalY :Float = (tX * tMat.col2.x + tY * tMat.col2.y )
        '//b2Vec2 v2Local = b2MulT(xf1, v2)
        'tX = v2X - xf1.position.x
        'tY = v2Y - xf1.position.y
        'Local v2LocalX :Float = (tX * tMat.col1.x + tY * tMat.col1.y )
        'Local v2LocalY :Float = (tX * tMat.col2.x + tY * tMat.col2.y )
        '//b2Vec2 nLocal = b2MulT(xf1.R, n)
        'Local nLocalX :Float = (nX * tMat.col1.x + nY * tMat.col1.y )
        'Local nLocalY :Float = (nX * tMat.col2.x + nY * tMat.col2.y )
        'Local separation1 :Float
        'Local separationIndex1 : Int = -1
        '// which normal on the poly found the shallowest depth?
        'Local separationMax1 :Float = -Constants.FMAX
        '// the shallowest depth of edge in poly
        'Local separation2 :Float
        'Local separationIndex2 : Int = -1
        '// which normal on the poly found the shallowest depth?
        'Local separationMax2 :Float = -Constants.FMAX
        '// the shallowest depth of edge in poly
        'Local separationMax :Float = -Constants.FMAX
        '// the shallowest depth of edge in poly
        'Local separationV1 : Bool = False
        '// is the shallowest depth from edges v1 or v2 vertex?
        'Local separationIndex : Int = -1
        '// which normal on the poly found the shallowest depth?
        'Local vertexCount : Int = polygon.m_vertexCount
        'Local vertices : Array = polygon.m_vertices
        'Local normals : Array = polygon.m_normals
        'Local enterStartIndex : Int = -1
        '// the last poly vertex above the edge
        'Local enterEndIndex : Int = -1
        '// the first poly vertex below the edge
        'Local exitStartIndex : Int = -1
        '// the last poly vertex below the edge
        'Local exitEndIndex : Int = -1
        '// the first poly vertex above the edge
        '// the "N" in the following variables refers to the edges normal.
        '// these are projections of poly vertices along the edges normal,
        '// a.k.a. they are the separation of the poly from the edge.
        'Local prevSepN :Float = 0.0
        'Local nextSepN :Float = 0.0
        'Local enterSepN :Float = 0.0
        '// the depth of enterEndIndex under the edge a((stored) separation, so its negative)
        'Local exitSepN :Float = 0.0
        '// the depth of exitStartIndex under the edge a((stored) separation, so its negative)
        'Local deepestSepN :Float = Constants.FMAX
        '// the depth of the deepest poly vertex under the end a((stored) separation, so its negative)
        '// for each poly normal, get the edges depth into the poly.
        '// for each poly vertex, get the vertexs depth into the edge.
        '// use these calculations to define the remaining variables declared above.
        'tVec1 = vertices.Get(vertexCount-1)
        'prevSepN = (tVec1.x - v1LocalX) * nLocalX + (tVec1.y - v1LocalY) * nLocalY
        'For Local i:Int = 0 Until vertexCount
        '
        'tVec1 = vertices.Get(i)
        'tVec2 = normals.Get(i)
        'separation1 = (v1LocalX - tVec1.x) * tVec2.x + (v1LocalY - tVec1.y) * tVec2.y
        'separation2 = (v2LocalX - tVec1.x) * tVec2.x + (v2LocalY - tVec1.y) * tVec2.y
        'if (separation2 < separation1)
        '
        'if (separation2 > separationMax)
        '
        'separationMax = separation2
        'separationV1 = False
        'separationIndex = i
        'End
        '
        'Else
        '
        '
        'if (separation1 > separationMax)
        '
        'separationMax = separation1
        'separationV1 = True
        'separationIndex = i
        'End
        'End
        '
        'if (separation1 > separationMax1)
        '
        'separationMax1 = separation1
        'separationIndex1 = i
        'End
        '
        'if (separation2 > separationMax2)
        '
        'separationMax2 = separation2
        'separationIndex2 = i
        'End
        'nextSepN = (tVec1.x - v1LocalX) * nLocalX + (tVec1.y - v1LocalY) * nLocalY
        'if (nextSepN >= 0.0 And prevSepN < 0.0)
        '
        'if( (i = 0)  )
        'exitStartIndex = vertexCount-1
        'Else
        '
        '
        'exitStartIndex = i-1
        '
        'End
        '
        'exitEndIndex = i
        'exitSepN = prevSepN
        'Else  if (nextSepN < 0.0 And prevSepN >= 0.0)
        '
        '
        'if( (i = 0)  )
        'enterStartIndex = vertexCount-1
        'Else
        '
        '
        'enterStartIndex = i-1
        '
        'End
        '
        'enterEndIndex = i
        'enterSepN = nextSepN
        'End
        '
        'if (nextSepN < deepestSepN)
        '
        'deepestSepN = nextSepN
        'End
        '
        'prevSepN = nextSepN
        'End
        'if (enterStartIndex = -1)
        '
        '// entirely(poly) below or entirely above edge, return with no contact:
        'return
        'End
        '
        'if (separationMax > 0.0)
        '
        '// laterally(poly) disjoint with edge, return with no contact:
        'return
        'End
        '// if the near(poly) a convex corner on the edge
        'if ((separationV1 And edge.m_cornerConvex1) Or (Not(separationV1) And edge.m_cornerConvex2))
        '
        '// if shallowest depth was from edge into poly,
        '// use the edges the(vertex) contact point:
        'if (separationMax > deepestSepN + b2Settings.b2_linearSlop)
        '
        '// if -normal closer(angle) to adjacent edge than this edge,
        '// let the adjacent edge handle it and return with no contact:
        'if (separationV1)
        '
        'tMat = xf2.R
        'tVec1 = edge.m_cornerDir1
        'tX = (tMat.col1.x * tVec1.x + tMat.col2.x * tVec1.y)
        'tY = (tMat.col1.y * tVec1.x + tMat.col2.y * tVec1.y)
        'tMat = xf1.R
        'v1X = (tMat.col1.x * tX + tMat.col2.x * tY)
        '// note abuse of v1...
        'v1Y = (tMat.col1.y * tX + tMat.col2.y * tY)
        'tVec2 = normals.Get(separationIndex1)
        'if (tVec2.x * v1X + tVec2.y * v1Y >= 0.0)
        '
        'return
        'End
        '
        'Else
        '
        '
        'tMat = xf2.R
        'tVec1 = edge.m_cornerDir2
        'tX = (tMat.col1.x * tVec1.x + tMat.col2.x * tVec1.y)
        'tY = (tMat.col1.y * tVec1.x + tMat.col2.y * tVec1.y)
        'tMat = xf1.R
        'v1X = (tMat.col1.x * tX + tMat.col2.x * tY)
        '// note abuse of v1...
        'v1Y = (tMat.col1.y * tX + tMat.col2.y * tY)
        'tVec2 = normals.Get(separationIndex2)
        'if (tVec2.x * v1X + tVec2.y * v1Y <= 0.0)
        '
        'return
        'End
        'End
        'tPoint = manifold.points.Get(0)
        'manifold.pointCount = 1
        '//manifold->normal = b2Mul(xf1.R, normals.Get(separationIndex))
        'tMat = xf1.R
        'tVec2 = normals.Get(separationIndex)
        'manifold.normal.x = (tMat.col1.x * tVec2.x + tMat.col2.x * tVec2.y)
        'manifold.normal.y = (tMat.col1.y * tVec2.x + tMat.col2.y * tVec2.y)
        'tPoint.separation = separationMax
        'tPoint.id.features.IncidentEdge = separationIndex
        'tPoint.id.features.IncidentVertex = b2Collision.b2_nullFeature
        'tPoint.id.features.ReferenceEdge = 0
        'tPoint.id.features.Flip = 0
        'if (separationV1)
        '
        'tPoint.localPoint1.x = v1LocalX
        'tPoint.localPoint1.y = v1LocalY
        'tPoint.localPoint2.x = edge.m_v1.x
        'tPoint.localPoint2.y = edge.m_v1.y
        'Else
        '
        '
        'tPoint.localPoint1.x = v2LocalX
        'tPoint.localPoint1.y = v2LocalY
        'tPoint.localPoint2.x = edge.m_v2.x
        'tPoint.localPoint2.y = edge.m_v2.y
        'End
        '
        'return
        'End
        'End
        '// Were going to use the edges normal now.
        'manifold.normal.x = -nX
        'manifold.normal.y = -nY
        '// Check whether we only need one contact point.
        'if (enterEndIndex = exitStartIndex)
        '
        'tPoint = manifold.points.Get(0)
        'manifold.pointCount = 1
        'tPoint.id.features.IncidentEdge = enterEndIndex
        'tPoint.id.features.IncidentVertex = b2Collision.b2_nullFeature
        'tPoint.id.features.ReferenceEdge = 0
        'tPoint.id.features.Flip = 0
        'tVec1 = vertices.Get(enterEndIndex)
        'tPoint.localPoint1.x = tVec1.x
        'tPoint.localPoint1.y = tVec1.y
        'tMat = xf1.R
        'tX = xf1.position.x + (tMat.col1.x * tVec1.x + tMat.col2.x * tVec1.y) - xf2.position.x
        'tY = xf1.position.y + (tMat.col1.y * tVec1.x + tMat.col2.y * tVec1.y) - xf2.position.y
        'tMat = xf2.R
        'tPoint.localPoint2.x = (tX * tMat.col1.x + tY * tMat.col1.y )
        'tPoint.localPoint2.y = (tX * tMat.col2.x + tY * tMat.col2.y )
        'tPoint.separation = enterSepN
        'return
        'End
        'manifold.pointCount = 2
        '// the edges direction vector, but in the frame of the polygon:
        'tX = -nLocalY
        'tY = nLocalX
        'tVec1 = vertices.Get(enterEndIndex)
        'Local dirProj1 :Float = tX * (tVec1.x - v1LocalX) + tY * (tVec1.y - v1LocalY)
        'Local dirProj2 :Float
        '// The contact more(resolution) robust if the two manifold points are
        '// adjacent to each other on the polygon. So pick the first two poly
        '// vertices that are under the edge:
        'if( (enterEndIndex = vertexCount - 1)  )
        'exitEndIndex = 0
        'Else
        '
        '
        'exitEndIndex = enterEndIndex + 1
        '
        'End
        '
        'tVec1 = vertices.Get(exitStartIndex)
        'if (exitEndIndex <> exitStartIndex)
        '
        'exitStartIndex = exitEndIndex
        'exitSepN = nLocalX * (tVec1.x - v1LocalX) + nLocalY * (tVec1.y - v1LocalY)
        'End
        '
        'dirProj2 = tX * (tVec1.x - v1LocalX) + tY * (tVec1.y - v1LocalY)
        'tPoint = manifold.points.Get(0)
        'tPoint.id.features.IncidentEdge = enterEndIndex
        'tPoint.id.features.IncidentVertex = b2Collision.b2_nullFeature
        'tPoint.id.features.ReferenceEdge = 0
        'tPoint.id.features.Flip = 0
        'if (dirProj1 > edge.m_length)
        '
        'tPoint.localPoint1.x = v2LocalX
        'tPoint.localPoint1.y = v2LocalY
        'tPoint.localPoint2.x = edge.m_v2.x
        'tPoint.localPoint2.y = edge.m_v2.y
        'ratio = (edge.m_length - dirProj2) / (dirProj1 - dirProj2)
        'if (ratio > 100.0 * Constants.EPSILON And ratio < 1.0)
        '
        'tPoint.separation = exitSepN * (1.0 - ratio) + enterSepN * ratio
        'Else
        '
        '
        'tPoint.separation = enterSepN
        'End
        '
        'Else
        '
        '
        'tVec1 = vertices.Get(enterEndIndex)
        'tPoint.localPoint1.x = tVec1.x
        'tPoint.localPoint1.y = tVec1.y
        'tMat = xf1.R
        'tX = xf1.position.x + (tMat.col1.x * tVec1.x + tMat.col2.x * tVec1.y) - xf2.position.x
        'tY = xf1.position.y + (tMat.col1.y * tVec1.x + tMat.col2.y * tVec1.y) - xf2.position.y
        'tMat = xf2.R
        'tPoint.localPoint2.x = (tX * tMat.col1.x + tY * tMat.col1.y)
        'tPoint.localPoint2.y = (tX * tMat.col2.x + tY * tMat.col2.y)
        'tPoint.separation = enterSepN
        'End
        'tPoint = manifold.points.Get(1)
        'tPoint.id.features.IncidentEdge = exitStartIndex
        'tPoint.id.features.IncidentVertex = b2Collision.b2_nullFeature
        'tPoint.id.features.ReferenceEdge = 0
        'tPoint.id.features.Flip = 0
        'if (dirProj2 < 0.0)
        '
        'tPoint.localPoint1.x = v1LocalX
        'tPoint.localPoint1.y = v1LocalY
        'tPoint.localPoint2.x = edge.m_v1.x
        'tPoint.localPoint2.y = edge.m_v1.y
        'ratio = (-dirProj1) / (dirProj2 - dirProj1)
        'if (ratio > 100.0 * Constants.EPSILON And ratio < 1.0)
        '
        'tPoint.separation = enterSepN * (1.0 - ratio) + exitSepN * ratio
        'Else
        '
        '
        'tPoint.separation = exitSepN
        'End
        '
        'Else
        '
        '
        'tVec1 = vertices.Get(exitStartIndex)
        'tPoint.localPoint1.x = tVec1.x
        'tPoint.localPoint1.y = tVec1.y
        'tMat = xf1.R
        'tX = xf1.position.x + (tMat.col1.x * tVec1.x + tMat.col2.x * tVec1.y) - xf2.position.x
        'tY = xf1.position.y + (tMat.col1.y * tVec1.x + tMat.col2.y * tVec1.y) - xf2.position.y
        'tMat = xf2.R
        'tPoint.localPoint2.x = (tX * tMat.col1.x + tY * tMat.col1.y)
        'tPoint.localPoint2.y = (tX * tMat.col2.x + tY * tMat.col2.y)
        'tPoint.separation = exitSepN
        'End
        '
        '*/
        #end
    End
End



