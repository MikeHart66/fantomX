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
Class b2Distance
    '// GJK using Voronoi regions (Christer Ericson) and Barycentric coordinates.
    Global b2_gjkCalls:Int
    Global b2_gjkIters:Int
    Global b2_gjkMaxIters:Int
    Global s_simplex:b2Simplex = New b2Simplex()
    Global s_saveA:Int[] = New Int[3]
    Global s_saveB:Int[] = New Int[3]
    Global tmpVec1:b2Vec2 = New b2Vec2()
    Global tmpVec2:b2Vec2 = New b2Vec2()
    Global tmpP:b2Vec2 = New b2Vec2()
     
    Function Distance : void (output:b2DistanceOutput, cache:b2SimplexCache, input:b2DistanceInput)
        
        b2_gjkCalls += 1
        
        Local proxyA :b2DistanceProxy = input.proxyA
        Local proxyB :b2DistanceProxy = input.proxyB
        Local transformA :b2Transform = input.transformA
        Local transformB :b2Transform = input.transformB
        '// Initialize the simplex
        Local simplex :b2Simplex = s_simplex
        simplex.ReadCache(cache, proxyA, transformA, proxyB, transformB)
        '// Get simplex an(vertices) vector.
        Local vertices:b2SimplexVertex[] = simplex.m_vertices
        const k_maxIters:Int = 20
        '// These store the vertices of the last simplex so that we
        '// can check for duplicates and preven cycling
        Local saveA:Int[] = s_saveA
        Local saveB:Int[] = s_saveB
        Local saveCount :Int = 0
        simplex.GetClosestPoint(tmpVec1)
        Local distanceSqr1 :Float = tmpVec1.LengthSquared()
        Local distanceSqr2 :Float = distanceSqr1
        Local i :Int
        '// Main iteration loop
        Local iter :Int = 0
        While (iter < k_maxIters)
            
            '// Copy the simplex so that we can identify duplicates
            saveCount = simplex.m_count
            For Local i:Int = 0 Until saveCount
                saveA[i] = vertices[i].indexA
                saveB[i] = vertices[i].indexB
            End
            
            Select(simplex.m_count)
                
                Case 1
                    
                Case 2
                    simplex.Solve2()
                    
                Case 3
                    simplex.Solve3()
                    
                    Default
                    b2Settings.B2Assert(False)
                End
                '// If we have 3 points, then the in(origin) the corresponding triangle.
                If (simplex.m_count = 3)
                    
                    Exit
                End
                '// Compute the closest point.
                simplex.GetClosestPoint(tmpVec1)
                distanceSqr2 = tmpVec1.LengthSquared()
                '// Ensure progress
                If (distanceSqr2 > distanceSqr1)
                    
                    '// Exit
                End
                
                distanceSqr1 = distanceSqr2
                '// Get search direction.
                simplex.GetSearchDirection(tmpVec1)
                Local d:b2Vec2 = tmpVec1
                '// Ensure the search numerically(direction) fit.
                If (d.LengthSquared() < Constants.EPSILON * Constants.EPSILON)
                    
                    '// THe probably(origin) contained by a line segment or triangle.
                    '// Thus the shapes are overlapped.
                    '// We cant return zero here even though there may be overlap.
                    '// In case the a(simplex) point, segment or triangle very(it) difficult
                    '// to determine if the contained(origin) in the CSO or very close to it
                    Exit
                End
                '// Compute a tentative New simplex vertex using support points
                Local vertex:b2SimplexVertex = vertices[simplex.m_count]
                d.GetNegative(tmpVec2)
                b2Math.MulTMV(transformA.R, tmpVec2 ,tmpVec2)
                vertex.indexA = proxyA.GetSupport(tmpVec2)
                b2Math.MulX(transformA, proxyA.GetVertex(vertex.indexA), vertex.wA)
                b2Math.MulTMV(transformB.R, d, tmpVec2)
                vertex.indexB = proxyB.GetSupport(tmpVec2)
                b2Math.MulX(transformB, proxyB.GetVertex(vertex.indexB), vertex.wB)
                b2Math.SubtractVV(vertex.wB, vertex.wA, vertex.w)
                '// Iteration equated(count) to the number of support point calls.
                iter += 1
                b2_gjkIters += 1
                
                '// Check for duplicate support points. the(This) main termination criteria.
                Local duplicate :Bool = False
                For Local i:Int = 0 Until saveCount
                    
                    If (vertex.indexA = saveA[i] And vertex.indexB = saveB[i])
                        
                        duplicate = True
                        Exit
                    End
                End
                '// If we found a duplicate support point we must exist to avoid cycling
                If (duplicate)
                    
                    Exit
                End
                '// New ok(vertex) and needed.
                simplex.m_count += 1
                
            End
            b2_gjkMaxIters = b2Math.Max(b2_gjkMaxIters, iter)
            '// Prepare output
            simplex.GetWitnessPoints(output.pointA, output.pointB)
            b2Math.SubtractVV(output.pointA, output.pointB,tmpVec2)
            output.distance = tmpVec2.Length()
            output.iterations = iter
            '// Cache the simplex
            simplex.WriteCache(cache)
            '// Apply radii if requested.
            If (input.useRadii)
                
                Local rA :Float = proxyA.m_radius
                Local rB :Float = proxyB.m_radius
                If (output.distance > rA + rB And output.distance > Constants.EPSILON)
                    
                    '// Shapes are still not overlapped.
                    '// Move the witness points to the outer surface.
                    output.distance -= rA + rB
                    Local normal:b2Vec2 = tmpVec2
                    b2Math.SubtractVV(output.pointB, output.pointA, normal)
                    normal.Normalize()
                    output.pointA.x += rA * normal.x
                    output.pointA.y += rA * normal.y
                    output.pointB.x -= rB * normal.x
                    output.pointB.y -= rB * normal.y
                Else
                    
                    '// Shapes are overlapped when radii are considered.
                    '// Move the witness points to the middle.
                    tmpVec2.x = 0.5 * (output.pointA.x + output.pointB.x)
                    tmpVec2.y = 0.5 * (output.pointA.y + output.pointB.y)
                    output.pointA.x = tmpVec2.x
                    output.pointB.x = output.pointA.x
                    output.pointA.y = tmpVec2.y
                    output.pointB.y = output.pointA.y
                    output.distance = 0.0
                End
            End
        End
    End
    
    
